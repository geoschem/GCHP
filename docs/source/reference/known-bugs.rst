.. _gchp-known-bugs:

#####################
Known bugs and issues
#####################

Please see our `Issue tracker on GitHub
<https://github.com/geoschem/gchp/issues>`_ for a list of recent
bugs and fixes.

===================
Current bug reports
===================

These `bug reports (on GitHub)
<https://github.com/geoschem/gchp/issues?q=is%3Aissue+is%3Aopen+label%3A%22category%3A+Bug%22>`_
are currently unresolved. We hope to fix these in future releases.

.. _gc-known-bugs-gcc12:

=======================================
Other issues that you should know about
=======================================

GCC 12.2.0 is discontinued in Spack v1.0.0
------------------------------------------

As of Spack v1.0, `spack-packages <https://packages.spack.io/>`_ has
been split off into its own separate repository. This change includes
the unfortunate deprecation of the :program:`GNU Compiler Collection
(GCC)` version 12.2.0. It appears that only the most recent minor
release in each major release is now treated as stable. These
deprecations are updated promptly for example, GCC 12.4.0 is already
marked as deprecated just 10 days after the release of GCC 12.5.0.

Deprecated GCC versions are no longer listed with the :command:`spack
info` command, so rather than warning users about deprecation, Spack
simply fails with an unhelpful error message about not being able to
satisfy the request.

For the time being, we recommend that you use `Spack release v0.23.1
<https://github.com/spack/spack/releases/tag/v0.23.1>`_ which still
supports GCC 12.2.0 and related libraries.  Please see our
supplemental guide entitled :ref:`spackguide` for an updated Spack
installation workflow.

We will likely need to wait until MAPL 2.55 is implemented in GCHP
before we can build the GCHP library environment with Spack v1.0.
MAPL 2.55 should be compatible with GCC 14 and later versions, but we
will need to test this.

Discontinuity in GEOS-FP convection at 01 Jun 2020
--------------------------------------------------

The convection scheme used for GEOS-FP met generation changed from RAS
to Grell-Freitas with impact on GEOS-FP meteorology files starting
June 1, 2020, specifically enhanced vertical transport. In addition,
there is a bug in convective precipitation flux following the switch
where all values are zero. While this bug is automatically fixed by
computing fluxes online for runs starting on or after June 1 2020, the
fix assumes meteorology year corresponds to simulation year. Due to
these issues we recommend splitting up GEOS-FP runs in time such that
a single simulation does not run across June 1, 2020. Instead. set one
run to stop on June 1 2020 and then restart a new run from there. If
you wish to use a GEOS-FP meteorology year different from your
simulation year please create a GEOS-Chem GitHub issue for assistance.

============================
Bugs that have been resolved
============================

These `bugs (reported on GitHub) <https://github.com/geoschem/gchp/issues?q=+label%3A%22category%3A+Bug+Fix%22+>`_ have been resolved.
