## Automated Node.js Delivery on AWS EKS

This project demonstrates a production-ready deployment of a containerized **Node.js** application on **Amazon EKS**, focusing on high availability, automated GitOps workflows, and comprehensive observability. The solution leverages **Terraform** for infrastructure, **Argo CD** for continuous delivery, and the **Prometheus stack** for cluster monitoring.

---

### Project Goals

* Deploy a scalable Node.js application on a managed Kubernetes service (EKS).


* Implement a **GitOps** workflow to automate manifest synchronization.


* Configure dynamic cloud storage and automated load balancing.


* Establish full-stack observability with industry-standard monitoring tools.



---

### High-Level Architecture

**Request Flow:** User → Application Load Balancer (via AWS Load Balancer Controller) → Nginx Ingress Controller → Node.js Service → Node.js Pods → Persistent Storage (EBS via CSI Driver).

---

### Technology Stack

* **Cloud Provider:** AWS (EKS).


* **Infrastructure as Code:** Terraform.


* **Continuous Delivery:** Argo CD (GitOps).


* **CI/CD:** GitHub Actions.


* **Ingress & Networking:** Nginx Ingress Controller & AWS Load Balancer Controller.


* **Monitoring & Observability:** Prometheus & Grafana.


* **Storage:** AWS EBS CSI Driver.

---

### CI/CD Pipeline (GitHub Actions)
The project utilizes GitHub Actions to manage four distinct automated workflows:


* **infra_pipeline:** Provisions the AWS infrastructure using Terraform, including the VPC and EKS cluster.


* **bootstrap_cluster:** Bootstraps the cluster by installing Argo CD, which then triggers the deployment of the Prometheus stack, Nginx controller, and Node.js application manifests.

* **k8s_manifests_deploy:** Validates the Kubernetes manifests for syntax and best practices before deploying them into the cluster.

* **destroy_infra:** A manual workflow to safely destroy all Terraform-managed AWS resources.

---

### Setup & Deployment Guide

#### Step 1: Configure GitHub Variables & Secrets
Add the following to your GitHub repository to enable the workflows:

**Variables:**

* **EKS_CLUSTER_NAME:** The name of your target EKS cluster.

* **AWS_REGION:** The AWS region for deployment (e.g., eu-west-1).

**Secrets:**

* **AWS_ACCESS_KEY_ID:** AWS credentials for infrastructure provisioning.

* **AWS_SECRET_ACCESS_KEY:** AWS credentials for infrastructure provisioning.


* **PAT_TOKEN:** A Personal Access Token with read:packages access to pull private images.


#### Step 2: Deployment Order

* Run the infra_pipeline to create the EKS cluster and networking.

* Run the bootstrap_cluster to initialize Argo CD and the core application stack.

* Access the application via the ALB DNS name provided in the infrastructure outputs.

---

### Design Decisions & Rationale

* **Argo CD vs. Manual Apply:** Ensures the cluster state is version-controlled and self-healing.

* **EBS CSI Driver:** Necessary for dynamic volume attachment in AWS, replacing legacy "in-tree" providers.

* **OIDC Integration:** Improves security by allowing Kubernetes service accounts to assume IAM roles without static keys.

* **HPA:** Ensures cost-efficiency by scaling down during low-traffic periods.

