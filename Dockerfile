# syntax=docker/dockerfile:1
FROM centos:7
ARG FSL_ENV_URL="https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fsl-6.0.7.2_linux-64.yml"
ARG INFANTFS_DOWNLOAD_URL="https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/infant/freesurfer-linux-centos7_x86_64-infant.tar.gz"

ARG A2X=1
ARG A2S=${A2X}

ARG MAMBA_USER=mambauser
ARG MAMBA_USER_ID=57439
ARG MAMBA_USER_GID=57439
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_USER_ID=$MAMBA_USER_ID
ENV MAMBA_USER_GID=$MAMBA_USER_GID


RUN yum install -y -q \
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
		unzip && \
        yum clean all

# for use with 'apptainer shell --shell /usr/local/bin/_apptainer_shell.sh ...'
COPY --chmod=755 micromamba-docker/_apptainer_shell.sh /usr/local/bin/_apptainer_shell.sh
# Script which launches commands passed to "docker run"
COPY --chmod=755 micromamba-docker/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --chmod=755 micromamba-docker/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --chmod=755 micromamba-docker/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
COPY --chmod=755 micromamba-docker/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh

ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
ENV FREESURFER_HOME="/opt/freesurfer"

SHELL [ "/bin/bash", "-o", "xtrace", "-o", "pipefail", "-o", "errexit", "-o", "errtrace", "-c" ]
RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
	mkdir -p /opt /opt/downloads "${MAMBA_ROOT_PREFIX}/conda-meta" "${FREESURFER_HOME}" && \
	chown -R "${MAMBA_USER}": /opt /opt/downloads "${MAMBA_ROOT_PREFIX}" "${FREESURFER_HOME}" && \
	chmod -R a+rwx /opt /opt/downloads "${MAMBA_ROOT_PREFIX}" "${FREESURFER_HOME}" && \
    curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba && \
	chmod a+rx "${MAMBA_EXE}"


USER "${MAMBA_USER}"
WORKDIR /opt/downloads
# Set up FSL
RUN "${MAMBA_EXE}" install -y -n "${ENV_NAME}" -c conda-forge conda aria2 pv && \
    "${MAMBA_EXE}" run -n "${ENV_NAME}" aria2c --out="fsl-env.yaml" "${FSL_ENV_URL}" && \
	"${MAMBA_EXE}" install -y -n "${ENV_NAME}" -f "fsl-env.yaml" && \
    rm "fsl-env.yaml" && \
    "${MAMBA_EXE}" clean -y --all --force-pkgs-dirs

# Set up infant FreeSurfer
WORKDIR /opt/downloads
RUN "${MAMBA_EXE}" run -n "${ENV_NAME}" \
    aria2c --show-console-readout=false --summary-interval=60 -x ${A2X} -s ${A2S} --out=fs-infant.tar.gz "${INFANTFS_DOWNLOAD_URL}" && \
    ${MAMBA_EXE} run -n "${ENV_NAME}" \
		pv fs-infant.tar.gz | \
		tar -xzf - \
		--no-same-owner \
		--mode='a+rwX' \
		--directory "${FREESURFER_HOME}" \
		--strip-components=1 && \
    : > fs-infant.tar.gz && \
	rm fs-infant.tar.gz

# Set up mamba/conda environment
WORKDIR /

ENV MAMBA_DOCKERFILE_ACTIVATE=1

# Set up FSL environment
ENV FSLDIR="${MAMBA_ROOT_PREFIX}"
ENV FSLOUTPUTTYPE="NIFTI_GZ"
ENV FSLMULTIFILEQUIT="TRUE"
ENV FSLTCLSH="${FSLDIR}/bin/fsltclsh"
ENV FSLWISH="${FSLDIR}/bin/fslwish"
ENV FSLLOCKDIR=""
ENV FSLMACHINELIST=""
ENV FSLREMOTECALL=""
ENV FSLGECUDAQ="cuda.q"

# Set up FreeSurfer environment
ENV OS="Linux"
ENV FREESURFER_HOME="${FREESURFER_HOME}"
ENV FREESURFER="${FREESURFER_HOME}"
ENV LOCAL_DIR="${FREESURFER_HOME}/local"
ENV MNI_DIR="${FREESURFER_HOME}/mni"
ENV MNI_PERL5LIB="${MNI_DIR}/share/perl5"
ENV PERL5LIB="${MNI_PERL5LIB}"
ENV MINC_BIN_DIR="${MNI_DIR}/bin"
ENV MINC_LIB_DIR="${MNI_DIR}/lib"
ENV MNI_DATAPATH="${MNI_DIR}/data"
ENV FSFAST_HOME="${FREESURFER_HOME}/fsfast"
ENV FMRI_ANALYSIS_DIR="${FSFAST_HOME}"
ENV SUBJECTS_DIR="${FREESURFER_HOME}/subjects"
ENV FUNCTIONALS_DIR="${FREESURFER_HOME}/sessions"
ENV FS_OVERRIDE="0"
ENV FSF_OUTPUT_FORMAT="nii.gz"
ENV FIX_VERTEX_AREA=""
ENV FSLOUTPUTTYPE="NIFTI_GZ"

ENV PATH="${FREESURFER_HOME}/bin:${FSFAST_HOME}/bin:${FREESURFER_HOME}/tktools:${MINC_BIN_DIR}:${PATH}"

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

# Default command for "docker run"
CMD ["/bin/bash"]

# Script which launches RUN commands in Dockerfile
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]
