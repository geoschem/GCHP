.. _downloading_gchp:

Download the model
==================

The GCHP source code is hosted at https://github.com/geoschem/GCHP. Clone 
the repository:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git GCHP

The GCHP repository has submodules (other repositories that are 
nested inside the GCHP repository) that aren't automatically retrieved when
you do :command:`git clone`. To finish retrieving the GCHP source code, 
initialize and update the submodules:

.. code-block:: console

   gcuser:~$ cd GCHP
   gcuser:~/GCHP$ git submodule update --init --recursive


By default, the source code will be on the :literal:`main` branch which is always the last offocial release of GCHP. 
Checking out the official release is recommended because it is a scientifically-validated version of the
code and is easily citable. You can find the list
of past and present GCHP releases `here <https://github.com/geoschem/GCHP/releases>`_.
Checkout the release that you want to work with, and update the submodules:

.. code-block:: console

   gcuser:~/GCHP$ git checkout 13.3.4
   gcuser:~/GCHP$ git submodule update --init --recursive

--------------------------------------------------------------------------------------

Before continuing, it is worth checking that the source code was retrieved correctly.
Run :command:`git status` to check that there are no differences:

.. code-block:: console

   gcuser:~/GCHP$ git status
   HEAD detached at 13.3.4
   nothing to commit, working tree clean
   gcuser:~/GCHP$

The output of :command:`git status` should confirm your GCHP version and
that there are no modifications (nothing to commit, and a clean working tree). It also says that you are are in detached HEAD state, meaning you are not in a GCHP git software branch. This is true for all submodules in the model as well. If you wish to use version control to track your changes you must checkout a new branch to work on in the directory you will be developing.
