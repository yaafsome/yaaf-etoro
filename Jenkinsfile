pipeline {
    agent any

    parameters {
        // Action options
        choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Action to perform: deploy or destroy the application')
        // Namespace options, add more IRL
        choice(name: 'NAMESPACE', choices: ['yaaf'], description: 'Namespace to deploy to')
        // Release name options
        string(name: 'RELEASE_NAME', defaultValue: 'simple-web', description: 'Name of the Helm release')
    }

    environment {
        HELM_CHART_DIR = 'simple-web'
    }

    stages {
        stage('Setup') {
            // Ensure kubectl and helm are installed and connect to AKS
            steps {
                sh '''
                    helm version
                    # Log in to Azure (suppress output)
                    echo "Authenticating to Azure..."
                    az login -i > /dev/null 2>&1
                    # Connect to AKS cluster using Azure CLI
                    echo "Authenticating to AKS cluster..."
                    az aks get-credentials -n devops-interview-aks -g devops-interview-rg --overwrite-existing
                    export KUBECONFIG=~/.kube/config
                    kubelogin convert-kubeconfig -l msi
                    
                    kubectl version
                '''
                echo "ACTION: ${params.ACTION} \n NAMESPACE: ${params.NAMESPACE} \n RELEASE_NAME: ${params.RELEASE_NAME}"
            }
        }

        // Dry Run deploy before actual deployment
        stage('Validate Helm Chart') {
            when {
                expression { return params.ACTION == 'deploy' }
            }
            steps {
                script {
                    try {
                        sh """
                            echo "Running Helm dry-run to validate chart..."
                            helm upgrade --install ${params.RELEASE_NAME} ${HELM_CHART_DIR} \\
                                --namespace ${params.NAMESPACE} \\
                                --dry-run --debug
                            
                            echo "Helm chart validation successful!"
                        """
                    } catch (Exception e) {
                        echo "Helm chart validation failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Chart validation failed")
                    }
                }
            }
        }

        // Dry Run deploy before actual deployment
        stage('Validate Helm Chart') {
            when {
                expression { return params.ACTION == 'deploy' }
            }
            steps {
                script {
                    try {
                        sh '''
                            echo "Running Helm dry-run to validate chart..."
                            helm upgrade --install ${params.RELEASE_NAME} ${HELM_CHART_DIR} \
                                --namespace ${params.NAMESPACE} \
                                --set namespace=${params.NAMESPACE} \
                                --dry-run --debug
                            
                            echo "Helm chart validation successful!"
                        '''
                    } catch (Exception e) {
                        echo "Helm chart validation failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Chart validation failed")
                    }
                }
            }
        }

        // Conditional stages: Deploy or Destroy
        stage('Deploy') {
            when {
                expression { return params.ACTION == 'deploy' }
            }
            steps {
                script {
                    try {
                        sh """
                            helm upgrade --install ${params.RELEASE_NAME} ${HELM_CHART_DIR} \\
                                --namespace ${params.NAMESPACE} \\
                                --set namespace=${params.NAMESPACE}
                        """
                        echo "Deployment successful!"
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Deployment failed")
                    }
                }
            }
        }

        stage('Verify Deployment') {
            when {
                expression { return params.ACTION == 'deploy' }
            }
            steps {
                sh """
                    echo "Verifying deployment..."
                    kubectl get all -n ${params.NAMESPACE} -l app=${params.RELEASE_NAME}
                    
                    # Wait for pods to be ready
                    kubectl wait --namespace=${params.NAMESPACE} \\
                        --for=condition=ready pod \\
                        --selector=app=${params.RELEASE_NAME} \\
                        --timeout=60s
                """
            }
        }

        stage('Destroy') {
            when {
                expression { return params.ACTION == 'destroy' }
            }
            steps {
                script {
                    try {
                        sh """
                            echo "Removing deployment ${params.RELEASE_NAME} from namespace ${params.NAMESPACE}..."
                            helm uninstall ${params.RELEASE_NAME} --namespace ${params.NAMESPACE} || true
                        """
                        echo "Uninstall successful!"
                    } catch (Exception e) {
                        echo "Uninstall failed or resources didn't exist: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully! Action performed: ${params.ACTION}"
        }
        failure {
            echo "Pipeline failed! Check the logs for details."
        }
    }
}