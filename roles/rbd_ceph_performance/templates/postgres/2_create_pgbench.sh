#!/bin/bash
#oc new-app --name=postgresql-block-4 --template=postgresql-persistent-ocs
for i in {1..9}
do
 	user=$(oc get secrets postgresql -n my-testing-pgbench-ocs-$i -o jsonpath='{.data.database-user}{"\n"}' | base64 -d)
 	password=$(oc get secrets postgresql -n my-testing-pgbench-ocs-$i -o jsonpath='{.data.database-password}{"\n"}' | base64 -d)
	service=$(oc get service -n my-testing-pgbench-ocs-$i -o jsonpath='{range .items[*]}{@.spec.clusterIP}{"\n"}')
    postgres_pod=$(oc get pods -n my-testing-pgbench-ocs-$i -o  jsonpath='{range .items[*]}{@.metadata.name}{"\n"}' | grep -v deploy)
#	echo "oc -n my-testing-pgbench-ocs-$i exec $postgres_pod -it -- pgbench -U $user -h $service -i -s 500 sampledb # $password"
#	echo "oc -n my-testing-pgbench-ocs-$i rsh $postgres_pod"
#	echo "export PGPASSWORD=$password"
#	echo "pgbench -U $user -h $service -i -s 2000 sampledb # $password"
#	echo "=============================================================================================================="