FROM sbtscala/scala-sbt:eclipse-temurin-17.0.15_6_1.11.5_3.7.2

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq cloc

# Clean
RUN apt-get clean
RUN rm -rf /var/cache/apt/lists/*
RUN rm -rf /tmp/* /var/tmp/*

# Copy in runner
RUN mkdir -p /opt
COPY ./run.sh /opt/run.sh

# Copy in plugins
RUN mkdir -p /root/.sbt/1.0/plugins
COPY ./plugins.sbt /root/.sbt/1.0/plugins/plugins.sbt

# Copy in SSH keys FIT GitLab
# (regenerate with `ssh-keyscan gitlab.fit.cvut.cz > known_hosts` if needed)
RUN mkdir -p /root/.ssh
COPY ./known_hosts /root/.ssh/known_hosts

# Run runner
CMD [ "/opt/run.sh" ]
