.. _downloading_gchp:

Downloading GCHP
================

The GCHP source code is hosted at https://github.com/geoschem/GCHP. Clone 
the repository:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git Code.GCHP

The GCHP repository has submodules (other repositories that are 
nested inside the GCHP repository) that aren't automatically retrieved when
you do :command:`git clone`. To finish retrieving the GCHP source code, 
initialize and update the submodules:

.. code-block:: console

   gcuser:~$ cd Code.GCHP
   gcuser:~/Code.GCHP$ git submodule update --init --recursive


By default, the source code will be on the :literal:`main` branch. Checking out
an official release is recommended because they are scientifically-validated versions of the
code, and it records the version for your future reference. You can find the list
of GCHP releases `here <https://github.com/geoschem/GCHP/releases>`_.
Checkout the version that you want to work with, and update the submodules:

.. code-block:: console

   gcuser:~/Code.GCHP$ git checkout 13.3.4
   gcuser:~/Code.GCHP$ git submodule update --init --recursive

--------------------------------------------------------------------------------------

Before continuing, it is worth checking that the source code was retrieved correctly.
Run :command:`git status` to check that there are no differences:

.. code-block:: console

   gcuser:~/Code.GCHP$ git status
   HEAD detached at 13.3.4
   nothing to commit, working tree clean
   gcuser:~/Code.GCHP$

The output of :command:`git status` should say that you are at the right version and
that there are no modifications (nothing to commit, and a clean working tree).
