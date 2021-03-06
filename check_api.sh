#!/bin/sh

# Works without a ~/.kube folder and also without a current valid session/token/certificate
#context=$( oc config current-context )
context=$( oc whoami -c )
if [ -z "${context}" ]
then
    echo "✘ Please perform an 'oc login' or export a valid KUBECONFIG file."
    exit 1
else
    # Left the more verbose, kubectl compatible commands, for reference
    #cluster=$( oc config view -o jsonpath="{.contexts[?(@.name=='${context}')].context.cluster}" )
    #api=$( oc config view -o jsonpath="{.clusters[?(@.name=='${cluster}')].cluster.server}" )
    api=$( oc whoami --show-server )

    if ! curl --fail -k -s --connect-timeout 9 "${api}/healthz" &>/dev/null
    then
        echo "✘ Cannot connect to OpenShit at '${api}'"
        exit 2
    else
        if ! oc get clusterversion -o name &>/dev/null
        then
          echo "✘ Please perform an 'oc login' or export a valid KUBECONFIG file for a cluster administrator."
          exit 1
        else
          version=$( oc get clusterversion version -o jsonpath='{.status.desired.version}' )
          echo "✔ OpenShift is reacheable and up, at version: '${version}'"
        fi
    fi
fi
