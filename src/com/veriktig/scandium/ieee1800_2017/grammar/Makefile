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

JAVA = /usr/bin/java
JAVAC = /usr/bin/javac
CURL = /usr/bin/curl

ANTLR_JAR = antlr-4.7.2-complete.jar
ANTLR_URL = https://www.antlr.org/download/antlr-4.7.2-complete.jar

ANTLR = $(JAVA) -jar antlr-4.7.2-complete.jar

PP_GRAMMAR = IEEE1800_2017PreprocessorLexer.g4 IEEE1800_2017PreprocessorParser.g4
MAIN_GRAMMAR = IEEE1800_2017Lexer.g4 IEEE1800_2017Parser.g4

all:: antlr

antlr: $(ANTLR_JAR)
	$(ANTLR) -long-messages -listener -no-visitor $(PP_GRAMMAR)
	$(ANTLR) -long-messages -listener -no-visitor $(MAIN_GRAMMAR)

$(ANTLR_JAR):
	$(CURL) $(ANTLR_URL) -o $(ANTLR_JAR)

CLEANFILES = \
	*.class \
	*.tokens \
	*.interp

clean::
	$(RM) -r $(CLEANFILES)

CLOBBERFILES = \
	antlr* \
	*.java

clobber:: clean
	$(RM) -r $(CLOBBERFILES)
