# Use the mimimun requirement
FROM gitpod/workspace-node-lts:latest

USER root

# Install JAVA runtime for Sonarlint to work properly
RUN install-packages openjdk-11-jre
