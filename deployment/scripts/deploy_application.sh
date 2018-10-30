#!/bin/bash

. /opt/wordpress-codedeploy/deployment/scripts/setenv.sh

# Move to deploy folder
cd $CODEDEPLOY

# Copy files to apache folder
echo "Files replacement"
rm -rf --preserve-root $BACKUP
mv $TARGET $BACKUP
mv $TMPTARGET $TARGET
ln -s $TARGET $CODEDEPLOY
cd $TARGET

# Create additional directories
mkdir -p $TARGET/wp-content/uploads
mkdir -p $TARGET/wp-content/cache
mkdir -p $TARGET/wp-content/w3tc-config

# Change ownership of files in apache folder
chown -R $USER:$GROUP $TARGET

# Uploads folder link
echo "Uploads folder"
cd $TARGET
rsync -arv wp-content/uploads/* $TARGET/../env/$PROJECT/uploads
rm -rf wp-content/uploads; sudo -H -u $USER bash -c "ln -s $TARGET/../env/$PROJECT/uploads ./wp-content/uploads  || true"

# Change SELinux config
chcon -t httpd_sys_content_t $TARGET -R
chcon -t httpd_sys_rw_content_t -R $TARGET/wp-content/{uploads,cache,w3tc-config}

# Copy healthcheck
cp $TARGET/deployment/configs/healthcheck.html $TARGET/

