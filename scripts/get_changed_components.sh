#!/usr/bin/bash

function log_verbose () {
  if [ $VERBOSE -eq 1 ]; then
    echo "$@" >&2
  fi
}

function help () {
  cat <<- EOT
Usage: $(basename $0) [options...]

Provide list of components that should be built based on changes in project repository.
It helps to implement granular build/deploy. And so it allows to reduce build/deploy time by process only components that were changed in feature branch but not all. 

If git-base-ref, GITHUB_BASE_REF are not set then only last commit pointing by HEAD is analysed for changed files. Otherwise all commits starting from HEAD and up to git-base-ref (excluded) are analysed.

Component should be processed if at least one of the following condition is met:
  - if shared repository project element was changed then all components must be processed. Example: .github, scripts are shared elements of project.
  - if componet itself was changed.
  - if any local terraform module that component depends on was changed.  

Options:
  --git-base-ref      [Optional] Git reference of merge base branch. Default is GITHUB_BASE_REF environment variables. It is only relevant for feature branch, pull request to compare changes.
  -v, --verbose                  Make the operation more talkative
  -h, --help                     Show this help output
EOT
}

function parse_arguments () {
  if options=$(getopt --options vh --longoptions verbose,help,git-base-ref: -- "$@"); then
    eval set -- "$options"
    while true; do
      case "$1" in
        -v | --verbose)
          VERBOSE=1
          ;;
        -h | --help)
          help
          exit 0
          ;;
        --git-base-ref)
          shift
          GIT_BASE_REF=$1
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
}

function get_changed_files () {
  [ $# -gt 0 ] && local git_base_ref=$1

  log_verbose "Getting git changed files ..."
  changed_files=$(git diff-tree --no-commit-id --name-only -r $(git log -1 --format='%H') ${git_base_ref})
  log_verbose $changed_files
 
  echo "$changed_files"  # double quotes to output multi-line string
}

function tracked_items_changed_files_map () {
  local -n local_tracked_items_path_map=$1  # pass associated array by reference
  local changed_files=$2  # multi-line string in expected

  log_verbose "Getting tracked changed items ..."
  declare -g -A tracked_items_changed_files_map  # create global associated array
  for tracked_item in ${!local_tracked_items_path_map[@]}; do
    log_verbose -n "Creating list of $tracked_item that were changed ... "
    changed_items=$(echo "$changed_files" | sed -rn 's/'${local_tracked_items_path_map[$tracked_item]}'\/(\S+?)\/.*/\1/p')
    log_verbose $changed_items
    tracked_items_changed_files_map[$tracked_item]=$changed_items
  done
}

function get_component_local_modules () {
  local component_path=$1

  log_verbose "Getting all local terraform modules that component depends on ..."
  pushd $component_path > /dev/null
  terraform get
  component_local_modules=$(jq '.Modules[] | select (.Source | contains("./")) | .Source | split("/") | last' .terraform/modules/modules.json | jq --slurp)
  log_verbose $component_local_modules
  popd > /dev/null

  echo $component_local_modules
}

function shared_paths_changed () {
  local -n local_shared_paths=$1  # pass array by reference
  local changed_files=$2  # multi-line string in expected

  log_verbose "Checking if shared directories were changed ..."
  shared_paths_changed=false
  for shared_path in ${local_shared_paths[@]}; do
    log_verbose -n "Checking if any in $shared_path directory was changed ... "
    shared_path_changed=$([[ "$changed_files" =~ "$shared_path/" ]] && echo "true" || echo "false")
    log_verbose $shared_path_changed

    if $shared_path_changed; then
      shared_paths_changed=true
      log_verbose "Skipping rest of shared paths as at least one shared directory was changed."
      break
    fi
  done

  $shared_paths_changed && update_component_reason="Shared directory was changed." && return 0 || return 1
}

function component_changed () {
  local component=$1
  local changed_components=$2

  log_verbose "Checking if component was changed ..."
  [[ $component =~ $changed_components ]] && update_component_reason="Component was changed." && return 0 || return 1  
}

function component_module_changed () {
  local component_path=$1
  local changed_modules=$2

  log_verbose "Checking if component local module was changed ..."

  component_local_modules=$(get_component_local_modules $component_path)

  log_verbose -n "Getting changed local terraform modules that component depends on ... "
  changed_component_local_modules=$(jq -cn --argjson a "$component_local_modules" --argjson b "$(echo \"$changed_modules\" | jq --raw-input | jq --slurp)" '$a - ($a - $b)')
  log_verbose $changed_component_local_modules

  [ "$changed_component_local_modules" != "[]" ] && update_component_reason="Some component module was changed." && return 0 || return 1
}

# Arguments and default
parse_arguments "$@"
VERBOSE=${VERBOSE:-0}
GIT_BASE_REF=${GIT_BASE_REF:-$GITHUB_BASE_REF}

# Configuration
components_path="src"
modules_path="modules"
declare -A tracked_items_path_map=(
  [components]="src"
  [modules]="modules"
)
shared_paths=(".github" "scripts")
update_component_reason=

# Main
changed_files=$(get_changed_files $GIT_BASE_REF)

tracked_items_changed_files_map "tracked_items_path_map" "$changed_files"  # double quotes to pass multi-line string
shared_paths_changed "shared_paths" "$changed_files"  # double quotes to pass multi-line string

update_components=()
for component_path in $(ls -d ${tracked_items_path_map["components"]}/*); do
  component=$(basename $component_path)
  log_verbose "Checking if $component component require update ..."

  if $shared_paths_changed ||
    component_changed $component "${tracked_items_changed_files_map['components']}" ||
    component_module_changed $component_path "${tracked_items_changed_files_map['modules']}"
  then
    log_verbose "Adding $component to update list. $update_component_reason"
    update_components+=($component)
  fi
done

echo ${update_components[@]}