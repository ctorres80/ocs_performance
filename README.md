# Synthetic benchmarking tool for OpenShift Container Storage for block and file interfaces

## Introduction 
This is in an interactive ansible role for performance testing with synthetic benchmarking workloads, the purpose is to simulate different workload profiles based on your inputs.

## Requirements
- OpenShift Container Platform v4.2+ 
- OpenShift Container Storage v4.2+ (AKA OCS)
- Local Storage Operator
- Supported infrastructures: AWS IPI, VMware UPI (Other platforms have not been tested yet but the tool should work)
- OpenShift management node with admin serviceaccount
- `oc` client with kubeconfig file authentication
- `git` client
- Ansible at least v2.8 

## Environment configuration
#### Openshift cluster information 
```bash
[ctorres-redhat.com@bastion ~]$ oc version
Client Version: 4.5.7
Server Version: 4.6.3
Kubernetes Version: v1.19.0+9f84db3
```
#### OpenShift nodes configuration (following labels work with AWS IPI deployment)
```bash
[ctorres-redhat.com@bastion machinesets]$ oc get nodes -L kubernetes.io/hostname -L node.kubernetes.io/instance-type -L failure-domain.beta.kubernetes.io/region -L failure-domain.beta.kubernetes.io/zone
NAME                                            STATUS   ROLES    AGE   VERSION           HOSTNAME          INSTANCE-TYPE   REGION         ZONE
ip-10-0-140-220.eu-central-1.compute.internal   Ready    worker   72s   v1.19.0+9f84db3   ip-10-0-140-220   i3.16xlarge     eu-central-1   eu-central-1a
ip-10-0-145-177.eu-central-1.compute.internal   Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-145-177   m5.4xlarge      eu-central-1   eu-central-1a
ip-10-0-151-216.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-151-216   c5d.2xlarge     eu-central-1   eu-central-1a
ip-10-0-182-17.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-182-17    m5.4xlarge      eu-central-1   eu-central-1b
ip-10-0-183-7.eu-central-1.compute.internal     Ready    worker   74s   v1.19.0+9f84db3   ip-10-0-183-7     i3.16xlarge     eu-central-1   eu-central-1b
ip-10-0-186-76.eu-central-1.compute.internal    Ready    master   12h   v1.19.0+9f84db3   ip-10-0-186-76    c5d.2xlarge     eu-central-1   eu-central-1b
ip-10-0-192-170.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-192-170   c5d.2xlarge     eu-central-1   eu-central-1c
ip-10-0-212-27.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-212-27    m5.4xlarge      eu-central-1   eu-central-1c
ip-10-0-213-116.eu-central-1.compute.internal   Ready    worker   69s   v1.19.0+9f84db3   ip-10-0-213-116   i3.16xlarge     eu-central-1   eu-central-1c
```
OCS node configuration, we are using "i3.16xlarge" AWS instances
```bash
[ctorres-redhat.com@bastion machinesets]$ oc get nodes -l cluster.ocs.openshift.io/openshift-storage=  -o=custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,RAM:.status.capacity.memory
NAME                                            CPU   RAM
ip-10-0-140-220.eu-central-1.compute.internal   64    503586776Ki
ip-10-0-183-7.eu-central-1.compute.internal     64    503586776Ki
ip-10-0-213-116.eu-central-1.compute.internal   64    503587072Ki
```
#### OCS and local-storage tested versions
```bash
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-local-storage
NAME                                           DISPLAY         VERSION                 REPLACES   PHASE
local-storage-operator.4.5.0-202010301114.p0   Local Storage   4.5.0-202010301114.p0              Succeeded
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-storage
NAME                         DISPLAY                       VERSION        REPLACES   PHASE
ocs-operator.v4.6.0-156.ci   OpenShift Container Storage   4.6.0-156.ci              Succeeded
```
#### OCS local storage available from pvs
```bash
[ctorres-redhat.com@bastion discovery]$  oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                        STORAGECLASS   REASON   AGE
local-pv-130a2b46                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-14b33970                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-18243a3                           1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-2589f91f                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-26f72b87                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-3c25a874                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-581418b3                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-58e52e78                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-591f61ef                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-5e9378eb                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-5f496d8a                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-6a593306                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-8c4fc950                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-8ebd12d1                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-90db8d4a                          1769Gi     RWO            Delete           Available                                localblock              16s
local-pv-9931edf4                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-9ee290f4                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-a17a3e75                          1769Gi     RWO            Delete           Available                                localblock              11s
local-pv-bf64cf6                           1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-c60ccd5d                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-c96581a5                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-d16ba471                          1769Gi     RWO            Delete           Available                                localblock              12s
local-pv-ecac9549                          1769Gi     RWO            Delete           Available                                localblock              17s
local-pv-eff870f2                          1769Gi     RWO            Delete           Available                                localblock              12s
pvc-59353490-6a69-4a80-a6c6-8e559a501538   1Gi        RWO            Delete           Bound       terminal/terminal-hub-data   gp2                     15h
```

## Openshift Container Storage deployment from WEB UI
