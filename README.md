# Jenkins Infrastructure as Code (IaC) Project 🚀

[![Built with Terraform](https://img.shields.io/badge/infra-terraform-blueviolet)](https://www.terraform.io/)
[![Configured with Ansible](https://img.shields.io/badge/config-ansible-red)](https://www.ansible.com/)
[![CI: Jenkins](https://img.shields.io/badge/ci-jenkins-blue)](https://www.jenkins.io/)

This project demonstrates my journey in learning and implementing Jenkins using Infrastructure as Code (IaC) principles with Terraform, Ansible, and Proxmox. It's part of my DevOps learning portfolio and reflects the skills I've built through self-teaching, hands-on debugging, and automation design.

---

## 📚 Learning Journey

🔍 Dive into the process behind this repo:

- [Jenkins IaC Journey (Full Story)](docs/Jenkins-IAC-journey.md)

---

## 🛠️ Tech Stack

- **Terraform** – Provisions Ubuntu VMs on Proxmox
- **Ansible** – Configures Jenkins and system packages
- **Jenkins** – Pipeline-driven infrastructure management
- **Proxmox** – Homelab virtualization platform
- **VS Code** – Daily driver IDE
- **GitHub** – Source control and project tracking

---

<details> <summary>📁 Repository Structure</summary>

<pre><code>### 📁 Repository Structure ``` jenkins-iac/ ├── terraform/ │ └── jenkins-vm/ # Proxmox VM provisioning ├── ansible/ │ └── playbooks/ # Jenkins install & config playbook ├── docs/ │ └── jenkins-iac-journey.md # Narrative & learning journey ├── Jenkinsfile # Declarative Jenkins pipeline └── README.md # Project overview ``` </code></pre>
</details>

---

## 💡 Highlights

- Jenkins is installed and configured via **automated pipeline**
- Jenkins agent/worker is **manually registered** (to be automated soon)
- GitHub commits can **trigger Jenkins builds**
- Built-in **credentials handling and security practices**
- Uses **cloud-init** and secret management for automation at scale

---

## 🎯 What's Next

- [ ] Automate Jenkins worker provisioning
- [ ] Add linting and validation to Jenkins pipeline
- [ ] Containerize the Jenkins master for portability
