# Use OpenSUSE Leap 15.4 as base
FROM opensuse/leap:15.4

# Install vim, sudo, and other necessary tools and libraries for drake
RUN zypper --non-interactive update && \
    zypper --non-interactive install -y vim sudo git cmake make java-1_8_0-openjdk-devel \
    glib2-devel lapack-devel libX11-devel ocl-icd-devel opencl-headers patch patchelf \
    pkg-config python3-devel python3-pygame zlib-devel pkg-config eigen3-devel \
    libmumps5 mumps-devel gcc-fortran nasm wget unzip tar gzip openmpi-devel
    # spdlog-devel   spdlog-devel install spdlog-devel and fmt-devel
    # llvm-clang llvm-clang-devel not installed as there are too old

# Add the repository for GCC 10
RUN zypper addrepo -f http://download.opensuse.org/repositories/devel:/gcc/openSUSE_Leap_15.4/ devel_gcc && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install -y gcc10 gcc10-c++

# Set GCC 10 as the default compiler
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30 && \
    update-alternatives --set cc /usr/bin/gcc && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30 && \
    update-alternatives --set c++ /usr/bin/g++

# Download and build fmt
RUN wget https://github.com/fmtlib/fmt/releases/download/8.0.1/fmt-8.0.1.zip && \
    unzip fmt-8.0.1.zip && \
    cd fmt-8.0.1 && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    sudo make install

# Download and build spdlog
RUN wget https://github.com/gabime/spdlog/archive/v1.6.0.tar.gz && \
    tar xzf v1.6.0.tar.gz && \
    cd spdlog-1.6.0 && \
    mkdir build && cd build && \
    cmake .. -DSPDLOG_BUILD_SHARED=ON -DCMAKE_CXX_FLAGS="-fPIC" -DSPDLOG_FMT_EXTERNAL=ON && \
    make && \
    sudo make install

# Install Bazelisk
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.7.5/bazelisk-linux-amd64 > /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk && \
    ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

# Download and place jchart2d-3.3.2.jar in /usr/share/java/jchart2d.jar
RUN wget https://repo1.maven.org/maven2/net/sf/jchart2d/jchart2d/3.3.2/jchart2d-3.3.2.jar -O /usr/share/java/jchart2d.jar

# Create .pc files for LAPACK and BLAS
RUN echo -e "prefix=/usr\nexec_prefix=\${prefix}\nlibdir=\${exec_prefix}/lib64\nincludedir=\${prefix}/include\n\nName: LAPACK\nDescription: Linear Algebra Package\nVersion: 3.9.0\nLibs: -L\${libdir} -llapack\nCflags: -I\${includedir}" > /usr/share/pkgconfig/lapack.pc && \
    echo -e "prefix=/usr\nexec_prefix=\${prefix}\nlibdir=\${exec_prefix}/lib64\nincludedir=\${prefix}/include\n\nName: BLAS\nDescription: Basic Linear Algebra Subprograms\nVersion: 3.9.0\nLibs: -L\${libdir} -lblas\nCflags: -I\${includedir}" > /usr/share/pkgconfig/blas.pc

# Set up the environment for user 'dan'
RUN groupadd -r dan && \
    useradd -m -s /bin/bash -r -g dan dan && \
    mkdir -p /home/dan/drake && \
    chown -R dan:dan /home/dan/drake && \
    echo "dan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER dan
ENV HOME /home/dan
WORKDIR $HOME

# Install dependencies for pyenv and Python build
RUN sudo zypper --non-interactive install -y git gcc make zlib-devel libbz2-devel libopenssl-devel readline-devel \
    sqlite3-devel python3-clang15 clang15-devel

# Install pyenv and Python 3.10
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc && \
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init --path)"\nfi' >> $HOME/.bashrc && \
    /bin/bash -c "source $HOME/.bashrc && pyenv install 3.10.0 && pyenv global 3.10.0"

# Ensure the selected Python version 3.10 is used and install PyYAML
RUN /bin/bash -c "source $HOME/.bashrc && pyenv rehash && pip install PyYAML"

# Set environment variables for GCC to ensure Bazel uses the correct version
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/g++-10
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/lib/llvm-14/lib:$LD_LIBRARY_PATH
ENV CMAKE_PREFIX_PATH=/usr/local/lib/cmake:${CMAKE_PREFIX_PATH}
