# LOG8100-projet

## Requirements

- `ansible`
- `terraform`
- `az CLI`

## Usage

### Preparation

The default Ansible configuration setups a load balancer with 3 instances of the webgoat service, each of them have a limit of 1 Gi memory usage.\
You can change these values in the `ansible.yaml` if needed.

### Launch

```sh
# Log in to your Azure account

az login

# Use terraform to set up the infrastructure on Azure

cd terraform
terraform init
terraform apply

# Use ansible to deploy the service and create a load balancer

cd ../ansible/
az aks get-credentials --resource-group aks-resource-group --name aks-cluster --file ~/config
ansible-playbook ansible.yml


```

## CI/CD Pipeline Overview

The CI/CD pipeline for this project is configured in the .GitHub/workflows/ folder. The pipeline consists of several stages,
each serving a specific purpose.

### Lint

- Run SonarCloud static analysis.

### Build

- Build the jar of the java application
- Build the docker image and deploy it on dockerhub with the SHA of the commit as tag

### Security

- Run Trivy for container image vulnerability scanning.

### Deploy

- Push the Docker image to the registry with the latest tag.

