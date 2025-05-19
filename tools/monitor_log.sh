#!/bin/bash

if ! command -v tmux &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y tmux
fi

tmux new-session -d -s ob_logs

tmux split-window -v -t ob_logs
tmux split-window -h -t ob_logs:0.1

tmux send-keys -t ob_logs:0.0 "sudo tail -f /var/log/postgresql/postgresql-*.log" C-m
tmux send-keys -t ob_logs:0.1 "sudo tail -f /var/lib/tomcat/logs/catalina.out" C-m
tmux send-keys -t ob_logs:0.2 "sudo tail -f /var/lib/tomcat/logs/openbravo.log" C-m

tmux select-pane -t ob_logs:0.0 -U 10
tmux select-pane -t ob_logs:0.1 -L 10

tmux attach-session -t ob_logs