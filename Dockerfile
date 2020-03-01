ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Vincent Pfister <vincent.pfister@raisepartner.com>"

USER root

RUN apt-get update && apt-get upgrade -y && apt-get install -yq --no-install-recommends \
    build-essential \
    vim \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    pandoc \
    python-dev \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-xetex \
    tzdata \
    unzip \
    openssh-client \
    libgfortran3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN conda install --quiet --yes \
    'jupyterlab-git' \
    'pipenv' \
    && \
    # pip install jupyterlab-gitlab && \
    conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^1.1 --no-build && \
    # install jupyterlab-git extension
    jupyter labextension install @jupyterlab/git --no-build && \
    jupyter serverextension enable --py jupyterlab_git && \
    # install jupyterlab gitlab extension
    #jupyter labextension install jupyterlab-gitlab --no-build && \
    #jupyter serverextension enable --sys-prefix jupyterlab_gitlab && \
    # rebuild jupyter lab
    jupyter lab build && \
    # clean
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
