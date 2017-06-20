#!/usr/bin/env bash

bundle install
mvn -q -Dmockserver.serverPort=8098 -Dmockserver.proxyPort=9102 -Dmockserver.logLevel=INFO org.mock-server:mockserver-maven-plugin:3.10.4:runForked
bundle exec rake spec
mvn -q -Dmockserver.serverPort=8098 -Dmockserver.proxyPort=9102 -Dmockserver.logLevel=INFO org.mock-server:mockserver-maven-plugin:3.10.4:stopForked