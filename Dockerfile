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
RUN wget https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip -O /var/tmp/packer.zip
RUN unzip /var/tmp/packer.zip -d /usr/local/src/ && rm -f /var/tmp/packer.zip
ADD packer-builder-softlayer /usr/local/src/
RUN chmod 755 -R /usr/local/src/packer/


ENV PATH /opt/chefdk/embedded/bin:/usr/local/src/packer:$PATH
RUN localedef -i en_US -f ISO-8859-1 en_US
ENV LC_CTYPE="en_US.iso88591"

RUN gem install kitchen-softlayer kitchen-ec2

CMD ["/usr/sbin/sshd", "-D", "-e"]