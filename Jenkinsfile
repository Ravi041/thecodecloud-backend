pipeline {
   agent any
   tools {
     maven "Maven3"  
   }
   environment {
        scannerHome = tool "SonarScanner"
               //This can be nexus 3 or Nexus 2
        NEXUS_VERSION= "nexus"
        //This can be http or https
        NEXUS_PROTOCOL= "http"
        //Where your Nexus is running
        NEXUS_URL= "3.87.250.245:8081"
        // Repository Name where we will upload the artifacts
        NEXUS_REPOSITORY= "devopsodia-mvn-backendapp-snapshot"
        // Jenkins credentials id to authenticate to Nexus OSS
        NEXUS_CREDENTIAL_ID= "nexus_creds"
        AWS_ACCOUNT_ID="260205721048"
        AWS_DEFAULT_REGION="us-east-1"
        IMAGE_REPO_NAME="devopsodia-backendapp"
        IMAGE_TAG="${env.BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
   }

    stages {
        stage('Git Checkout') {
            steps {
            script{
                git branch: 'main', credentialsId: 'GitHub', url:  'https://github.com/Ravi041/thecodecloud-backend.git'  
                }  
            }
        }
        stage ('Maven Goal'){
            steps {
            script{
            sh "mvn clean install package"
            } 
        }    
        }
        stage('Static code Analisys'){
            steps {
            script{
                def mvn = tool 'Maven3';
                withSonarQubeEnv() {
                    sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=devopsodia-backendapp"
                }
            }
        }    
            
    }
        stage ('Deploying Artifact'){
            steps {
            script{
            sh "mvn deploy"
            }
        }
    }
        stage('Logging into AWS ECR') {
            steps {
            script {
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 314156154970.dkr.ecr.us-east-1.amazonaws.com"
            }
        }
    }
	// Building Docker images
        stage('Building image') {
            steps{
            script {
                dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
            }
        }
    }
    	stage('Pushing to ECR') {
		    steps{
		    script {
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
			}
		  }
		}
        stage('Trigger Update K8s') {
            steps{
            script {
                echo "triggering Update manifest Job"
                build job: 'backendapp-updatek8s', parameters: [string(name: 'DOCKERTAG', value: env.BUILD_NUMBER)]
            }
        }
    }
   }
}