

Downloading GCHP
================

Clone the GCHP repository from GitHub:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git Code.GCHP

Next, update the submodules. These are other repositories
that are nested inside the GCHP repository. Initialize the submodules:

.. code-block:: console

   gcuser:~$ cd Code.GCHP
   gcuser:~/Code.GCHP$ git submodule update --init --recursive


By default, your source code will be on the :literal:`main` branch. It is a good
idea to checkout an official release rather than use the :literal:`main` branch.
You can find the list of GCHP releases `here <https://github.com/geoschem/GCHPctm/releases>`_.
Checkout the version that you want to work with, and update your submodules:

.. code-block:: console

   gcuser:~/Code.GCHP$ git checkout 13.0.0-beta.1
   gcuser:~/Code.GCHP$ git submodule update --init --recursive

.. note::
   Version 13 is not officially released yet. Until then, the most recent
   commit to :literal:`main` is the most stable version of GCHP. Therefore,
   we recommend you checkout :literal:`main`, rather than a version
   like :literal:`13.0.0-beta.1`. E.g.:

   .. code-block:: console

      $ git checkout main   # recommended until version 13 is officially released

   Once version 13 is released, we will resume recommending users checkout
   a specific version.
