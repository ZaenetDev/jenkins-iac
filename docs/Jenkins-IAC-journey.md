# DevOps Homelab Journey: From Terraform to Jenkins CI/CD

This document captures the full technical and learning journey undertaken to build an automated CI/CD pipeline in a homelab using Terraform, Ansible, Jenkins, and Proxmox. The goal was to simulate real-world DevOps responsibilities and use this experience as a showcase of self-driven learning, skill acquisition, and problem-solving.

---

## 1. Initial Dev Environment Setup

Though often skipped on resumes, the initial development environment setup was critical. We configured:

- **WSL2 with Ubuntu** on Windows for local dev.
- **VS Code** with remote SSH, extensions for Terraform, YAML, Ansible, and Git.
- **Terraform**, **Ansible**, and **Git CLI** installations.
- Cloud-init templates and basic Proxmox API research.

_Challenge:_ Dealing with multiple terminals, unfamiliar file paths, and early credential issues.

_Accomplishment:_ Set up a reproducible dev environment for full-stack IaC workflows.

---

## 2. Proxmox + Terraform Integration (Secure API)

We created a `provider.tf` file using the `telmate/proxmox` provider, and secured access with an API token instead of username/password.

_Challenge:_ 
- Understanding how to structure Terraform for Proxmox (resource blocks, provider syntax).
- Figuring out how to safely inject secrets without storing them in plaintext.

_Accomplishment:_
- Built secure Terraform code that could authenticate to Proxmox using environment variables and/or Jenkins secrets.
- Created reusable `main.tf` and `variables.tf` with a focus on safety.

---

## 3. Spinning up a Basic Ubuntu VM

With Proxmox connected, we created a Terraform plan to:

- Spin up a new Ubuntu VM from a cloud-init enabled template.
- Apply static IP, disk sizing, VM name, and SSH key injection.

_Challenge:_ 
- Slot ordering and VM hardware compatibility (IDE2 vs SCSI0).
- Proxmox-side bugs when cloud-init configs were malformed.
- Confusion around Terraform's in-place update warnings.

_Accomplishment:_ Created a portable, reproducible plan for launching new cloud-init-enabled VMs.

---

## 4. Configuring the VM with Ansible

Used Ansible to:

- Install updates
- Harden SSH
- Install Jenkins (initially manually)
- Set hostname and deploy common packages

We leveraged cloud-init to inject an SSH key, then used that key with Ansible.

_Challenge:_
- Passing secrets between Terraform → Jenkins → Ansible securely
- Vault setup and `.vault_pass.txt` errors during early builds

_Accomplishment:_
- Established a pipeline from Terraform → Ansible with private key and vault decryption.
- Kept secrets out of logs and source control.

---

## 5. Manual Jenkins Install

Initially we:

- SSH’d in
- Manually installed Jenkins
- Understood the initial wizard, unlock key, and setup flow

_Challenge:_ Had to learn the pieces Jenkins installs, where it puts config, and how to replicate manually what we later automated.

_Accomplishment:_ Understood the anatomy of Jenkins before automating it.

---

## 6. Jenkins Automation Begins

We built an Ansible playbook to automate Jenkins installation. This included:

- Repo configuration
- Java dependencies
- Unlock key bypass
- Plugin installation
- Admin credential configuration

_Challenge:_
- Vault password wasn’t found due to Jenkins running under `jenkins` user
- Secrets had to be passed via Jenkins credentials safely
- Pathing issues between Terraform + Jenkins + Ansible coordination

_Accomplishment:_ Jenkins installed, fully configured, and password-less within 2 minutes of VM creation.

---

## 7. Advanced Jenkins Setup: Wizard Bypass, Plugins, Secrets

We extended the Jenkins automation to:

- Use `init.groovy.d` to skip the wizard
- Create users and set passwords via Groovy
- Install plugins automatically (plugin.txt)

_Challenge:_
- Groovy syntax errors (missing brackets, wrong closure types)
- Jenkins wouldn’t accept secrets unless base64’d or declared properly

_Accomplishment:_ Bootstrapped Jenkins without manual input, ready to accept builds.

---

## 8. Jenkinsfile and VM Numbering by Build

We wrote a `Jenkinsfile` that:

- Pulled from GitHub
- Called Terraform with the build number as a suffix
- Passed secrets using Jenkins credentials binding plugin

_Challenge:_
- Groovy interpolation of secrets caused warning messages about insecure usage
- Had to use `withCredentials` block + `credentials('id')` style instead

_Accomplishment:_ Jenkins pipeline could launch a brand-new VM with a unique name using a single commit.

---

## 🛠️ Interlude: Git Learning Journey

We paused to:

- Learn Git fundamentals
- Understand the difference between `git commit`, `push`, `pull`, and `clone`
- Configure VS Code to push securely using a GitHub PAT
- Push a branch → test → merge to main

_Challenge:_
- PAT scopes
- VS Code not properly handling multiple Git configs

_Accomplishment:_ Built Git muscle memory and integrated version control into our pipeline.

---

## 9. Securing `sh` Calls and Secrets

We replaced all inline variable injection in `sh` with proper bindings.

_Challenge:_
- Jenkins warns if secrets are used inside double-quoted strings (`sh "some command $SECRET"`)
- We updated all commands to safely pass them in `${}` blocks or as `environment {}` vars

_Accomplishment:_ Fully secure Jenkinsfile with no leaking secrets to logs or process trees.

---

## 10. Manually Configuring a Worker Node

To prepare for distributed builds:

- Created a new VM as `jenkins-worker` using our pipeline
- Added SSH keys to allow Jenkins master to authenticate
- Registered it as a node in Jenkins UI
- Used `SSHLauncher` to connect and verify agent startup

_Challenge:_
- Matching known_hosts keys with manually supplied fingerprints
- `Permission denied` errors due to missing aliases or wrong key usage

_Accomplishment:_ Jenkins master now supports distributed builds across multiple VMs.

---

## Next Steps

- Automate worker node setup
- Build reusable modules for Terraform
- Parameterize Jenkins jobs
- Add dashboards and observability (Grafana, Zabbix)

---

## Final Notes

This entire project was done from scratch using a self-taught approach and a desire to simulate real-world DevOps problems in a homelab. Major takeaways:

- Deep understanding of how the pieces fit together (Terraform, Ansible, Jenkins, Git)
- Real-world security hygiene (secrets management, credential boundaries)
- Infrastructure lifecycle automation

This portfolio will continue to evolve. All configs, pipelines, and infra are reusable and production-inspired.

