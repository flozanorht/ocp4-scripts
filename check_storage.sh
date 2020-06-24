#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

# I see no status for a storage class
defclass=$( oc get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}' )

if [ -z "${defclass}" ]
then
    echo '✘ There is no default storage class.'
else
    provisioner=$( oc get storageclass "${defclass}" -o jsonpath='{.provisioner}' )

    if [ -z "${provisioner}" ]
    then
        echo "✘ The default storage class does not support dynamic provisioning."
    else
        echo "✔ There is a default storage class for dynamic provisioning."
    fi
fi

released_pvs=$( oc get pv -o jsonpath='{.items[?(@.status.phase=="Released")].metadata.name}' )
failed_pvs=$( oc get pv -o jsonpath='{.items[?(@.status.phase=="Failed")].metadata.name}' )

if [ -n "${released_pvs}" -o -n "${failed_pvs}" ]
then
    if [ -n "${released_pvs}" ]
    then
        echo '✘ Released PVs:'
        echo "✘ ${released_pvs}"
    else
        echo "✔ No PV is released."
    fi
    if [ -n "${failed_pvs}" ]
    then
        echo '✘ Failed PVs:'
        echo "✘ ${released_pvs}"
    else
        echo "✔ No PV is failed."
    fi
else
    echo "✔ All PVs are either bound or available."
fi

not_bound_pvcs=$( oc get pvc -A -o jsonpath='{.items[?(@.status.phase!="Bound")].metadata.name}' )

num_not_bound_pvcs=$( echo "${not_bound_pvcs}" | wc -w )

if [ "${num_not_bound_pvcs}" -gt 0 ]
then
    ns_not_bound_pvcs=$( oc get pvc -A -o jsonpath="{.items[?(@.status.phase!='Bound')].metadata.namespace}" )
    echo '✘ Namespaces with PVCs that are not bound:'
    echo "✘ ${ns_not_bound_pvcs}"
    exit 1
else
    echo "✔ All PVCs are bound."
fi
