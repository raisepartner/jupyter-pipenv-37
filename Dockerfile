ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Vincent Pfister <vincent.pfister@raisepartner.com>"

USER root

RUN apt-get update && apt-get install -yq --no-install-recommends \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN conda install --quiet --yes \
    'conda-forge::blas=*=openblas' \
    'cython=0.29*' \
    'ipywidgets=7.5*' \
    'matplotlib-base=3.1.*' \
    'numpy=1.17*' \
    'pandas=0.25*' \
    'patsy=0.5*' \
    'statsmodels=0.10*' \
    'sympy=1.4*' \
    'xlrd' \
    'pipenv' \
    && pip install --upgrade jupyterlab-git \
    && \
    conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^1.0.1 --no-build && \
    jupyter lab build && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# RUN conda install --quiet --yes numpy pandas matplotlib pipenv \
#   && pip install --upgrade jupyterlab-git \
#   && jupyter lab build
