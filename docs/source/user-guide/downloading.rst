.. _downloading_gchp:

##################
Download the model
##################

The GCHP source code is hosted at https://github.com/geoschem/GCHP. To clone
the repository and checkout all git submodules for the latest release:

.. code-block:: console

   gcuser:~$ git clone --recurse-submodules https://github.com/geoschem/GCHP.git GCHP

The GCHP repository has git submodules (other repositories that are
nested inside the GCHP repository) that aren't automatically retrieved
when you do :command:`git clone`.  The :literal:`--recurse-submodules`
option tells Git to finish retrieving the source code for each
submodule.  It will also initialize and update each submodule's source
code to the proper place in its version history. You can also download
and checkout the git submodules in two steps if you prefer:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git GCHP
   gcuser:~$ git submodule update --init --recursive

By default, the source code will be on the :literal:`main` branch
which is always the last official release of GCHP.  Checking out the
official release is recommended because it is a
scientifically-validated version of the code and is easily
citable. You can find the list of past and present GCHP releases on the
`GEOS-Chem versions page <https://wiki.seas.harvard.edu/geos-chem/index.php/GEOS-Chem_versions>`_.

If you wish to use an older version of GCHP then you can checkout a version
tag and then update the git submodules. Here is an example of downloading
and checking out version 14.2.1:

.. code-block:: console

   gcuser:~$ git clone https://github.com/geoschem/GCHP.git GCHP
   gcuser:~$ git tag                   # browse available version tags
   gcuser:~$ git checkout tags/14.2.1
   gcuser:~$ git submodule update --init --recursive

Before continuing, it is worth checking that the source code was
retrieved correctly. Run :command:`git status` to check that there are
no differences. You can also run :command:`git log` to see the recent git history,
or open a gitk window to browse the history using a graphical user interface.

.. code-block:: console

   gcuser:~/GCHP$ git status
   HEAD detached at 14.2.1
   nothing to commit, working tree clean
   gcuser:~/GCHP$ git log
   gcuser:~/GCHP$ gitk &

The output of :command:`git status` should confirm your GCHP version
and that there are no modifications (nothing to commit, and a clean
working tree). It also says that you are are in detached HEAD state,
meaning you are not in a GCHP git software branch. This is true for
all submodules in the model as well. If you plan to make changes to the
source code then you must checkout a new branch within whatever submodules
you plan to develop. Here is an example for developing GEOS-Chem.

.. code-block:: console

   gcuser:~/GCHP$ cd src/GCHP_GridComp/GEOSChem_GridComp/geos-chem
   gcuser:~/GCHP$ git status
   HEAD detached at c4c4c146e
   nothing to commit, working tree clean
   gcuser:~/GCHP$ git checkout -b feature/model_dev
