#!/bin/sh

# Works without a ~/.kube folder and also without a current valid session/token/certificate
context=$( oc config view -o jsonpath='{.current-context}' )
if [ -n "${context}" ]
then
    cluster=$( oc config view -o jsonpath="{.contexts[?(@.name=='${context}')].context.cluster}" )
    api=$( oc config view -o jsonpath="{.clusters[?(@.name=='${cluster}')].cluster.server}" )

    if curl --fail -k -s --connect-timeout 9 "${api}/healthz" &>/dev/null
    then
        version=$( oc get clusterversion version -o jsonpath='{.status.desired.version}' )
        echo "OpenShift version is: '${version}'"
    else
        echo "Cannot connect to OpenShit at '${api}'"
        exit 2
    fi
else
    echo "Please perform an 'oc login' or export a valid KUBECONFIG file."
    exit 1
fi
