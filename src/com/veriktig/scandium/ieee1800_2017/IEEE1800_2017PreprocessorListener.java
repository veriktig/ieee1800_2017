// Copyright (c) 2017 Veriktig.  All rights reserved.

package com.veriktig.scandium.ieee1800_2017;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Deque;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ListTokenSource;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorLexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorParser;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017PreprocessorParserBaseListener;

public class IEEE1800_2017PreprocessorListener extends IEEE1800_2017PreprocessorParserBaseListener {
    private Deque<Boolean> stack = new LinkedList<Boolean>();
    private IEEE1800_2017TextMacros macros;
    private Queue<String> runtime_args = new LinkedList<String>();
    private StringBuilder return_string;
    private int recursion_level;
    private Path base_path;
    private Path current_path;
    private Deque<Path> path_stack = new LinkedList<Path>();
    private Integer line_number = new Integer(1);
    private Deque<Integer> line_stack = new LinkedList<Integer>();

    public IEEE1800_2017PreprocessorListener(IEEE1800_2017TextMacros macros, StringBuilder str, Path path)
    {
        this.macros = macros;
        this.return_string = str;
        this.base_path = path;
        this.current_path = path;
        stack.push(true);
        addBuiltins();
    }

    // 40.3.1 Predefined coverage constants in SystemVerilog
    private void addBuiltins()
    {
        class Builtin {
            private final String key;
            private final String value;
            
            public Builtin(String akey, String avalue) 
            {
                key = akey;
                value = avalue;
            }

            public String getKey() { return key; }
            public String getValue() { return value; }
        }

        Builtin[] builtins = new Builtin[15];

        // Coverage control
        builtins[0] = new Builtin("SV_COV_START", "0");
        builtins[1] = new Builtin("SV_COV_STOP", "1");
        builtins[2] = new Builtin("SV_COV_RESET", "2");
        builtins[3] = new Builtin("SV_COV_CHECK", "3");
        // Scope definition
        builtins[4] = new Builtin("SV_COV_MODULE", "10");
        builtins[5] = new Builtin("SV_COV_HIER", "11");
        // Coverage type
        builtins[6] = new Builtin("SV_COV_ASSERTION", "20");
        builtins[7] = new Builtin("SV_COV_FSM_STATE", "21");
        builtins[8] = new Builtin("SV_COV_STATEMENT", "22");
        builtins[9] = new Builtin("SV_COV_TOGGLE", "23");
        // Status results
        builtins[10] = new Builtin("SV_COV_OVERFLOW", "-2");
        builtins[11] = new Builtin("SV_COV_ERROR", "-1");
        builtins[12] = new Builtin("SV_COV_NOCOV", "0");
        builtins[13] = new Builtin("SV_COV_OK", "1");
        builtins[14] = new Builtin("SV_COV_PARTIAL", "2");

        for (int ii = 0; ii < builtins.length; ii++) {
            IEEE1800_2017TextMacroDefinition tmd = new IEEE1800_2017TextMacroDefinition(builtins[ii].getKey());
            tmd.setText(builtins[ii].getValue().trim());
            macros.add(tmd);
        }
    }

	@Override
    public void enterCurrentFilename(IEEE1800_2017PreprocessorParser.CurrentFilenameContext ctx) {
        if (Skip()) return;

        String filename = ctx.FILENAME().getText();
        filename = filename.replace("<+=_", "");
        filename = filename.replace("_=+>", "");
        filename = filename.replaceAll("[\"]", "");
        String[] parts = filename.split("[,]");
        current_path = Paths.get(parts[0]);
        return_string.append("`line ");
        return_string.append(line_number);
        return_string.append(" \"");
        return_string.append(current_path);
        return_string.append("\" ");
        return_string.append(parts[1]);
    }

	@Override
    public void exitNewLine(IEEE1800_2017PreprocessorParser.NewLineContext ctx) {
        line_number++;
        return_string.append("\n`line ");
        return_string.append(line_number);
        return_string.append(" \"");
        return_string.append(current_path);
        return_string.append("\" 0\n");
    }

	@Override
    public void enterFileEnd(IEEE1800_2017PreprocessorParser.FileEndContext ctx) {
        return_string.append("\n");
    }

	@Override
    public void exitRunCode(IEEE1800_2017PreprocessorParser.RunCodeContext ctx) {
        if (Skip()) return;

        List<TerminalNode> codes = ctx.code().CODE();
        StringBuilder str = new StringBuilder();
        for (TerminalNode tn : codes) {
            str = str.append(tn.getText());
        }
        return_string.append(str);
        line_number += countLines(str.toString());
    }

	@Override
    public void exitRunFile(IEEE1800_2017PreprocessorParser.RunFileContext ctx) {
        if (Skip()) return;

        String filename = new String("\"" + current_path.toString() + "\"");
        return_string.append(filename);
    }

	@Override
    public void exitRunLine(IEEE1800_2017PreprocessorParser.RunLineContext ctx) {
        if (Skip()) return;

        return_string.append(line_number.toString());
    }

	@Override
    public void exitRunTimescale(IEEE1800_2017PreprocessorParser.RunTimescaleContext ctx) {
        if (Skip()) return;

        String timescale = new String(ctx.BACK_TICK().getText() + ctx.TIMESCALE().getText());
        return_string.append(timescale);
    }

	@Override
    public void enterRunMulti(IEEE1800_2017PreprocessorParser.RunMultiContext ctx) {
        if (Skip()) return;

        runtime_args.clear();
        // Prepend an empty space
        String empty_space = new String(" ");
        return_string.append(empty_space);
    }

	@Override
    public void exitRunMulti(IEEE1800_2017PreprocessorParser.RunMultiContext ctx) {
        if (Skip()) return;

        String key = ctx.DEFINED_SYMBOL_LP().getText();
        key = key.replaceFirst("[(]", "");
        String replacement_text = macros.expand(current_path, line_number, return_string, key, runtime_args);
        return_string.append(replacement_text);
    }

	@Override
    public void enterRunSingle(IEEE1800_2017PreprocessorParser.RunSingleContext ctx) {
        if (Skip()) return;

        runtime_args.clear();
        // Prepend an empty space
        String empty_space = new String(" ");
        return_string.append(empty_space);
    }

	@Override
    public void exitRunSingle(IEEE1800_2017PreprocessorParser.RunSingleContext ctx) {
        if (Skip()) return;

        String key = ctx.DEFINED_SYMBOL().getText();
        String replacement_text = macros.expand(current_path, line_number, return_string, key, runtime_args);
        return_string.append(replacement_text);
    }

	@Override
    public void exitRtArgList(IEEE1800_2017PreprocessorParser.RtArgListContext ctx) {
        List<TerminalNode> all_tokens = new LinkedList<TerminalNode>();

        if (Skip()) return;

        List<IEEE1800_2017PreprocessorParser.Rtarg_textContext> alist = ctx.rtarg_text();
        for (IEEE1800_2017PreprocessorParser.Rtarg_textContext aa : alist) {
            List<TerminalNode> args = aa.getTokens();
            all_tokens.addAll(args);
        }

        List<TerminalNode> commas = ctx.RUN_COMMA();
        all_tokens.addAll(commas);
        // Sort by Interval
        all_tokens.sort((TerminalNode tn1, TerminalNode tn2) -> tn1.getSourceInterval().a - tn2.getSourceInterval().a);
        StringBuilder str = new StringBuilder();
        for (TerminalNode tn : all_tokens) {
            if (tn.getSymbol().getType() == IEEE1800_2017PreprocessorParser.RUN_COMMA) {
                runtime_args.add(str.toString());
                str = new StringBuilder();
            } else {
                str = str.append(tn.getText().trim());
            }
        }
        runtime_args.add(str.toString());
    }

	@Override
    public void exitDefineMulti(IEEE1800_2017PreprocessorParser.DefineMultiContext ctx) {
        List<TerminalNode> all_tokens = new LinkedList<TerminalNode>();

        if (Skip()) return;

        String name = ctx.DEFINE_SYMBOL_LP().getText();
        name = name.replaceFirst("[(]", "");
        IEEE1800_2017TextMacroDefinition tmd = new IEEE1800_2017TextMacroDefinition(name);
        IEEE1800_2017PreprocessorParser.List_of_argsContext ctx2 = ctx.list_of_args(); 
        if (ctx2 == null) {
            System.err.println("ERROR: Malformed list of arguments.");
            return;
        }
        List<IEEE1800_2017PreprocessorParser.ArgumentContext> args = ctx2.argument();
        for (IEEE1800_2017PreprocessorParser.ArgumentContext aa : args) {
            IEEE1800_2017TextMacroDefinition.Argument tma = null;
            if (aa.getClass().getName().contains("DefaultArgContext")) {
                String[] parts = aa.getText().split("=", 2);
                if (parts[0].length() > 0) {
                    tma = tmd.new Argument(parts[0]);
                }
                if (parts[1].length() > 0) {
                    tma.setDefault(parts[1].trim());
                } else {
                    tma.setDefault(new String(""));
                }
            } else {
                String temp = aa.getText().trim();
                tma = tmd.new Argument(temp);
            }
            tmd.addArgument(tma);
        }

        List<TerminalNode> tlist = ctx.TEXT();
        all_tokens.addAll(tlist);
        List<TerminalNode> clist = ctx.TEXT_LINE_CONTINUATION();
        all_tokens.addAll(clist);
        // Sort by Interval
        all_tokens.sort((TerminalNode tn1, TerminalNode tn2) -> tn1.getSourceInterval().a - tn2.getSourceInterval().a);
        StringBuilder str = new StringBuilder();
        for (TerminalNode tn : all_tokens) {
            if (tn.getSymbol().getType() == IEEE1800_2017PreprocessorParser.TEXT) {
                String temp = tn.getText();
                if (temp.length() > 0) {
                    str = str.append(temp);
                }
            } else {
                str = str.append("\n");
            }
        }
        tmd.setText(str.toString().trim());
        macros.add(tmd);
        line_number += 1 + clist.size();
    }

	@Override
    public void exitDefine(IEEE1800_2017PreprocessorParser.DefineContext ctx) {
        List<TerminalNode> all_tokens = new LinkedList<TerminalNode>();

        if (Skip()) return;

        String name = ctx.DEFINE_SYMBOL().getText();
        IEEE1800_2017TextMacroDefinition tmd = new IEEE1800_2017TextMacroDefinition(name);
        List<TerminalNode> tlist = ctx.TEXT();
        all_tokens.addAll(tlist);
        List<TerminalNode> clist = ctx.TEXT_LINE_CONTINUATION();
        all_tokens.addAll(clist);
        // Sort by Interval
        all_tokens.sort((TerminalNode tn1, TerminalNode tn2) -> tn1.getSourceInterval().a - tn2.getSourceInterval().a);
        StringBuilder str = new StringBuilder();
        for (TerminalNode tn : all_tokens) {
            if (tn.getSymbol().getType() == IEEE1800_2017PreprocessorParser.TEXT) {
                String temp = tn.getText();
                if (temp.length() > 0) {
                    str = str.append(temp);
                }
            } else {
                str = str.append("\n");
            }
        }
        tmd.setText(str.toString().trim());
        macros.add(tmd);
        line_number += 1 + clist.size();
    }

	@Override
    public void exitConditional(IEEE1800_2017PreprocessorParser.ConditionalContext ctx) {
        String key;

        if (ctx.ELSIF() != null) {
            key = ctx.ELSIF().getText();
            key = key.replaceFirst("elsif", ""); 
            key = key.replace(" ", ""); 
            key = key.replace("\t", ""); 
            if (stack.size() > 0) {
                stack.pop();
            } else {
                System.out.println("ERROR: stack is empty on `elsif");
            }
            boolean condition = macros.containsKey(key);
            stack.push(condition);
        } else if (ctx.ELSE() != null) {
            if (stack.size() > 0) {
                boolean val = stack.pop();
                stack.push(!val);
            } else {
                System.out.println("ERROR: stack is empty on `else");
            }
        } else if (ctx.ENDIF() != null) {
            if (stack.size() > 0) {
                stack.pop();
            } else {
                System.out.println("ERROR: stack is empty on `endif");
            }
        }
    }

	@Override
    public void exitDef(IEEE1800_2017PreprocessorParser.DefContext ctx) {
        String key;

        if (ctx.IFDEF() != null) {
            key = ctx.IFDEF().getText();
            key = key.replaceFirst("ifdef", ""); 
            key = key.replace(" ", ""); 
            key = key.replace("\t", ""); 
            boolean condition = macros.containsKey(key);
            stack.push(condition);
        } else if (ctx.IFNDEF() != null) {
            key = ctx.IFNDEF().getText();
            key = key.replaceFirst("ifndef", ""); 
            key = key.replace(" ", ""); 
            key = key.replace("\t", ""); 
            boolean condition = macros.containsKey(key);
            condition = !condition;
            stack.push(condition);
        } else if (ctx.UNDEF() != null) {
            if (!Skip()) {
                key = ctx.UNDEF().getText();
                key = key.replaceFirst("undef", ""); 
                key = key.replace(" ", ""); 
                key = key.replace("\t", ""); 
                macros.remove(key);
            }
        } else if (ctx.UNDEFINEALL() != null) {
            if (!Skip()) {
                macros.clear();
            }
        }
    }

	@Override
    public void enterInclude(IEEE1800_2017PreprocessorParser.IncludeContext ctx) {
        if (Skip()) return;

        path_stack.push(current_path);
        line_stack.push(line_number);

        IEEE1800_2017PreprocessorParser.IncludeTextContext itc =
          (IEEE1800_2017PreprocessorParser.IncludeTextContext)ctx.include_text();
        List<TerminalNode> text = itc.TEXT();
        StringBuilder str = new StringBuilder();
        for (TerminalNode tn : text) {
            String temp = tn.getText().trim();
            if (temp.length() > 0) {
                str = str.append(temp);
            }
        }
        String temp = str.toString();
        if (temp.contains("`")) {
            StringBuilder inc = new StringBuilder();
            CharStream is = CharStreams.fromString(temp);
            IEEE1800_2017PreprocessorLexer lexer = new IEEE1800_2017PreprocessorLexer(is);
            List<? extends Token> tt = lexer.getAllTokens();
            LinkedList<Token> tokens = new LinkedList<Token>(tt);
            ListTokenSource lts = new ListTokenSource(tokens);
            CommonTokenStream ts = new CommonTokenStream(lts);
            IEEE1800_2017PreprocessorParser parser = new IEEE1800_2017PreprocessorParser(ts);
            ParseTree tree = parser.source_text();
            ParseTreeWalker walker = new ParseTreeWalker();
            IEEE1800_2017PreprocessorListener eval = new IEEE1800_2017PreprocessorListener(macros, inc, base_path);
            eval.recursion();
            walker.walk(eval, tree);
            temp = inc.toString().trim();
        }
        // Replace the delimiters
        if (temp.contains("\"")) {
            temp = temp.replaceAll("\"", "");
        }
        if (temp.contains("<")) {
            temp = temp.replaceAll("<", "");
        }
        if (temp.contains(">")) {
            temp = temp.replaceAll(">", "");
        }
        // Convert to absolute paths
        Path path = Paths.get(temp);
        if (!path.isAbsolute()) {
            if (base_path == null) {
                path = path.toAbsolutePath();
            } else {
                String path_string;
                if (recursion_level == 0) {
                    path_string = new String(base_path.getParent().toString() + "/" + path.toString());
                } else {
                    path_string = new String(base_path.getParent().toString() + "/" + path.toString());
                }
                path_string = path_string.replaceAll("\"", "");
                path = Paths.get(path_string).toAbsolutePath();
            }
        }
        // Recursion
        StringBuilder str2 = new StringBuilder();
        try {
            CharStream is = CharStreams.fromFileName(path.toString());
            IEEE1800_2017PreprocessorLexer lexer = new IEEE1800_2017PreprocessorLexer(is);
            lexer.setFilename(path.toString(), 1);
            List<? extends Token> tt = lexer.getAllTokens();
            LinkedList<Token> tokens = new LinkedList<Token>(tt);
            ListTokenSource lts = new ListTokenSource(tokens);
            CommonTokenStream ts = new CommonTokenStream(lts);
            IEEE1800_2017PreprocessorParser parser = new IEEE1800_2017PreprocessorParser(ts);
            ParseTree tree = parser.source_text();
            ParseTreeWalker walker = new ParseTreeWalker();
            IEEE1800_2017PreprocessorListener eval = new IEEE1800_2017PreprocessorListener(macros, str2, base_path);
            eval.recursion();
            walker.walk(eval, tree);
        } catch (Exception e) {
            System.err.println("ERROR processing " + path);
            e.printStackTrace();
        }
        return_string.append(str2);
        line_number += countLines(str2.toString());
    }

	@Override
    public void exitInclude(IEEE1800_2017PreprocessorParser.IncludeContext ctx) {
        if (Skip()) return;

        current_path = path_stack.pop();
        line_number = line_stack.pop();
        line_number++;
        return_string.append("`line ");
        return_string.append(line_number);
        return_string.append(" \"");
        return_string.append(current_path);
        return_string.append("\" 2\n");
    }

    public void recursion() {
        recursion_level++;
    }

    private int countLines(String str) {
        Matcher m = Pattern.compile("\r\n|\r|\n").matcher(str);
        int lines = 0;
        while (m.find()) {
            lines++;
        }
        return lines;
    }

    private boolean Skip() {
        return stack.contains(false);
    }
}
