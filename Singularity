Bootstrap: docker
From: centos:7

%arguments
	DOWNLOAD_DIR=/.setup-downloads
	FSL_ENV_URL=https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fsl-6.0.7.2_linux-64.yml
	FS_DOWNLOAD_URL=https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/infant/freesurfer-linux-centos7_x86_64-infant.tar.gz
	FS_DOWNLOAD_FILE=fs-infant.tar.gz

%post
	set -ex

	# Set up download directory
	DOWNLOAD_DIR="{{DOWNLOAD_DIR}}"
	mkdir -p "${DOWNLOAD_DIR}"
	
	# Set up dependencies
	yum install -y -q \
		bc \
        bzip2 \
        curl \
		file \
		install \
		less \
		libGL \
		libGLU \
		libgomp \
		libICE \
		libjpeg \
		libmng \
		libpng12 \
		libSM \
		libX11 \
		libXcursor \
		libXext \
		libXft \
		libXinerama \
		libXmu \
		libXrandr \
		libXrender \
		libXt \
		mesa-libGL \
		openblas-serial \
		perl \
        tar \
		tcsh \
		unzip
	
	# Clean up downloaded packages
	yum clean all
	
	# Set up micromamba
	export ENV_NAME="base"
	export MAMBA_ROOT_PREFIX="/opt/conda"
	export MAMBA_EXE="/bin/micromamba"
	cd /
	curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
	chmod a+x "${MAMBA_EXE}"
	mkdir -p "${MAMBA_ROOT_PREFIX}/conda-meta"
	chmod -R a+rwx "${MAMBA_ROOT_PREFIX}"
	
    # Show the current disk usage
    df -hT

	# Set up FSL
	curl -L "{{FSL_ENV_URL}}" -o "${DOWNLOAD_DIR}/fsl-env.yaml"
	"${MAMBA_EXE}" install -y -n "${ENV_NAME}" -f "${DOWNLOAD_DIR}/fsl-env.yaml"
    "${MAMBA_EXE}" install -y -n "${ENV_NAME}" -c conda-forge conda
    "${MAMBA_EXE}" install -y -n "${ENV_NAME}" -c conda-forge aria2
	rm "${DOWNLOAD_DIR}/fsl-env.yaml"
    "${MAMBA_EXE}" clean -y --all --force-pkgs-dirs
	
    # Show the current disk usage
    df -hT

	# Set up FreeSurfer
	FS_DOWNLOAD_URL="{{FS_DOWNLOAD_URL}}"
	FS_DOWNLOAD_FILE="{{FS_DOWNLOAD_FILE}}"
	FS_DOWNLOAD_PATH="${DOWNLOAD_DIR}/${FS_DOWNLOAD_FILE}"
	
    cd "${DOWNLOAD_DIR}"
    "${MAMBA_EXE}" run -n "${ENV_NAME}" aria2c --show-console-readout=false --summary-interval=60 -x 4 -s 2 --out="${FS_DOWNLOAD_FILE}" "${FS_DOWNLOAD_URL}"
	tar --no-same-owner -xzvf "${FS_DOWNLOAD_URL}"
    mv freesurfer /usr/local/
	rm -f "${FS_DOWNLOAD_FILE}"

    # Show the current disk usage
    df -hT

%environment
	export SHELL="/bin/bash"
	
	# Set up mamba/conda environment
	export ENV_NAME="base"
	export MAMBA_ROOT_PREFIX="/opt/conda"
	export MAMBA_EXE="/bin/micromamba"
	
	export CONDA_DEFAULT_ENV="${ENV_NAME}"
	export CONDA_PREFIX="${MAMBA_ROOT_PREFIX}"
	export CONDA_PROMPT_MODIFIER="(base)"
	export CONDA_SHLVL=1
	export PATH="${CONDA_PREFIX}:${CONDA_PREFIX}/condabin:${PATH}"
	export PS1="${CONDA_PROMPT_MODIFIER} ${PS1:->}"
	
	# Set up FSL environment
	export FSLDIR="${MAMBA_ROOT_PREFIX}"
	export FSLOUTPUTTYPE="NIFTI_GZ"
	export FSLMULTIFILEQUIT="TRUE"
	export FSLTCLSH="${FSLDIR}/bin/fsltclsh"
	export FSLWISH="${FSLDIR}/bin/fslwish"
	export FSLLOCKDIR=
	export FSLMACHINELIST=
	export FSLREMOTECALL=
	export FSLGECUDAQ="cuda.q"
	
	# Set up FreeSurfer environment
	export OS="Linux"
	export FREESURFER_HOME="/usr/local/freesurfer"
	export FREESURFER="${FREESURFER_HOME}"
	export LOCAL_DIR="${FREESURFER_HOME}/local"
	export MNI_DIR="/usr/local/freesurfer/mni"
	export MNI_PERL5LIB="${MNI_DIR}/share/perl5"
	export PERL5LIB="${MNI_PERL5LIB}"
	export MINC_BIN_DIR="${MNI_DIR}/bin"
	export MINC_LIB_DIR="${MNI_DIR}/lib"
	export MNI_DATAPATH="${MNI_DIR}/data"
	export FSFAST_HOME="${FREESURFER_HOME}/fsfast"
	export FMRI_ANALYSIS_DIR="${FSFAST_HOME}"
	export SUBJECTS_DIR="${FREESURFER_HOME}/subjects"
	export FUNCTIONALS_DIR="${FREESURFER_HOME}/sessions"
	export FS_OVERRIDE="0"
	export FSF_OUTPUT_FORMAT="nii.gz"
	export FIX_VERTEX_AREA=""
	export FSLOUTPUTTYPE="NIFTI_GZ"
	
	export PATH="${FREESURFER_HOME}/bin:${FSFAST_HOME}/bin:${FREESURFER_HOME}/tktools:${MINC_BIN_DIR}:${PATH}"

%runscript
	#!/bin/bash
	eval "$("${MAMBA_EXE}" shell hook --shell=bash)"
	micromamba activate "${ENV_NAME:-base}"
	exec "$@"

