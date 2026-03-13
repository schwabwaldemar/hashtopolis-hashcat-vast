#!/bin/bash
set -e

# If arguments are provided, execute them directly (allows custom commands like "bash")
if [ $# -gt 0 ] && [ "$1" != "--auto-start" ]; then
    exec "$@"
fi

# Auto-start mode: Check for required environment variables
if [ -z "$HASHTOPOLIS_URL" ] || [ -z "$HASHTOPOLIS_VOUCHER" ]; then
    echo "ERROR: Missing required environment variables"
    echo ""
    echo "To run the Hashtopolis agent automatically, you must set:"
    echo "  HASHTOPOLIS_URL    - The URL of your Hashtopolis server"
    echo "  HASHTOPOLIS_VOUCHER - Your voucher code for agent registration"
    echo ""
    echo "Example:"
    echo "  docker run -e HASHTOPOLIS_URL='https://your-server.com' \\"
    echo "             -e HASHTOPOLIS_VOUCHER='your-voucher-code' \\"
    echo "             ghcr.io/kruton/hashtopolis-hashcat-vast:latest"
    echo ""
    echo "Alternatively, you can run with a custom command:"
    echo "  docker run -it ghcr.io/kruton/hashtopolis-hashcat-vast:latest bash"
    echo ""
    echo "For vast.ai, use this in your onstart script:"
    echo "  cd htpclient"
    echo "  python3 hashtopolis.zip --url {server} --voucher {voucher_id}"
    exit 1
fi

# Start the Hashtopolis agent with the provided environment variables
echo "Starting Hashtopolis agent..."
echo "Server: $HASHTOPOLIS_URL"
echo "Voucher: $HASHTOPOLIS_VOUCHER"
echo ""

exec python3 hashtopolis.zip --url "$HASHTOPOLIS_URL" --voucher "$HASHTOPOLIS_VOUCHER"