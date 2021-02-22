#!bin/bash

aws iam create-role --role-name vmimport --assume-role-policy-document "file://C:\Users\lucas\Documents\Projects\ImportVM\trust-policy.json"
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://C:\Users\lucas\Documents\Projects\ImportVM\role-policy.json"
aws ec2 import-image --description "My server disk vm" --disk-containers "file://C:\Users\lucas\Documents\Projects\ImportVM\containers.json"
