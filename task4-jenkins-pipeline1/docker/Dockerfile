FROM centos:7

RUN yum update -y && yum install -y epel-release && \
yum install -y git curl dpkg java java-devel unzip which && \
# curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
yum install -y git-lfs && \
yum install -y nginx && \
yum clean all
ENV JAVA_HOME /etc/alternatives/jre_openjdk

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV REF $REF
# setup nginx for always run on start container
COPY ./nginx/nginx.comf /etc/nginx/nginx.conf
RUN systemctl enable nginx

# install docker
RUN curl -fsSL https://get.docker.com/ | sh
RUN systemctl enable docker

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
  && usermod -aG docker jenkins
RUN mkdir -p $JAVA_HOME/.ssh
# COPY ./ssh/id

# config git user
RUN git config --global user.name "Volodymyr Kozulenko" && git config --global user.email fenixra73@gmail.com


# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.99}
#ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# jenkins.war checksum, download will be validated using it
#ARG JENKINS_SHA=5bb075b81a3929ceada4e960049e37df5f15a1e3cfc9dc24d749858e70b48919

# Can be used to customize where jenkins.war get downloaded from
#ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_URL=http://updates.jenkins-ci.org/download/war/2.204.2/jenkins.war
# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war 
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# for main web interface:
EXPOSE ${http_port}


ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}
ARG pass=3fd7979c3bf34984b1bfb69f0d6467fc
ENV pass $pass

COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# ADD  https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/cli/2.99/cli-2.99.jar /usr/share/jenkins/jenkins-cli.jar
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# RUN echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("user1", "password123")'| \java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost/ groovy =

# copy groovy scripd for create user and  disable initial setup
COPY basic-security.groovy $JENKINS_HOME/init.groovy.d/basic-security.groovy

# COPY jenkins.sh /usr/local/bin/jenkins.sh
# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]  
