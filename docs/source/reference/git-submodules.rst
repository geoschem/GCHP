

Git Submodules
==============


Forking submodules
------------------

This sections describes updating git submodules to use your own forks. You can
update submodule so that they use your forks at any time. It is recommended you
only update the submodules that you need to, and that you leave submodules that
you don't need to modify pointing to the GEOS-Chem repositories.

The rest of this section assumes you are in the top-level of GCHPctm, i.e.,

.. code-block:: console

   $ cd GCHPctm   # navigate to top-level of GCHPctm

First, identify the submodules that you need to modify. The :file:`.gitmodules`
file has the paths and URLs to the submodules. You can see it with the following
command

.. code-block:: console

   $ cat .gitmodules 
   [submodule "src/MAPL"]
      path = src/MAPL
      url = https://github.com/sdeastham/MAPL
   [submodule "src/GMAO_Shared"]
      path = src/GMAO_Shared
      url = https://github.com/geoschem/GMAO_Shared
   [submodule "ESMA_cmake"]
      path = ESMA_cmake
      url = https://github.com/geoschem/ESMA_cmake
   [submodule "src/gFTL-shared"]
      path = src/gFTL-shared
      url = https://github.com/geoschem/gFTL-shared.git
   [submodule "src/FMS"]
      path = src/FMS
      url = https://github.com/geoschem/FMS.git
   [submodule "src/GCHP_GridComp/FVdycoreCubed_GridComp"]
      path = src/GCHP_GridComp/FVdycoreCubed_GridComp
      url = https://github.com/sdeastham/FVdycoreCubed_GridComp.git
   [submodule "src/GCHP_GridComp/GEOSChem_GridComp/geos-chem"]
      path = src/GCHP_GridComp/GEOSChem_GridComp/geos-chem
      url = https://github.com/sdeastham/geos-chem.git
   [submodule "src/GCHP_GridComp/HEMCO_GridComp/HEMCO"]
      path = src/GCHP_GridComp/HEMCO_GridComp/HEMCO
      url = https://github.com/geoschem/HEMCO.git

Once you know which submodules you need to update, fork each of them on GitHub.

Once you have your own forks for the submodules that you are going to modify, update
the submodule URLs in :file:`.gitmodules`

.. code-block:: console

   $ git config -f .gitmodules -e    # opens editor, update URLs for your forks

Synchronize your submodules

.. code-block:: console

   $ git submodule sync 

Add and commit the update to :file:`.gitmodules`.

.. code-block:: console

   $ git add .gitmodules
   $ git commit -m "Updated submodules to use my own forks"

Now, when you push to your GCHPctm fork, you should see the submodules point to your
submodule forks.