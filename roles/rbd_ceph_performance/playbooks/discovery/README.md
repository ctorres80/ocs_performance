# Playbooks for simplify some taks with local-storage in OpenShift Container Storage

## Introduction 
Those ansible playbooks provides an intereactive menu for storage operations.

WARNING: Those playbooks are personal tools and don't recommended and supported in production clusters.

REQUIREMENTS: ansible and jq

## What can I do for you?
The playbooks will offer the following interactive menu:
    
    Hey there, what do you want to do?
    1=List device-byid for Create/Update loca-storage CR
    2=Replace a failed OSD (interactive)
    3=Listing OSD information deviceset|pv|pvc|host
    [0]: 1

## Testing environment
Following the cluster for testing the playbooks:
* OCP Cluster v4.3 with 3 masters, IPI deployment
* OCS v4.3 operator with local-storage (Techpreview)
* OCS i3.8xlarge AWS instances with 4 local NVMes with 1.8TB size each  
    
     
        [ctorres-redhat.com@clientvm 130 ~/deploy/tools/ocs-osd-manager]$ oc get machines
        NAME                                                   PHASE     TYPE         REGION         ZONE            AGE
        cluster-milano-9521-8xh7k-master-0                     Running   m5.xlarge    eu-central-1   eu-central-1a   3d6h
        cluster-milano-9521-8xh7k-master-1                     Running   m5.xlarge    eu-central-1   eu-central-1b   3d6h
        cluster-milano-9521-8xh7k-master-2                     Running   m5.xlarge    eu-central-1   eu-central-1c   3d6h
        cluster-milano-9521-8xh7k-worker-eu-central-1a-svlkq   Running   m5.4xlarge   eu-central-1   eu-central-1a   3d6h
        cluster-milano-9521-8xh7k-worker-eu-central-1b-g7lfr   Running   m5.4xlarge   eu-central-1   eu-central-1b   3d6h
        cluster-milano-9521-8xh7k-worker-eu-central-1c-r54sg   Running   m5.4xlarge   eu-central-1   eu-central-1c   3d5h
        ocs-worker-eu-central-1a-hlppq                         Running   i3.8xlarge   eu-central-1   eu-central-1a   48m
        ocs-worker-eu-central-1b-kfv4k                         Running   i3.8xlarge   eu-central-1   eu-central-1b   48m
        ocs-worker-eu-central-1c-kwfs6                         Running   i3.8xlarge   eu-central-1   eu-central-1c   48m

## Let's do some testing

Use case 1: Discover the OCS nodes and return the local-block CR useful to create devices with device-byid format, please remember to configure variable "disk_size_bytes" in vars/vars.yml (it should be whatever size but greater than Operating System disks)

    [ctorres-redhat.com@clientvm 0 ~/deploy/tools/ocs-osd-manager]$ ansible-playbook osd_manager.yml
    [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

    Hey there, what do you want to do?
    1=List device-byid for Create/Update loca-storage CR
    2=Replace a failed OSD (interactive)
    3=Listing OSD information deviceset|pv|pvc|host
    [0]: 1

    PLAY [Playbook for Ceph OSD mapping in OpenShift] ************************************************************************************************************************************************************************

    TASK [Gathering Facts] ***************************************************************************************************************************************************************************************************
    ok: [localhost]

    TASK [Collect OCS workers] ***********************************************************************************************************************************************************************************************
    changed: [localhost]

    TASK [Collect device by-id and size] *************************************************************************************************************************************************************************************
    changed: [localhost]

    TASK [Collect device by-id] **********************************************************************************************************************************************************************************************
    changed: [localhost] => (item=ip-10-0-141-44.eu-central-1.compute.internal)
    changed: [localhost] => (item=ip-10-0-157-251.eu-central-1.compute.internal)
    changed: [localhost] => (item=ip-10-0-163-72.eu-central-1.compute.internal)

    TASK [Print to screen config file ./local-storage-block.yaml] ************************************************************************************************************************************************************
    changed: [localhost]

    TASK [debug] *************************************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": [
            "apiVersion: local.storage.openshift.io/v1",
            "kind: LocalVolume",
            "metadata:",
            "  name: local-block",
            "  namespace: local-storage",
            "spec:",
            "  nodeSelector:",
            "    nodeSelectorTerms:",
            "    - matchExpressions:",
            "        - key: cluster.ocs.openshift.io/openshift-storage",
            "          operator: In",
            "          values:",
            "          - \"\"",
            "  storageClassDevices:",
            "    - storageClassName: localblock",
            "      volumeMode: Block",
            "      devicePaths:",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS1032495F0D628878C # nvme0n1    1769 GB    ip-10-0-141-44.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS6032495F0D628878C # nvme1n1    1769 GB    ip-10-0-141-44.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS1977293BF68DDE42D # nvme2n1    1769 GB    ip-10-0-141-44.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS6977293BF68DDE42D # nvme3n1    1769 GB    ip-10-0-141-44.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS1C2B4567DAD58239A # nvme0n1    1769 GB    ip-10-0-157-251.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS6C2B4567DAD58239A # nvme1n1    1769 GB    ip-10-0-157-251.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS1EDE35EF918811545 # nvme2n1    1769 GB    ip-10-0-157-251.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS6EDE35EF918811545 # nvme3n1    1769 GB    ip-10-0-157-251.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS10FDCEE1E2D1EC57B # nvme0n1    1769 GB    ip-10-0-163-72.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS60FDCEE1E2D1EC57B # nvme1n1    1769 GB    ip-10-0-163-72.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS1881394BBC04782BC # nvme2n1    1769 GB    ip-10-0-163-72.eu-central-1.compute.internal",
            "        - /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_AWS6881394BBC04782BC # nvme3n1    1769 GB    ip-10-0-163-72.eu-central-1.compute.internal"
        ]
    }

    TASK [Clean files] *******************************************************************************************************************************************************************************************************
    changed: [localhost] => (item=./file_tmp_1)
    changed: [localhost] => (item=./file_tmp_2)

    TASK [pause] *************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Check OSD status] **************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Warning print OSD status up] ***************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Warning wrong osd] *************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Check pg status] ***************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [pause] *************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Remove and clean osd {{ osd_id.user_input }}] **********************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [debug] *************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Clean files] *******************************************************************************************************************************************************************************************************
    skipping: [localhost] => (item=./file_tmp_1)
    skipping: [localhost] => (item=./file_tmp_2)
    skipping: [localhost] => (item=./file_tmp_3)

    TASK [Get device->pv->pvc->host information] *****************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [debug] *************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Clean files] *******************************************************************************************************************************************************************************************************
    skipping: [localhost] => (item=./file_tmp_1)
    skipping: [localhost] => (item=./file_tmp_2)
    skipping: [localhost] => (item=./file_tmp_3)

    PLAY RECAP ***************************************************************************************************************************************************************************************************************
    localhost                  : ok=7    changed=5    unreachable=0    failed=0    skipped=12   rescued=0    ignored=0

    [ctorres-redhat.com@clientvm 0 ~/deploy/tools/ocs-osd-manager]$ oc create -f local-storage-block.yaml
    localvolume.local.storage.openshift.io/local-block created
    [ctorres-redhat.com@clientvm 0 ~/deploy/tools/ocs-osd-manager]$ oc get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                        STORAGECLASS   REASON   AGE
    local-pv-10ee1aeb                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-111134d4                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-1cd1beec                          1769Gi     RWO            Delete           Available                                localblock              6m54s
    local-pv-37eb7cdf                          1769Gi     RWO            Delete           Available                                localblock              6m54s
    local-pv-51a7939b                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-643f2246                          1769Gi     RWO            Delete           Available                                localblock              6m54s
    local-pv-69d0199                           1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-70cc1dc8                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-90e812                            1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-9e7e33ea                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    local-pv-ac1a8ed5                          1769Gi     RWO            Delete           Available                                localblock              6m54s
    local-pv-ad10eded                          1769Gi     RWO            Delete           Available                                localblock              7m10s
    pvc-98b3dc0b-730d-48f6-813f-5fb732845c79   1Gi        RWO            Delete           Bound       terminal/terminal-hub-data   gp2                     3d7h

Use case 2: Replace OSD (work in progress, some issues with local-storage pvs)

use case 3: List the device-pv-pvc-osd.id-node

    [ctorres-redhat.com@clientvm 130 ~/deploy/tools/ocs-osd-manager]$ ansible-playbook osd_manager.yml
    [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

    Hey there, what do you want to do?
    1=List device-byid for Create/Update loca-storage CR
    2=Replace a failed OSD (interactive)
    3=Listing OSD information deviceset|pv|pvc|host
    [0]: 3

    PLAY [Playbook for Ceph OSD mapping in OpenShift] ******************************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************************************************
    ok: [localhost]

    TASK [Collect OCS workers] *****************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Collect device by-id and size] *******************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Collect device by-id] ****************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Print to screen config file ./local-storage-block.yaml] ******************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [debug] *******************************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Clean files] *************************************************************************************************************************************************************************************************************************
    skipping: [localhost] => (item=./file_tmp_1)
    skipping: [localhost] => (item=./file_tmp_2)

    TASK [pause] *******************************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Check OSD status] ********************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Warning print OSD status up] *********************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Warning wrong osd] *******************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Check pg status] *********************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [pause] *******************************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Remove and clean osd {{ osd_id.user_input }}] ****************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [debug] *******************************************************************************************************************************************************************************************************************************
    skipping: [localhost]

    TASK [Clean files] *************************************************************************************************************************************************************************************************************************
    skipping: [localhost] => (item=./file_tmp_1)
    skipping: [localhost] => (item=./file_tmp_2)
    skipping: [localhost] => (item=./file_tmp_3)

    TASK [Get device->pv->pvc->host information] ***********************************************************************************************************************************************************************************************
    changed: [localhost]

    TASK [debug] *******************************************************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": [
            "PVC                      OSD_ID  PV                 MOUNT_POINT                            PROVISIONED-BY",
            "ocs-deviceset-0-0-2tcpk  0       local-pv-ac1a8ed5  /mnt/local-storage/localblock/nvme2n1  ip-10-0-157-251",
            "ocs-deviceset-0-1-b7kjd  1       local-pv-1cd1beec  /mnt/local-storage/localblock/nvme3n1  ip-10-0-157-251",
            "ocs-deviceset-1-0-qcn9j  2       local-pv-69d0199   /mnt/local-storage/localblock/nvme0n1  ip-10-0-163-72",
            "ocs-deviceset-1-1-trzzj  3       local-pv-9e7e33ea  /mnt/local-storage/localblock/nvme1n1  ip-10-0-163-72",
            "ocs-deviceset-2-0-xkmph  5       local-pv-70cc1dc8  /mnt/local-storage/localblock/nvme0n1  ip-10-0-141-44",
            "ocs-deviceset-2-1-zfjq4  4       local-pv-90e812    /mnt/local-storage/localblock/nvme2n1  ip-10-0-141-44",
            "",
            "OSD_ID  TYPE  WEIGHT              STATUS",
            "osd.0   ssd   1.7274932861328125  up",
            "osd.1   ssd   1.7274932861328125  up",
            "osd.2   ssd   1.7274932861328125  up",
            "osd.3   ssd   1.7274932861328125  up",
            "osd.4   ssd   1.7274932861328125  up",
            "osd.5   ssd   1.7274932861328125  up"
        ]
    }

    TASK [Clean files] *************************************************************************************************************************************************************************************************************************
    changed: [localhost] => (item=./file_tmp_1)
    changed: [localhost] => (item=./file_tmp_2)
    changed: [localhost] => (item=./file_tmp_3)

    PLAY RECAP *********************************************************************************************************************************************************************************************************************************
    localhost                  : ok=4    changed=2    unreachable=0    failed=0    skipped=15   rescued=0    ignored=0
