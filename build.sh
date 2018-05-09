#!/bin/bash
cd life
etlas install
etlas configure --enable-uberjar-mode
etlas build
cd ../life-java
mvn package
