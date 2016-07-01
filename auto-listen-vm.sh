#!/bin/sh
IP="192.168.58.109"
OS="centos"
USER="cmcc"
password="123456"
add_bigren='"sudo su  -c \"userdel -r bigren;useradd -s /bin/bash -m bigren -g root\""'
modify_passwd='"sudo su -c \"passwd bigren\""'
create_sshkey='ssh-keygen -t rsa'


#Warning:you must add "exp_continue" when expect "cmcc*" otherwise it won't execute the command:
#"userdel -r jason;useradd -s /bin/bash -m jason -g root"
add_bigren(){
expect<<EOF
set timeout -1
spawn ssh -t $USER@$IP $add_bigren
expect {
	"cmcc*" {send "CMCC@22F\r";exp_continue}
	"userdel*" {send "\r\n";exp_continue}
	}
EOF
}
#The function of create_keygen has two functions:1,modify the password of bigren.
#2,add the sshkey for exchanging secret key for the first level machine
create_keygen()
{
expect<<EOF
	set timeout -1
	spawn ssh -t $USER@$IP $modify_passwd; 
	expect {
        	"*cmcc*" {send "CMCC@22F\r";exp_continue}
		 "*password:" {send "$password\r";exp_continue}
        	"*password:" {send "$password\r"}
	}	

	spawn ssh -t bigren@192.168.58.109 $create_sshkey;
	expect {
        	"*password:" {send "$password\r";exp_continue}
		 "Enter*" {send "\r\n";exp_continue}
       		 "Enter*" {send "\r\n";exp_continue}
       		 "Enter*" {send "\r\n"}
	}
EOF
}
add_bigren
create_keygen
