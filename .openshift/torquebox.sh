#!/bin/bash

# The pre_start_cartridge and pre_stop_cartridge hooks are *SOURCED*
# immediately before (re)starting or stopping the specified cartridge.
# They are able to make any desired environment variable changes as
# well as other adjustments to the application environment.

# The post_start_cartridge and post_stop_cartridge hooks are executed
# immediately after (re)starting or stopping the specified cartridge.

# Exercise caution when adding commands to these hooks.  They can
# prevent your application from stopping cleanly or starting at all.
# Application start and stop is subject to different timeouts
# throughout the system.

# Required TorqueBox environment variables
export TORQUEBOX_HOME=$OPENSHIFT_DATA_DIR/torquebox
export JRUBY_HOME=$TORQUEBOX_HOME/jruby
export PATH=$JRUBY_HOME/bin:$PATH
# Insert the TorqueBox modules before the jbossas-7 ones
export JBOSS_MODULEPATH_ADD=$TORQUEBOX_HOME/jboss/modules/system/layers/base:$TORQUEBOX_HOME/jboss/modules

function torquebox_install() {
    local VERSION=${1:-LATEST}
    # Determine whether we're getting a release or an incremental
    if [[ ${VERSION} =~ \. ]]; then
        URL=http://repository-projectodd.forge.cloudbees.com/release/org/torquebox/torquebox-dist/${VERSION}/torquebox-dist-${VERSION}-bin.zip
    else
        URL=http://repository-projectodd.forge.cloudbees.com/incremental/torquebox/${VERSION}/torquebox-dist-bin.zip
    fi
    pushd ${OPENSHIFT_DATA_DIR} >/dev/null
    rm -rf torquebox*
    wget -nv ${URL}
    unzip -q torquebox-dist-*.zip
    rm torquebox-dist-*.zip
    ln -s torquebox-* torquebox
    echo "Installed" torquebox-*
    popd >/dev/null
}

function bundle_install() {
    if [ ! -d "${OPENSHIFT_REPO_DIR}/.bundle" ] && [ -f "${OPENSHIFT_REPO_DIR}/Gemfile" ]; then
        pushd ${OPENSHIFT_REPO_DIR} > /dev/null
        jruby -J-Xmx256m -J-Dhttps.protocols=SSLv3 -S bundle install
        popd > /dev/null
    fi
}

function db_migrate() {
    pushd ${OPENSHIFT_REPO_DIR} > /dev/null
    bundle exec rake db:migrate RAILS_ENV="production"
    popd > /dev/null
}