## Automated Node.js Delivery on AWS EKS

This project demonstrates a production-ready deployment of a containerized **Node.js** application on **Amazon EKS**, focusing on high availability, automated GitOps workflows, and comprehensive observability. The solution leverages **Terraform** for infrastructure, **Argo CD** for continuous delivery, and the **Prometheus stack** for cluster monitoring.

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

* 
**Cloud Provider:** AWS (EKS).


* 
**Infrastructure as Code:** Terraform.


* 
**Continuous Delivery:** Argo CD (GitOps).


* 
**Ingress & Networking:** Nginx Ingress Controller & AWS Load Balancer Controller.


* 
**Monitoring & Observability:** Prometheus & Grafana.


* 
**Storage:** AWS EBS CSI Driver.



---

### Infrastructure Design (Terraform)

The underlying EKS cluster and supporting cloud resources are provisioned using modular **Terraform** configurations.

#### **EKS Cluster & Compute**

* Deployed a managed AWS EKS cluster with OIDC integration for fine-grained IAM roles for service accounts (IRSA).


* Configured managed node groups spread across multiple Availability Zones for high availability.



#### **Add-ons & Controllers**

* 
**AWS Load Balancer Controller:** Automates the provisioning of ALBs/NLBs when Kubernetes Ingress or LoadBalancer services are created.


* 
**EBS CSI Driver:** Enables dynamic provisioning of AWS EBS volumes directly from Kubernetes StorageClass manifests, optimized with **gp3** for performance.



---

### Kubernetes Manifests & Resources

The application is defined by a robust set of manifests managed via **Argo CD**:

* 
**Deployment & Service:** Manages the Node.js application lifecycle and internal networking.


* 
**HPA (Horizontal Pod Autoscaler):** Automatically scales pods based on CPU/Memory metrics to handle traffic spikes.


* 
**StorageClass & PVC:** Utilizes the EBS CSI driver to provide persistent storage for application data.


* 
**Ingress:** Configured with Nginx to manage external access and SSL termination.


* 
**Service Monitor:** Integrates the application with Prometheus to scrape custom metrics.



---

### GitOps & CI/CD Pipeline

1. 
**Continuous Integration:** GitHub Actions builds the Docker image and pushes it to a container registry (GHCR/ECR).


2. 
**Continuous Delivery:** Argo CD monitors the Git repository for changes to Kubernetes manifests.


3. 
**Automated Sync:** Upon a commit, Argo CD automatically synchronizes the state of the EKS cluster to match the repository, reducing manual deployment time by **70%**.



---

### Monitoring & Observability

A comprehensive monitoring stack is deployed to provide real-time insights into cluster health:

* 
**Prometheus:** Collects and stores time-series metrics from the cluster and Node.js application.


* 
**Grafana:** Visualizes metrics through customized dashboards for performance tracking.


* 
**ServiceMonitors:** Automated discovery of application endpoints for seamless metric scraping.



---

### Design Decisions & Rationale

* 
**Argo CD vs. Manual Apply:** Ensures the cluster state is version-controlled and self-healing.


* 
**EBS CSI Driver:** Necessary for dynamic volume attachment in AWS, replacing legacy "in-tree" providers.


* 
**OIDC Integration:** Improves security by allowing Kubernetes service accounts to assume IAM roles without static keys.


* 
**HPA:** Ensures cost-efficiency by scaling down during low-traffic periods.



**Would you like me to help you draft the `kustomization.yaml` or any specific Kubernetes manifests for this Node.js deployment?**
