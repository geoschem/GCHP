

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

   gcuser:~/Code.GCHP$ git checkout 13.0.0-beta.1
   gcuser:~/Code.GCHP$ git submodule update --init --recursive

.. note::
   Version 13 is not officially released yet. Until then, the most recent
   commit to :literal:`main` is the most stable version of GCHP. Therefore,
   we recommend you checkout :literal:`main`, rather than a version
   like :literal:`13.0.0-beta.1`, until 13.0.0 is officially released. E.g.:

   .. code-block:: console

      $ git checkout main   # recommended until version 13 is officially released

   Once version 13 is released, we will resume recommending users checkout
   a specific version.

--------------------------------------------------------------------------------------

Before continuing, it is worth checking that the source code was retrieved correctly.
Run :command:`git status` to check that there are no differences:

.. code-block:: console

   gcuser:~/Code.GCHP$ git status
   HEAD detached at 13.0.0-beta.1
   nothing to commit, working tree clean
   gcuser:~/Code.GCHP$

The output of :command:`git status` should say that you are at the right version and
that there are no modifications (nothing to commit, and a clean working tree).