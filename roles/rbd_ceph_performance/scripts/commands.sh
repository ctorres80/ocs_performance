# requirements for
sudo yum install -y python2-openshift.noarch
sudo yum install -y python2-openshift.noarch

# get worker nodes
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
# discovery CPUs in workers
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc debug node/$node -- lscpu|grep "^CPU(s)"; done
# discovery RAM
oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do oc debug node/$node -- free -h; done
# get the OCS workers
oc get nodes -l cluster.ocs.openshift.io/openshift-storage= -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}'
# label namespace openshift-storage for monitoring
oc label namespace openshift-storage "openshift.io/cluster-monitoring=true"
# enable ceph-tool in ocs
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
oc -n openshift-storage patch StorageCluster ocs-storagecluster --type=json -p '[{"op": "replace", "path": "/spec/storageDeviceSets/1/dataPVCTemplate/spec/resources/requests/storage", "value":4Ti}]'
# delete files with fstrim by running commands from hosts with oc debug
oc get pods -l app=fio-testing-performance -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read fiopod; do oc exec $fiopod  -i -t -- find /usr/share/ocs-pvc/ -type f -name 'test*' -delete; done
oc get pods -l app=fio-testing-performance -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read fiopod; do oc exec $fiopod -- fstrim /usr/share/ocs-pvc; done
oc get pod -l app=fio-testing-performance -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\t"}{"\n"}{end}' | while read output; do pvc=$(echo $output | cut -d' ' -f3); pv=$(oc get pvc $pvc -o jsonpath='{.items[*]}{.spec.volumeName}{"\n"}');echo -e "$output \t $pv";done | while read line; do pv=$(echo $line | cut -d' ' -f4); node=$(echo $line | cut -d' ' -f2);mountpoint=$(oc debug node/$node -- df -hk | grep $pv | awk '{print $NF}'); echo "oc debug node/$node -- fstrim $mountpoint; sleep 5";done > fstrim_pvc.sh; chmod +x fstrim_pvc.sh
# Scale noobaa postgress from operator to 4 cpus
oc -n openshift-storage patch Noobaa noobaa --type=json -p '[{"op": "replace", "path": "/spec/endpoints/resources/limits/cpu", "value":4}]'
# Create simple blog application
curl -s https://raw.githubusercontent.com/red-hat-storage/ocs-training/master/training/modules/ocs4/attachments/configurable-rails-app.yaml | oc new-app -p STORAGE_CLASS=ocs-storagecluster-ceph-rbd -p VOLUME_CAPACITY=50Gi -f -