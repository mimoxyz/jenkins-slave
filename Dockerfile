# Based on evarga/jenkins-slave
FROM centos:7

RUN yum -y update
RUN yum -y install epel-release

# Install a basic SSH server
RUN yum install -y openssh-server \
		java-1.7.0-openjdk \
		sudo git lsof ifconfig openldap-clients ansible \
		 gcc gcc-c++ make openssl-devel kernel-devel \
		 bzip2 \
		 unzip

RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key

RUN mkdir -p /var/run/sshd


RUN adduser jenkins
RUN echo "jenkins:jenkins" | chpasswd
RUN echo '%jenkins        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

EXPOSE 22

# Installing ChefDK
RUN curl -L https://www.opscode.com/chef/install.sh | bash -s -- -P chefdk
ADD packer.zip /var/tmp
RUN unzip /var/tmp/packer.zip -d /usr/local/src/ && rm -f /var/tmp/packer.zip
RUN chmod 755 -R /usr/local/src/packer/

USER jenkins

ENV PATH /opt/chefdk/embedded/bin:/usr/local/src/packer:$PATH
ENV LANG=en_US.iso88591 
ENV LC_CTYPE=en_US.iso88591
RUN gem install kitchen-softlayer kitchen-ec2

USER root
CMD ["/usr/sbin/sshd", "-D", "-e"]