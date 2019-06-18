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

package examples;

package com.veriktig.scandium.ieee1800_2017;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.Set;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ListTokenSource;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorLexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorParser;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Lexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Parser;

public class IEEE1800_2017TextMacros {
    private Set<IEEE1800_2017TextMacroDefinition> macros = new HashSet<IEEE1800_2017TextMacroDefinition>();
    private Path current_path;
    private int line_number;

    public IEEE1800_2017TextMacros() {
    }

    public boolean importJSO(String filename) {
        try {
            Path path = Paths.get(filename).toAbsolutePath();
            InputStream fis = new BufferedInputStream(new FileInputStream(path.toFile()));
            ObjectInputStream ois = new ObjectInputStream(fis);
            Object obj = ois.readObject();
            ois.close();
            if (obj instanceof Set) {
                @SuppressWarnings("unchecked")
                Set<IEEE1800_2017TextMacroDefinition> imported_macros =
                  (Set<IEEE1800_2017TextMacroDefinition>) obj;
                macros.addAll(imported_macros);
            } else {
                System.err.println("ERROR: " + filename + " not Set.");
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return true;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return true;
        }
        return false;
    }

    public boolean exportJSO(String filename) {
        try {
            Path path = Paths.get(filename).toAbsolutePath();
            OutputStream fout = new BufferedOutputStream(new FileOutputStream(path.toFile()));
            ObjectOutputStream oos = new ObjectOutputStream(fout);
            oos.writeObject(macros);
            oos.close();
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
        return false;
    }

    public void add(IEEE1800_2017TextMacroDefinition def) {
        remove(def.getName());
        macros.add(def);
    }

    public boolean containsKey(String key) {
        boolean status = false;
        for (IEEE1800_2017TextMacroDefinition dd : macros) {
            if (dd.getName().equals(key)) {
                status = true;
                break;
            }
        }
        return status;
    }

    public boolean remove(String key) {
        boolean status = false;

        Iterator<IEEE1800_2017TextMacroDefinition> iter = macros.iterator();
        while (iter.hasNext()) {
            IEEE1800_2017TextMacroDefinition mm = iter.next();
            String name = mm.getName();
            if (name.equals(key)) {
                iter.remove();
                status = true;
            }
        }
        return status;
    }

    public void clear() {
        macros.clear();
    }

    public String expand(Path current_path, int line_number, StringBuilder sb, String key, Queue<String> runtime_args) {
        String replacement = new String("");

        this.current_path = current_path;
        this.line_number = line_number;
        for (IEEE1800_2017TextMacroDefinition dd : macros) {
            if (dd.getName().equals(key)) {
                replacement = substitute(sb, dd, runtime_args);
                break;
            }
        }
        return replacement;
    }

    private String substitute(StringBuilder sb, IEEE1800_2017TextMacroDefinition dd, Queue<String> runtime_args) {
        String status = new String("");
        String rta = new String("");

        Queue<IEEE1800_2017TextMacroDefinition.Argument> qargs = dd.getArguments();
        if (runtime_args.size() > qargs.size()) {
            /* Special case for macro name used in front of a parend */
            if (qargs.size() == 0) {
                StringBuilder sba = new StringBuilder();
                sba.append(dd.getText());
                sba.append("(");
                Iterator<String> iter = runtime_args.iterator();
                if (iter.hasNext()) {
                    rta = iter.next();
                    sba.append(rta);
                }
                while (iter.hasNext()) {
                    rta = iter.next();
                    sba.append(",");
                    sba.append(rta);
                }
                sba.append(")");
                return sba.toString();
            }
            if (current_path != null) {
                System.err.println(current_path.toString() + ":" + line_number);
            }
            System.err.println("ERROR: Too many runtime arguments in `" + dd.getName());
            System.err.println("     " + runtime_args.size() + " > " + qargs.size());
            return status;
        }

        String text = dd.getText();
        String new_text = scan(dd, text, qargs, runtime_args);
        if (new_text == null) {
            return status;
        }
        if (!dd.hasArguments()) {
            if (dd.hasText()) {
                rescan(new_text, sb);
                return status;
            } else {
                return status;
            }
        }
        if (!dd.hasText()) {
            return status;
        }
        rescan(new_text, sb);

        return status;
    }

    private void rescan(String new_text, StringBuilder sb) {
        // Recursion
        CharStream is = CharStreams.fromString(new_text);
        IEEE1800_2017PreprocessorLexer lexer = new IEEE1800_2017PreprocessorLexer(is);
        List<? extends Token> temp = lexer.getAllTokens();
        LinkedList<Token> tokens = new LinkedList<Token>(temp);
        ListTokenSource lts = new ListTokenSource(tokens);
        CommonTokenStream ts = new CommonTokenStream(lts);
        IEEE1800_2017PreprocessorParser parser = new IEEE1800_2017PreprocessorParser(ts);
        ParseTree tree = parser.source_text();
        ParseTreeWalker walker = new ParseTreeWalker();
        IEEE1800_2017PreprocessorListener eval = new IEEE1800_2017PreprocessorListener(this, sb, current_path);
        eval.recursion();
        walker.walk(eval, tree);
    }

    private String scan(IEEE1800_2017TextMacroDefinition dd, String inputString, Queue<IEEE1800_2017TextMacroDefinition.Argument> args, Queue<String> rargs) {
        if (inputString == null) {
            return new String("");
        }
        CharStream is = CharStreams.fromString(inputString);
        IEEE1800_2017Lexer lexer = new IEEE1800_2017Lexer(is);
        List<? extends Token> temp = lexer.getAllTokens();
        LinkedList<Token> tokens = new LinkedList<Token>(temp);
        StringBuilder str = new StringBuilder();
        for (Token tt : tokens) {
            if (tt.getText().startsWith("\"") && tt.getText().endsWith("\"")) {
                str.append(tt.getText());
                continue;
            }
            String rtxt = replace(dd, tt.getText(), args, rargs);
            if (rtxt != null) {
                str.append(rtxt);
            } else {
                return rtxt;
            }
        }
        return str.toString();
    }

    private String replace(IEEE1800_2017TextMacroDefinition dd, String text, Queue<IEEE1800_2017TextMacroDefinition.Argument> args, Queue<String> rargs) {
        text = text.replace("``","");
        text = text.replace("`\\`\"","\\\"");
        text = text.replace("`\"","\"");
        LinkedList<String> rtargs = new LinkedList<String>(rargs);
        Iterator<IEEE1800_2017TextMacroDefinition.Argument> miter = args.iterator();
        while (miter.hasNext()) {
            IEEE1800_2017TextMacroDefinition.Argument marg = miter.next();
            String arg = marg.getName();
            String rtarg = null;
            if (rtargs.size() > 0) {
                rtarg = rtargs.pop();
            }
            if (rtarg == null) {
                rtarg = marg.getDefault();
                if (rtarg == null) {
                    System.err.println(current_path.toString() + ":" + line_number);
                    System.err.println("ERROR: Unspecified runtime_arg with no default in `" + dd.getName());
                    return null;
                }
            }
            if (text.equals(arg)) {
                text = text.replace(arg, rtarg);
                break;
            }
        }
        return text;
    }

    public void reportGlobalSymbols(boolean verbose) {
        // 40.3.1 Predefined coverage constants in SystemVerilog
        String[] builtins = new String[]{
            "SV_COV_START",
            "SV_COV_STOP",
            "SV_COV_RESET",
            "SV_COV_CHECK",
            "SV_COV_MODULE",
            "SV_COV_HIER",
            "SV_COV_ASSERTION",
            "SV_COV_FSM_STATE",
            "SV_COV_STATEMENT",
            "SV_COV_TOGGLE",
            "SV_COV_OVERFLOW",
            "SV_COV_ERROR",
            "SV_COV_NOCOV",
            "SV_COV_OK",
            "SV_COV_PARTIAL"
        };

        for (IEEE1800_2017TextMacroDefinition mm : macros) {
            if (Arrays.asList(builtins).contains(mm.getName())) continue;
            if (verbose)
                System.out.println("WARNING: Symbol left defined: `" + mm.getName() + "\n" + mm.getText());
            else
                System.out.println("WARNING: Symbol left defined: `" + mm.getName());
        }
    }
}
