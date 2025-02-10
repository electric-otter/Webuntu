FROM ubuntu:24.04

# Install necessary dependencies for the desktop environment and VNC server
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    ubuntu-desktop \
    x11vnc \
    fluxbox \
    sudo \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create a new user (customize this as needed)
RUN useradd -m -s /bin/bash user && echo "user:user" | chpasswd && adduser user sudo

# Expose the VNC port (defaults to 5900, can be overridden)
ARG VNC_PORT=5900
EXPOSE ${VNC_PORT}

# Configure environment variables
ENV VNC_PORT=${VNC_PORT}

# Create VNC server startup script with user configuration
RUN echo '#!/bin/bash\n\
    echo "Starting VNC server on port ${VNC_PORT}"\n\
    x11vnc -forever -usepw -create -rfbport ${VNC_PORT} -display :0 & fluxbox' > /usr/local/bin/start-vnc.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-vnc.sh

# Set the command to run the VNC server and fluxbox when the container starts
CMD ["/usr/local/bin/start-vnc.sh"]
