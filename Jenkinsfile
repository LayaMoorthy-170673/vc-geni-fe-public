pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'sftp-vc'
        IMAGE_TAG = 'geni-fe-bmw-${BUILD_NUMBER}'
	AWS_DEFAULT_REGION = 'us-east-1'
	AWS_ACCOUNT_ID = '442426895473'
	registryCredential = 'aws-sftp-creds'
        AWS_ACCESS_KEY_ID = credentials('aws-sftp-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-sftp-secret-key')
    }
    stages {
         stage('Checkout Az Repo') {
            steps {
                script {
		   dir('temp_repo2') {
                   checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'azure-repo-laya', url: 'https://EmergingTechnologySolutions@dev.azure.com/EmergingTechnologySolutions/VisionCheckout_Geni/_git/VisionCheckout_Geni_Frontend']])
                }
		   sh '''
                   rm temp_repo2/Dockerfile
		   ls
                   cp -r temp_repo2/* .
                   rm -rf temp_repo2
                   '''
	      }
            }
         } 

	// stage('SonarQube Analysis') {
	//      steps {
	// 	dir("${WORKSPACE}"){
 //                // Run SonarQube analysis n
	// 	script {
 //                    def scannerHome = tool name: 'sonarScan', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
 //                    withSonarQubeEnv(credentialsId: 'vc-jenkins-sonar') {
    
 //                        sh "echo $pwd"
	// 		sh "ls -l ${WORKSPACE}"
 //                        sh "${scannerHome}/bin/sonar-scanner \
 //                            -D sonar.projectVersion=1.0-SNAPSHOT \
 //                            -D sonar.qualityProfile=\"Sonar way\"  \
 //                            -D sonar.projectBaseDir=${WORKSPACE} \
 //                            -D sonar.projectKey=vc-geni-fe \
 //                            -D sonar.sourceEncoding=UTF-8 \
 //                            -D sonar.host.url=https://sonar.ustpace.com \
	// 		    -D sonar.security.hotspots=true"
 //                    }
 //                }
 //              }
 //            }
 //        }

	// stage('Waiting for Quality Gate'){
      
 //            steps{
 //         	 script{
 //         		 timeout(time: 5, unit: 'MINUTES') {
 //           		 def qGate = waitForQualityGate()
 //           		 if (qGate.status != 'OK') {
 //             		 qualityGate = qGate.status
 //             		 error "Pipeline aborted due to quality gate failure: ${qGate.status}"
 //            		  abortPipeline: true
 //           		 }
 //           		 qualityGate = qGate.status
 //          }
          		
 //          }
 //        }
 //      }    
 

       	stage('Check and Install Buildah') {
             steps {
                  script {
                      echo "Checking if Buildah is installed..."
                      if (sh(script: 'command -v buildah > /dev/null 2>&1', returnStatus: true) != 0) {
                          echo "Buildah not found. Installing Buildah..."
                          sh '''
                          apt-get update
                          apt-get install -y buildah
                          '''
                          } else {
                            echo "Buildah is already installed."
                          }
                        }
                     }
                }
 	    stage('Logging into AWS ECR') {
	        steps {
		          script {
		               sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | buildah login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
			            }
		
			          }
		          }

    	stage('Build and Push Image') {
  	      steps {
       	      script {

	 	        echo "Building and pushing Docker image using Buildah..."
					          // Build Docker image
                                            
		        docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1:" + registryCredential) {
                        sh 'buildah bud --no-cache --pull --force-rm --format docker ' + " -t "+ "  ${AWS_ACCOUNT_ID}" + ".dkr.ecr.us-east-1.amazonaws.com/" + "${DOCKER_IMAGE_NAME}:${IMAGE_TAG}" + " --iidfile iid ."
			sh 'buildah push --rm $(cat iid) ' + "  ${AWS_ACCOUNT_ID}" + ".dkr.ecr.us-east-1.amazonaws.com/" + "${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
		   
		                }
       		           }
  	              }
	            }
        
          }
}
