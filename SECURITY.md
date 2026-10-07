# Security Policy

## Supported Versions

GCHP does not maintain long-term-support branches. Security fixes are only provided for the most recently released version, listed in `CHANGELOG.md`.

## Reporting a Vulnerability

If you believe you have found a security vulnerability in GCHP or one of its submodules (MAPL, GMAO\_Shared, FVdycoreCubed\_GridComp, geos-chem, HEMCO, Cloud-J, HETP) — for example, a supply-chain issue in a GitHub Actions workflow, or an issue in a data-download or run-directory script that could lead to unintended code execution — please report it privately using GitHub's **[Report a vulnerability](https://github.com/geoschem/GCHP/security/advisories/new)** feature (Security tab) rather than opening a public issue.

The threat class that matters most here is **arbitrary code execution when reading a data/config file**. GCHP and its helper scripts read many files that users download or share: `GCHP.rc`, `CAP.rc`, `HISTORY.rc`, `ExtData.rc`, `HEMCO_Config.rc`, and the other `.rc` files; YAML configuration files (`geoschem_config.yml` and others); `download_data.yml` (read by `download_data.py`); and NetCDF input files. If any of these can be crafted to make the model or a script run code or shell commands, please report it.

This project is maintained by the **GEOS-Chem Support Team (GCST)** on a best-effort basis, so there is no guaranteed response SLA, but we will acknowledge reports as promptly as we can and work with you on a fix and coordinated disclosure.

## Out of Scope

Scientific-correctness bugs, numerical issues, and general "how do I..." questions are **not** security reports. Please use the normal channels described in `SUPPORT.md` and `CONTRIBUTING.md` ([GitHub issues](https://github.com/geoschem/GCHP/issues/new/choose)) for those instead.
