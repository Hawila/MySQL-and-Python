
pipeline {
    agent any
    environment{
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        flaskApp = "public.ecr.aws/t0o2r4y2/flask-webapp"
        mysql_image = "public.ecr.aws/t0o2r4y2/mysqldb"
        REGION = "us-east-1"
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
                sh "aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin docker login --username AWS --password-stdin public.ecr.aws/t0o2r4y2"
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
    }
}

