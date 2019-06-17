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

package examples.parse_tree;

import java.util.ArrayList;
import java.util.List;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ListTokenSource;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;

import com.veriktig.scandium.ieee1800_2017.IEEE1800_2017LexerError;
import com.veriktig.scandium.ieee1800_2017.IEEE1800_2017ParserError;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Lexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Parser;

public class SVParseTree {
    private CharStream is;
    public IEEE1800_2017Parser svparser;
    public CommonTokenStream ts;

    public SVParseTree(CharStream is) {
        this.is = is;
    }

    public ParseTree createTree() {
        IEEE1800_2017Lexer svlexer = new IEEE1800_2017Lexer(is);
        List<? extends Token> svtokens = svlexer.getAllTokens();
        List<Token> modified_tokens = new ArrayList<Token>();
        // Support `line
        boolean startLine = false;
        String file = new String("");
        Integer line = new Integer(1);
        for (Token tt : svtokens) {
            CommonToken ct = (CommonToken) tt;
            int type = ct.getType();
            if (type == IEEE1800_2017Lexer.LINE) {
                startLine = true;
            }
            if (startLine && (type == IEEE1800_2017Lexer.LINE_MODE_NUMBER)) {
                line = new Integer(ct.getText());
            }
            if (startLine && (type == IEEE1800_2017Lexer.LINE_MODE_STRING)) {
                file = ct.getText();
                file = file.replaceAll("\"", "");
                startLine = false;
            }
            ct.setFile(file);
            ct.setLine(line);
            modified_tokens.add(tt);
        }
        svlexer.removeErrorListeners();
        IEEE1800_2017LexerError lerr = new IEEE1800_2017LexerError();
        svlexer.addErrorListener(lerr);
        //ts = new CommonTokenStream(svlexer);
        ListTokenSource svlts = new ListTokenSource(modified_tokens);
        ts = new CommonTokenStream(svlts);
        svparser = new IEEE1800_2017Parser(ts);
        svparser.removeErrorListeners();
        IEEE1800_2017ParserError perr = new IEEE1800_2017ParserError();
        svparser.addErrorListener(perr);
        ParseTree svtree = svparser.source_text();
        return svtree;
    }
}
