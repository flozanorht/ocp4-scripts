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
        # Workaround for Microshift
        status=$(curl --fail -k -s --connect-timeout 9 -o /dev/null -w "%{http_code}" "${api}/healthz")
        if [ "${status}" != "401" ]
        then
          echo "✘ Cannot connect to OpenShift at '${api}'"
          exit 2
        else
          echo "✘ The API health endpoint '${api}/healthz' requires authentication, proceeding anyway."
        fi
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
