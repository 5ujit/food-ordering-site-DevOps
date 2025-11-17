# Food-ordering-site

A simple static food-ordering site (HTML/CSS/JS).

## DevOps Integration

This repository includes sample DevOps configuration to help you build, test and deploy the static site.

- **Docker**: A `Dockerfile` and `docker-compose.yml` are provided to build and run the site locally with nginx. Run `docker-compose up --build` and open `http://localhost:8080`.
- **Jenkins**: A `Jenkinsfile` is included demonstrating a simple pipeline that builds a Docker image and runs the container on the Jenkins agent.
- **GitHub Actions**: A workflow at `.github/workflows/ci.yml` builds and pushes the Docker image to Docker Hub. Configure `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` in the repository secrets.
- **Ansible**: `ansible/site.yml` and `ansible/inventory.ini` are example playbooks to install Docker on a host, sync the project and run `docker-compose` there. Adjust the inventory and remote user.
- **Terraform**: `terraform/` contains example configuration to provision an AWS EC2 instance (requires AWS credentials). Edit `terraform/variables.tf` to set the `ami` and run `terraform init && terraform apply`.

### Quick Commands

Local Docker:

```
docker build -t food-ordering-site:local .
docker run -p 8080:80 food-ordering-site:local
docker-compose up --build
```

Jenkins:

- Create a Jenkins pipeline job that checks out this repo and runs the `Jenkinsfile`.

### Setup (step-by-step)

1. Clone the repo locally.
2. Create a `.env` file from `.env.example` and fill in secrets (Docker Hub, AWS).
3. For GitHub Actions: add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` to repository secrets.
4. For Jenkins: create credentials with ID `dockerhub-creds` (username/password) and enable pipeline job.
5. To deploy to a server using Ansible: edit `ansible/inventory.ini` to point to your host and run:

```
cd ansible
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini site.yml
```

6. To provision an EC2 instance (example): edit `terraform/terraform.tfvars.example` -> `terraform/terraform.tfvars`, then:

```
cd terraform
terraform init
terraform apply
```

### Local build & push scripts

Use the helper scripts in `scripts/` to build and push the image from macOS/Linux or Windows PowerShell.

macOS / Linux:

```
./scripts/build-and-push.sh
```

Windows PowerShell:

```
./scripts/build-and-push.ps1
```

### Secrets and credentials summary

- Docker Hub: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (or Jenkins credential `dockerhub-creds`).
- AWS: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` (used by Terraform).
- Ansible: needs SSH access to target host; configure `ansible/inventory.ini` accordingly.

GitHub Actions:

- Add Docker Hub credentials to repo secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

Ansible:

- From a control machine with `ansible` installed run:

```
cd ansible
ansible-playbook -i inventory.ini site.yml
```

Terraform:

- Configure AWS credentials in environment and run:

```
cd terraform
terraform init
terraform apply
```
