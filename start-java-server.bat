set JAVA_HOME=C:\Program Files\Java\jdk-10.0.1
set M2_HOME=C:\Program Files\Apache Foundation\apache-maven-3.5.3
set ANT_HOME=C:\Program Files\Apache Foundation\apache-ant-1.10.3
set GRADLE_HOME=C:\Program Files\gradle.org\gradle-4.6
:: set CLASSPATH=.;C:\Program Files\Antlr\antlr-4.5.2-complete.jar;C:\Program Files\Antlr\antlr-3.5.2-complete.jar;%CLASSPATH%
set PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%ANT_HOME%\bin;%GRADLE_HOME%\bin;C:\Program Files\Antlr;%PATH%
cd java-rest-server
call mvn clean
call mvn package
call mvn jetty:run