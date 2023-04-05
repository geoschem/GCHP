#!/bin/bash

# findRefKey.sh: Find last successful benchmark run
#   primary key (ref) for automatically determining the simulation to 
#   create benchmark plots against in the cloud benchmarking workflow
#
# usage: 
#   ./findRefKey.sh resolution time_period
#       resolution: The resolution used for the benchmark sim (eg. 24)
#       time_period: The time period for the benchmark (eg. 1Hr, 1Mon)  
               
function find_previous_tag() {
    new_tag=`$describe_command $commit`
    primary_key="${MODEL_PREFIX}-c${resolution}-${time_period}-${new_tag}"
}

# Constants
MODEL_PREFIX=gchp # gcc or gchp
MAX_COMMITS=30 # number of commits to check for successful simulations

# Set parameters
resolution=$1
time_period=$2
hash=$3


commits=`git rev-list --max-count=${MAX_COMMITS} ${hash}`
recent_tags=`git tag --sort=-v:refname --list "[0-9]*" | head -n 5`

# in reverse chronological order we query dynamodb for the last
# successful simulation run
for commit in ${commits}
do
    exclude_string=""

    for tag in ${recent_tags}
    do
        if [[ ! -z $exclude_string ]]; then
            describe_command="git describe ${exclude_string} --tags"
        else
            describe_command="git describe --tags"
        fi
        find_previous_tag

        # query dynamodb for the given primary key simulation
        output=`aws dynamodb get-item \
            --table-name geoschem_testing \
            --key "{\"InstanceID\": {\"S\": \"${primary_key}\"}}"`
        # Check if the simulation for given primary key exists and ran
        # successfully print out the first successful primary key and exit
        if [[ `echo $output | jq '.Item.ExecStatus.S | contains("SUCCESSFUL")'` == "true" ]] \
        && [[ `echo $output | jq 'any(.Item.Stages.L[].M.Name.S; . == "RunGCHP")'` == "true" ]]; then
            echo $primary_key
            exit 0
        fi
        exclude_string="${exclude_string} --exclude ${tag}"
    done
done

echo "Error: No successful primary key found within $MAX_COMMITS commits"
exit 1
