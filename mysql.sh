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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MYSQL server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started MYSQL server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE --> we have to go into mysql to see the content with this cmnd.

mysql -h mysql.naziyadaws81.online  -u root -pExpenseApp@1 -e 'show databases;'&>>$LOG_FILE #but with this cmnd we can directly see the content without entering into mysql
if [ $? -ne 0 ]
then
    echo "MySql root password is not setup , settingup now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Settingup root password"
else
    echo -e "mysql root password is already setup....$Y SKIPPING $N" | tee -a $LOG_FILE
fi
