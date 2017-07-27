#!/usr/bin/env bash
#
# <bitbar.title>Docker Container Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Jerome Schaeffer</bitbar.author>
# <bitbar.author.github>Neofox</bitbar.author.github>
# <bitbar.desc>Displays the status of running containers by networks</bitbar.desc>
# <bitbar.dependencies>shell,docker</bitbar.dependencies>
#
# Based on the work of Manoj Mahalingam (@manojlds)
#
# Displays the status of Docker For Mac containers

export PATH="/usr/local/bin:/usr/bin:$PATH"
echo "🐳| dropdown=false"
echo "---"

function containers() {
  CONTAINERS="$(docker ps -a --filter "network=$network" --format "{{.Names}}|{{.ID}}|{{.Status}}")"
  if [ -z "$CONTAINERS" ]; then
    echo "No running containers"
  else
    LAST_CONTAINER=$(echo "$CONTAINERS" | tail -n1 )
    echo "${CONTAINERS}" | while read -r CONTAINER; do
      CONTAINER_NAME=$(echo "$CONTAINER" | awk -F"|" '{print $1}')
      CONTAINER_ID=$(echo "$CONTAINER" | awk -F"|" '{print $2}')
      CONTAINER_STATE=$(echo "$CONTAINER" | awk -F"|" '{print $3}')
      CONTAINER_PORT=$(docker port $CONTAINER_NAME)
      SYM="├ ︎︎→ "
      if [ "$CONTAINER" = "$LAST_CONTAINER" ]; then SYM="└ → "; fi
      case "$CONTAINER_STATE" in
        *Up*) 
          echo "$SYM $CONTAINER_NAME | color=green bash=$(which docker) param1=stop param2=$CONTAINER_ID terminal=false refresh=true"
          if [ -n "$CONTAINER_PORT" ]; then
            echo "${CONTAINER_PORT}" | while read -r port; do
              echo "­­└ →  $port" 
            done
          fi
          ;;
        *Exited*) echo "$SYM $CONTAINER_NAME | color=red bash=$(which docker) param1=start param2=$CONTAINER_ID terminal=false refresh=true";;
      esac
    done
  fi
}


DOCKER_NETWORKS="$(docker ps -a --format "{{.Networks}}" | tr -s ',' '\n' | awk '!a[$0]++')" # get all networks of running containers

if [ -n "$DOCKER_NETWORKS" ]; then
  echo "${DOCKER_NETWORKS}" | while read -r network; do
    CONTAINERS="$(docker ps -a --filter "network=$network")"
    NETWORK_NAME=$(docker network inspect $network --format "{{.Name}}" 2>/dev/null) # if there is containers with unexisting network, we don't wan't to display them

    if [[ $? == 0 ]]; then # if we retrieve a network name
      echo " ◉ $NETWORK_NAME"
      if [ -n "$CONTAINERS" ]; then
        containers
      else
        echo "No running containers"
      fi
    fi
    echo "---"
  done
fi



