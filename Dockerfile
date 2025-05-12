FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        openssh-server \
        wget \
        sudo \
        iproute2 \ 
        net-tools \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Rest of your Dockerfile remains the same...

# Create virtual environment and install webssh
RUN python3 -m venv /opt/webssh && \
    /opt/webssh/bin/pip install --upgrade pip && \
    /opt/webssh/bin/pip install webssh

# Environment variables with defaults
ENV SSH_USERNAME=admin
ENV SSH_PASSWORD=password
ENV ALLOW_SSH_PASSWORD_AUTH=true
ENV CONTAINER_IP=127.0.0.1

# Create user and configure SSH
RUN useradd -m $SSH_USERNAME && \
    mkdir -p /home/$SSH_USERNAME/.ssh && \
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME && \
    chmod 700 /home/$SSH_USERNAME/.ssh && \
    usermod -aG sudo $SSH_USERNAME && \
    echo "$SSH_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure SSH
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers $SSH_USERNAME" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

EXPOSE 22 8888

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]