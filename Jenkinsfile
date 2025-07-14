/* groovylint-disable-next-line CompileStatic */
pipeline {
  agent any

  environment {
    VM_NAME = "jenkins-worker-${BUILD_NUMBER}"
    TF_IN_AUTOMATION = 'true'
    PM_API_URL = credentials('pm-api-url')
    PM_API_TOKEN_ID = credentials('pm_api_token_id')
    PM_API_TOKEN_SECRET = credentials('pm_api_token_secret')
    CIPASSWORD = credentials('cipassword')
    SSH_PUBLIC_KEY = credentials('ssh_public_key')
    SSH_USER = 'ubuntu'
    SSH_KEY_FILE = credentials('jenkins-ssh-key')
    ANSIBLE_VAULT_PASS = credentials('ansible-vault-pass')
    TERRAFORM_DIR = 'terraform/jenkins-vm'
    ANSIBLE_DIR = 'ansible'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/ZaenetDev/jenkins-iac.git',
            credentialsId: 'github-pat'
          ]]
        ])
      }
    }

    stage('Terraform Init') {
      steps {
        dir(env.TERRAFORM_DIR) {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir(env.TERRAFORM_DIR) {
          sh """
            terraform plan \
              -var "vm_name=$VM_NAME" \
              -var "pm_api_url=$PM_API_URL" \
              -var "pm_api_token_id=$PM_API_TOKEN_ID" \
              -var "pm_api_token_secret=$PM_API_TOKEN_SECRET" \
              -var "cipassword=$CIPASSWORD" \
              -var "ssh_public_key=$SSH_PUBLIC_KEY"
          """
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(env.TERRAFORM_DIR) {
          sh """
            terraform apply -auto-approve \
              -var "pm_api_url=$PM_API_URL" \
              -var "pm_api_token_id=$PM_API_TOKEN_ID" \
              -var "pm_api_token_secret=$PM_API_TOKEN_SECRET" \
              -var "cipassword=$CIPASSWORD" \
              -var "ssh_public_key=$SSH_PUBLIC_KEY" \
              -var "vm_name=$VM_NAME"
          """
        }
      }
    }
    stage('Terraform Output') {
      /* groovylint-disable-next-line NestedBlockDepth */
      steps {
        dir(env.TERRAFORM_DIR) {
          /* groovylint-disable-next-line NestedBlockDepth */
          script {
            String ip = sh(
              script: 'terraform output -raw jenkins_ip',
              returnStdout: true
            ).trim()
            env.JENKINS_IP = ip
            echo "Captured VM IP: ${env.JENKINS_IP}"
          }
        }
      }
    }
    stage('Run Ansible Playbook') {
      steps {
        withCredentials([
          file(credentialsId: 'vault-yml-file', variable: 'VAULT_FILE')
        ]) {
          /* groovylint-disable-next-line NestedBlockDepth */
          dir(env.ANSIBLE_DIR) {
            sh """
              #!/bin/bash
              echo "$ANSIBLE_VAULT_PASS" > .vault_pass.txt
              chmod 600 .vault_pass.txt

              ansible-playbook \
                -i "$JENKINS_IP," \
                -u "$SSH_USER" \
                --private-key "$SSH_KEY_FILE" \
                --vault-password-file .vault_pass.txt \
                -e "@$VAULT_FILE" \
                -e "vm_hostname=${env.VM_NAME}" \
                playbooks/install_jenkins.yml

              rm -f .vault_pass.txt \
            """
          }
        }
      }
    }
    stage('Verify Jenkins') {
      steps {
        dir(env.ANSIBLE_DIR) {
          sh """
          ansible all -i "$JENKINS_IP," -m wait_for \
          -a "port=8080 timeout=60" \
          -u "$SSH_USER" --private-key "$SSH_KEY_FILE"
          """
        }
      }
    }
    stage('Jenkins Info') {
      steps {
        echo "Jenkins deployed at: http://$JENKINS_IP:8080"
      }
    }
  }
}
