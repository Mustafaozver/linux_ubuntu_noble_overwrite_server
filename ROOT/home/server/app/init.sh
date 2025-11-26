# System Start

tmux new-session -d -s tunnel0
tmux new-session -d -s app0

tmux pipe-pane -t tunnel0 -o 'cat >> /home/server/app/tunnel0.log'
tmux pipe-pane -t app0 -o 'cat >> /home/server/app/app0.log'

tmux send-keys -t app0 "node '/home/server/app/app.js'" C-m
tmux send-keys -t tunnel0 "sh '/home/server/app/start_web_tunnel.sh'" C-m

## tmux attach -t tunnel0
## ctrl + b -> d => çıkış
