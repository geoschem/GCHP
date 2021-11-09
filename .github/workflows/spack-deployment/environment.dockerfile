# This dockerfile is used to build the basic spack and conda environment 
# It is only meant to contain environment software that is needed to  
# run the pipeline, but does not need to be built on the fly. 
# Building this image reduces the pipeline time needed to deploy spack. 
# The resulting image is posted on docker for usage by the pipeline
# pushed to laestrada/conda-spack-environment:version

# to build and push to docker:
# $ docker build -f environment.dockerfile -t laestrada/conda-spack-environment:{version} .
# $ docker push laestrada/conda-spack-environment:{version}

FROM continuumio/miniconda3:4.10.3-alpine
# set env variables
ENV SPACK_PYTHON=/opt/conda/envs/spackenv/bin/python
COPY environment.yml ./environment.yml

ENV SPACK_ROOT=/home/spack
ENV FORCE_UNSAFE_CONFIGURE=1
ENV PATH="${PATH}:${SPACK_ROOT}/bin"

# Install basic spack dependencies
RUN apk update && \
    apk add --no-cache git gcc g++ gfortran make bzip2 && \
    apk add --no-cache patch file curl python3 gnupg xz && \
    apk add --no-cache curl bash openssh libtool linux-headers
    
# create conda environment
RUN conda env create -f environment.yml


# Install spack
RUN cd home && \
    git clone https://github.com/laestrada/spack.git
# install the dependencies for spack style.
RUN cd /home/spack && spack style
