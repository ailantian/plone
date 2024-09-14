# plone
plone tips \s
As there is not too much document describes how to upgrade plone to latest 6 with classic UI.
And there is no detailed document about the plone architecture. so when we upgrade plone, you will have different problems.
Plone 6 introduced new frontend which based on javascript(react), but we don't actually want to introduce too much components to plone
Originally plone was developped on python. 

As plone is always updating with the fundamental components such as 
Python
Zope
Zodb

upgrade your os
---------------
for Ubuntu, I was on a really old 20.04.6, the latest one is 24.04, but as latest Ubuntu may still have problem, Ubuntu 22.04 has already provided python 3.10 which we required. so use 22.04.

apt-get update \s
apt-get dist-upgrade \s
do-release-upgrade \s
reboot \s

Install classic UI by script
----------------
( ALERT, it uses zeoclient and zeoserver)
refer to this link
https://community.plone.org/t/what-is-the-best-way-install-a-plone-instance/16225/32?page=2
please refer to my script to install plone 6.0.12, zope version changed. keep in mind to set the password and database name
as the same as your original old plone configuration. for plone5
* /opt/plone52/zinstance/README.html
* /opt/plone52/zinstance/adminPassword.txt
* /opt/plone52/zinstance/parts/instance/inituser

plone 6->zope->zeoclient->zeoserver\s

zeoclient and zeoserver are components of zodb which is the database. so if you use zeoclient,zeoserver\s

zeoserver configuration here [zeoserver] is your zeoserver instance name which you set in the script\s
Plone-6.0.12/zeoserver/etc/zeo.conf

zope configuration for databases\s
Plone-6.0.12/zinstance/etc/zope.conf

zope configuration for wsgi, (web server,default 0.0.0.0:8080)\s
Plone-6.0.12/zinstance/etc/zope.ini

here is the problem, on plone5 which we installed which standalone installer doesn't use zeoserver and zeoclient.\s
plone5 ->zope-> zodb

so after the installation, we should configure plone6 use the same architecture with plone 5, which call zodb without zeoclient.\s
may be you can configure in cookiecutter to disable zeoserver directly.\s

this is plone5 configurations for zodb\s

    </environment>
    <zodb_db main>
        # Main database
        cache-size 30000
        # Blob-enabled FileStorage database
        <blobstorage>
          blob-dir /opt/plone52/zinstance/var/blobstorage
          # FileStorage database
          <filestorage>
            path /opt/plone52/zinstance/var/filestorage/Data.fs
          </filestorage>
        </blobstorage>
        mount-point /
    </zodb_db>
    <zodb_db temporary>
        # Temporary storage database (for sessions)
        <temporarystorage>
          name temporary storage for sessioning
        </temporarystorage>
        mount-point /temp_folder
        container-class Products.TemporaryFolder.TemporaryContainer
    </zodb_db>

this is plone6 zope configurations for zodb should be, plone6 dropped temporarystorage
Plone-6.0.12/zinstance/etc/zope.conf

    <zodb_db main>
        # Main database
        cache-size 30000
        # Blob-enabled FileStorage database
        <blobstorage>
          blob-dir $INSTANCENAME/zinstance/var/blobstorage
          # FileStorage database
          <filestorage>
            path $INSTANCENAME/zinstance/var/filestorage/Data.fs
          </filestorage>
        </blobstorage>
        mount-point /
    </zodb_db>

migrate database
-----
copy your plone5 database to plone6 working directory, the last . is your 

cp -ra /opt/plone52/zinstance/var/blobstorage /opt/plone52/zinstance/var/filestorage/ Plone-6.0.12/zinstance/var/

start your zope instance
---

Plone-6.0.12/runwsgi -dv zinstance/etc/zope.ini &

then try to access with localhost:8080


Tips: 
* my problem is that plone missing my blob files so some images are missing. quite slow, and creating new site works well,
it is possible to move to zeoclient.
but it takes server hours to make it work as original standalone zodb mode for plone. as my site has already lots of data. 

always keeping your old plone working directory as a backup. so you can compare the configurations.

plone5 configurations for zope

/opt/plone52/zinstance/parts/instance/etc/

* my plone 5.2.14 was upgraded from plone 4. so the python has already changed to python3. the zodb has already updated
refer to this link with zodbupdate/zodbverify
https://6.docs.plone.org/backend/upgrading/version-specific-migration/upgrade-zodb-to-python3.html

reference links
for zope configuration, use zodb directly, not with zeoclient if you upgraded from standalone installer installed plone5
without zeoserver. 

https://zope.readthedocs.io/en/latest/operation.html

more details on zeo server and zeo client
https://zeo.readthedocs.io/en/stable/server.html


