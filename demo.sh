#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage: $0 <filename(s)>"
fi

/usr/bin/java -cp bin/ieee1800_2017.jar:bin/example.jar examples.Example $@
