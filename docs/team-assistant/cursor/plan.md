### Proposed Phased Implementation Plan

Let's restructure the 20 steps into a more agile, iterative process.

#### **Phase 1: The Core Application (Getting it Running)**
*Goal: Deploy a basic Open WebUI on Cloud Run with secrets managed correctly. No database, no Redis, no custom networking.*

1.  **Project & State Setup (Steps 1, 2, 3):**
    *   Validate prerequisites (the *core* ones).
    *   Create the GCS bucket for Terraform state.
    *   Use the `project-services` module to enable the **core APIs**: Run, Artifact Registry, Secret Manager, Cloud Build.

2.  **Artifacts & Secrets (Steps 7, 10):**
    *   Create the `artifact-registry` module and apply it.
    *   Create the `secret-manager` module. Create and populate the `webui-secret-key` secret.

3.  **Build the Image (Step 17):**
    *   Create the `cloudbuild.yaml` file.
    *   Manually run Cloud Build (`gcloud builds submit`) to build the Docker image (with `USE_OLLAMA=false`, `USE_CUDA=false`) and push it to your new Artifact Registry repository. **This is a critical, early step.**

4.  **Deploy to Cloud Run (Step 13):**
    *   Create a simplified `cloud-run` module.
    *   The service definition will be minimal: it points to the image in Artifact Registry and injects the `WEBUI_SECRET_KEY` from Secret Manager.
    *   **Do not** configure the VPC Connector or any database/Redis variables yet.
    *   Set the CPU, Memory, and the crucial 240s startup probe.

**Outcome of Phase 1:** Within a short time, you will have a publicly accessible Open WebUI URL. You can log in and use it. The data will be ephemeral (stored in the container), but it *works*. You can `terraform plan/apply`, test, and proceed with confidence.

---

#### **Updated Phase 2: Adding State, Persistence, and a Shared Filesystem**

*   **Goal:** Connect the running application to a persistent PostgreSQL database and a Redis cache, and provide a persistent, shared filesystem for the `/app/backend/data` directory using an NFS volume so that all user-uploaded data is saved.

#### **Step 1: Build the Core Network** (Unchanged)

*   **Action:** Create and apply a new `networking` Terraform module.
*   **Components:**
    *   A Virtual Private Cloud (VPC) to house our private resources.
    *   A **VPC Connector**, which is essential. It acts as a bridge, allowing the Cloud Run service to communicate with resources inside our private VPC (like the database, cache, and filesystem).
*   **Outcome:** A secure, private network foundation is ready.

#### **Step 2: Create Persistent Storage Services** (Updated)

*   **Action:** Create and apply three new modules: `database`, `redis`, and `filestore`.
*   **Components:**
    *   **Database Module:** Deploys a **Cloud SQL PostgreSQL** instance. It will be configured with a **private IP** only, accessible solely from within our VPC. We will add the database URL and password to Secret Manager.
    *   **Redis Module:** Deploys a **Memorystore for Redis** instance. This will also have a **private IP** only. We will add its connection URL to Secret Manager.
    *   **(New) Filestore Module:** Deploys a **Cloud Filestore** instance. This provides the NFS share.
        *   **Tier:** `BASIC_HDD` or `BASIC_SSD`.
        *   **Capacity:** 1TB (the minimum size).
        *   **File Share Name:** We'll name the share `data`.
        *   This instance will also get a **private IP** within our VPC.

*   **Outcome:** A PostgreSQL database for user/chat data, a Redis instance for caching, and an NFS file share for document persistence are all running and waiting for connections within our private network.

#### **Step 3: Upgrade Cloud Run Service with Full Connectivity** (Updated)

*   **Action:** We will significantly update our existing `cloud-run` module and apply the changes.
*   **Configuration Changes:**
    1.  **VPC Connector:** We will attach the VPC Connector created in Step 1 to the Cloud Run service. This allows it to "see" the private network.
    2.  **Database/Redis Integration:** We will add the `DATABASE_URL` and `REDIS_URL` environment variables, pulling their values securely from Secret Manager.
    3.  **(New) Volume Mount:** This is the key part. We will add two new blocks to the Cloud Run configuration in Terraform:
        *   A `volume` block that defines a volume named `data-volume` and points it to our Cloud Filestore instance's private IP and the `/data` share name.
        *   A `volume_mounts` block inside the container definition that tells Cloud Run to take the `data-volume` and mount it at the path `/app/backend/data`.

*   **Outcome:** A new revision of our Cloud Run service will be deployed. This new version will have the correct environment variables to connect to the database/cache and will have the `/app/backend/data` directory persistently mapped to our shared Cloud Filestore instance.

#### **Phase 3: Production Hardening & Automation**
*Goal: Add CI/CD, OAuth, monitoring, and the production environment.*

1.  **Implement CI/CD (Step 13, 17, 18):**
    *   Create the `cloud-build` module to define triggers that automatically run your `cloudbuild.yaml` on commits/merges.
    *   Create the deployment scripts.

2.  **Add Authentication (Step 11):**
    *   Manually configure the OAuth consent screen.
    *   Create the `oauth` module, store the client secret in Secret Manager, and update the Cloud Run service with the required `OAUTH_*` environment variables.

3.  **Layer on Operations (Step 14, 15):**
    *   Create and apply the `monitoring` module.
    *   Create the `iam` and `storage` modules to refine permissions and data handling.

4.  **Go to Production (Steps 16-20):**
    *   Create the `prod` environment in Terraform, which re-uses all your tested modules but with production-grade variables (`terraform.tfvars`).
    *   Follow the documentation and validation steps.
