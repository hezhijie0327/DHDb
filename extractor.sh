#!/bin/bash

# Current Version: 1.0.5

## How to get and use?
# git clone "https://github.com/hezhijie0327/DHDb.git" && bash ./DHDb/extractor.sh -e "example.org\|zhijie.online" -i /root/AdGuardHome/data -o /root/AdGuardHome/data -u hezhijie0327

## Parameter
while getopts e:i:o:u: GetParameter; do
    case ${GetParameter} in
        e) EXCLUDE="${OPTARG}";;
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
    if [ "${USERNAME}" == "" ]; then
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
    DOMAIN_REGEX="^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$"
    EXCLUDE_DEFAULT="in-addr.arpa\|ip6.arpa"
    if [ "${EXCLUDE}" == "" ]; then
        EXCLUDE_CUSTOM="${EXCLUDE_DEFAULT}"
    else
        EXCLUDE_CUSTOM="${EXCLUDE}"
    fi
    if [ ! -f "${INPUT}/querylog.json.1" ]; then
        querylog_raw=$(cat "${INPUT}/querylog.json")
    else
        querylog_raw=$(cat "${INPUT}/querylog.json" "${INPUT}/querylog.json.*")
    fi && querylog_data=$(echo "${querylog_raw}" | jq -s add | jq -Sr ".QH" | grep -E "${DOMAIN_REGEX}" | grep -v "${EXCLUDE_CUSTOM}" | grep -v "${EXCLUDE_DEFAULT}" | sort | uniq)
}
# Output Data
function OutputData() {
    BUILD_TIME=$(date "+%s")
    echo "${querylog_data}" >> "${OUTPUT}/querylog-${USERNAME}-${BUILD_TIME}.txt"
    echo "\"${OUTPUT}/querylog-${USERNAME}-${BUILD_TIME}.txt\" has been generated."
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
