

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

   gcuser:~/Code.GCHP$ git checkout 13.0.0
   gcuser:~/Code.GCHP$ git submodule update --init --recursive
