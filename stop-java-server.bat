set JAVA_HOME=C:\Program Files\Zulu\zulu-11
set M2_HOME=C:\Program Files\Apache Foundation\apache-maven-3.9.1
set ANT_HOME=C:\Program Files\Apache Foundation\apache-ant-1.10.13
set GRADLE_HOME=C:\Program Files\gradle.org\gradle-4.10.2
:: set CLASSPATH=.;C:\Program Files\Antlr\antlr-4.5.2-complete.jar;C:\Program Filesset PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%ANT_HOME%\bin;%GRADLE_HOME%\bin;C:\Program Files\Antlr;%PATH%
set PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%ANT_HOME%\bin;%GRADLE_HOME%\bin;C:\Program Files\Antlr;%PATH%
cd java-rest-server
mvn jetty:stop