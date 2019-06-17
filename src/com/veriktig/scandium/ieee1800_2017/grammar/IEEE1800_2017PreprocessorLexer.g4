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

lexer grammar IEEE1800_2017PreprocessorLexer;

channels {
COMMENTS_CHANNEL,
WHITESPACE_CHANNEL
}

@header {
package com.veriktig.scandium.ieee1800_2017.grammar;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Queue;
import java.util.LinkedList;
import java.util.List;
}

@members {
private int run_level;
private Queue<Token> tokens = new LinkedList<Token>();
private Path current_path;

public void setFilename(String filename, int level) {
    Path path = Paths.get(filename);
    this.current_path = path.toAbsolutePath();
    tokens = tokenize("<+=_\"" + current_path.toString() + "," + level + "\"_=+>\n");
    mode(DEFAULT_MODE);
}

private Queue<Token> tokenize(String inputString) {
    if (inputString == null) {
        return new LinkedList<Token>();
    }
    CharStream is = CharStreams.fromString(inputString);
    IEEE1800_2017PreprocessorLexer lexer = new IEEE1800_2017PreprocessorLexer(is);
    List<? extends Token> temp = lexer.getAllTokens();
    return new LinkedList<Token>(temp);
}

@Override
public Token nextToken() {
    if (tokens.size() == 0) {
        return super.nextToken();
    }
    Token temp = tokens.remove();
    return temp;
}

@Override
public Token getToken() {
    if (tokens.size() == 0) {
        return super.getToken();
    }
    return tokens.peek();
}

@Override
public Token emit() {
    if (tokens.size() == 0) {
        return super.emit();
    }

    Token temp = tokens.remove();
    emit(temp);
    return temp;
}
}

FILENAME  : FILE_START .*? FILE_END '\r'? '\n' -> mode(DEFAULT_MODE);
BACK_TICK:  '`' -> mode(DIRECTIVE_MODE);
NEW_LINE: '\r'? '\n' ;
COMMENT:                  '/*' .*? '*/'                              -> type(CODE);
LINE_COMMENT:             '//' ~[\r\n]*                              -> type(CODE);
STRING:                   StringLiteral                             -> type(CODE);
SLASH:                    '/'                                        -> type(CODE);
CONCAT: '``' -> type(CODE);
ESCAPE_QUOTE: '`"' -> type(CODE);
ESCAPE_SEQUENCE: '`\\`"' -> type(CODE);
CODE:                     ~[`"/\r\n]+ ;

mode RUN_MODE;
RUN_WHITESPACE:      [ \t]+                           -> channel(WHITESPACE_CHANNEL);
RUN_LINE_CONTINUATION:         '\\' '\r'? '\n'  -> channel(WHITESPACE_CHANNEL);
RUN_NEW_LINE:                   '\r'? '\n' -> channel(WHITESPACE_CHANNEL);
RUN_BACK_SLASH_ESCAPE:               '\\' .           -> type(RUN_TEXT);
RUN_BLOCK_COMMENT:               '/*' .*? '*/'    -> channel(COMMENTS_CHANNEL);
RUN_LINE_COMMENT:          '//' ~[\r\n]*    -> channel(COMMENTS_CHANNEL);
RUN_SLASH:                 '/'              -> type(RUN_TEXT);
RUN_STRING: StringLiteral -> type(RUN_TEXT);
RUN_START: [([{] { run_level++; } ;
RUN_END: [\]}] { run_level--; } ;
RUN_COMMA: [,] { if ((run_level - 1) != 0) setType(COMMA_TEXT); else setType(RUN_COMMA); } ;
COMMA_TEXT: [,] ;
RUN_RP: [)] { run_level--; if (run_level == 0) mode(DEFAULT_MODE); else setType(RP_TEXT); } ;
RP_TEXT: [)] ;
RUN_TEXT:                            ~[",(){}[\]\r\n\\/]+ ;

mode DIRECTIVE_MODE;
DIRECTIVE_WHITESPACES:      [ \t]+                           -> channel(WHITESPACE_CHANNEL);
DIRECTIVE_COMMENT:          '/*' .*? '*/'                    -> channel(COMMENTS_CHANNEL);
DIRECTIVE_LINE_COMMENT:     '//' ~[\r\n]*                    -> channel(COMMENTS_CHANNEL);
DIRECTIVE_LINE_CONTINUATION:         '\\' '\r'? '\n'                  -> channel(WHITESPACE_CHANNEL);
DIRECTIVE_NEW_LINE:                   '\r'? '\n'     -> channel(WHITESPACE_CHANNEL), mode(DEFAULT_MODE);
DEFINE:  'define' [ \t]+ -> mode(DEFINE_MODE);
INCLUDE: 'include' [ \t]+ -> mode(TEXT_MODE);
IFNDEF:  'ifndef' [ \t]+ Identifier -> mode(DEFAULT_MODE);
IFDEF:   'ifdef' [ \t]+ Identifier -> mode(DEFAULT_MODE);
ELSIF:   'elsif' [ \t]+ Identifier -> mode(DEFAULT_MODE);
ELSE:    'else' -> mode(DEFAULT_MODE);
ENDIF:   'endif' -> mode(DEFAULT_MODE);
UNDEFINEALL:   'undefineall' -> mode(DEFAULT_MODE);
UNDEF:   'undef' [ \t]+ Identifier -> mode(DEFAULT_MODE);
PRAGMA:  'pragma' -> mode(TEXT_MODE);

FILE: '__FILE__' -> mode(DEFAULT_MODE);
LINE: '__LINE__' -> mode(DEFAULT_MODE);
TIMESCALE: 'timescale' ~[\r\n]+ -> mode(DEFAULT_MODE);
DEFINED_SYMBOL_LP: Identifier [ \t]* [(] { run_level++; } -> mode(RUN_MODE);
DEFINED_SYMBOL: Identifier -> mode(DEFAULT_MODE) ;
DIRECTIVE_STRING:           StringLiteral ;
DIRECTIVE_TICK: '\'' -> type(CODE), mode(DEFAULT_MODE);

mode DEFINE_MODE;

DEFINE_WHITESPACES:      [ \t]+                           -> channel(WHITESPACE_CHANNEL);
DEFINE_LINE_CONTINUATION:         '\\' '\r'? '\n'  -> channel(WHITESPACE_CHANNEL);
DEFINE_NEW_LINE:                   '\r'? '\n'      -> channel(WHITESPACE_CHANNEL);
DEFINE_SYMBOL_LP: Identifier [(] -> mode(DEFINE_ARG_MODE);
DEFINE_SYMBOL: Identifier -> mode(TEXT_MODE);

mode DEFINE_ARG_MODE;
DEFINE_ARG_WHITESPACES:      [ \t]+                           -> channel(WHITESPACE_CHANNEL);
DEFINE_ARG_LINE_CONTINUATION:         '\\' '\r'? '\n'  -> channel(WHITESPACE_CHANNEL);
DEFINE_ARG_NEW_LINE:                   '\r'? '\n'      -> channel(WHITESPACE_CHANNEL);
COMMA: ',' ;
RP: ')' -> mode(TEXT_MODE);
DEFAULT_ARG: Simple_Identifier [ \t]* '=' -> mode(DEFAULT_TEXT_MODE);
ARG: Simple_Identifier ;

mode DEFAULT_TEXT_MODE;

DEFAULT_TEXT_LINE_CONTINUATION:         '\\' '\r'? '\n'  -> channel(WHITESPACE_CHANNEL);
DEFAULT_TEXT_LINE_BACK_SLASH:               '\\' .           -> type(DEFAULT_TEXT);
DEFAULT_TEXT_NEW_LINE:                   '\r'? '\n'       -> channel(WHITESPACE_CHANNEL);
DEFAULT_TEXT_COMMENT:               '/*' .*? '*/'    -> channel(COMMENTS_CHANNEL);
DEFAULT_TEXT_LINE_COMMENT:          '//' ~[\\\r\n]*    -> channel(COMMENTS_CHANNEL);
DEFAULT_TEXT_SLASH:                 '/'              -> type(DEFAULT_TEXT);
DEFAULT_COMMA: ',' -> type(COMMA), mode(DEFINE_ARG_MODE);
DEFAULT_RP: ')' -> type(RP), mode(TEXT_MODE);
DEFAULT_TEXT:                    ~[,)\r\n\\/]+ ;

mode TEXT_MODE;

TEXT_LINE_CONTINUATION:         '\\' '\r'? '\n'  ;
TEXT_LINE_BACK_SLASH:               '\\' .           -> type(TEXT);
TEXT_NEW_LINE:                   '\r'? '\n'       -> channel(WHITESPACE_CHANNEL), mode(DEFAULT_MODE);
TEXT_COMMENT:               '/*' .*? '*/'    -> channel(COMMENTS_CHANNEL);
TEXT_LINE_COMMENT:          '//' ~[\\\r\n]*  -> channel(COMMENTS_CHANNEL);
TEXT_SLASH:                 '/'              -> type(TEXT);
TEXT_WHITESPACE: [ \t]+ -> type(TEXT);
TEXT_CONCAT: '``' -> type(TEXT);
TEXT_ESCAPE_QUOTE: '`"' -> type(TEXT);
TEXT_ESCAPE_SEQUENCE: '`\\`"' -> type(TEXT);
TEXT_STRING: StringLiteral -> type(TEXT);
TEXT:                    ~["\r\n\\/]+ ;

fragment
FILE_START  : '<+=_';
fragment
FILE_END    : '_=+>';
fragment
StringLiteral: '"' (TwoChar|.)*? '"' ;
fragment
TwoChar : '\\"' | '\\\\' ; // 2-char sequences \" and \\
fragment
Identifier : (Simple_Identifier | Escaped_Identifier);
fragment
Simple_Identifier : First_Part (Second_Part)* ;
fragment
First_Part : [a-zA-Z_] ;
fragment
Second_Part : [a-zA-Z0-9_$] ;
fragment
Escaped_Identifier : '\\' ('\u0021'..'\u007E')+ ~[ \r\t\n]* ;
