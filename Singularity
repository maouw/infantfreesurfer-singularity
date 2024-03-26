Bootstrap: docker
From: centos:7


%setup
    # Invoke build with apptainer build --bind ${PWD}/dl:/dl if you want to use predownloaded freesurfer
    mkdir -p ${APPTAINER_ROOTFS}/dl

%post
    set -ex
    # install utils
    yum -y update
    yum -y install bc libgomp perl tar tcsh wget vim-common
    yum -y install mesa-libGL libXext libSM libXrender libXmu
    yum clean all
    
    # Use local freesurfer download if available
    if [ -f "/dl/fs-infant.tar.gz" ]; then
        echo "Using local freesurfer download"
        USING_LOCAL_FS=1
    else
        wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/infant/freesurfer-linux-centos7_x86_64-infant.tar.gz -O /dl/fs-infant.tar.gz
    fi

    tar --no-same-owner -xzvf /dl/fs-infant.tar.gz --directory=/ && mv freesurfer /usr/local

    if [ -z "${USING_LOCAL_FS:-}" ]; then
        echo "Cleaning up local freesurfer download"
        rm -f /dl/fs-infant.tar.gz
    fi

%environment
    # setup freesurfer env
    export OS="Linux"
    export PATH="/usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    export FREESURFER_HOME="/usr/local/freesurfer"
    export FREESURFER="/usr/local/freesurfer"
    export FS_OVERRIDE="0"
    export PERL5LIB="/usr/local/freesurfer/mni/share/perl5"
    export LOCAL_DIR="/usr/local/freesurfer/local"
    export FSFAST_HOME="/usr/local/freesurfer/fsfast"
    export FMRI_ANALYSIS_DIR="/usr/local/freesurfer/fsfast"
    export FSF_OUTPUT_FORMAT="nii.gz"
    export MINC_BIN_DIR="/usr/local/freesurfer/mni/bin"
    export SUBJECTS_DIR="/usr/local/freesurfer/subjects"
    export FUNCTIONALS_DIR="/usr/local/freesurfer/sessions"
    export MINC_LIB_DIR="/usr/local/freesurfer/mni/lib"
    export MNI_DIR="/usr/local/freesurfer/mni"
    export MNI_DATAPATH="/usr/local/freesurfer/mni/data"
    export MNI_PERL5LIB="/usr/local/freesurfer/mni/share/perl5"
    export FIX_VERTEX_AREA=""
    export FSLOUTPUTTYPE="NIFTI_GZ"
