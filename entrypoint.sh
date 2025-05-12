#!/bin/bash
set -e

# Set credentials
USERNAME=${SSH_USERNAME:-admin}
PASSWORD=${SSH_PASSWORD:-password}

# Ensure user exists and set password
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME exists, updating password..."
    echo "$USERNAME:$PASSWORD" | chpasswd
else
    echo "Creating user $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo "$USERNAME"
fi

# Configure SSH
echo "Configuring SSH..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config

# Start SSH service
echo "Starting SSH server..."
service ssh restart

# Verify SSH is running
echo "SSH status:"
service ssh status

# Get container network info (using ifconfig instead of ip)
echo "Network info:"
ifconfig || echo "ifconfig not available"
netstat -tulnp || echo "netstat not available"

# Start WebSSH
echo "Starting WebSSH..."
exec /opt/webssh/bin/wssh \
    --address=0.0.0.0 \
    --port=8888 \
    --wpintvl=0 \
    --fbidhttp=False