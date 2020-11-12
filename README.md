# Synthetic benchmarking tool for OpenShift Container Storage for block and file interfaces
- [Introduction](#Introduction)
- [Requirements](#Requirements)
- [Environment configuration](#environment-configuration)
   - [Openshift cluster information](#openshift-cluster-information)

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
### Openshift cluster information
```bash
[ctorres-redhat.com@bastion ~]$ oc version
Client Version: 4.5.7
Server Version: 4.6.3
Kubernetes Version: v1.19.0+9f84db3
```
### OpenShift nodes configuration (following labels work with AWS IPI deployment)
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
### OCS node configuration, we are using "i3.16xlarge" AWS instances
```bash
[ctorres-redhat.com@bastion machinesets]$ oc get nodes -l cluster.ocs.openshift.io/openshift-storage=  -o=custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,RAM:.status.capacity.memory
NAME                                            CPU   RAM
ip-10-0-140-220.eu-central-1.compute.internal   64    503586776Ki
ip-10-0-183-7.eu-central-1.compute.internal     64    503586776Ki
ip-10-0-213-116.eu-central-1.compute.internal   64    503587072Ki
```
### OCS and local-storage tested versions
```bash
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-local-storage
NAME                                           DISPLAY         VERSION                 REPLACES   PHASE
local-storage-operator.4.5.0-202010301114.p0   Local Storage   4.5.0-202010301114.p0              Succeeded
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-storage
NAME                         DISPLAY                       VERSION        REPLACES   PHASE
ocs-operator.v4.6.0-156.ci   OpenShift Container Storage   4.6.0-156.ci              Succeeded
```
### OCS local storage available from pvs
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
### OCS osds that are consuming the previous local-storage pvs
```bash
[ctorres-redhat.com@bastion ocs_performance]$ oc get pods -l app=rook-ceph-osd
NAME                                READY   STATUS    RESTARTS   AGE
rook-ceph-osd-0-5546dbc98f-s9c4f    1/1     Running   0          6m47s
rook-ceph-osd-1-bd4f95845-d66zb     1/1     Running   0          6m46s
rook-ceph-osd-10-589c45bd5c-pwgt5   1/1     Running   0          6m39s
rook-ceph-osd-11-94568d7cd-gwbfs    1/1     Running   0          6m37s
rook-ceph-osd-12-7f6d5dd9fb-mhqpw   1/1     Running   0          6m38s
rook-ceph-osd-13-5ddc6f8d66-v7jsd   1/1     Running   0          6m36s
rook-ceph-osd-14-6bf99c4df8-m2fs9   1/1     Running   0          6m35s
rook-ceph-osd-15-788fd77885-cvd8c   1/1     Running   0          6m34s
rook-ceph-osd-16-655bbcc447-vtfbr   1/1     Running   0          6m32s
rook-ceph-osd-17-6949cd6ff7-scvdn   1/1     Running   0          6m31s
rook-ceph-osd-18-856b7858bc-z5wms   1/1     Running   0          6m33s
rook-ceph-osd-19-6d988f75dd-m42c8   1/1     Running   0          6m30s
rook-ceph-osd-2-77769ddcf4-vbp4m    1/1     Running   0          6m47s
rook-ceph-osd-20-77d8ff8dbc-d58qb   1/1     Running   0          6m28s
rook-ceph-osd-21-fb69fdf7d-srsgs    1/1     Running   0          6m29s
rook-ceph-osd-22-6c97568856-5qdmg   1/1     Running   0          6m27s
rook-ceph-osd-23-868f4995f6-7f78h   1/1     Running   0          6m26s
rook-ceph-osd-3-697847c554-cmkdv    1/1     Running   0          6m46s
rook-ceph-osd-4-cdc44c467-zdcxm     1/1     Running   0          6m44s
rook-ceph-osd-5-5d54cd6cfc-ddtvw    1/1     Running   0          6m43s
rook-ceph-osd-6-59c6fb6664-2lbnv    1/1     Running   0          6m45s
rook-ceph-osd-7-7bb6bf55c-r28jd     1/1     Running   0          6m42s
rook-ceph-osd-8-6f5c5786f9-s9f2g    1/1     Running   0          6m41s
rook-ceph-osd-9-7bd5597b77-wqtbb    1/1     Running   0          6m40s
```
## Performance testing
#### 1. Clone the repo
```bash
[ctorres-redhat.com@bastion ~]$ git clone https://github.com/ctorres80/ocs_performance.git
Cloning into 'ocs_performance'...
remote: Enumerating objects: 394, done.
remote: Counting objects: 100% (394/394), done.
remote: Compressing objects: 100% (215/215), done.
remote: Total 394 (delta 138), reused 374 (delta 118), pack-reused 0
Receiving objects: 100% (394/394), 56.47 KiB | 713.00 KiB/s, done.
Resolving deltas: 100% (138/138), done.
```
#### 2. Running the ansible role to deploy statefulsets
```bash
[ctorres-redhat.com@bastion ocs_performance]$ ansible-playbook use_playbook.yml
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Using ansible rbd_ceph_performance role] ********************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************
ok: [localhost]

TASK [rbd_ceph_performance : pause] *******************************************************************************************************************************************************************
[rbd_ceph_performance : pause]
Select the task number:
    - 1 -> deploy fio file and block statefulset and pods (project=testing-ocs-storage)
    - 2 -> fio workloads
    - 3 -> clean-fio-tests
    - 4 -> s3cmd-sync
    - 5 -> s3cmd-delete
    - 6 -> delete-fio-pods
: 1
ok: [localhost]

TASK [rbd_ceph_performance : create environment test] *************************************************************************************************************************************************
included: /home/ctorres-redhat.com/ocs_performance/roles/rbd_ceph_performance/tasks/deploy_test_env.yml for localhost

TASK [rbd_ceph_performance : pause] *******************************************************************************************************************************************************************
[rbd_ceph_performance : pause]
OCS cluster:
- internal
- external
: internal
ok: [localhost]

TASK [rbd_ceph_performance : pause] *******************************************************************************************************************************************************************
[rbd_ceph_performance : pause]
How many fio pods ?
: 24
ok: [localhost]

TASK [rbd_ceph_performance : Create the statefulset external] *****************************************************************************************************************************************
skipping: [localhost]

TASK [rbd_ceph_performance : Create the statefulset internal] *****************************************************************************************************************************************
fatal: [localhost]: FAILED! => {"changed": true, "cmd": "export KUBECONFIG=$HOME/.kube/config\noc create -f roles/rbd_ceph_performance/templates/fio-block.yml\noc create -f roles/rbd_ceph_performance/templates/fio-file.yml\n", "delta": "0:00:00.543063", "end": "2020-11-12 02:23:28.411679", "msg": "non-zero return code", "rc": 1, "start": "2020-11-12 02:23:27.868616", "stderr": "Error from server (AlreadyExists): error when creating \"roles/rbd_ceph_performance/templates/fio-file.yml\": namespaces \"testing-ocs-storage\" already exists", "stderr_lines": ["Error from server (AlreadyExists): error when creating \"roles/rbd_ceph_performance/templates/fio-file.yml\": namespaces \"testing-ocs-storage\" already exists"], "stdout": "namespace/testing-ocs-storage created\nstatefulset.apps/fio-block-ceph-tools created\nstatefulset.apps/fio-file-ceph-tools created", "stdout_lines": ["namespace/testing-ocs-storage created", "statefulset.apps/fio-block-ceph-tools created", "statefulset.apps/fio-file-ceph-tools created"]}
...ignoring

TASK [rbd_ceph_performance : Scale fio-{{ ocs_interface.user_input  }}-{{ ocs_cluster.user_input  }} pods] ********************************************************************************************
changed: [localhost]

TASK [rbd_ceph_performance : fio benchmark] ***********************************************************************************************************************************************************
skipping: [localhost]

TASK [rbd_ceph_performance : clean-fio-test] **********************************************************************************************************************************************************
skipping: [localhost]

TASK [rbd_ceph_performance : s3cmd testing] ***********************************************************************************************************************************************************
skipping: [localhost]

TASK [rbd_ceph_performance : s3cmd delete] ************************************************************************************************************************************************************
skipping: [localhost]

TASK [rbd_ceph_performance : fio delete environment test] *********************************************************************************************************************************************
skipping: [localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************
localhost                  : ok=8    changed=2    unreachable=0    failed=0    skipped=6    rescued=0    ignored=2

```