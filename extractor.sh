#!/bin/bash

# Current Version: 1.0.0

## How to get and use?
# git clone "https://github.com/hezhijie0327/DHDb.git" && bash ./DHDb/extractor.sh -i /root/AdGuardHome/data -o /root/AdGuardHome/data -u hezhijie0327

## Parameter
while getopts i:o:u: GetParameter; do
    case ${GetParameter} in
        i) INPUT="${OPTARG}";;
        o) OUTPUT="${OPTARG}";;
        u) USERNAME="${OPTARG}";;
    esac
done

## Function
# Check Configuration Validity
function CheckConfigurationValidity() {
    if [ "${INPUT}" == "" ]; then
        echo "An error occurred during processing. Missing (INPUT) value, please check it and try again."
        exit 1
    elif [ ! -f "${INPUT}/querylog.json" ]; then
        echo "An error occurred during processing. Invalid (INPUT) value, please check it and try again."
        exit 1
    fi
    if [ "${OUTPUT}" == "" ]; then
        echo "An error occurred during processing. Missing (OUTPUT) value, please check it and try again."
        exit 1
    elif [ ! -d "${OUTPUT}" ]; then
        echo "An error occurred during processing. Invalid (OUTPUT) value, please check it and try again."
        exit 1
    fi
    if [ "${USERNAME}" == ""]; then
        echo "An error occurred during processing. Missing (USERNAME) value, please check it and try again."
        exit 1
    fi
}
# Check Requirement
function CheckRequirement() {
    which "jq" > "/dev/null" 2>&1
    if [ "$?" -eq "1" ]; then
        echo "jq is not existed."
        exit 1
    fi
}
# Analyse Data
function AnalyseData() {
    querylog_data=($(cat "${INPUT}/querylog.json" | jq -Sr '.QH' | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    BUILD_TIME=$(date "+%s") && for querylog_data_task in "${!querylog_data[@]}"; do
        echo "${querylog_data[$querylog_data_task]}" >> "${OUTPUT}/querylog-${USERNAME}-${BUILD_TIME}.txt"
    done
}

## Process
# Call CheckConfigurationValidity
CheckConfigurationValidity
# Call CheckRequirement
CheckRequirement
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
