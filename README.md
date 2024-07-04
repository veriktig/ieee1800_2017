# ieee1800_2017
SystemVerilog preprocessor, lexer and parser with examples

![workflow](https://github.com/veriktig/scandium/actions/workflows/build.yml/badge.svg)

## Overview
The preprocessor was inspired by the excellent **mcpp** by Kiyoshi Matsui.

The lexer and parser are based on the [IEEE spec](https://ieeexplore.ieee.org/document/8299595).

Any questions I had with the spec are marked **// FRED** in IEEE1800_2017Parser.g4.

This project is designed so that it can used with [Project Scandium](https://github.com/veriktig/scandium).

## License
The files in src/org are from The ANTRL Project and are covered by ANTLR_LICENSE.
Other files and ANTLR modifications are covered by LICENSE.

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
```
    Oracle 9
    macOS 10.14.5
```

using:
```
    JDK22
```

## Other Projects
* [ANTLR](http://www.antlr.org) ANother Tool for Language Recognition. BSD-3-clause license
* [MCPP](http://mcpp.sourceforge.net) A portable C preprocessor. BSD-2-clause license

### Change Log
* 2.0.0 Update Antlr version and add CI.
* 1.0.1 Use curl instead of wget (for macOS)
* 1.0.0 Initial Release
