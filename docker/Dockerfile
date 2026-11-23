# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG SBT_VERSION=1.11.5
ARG SEMESTER=B261

# openssh-client is needed to clone over git@
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
      openjdk-17-jdk-headless git openssh-client curl ca-certificates cloc

RUN curl -fsSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
      | tar -xz -C /opt
ENV PATH="/opt/sbt/bin:${PATH}"

# Copy in plugins
RUN mkdir -p /root/.sbt/1.0/plugins
COPY ./plugins.sbt /root/.sbt/1.0/plugins/plugins.sbt

# Copy in SSH keys FIT GitLab
# (regenerate with `ssh-keyscan gitlab.fit.cvut.cz > known_hosts` if needed)
RUN mkdir -p /root/.ssh
COPY ./known_hosts /root/.ssh/known_hosts

# Pre-fetch the template's sbt and try to compile (warms up cache). Requires `docker build --ssh default`.
RUN --mount=type=ssh \
    git clone "git@gitlab.fit.cvut.cz:BI-OOP/${SEMESTER}/semestral-project-template.git" /tmp/warmup \
 && cd /tmp/warmup && sbt --batch coverage Test/compile

# Copy in runner
RUN mkdir -p /opt
COPY ./run.sh /opt/run.sh

# Clean
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run runner
CMD [ "/opt/run.sh" ]
