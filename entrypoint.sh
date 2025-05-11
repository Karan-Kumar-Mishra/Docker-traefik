#!/bin/bash

# Set the username and password from environment variables
# Default values if not provided
USERNAME=${SSH_USER:-sshuser}
PASSWORD=${SSH_PASSWORD:-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)}

# Create or modify the user
if id "$USERNAME" &>/dev/null; then
    # User exists, just change the password
    echo "$USERNAME:$PASSWORD" | chpasswd
else
    # Create new user
    useradd -m "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Start SSH service
service ssh start

# Start WebSSH
/opt/webssh/bin/wssh --address=0.0.0.0 --port=8888 --xsrf=False