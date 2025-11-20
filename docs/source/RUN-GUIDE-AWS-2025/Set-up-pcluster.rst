.. _set_up_pcluster:

######################
Set up ParallelCluster
######################

AWS ParallelCluster provides a scalable HPC environment enabling users to run across multiple cores and manage scheduling. It suits GCHP to execute large-scale simulations effectively.
======================================
Installing the AWS ParallelCluster CLI
======================================

The AWS ParallelCluster CLI is a Python package and needs to be installed using pip:

.. code-block:: console
    $ pip install --upgrade aws-parallelcluster

Verify that the CLI is working and check the version:

.. code-block:: console
    $ pcluster version

.. note:: 
    It is recommended to use the latest stable version of the ParallelCluster CLI (currently 3.14.0) as it uses a simpler YAML configuration file.
    If you are using a custom AMI, make sure you install the matching version. Check :ref:`the AMI list <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>` in advance.

###############
Create Key Pair
###############

A key pair is needed as your secure identity credential to access your cluster's head node. You can create the key pair using the AWS Management Console or the AWS CLI:

.. code-block:: console
    $ aws ec2 create-key-pair --key-name your-ec2-keypair-name --query 'KeyMaterial' --output text > your-keypair-name.pem
    
Replace Key-name, your-keypair-name with your desired names.

Store your :code:`.pem` key in a secure location. It is only accessible at creation and cannot be recovered later. If you lose the private key, you will need to create a new key pair. Set strict permission to your keypair
.. code-block:: console 
    chmod 400 your-keypair-name.pem

###########################
Create GCHP ParallelCluster
###########################

Use :code:`pcluster` command to perform actions including creating a cluster, temporarily pausing it, or destroying it.

First, create a cluster configuration file by running :code:`pcluster configure` command.
    
        
        

