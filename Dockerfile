FROM continuumio/miniconda3:latest

LABEL authors="Angelos Tzotsos,Markus Neteler"
LABEL maintainer="neteler@mundialis.de"

# Latest ARCSI release: https://github.com/remotesensinginfo/arcsi/releases

# update conda and install arcsi using conda package manager and clean up (rm tar packages to save space)
RUN conda update --yes -n base conda
RUN conda config --add channels conda-forge && \
conda update --yes conda && \
conda install --yes -c conda-forge arcsi && \
conda clean --yes -t

# add debian packages required by arcsi
RUN apt-get update && apt-get install -y libcgal13

# set gdal paths
ENV GDAL_DRIVER_PATH /opt/conda/lib/gdalplugins:$GDAL_DRIVER_PATH
ENV GDAL_DATA /opt/conda/share/gdal
ENV PROJ_LIB=/opt/conda/share/proj
