#!/bin/bash

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
workDir=`pwd`
stageName=${1}
fileToCheck=${2}
tmpFile=".tmp-stage"

function echoHelp() {
    echo "************ Usage ************"
    echo ""
    echo "check-stages.sh [stage] [file]"
    echo "Example: check-stages.sh dev dev-values.yaml"
    echo ""
    echo "Configurable via a file called .stage-check.yaml in your working directory."
}

# Check preconditions
if [[ -z "${stageName}" || -z "${fileToCheck}" ]]; then
    echoHelp
    exit 1
fi

confFile="${workDir}/.stage-check.yaml"

if [[ ! -f "${confFile}" ]]; then
    echo "using default configuration"
    confFile="${scriptDir}/.stage-check.yaml"
fi

# Load configuration for stage
myStageConf=`yq read ${confFile} ${stageName}`
if [[ -z "${myStageConf}" ]]; then
    echo "Stage '${stageName}' not found in '${confFile}'"
    exit 1
fi

denyValues=(`yq read ${confFile} ${stageName}.deny | cut -d ' ' -f2`)
allowValues=(`yq read ${confFile} ${stageName}.allow | cut -d ' ' -f2`)
globalAllowValues=(`yq read ${confFile} global.allow | cut -d ' ' -f2`)

echo "Checking '${fileToCheck}' for occurrences of:"
echo ""
for s in ${denyValues[@]}; do
    echo ${s}
done
echo ""
echo ""
echo "Allowing specific occurrences of:"
echo ""
for s in ${allowValues[@]}; do
    echo ${s}
done
for s in ${globalAllowValues[@]}; do
    echo ${s}
done
echo ""
echo ""

# Search.........
function copyFileToCheckAndRemoveAllowedValues() {
    cp ${fileToCheck} ${tmpFile}
    for allow in ${allowValues[@]}; do
        sed -i "s,$allow,,g" ${tmpFile}
    done
    for allow in ${globalAllowValues[@]}; do
        sed -i "s,$allow,,g" ${tmpFile}
    done
}

function searchVorValueIgnoreAllowed() {
    deniedString=${1}
    intermediateResult=`cat ${tmpFile} | grep -n -i "${deniedString}"; echo $?`
    if [[ ${intermediateResult} != 1 ]]
    then
        echo ""
        echo "************************************************************************************************************"
        echo "************* \"${fileToCheck}\" contains \"${deniedString}\" *************"
        echo ""
        echo "${intermediateResult}" | head -n -1
        echo ""
        findings+=1
    fi
}

copyFileToCheckAndRemoveAllowedValues
declare -i findings=0
for s in ${denyValues[@]}; do
    searchVorValueIgnoreAllowed ${s}
done
rm .tmp-stage

if [[ ${findings} != 0 ]]
then
    echo "${findings} errors occurred -> exit 1"
    exit 1
fi

echo "Stages are clean -> exit 0"
exit 0
