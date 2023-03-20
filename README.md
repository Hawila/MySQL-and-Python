# Sprints Ai DevOps Final Project
this project will use terraform to install EKS cluster of two nodes,ec2 instance and ecr to push new build of Flask app.

using ansible script to configure ec2 instance and install all pre-req.
check installation steps below for how to install and configure

Project Files:

- Terraform Files for provisioning infrastructure 
- ansible script to configure ec2 instance 
- DockerFile for flask web app and mysqldb 
- docker-compose for local run
- jenkins file for CI/CD
- bash Script for terraform and ansible automation

## Dependencies

- Terraform installed
check installation guide here https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

- ansible https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

- [Optional] Docker to run docker-compose up and test app local https://docs.docker.com/engine/install/
- Aws cli 
```bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
``` 
- set up authentication credentials for your AWS account (important)
```bash
    aws configure
```
then edit 
```bash
    [default]
    aws_access_key_id = YOUR_ACCESS_KEY
    aws_secret_access_key = YOUR_SECRET_KEY
```   

## Installation
Clone the project first
```bash
    git clone https://github.com/Hawila/MySQL-and-Python.git
```
we have two installation process 
- using bash script 
- Manually
### execute bash script
run this command to make bash exec 
```bash
    chmod u+x bash.sh
```
execute the script
```bash
    ./bash.sh
```
script will run everything in terraform and ansible to create the infrastructure and will create a log file in project dir consist of all steps done 
![bash-log](https://user-images.githubusercontent.com/23001599/226409475-6ff6e7d3-470d-43fb-8ae0-f793eda13e35.png)


Skip Manual installation  

### Manual installation
 cd into terraform 
```bash
    cd terraform/
```
run terraform init the terraform apply
```bash
    terraform init
    terraform apply 
```
Through terraform apply process 2 local-execute occured into shell 
- first local-exec create ec2-key.pem in Home Dir ~/ec2-key
- Second local-exec create inventory.txt in ansible dir 
![3](https://user-images.githubusercontent.com/23001599/226409635-36709a83-b1af-4846-a14a-3a5316448a23.png)


 cd into ansible and change ec2-key permission for successful connection 
```bash
    cd ../ansible
    chmod 400 ~/ec2-key.pem
```
next run ansible-playbook 
```bash
    ansible-playbook -i inventory.txt install-jenkins.yml
```
### Configure Jenkins
![8](https://user-images.githubusercontent.com/23001599/226410198-7fd0a65c-3594-4fb4-bcdb-96d8d04829d3.png)

after complation of ansible script cd into home dir and connect to ec2 by ssh

```bash
    cd ~
    ssh -i ec2-key.pem ubuntu@<instance-ip-address>
```
![9](https://user-images.githubusercontent.com/23001599/226410335-a088ae3a-a5a2-4448-9d43-ae2f721a0457.png)

configure aws credintial first
```bash
    aws configure
```

![14](https://user-images.githubusercontent.com/23001599/226410373-bb562d3c-b826-4756-b658-4dc6df9ca854.png)
cat the following then copy the result 
```bash
    cat /var/lib/jenkins/secret/initialAdminPassword
```
now open browser and navigate to this url <ec2-instance-public-ip>:8080 
- paste the value here
    
![10](https://user-images.githubusercontent.com/23001599/226410616-203ecaa5-aacb-4b92-9038-103efc318f6b.png)

- install suggested plugins
![11](https://user-images.githubusercontent.com/23001599/226410674-a863d0a9-31af-48c2-ad2d-a4acebc27e8e.png)

- click save and finish (save this url for later we will use it in github webhook payload)
![12](https://user-images.githubusercontent.com/23001599/226410932-57b6257b-6479-4bc5-94bf-3857fc969065.png)


Next go to Manage jenkins Credintials and add the following
- github Credintial As username with password
- aws_access_key as secret text
- aws_secret_access_key as secret text 
![13](https://user-images.githubusercontent.com/23001599/226411345-3bddf099-d076-49ca-9dcc-f22dfb638815.png)


## Configure Pipeline
- create new item
- choose pipeline or multibranch pipeline 
- check github hook trigger in build triggers
![16](https://user-images.githubusercontent.com/23001599/226411390-c6da231e-fd5d-45ee-8fe3-cedd3868ad44.png)

- choose pipeline from scm 
![17](https://user-images.githubusercontent.com/23001599/226411448-bc1dbe85-3840-4084-ae4f-240243fe7382.png)


## Configure github webhook
- in github repo go to repo setting click on webhook and configure as following 
![15](https://user-images.githubusercontent.com/23001599/226411479-66660dc7-7efb-4148-8444-1b3dd4f379d0.png)


### Everything is configured and any commit to the repo will trigger the pipeline that will
### run jenkins file in the repo that do the following 
    - clone repo
    - build flask web image - mysql db image
    - login to ecr and push the new flask and db images to ecr
    - EKS kubeconfig
    - update deployment and statefulset yaml file with the new built images
    - install ingress controller
    - deploy all kubernates filles 
    - (BONUS) Last stage getting ingress service controller description as json format and use a jq to extract value of LoadBalancer ingress url the applying sed command  in place to add http to url to make it hyperlink then cat the result to the console log  
---------
    
![18](https://user-images.githubusercontent.com/23001599/226412361-b626f0e7-19b5-4130-873c-05c80e20a19f.png)


- pipeline will echo url of loadbalancer in logs 

![19](https://user-images.githubusercontent.com/23001599/226412407-0a4f3b47-c6f3-44df-a3ff-5340b87b413c.png)


- open url in browser will navigate to flask web app frontend
 
![20](https://user-images.githubusercontent.com/23001599/226412461-fd775b98-fa2b-4125-bfe3-838d59f75a23.png)


- click sign up (email must be like this format (anystring @ anystring.com)
- now login with your credintials and add wish 
![22](https://user-images.githubusercontent.com/23001599/226412501-daec7849-e458-4b2e-bd2b-d0e0396d8bf6.png)


- github hook log
![hook-log](https://user-images.githubusercontent.com/23001599/226412536-ca6b257b-1d89-42e9-8be8-cefda33f1d1c.png)


- (BONUS)liveness and readiness using tcp socket 
configured in deployment.yml file 
![liveness-rediness](https://user-images.githubusercontent.com/23001599/226412575-7f5ba0ea-9047-42e2-9dd1-13efcd4cfc7b.png)




