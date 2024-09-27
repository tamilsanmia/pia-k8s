# Use the official Ubuntu base image
FROM ubuntu:jammy

# Set environment variables
ENV TZ=Asia/Kolkata \
    DEBIAN_FRONTEND=noninteractive

# Update the package list and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    sudo \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a 'faveo' user and group
RUN groupadd -r faveo && \
    useradd -r -m -s /bin/bash -g faveo faveo
RUN usermod -a -G sudo faveo

# Configure sudo to not require a password for 'faveo'
RUN echo "faveo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/faveo

# Set the default command to bash
CMD ["/bin/bash"]
