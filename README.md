# Synthetic benchmarking tool for OpenShift Container Storage for block and file interfaces

## Introduction 
The following ansible role can help you to automate performance benchmarking to OpenShift Container Storage.
This is in an interactive playbook for synthetic benchmarking workloads that covers different workload profiles based on what you're interesting to test.

## Requirements
- OpenShift v4.2+ 
- OpenShift Container Storage v4.2+ (AKA OCS)
- Supported infrastructures: AWS IPI, VMware UPI (Other platforms have not been tested yet but it should works because there not dependencies)
- OpenShift management node with admin serviceaccount
- oc client and authentication with kubeconfig file

## What this playbook can do for you?
The role will automate following workflow:
- It will deploy a 2 Statefulsets:
    - 1 Statefulset with fio container that will consume block with ceph-rbd interface in OCS
    - 1 Statefulset with fio container that will consume file with cephfs interface in OCS
- Create a dedicated rbd images in the format rbd_name_{{ ansible_hostname }}
- Run "rbd bench" in parallel from each client
- The "rbd bench" statistics are reported in the standard output you can redirect to file for further analysis
- Multiple workload and profiles are supported in this role: :
  - profile: sequential, random
  - type: write, read, rw 
  - block size: 4K, 8K, 16K, 32K, 64K, 128K, 256K, 512K, 1024K, 2048K, 4096K
  - file size: XXXG  (XXX is the size of amount of data to transfer) 


## Testing environment
Following the Openshift cluster information 
```bash
[ctorres-redhat.com@bastion ~]$ oc version
Client Version: 4.5.7
Server Version: 4.6.3
Kubernetes Version: v1.19.0+9f84db3
```
    [ctorres-redhat.com@bastion tools]$ oc get nodes -L kubernetes.io/hostname -L node.kubernetes.io/instance-type -L failure-domain.beta.kubernetes.io/region -L failure-domain.beta.kubernetes.io/zone
    NAME                                            STATUS   ROLES    AGE   VERSION           HOSTNAME          INSTANCE-TYPE   REGION         ZONE
    ip-10-0-145-177.eu-central-1.compute.internal   Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-145-177   m5.4xlarge      eu-central-1   eu-central-1a
    ip-10-0-151-216.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-151-216   c5d.2xlarge     eu-central-1   eu-central-1a
    ip-10-0-182-17.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-182-17    m5.4xlarge      eu-central-1   eu-central-1b
    ip-10-0-186-76.eu-central-1.compute.internal    Ready    master   12h   v1.19.0+9f84db3   ip-10-0-186-76    c5d.2xlarge     eu-central-1   eu-central-1b
    ip-10-0-192-170.eu-central-1.compute.internal   Ready    master   12h   v1.19.0+9f84db3   ip-10-0-192-170   c5d.2xlarge     eu-central-1   eu-central-1c
    ip-10-0-212-27.eu-central-1.compute.internal    Ready    worker   12h   v1.19.0+9f84db3   ip-10-0-212-27    m5.4xlarge      eu-central-1   eu-central-1c


In my lab I running Red Hat Cep Storage v4:  

    [ansible@host1 deployment]$ sudo ceph --version
    ceph version 14.2.4-125.el8cp (db63624068590e593c47150c7574d08c1ec0d3e4) nautilus (stable)

In the Ceph cluster we have 9 OSDs:
    
    [ansible@host1 deployment]$ sudo ceph osd tree
    ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF
    -1       0.87025 root default
    -5       0.29008     host host1
    0   hdd 0.09669         osd.0      up  1.00000 1.00000
    3   hdd 0.09669         osd.3      up  1.00000 1.00000
    6   hdd 0.09669         osd.6      up  1.00000 1.00000
    -7       0.29008     host host2
    1   hdd 0.09669         osd.1      up  1.00000 1.00000
    4   hdd 0.09669         osd.4      up  1.00000 1.00000
    7   hdd 0.09669         osd.7      up  1.00000 1.00000
    -3       0.29008     host host3
    2   hdd 0.09669         osd.2      up  1.00000 1.00000
    5   hdd 0.09669         osd.5      up  1.00000 1.00000
    8   hdd 0.09669         osd.8      up  1.00000 1.00000

And based on Nautilus version the default object store is bluestore, we can easily check with this command:

    [ansible@host1 deployment]$ sudo ceph osd tree | grep "osd." | awk '{print $4}' | while read osd; do echo $osd; sudo ceph osd metadata osd.$i | grep osd_objectstore ; done
    osd.0
        "osd_objectstore": "bluestore",
    osd.3
        "osd_objectstore": "bluestore",
    osd.6
        "osd_objectstore": "bluestore",
    osd.1
        "osd_objectstore": "bluestore",
    osd.4
        "osd_objectstore": "bluestore",
    osd.7
        "osd_objectstore": "bluestore",
    osd.2
        "osd_objectstore": "bluestore",
    osd.5
        "osd_objectstore": "bluestore",
    osd.8
        "osd_objectstore": "bluestore",

The workload is defined in the followig variables:

    [ansible@host1 deployment]$ cat roles/rbd_ceph_performance/defaults/main.yml
      ---
      pool_name: 'rbd'
      rbd_name: 'volume_testing'
      rbd_size: '5G'
      io_type: 'rw'
      io_size: '64K'
      io_threads: '1'
      io_total: '3G'
      io_pattern: 'rand'
      rw_mix_read: 50
      rbd_image_name: '{{ rbd_name }}_{{ ansible_hostname }}'
      path_fio_files: '/root/ceph_performance'

## Let's have fun

Create an ansible playbook by using the role, following an example:

    ---
    - name: 'Using ansible rbd_ceph_performance role'
      hosts: clients
      become: true
      roles:
        - rbd_ceph_performance

Now let's share some screenshots with comments:

![1.](1.png)

![2.](2.png)

![3.](3.png)

While the benchmark is running you can monitor performance in real time  from RHCS v4 dashboard  

![4.](4.png)