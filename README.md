These are scripts designed to provide a quick status of you OpenShift 4 cluster: is it healthy?

All scripts assume that you have either the KUBECONFIG variable set or performed oc login before.
They also assume cluster admin accessr.

The `check_cluster.sh` script just invokes all other scripts.

The current set of scripts is terribly inefficient.
Each of them may take minutes running because they perform many small API calls (oc commands).
They could be probably improved with better use of jsonpath or switching to jq.

If someone is willing to create alternate versions of the same scripts, using python or whatever, preserving a 1:1 mapping from each alterative versions for didatic purposes, it would be great!

