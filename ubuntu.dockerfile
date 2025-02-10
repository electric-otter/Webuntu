FROM ubuntu:24.04

# Install necessary dependencies for the desktop environment
RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y \
    ubuntu-desktop \
    x11vnc \
    fluxbox \
    sudo \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Expose default VNC port, but this can be changed via ENV
ARG VNC_PORT=5900
EXPOSE ${VNC_PORT}

# Create a script to handle user creation and configuration
RUN echo '#!/bin/bash\n\
    echo "Enter the username:"\n\
    read USERNAME\n\
    useradd -m -s /bin/bash $USERNAME\n\
    echo "Enter password for $USERNAME:"\n\
    passwd $USERNAME\n\
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers\n\
    mkdir -p /home/$USERNAME/.vnc\n\
    x11vnc -storepasswd 0 /home/$USERNAME/.vnc/passwd\n\
    chown -R $USERNAME:$USERNAME /home/$USERNAME' > /usr/local/bin/setup-user.sh

# Make the script executable
RUN chmod +x /usr/local/bin/setup-user.sh

# Set up VNC server for root initially
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd 0 /root/.vnc/passwd

# Set up the Supervisor to manage VNC and Fluxbox
RUN echo "[supervisord]\nnodaemon=true\n\n[program:vnc]\ncommand=x11vnc -forever -usepw -create -display :0 -rfbport ${VNC_PORT}\n\n[program:fluxbox]\ncommand=fluxbox" > /etc/supervisor/conf.d/desktop.conf

# Set entrypoint to run the user setup script and Supervisor
ENTRYPOINT ["/bin/bash", "/usr/local/bin/setup-user.sh", "&&", "supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Serve index.html using Nginx for the GUI
COPY index.html /usr/share/nginx/html/index.html

# Start Nginx and keep the container running
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
