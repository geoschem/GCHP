.. _downloading_gchp:

##################
Download the model
##################

The GCHP source code is hosted at https://github.com/geoschem/GCHP. Clone
the repository:

.. code-block:: console

   gcuser:~$ git clone --recurse-submodules https://github.com/geoschem/GCHP.git GCHP

The GCHP repository has submodules (other repositories that are
nested inside the GCHP repository) that aren't automatically retrieved
when you do :command:`git clone`.  The :literal:`--recurse-submodules`
option tells Git to finish retrieving the source code for each
submodule.  It will also initialize and update each submodule's source
code to the proper place in its version history.

By default, the source code will be on the :literal:`main` branch
which is always the last official release of GCHP.  Checking out the
official release is recommended because it is a
scientifically-validated version of the code and is easily
citable. You can find the list of past and present GCHP releases `here
<https://github.com/geoschem/GCHP/releases>`_.

.. tip::

   To use an older GCHP version (e.g. 14.0.0), follow
   these additional steps:

   .. code-block:: console

      gcuser:~/GCHP$ git checkout tags/14.0.0                  # Points HEAD to the tag "14.0.0"
      gcuser:~/GCHP$ git branch version_14.0.0                 # Creates a new branch at tag "14.0.0"
      gcuser:~/GCHP$ git checkout version_14.0.0               # Checks out the version_14.0.0 branch
      gcuser:~/GCHP$ git submodule update --init --recursive   # Reverts submodules to the "14.0.0" tag

   You can do this for any tag in the version history.   For a list of
   all tags, type:

   .. code-block:: console

      gcuser:~/GCHP$ git tag

   If you have any unsaved changes, make sure you commit those to a
   branch prior to updating versions.

Before continuing, it is worth checking that the source code was
retrieved correctly. Run :command:`git status` to check that there are
no differences:

.. code-block:: console

   gcuser:~/GCHP$ git status
   HEAD detached at 14.0.0
   nothing to commit, working tree clean
   gcuser:~/GCHP$

The output of :command:`git status` should confirm your GCHP version
and that there are no modifications (nothing to commit, and a clean
working tree). It also says that you are are in detached HEAD state,
meaning you are not in a GCHP git software branch. This is true for
all submodules in the model as well. If you wish to use version
control to track your changes you must checkout a new branch to work
on in the directory you will be developing.
