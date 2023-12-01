#!/bin/bash

#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: changeVersionNumbers.sh
#
# !DESCRIPTION: Bash script to change the version numbers in the appropriate
#  files in the GCHP directory structure.  Run this before releasing
#  a new GCHP Classic version.
#\\
#\\
# !CALLING SEQUENCE:
#  $ ./changeVersionNumbers.sh X.Y.Z        # X.Y.Z = GCHP version number
#EOP
#------------------------------------------------------------------------------
#BOC

function replace() {

    #========================================================================
    # Function to replace text in a file via sed.
    #
    # 1st argument: Search pattern
    # 2nd argument: Replacement text
    # 3rd argument: File in which to search and replace
    #========================================================================

    sed -i -e "s/${1}/${2}/" "${3}"
}


function exitWithError() {

    #========================================================================
    # Display and error message and exit
    #========================================================================

    echo "Could not update version numbers in ${1}... Exiting!"
    exit 1
}


function main() {

    #========================================================================
    # Replaces the version number in the files listed.
    #
    # 1st argument: New version number to use
    #========================================================================

    # New version number
    version="${1}"

    # Save this directory path and change to root directory
    thisDir=$(pwd -P)
    cd ..

    #========================================================================
    # Update version numbers in various files
    #========================================================================

    # Pattern to match: X.Y.Z
    pattern='[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*'

    # List of files to replace
    files=(                   \
        "CMakeLists.txt"      \
        "docs/source/conf.py" \
    )

    # Replace version numbers in files
    for file in ${files[@]}; do
        replace "${pattern}" "${version}" "${file}"
        [[ $? -ne 0 ]] && exitWithError "${file}"
        echo "GCClassic version updated to ${version} in ${file}"
    done

    #========================================================================
    # Update version number and date in CHANGELOG.md
    #========================================================================

    # Pattern to match: "[Unreleased] - TBD"
    pattern='\[.*Unreleased.*\].*'
    date=$(date -Idate)

    # List of files to replace
    files=(                                                          \
        "CHANGELOG.md"                                               \
        "src/GCHP_GridComp/GEOSChem_GridComp/geos-chem/CHANGELOG.md" \
    )

    # Replace version numbers in files
    for file in ${files[@]}; do
	replace "${pattern}" "\[${version}\] - ${date}" "${file}"
        [[ $? -ne 0 ]] && exitWithError "${file}"
        echo "GCClassic version updated to ${version} in ${file}"
    done

    # Return to the starting directory
    cd "${thisDir}"
}

# ---------------------------------------------------------------------------

# Expect 1 argument, or exit with error
if [[ $# -ne 1 ]]; then
    echo "Usage: ./changeVersionNumbers.sh VERSION"
    exit 1
fi

# Replace version numbers
main "${1}"

# Return status
exit $?
