

Downloading GCHP
================

When cloning GCHP you will get the :literal:`main` branch by default.

.. code-block:: console

   $ git clone https://github.com/geoschem/gchpctm.git Code.GCHP
   $ cd Code.GCHP
   $ git submodule update --init --recursive

If you would like a different version of GCHP you can checkout the branch or tag from the top-level
directory. Beware that you must always then update the submodules again to checkout the compatible
submodule versions. If you have any unsaved changes in a submdodule, such as local GEOS-Chem
development, make sure you commit those to a branch prior to updating versions.

.. code-block:: console

   $ cd Code.GCHP
   $ git checkout tags/13.0.0-alpha.6
   $ git submodule update --init --recursive
