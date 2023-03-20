#!/usr/bin/env bash
LOGFILE="$PWD/bash.log"
echo "$PWD/terraform"
echo -e "Change working dir to Terraform dir..\n " >> $LOGFILE
cd $PWD/terraform

echo "************************************"
echo "Init terraform">> $LOGFILE
terraform init

echo -e "creating AWS infrastructure ....\n ">> $LOGFILE
terraform apply -auto-approve
echo "************************************"

echo -e "ec2 access key created $HOME/ec2-key.pem..\n ">> $LOGFILE
echo "Ansible inventory created and updated with instance ip  in ansible dir">> $LOGFILE

echo -e "Change ex2 key permission..\n ">> $LOGFILE
chmod 400 $HOME/ec2-key.pem

echo -e "Run ansible to configure remote ec2..\n ">> $LOGFILE
cd ../ansible
ansible-playbook -i inventory.txt install-jenkins.yml 
echo "Done" >> $LOGFILE

