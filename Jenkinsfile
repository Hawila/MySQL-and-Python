
pipeline {
    agent any
    environment{
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        flaskApp = "public.ecr.aws/t0o2r4y2/flask-webapp"
        mysql_image = "public.ecr.aws/t0o2r4y2/mysqldb"
        REGION = "us-east-1"
        CLUSTER_NAME = "sprint-cluster"
    }

    stages {
        stage('git check') {
            steps {
                git branch: 'main', credentialsId: 'github-cred' , url: 'https://github.com/Hawila/MySQL-and-Python.git'
            }
        }
        stage('Build Flask App') {
            steps {
                sh "docker build -t ${flaskApp}:$BUILD_NUMBER FlaskApp/."
            }
        }
        stage('Build Mysql db') {
            steps {
                sh "docker build -t ${mysql_image}:$BUILD_NUMBER MySQL_Queries/."
            }
        }
        stage('ECR Login') {
            steps {
                sh "aws ecr-public get-login-password --region ${REGION} | docker login --username AWS --password-stdin public.ecr.aws/t0o2r4y2"
            }
        }
        stage('Push Flask Image') {
            steps {
                sh "docker push ${flaskApp}:$BUILD_NUMBER"
            }
        }
        stage('Push Mysql Image') {
            steps {
                sh "docker push ${mysql_image}:$BUILD_NUMBER"
            }
        }
        stage('EKS kubeconfig') {
            steps {
                sh "aws eks --region ${REGION} update-kubeconfig --name ${CLUSTER_NAME}"
            }
        }
        
        stage('Updating k8s mainfest'){
            steps {
                echo 'replacing old images with the new one'
                sh "sed -i \"s|image:*|image: ${flaskApp}:$BUILD_NUMBER|g\" Kubernates/deployment.yaml"
                sh "sed -i \"s|image:*|image: ${mysql_image}:$BUILD_NUMBER|g\" Kubernates/statfulset.yaml"
            }
        }
        stage('Install ingress-controller'){
            steps{
                sh 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/aws/deploy.yaml'
            }
        }
        stage('Deploy Kubernates Files') {
            steps{
                sh'kubectl apply -f Kubernates/pv.yaml -f Kubernates/db-configmap.yaml -f Kubernates/app-configmap.yaml'
                sh'kubectl apply -f -f Kubernates/statfulset.yaml -f Kubernates/deployment.yaml'
                sh'kubectl apply -f Kubernates/ingress.yaml'
                
            }
        }
        stage('Getting Service Ip'){
            steps{
                sh '''#!/bin/bash
                    kubectl -n ingress-nginx -ojson get service ingress-nginx-controller > sv.json
                    jq '.status.loadBalancer.ingress[0].hostname' sv.json > url.txt
                    sed -i 's/^./http:\\/\\//;s/.$//' url.txt'
                    cat url.txt
                    '''
            }
        }
    }
}

