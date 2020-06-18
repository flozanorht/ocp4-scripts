#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

# I see no status for a storage class
#num_classes=$( oc get storageclass -o name | wc -l )

# Checking only PVCs for now
#num_pvs=$( oc get pv -o name | wc -l )
num_pvcs=$( oc get pvc -A -o name | wc -l )

not_bound_pvcs=$( oc get pvc -A -o jsonpath="{.items[?(@.status.phase!='Bound')].metadata.name}" )

num_not_bound_pvcs=$( echo "${not_bound_pvcs}" | wc -w )

if [ "${num_not_bound_pvcs}" -gt 0 ]
then
    echo "✘ There are ${num_pvcs} PVCs on the cluster, ${num_not_bound_pvcs} of them are not bound."
    ns_not_bound_pvcs=$( oc get pvc -A -o jsonpath="{.items[?(@.status.phase!='Bound')].metadata.namespace}" )
    echo '✘ Namespaces with PVCS that are not bound:'
    echo "✘ ${ns_not_bound_pvcs}"
    exit 1
else
    echo "✔ There are ${num_pvcs} PVCs on the cluster, all of them are bound."
fi
