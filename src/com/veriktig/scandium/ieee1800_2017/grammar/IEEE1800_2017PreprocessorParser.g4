// Copyright 2019 Fred Gotwald.  All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

parser grammar IEEE1800_2017PreprocessorParser;

options {
    tokenVocab=IEEE1800_2017PreprocessorLexer;
}

@header {
package com.veriktig.scandium.ieee1800_2017.grammar;
}

source_text
    : text* EOF
    ;

text
    : current_filename                                      # runFilename
    | code                                                  # runCode
    | new_line                                              # runNewLine
    | BACK_TICK FILE                                        # runFile
    | BACK_TICK LINE                                        # runLine
    | BACK_TICK TIMESCALE                                   # runTimescale
    | BACK_TICK DEFINED_SYMBOL_LP (list_of_rtargs)? RUN_RP  # runMulti
    | BACK_TICK DEFINED_SYMBOL                              # runSingle
    | BACK_TICK define_directive                            # runDefine
    | BACK_TICK directive                                   # runDirective
    ;

current_filename
    : FILENAME         # currentFilename
    ;

code
    : CODE+
    ;

new_line
    : NEW_LINE EOF      # fileEnd
    | NEW_LINE      # newLine
    ;

list_of_rtargs
    : (rtarg_text)* (RUN_COMMA (rtarg_text)*)*      # rtArgList
    ;

rtarg_text
    : RUN_START
    | RUN_END
    | COMMA_TEXT
    | RP_TEXT
    | RUN_TEXT
    ;

define_directive
    : DEFINE DEFINE_SYMBOL_LP (list_of_args)? RP TEXT_LINE_CONTINUATION? (TEXT+ | TEXT_LINE_CONTINUATION)*   # defineMulti
    | DEFINE DEFINE_SYMBOL TEXT_LINE_CONTINUATION? (TEXT+ | TEXT_LINE_CONTINUATION)*                         # define
    ;

list_of_args
    : argument (COMMA argument)*
    ;

argument
    : DEFAULT_ARG (DEFAULT_TEXT+)*              # defaultArg
    | ARG                                       # arg
    ;

directive
    : INCLUDE include_text                      # include
    | ELSIF                                     # conditional
    | ELSE                                      # conditional
    | ENDIF                                     # conditional
    | IFDEF                                     # def
    | IFNDEF                                    # def
    | UNDEF                                     # def
    | UNDEFINEALL                               # def
    | PRAGMA pragma_text                        # pragma
    ;

include_text
    : TEXT+                                     # includeText
    ;

pragma_text
    : TEXT+                                     # pragmaText
    ;
