FROM centos:7

RUN yum install -y gcc make gcc-c++ zlib-devel boost-devel epel-release wget
RUN yum install -y libRmath-devel libRmath-static gsl-devel boost-static zlib zlib-static bzip2 bzip2-devel bzip2-libs blas blas-devel xz-devel blas-static 
RUN wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 && tar xf htslib-1.9.tar.bz2 && mkdir ~/Tools && ln -s `pwd`/htslib-1.9 ~/Tools/htslib-1.3
RUN mkdir -p ~/Tools/R-3.2.2/src/nmath/standalone && ln -s /usr/lib64/libRmath.a ~/Tools/R-3.2.2/src/nmath/standalone/libRmath.a
RUN cd htslib-1.9 && make 
RUN ln -s /usr/lib64 /usr/lib/x86_64-linux-gnu
RUN mkdir -p bin

RUN yum install -y patch

RUN mkdir libbz2_TEMP && cd libbz2_TEMP && \
    yumdownloader -y --resolve --destdir=`pwd` --source bzip2-devel-1.0.6-13.el7 && \
    rpm2cpio bzip2-1.0.6-13.el7.src.rpm | cpio -idv &&\
    tar xf bzip2-1.0.6.tar.gz && \
    patch -p0 < bzip2-1.0.4-saneso.patch &&\
    patch -p0 < bzip2-1.0.4-cflags.patch &&\
    cd bzip2-1.0.6 && \
    patch -p1 < ../bzip2-1.0.4-bzip2recover.patch && \
    make libbz2.a

RUN mkdir libgsl_TEMP && cd libgsl_TEMP && \
    yumdownloader -y --resolve --destdir=`pwd` --source gsl-1.15-13.el7 && \
    rpm2cpio gsl-1.15-13.el7.src.rpm | cpio -idv &&\
    tar xf gsl-1.15.tar.gz && \
    patch -p0 < gsl-1.10-lib64.patch &&\
    patch -p0 < gsl-1.14-link.patch &&\
    cd gsl-1.15 && \
    patch -p1 < ../gsl-1.15-odeinitval2_upstream_rev4788.patch && \
    ./configure --disable-shared && \
    make

RUN mkdir OpenBLAS_TEMP && cd OpenBLAS_TEMP && \
    curl https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v0.3.6 | tar xzf - && \
    cd OpenBLAS-0.3.6 && \
    make

RUN mkdir liblzma_TEMP && cd liblzma_TEMP && \
     yumdownloader -y --resolve --destdir=`pwd` --source xz-5.2.2-1.el7 && \
    rpm2cpio xz-5.2.2-1.el7.src.rpm | cpio -idv &&\
    tar xf xz-5.2.2.tar.gz && \
    cd xz-5.2.2 && \
    patch -p1 < ../xz-5.2.2-man-page-day.patch &&\
    patch -p1 < ../xz-5.2.2-compat-libs.patch &&\
    ./configure --disable-shared && \
    make

RUN yum install -y git

CMD cd /opt && make -f Makefile.static