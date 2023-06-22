set JAVA_HOME=%HOMEPATH%\scoop\apps\zulufx11-jdk\current
set M2_HOME=%HOMEPATH%\scoop\apps\maven\current
set ANT_HOME=%HOMEPATH%\scoop\apps\ant\current
set GRADLE_HOME=%HOMEPATH%\scoop\apps\gradle\current
:: set CLASSPATH=.;C:\Program Files\Antlr\antlr-4.5.2-complete.jar;C:\Program Filesset PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%ANT_HOME%\bin;%GRADLE_HOME%\bin;C:\Program Files\Antlr;%PATH%
set PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%ANT_HOME%\bin;%GRADLE_HOME%\bin;C:\Program Files\Antlr;%PATH%
cd java-rest-server
mvn jetty:stop