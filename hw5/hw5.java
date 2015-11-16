/* Name: Victor Frolov

   UID: 978687700

   Others With Whom I Discussed Things: Peyton

   Other Resources I Consulted: StackExchange for some errors I was getting
   
*/

import java.util.*;

interface AExp {
    Double eval(); 
    List<AInstr> compile();             
    List<String> compileToString();
}

class Num implements AExp {
    protected Double val;

    public Num(Double n) {
        this.val = n;
    }

    public Double eval() {
        return this.val;
    }

    public List<AInstr> compile() {
        List<AInstr> num = new LinkedList<AInstr>();
        num.add(new Push (val));
        return num;
    }

    public List<String> compileToString() {
        List<String> num = new LinkedList<String>();
        num.add("Push "+ val.toString());
        return num;
    }
}

class BinOp implements AExp {
    protected AExp left, right;
    protected Op op;

    public BinOp(AExp left, Op op, AExp right) {
        this.left = left;
        this.op = op;
        this.right = right;
    }

    public Double eval() {
        return op.calculate(left.eval(), right.eval());
    }

    public List<AInstr> compile() {
        List<AInstr> list = new LinkedList<AInstr>();
        
        if (this.left != null) {
            list.addAll(left.compile());
        }
        if (this.right != null) {
            list.addAll(right.compile());
        }
        
        list.add(new Calculate(op));
        
        return list;
    }

    
    public List<String> compileToString() {
        List<String> test = new LinkedList<String>();
        
        if (this.left != null) {
            test.addAll(this.left.compileToString());
        }
        if (this.right != null) {
            test.addAll(this.right.compileToString());
        }
        
        test.add("Calculate " + op.toString());
        return  test;
    }    
}

enum Op {
    PLUS { public Double calculate(Double a1, Double a2) { return a1 + a2; } },
    MINUS { public Double calculate(Double a1, Double a2) { return a1 - a2; } },
    TIMES { public Double calculate(Double a1, Double a2) { return a1 * a2; } },
    DIVIDE { public Double calculate(Double a1, Double a2) { return a1 / a2; } };

    abstract Double calculate(Double a1, Double a2);
}

interface AInstr {
    void eval(Stack<Double> stack);  
}

class Push implements AInstr {
    protected Double val;

    public Push(Double n) {
        this.val = n;
    }

    public void eval(Stack<Double> stack) {
        stack.push(val);
    }

}

class Calculate implements AInstr {
    protected Op op;
    
    public Calculate(Op o) {
        this.op = o;
    }

    public void eval(Stack<Double> stack) {
        Double d1 = stack.pop();
        Double d2 = stack.pop();
        Double result = op.calculate(d1, d2);
        stack.push(result);
    }
}

class Instrs {
    protected List<AInstr> instrs;

    public Instrs(List<AInstr> instrs) { 
        this.instrs = instrs; 
    }

    public Double eval() {
        Stack<Double> stackEvaluation = new Stack<Double>();
        
        for(AInstr instrs : instrs) {
            instrs.eval(stackEvaluation);
        }

        return stackEvaluation.pop();
    }
}


class CalcTest {
    public static void main(String[] args) {
        // Tests for Problem 1
        AExp aexp =
            new BinOp(new BinOp(new Num(1.0), Op.PLUS, new Num(2.0)),
            Op.TIMES,
            new Num(4.0));
        System.out.println("aexp evaluates to " + aexp.eval()  + " and expected 12.0"); // aexp evaluates to 12.0
        
        AExp aexp2 =
            new BinOp(new BinOp(new Num(100.0), Op.MINUS, new Num(80.0)),
            Op.TIMES,
            new Num(40.0));
        System.out.println("aexp evaluates to " + aexp2.eval() + " and expected 800.0"); // aexp evaluates to 800.0

        AExp aexp3 =
            new BinOp(new BinOp(new Num(4.0), Op.TIMES, new Num(4.0)),
            Op.TIMES,
            new Num(4.0));
        System.out.println("aexp evaluates to " + aexp3.eval() + " and expected 64.0"); // aexp evaluates to 64.0        

        // Tests for Problem 2
        List<AInstr> is = new LinkedList<AInstr>();
        is.add(new Push(1.0));
        is.add(new Push(2.0));
        is.add(new Calculate(Op.PLUS));
        is.add(new Push(4.0));
        is.add(new Calculate(Op.TIMES));
        Instrs instrs = new Instrs(is);
        System.out.println("instrs evaluates to " + instrs.eval());  // instrs evaluates to 12.0

        List<AInstr> is2 = new LinkedList<AInstr>();
        is2.add(new Push(100.0));
        is2.add(new Push(40.0));
        is2.add(new Calculate(Op.MINUS));
        is2.add(new Push(4.0));
        is2.add(new Calculate(Op.TIMES));
        Instrs instrs2 = new Instrs(is2);
        System.out.println("instrs evaluates to " + instrs2.eval() + " and expected -240.0");

        // Tests for Problem 3
        System.out.println("aexp converts to " + aexp.compile());
        System.out.println("aexp converts to " + aexp.compileToString());
        System.out.println("aexp2 converts to " + aexp2.compile());
        System.out.println("aexp2 converts to " + aexp2.compileToString());
        System.out.println("aexp3 converts to " + aexp3.compile());
        System.out.println("aexp3 converts to " + aexp3.compileToString());

    }
}