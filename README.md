# Synthetic benchmark tool for block and file persistent volumes in OpenShift Container Storage
- [Introduction](#Introduction)
- [Requirements](#Requirements)
- [Environment information](#environment-configuration)
    - [Openshift cluster information](#openshift-cluster-information)
    - [OpenShift nodes configuration](#openshift-nodes-configuration)
    - [OCS node resources](#ocs-node-resources)
    - [OCS SW tested versions](#ocs-sw-tested-versions)
    - [Label OCS nodes as infra nodes](#label-ocs-nodes-as-infra-nodes)
- [Performance testing](#performance-testing)
    - [Clone the repo](#clone-the-repo)
    - [Fio testing](#fio-testing)
    - [Running the fio benchmark pods](#running-the-fio-benchmark-pods)
    - [Monitoring performance during benchmark](#monitoring-performance-during-benchmark)
         - [Using Openshift Webconsole and grafana](#using-openshift-webconsole-and-grafana)
         - [Using toolbox for cephrbd monitoring](#using-toolbox-for-cephrbd-monitoring)
- [Cleaning environment](#cleaning-environment)
    - [Delete all](#delete-all)

## Introduction 
This is in an interactive ansible role for performance testing with synthetic benchmarking workloads, the purpose is to simulate different workload profiles based on your inputs.  
If you already deployed an OCS cluster you can move to [Performance testing](#performance-testing)

## Requirements
- OpenShift Container Platform v4.2+ 
- OpenShift Container Storage v4.2+ (AKA OCS)
- OpenShift authentication through kubeconfig file, modifify the following variable accordingly:
```bash
roles/rbd_ceph_performance/defaults/main.yml
# kubeconfig path
kubeconfig: '$HOME/.kube/config'
```

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
### OpenShift nodes configuration
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
### OCS node resources 
```bash
[ctorres-redhat.com@bastion machinesets]$ oc get nodes -l cluster.ocs.openshift.io/openshift-storage=  -o=custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,RAM:.status.capacity.memory
NAME                                            CPU   RAM
ip-10-0-140-220.eu-central-1.compute.internal   64    503586776Ki
ip-10-0-183-7.eu-central-1.compute.internal     64    503586776Ki
ip-10-0-213-116.eu-central-1.compute.internal   64    503587072Ki
```
### OCS SW tested versions
```bash
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-local-storage
NAME                                           DISPLAY         VERSION                 REPLACES   PHASE
local-storage-operator.4.5.0-202010301114.p0   Local Storage   4.5.0-202010301114.p0              Succeeded
[ctorres-redhat.com@bastion discovery]$ oc get csv -n openshift-storage
NAME                         DISPLAY                       VERSION        REPLACES   PHASE
ocs-operator.v4.6.0-156.ci   OpenShift Container Storage   4.6.0-156.ci              Succeeded
```
### Label OCS nodes as infra nodes
```bash
[ctorres-redhat.com@bastion ocs_performance]$ oc label nodes ip-10-0-140-220.eu-central-1.compute.internal node-role.kubernetes.io/infra=''
node/ip-10-0-140-220.eu-central-1.compute.internal labeled
[ctorres-redhat.com@bastion ocs_performance]$ oc label nodes ip-10-0-183-7.eu-central-1.compute.internal node-role.kubernetes.io/infra=''
node/ip-10-0-183-7.eu-central-1.compute.internal labeled
[ctorres-redhat.com@bastion ocs_performance]$ oc label nodes ip-10-0-213-116.eu-central-1.compute.internal node-role.kubernetes.io/infra=''
node/ip-10-0-213-116.eu-central-1.compute.internal labeled
```
## Performance testing
### Clone the repo
```bash
[ctorres-redhat.com@bastion ~]$ git clone https://github.com/ctorres80/ocs_performance.git
```
### Fio testing
1. The ansible role is interactive, the fio testing is available 
```bash
[ctorres-redhat.com@bastion ocs_performance]$ ansible-playbook use_playbook.yml
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Using ansible rbd_ceph_performance role] *******************************************************************************************************************************************

TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:17:25 +0000 (0:00:00.041)       0:00:00.041 *****
[rbd_ceph_performance : pause]
Select the task number:
    - 1 -> FIO: Create project=testing-ocs-storage, deploy fio statefulset, scale to a number of replicas, testing and cleaning the environment
    - 2 -> POSTGRES: Running pgbench from custom template, testing and cleaning the environment
:
1
 ```
   - It will create a namespace `` testing-ocs-storage ``
   - Deploy a statefulsets `` fio-testing-performance `` in the namespace `` testing-ocs-storage ``
   - Only requirement is to select the storage class available from the list because is required for configure the statefulset `` fio-testing-performance `` accordingly:
```bash
TASK [rbd_ceph_performance : Select storage class] ***************************************************************************************************************************************
Thursday 19 November 2020  01:18:32 +0000 (0:00:00.097)       0:01:07.567 *****
changed: [localhost]

TASK [rbd_ceph_performance : Available storage classess] *********************************************************************************************************************************
Thursday 19 November 2020  01:18:33 +0000 (0:00:00.590)       0:01:08.158 *****
ok: [localhost] =>
  msg:
  - 'Select the storage class: '
  - - ocs-storagecluster-ceph-rbd
    - ocs-storagecluster-cephfs
    - sc-cephrbd-replica2
    - sc-cephrbd-replica2-compress

TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:18:33 +0000 (0:00:00.049)       0:01:08.207 *****
[rbd_ceph_performance : pause]
Select the storage class:
:
sc-cephrbd-replica2
```
In the interactive menu, the ansible role will ask you how many fio `` pods `` you want to deploy and it will wait for max 60min that the replica pods will be in `` Ready `` status  
Following an example:  
```bash
TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:20:56 +0000 (0:00:00.601)       0:03:31.781 *****
[rbd_ceph_performance : pause]
How many fio pods ?
:
8
TASK [rbd_ceph_performance : Create the fio statefulset fio-testing-performance accordingly] *********************************************************************************************
Thursday 19 November 2020  01:22:18 +0000 (0:01:21.524)       0:04:53.306 *****
changed: [localhost]

TASK [rbd_ceph_performance : Scale fio for OCS to 8 pods in namespace testing-ocs-storage] ***********************************************************************************************
Thursday 19 November 2020  01:22:19 +0000 (0:00:00.737)       0:04:54.044 *****
changed: [localhost]

TASK [rbd_ceph_performance : Waiting for the availability of fio replicas=8] *************************************************************************************************************
Thursday 19 November 2020  01:22:19 +0000 (0:00:00.418)       0:04:54.462 *****
FAILED - RETRYING: Waiting for the availability of fio replicas=8 (60 retries left).
```
Be careful with the ansible output, it will show the fio pods `` Running `` and ready for testing  
```bash
TASK [rbd_ceph_performance : fio pods available for OCS testing with storage class sc-cephrbd-replica2] **********************************************************************************
Thursday 19 November 2020  01:23:54 +0000 (0:00:00.419)       0:06:29.268 *****
ok: [localhost] =>
  msg:
  - NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE                                            NOMINATED NODE   READINESS GATES
  - fio-testing-performance-0   1/1     Running   0          95s   10.129.2.203   ip-10-0-212-27.eu-central-1.compute.internal    <none>           <none>
  - fio-testing-performance-1   1/1     Running   0          87s   10.128.2.127   ip-10-0-182-17.eu-central-1.compute.internal    <none>           <none>
  - fio-testing-performance-2   1/1     Running   0          81s   10.131.0.70    ip-10-0-145-177.eu-central-1.compute.internal   <none>           <none>
  - fio-testing-performance-3   1/1     Running   0          68s   10.129.2.204   ip-10-0-212-27.eu-central-1.compute.internal    <none>           <none>
  - fio-testing-performance-4   1/1     Running   0          58s   10.131.0.71    ip-10-0-145-177.eu-central-1.compute.internal   <none>           <none>
  - fio-testing-performance-5   1/1     Running   0          45s   10.128.2.128   ip-10-0-182-17.eu-central-1.compute.internal    <none>           <none>
  - fio-testing-performance-6   1/1     Running   0          31s   10.129.2.206   ip-10-0-212-27.eu-central-1.compute.internal    <none>           <none>
  - fio-testing-performance-7   1/1     Running   0          16s   10.131.0.72    ip-10-0-145-177.eu-central-1.compute.internal   <none>           <none>
```
### Running the fio benchmark pods
2. As a second step you just need to select from the list the option `` 2 -> fio workloads `` and insert the parameters for the workload that you want to test (random, sequential, small or big block sizes):
   - Select the I/O type, valid parameters: `` read, write, randwrite, randread, readwrite, randrw ``
        - if you select mixed workloads like `` randrw, readwrite `` more options like ``R/W ratio`` will be required.
   - Select the I/O size, valid parameters(integer number): `` 4, 8, 16, 32, 64, 128, 256, 1024, 2048, 4096 ``
   - Select the I/O threads, valid parameters(integer number): `` 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 ``
   - And finally the file size of the fio benchmark, valid parameters(integer number): `` from 1 to 100 ``
   - The fio pod replicas are consuming OCS pvcs that are mounted on `` /usr/share/ocs-pvc `` (same for file and block pods) the benchmark will run on top of the mount point
```bash
[ctorres-redhat.com@bastion ocs_performance]$ oc rsh fio-testing-performance-0
sh-4.4$ df -h | grep rbd
/dev/rbd1                              98G   11G   88G  11% /usr/share/ocs-pvc
```
   - If you want to analyse the fio output the playbook will return the output from each fio pod, you can see the parameters that you have configured with different, following an example:
```bash
TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:23:54 +0000 (0:00:00.031)       0:06:29.300 *****
[rbd_ceph_performance : pause]
Valid I/O type (Only one option is available):
- read
- write
- randwrite
- randread
- readwrite
- randrw
:
randwrite
TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:27:39 +0000 (0:03:45.525)       0:10:14.825 *****
[rbd_ceph_performance : pause]
Valid I/O size in KB example:
- 4, 8, 16, 32, 64, 128, 256, 1024, 2048, 4096 ?
:
4
ok: [localhost]

TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:28:12 +0000 (0:00:32.505)       0:10:47.331 *****
[rbd_ceph_performance : pause]
Valid io_threads example:
- 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096
:
64
ok: [localhost]

TASK [rbd_ceph_performance : pause] ******************************************************************************************************************************************************
Thursday 19 November 2020  01:28:39 +0000 (0:00:27.318)       0:11:14.649 *****
[rbd_ceph_performance : pause]
IO in GB total in GB (max 100):
:
5
```
   - We are using several files instead of single one because in cephfs we want to create more files for metadata workload, following the formula:
```bash
--nrfiles={{ io_total.user_input|int|round(0,'common') * 1024 / io_size.user_input|int|round(0,'common') }}
``` 
   - The playbook will run the fio benchmark based on your inputs for at maximum 1 hour
```bash
TASK [rbd_ceph_performance : fio bench read, write, randwrite with storage class sc-cephrbd-replica2] ************************************************************************************
Thursday 19 November 2020  01:29:02 +0000 (0:00:00.087)       0:11:37.466 *****
changed: [localhost] => (item=fio-testing-performance-0)
changed: [localhost] => (item=fio-testing-performance-1)
changed: [localhost] => (item=fio-testing-performance-2)
changed: [localhost] => (item=fio-testing-performance-3)
changed: [localhost] => (item=fio-testing-performance-4)
changed: [localhost] => (item=fio-testing-performance-5)
changed: [localhost] => (item=fio-testing-performance-6)
changed: [localhost] => (item=fio-testing-performance-7)
```
Following an example for 4K block size, randomwrite workload, 5GB size, on 8 parallel `` fio pods ``:   
```bash
TASK [rbd_ceph_performance : Testing storage class sc-cephrbd-replica2 with fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --directory=/usr/share/ocs-pvc --bs=4K --iodepth=64 --size=5G --rw=randwrite --nrfiles=1280.0 --refill_buffers=1] ***
Thursday 19 November 2020  01:29:06 +0000 (0:00:03.804)       0:11:41.271 *****
FAILED - RETRYING: Testing storage class sc-cephrbd-replica2 with fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --directory=/usr/share/ocs-pvc --bs=4K --iodepth=64 --size=5G --rw=randwrite --nrfiles=1280.0 --refill_buffers=1 (360 retries left).
...
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '967940780879.285165', 'results_file': '/root/.ansible_async/967940780879.285165', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-0', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '181332745762.285189', 'results_file': '/root/.ansible_async/181332745762.285189', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-1', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '6662321433.285224', 'results_file': '/root/.ansible_async/6662321433.285224', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-2', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '451732772989.285259', 'results_file': '/root/.ansible_async/451732772989.285259', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-3', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '395527185491.285304', 'results_file': '/root/.ansible_async/395527185491.285304', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-4', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '814802384312.285350', 'results_file': '/root/.ansible_async/814802384312.285350', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-5', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '326771985996.285384', 'results_file': '/root/.ansible_async/326771985996.285384', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-6', 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '364513102976.285416', 'results_file': '/root/.ansible_async/364513102976.285416', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-7', 'ansible_loop_var': 'item'})

TASK [rbd_ceph_performance : Print fio benchmarks stats testing storage class sc-cephrbd-replica2] ***************************************************************************************
Thursday 19 November 2020  01:30:31 +0000 (0:01:24.765)       0:13:06.037 *****
ok: [localhost] => (item={'cmd': 'export KUBECONFIG=$HOME/.kube/config\noc exec -n testing-ocs-storage fio-testing-performance-0 -it -- fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --directory=/usr/share/ocs-pvc --bs=4K --iodepth=64 --size=5G --rw=randwrite --nrfiles=1280.0 --refill_buffers=1\n', 'stdout': 'test: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64\nfio-3.19\nStarting 1 process\ntest: Laying out IO files (1280 files / total 5120MiB)\n\ntest: (groupid=0, jobs=1): err= 0: pid=30: Thu Nov 19 01:30:23 2020\n  write: IOPS=16.6k, BW=64.7MiB/s (67.8MB/s)(5120MiB/79137msec); 0 zone resets\n   bw (  KiB/s): min=38776, max=138618, per=99.93%, avg=66203.02, stdev=12842.18, samples=157\n   iops        : min= 9694, max=34654, avg=16550.74, stdev=3210.46, samples=157\n  cpu          : usr=5.87%, sys=24.01%, ctx=634519, majf=0, minf=7\n  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%\n     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%\n     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%\n     issued rwts: total=0,1310720,0,0 short=0,0,0,0 dropped=0,0,0,0\n     latency   : target=0, window=0, percentile=100.00%, depth=64\n\nRun status group 0 (all jobs):\n  WRITE: bw=64.7MiB/s (67.8MB/s), 64.7MiB/s-64.7MiB/s (67.8MB/s-67.8MB/s), io=5120MiB (5369MB), run=79137-79137msec\n\nDisk stats (read/write):\n  rbd0: ios=0/1307613, merge=0/41661, ticks=0/4943261, in_queue=4285558, util=94.22%', 'stderr': 'Unable to use a TTY - input is not a terminal or the right kind of file', 'rc': 0, 'start': '2020-11-19 01:29:03.355251', 'end': '2020-11-19 01:30:24.031011', 'delta': '0:01:20.675760', 'changed': True, 'invocation': {'module_args': {'_raw_params': 'export KUBECONFIG=$HOME/.kube/config\noc exec -n testing-ocs-storage fio-testing-performance-0 -it -- fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --directory=/usr/share/ocs-pvc --bs=4K --iodepth=64 --size=5G --rw=randwrite --nrfiles=1280.0 --refill_buffers=1\n', '_uses_shell': True, 'warn': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'finished': 1, 'ansible_job_id': '967940780879.285165', 'stdout_lines': ['test: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64', 'fio-3.19', 'Starting 1 process', 'test: Laying out IO files (1280 files / total 5120MiB)', '', 'test: (groupid=0, jobs=1): err= 0: pid=30: Thu Nov 19 01:30:23 2020', '  write: IOPS=16.6k, BW=64.7MiB/s (67.8MB/s)(5120MiB/79137msec); 0 zone resets', '   bw (  KiB/s): min=38776, max=138618, per=99.93%, avg=66203.02, stdev=12842.18, samples=157', '   iops        : min= 9694, max=34654, avg=16550.74, stdev=3210.46, samples=157', '  cpu          : usr=5.87%, sys=24.01%, ctx=634519, majf=0, minf=7', '  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%', '     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%', '     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%', '     issued rwts: total=0,1310720,0,0 short=0,0,0,0 dropped=0,0,0,0', '     latency   : target=0, window=0, percentile=100.00%, depth=64', '', 'Run status group 0 (all jobs):', '  WRITE: bw=64.7MiB/s (67.8MB/s), 64.7MiB/s-64.7MiB/s (67.8MB/s-67.8MB/s), io=5120MiB (5369MB), run=79137-79137msec', '', 'Disk stats (read/write):', '  rbd0: ios=0/1307613, merge=0/41661, ticks=0/4943261, in_queue=4285558, util=94.22%'], 'stderr_lines': ['Unable to use a TTY - input is not a terminal or the right kind of file'], 'failed': False, 'attempts': 9, 'item': {'started': 1, 'finished': 0, 'ansible_job_id': '967940780879.285165', 'results_file': '/root/.ansible_async/967940780879.285165', 'changed': True, 'failed': False, 'item': 'fio-testing-performance-0', 'ansible_loop_var': 'item'}, 'ansible_loop_var': 'item'}) =>
  msg:
  - 'test: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64'
  - fio-3.19
  - Starting 1 process
  - 'test: Laying out IO files (1280 files / total 5120MiB)'
  - ''
  - 'test: (groupid=0, jobs=1): err= 0: pid=30: Thu Nov 19 01:30:23 2020'
  - '  write: IOPS=16.6k, BW=64.7MiB/s (67.8MB/s)(5120MiB/79137msec); 0 zone resets'
  - '   bw (  KiB/s): min=38776, max=138618, per=99.93%, avg=66203.02, stdev=12842.18, samples=157'
  - '   iops        : min= 9694, max=34654, avg=16550.74, stdev=3210.46, samples=157'
  - '  cpu          : usr=5.87%, sys=24.01%, ctx=634519, majf=0, minf=7'
  - '  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%'
  - '     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%'
  - '     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%'
  - '     issued rwts: total=0,1310720,0,0 short=0,0,0,0 dropped=0,0,0,0'
  - '     latency   : target=0, window=0, percentile=100.00%, depth=64'
  - ''
  - 'Run status group 0 (all jobs):'
  - '  WRITE: bw=64.7MiB/s (67.8MB/s), 64.7MiB/s-64.7MiB/s (67.8MB/s-67.8MB/s), io=5120MiB (5369MB), run=79137-79137msec'
  - ''
  - 'Disk stats (read/write):'
  - '  rbd0: ios=0/1307613, merge=0/41661, ticks=0/4943261, in_queue=4285558, util=94.22%'
```
### Monitoring performance during benchmark
We have two options for real time monitoring:  
- OpenShift Webconsole and Grafana (preferred) 
- CLI from the toolbox   
#### Using Openshift Webconsole and grafana
![alt text](https://github.com/ctorres80/ocs_performance/blob/v1.0.1/roles/rbd_ceph_performance/files/performance_screenshot.png?raw=true)
#### Using toolbox for cephrbd monitoring
![alt text](https://github.com/ctorres80/ocs_performance/blob/v1.0.1/roles/rbd_ceph_performance/files/performance_cli.png)  
You can use toolbox (not available out of the box and not supported tool) to connect to your ceph cluster and run `` rbd perf image iostat `` to have a realtime rbd image monitoring (missing in the OCS dashboards)
```bash
[ctorres-redhat.com@bastion ocs_performance]$ oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
[ctorres-redhat.com@bastion ~]$ oc -n openshift-storage rsh rook-ceph-tools-85dc5f7bc8-mj6xk
sh-4.4# rbd perf image iostat
NAME                                                                               WR   RD  WR_BYTES  RD_BYTES    WR_LAT   RD_LAT
ocs-storagecluster-cephblockpool/csi-vol-8b8ef8da-24d6-11eb-afdf-0a580a82020d 8.29k/s  0/s  32 MiB/s     0 B/s  12.84 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-8608dbbf-24d6-11eb-afdf-0a580a82020d 8.18k/s  0/s  32 MiB/s     0 B/s  12.68 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-6be9bc87-24d6-11eb-afdf-0a580a82020d 8.18k/s  0/s  32 MiB/s     0 B/s  12.78 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-79a4e26b-24d6-11eb-afdf-0a580a82020d 8.16k/s  0/s  32 MiB/s     0 B/s  12.90 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-8197574a-24d6-11eb-afdf-0a580a82020d 8.15k/s  0/s  32 MiB/s     0 B/s  12.81 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-741f501c-24d6-11eb-afdf-0a580a82020d 8.07k/s  0/s  32 MiB/s     0 B/s  12.85 ms  0.00 ns
ocs-storagecluster-cephblockpool/csi-vol-7c021d1f-248c-11eb-afdf-0a580a82020d     2/s  0/s  24 KiB/s     0 B/s   7.78 ms  0.00 ns
```
### Cleaning environment
#### Delete all
When the testing will be completed the ansible role includes a task for cleaning all the resources that have been created for the purpose of the test included: namespace, pvc, pv, statefulset 
```bash
TASK [rbd_ceph_performance : Testing fio testing storage class ocs-storagecluster-ceph-rbd completed!!! I'm going to clean fio environment] **************************************************************************************************
Thursday 19 November 2020  11:58:27 +0000 (0:00:00.147)       0:06:36.307 *****
changed: [localhost]

TASK [rbd_ceph_performance : Postgres pgbench testing] ***************************************************************************************************************************************************************************************
Thursday 19 November 2020  11:59:15 +0000 (0:00:47.440)       0:07:23.748 *****
skipping: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************
localhost                  : ok=24   changed=11   unreachable=0    failed=0    skipped=7    rescued=0    ignored=0

Thursday 19 November 2020  11:59:15 +0000 (0:00:00.016)       0:07:23.765 *****
===============================================================================
rbd_ceph_performance : Testing storage class ocs-storagecluster-ceph-rbd with fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --directory=/usr/share/ocs-pvc --bs=4K --iodepth=64 --size=10G --rw=randwrite --nrfiles=2560.0 --refill_buffers=1 - 248.54s
rbd_ceph_performance : Waiting for the availability of fio replicas=8 --------------------------------------------------------------------------------------------------------------------------------------------------------------- 104.20s
rbd_ceph_performance : Testing fio testing storage class ocs-storagecluster-ceph-rbd completed!!! I'm going to clean fio environment ------------------------------------------------------------------------------------------------- 47.44s
rbd_ceph_performance : pause --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 10.77s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 8.28s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 4.82s
rbd_ceph_performance : fio bench read, write, randwrite with storage class ocs-storagecluster-ceph-rbd -------------------------------------------------------------------------------------------------------------------------------- 3.74s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 3.16s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 2.82s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 2.41s
rbd_ceph_performance : pause ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 2.15s
Gathering Facts ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.96s
rbd_ceph_performance : Select storage class ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.88s
rbd_ceph_performance : Modify statefulset for block accordingly provisioner ----------------------------------------------------------------------------------------------------------------------------------------------------------- 0.47s
rbd_ceph_performance : Create the fio statefulset fio-testing-performance accordingly ------------------------------------------------------------------------------------------------------------------------------------------------- 0.43s
rbd_ceph_performance : Looking for storage provisioner -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.43s
rbd_ceph_performance : Scale fio for OCS to 8 pods in namespace testing-ocs-storage --------------------------------------------------------------------------------------------------------------------------------------------------- 0.42s
rbd_ceph_performance : Collect fio-testing-performance pod names ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.42s
rbd_ceph_performance : shell ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.40s
rbd_ceph_performance : Modify statefulset with the storageclass accordingly ----------------------------------------------------------------------------------------------------------------------------------------------------------- 0.30s
```