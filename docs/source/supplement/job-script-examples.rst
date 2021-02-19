
Example Job Scripts
===================

These are example job scripts for GCHP batch jobs. These examples are taken from the :file:`runScriptSamples/`. See that
directory for more information and examples.

.. important::
   These are examples. You need to write your own job scripts, but these are good templates to start from.

Please share yours! Submit a pull-request on GitHub.

Examples for Various Schedulers
-------------------------------

These are simple examples for various schedulers. They are set up to use 2 nodes, and are suitable for C48 or C90 resolution.

* For PBS-based clusters: :download:`simple_batch_job.pbs.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.pbs.sh>`
* For Slurm-based clusters: :download:`simple_batch_job.slurm.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.slurm.sh>`
* For LSF-based clusters: :download:`simple_batch_job.lsf.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.lsf.sh>`

Examples for Various HPCs
-------------------------

These are simple examples for various systems. They are set up to use 2 nodes, and are suitable for C48 or C90 resolution.

* For Pleiades (NASA Advanced Supercomputing): :download:`simple_batch_job.pbs.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.pbs.sh>`
* For Cannon (Harvard): :download:`simple_batch_job.slurm.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.slurm.sh>`
* For Compute1 (WUSTL): :download:`simple_batch_job.lsf.sh <../../../run/runScriptSamples/simple_examples/simple_batch_job.lsf.sh>`

Operational Examples
--------------------

These are "full-fledged" examples. They are more complicated, but they demonstrate what
operational GCHP batch jobs look like. Initially, it's probably best to err on the side of
simplicity, and build your own automated functionality with time. 

* Auto-requeuing C360 simulation (Compute1): :download:`c360_requeuing.sh <../../../run/runScriptSamples/operational_examples/wustl_gcst/c360_requeuing.sh>`
* 1 month benchmark simulation (Cannon): :download:`gchp.benchmark.run <../../../run/runScriptSamples/operational_examples/harvard_gcst/gchp.benchmark.run>`

