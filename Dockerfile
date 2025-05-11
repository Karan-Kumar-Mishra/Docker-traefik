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

# Create user and set password properly
RUN useradd -m $SSH_USERNAME && \
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd && \
    mkdir -p /home/$SSH_USERNAME/.ssh && \
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME && \
    chmod 700 /home/$SSH_USERNAME/.ssh

# Configure SSH properly
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "AllowUsers $SSH_USERNAME" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

EXPOSE 22 8888

# Entrypoint script
CMD (service ssh start || /usr/sbin/sshd -D) & \
    /opt/webssh/bin/wssh --address=0.0.0.0 --port=8888 --fbidhttp=False --xsrf=False --wpintvl=0