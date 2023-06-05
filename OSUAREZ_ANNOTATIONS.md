# Helm Chart
### Improvements

* Use an alpine image to reduce the surface attack of the image.
    * Trivy gives some critical and high vulnerabilities in the debian image
    * The alpine image contains 0 critical or high vulnerabilities
* Add version to the `Chart.yaml` file
* A custom container image should be used in any case
* Add resource constraints for the containers
* Make the container immutable
    * filesystem is read-only
    * no privileged mode
* Run process as a non-root user
* Deny all ingress and egress traffic for security reasons
* Add a more restrictive SA and do not mount the token inside the Pod
* Install all the k8s resources in the `apps` namespace 

# Terraform code
## Improvements
* Create a TF module for the resources
    * one for GKE is created
    * maybe another for the Helm resource would be nice
* Organize all the root module code inside a unique `main.tf` file


# Tests
A simple test code is added to the Terraform code to test the GKE module. 
*Note: the test has not been executed so it could contain some errors or could be incompleted in some ways. The idea is just to provide an example of how we can use Terratest to test Terraform code.*

# Multiple applications orchestration

## No dependencies between the applications
We could use any CI/CD tool to automate the different deployments using Helm or Terraform if the applications are totally independent from each other.

## Dependencies between applications
We could use some functionality in a CI/CD tool similar to the *Multi-project pipelines* in **GitlabCI**. This options gives us the possibility to trigger pipelines in different projects so we could, for example, have a project from were we can synchronize somehow all the deployments that we need to execute in order to deploy the different applications.

In case of using **ArgoCD** we could probably use the App-of-apps pattern to group multiple applications within the same ArgoCD application and use resources like *Syncwaves* and *Synchooks* to control the orchestration and synchronization between them.