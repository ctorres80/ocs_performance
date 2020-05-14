#!/bin/bash
endpoint=$(oc get services s3 -n openshift-storage -o yaml -o jsonpath='{.spec.clusterIP}{"\n"}')
for i in {1..6}
do
 	access_key=$(oc get secrets test-ocs-$i -n openshift-storage -o jsonpath='{.data.AWS_ACCESS_KEY_ID}{"\n"}' | base64 -d)
 	secret_key=$(oc get secrets test-ocs-$i -n openshift-storage -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}{"\n"}' | base64 -d)
 	bucket=$(oc get configmap test-ocs-$i -n openshift-storage -o jsonpath='{.data.BUCKET_NAME}{"\n"}')
	echo "s3cmd --host-bucket= --no-ssl --multipart-chunk-size-mb=256 --host=$endpoint --access_key=$access_key --secret_key=$secret_key sync /opt/data/ s3://$bucket"
	echo "==================================================================================================================================================================================================================="
done