What is CloudFormation?
-----------------------
AWS CloudFormation is a service that allows you to define and provision AWS infrastructure using code. You can create templates that describe the resources you want (like EC2 instances, VPCs, IAM roles, etc.) 
and CloudFormation will take care of provisioning and configuring those resources for you. This is particularly useful for managing HPC clusters.

AWS ParallelCluster uses AWS CloudFormation to automate the provisioning of resources. When you create a cluster, ParallelCluster generates a CloudFormation template that defines the infrastructure and configuration of your cluster. 
This template is then deployed to AWS, which creates the necessary resources (VPCs, EC2 instances, IAM roles, etc.) based on the specifications in the template. 
