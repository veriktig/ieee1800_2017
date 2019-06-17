// Copyright (c) 2017 Veriktig.  All rights reserved.

package com.veriktig.scandium.ieee1800_2017;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.RecognitionException;

public class IEEE1800_2017ParserError extends BaseErrorListener {
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
      int line, int charPositionInLine, String msg, RecognitionException e) {
        CommonToken ct = (CommonToken) offendingSymbol;
        System.err.println("ERROR: " + ct.getFile() + ":"+ct.getLine()+":"+charPositionInLine+" "+msg);
    }
}
