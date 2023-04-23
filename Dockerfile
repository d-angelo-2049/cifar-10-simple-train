FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04

# set timezone to Asia/Tokyo
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install Anaconda
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh && \
    sh Anaconda3-2021.05-Linux-x86_64.sh -b -p /opt/conda && \
    rm Anaconda3-2021.05-Linux-x86_64.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" >> ~/.bashrc

# Activate conda in non-interactive shell
RUN /opt/conda/bin/conda init bash

# create a new conda environment and activate it
COPY ./tensorflow_env.yaml /tmp/tensorflow_env.yaml
RUN /opt/conda/bin/conda env create -f /tmp/tensorflow_env.yaml
ENV PATH /opt/conda/envs/tensorflow_env/bin:$PATH
RUN echo "conda activate tensorflow_env" >> ~/.bashrc

# clean packages
#COPY ./requirements.txt /tmp/requirements.txt
RUN /opt/conda/bin/conda clean --all --yes
#/opt/conda/bin/conda install --yes --file /tmp/requirements.txt && \

# enable SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "export VISIBLE=now" >> /etc/profile

# expose port 22 for SSH, port 8888 for JupytorLab
EXPOSE 22 8888

# set the working directory to /src
WORKDIR /cifar-10-simple-train

# mount the current directory on the host to /src in the container
COPY . /cifar-10-simple-train
#RUN /bin/bash -c "cd src"
SHELL ["/bin/bash", "-c", "source ~/.bashrc && conda activate tensorflow_env"]
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
