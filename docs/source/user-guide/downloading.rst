

Downloading GCHP
================

You can download the GCHP source code from Github:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHPctm.git Code.GCHP


Next you need to update all the submodules. These are other repositories
that are nested in the GCHP source code. You can initialize the submodules
with

.. code-block:: console

   gcuser:~$ cd Code.GCHP
   gcuser:~/Code.GCHP$ git submodule update --init --recursive


By default, your source code will be on the :literal:`main` branch. It is a good
idea to checkout an official release rather than use the :literal:`main` branch.
You can find the list of GCHP releases `here <https://github.com/geoschem/GCHPctm/releases>`_.
Once you have decided which version you want to work with, check it out and update your
submodules:

.. code-block:: console

   gcuser:~/Code.GCHP$ git checkout 13.0.0
   gcuser:~/Code.GCHP$ git submodule update --init --recursive
