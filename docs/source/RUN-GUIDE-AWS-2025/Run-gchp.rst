.. _gchp-2025:

########################################
Running GCHP on AWS ParallelCluster 2025
########################################
This page outlines the high-level steps required to deploy an AWS ParallelCluster, prepare the environment, and execute a GCHP simulation. Each steps links to a detailed guide for execution.

=============
Prerequisites
=============
Before you start, ensure you have the following ready on your local machine:
1. An AWS account with administrative access. Please ask your administrator for access (needed for creating pcluster, FSx, etc)
2. Python version>=3 installed
3. AWS CLI(Command-Line Interface) installed and configured. Refer to `Installing AWS CLI <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>`_ for more details.
4. :ref:`AWS ParallelCluster CLI <set_up_pcluster>` installed. 

====================================
Cluster Configuration and Deployment
====================================
On your local machine, define and launch pcluster on AWS.
1. :ref:`Create an AWS FSx for Lustre file system <create-fsx>`: Fast, parallel, mounted storage in pcluster for input data.
1. Create Configuration File: Define your cluster settings (VPC, subnets, FSx for Lustre storage, instance types, and Slurm queues) in a gchp-cluster.yaml file.
2. Deploy Cluster: Use the configuration file to launch the entire stack.

=======================
Environment Preparation
=======================

SSH into the pcluster head node first. 

..code-block:: console

    $ ssh -i /path/to/.pem/pem ec2-user@public-IPv4

We need to install the required software dependencies and download GCHP files.
1. Install dependencies: Install required libraries on the head node.
2. Download GCHP Code: Place the GCHP source code into the shared file system.
3. Download External Data: Download necessary input data and configure symbolic links.

===========================
Model Setup & Job Execution
===========================

Set up the specific run instance and compile the executable.
1. Model Setup: Create run directory, edit configuration files, and compile GCHP.
2. Use slurm to submit job: write a slurm script to define job parameters and use mpi to execute.
3. Monitor Output: Set checkpoint files, check job status, and clean up.