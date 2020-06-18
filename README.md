These are simple Bash scripts designed to provide a quick status of you OpenShift 4 cluster: is it healthy?

```
$ ./scripts/check_cluster.sh
✔ OpenShift is reacheable and up, at version: '4.4.6'
✔ All cluster nodes are ready and none is under pressure.
✔ All cluster operators are healthy and idle.
✔ There are no CSRs.
✔ There are 257 pods on the cluster, none of them are in error, 0 of them are pending.
```

All scripts assume that you have either the KUBECONFIG variable set or performed oc login before.
They also assume cluster admin privileges.

The `check_cluster.sh` script just invokes all other scripts.
All scripts exit with status != 0 in case of any not healthy condition.
Not that some not healthy conditions are expected to disaper by themselves after a few moments.

The current set of scripts is terribly inefficient.
Each of them may take minutes running because they perform lots of small API calls (oc commands).
They could be probably improved with better use of jsonpath or switching to jq.

If someone is willing to create alternate versions of the same scripts, using ansible, python, or whatever, and preserving a 1:1 mapping from each of the original bash versions to each alterative versions for didatic purposes, it would be great!

I avoided using advanced Bash features (such as functions and arrays) on purpose to keep these scripts easy to read for the not so advanced sysadmin.
A consequence is that there is lot of cut-and-paste inside and between scripts.
If you know ways to streamline these scripts without making them harder to read, I would appreciate your PRs. :-)
