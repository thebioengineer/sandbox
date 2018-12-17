#! /bin/sh

port=$1
R --vanilla --slave -e sandbox:::evaluateSandbox(port) &
