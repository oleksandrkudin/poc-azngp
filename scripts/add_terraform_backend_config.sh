#!/usr/bin/bash

function help () {
  cat <<- EOT
Usage: $(basename $0) [options...]

Add terraform azurerm backend configuration file for current Terraform code directory. It could fallback to local backend if storage account does not exist.

Options:
  -e, --environment     [Required]  Delivery environment name
  -l, --fallback-to-local           If storage account does not exist, then create local backend configuration file
  -h, --help                        Show this help output
EOT
}

if options=$(getopt --options hle: --longoptions help,fallback-to-local,environment: -- "$@"); then
  eval set -- "$options"
  while true; do
    case "$1" in
      -e | --environment)
        shift
        environment=$1
        ;;
      -l | --fallback-to-local)
        fallback_to_local=1
        ;;
      -h | --help)
        help
        exit 0
        ;;
      --)
        shift
        break
        ;;
    esac
    shift
  done
else
  help
  exit 1
fi

if [[ -z $environment ]]; then
  echo "Error: Missed required argument(s)." >&2
  help
  exit 1
fi

fallback_to_local=${fallback_to_local:=0}

echo "Creating backend_override.tf.json for current terraform project ..."
terraform -chdir=../../modules/terraform-azurerm-backend init
terraform -chdir=../../modules/terraform-azurerm-backend apply -auto-approve -var component_path=$(pwd) \
  -var-file  ../../configurations/global.tfvars \
  -var-file ../../configurations/environments/${environment}/environment.tfvars
backend_config=$(terraform -chdir=../../modules/terraform-azurerm-backend output -json | jq --compact-output '.terraform_backend_block.value')


if [ $fallback_to_local -eq 1 ]; then
  resource_group_name=$(echo $backend_config | jq --raw-output '.terraform.backend.azurerm.resource_group_name')
  storage_account_name=$(echo $backend_config | jq --raw-output '.terraform.backend.azurerm.storage_account_name')
  if az storage account show -n $storage_account_name -g $resource_group_name > /dev/null; then
    echo $backend_config | jq | tee backend_override.tf.json
  else
    if [ $? -eq 3 ]; then
      echo "Fallback to use local backend."
      cat <<-EOF | tee backend_override.tf.json
{
  "terraform": {
    "backend": {
      "local": {}
    } 
  }
}
EOF
    else
      exit $?
    fi
  fi
else
  echo $backend_config | jq | tee backend_override.tf.json
fi