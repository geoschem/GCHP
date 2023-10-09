.. _using_aws_parallelcluster:

Set up AWS ParallelCluster
==========================

.. important::

    AWS ParallelCluster and FSx for Lustre costs hundreds or thousands of dollars per month to use. 
    See `FSx for Lustre Pricing <https://aws.amazon.com/fsx/lustre/pricing/>`_ and
    `EC2 Pricing <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for details.


AWS ParallelCluster is a service that lets you create your own HPC cluster. Using GCHP on AWS ParallelCluster is similar to using GCHP on any other HPC. 
We offer up-to-date Amazon Machine Images (AMIs) with GCHP's dependencies built and GCHP compiled through `AMI list <https://github.com/yidant/GCHP-cloud/blob/main/aws/ami.md>`_. 
These images contain pre-built GCHP source code and the tools for creating a GCHP run directory.
This page has instructions on using the AMIs to create your own ParallelCluster. 
You can also choose to set up AWS ParallelCluster for running GCHP simulations yourself, and the other GCHP documentation like :ref:`Build GCHP's dependencies <spackguide>`, :ref:`downloading_gchp`, :ref:`building_gchp`, :ref:`downloading_input_data`, and :ref:`running_gchp` is appropriate for using GCHP on AWS ParallelCluster.

The workflow for getting started with GCHP simulations using AWS ParallelCluster based on our public AMIs is

#. Create an FSx for Lustre file system for input data (:ref:`described on this page <create_fsx_for_lustre>`)
#. Configure AWS CLI (:ref:`described on this page <aws_cli_setup>`)
#. Configure AWS ParallelCluster (:ref:`described on this page <creating_your_pcluster>`)
#. Create AWS ParallelCluster with GCHP public AMIs (:ref:`described on this page <creating_your_pcluster>`)
#. Follow the normal GCHP User Guide

   a. :ref:`creating_a_run_directory`
   #. :ref:`downloading_input_data`
  
#. Running GCHP on ParallelCluster (:ref:`described on this page <create_fsx_for_lustre>`)

These instructions were written using AWS ParallelCluster 3.7.0. 

.. _create_fsx_for_lustre:

1. Create an FSx for Lustre file system
---------------------------------------

Start by creating an FSx for Lustre file system. 
This is persistent storage that will be mounted to your AWS ParallelCluster cluster.
This file system will be used for storing GEOS-Chem input data and for housing your GEOS-Chem run directories.

Refer to the official `FSx for Lustre Instructions <https://docs.aws.amazon.com/fsx/latest/LustreGuide/getting-started-step1.html>`_ for instructions on creating the file system.
Only Step 1, *Create your Amazon FSx for Lustre file system*, is necessary. 
Step 2, *Install the Lustre client*, and subsequent steps have instructions for mounting your file system to EC2 instances, but AWS ParallelCluster automates this for us.

In subsequent steps you will need the following information about your FSx for Lustre file system:

* its ID (:literal:`fs-XXXXXXXXXXXXXXXXX`)
* its subnet (:literal:`subnet-YYYYYYYYYYYYYYYYY`)
* its security group that has the inbound network rules (:literal:`sg-ZZZZZZZZZZZZZZZZZ`).

Once you have created the file system, proceed with :ref:`aws_cli_setup`.

.. _aws_cli_setup:

2. AWS CLI Installation and First-Time Setup
--------------------------------------------

Next you need to make sure you have the AWS CLI installed and configured.
The AWS CLI is a terminal command, :literal:`aws`, for working with AWS services.
If you have already installed and configured the AWS CLI previously, continue to :ref:`creating_your_pcluster`.

Install the :literal:`aws` command: `Official AWS CLI Install Instructions <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>`_. 
Once you have installed the :literal:`aws` command, you need to configure it with the credentials for your AWS account:

.. code-block:: console

   $ aws configure

For instructions on :literal:`aws configure`, refer to the `Official AWS Instructions <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>`_ or `this YouTube tutorial <https://www.youtube.com/watch?v=Rp-A84oh4G8>`_.

.. _creating_your_pcluster:

3. Create your AWS ParallelCluster 
----------------------------------

.. note::
  You should also refer to the offical AWS documentation on `Configuring AWS ParallelCluster <https://docs.aws.amazon.com/parallelcluster/latest/ug/install-v3-configuring.html>`_.
  Those instructions will have the latest information on using AWS ParallelCluster.
  The instructions on this page are meant to supplement the official instructions, and point out the important parts of the configuration for use with GCHP.

Next, install `AWS ParallelCluster <https://docs.aws.amazon.com/parallelcluster/latest/ug/parallelcluster-version-3.html>`_ with :literal:`pip`. This requires Python 3.

.. code-block:: console

   $ pip install aws-parallelcluster

Now you should have the :literal:`pcluster` command. 
You will use this command to performs actions like: creating a cluster, shutting your cluster down (temporarily), destroying a cluster, etc.

Create a cluster config file by running the :command:`pcluster configure` command:

.. code-block:: console

   $ pcluster configure --config cluster-config.yaml

For instructions on :literal:`pcluster configure`, refer to the official instructions `Configuring AWS ParallelCluster <https://docs.aws.amazon.com/parallelcluster/latest/ug/install-v3-configuring.html>`_.

The following settings are recommended:

* Scheduler: slurm
* Operating System: alinux2
* Head node instance type: c5n.large
* Number of queues: 1
* Compute instance type: c5n.18xlarge
* Maximum instance count: Your choice. 
  This is the maximum number execution nodes that can run concurrently.
  Execution nodes automatically spinup and shutdown according when there are jobs in your queue.

Now you should have a file name :file:`cluster-config.yaml`. 
This is the configuration file with setting for a cluster. 

Before starting your cluster with the :command:`pcluster create-cluster` command, you can modify :file:`cluster-config.yaml` to create cluster based on our AMIs. We provide the available AMI ID through `AMI list <https://github.com/yidant/GCHP-cloud/blob/main/aws/ami.md>`_.

You also need to modify :file:`cluster-config.yaml` so that your FSx for Lustre file system is mounted to your cluster.
Use the following :file:`cluster-config.yaml` as a template for these changes.

.. code-block:: yaml

   Region: us-east-1  # [replace with] the region with your FSx for Lustre file system
   Image:
     Os: alinux2
     CustomAmi: ami-AAAAAAAAAAAAAAAAA # [replace with] the AMI ID you want to use
   HeadNode:
     InstanceType: c5n.large  # smallest c5n node to minimize costs when head-node is up
     Networking:
       SubnetId: subnet-YYYYYYYYYYYYYYYYY  # [replace with] the subnet of your FSx for Lustre file system
       AdditionalSecurityGroups:
         - sg-ZZZZZZZZZZZZZZZZZ  # [replace with] the security group with inbound rules for your FSx for Lustre file system
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
         - subnet-YYYYYYYYYYYYYYYYY  # [replace with] the subnet of your FSx for Lustre file system (same as above)
         AdditionalSecurityGroups:
           - sg-ZZZZZZZZZZZZZZZZZ  # [replace with] the security group with inbound rules for your FSx for Lustre file system
         PlacementGroup:
           Enabled: true
       ComputeSettings:
         LocalStorage:
           RootVolume:
             VolumeType: io2

When you are ready, run the :command:`pcluster create-cluster` command.

.. code-block:: console

   $ pcluster create-cluster --cluster-name pcluster --cluster-configuration cluster-config.yaml

It may take several minutes up to an hour for your cluster's status to change to :literal:`CREATE_COMPLETE`. 
You can check the status of you cluster with the following command.

.. code-block:: console

   $ pcluster describe-cluster --cluster-name pcluster
  
Once your cluster's status is :literal:`CREATE_COMPLETE`, run the :command:`pcluster ssh` command to ssh into it.

.. code-block:: console

   $ pcluster ssh --cluster-name pcluster -i ~/path/to/keyfile.pem


At this point, your cluster is set up and you can use it like any other HPC. 
Now you can create a run directory by running the :literal:`createRunDir.sh` command. Your next steps will be following the normal instructions found in the User Guide.

.. _running_gchp_on_parallelcluster:

4. Running GCHP on ParallelCluster
--------------------------------------------

AWS ParallelCluster supports Slurm and AWS Batch job schedulers. Your cluster is set to use Slurm scheduler according to the configuration file. 
It might require the root permission to run Slurm commands or restart Slurm. 
Before you submit your job, you can start a shell as superuser by running :literal:`sudo -s`. 

You can follow :ref:`running_gchp` to run GCHP with Slurm scheduler. 