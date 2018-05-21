FROM ubuntu:latest

RUN apt-get update  && apt-get -y upgrade \
  && apt-get install -y python python-dev python-yaml curl \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/* \
  && mkdir /cwl
ADD get_exe_env.py /cwl/
ADD cwl_log_generator.py /cwl/
WORKDIR /cwl
ENTRYPOINT ["python"]
