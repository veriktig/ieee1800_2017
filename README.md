# ieee1800_2017
SystemVerilog preprocessor, lexer and parser with examples

## Overview
The preprocessor was inspired by the excellent **mcpp** by Kiyoshi Matsui.

The lexer and parser are based on the * [IEEE spec](https://ieeexplore.ieee.org/document/8299595)

Any questions I had with the spec are marked **// FRED** in IEEE1800_2017Parser.g4.

This project is designed so that it can used with * [Project Scandium](https://github.com/veriktig/scandium)

## Building
Type ```make```

## Running
Use ```./demo.sh <SystemVerilog filename(s)>```

The Example program:
1. Runs the preprocessor and checks if any `define's are left defined.
2. Runs the lexer and parser. Optionally pretty-prints the parse tree.
3. Runs an example linter.
4. Extracts and prints module headers.

### Tools Required
The project was built on:
    Ubuntu 18.04.2

using:
    openjdk 11.0.3 2019-04-16
    OpenJDK Runtime Environment (build 11.0.3+7-Ubuntu-1ubuntu218.04.1)
    OpenJDK 64-Bit Server VM (build 11.0.3+7-Ubuntu-1ubuntu218.04.1, mixed mode, sharing)

## Other Projects
* [ANTLR](http://www.antlr.org) ANother Tool for Language Recognition. BSD-3-clause license
* [MCPP](http://mcpp.sourceforge.net) A portable C preprocessor. BSD-2-clause license

### Change Log
* 1.0.0 Initial Release
