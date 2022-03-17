.. _using_aws_parallelcluster:
Using AWS ParallelCluster
=========================

.. important::

    AWS ParallelCluster and FSx for Lustre costs several hundred dollars per month to use. 
    See `FSx for Lustre Pricing <https://aws.amazon.com/fsx/lustre/pricing/>`_ and
    `EC2 Pricing <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for details.



1. Create an FSx for Lustre file system
---------------------------------------

First, create a FSx for Lustre file system. 
This is persistent storage that will be mounted to your AWS ParallelCluster cluster.

Instructions for creating a file system: `FSx for Lustre Instructions <https://docs.aws.amazon.com/fsx/latest/LustreGuide/getting-started-step1.html>`_.

Only Step 1, *Create your Amazon FSx for Lustre file system*, is necessary. 
Step 2, *Install the Lustre client*, and onwards has instructions for mounting your file system to EC2 instances, but AWS ParallelCluster automates that for us.

In subsequent steps you will need the following information about your FSx for Lustre file system:

* its ID (:literal:`fs-XXXXXXXXXXXXXXXXX`)
* its subnet (:literal:`subnet-YYYYYYYYYYYYYYYYY`)
* its security group that has the inbound network rules (:literal:`sg-ZZZZZZZZZZZZZZZZZ`).

2. AWS CLI Installation and First-Time Setup
--------------------------------------------

`Configuring the AWS CLI <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html>`_.


3. Create your AWS ParallelCluster 
----------------------------------

.. code-block:: yaml

   Region: us-east-1  # use your 
   Image:
     Os: alinux2
   HeadNode:
     InstanceType: c5n.large  # smallest c5n node to minimize costs when head-node is up
     Networking:
       SubnetId: subnet-YYYYYYYYYYYYYYYYY  # [replace with] the subnet of your FSx for Lustre file system
       AdditionalSecurityGroups:
         - sg-ZZZZZZZZZZZZZZZZZ
     LocalStorage:
       RootVolume:
         VolumeType: io2
     Ssh:
       KeyName: AAAAAAAAAA  # [replace with] the name of your ssh key name for AWS CLI
   SharedStorage:
     - MountDir: /fsx  # [replace with] where you want to mount your FSx for Lustre file system
       Name: FSxExtData
       StorageType: FsxLustre
       FsxLustreSettings:
         FileSystemId: fs-XXXXXXXXXXXXXXXXX  # [replace with] the ID of your FSx for Lustre file system
   Scheduling:
     Scheduler: slurm
     SlurmQueues:
     - Name: main
       ComputeResources:
       - Name: c5n18xlarge
         InstanceType: c5n.18xlarge
         MinCount: 0
         MaxCount: 10  # max number of concurrent exec-nodes
         DisableSimultaneousMultithreading: true  # disable hyperthreading (recommended)
         Efa:
           Enabled: true
       Networking:
         SubnetIds:
         - subnet-YYYYYYYYYYYYYYYYY # [replace with] the subnet of your FSx for Lustre file system (same as above)
         AdditionalSecurityGroups:
           - sg-ZZZZZZZZZZZZZZZZZ
         PlacementGroup:
           Enabled: true
       ComputeSettings:
         LocalStorage:
           RootVolume:
             VolumeType: io2
