# Quick OCP4 Cluster Check Scripts

These are simple Bash scripts designed to provide a quick status of you OpenShift 4 cluster: is it healthy?

```
$ ./check_cluster.sh
✔ OpenShift is reacheable and up, at version: '4.4.8'
✔ All cluster nodes are ready and none is under pressure.
✔ All cluster operators are healthy and idle.
✔ There are no CSRs.
✔ All pods are either running or succeeded.
✔ There is a default storage class for dynamic provisioning.
✔ All PVs are either bound or available.
✔ All PVCs are bound.
```

I created these scripts as a convenient way to check temporary and short-lived clusters used for teaching, that are created, deleted, stopped, and restarted frequently.
They are not intended as an alternative to OpenShift Cluster Monitoring and other types of IT alerting infrastructure.

If you know about common error scenarios for new and restarted clusters, please create a GitHub issue explaining the scenario and how to check for it. Better yet, create a PR for a new script or an improvement of one of the existing ones. :-)

## Usage

All scripts assume that you have either the KUBECONFIG variable set or performed oc login before.
They also assume cluster administration privileges.

The `check_cluster.sh` script just invokes all other scripts.
All scripts exit with status != 0 in case of any not healthy condition.

Not that some not healthy conditions are expected to disapear by themselves after a few moments.
For example: a pending pod might become running after its container image is available or its storage is provisioned.

## Usage with Microshift

These scripts were created to test OpenShift clusters, including OpenShift extensions such as cluster operators and were never intended to "just work" on vanilla Kubernetes. 
Microshift changes that because it drops components such as the CVO and OLM.

The scripts were minimally updated to report an "error" but ignore it under the assumption it is running on Microshift and other checks are still valuable. Here's an example of the output on Microshift:

```
✘ The API health endpoint 'https://127.0.0.1:6443/healthz' requires authentication, proceeding anyway.
✘ Cannot get a clusterversion resource. Proceeding under the assumption this is a Microshift cluster.
✔ All cluster nodes are ready and none is under pressure.
✘ Cannot query cluster operators. Proceeding under the assumption this is a Microshift cluster.
✘ Cannot query add-on operators. Proceeding under the assumption this is a Microshift cluster.
✔ There are no CSRs awaiting for approval.
✔ All pods are either running or succeeded.
✔ There is a default storage class for dynamic provisioning.
✔ All PVs are either bound or available.
✔ All PVCs are bound.
```

## Design and Caveats

Each script is designed to test for error and warning conditions, reporting them, and at the end, if it found no issues, reporting that everything is fine.
They are also designed to minimize the number of "this is healthy" messages and output additional information for further troubleshooting of "not healthy" resources.

For example: if all pods are ok (running or successful), `check_pods.sh` outputs a single message.
But if there are pods that are either pending, failed, or in an unknown state, it outputs a heathy or not healthy message for each of these states, and also outputs the names of all namespaces with pods in either state.

The current set of scripts is somewhat inefficient.
Each of them might take a few seconds running because they perform lots of small API calls (oc commands).
They could be probably improved with better use of jsonpath or switching to jq.

If someone is willing to create alternate versions of the same scripts, using Ansible, Python, or whatever, and preserving a 1:1 mapping from each of the original Bash versions to each alterative versions, for didatic purposes, it would be great!

I avoided using advanced Bash features (such as functions and arrays) on purpose to keep these scripts easy to read for the not so advanced sysadmin.
As a consequence of that, there is lot of cut-and-paste inefficiencies inside and between scripts.
If you know ways to streamline these scripts without making them harder to read, I would appreciate your PRs. :-)
