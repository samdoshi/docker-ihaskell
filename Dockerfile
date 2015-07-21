FROM samdoshi/haskell-lts:lts-2.18
MAINTAINER Sam Doshi <sam@metal-fish.co.uk>

ENV IPYTHON_VERSION 3.2.1
ENV IHASKELL_SHA ab3fea6da081e8fb868a2fd18e012d0e96b21928

EXPOSE 8888

VOLUME /notebooks

RUN apt-get update -q && \
    apt-get install -qy libtinfo-dev \
                        libzmq3-dev \
                        libcairo2-dev \
                        libpango1.0-dev \
                        libmagic-dev \
                        libblas-dev \
                        liblapack-dev \
                        python-dev \
                        python-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install ipython[all]==$IPYTHON_VERSION && \
    python -c 'from IPython.external import mathjax; mathjax.install_mathjax()'

RUN git clone http://www.github.com/gibiansky/IHaskell /tmp/ihaskell && \
    cd /tmp/ihaskell && \
    git checkout -q $IHASKELL_SHA && \
    stack build --prefetch --dry-run && \
    stack install && \
    stack exec ihaskell -- install && \
    rm -r /root/.stack/indices

CMD cd /tmp/ihaskell && \
    stack exec ipython -- notebook \
        --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --notebook-dir=/notebooks

