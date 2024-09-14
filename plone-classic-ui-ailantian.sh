# set path
PATH=
PATH=${PATH}:/usr/local/bin
PATH=${PATH}:/usr/bin
PATH=${PATH}:/bin
echo ${PATH}
PYTHON_TARGET_DIR=/usr/bin

# set variables
PLONE_VERSION=6.0.12
PLONE_NAME=Plone-${PLONE_VERSION}
PLONE_HOME=${HOME}/${PLONE_NAME}
PLONE_CONSTRAINTS_URL=https://dist.plone.org/release/${PLONE_VERSION}/constraints.txt
PLONE_REQUIREMENTS_URL=https://dist.plone.org/release/${PLONE_VERSION}/requirements.txt
#change the name to your old plone5 site name
PLONE_SITE_NAME=oldplone5sitename
ZEO_HOST=127.0.0.1
ZEO_PORT=8100
ZEO_NAME=zeoserver
ZOPE_INSTANCE_NAME=zinstance
#for security, you may use internal address like 127.0.0.1 and use ngnix as backend to forward ssl packages.
ZOPE_INSTANCE_HOST=0.0.0.0
ZOPE_INSTANCE_PORT=8080
DEBUG_MODE=off
ADMIN_USERNAME=admin
#change the name to your old plone5 site admin password
ADMIN_PASSWORD=oldplone5password

# create venv
cd ${HOME}
rm -rf ${PLONE_HOME}
mkdir -p "${PLONE_HOME}"
${PYTHON_TARGET_DIR}/python3 -m venv "${PLONE_HOME}"
cd "${PLONE_HOME}"

# update pip with Plone's release versions requirements
${PLONE_HOME}/bin/python -m pip install \
    pip \
    setuptools \
    wheel \
    -c ${PLONE_REQUIREMENTS_URL}

# pip install Plone Classic UI (no Volto!)
${PLONE_HOME}/bin/pip install \
    Products.CMFPlone \
    Products.CMFPlacefulWorkflow \
    plone.app.caching \
    plone.app.iterate \
    plone.app.upgrade \
    plone.restapi \
    -c ${PLONE_CONSTRAINTS_URL}

# install zope.mkzeoinstance and cookiecutter
${PLONE_HOME}/bin/pip install \
    zope.mkzeoinstance==5.1.1 \
    cookiecutter==2.1.1 \
    -c ${PLONE_CONSTRAINTS_URL}

cd ${PLONE_HOME}

# configure zeo with mkzeoinstance
${PLONE_HOME}/bin/mkzeoinstance ${ZEO_NAME} ${ZEO_HOST}:${ZEO_PORT}

# configure wsgi with cookiecutter-zope-instance
cat <<EOF | tee ${PLONE_HOME}/${ZOPE_INSTANCE_NAME}.yaml
default_context:
    target: '${ZOPE_INSTANCE_NAME}'
    wsgi_listen: '${ZOPE_INSTANCE_HOST}:${ZOPE_INSTANCE_PORT}'
    initial_user_name: '${ADMIN_USERNAME}'
    initial_user_password: '${ADMIN_PASSWORD}'
    db_blobs_mode: 'shared'
    db_storage: 'zeo'
    db_zeo_server: '${ZEO_HOST}:${ZEO_PORT}'
    #db_filestorage_location: "filestorage/Data.fs"
    db_zeo_read_only: false
    db_zeo_read_only_fallback: false
    db_blobs_location: "blobstorage"
EOF
${PLONE_HOME}/bin/cookiecutter -f --no-input \
    --config-file "${PLONE_HOME}/${ZOPE_INSTANCE_NAME}.yaml" \
    --checkout 1.0.0b2  https://github.com/plone/cookiecutter-zope-instance

# set debug-mode
#sed -i 's|^debug-mode.*|debug-mode '${DEBUG_MODE}'|' \
#    ${PLONE_HOME}/${ZOPE_INSTANCE_NAME}/etc/zope.conf
#grep --color "debug-mode.*" ${PLONE_HOME}/${ZOPE_INSTANCE_NAME}/etc/zope.conf

# start zeo as background job
#${PLONE_HOME}/bin/runzeo -C ${PLONE_HOME}/${ZEO_NAME}/etc/zeo.conf &

# runwsgi in debug mode
#${PLONE_HOME}/bin/runwsgi -dv ${PLONE_HOME}/${ZOPE_INSTANCE_NAME}/etc/zope.ini
