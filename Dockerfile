# Use OpenSUSE Leap 15.4 as base
FROM opensuse/leap:15.4

# Install necessary tools and libraries in non-interactive mode
RUN zypper --non-interactive update && zypper --non-interactive install -y \
    gcc gcc-c++ git cmake make \
    java-1_8_0-openjdk-devel \
    # For packages that could not be found, verify their availability or look for alternatives
    # libclang-devel might need an alternative approach or additional repositories
    glib2-devel \
    # libGL-devel, libGLX-devel, and libOpenGL-devel might be covered by Mesa libraries or need alternative solutions
    lapack-devel \
    # mumps-seq-devel might require adding a repository or installing from source
    libX11-devel \
    ocl-icd-devel opencl-headers patch patchelf pkg-config python3-devel \
    python3-pygame zlib-devel \
    && zypper clean -a

