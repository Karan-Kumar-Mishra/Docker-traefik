#!/bin/bash
set -e

# Set the username and password from environment variables
USERNAME=${SSH_USERNAME:-admin}
PASSWORD=${SSH_PASSWORD:-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)}

# Create or modify the user
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME exists, updating password..."
    echo "$USERNAME:$PASSWORD" | chpasswd
else
    echo "Creating user $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Output credentials for debugging
echo "SSH Credentials: $USERNAME:$PASSWORD"

# Configure SSH password authentication
if [ "$ALLOW_SSH_PASSWORD_AUTH" = "true" ]; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config
else
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi

# Ensure proper permissions
mkdir -p /home/$USERNAME/.ssh
chown -R $USERNAME:$USERNAME /home/$USERNAME
chmod 700 /home/$USERNAME/.ssh

# Start SSH service
echo "Starting SSH server..."
service ssh restart

# Start WebSSH
echo "Starting WebSSH..."
exec /opt/webssh/bin/wssh \
    --address=0.0.0.0 \
    --port=8888 \
    --wpintvl=0 \
    --fbidhttp=False