# Use OpenSUSE Leap 15.4 as base
FROM opensuse/leap:15.4

# Install vim, sudo, and other necessary tools and libraries for drake
RUN zypper --non-interactive update && \
    zypper --non-interactive install -y vim sudo git cmake make java-1_8_0-openjdk-devel \
    glib2-devel lapack-devel libX11-devel ocl-icd-devel opencl-headers patch patchelf \
    pkg-config python3-devel python3-pygame zlib-devel pkg-config libfmt8 eigen3-devel \
    libmumps5 mumps-devel gcc-fortran nasm 

# Add the repository for newer GCC versions, install GCC 9, and set it as default
RUN zypper addrepo -f http://download.opensuse.org/repositories/devel:/gcc/openSUSE_Leap_15.3/ devel_gcc && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install -y gcc9 gcc9-c++ && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9

# Clone, build, and install fmt and spdlog from source
RUN cd /tmp && \
    git clone https://github.com/fmtlib/fmt.git && \
    cd fmt && mkdir build && cd build && cmake .. && make install && \
    cd /tmp && \
    git clone https://github.com/gabime/spdlog.git && \
    cd spdlog && mkdir build && cd build && cmake .. && make install

# Install Bazelisk
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.7.5/bazelisk-linux-amd64 > /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk && \
    ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

# Create .pc files for LAPACK and BLAS
RUN echo -e "prefix=/usr\nexec_prefix=\${prefix}\nlibdir=\${exec_prefix}/lib64\nincludedir=\${prefix}/include\n\nName: LAPACK\nDescription: Linear Algebra Package\nVersion: 3.9.0\nLibs: -L\${libdir} -llapack\nCflags: -I\${includedir}" > /usr/share/pkgconfig/lapack.pc && \
    echo -e "prefix=/usr\nexec_prefix=\${prefix}\nlibdir=\${exec_prefix}/lib64\nincludedir=\${prefix}/include\n\nName: BLAS\nDescription: Basic Linear Algebra Subprograms\nVersion: 3.9.0\nLibs: -L\${libdir} -lblas\nCflags: -I\${includedir}" > /usr/share/pkgconfig/blas.pc

# Set up the environment for user 'dan'
RUN groupadd -r dan && \
    useradd -m -s /bin/bash -r -g dan dan && \
    mkdir -p /home/dan/drake && \
    chown -R dan:dan /home/dan/drake && \
    echo "dan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to user 'dan' before installing pyenv and Python
USER dan
ENV HOME /home/dan
WORKDIR $HOME

# Install dependencies for pyenv and Python build
RUN sudo zypper --non-interactive install -y git gcc make zlib-devel libbz2-devel libopenssl-devel readline-devel sqlite3-devel tar gzip


# Install pyenv and Python 3.10
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc && \
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init --path)"\nfi' >> $HOME/.bashrc && \
    /bin/bash -c "source $HOME/.bashrc && pyenv install 3.10.0 && pyenv global 3.10.0"

# Set environment variables for GCC to ensure Bazel uses the correct version
ENV CC=/usr/bin/gcc-9
ENV CXX=/usr/bin/g++-9
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

