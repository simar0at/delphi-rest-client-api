set JAVA_HOME=C:\Program Files\Java\jdk1.7.0_60
set M2_HOME=C:\Program Files\Apache Foundation\apache-maven-3.0.4
set ANT_HOME=C:\Program Files\Apache Foundation\apache-ant-1.9.3
set PATH=%M2_HOME%\bin;%JAVA_HOME%\bin;%ANT_HOME%\bin;%PATH%
cd java-rest-server
call mvn clean
call mvn package
call mvn jetty:run