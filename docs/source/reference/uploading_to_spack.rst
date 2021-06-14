Uploading to Spack
==================

This page describes how to upload recipe changes to Spack. Common recipe changes include updating available versions of GCHP 
and changing version requirements for dependencies.

   1. Create a fork of https://github.com/spack/spack.git and clone your fork.
   2. Change your ``SPACK_ROOT`` environment variable to point to the root directory of your fork clone.
   3. Create a descriptive branch name in the clone of your fork and checkout that branch.
   4. Make any changes to ``$SPACK_ROOT/var/spack/repos/builtin/packages/package_name/`` as desired.
   5. Install Flake8 and mypy using ``conda install flake8`` and ``conda install mypy`` if you don't already have these packages.
   6. Run Spack's style tests using ``spack style``, which will conduct tests in ``$SPACK_ROOT`` using Flake8 and mypy.
   7. (Optional) Run Spack's unit tests using ``spack unit-test``. These tests may take a long time to run. The unit tests will always be run
      when you submit your PR, and the unit tests primarily test core Spack features unrelated to specific packages, so you don't usually
      need to run these manually.
   8. Prefix your commit messages with the package name, e.g. ``gchp: added version 13.1.0``.
   9. Push your commits to your fork.
   10. Create a PR targetted to the ``develop`` branch of the original Spack repository, prefixing the PR title with the package name,
       e.g. ``gchp: added version 13.1.0``.