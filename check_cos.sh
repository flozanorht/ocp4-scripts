#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

allcos=$( oc get co -o name )

notaval=''
degraded=''
progress=''
for co in ${allcos}
do
	name=$( echo ${co} | awk -F/ '{print $2}' )
	if [ "False" = "$( oc get ${co} -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' )" ]
	then
		notaval="${notaval} ${name}"
	fi
	if [ "True" = "$( oc get ${co} -o jsonpath='{.status.conditions[?(@.type=="Degraded")].status}' )" ]
	then
		degraded="${degraded} ${name}"
	fi
	if [ "True" = "$( oc get ${co} -o jsonpath='{.status.conditions[?(@.type=="Progressing")].status}' )" ]
	then
		progress="${progress} ${name}"
	fi
done

if [ -n "${notaval}" -o -n "${degreaded}" -o -n "${progress}" ]
then

	if [ -n "${notaval}" ]
	then
		echo 'Cluster operators that are not available:'
		echo "${notaval}"
	else
		echo 'All Cluster Operators are available.'
	fi
	if [ -n "${degreaded}" ]
	then
		echo 'Cluster operators that are degraded:'
		echo "${degraded}"
	else
		echo 'No cluster operators is degraded.'
	fi
	if [ -n "${progress}" ]
	then
		echo 'Cluster operators that are progressing:'
		echo "${progress}"
	else
		echo 'No cluster operators is progressing.'
	fi

else
	echo "All cluster operators are healthy and idle."
fi
