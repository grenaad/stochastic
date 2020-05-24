# r-notebook is based on the minimal-notebook https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
# repo for r-notebook: https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
# Ubuntu 18.04 (bionic)
FROM jupyter/r-notebook:latest

WORKDIR ${HOME}

####### Install .NET Core SDK #######
# https://github.com/dotnet/dotnet-docker/blob/master/5.0/sdk/focal/amd64/Dockerfile
# Have to use sdk version 3.1.200 for now, the .NET kernel only works with it,
# otherwise cmd "dotnet interactive jupyter install", will fail

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # DOTNET_SDK_VERSION=5.0.100-preview.4.20258.7 \
    DOTNET_SDK_VERSION=3.1.200 \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_ROOT=$HOME/dotnet

RUN curl -SL --output dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
RUN mkdir -p $HOME/dotnet \
    && tar zxf dotnet.tar.gz -C $DOTNET_ROOT \
    && rm dotnet.tar.gz

USER root
RUN sudo ln -s $DOTNET_ROOT/dotnet /usr/bin/dotnet
USER $NB_UID

# Fsharp samples
# RUN git clone https://github.com/dotnet/interactive
# # Copy notebooks
# RUN cp -r interactive/NotebookExamples/ ${HOME}/Notebooks/
# # Copy package sources
# RUN cp -r interactive/NuGet.config ${HOME}/nuget.config

####### END Install .NET Core SDK #######

# path is used by .Net Interactive
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

# Install .NET Interactive
# RUN dotnet tool install --global Microsoft.dotnet-interactive
# Install lastest build from master branch of Microsoft.DotNet.Interactive from myget
RUN dotnet tool install --tool-path $DOTNET_ROOT/dotnet-interactive Microsoft.dotnet-interactive --version 1.0.127302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
RUN dotnet tool install --tool-path $DOTNET_ROOT/dotnet-try dotnet-try --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

USER root
RUN ln -s $DOTNET_ROOT/dotnet-interactive/dotnet-interactive /usr/bin/dotnet-interactive
RUN ln -s $DOTNET_ROOT/dotnet-try/dotnet-try /usr/bin/dotnet-try
USER $NB_UID

# Install the .NET kernel
RUN dotnet interactive jupyter install

# Set root to Notebooks
WORKDIR ${HOME}/Notebooks/

# Install R Statistics packages
RUN R -e "install.packages(c('dplyr','ggplot2'), repos = 'http://cran.us.r-project.org')"

# There is no env variable to switch of the token, have use start.sh
ENTRYPOINT ["start.sh", "jupyter", "lab", "--LabApp.token=''", "--ip='*'", "--allow-root", "--LabApp.password=''"]
