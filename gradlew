#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##############################################################################
#
#   Gradle startup script for POSIX-compliant shells
#
##############################################################################

# Set local scope for the variables with bash'ism
if [ -n "${BASH_VERSION:-}" ]; then
    set -o posix
fi

DIRNAME=$(dirname "$0")
if [ "$DIRNAME" = "." ] || [ "$DIRNAME" = "" ]; then
    DIRNAME=$(pwd)
fi

APP_BASE_NAME=$(basename "$0")
APP_HOME=$DIRNAME

# Resolve any "." and ".." in APP_HOME to make it shorter.
APP_HOME=$(cd "$APP_HOME" || exit; pwd)

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Find java.exe
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM JDK on AIX uses strange locations for the executables
        JAVA_EXE="$JAVA_HOME/jre/sh/java"
    else
        JAVA_EXE="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVA_EXE" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVA_EXE=java
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

# Increase the maximum file descriptors if we can.
if ! "$JAVA_EXE" -version >/dev/null 2>&1; then
    die "ERROR: Java installation is corrupt. Please check your Java installation."
fi

# Execute Gradle
exec "$JAVA_EXE" $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS "-Dorg.gradle.appname=$APP_BASE_NAME" -classpath "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain "$@"