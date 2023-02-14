# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#!/bin/bash
echo $1
echo $2
echo $3

set -euo pipefail

gen_manifests_file_name='gen_manifests.yaml'
values_file_name='values.yaml'

# Usage:
# generate-manifests.sh FOLDER_WITH_MANIFESTS FOLDER_WITH_CONFIGS GENERATED_MANIFESTS_FOLDER


mkdir -p $3

# Substitute env variables in Helm yaml files in the manifest folder
for file in `find $1 -type f \( -name "*.yaml" \)`; do 
  service_name=$(yq '.name' $file)
  helm_repository=$(yq '.helm.repository' $file)
  helm_chart=$(yq '.helm.chart' $file)
  helm_chart_version=$(yq '.helm.version' $file)

  echo $file
  echo $service_name
  echo $helm_repository
  echo $helm_chart
  echo $helm_chart_version

  helm repo add $service_name $helm_repository
  mkdir -p $3/$service_name
  helm template $service_name $service_name/$helm_chart --version $helm_chart_version -f $2/$service_name/$values_file_name | sed '/namespace: default/d' > $3/$service_name/$gen_manifests_file_name
  cat $3/$service_name/$gen_manifests_file_name
done
