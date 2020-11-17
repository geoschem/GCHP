
Creating a run directory
========================

GCHP run directories are created from within the source code.
A new run directory should be created for each different version of GEOS-Chem you use. 
Git version information is logged to file :file:`rundir.version` within the run directory upon creation.

To create a run directory, navigate to the :file:`run/` subdirectory of the source code and execute shell script :file:`createRunDir.sh`.

.. code-block:: console

   gcuser:~$ cd Code.GCHP/run
   gcuser:~/Code.GCHP/run$

During the course of script execution you will be asked a series of questions:

Enter ExtData path
------------------

The first time you create a GCHP run directory on your system you will be prompted for a path to GEOS-Chem shared data directories. 
The path should include the name of your :file:`ExtData/` directory and should not contain symbolic links. 
The path you enter will be stored in file :file:`.geoschem/config` in your home directory as environment variable :envvar:`GC_DATA_ROOT`. 
If that file does not already exist it will be created for you. 
When creating additional run directories you will only be prompted again if the file is missing or if the path within it is not valid.

.. code-block:: none

   -----------------------------------------------------------
   Enter path for ExtData:
   -----------------------------------------------------------

Choose a simulation type
------------------------

Enter the integer number that is next to the simulation type you want to use.

.. code-block:: none

   -----------------------------------------------------------
   Choose simulation type:
   -----------------------------------------------------------
     1. Full chemistry
     2. TransportTracers

If creating a full chemistry run directory you will be given additional options. Enter the integer number that is next to the simulation option you want to run.

.. code-block:: none

   -----------------------------------------------------------
   Choose additional simulation option:
   -----------------------------------------------------------
     1. Standard
     2. Benchmark
     3. Complex SOA
     4. Marine POA
     5. Acid uptake on dust
     6. TOMAS
     7. APM
     8. RRTMG

Choose meteorology source
-------------------------

Enter the integer number that is next to the input meteorology source you would like to use.

.. code-block:: none

   -----------------------------------------------------------
   Choose meteorology source:
   -----------------------------------------------------------
     1. MERRA2 (Recommended)
     2. GEOS-FP

Enter run directory path
------------------------

Enter the target path where the run directory will be stored. You will be prompted to enter a new path if the one you enter does not exist.

.. code-block:: none

   -----------------------------------------------------------
   Enter path where the run directory will be created:
   -----------------------------------------------------------

Enter run directory name
------------------------

Enter the run directory name, or accept the default. You will be prompted for a new name if a run directory of the same name already exists at the target path.

.. code-block:: none

   -----------------------------------------------------------
   Enter run directory name, or press return to use default:
   -----------------------------------------------------------

Enable version control (optional)
---------------------------------

Enter whether you would like your run directory tracked with git version control. 
With version control you can keep track of exactly what you changed relative to the original settings. 
This is useful for trouble-shooting as well as tracking run directory feature changes you wish to migrate back to the standard model.

.. code-block:: none

   -----------------------------------------------------------
   Do you want to track run directory changes with git? (y/n)
   -----------------------------------------------------------
