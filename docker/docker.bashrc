### Disable docker Snyk suggestion after ``docker build``
#export DOCKER_SCAN_SUGGEST=false

alias dsl="docker service ls"
alias dps="docker ps"

dex () {
    pattern=$1
    shift
    echo "Pattern: $pattern"
    if [[ -z "$pattern" ]]; then
        echo "No pattern provided"
        return 1
    fi

    # Get containers matching pattern
    containers=($(docker ps | awk '/'$pattern'/ {print $1}'))
    container_names=($(docker ps | awk '/'$pattern'/ {print $NF}'))

    # Check if no containers found
    if [ ${#containers[@]} -eq 0 ]; then
        echo "No containers found matching pattern: $pattern"
        return 1
    fi

    # If exactly one container found, use it
    if [ ${#containers[@]} -eq 1 ]; then
        echo "Executing command on container: ${container_names[0]}"
        docker exec -it ${containers[0]} "$@"
        return
    fi

    # If multiple containers found, let user choose
    echo "Multiple containers found:"
    for i in "${!containers[@]}"; do
        echo "[$i] ${container_names[$i]} (${containers[$i]})"
    done

    read -p "Choose container number (0-$((${#containers[@]}-1))): " choice

    # Validate choice
    if [[ ! $choice =~ ^[0-9]+$ ]] || [ $choice -ge ${#containers[@]} ]; then
        echo "Invalid selection"
        return 1
    fi

    echo "Executing command on container: ${container_names[$choice]}"
    docker exec -it ${containers[$choice]} "$@"
}

drm() {
  pattern=$1
  echo "Pattern: $pattern"
  if [[ -z "$pattern" ]]; then
      return
  fi
  echo "Start removing docker images"
  docker rmi --force $(docker images | awk '/'$pattern'/ {print $3}')
}

drms() {
  pattern=$1
  echo "Pattern: $pattern"
  if [[ -z "$pattern" ]]; then
      return
  fi
  echo "Start removing stacks"
  docker stack rm $(docker stack ls | awk '/'$pattern'/ {print $1}')
}


drmv() {
  pattern=$1
  echo "Pattern: $pattern"
  if [[ -z "$pattern" ]]; then
      return
  fi
  volumes=$(docker volume ls | awk '/'$pattern'/ {print $2}')

  for volume in $volumes; do
    read -p "Do you want to remove volume $volume? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo "Removing volume: $volume"
        docker volume rm $volume
    else
        echo "Skipping volume: $volume"
    fi
  done
}

drmse() {
  pattern=$1
  echo "Pattern: $pattern"
  if [[ -z "$pattern" ]]; then
      return
  fi
  secrets=$(docker secret ls | awk '/'$pattern'/ {print $2}')

  for secret in $secrets; do
    read -p "Do you want to remove secret $secret? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo "Removing secret: $secret"
        docker secret rm $secret
    else
        echo "Skipping secret: $secret"
    fi
  done
}

