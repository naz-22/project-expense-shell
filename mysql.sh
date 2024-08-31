#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
CHECK_ROOT()
{
if [ $USERID -ne 0  ]
then            
    echo -e "$R please run the script with root priviliges $N" | tee -a $LOG_FILE  
    exit 1
fi
}

VALIDATE()
{
 if [ $1 -ne 0 ]
 then 
    echo -e "$2 is ... $R failed $N"  | tee -a $LOG_FILE 
    exit 1
 else 
    echo -e "$2 is ...  $G success $N"  | tee -a $LOG_FILE 
 fi 

}


echo "Script started executing at : $(date)" | tee -a $LOG_FILE 

CHECK_ROOT 

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld
VALIDATE $? "Enabled MYSQL server"

systemctl start mysqld
VALIDATE $? "Started MYSQL server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Settingup root password"

