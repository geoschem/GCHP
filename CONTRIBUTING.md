# Contributing Guidelines

Thank you for looking into contributing to GEOS-Chem! GEOS-Chem is a grass-roots model that relies on contributions from community members like you. Whether you're new to GEOS-Chem or a longtime user, you're a valued member of the community, and we want you to feel empowered to contribute.

Updates to the GEOS-Chem model benefit both you and the [entire GEOS-Chem community](https://geoschem.github.io/people.html).  You benefit through [coauthorship and citations](https://geoschem.github.io/new-developments.html).  Priority development needs are identified at GEOS-Chem users' meetings with updates between meetings based on [GEOS-Chem Steering Committee (GCSC)](https://geoschem.github.io/steering-committee.html) input through [Working Groups](https://geoschem.github.io/working-groups.html).

## We use GitHub and ReadTheDocs
We use GitHub to host the GCHP source code, to track issues, user questions, and feature requests, and to accept pull requests: [https://github.com/geoschem/GCHP](https://github.com/geoschem/GCHP). Please help out as you can in response to issues and user questions.

GCHP Classic documentation can be found at [gchp.readthedocs.io](https://geos-chem.readthedocs.io).

## When should I submit updates?

Submit bug fixes right away, as these will be given the highest priority.  Please see "Support Guidelines" for more information.

Submit updates (code and/or data) for mature model developments once you have submitted a paper on the topic.  Your Working Group chair can offer guidance on the timing of submitting code for inclusion into GEOS-Chem.

The practical aspects of submitting code updates are listed below.

## How can I submit updates?
We use [GitHub Flow](https://guides.github.com/introduction/flow/index.html), so all changes happen through pull requests. This workflow is [described here](https://guides.github.com/introduction/flow/index.html).

As the author you are responsible for:
- Testing your changes
- Updating the user documentation (if applicable)
- Supporting issues and questions related to your changes

### Process for submitting code updates

  1. Contact your GEOS-Chem Working Group leaders to request that your updates be added to GEOS-Chem.  They will will forward your request to the GCSC.
  2. The GCSC meets quarterly to set [GEOS-Chem model development priorities](http://wiki.geos-chem.org/GEOS-Chem_model_development_priorities). Your update will be slated for inclusion into an upcoming GEOS-Chem version.
  3. Create or log into your [GitHub](https://github.com/) account.
  4. [Fork the relevant GEOS-Chem repositories](https://help.github.com/articles/fork-a-repo/) into your Github account.
  5. Clone your forks of the GEOS-Chem repositories to your computer system.
  6. Add your modifications into a [new branch](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell) off the **main** branch.
  7. Test your update thoroughly and make sure that it works.  For structural updates we recommend performing a difference test (i.e. testing against the prior version) in order to ensure that identical results are obtained).
  8. Review the coding conventions and checklists for code and data updates listed below.
  9. Create a [pull request in GitHub](https://help.github.com/articles/creating-a-pull-request/).
  10. The [GEOS-Chem Support Team](https://geoschem.github.io/support-team.html) will add your updates into the development branch for an upcoming GEOS-Chem version.  They will also validate your updates with [benchmark simulations](http://wiki.geos-chem.org/GEOS-Chem_benchmarking).
  11. If the benchmark simulations reveal a problem with your update, the GCST will request that you take further corrective action.

### Coding conventions
The GEOS-Chem codebase dates back several decades and includes contributions from many people and multiple organizations. Therefore, some inconsistent conventions are inevitable, but we ask that you do your best to be consistent with nearby
code.

### Checklist for submitting code updates

  1. Use Fortran-90 free format instead of Fortran-77 fixed format.
  2. Include thorough comments in all submitted code.
  3. Include full citations for references at the top of relevant source code modules.
  4. Remove extraneous code updates (e.g. testing options, other science).
  5. Submit any related code or configuration files for [GCHP](https://gchp.readthedocs.io) along with code or configuration files for [GEOS-Chem Classic](https://geos-chem.readthedocs.io).

### Checklist for submitting data files

  1. Choose a final file naming convention before submitting data files for inclusion to GEOS-Chem.
  2. Make sure that all netCDF files [adhere to the COARDS conventions](https://geos-chem.readthedocs.io/en/latest/geos-chem-shared-docs/supplemental-guides/coards-guide.html).
  3. [Concatenate netCDF files](https://geos-chem.readthedocs.io/en/latest/geos-chem-shared-docs/supplemental-guides/netcdf-guide.html#concatenate-netcdf-files)  to reduce the number of files that need to be opened.  This results in more efficient I/O operations.
  4. [Chunk and deflate netCDF](https://geos-chem.readthedocs.io/en/latest/geos-chem-shared-docs/supplemental-guides/netcdf-guide.html#chunk-and-deflate-a-netcdf-file-to-improve-i-o) files in order to improve file I/O.
  5. Include an updated [HEMCO configuration file](https://hemco.readthedocs.io/en/latest/hco-ref-guide/hemco-config.html) corresponding to the new data.
  6. Include a README file detailing data source, contents, etc.
  7. Include script(s) used to process original data
  8. Include a summary or description of the expected results (e.g. emission totals for each species)

Also follow these additional steps to ensure that your data can be read by GCHP:

  1. All netCDF data variables should be of type `float` (aka `REAL*4`) or `double` (aka `REAL*8`).
  2. Use a recent reference datetime (i.e. after `1900-01-01`) for the netCDF `time:units` attribute.
  3. The first time value in each file should be 0, corresponding with the reference datetime.

## How can I request a new feature?
We accept feature requests through issues on GitHub. To request a new feature, **[open a new issue](https://github.com/geoschem/GCHP/issues/new/choose)** and select the feature request template. Please include all the information that migth be relevant, including the motivation for the feature.

## How can I report a bug?
Please see **[Support Guidelines](https://gchp.readthedocs.io/en/latest/reference/SUPPORT.html).**

## Where can I ask for help?
Please see **[Support Guidelines](https://gchp.readthedocs.io/en/latest/reference/SUPPORT.html).**
