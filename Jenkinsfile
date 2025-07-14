pipeline {
  agent any

  environment {
    VM_NAME = "jenkins-worker-${BUILD_NUMBER}"
    TF_IN_AUTOMATION = "true"
    PM_API_URL = credentials('pm-api-url')
    PM_API_TOKEN_ID = credentials('pm_api_token_id')
    PM_API_TOKEN_SECRET = credentials('pm_api_token_secret')
    CIPASSWORD = credentials('cipassword')
    SSH_PUBLIC_KEY = credentials('ssh_public_key')
    SSH_USER= "ubuntu"
    SSH_KEY_FILE = credentials('jenkins-ssh-key')
    ANSIBLE_VAULT_PASS = credentials('ansible-vault-pass')
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
        dir('terraform/jenkins-vm') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('terraform/jenkins-vm') {
          sh '''
            terraform plan \
              -var "vm_name=$VM_NAME" \
              -var "pm_api_url=$PM_API_URL" \
              -var "pm_api_token_id=$PM_API_TOKEN_ID" \
              -var "pm_api_token_secret=$PM_API_TOKEN_SECRET" \
              -var "cipassword=$CIPASSWORD" \
              -var "ssh_public_key=$SSH_PUBLIC_KEY"
          '''
        }
      }
    }
    
    stage('Terraform Apply') {
      steps {
        dir('terraform/jenkins-vm') {
          sh '''
            terraform apply -auto-approve \
              -var "pm_api_url=$PM_API_URL" \
              -var "pm_api_token_id=$PM_API_TOKEN_ID" \
              -var "pm_api_token_secret=$PM_API_TOKEN_SECRET" \
              -var "cipassword=$CIPASSWORD" \
              -var "ssh_public_key=$SSH_PUBLIC_KEY" \
              -var "vm_name=$VM_NAME"
          '''
        }
      }
    }
    stage('Terraform Output') {
      steps {
        dir('terraform/jenkins-vm') {
          script {
            def ip = sh(
              script: 'terraform output -raw jenkins_ip',
              returnStdout: true
            ).trim()
            env.JENKINS_VM_IP = ip
            echo "Captured VM IP: ${env.JENKINS_VM_IP}"
          }
        }
      }
    }
    stage('Run Ansible Playbook') {
    steps {
      dir('ansible') {
        sh '''
          ansible-playbook \
          -i "$JENKINS_VM_IP," \
          -u "$SSH_USER" \
          --private-key "$SSH_KEY_FILE" \
          --vault-password-file <(echo "$ANSIBLE_VAULT_PASS") \
          playbooks/jenkins.yml
          '''
        }
      }
    }
    stage('Verify Jenkins') {
      steps {
        dir('ansible') {
        sh '''
          ansible all -i "$JENKINS_IP," -m wait_for \
          -a "port=8080 timeout=60" \
          -u "$SSH_USER" --private-key "$SSH_KEY_FILE"
          '''
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
