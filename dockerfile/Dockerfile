FROM ruby:2.5.1-stretch

RUN apt-get update -y && sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common
RUN curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update -y && apt-get install -y docker-ce

RUN cd / && git clone https://github.com/inutano/cwl-log-generator
ENTRYPOINT ["/cwl-log-generator/generate_cwl_log"]
