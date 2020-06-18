#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

allnodes=$( oc get node -o name )

notready=''
memory=''
disk=''
pid=''

for node in ${allnodes}
do
	name=$( echo ${node} | awk -F/ '{print $2}' )
	# The Ready condition could also be Unknown
	if [ "True" != "$( oc get ${node} -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' )" ]
	then
		notready="${notready} ${name}"
	fi
	if [ "True" = "$( oc get ${node} -o jsonpath='{.status.conditions[?(@.type=="MemoryPressure")].status}' )" ]
	then
		memory="${memory} ${name}"
	fi
	if [ "True" = "$( oc get ${node} -o jsonpath='{.status.conditions[?(@.type=="DiskPressure")].status}' )" ]
	then
		disk="${disk} ${name}"
	fi
	if [ "True" = "$( oc get ${node} -o jsonpath='{.status.conditions[?(@.type=="PIDPressure")].status}' )" ]
	then
		pid="${pid} ${name}"
	fi
done

if [ -n "${notready}" -o -n "${memory}" -o -n "${disk}" -o -n "${pid}" ]
then

	if [ -n "${notready}" ]
	then
		echo '✘ Cluster nodes that are not ready:'
		echo "✘ ${notready}"
	else
		echo '✔ All cluster nodes are ready.'
	fi
	if [ -n "${memory}" ]
	then
		echo '✘ Cluster nodes that are under memory pressure:'
		echo "✘ ${memory}"
	else
		echo '✔ No cluster node is under memory pressure.'
	fi
	if [ -n "${disk}" ]
	then
		echo '✘ Cluster nodes that are under disk pressure:'
		echo "✘ ${disk}"
	else
		echo '✔ No cluster node is under disk pressure.'
	fi
	if [ -n "${pid}" ]
	then
		echo '✘ Cluster nodes that are under pid pressure:'
		echo "✘ ${pid}"
	else
		echo '✔ No cluster node is under pid pressure.'
	fi

	exit 1

else
	echo "✔ All cluster nodes are ready and none is under pressure."
fi
