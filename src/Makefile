# Copyright 2019 Fred Gotwald.  All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

include Makefile.antlr
include Makefile.ieee1800_2017

JAVA = /usr/bin/java
JAVAC = /usr/bin/javac
JAR = /usr/bin/jar

CLASSPATH = ./classes
JARFILE = ieee1800_2017.jar
EXAMPLES = examples

# Might need this sometimes
# HEAP_SIZE = -Xms12G
HEAP_SIZE =

all:: listener example

listener: grammar compile jarfile

grammar:
	cd $(IEEE1800_2017_GRAMMAR); $(MAKE)

compile:
	$(JAVAC) $(HEAP_SIZE) -d $(CLASSPATH) -Xlint:unchecked $(ANTLR_SRCS) $(IEEE1800_2017_SRCS)

jarfile:
	cd $(CLASSPATH); $(JAR) cvf ../../bin/$(JARFILE) .

example:
	cd $(EXAMPLES); $(MAKE)

listen_run: $(TEST)
	$(JAVA) -cp $(CLASSPATH) com.veriktig.scandium.ieee1800_2017.IEEE1800_2017 $?

CLEANFILES = \
	$(CLASSPATH)

clean::
	cd $(IEEE1800_2017_GRAMMAR); $(MAKE) clean
	cd $(EXAMPLES); $(MAKE) clean
	$(RM) -r $(CLEANFILES)

CLOBBERFILES = \
	$(JARFILE)

clobber:: clean
	cd $(IEEE1800_2017_GRAMMAR); $(MAKE) clobber
	cd $(EXAMPLES); $(MAKE) clobber
	$(RM) -r $(CLOBBERFILES)
