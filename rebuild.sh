#!/usr/bin/env bash
#
#  written by maximilian-huber.de

if [ "$EUID" -eq 0 ]; then
    echo "you should run this script as user"
    exit 1
fi

cd "$(dirname $0)"
SRC="$(pwd)"

TMUX_NAME="rebuild_sh"
logfile="_logs/$(date +%Y-%m-%d)-rebuild.sh.log"

# wrap into tmux ##########################################################
if test -z $TMUX && [[ $TERM != "screen" ]]; then
    echo "wrap into tmux ..."
    tmux has-session -t $TMUX_NAME 2>/dev/null
    [[ "$?" -eq 0 ]] && {
        echo "already running somewhere"
        exit 1
    }
    tmux -2 new-session -s $TMUX_NAME \
         "command echo \"... wrapped into tmux\"; $0 $@; $SHELL" \; \
         set-option status-left "rebuild.sh "\; \
         set-option status-right "..."\; \
         set set-titles-string "${TMUX_NAME}@tmux" \
        && exit 0
    echo "tmux failed to start, running without tmux"
fi

# prepare logging #########################################################
mkdir -p _logs

echo -e "\n\n\n\n\n\n\n" >> $logfile
exec &> >(tee -a $logfile)

set -e

# check, if connected #####################################################
if ! ping -c1 cloud.github.com > /dev/null 2>&1; then
  echo "**** not connected (ping) ****"
  # check again ###########################################################
  if ! wget -O - cloud.github.com > /dev/null 2>&1; then
    echo "**** not connected (wget) ****"
    exit 1
  fi
fi

# update git directory if clean ###########################################
echo "* update config ..."
if git diff-index --quiet HEAD --; then
    git fetch
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")
    if [ $LOCAL = $REMOTE ]; then
        echo "... up-to-date"
    elif [ $LOCAL = $BASE ]; then
        echo "* pull ..."
        git pull --rebase
        # run updatet version of script ###################################
        exec $0
    elif [ $REMOTE = $BASE ]; then
        echo "... need to push"
    else
        echo "... diverged"
    fi
else
    echo "... git directory is unclean, it will not be updated"
fi

# run hooks ###############################################################
shopt -s nullglob
for f in $SRC/_hooks/*; do
    [ -x $f ] && $f
done
