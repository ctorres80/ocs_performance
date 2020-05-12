#!/bin/bash
for i in {1..9}
do
	oc delete all --all -n my-postgres-$i
	oc delete pvc postgresql -n my-postgres-$i
	oc delete project my-postgresql-$i
done