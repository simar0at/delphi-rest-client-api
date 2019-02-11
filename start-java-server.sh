#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export M2_HOME=/usr/share/maven
export ANT_HOME=/usr/share/ant
export GRADLE_HOME=/usr/share/gradle
# export CLASSPATH=.;C:/Program Files/Antlr/antlr-4.5.2-complete.jar;C:/Program Filesset PATH=%JAVA_HOME%/bin;%M2_HOME%/bin;%ANT_HOME%/bin;%GRADLE_HOME%/bin;C:/Program Files/Antlr;%PATH%
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$ANT_HOME/bin:$GRADLE_HOME/bin:$PATH
cd java-rest-server
mvn clean
mvn package
mvn jetty:run
