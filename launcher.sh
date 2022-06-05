#!/bin/sh

session="litestream-secondary"
window="$session:0"

lines="$(tput lines)"
columns="$(tput cols)"

export STARTDIR="$PWD"

tmux has-session -t $session &> /dev/null

if [ $? != 0 ]
then
  # top left
  tmux -2 new-session -d -x "$columns" -y "$lines" -s "$session" -c "$STARTDIR/primary" -d
  tmux send-keys -t "$window" 'echo "1. sqlite primary"; sqlite3 foo.db "PRAGMA journal_mode = wal"; ../bin/litestream replicate -config litestream.yml' C-m

  # top right
  tmux split-window -t "$window"   -h -p 50 -c "$STARTDIR/secondary"  -d 'sleep 1; echo "step 2"; zsh'
  tmux send-keys -t "$window.{right}" 'sqlite3 foo.db "PRAGMA journal_mode = wal"; UPSTREAM_PATH=$STARTDIR/primary ../bin/litestream replicate -config litestream.yml' C-m

  # bottom left
  tmux split-window -t "$window"  -v -p 50 -c "$STARTDIR/primary"  -d 'echo "step 3"; zsh'
  tmux send-keys -t "$window.{bottom-left}" 'sqlite3 foo.db' C-M

  # bottom right
  tmux split-window -t "$window.{top-right}" -v -p 50 -c "$STARTDIR/secondary"  -d 'echo "4 sqlite secondary";  zsh'
  tmux send-keys -t "$window.{bottom-right}" 'sqlite3 -readonly foo.db' C-M

  # assumes panes start at 0
  # https://gist.github.com/niderhoff/871d953bcf14ab6814255a1ab4b6ab34 and
  # https://unix.stackexchange.com/questions/553463/how-can-i-programmatically-get-this-layout-in-tmux
  # for tmux config setup
fi

tmux select-window -t "$window"

# Attach to session
tmux -2 attach-session -t "$session"