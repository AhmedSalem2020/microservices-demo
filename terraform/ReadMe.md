[CET-011] Codedeploy with Lambda and SNS using Terraform 


Discription: Deploy a simple web app using CodeDeploy, Lambda, and SNS as follows: 
     When a developer uploads a new artifact to S3 bucket this should trigger a Lambda function that starts deployment on a specific deployment group, then sends SNS notification to an email with deployment details.

Steps: 
1- Create S3 bucket named "ahmedsalem-demobucket" and upload the wep app as a zip file to it 

2- Assocaiate aws_s3_bucket_policy to the S3 bucket to all access to the bucket form within my aws acc.

2- create 2 roles 
    a- IAM role named "ahmedsalem-Ec2CodeDeploy" for ec2 with 2 policies: AmazonEC2RoleforCodeDeploy and AmazonS3FullAccess to 
       grant my EC2 instance access to S3 bucket and CodeDeploy.

    b- IAM role named "ahmedsalem-CodeDeployServiceRole" for CodeDeploy.

3- Create a security Group to allow inbound traffic on port 80 and 22 from anyone.

4- Launch ec2 instance with Role "ahmedsalem-Ec2CodeDeploy", userdata and a security Group and assocaite the instance profile with 
   my ec2.

5- Create CodeDeploy Application and Deplyment Group

6- Create a lambda role and attach 3 policies to it which AWSLambdaBasicExecutionRole, SNS Policy, CodeDeploy Policy, CloudFormation 
   Policy (to give lambda access to codeDeploy, SNS, CloudFormation)

7- Create the JavaScript code of Lambda.

8- Create S3 event notification and associate it with lambda (while uploading a new zip file then lambda 
   triggers).

9- Create the SNS resource by using aws_cloudformation_stack terraform resource 

10- Lambda sends an email to the admin mail with the deploymnet details using SNS topic. 


***AWSLambdaBasicExecutionRole***
AWSLambdaBasicExecutionRole – Permission to upload logs to CloudWatch.

***Flat Module***
Flat Module means that you just have the root module and one Child Module(child module doesn't contain nested modules) because it could be very hard to debug nested modules. So, dont define module inside child module

***To Export value form module and use it in another module:***
1- export the arribute as an output in output.tf file. see "modules\securityGroup_module\output.tf"
2- in the target module(modules/ec2_module), create a variable with that attribute. See   
   "modules\ec2_module\variables.tf" (check the type of the varaible)
3- Pass that varible in the ec2 module attribute like "vpc_security_group_ids = var.sg_id"
4- Call that variable in main.tf file like "sg_id = [module.ec2SecurityGroup.sg_id]" 