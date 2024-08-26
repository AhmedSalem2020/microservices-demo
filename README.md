**Microservices Demo on Google Cloud with Terraform and CI/CD Pipeline**

## Overview

This repository contains the infrastructure and deployment configuration for the **Microservices Demo (Online Boutique)** application on Google Cloud. The application is a cloud-native microservices demo where users can browse items, add them to the cart, and purchase them.

## Solution Design

The solution leverages Google Kubernetes Engine (GKE) to host the microservices application, with Terraform handling the infrastructure provisioning. A CI/CD pipeline is implemented using Google Cloud Build and Skaffold to ensure automated deployment and scalability.

## Acceptance Criteria

The project ensures best practices in Terraform-based infrastructure provisioning. This includes correct networking and security settings, such as adhering to required IP ranges and enforcing least privilege principles for IAM roles. A fully functional CI/CD pipeline deploys the microservices, exposing the frontend via a LoadBalancer.

## Architecture

**Online Boutique** is composed of 11 microservices written in different
languages that talk to each other over gRPC.

[![Architecture of
microservices](./diagram.png)](./diagram.png)


| Service                                              | Language      | Description                                                                                                                       |
| ---------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [frontend](/src/frontend)                           | Go            | Exposes an HTTP server to serve the website. Does not require signup/login and generates session IDs for all users automatically. |
| [cartservice](/src/cartservice)                     | C#            | Stores the items in the user's shopping cart in Redis and retrieves it.                                                           |
| [productcatalogservice](/src/productcatalogservice) | Go            | Provides the list of products from a JSON file and ability to search products and get individual products.                        |
| [currencyservice](/src/currencyservice)             | Node.js       | Converts one money amount to another currency. Uses real values fetched from European Central Bank. It's the highest QPS service. |
| [paymentservice](/src/paymentservice)               | Node.js       | Charges the given credit card info (mock) with the given amount and returns a transaction ID.                                     |
| [shippingservice](/src/shippingservice)             | Go            | Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock)                                 |
| [emailservice](/src/emailservice)                   | Python        | Sends users an order confirmation email (mock).                                                                                   |
| [checkoutservice](/src/checkoutservice)             | Go            | Retrieves user cart, prepares order and orchestrates the payment, shipping and the email notification.                            |
| [recommendationservice](/src/recommendationservice) | Python        | Recommends other products based on what's given in the cart.                                                                      |
| [adservice](/src/adservice)                         | Java          | Provides text ads based on given context words.                                                                                   |
| [loadgenerator](/src/loadgenerator)                 | Python/Locust | Continuously sends requests imitating realistic user shopping flows to the frontend.                                              |


## Screenshots

| Home Page                                                                                                         | Checkout Screen                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of store homepage](././frontend-1.png)](././frontend-1.png) | [![Screenshot of checkout screen](./frontend-2.png)](./frontend-2.png)

## Prerequisites

- Google Cloud account with an active project.
- Google Cloud SDK installed.
- Docker installed and running.
- Terraform installed.
- GitHub account for source control.

## Setup Instructions

## Step 1: Set Up Google Cloud Environment

1. Create a Google Cloud Project:**
    - Navigate to Google Cloud Console.
    - Create a new project and note down the Project ID.

2. Enable Required APIs:
    - Kubernetes Engine API
    - Cloud Build API

3. Set Up Google Cloud Authentication:

    ```sh
    gcloud auth login
    gcloud auth application-default login
    gcloud config set project YOUR_PROJECT_ID
    ```

## Step 2: Infrastructure Provisioning with Terraform

1. Clone the Repository

    ```sh
    git clone https://github.com/AhmedSalem2020/microservices-demo.git
    cd microservices-demo
    ```

2. Update Terraform Variables:
    - Modify `variables.tf` to set your project-specific values such as `project_id`, `region`, etc.

3. Initialize Terraform:

    ```sh
    terraform init
    ```

4. Run Terraform Plan:

    ```sh
    terraform plan
    ```

5. Apply Terraform Configuration:

    ```sh
    terraform apply
    ```

## Step 3: CI/CD Pipeline with Google Cloud Build and Skaffold

1. Set Up Cloud Build Trigger:

    - Navigate to Cloud Build > Triggers in Google Cloud Console.
    - Create a new trigger to monitor changes in the GitHub repository.
    - Specify `cloudbuild.yaml` as the build configuration file.
    - Set up necessary environment variables.

2. Manual Build Trigger (Optional):

    ```sh
    gcloud builds submit --config=cloudbuild.yaml --substitutions=_ZONE=us-central1-a,_CLUSTER=demo-app-staging .
    ```

3. Deploy Using Skaffold:

    - Skaffold is integrated with Cloud Build to manage the deployment of Kubernetes resources.

4. Wait for the pods to be ready.

   ```sh
   kubectl get pods -n default 
   ```

   After a few minutes, you should see the Pods in a `Running` state:

    [![Running Pods](./pods.png)](./pods.png)

## Step 4: Access the Application

- Run the following command to get the external IP of the frontend service:

    ```sh
    kubectl get svc frontend-external -n default | awk '{print $4}'
    ```
     [![Running Pods](./svc.png)](./svc.png)

- Access the application using the external IP in your web browser to access your instance of Online Boutique:

    ```
    http://<external IP>/
    ```

## Step 5: Clean Up Resources

- Destroy Terraform Resources:

    ```sh
    terraform destroy
    ```

- This will delete all the Google Cloud resources created during the setup.

## Conclusion

This setup provides a scalable and robust environment for running the Microservices Demo on Google Cloud. By leveraging Terraform for infrastructure as code and integrating a CI/CD pipeline, the solution is both automated and easy to manage.

## Author

Ahmed Salem