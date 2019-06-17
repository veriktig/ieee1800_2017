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

package examples.preprocessor;

import java.io.BufferedWriter;
import java.io.File;
import java.io.Writer;
import java.io.OutputStreamWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ListTokenSource;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeListener;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import com.veriktig.scandium.ieee1800_2017.IEEE1800_2017PreprocessorListener;
import com.veriktig.scandium.ieee1800_2017.IEEE1800_2017TextMacros;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorLexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorParser;

public class Preprocessor {
    private IEEE1800_2017TextMacros macros;
    private boolean reportSymbols;
    private boolean createPreprocessedFile;
    
    public Preprocessor(IEEE1800_2017TextMacros macros, boolean reportSymbols, boolean createPreprocessedFile) {
        this.macros = macros;
        this.reportSymbols = reportSymbols;
        this.createPreprocessedFile = createPreprocessedFile;
    }

    public CharStream createStream(String filename) {
    	try {
            Path path = Paths.get(filename).toAbsolutePath();
            CharStream is = CharStreams.fromFileName(filename);
            IEEE1800_2017PreprocessorLexer lexer = new IEEE1800_2017PreprocessorLexer(is);
            lexer.setFilename(filename, 0);
            List<? extends Token> tokens = lexer.getAllTokens();
            ListTokenSource lts = new ListTokenSource(tokens);
            CommonTokenStream ts = new CommonTokenStream(lts);
            IEEE1800_2017PreprocessorParser parser = new IEEE1800_2017PreprocessorParser(ts);
            ParseTree tree = parser.source_text();
            StringBuilder str = new StringBuilder();
            IEEE1800_2017PreprocessorListener listener = new IEEE1800_2017PreprocessorListener(macros, str, path);
            ParseTreeWalker.DEFAULT.walk((ParseTreeListener) listener, tree);
            if (reportSymbols) {
                macros.reportGlobalSymbols(true);
            }
            if (createPreprocessedFile) {
                File fd = new File(filename + ".pp");
                Writer out = null;
                try {
                    out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fd), StandardCharsets.UTF_8));
                    out.append(str.toString());
                    out.close();
                    out = null;
                } finally {
                    if (out != null) {
                        // there was an exception and fd is corrupt
                        try { out.close(); } catch (IOException e) { }
                        fd.delete();
                    }
                }
            }
            is = CharStreams.fromString(str.toString());
            return is;
		} catch (IOException e1) {
			e1.printStackTrace();
            return null;
		}
    }
}
