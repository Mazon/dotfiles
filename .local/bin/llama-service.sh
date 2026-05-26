#!/bin/bash
# llama-service.sh — manage llama-server as a system service
# Usage: llama-service.sh {start|stop|restart|status|logs|enable|disable|setup}

set -euo pipefail

cmd="${1:-help}"

case "$cmd" in
  start)
    sudo systemctl start llama-server.service
    echo "llama-server started."
    ;;
  stop)
    sudo systemctl stop llama-server.service
    echo "llama-server stopped."
    ;;
  restart)
    sudo systemctl restart llama-server.service
    echo "llama-server restarted."
    ;;
  status)
    sudo systemctl status llama-server.service --no-pager
    ;;
  logs)
    sudo journalctl -u llama-server.service -f --no-pager "${@:2}"
    ;;
  enable)
    sudo systemctl enable llama-server.service
    echo "llama-server enabled (starts on boot)."
    ;;
  disable)
    sudo systemctl disable llama-server.service
    echo "llama-server disabled."
    ;;
  reload)
    sudo systemctl daemon-reload
    echo "systemd config reloaded."
    ;;
  setup)
    echo "Installing system service (requires sudo)..."
    sudo cp /home/mazon/llama-server.service /etc/systemd/system/llama-server.service
    sudo systemctl daemon-reload
    echo "Done. Run '$0 enable' to start on boot, or '$0 start' to run now."
    ;;
  *)
    echo "Usage: $0 {setup|start|stop|restart|status|logs|enable|disable|reload}"
    echo ""
    echo "  setup    Install the service file (one-time, requires sudo)"
    echo "  start    Start the llama-server service"
    echo "  stop     Stop the llama-server service"
    echo "  restart  Restart the llama-server service"
    echo "  status   Show service status"
    echo "  logs     Follow live logs (pass -n 100 etc.)"
    echo "  enable   Start automatically on boot"
    echo "  disable  Stop auto-starting"
    echo "  reload   Reload systemd config (after editing the service file)"
    exit 1
    ;;
esac
