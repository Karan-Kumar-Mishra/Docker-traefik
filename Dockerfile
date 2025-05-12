FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        openssh-server \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment and install webssh
RUN python3 -m venv /opt/webssh && \
    /opt/webssh/bin/pip install --upgrade pip && \
    /opt/webssh/bin/pip install webssh

# Environment variables with defaults
ENV SSH_USERNAME=admin
ENV SSH_PASSWORD=password
ENV ALLOW_SSH_PASSWORD_AUTH=true

# Create user without setting password yet (will be done in entrypoint)
RUN useradd -m $SSH_USERNAME && \
    mkdir -p /home/$SSH_USERNAME/.ssh && \
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME && \
    chmod 700 /home/$SSH_USERNAME/.ssh

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers $SSH_USERNAME" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

EXPOSE 22 8888

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]