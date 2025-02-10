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

# Expose the VNC port (defaults to 5900, can be overridden)
ARG VNC_PORT=5900
EXPOSE ${VNC_PORT}

# Configure environment variables
ENV VNC_PORT=${VNC_PORT}

# Create VNC server startup script
RUN echo '#!/bin/bash\n\
    echo "Starting VNC server on port ${VNC_PORT}"\n\
    x11vnc -forever -usepw -create -rfbport ${VNC_PORT} & fluxbox' > /usr/local/bin/start-vnc.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-vnc.sh

# Set the command to run the VNC server and fluxbox when the container starts
CMD ["/usr/local/bin/start-vnc.sh"]
