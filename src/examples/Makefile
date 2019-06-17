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

include Makefile.examples

JAVA = /usr/bin/java
JAVAC = /usr/bin/javac
JAR = /usr/bin/jar

IEEE1800 = ../../bin/ieee1800_2017.jar
CLASSPATH = ./classes
JARFILE = example.jar

# Might need this sometimes
# HEAP_SIZE = -Xms12G
HEAP_SIZE =

COMMON = $(JAVAC) $(HEAP_SIZE) -cp $(IEEE1800) -d $(CLASSPATH) -Xlint:unchecked

all:: base example jarfile

base:
	$(COMMON) $(EXAMPLE_SRCS)

example:
	$(JAVAC) $(HEAP_SIZE) -cp $(IEEE1800):$(CLASSPATH) -d $(CLASSPATH) -Xlint:unchecked Example.java

jarfile:
	cd $(CLASSPATH); $(JAR) cvf ../../../bin/$(JARFILE) .

listen_run: $(TEST)
	$(JAVA) -cp $(CLASSPATH) com.veriktig.scandium.ieee1800_2017.IEEE1800_2017 $?

CLEANFILES = \
	$(CLASSPATH)

clean::
	$(RM) -r $(CLEANFILES)

CLOBBERFILES =

clobber:: clean
	$(RM) -r $(CLOBBERFILES)
