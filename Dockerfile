# Based heavily on evarga/jenkins-slave
FROM centos:7

# Make sure the package repository is up to date.
RUN yum -y update

# Install the EPEL repo
RUN yum -y install epel-release

# Install a basic SSH server
RUN yum install -y openssh-server
# Ubuntu specific
# RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
# For CentOS this translates to this. Thank you https://gist.github.com/gasi/5691565
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key

RUN mkdir -p /var/run/sshd

# Install JDK 7 (latest edition)
RUN yum install -y java-1.7.0-openjdk

# Add user jenkins to the image
RUN adduser jenkins
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN echo '%jenkins        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

# Install basic tools for the slave
RUN yum install -y sudo git lsof ifconfig openldap-clients ansible
# This is the equivalent of Ubuntu's build-essential
RUN yum install -y gcc gcc-c++ make openssl-devel kernel-devel
RUN yum install -y bzip2

# Standard SSH port
EXPOSE 22

# Installing ChefDK
RUN curl -L https://www.opscode.com/chef/install.sh | bash -s -- -P chefdk

ENV PATH /opt/chefdk/embedded/bin:$PATH
ENV LANG=en_US.iso88591
ENV LC_CTYPE=en_US.iso88591

RUN gem install kitchen-softlayer

CMD ["/usr/sbin/sshd", "-D", "-e"]