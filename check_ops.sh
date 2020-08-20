#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

# Other scripts checking namespaced resoures (ex: pods) only report namespaces.
# I believe that the number of operators will not be so big that reporting on each one would be an issue

allops=$( oc get csv -A -o jsonpath="{range .items[*]}{.metadata.namespace}/{.metadata.name} {end}" )
#numops=$( echo "${allops}" | wc -w )

notsucceeded=''
#XXX not sure what to do with the conditions from CSVs
#XXX for example, the OCP Virt operator in my test lab reports "Succeeded" but has a few conditions that look like errors or degraded. But I was able to create simple VMs so it looks like working.
#notaval=''
#degraded=''
#progress=''
for op in ${allops}
do
	name=$( echo ${op} | awk -F/ '{print $2}' )
	namespace=$( echo ${op} | awk -F/ '{print $1}' )
	if [ "Succeeded" != "$( oc get csv ${name} -n ${namespace} -o jsonpath='{.status.phase}' )" ]
	then
		notsucceeded="${notsucceeded} ${op}"
	fi
	#if [ "True" = "$( oc get ${co} -o jsonpath='{.status.conditions[?(@.type=="Degraded")].status}' )" ]
	#then
	#	degraded="${degraded} ${name}"
	#fi
	#if [ "True" = "$( oc get ${co} -o jsonpath='{.status.conditions[?(@.type=="Progressing")].status}' )" ]
	#then
	#	progress="${progress} ${name}"
	#fi
done

#if [ -n "${notaval}" -o -n "${degreaded}" -o -n "${progress}" ]
if [ -n "${notsucceeded}" ]
then

	#if [ -n "${notsucceeded}" ]
	#then
		echo '✘ OLM operators that are still installing or failed installation:'
		echo "✘ ${notsucceeded}"
	#else
	#	echo "✔ ${numops} OLM operators are installed sucessfully."
	#fi
	#if [ -n "${notaval}" ]
	#then
	#	echo '✘ Cluster operators that are not available:'
	#	echo "✘ ${notaval}"
	#else
	#	echo '✔ All cluster operator are available.'
	#fi
	#if [ -n "${degreaded}" ]
	#then
	#	echo '✘ Cluster operators that are degraded:'
	#	echo "✘ ${degraded}"
	#else
	#	echo '✔ No cluster operator is degraded.'
	#fi
	#if [ -n "${progress}" ]
	#then
	#	echo '✘ Cluster operators that are progressing:'
	#	echo "✘ ${progress}"
	#else
	#	echo '✔ No cluster operator is progressing.'
	#fi

	exit 1

else
	echo "✔ All OLM operators are installed."
	#echo "✔ All OLM operators are healthy and idle."
fi
