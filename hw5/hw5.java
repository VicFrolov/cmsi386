/* Name:

   UID:

   Others With Whom I Discussed Things:

   Other Resources I Consulted:
   
*/

// import lists and other data structures from the Java standard library
// DO NOT IMPORT ANYTHING ELSE
import java.util.*;


     
// a type for arithmetic expressions
interface AExp {
    Double eval();                         // Problem 1
    // List<AInstr> compile();                 // Problem 3
}



class Num implements AExp {
    protected Double val;

    public Num(Double n) {
      this.val = n;
    }

    public Double eval() {
     return this.val;
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
}

// a representation of four arithmetic operators
enum Op {
    PLUS { public Double calculate(Double a1, Double a2) { return a1 + a2; } },
    MINUS { public Double calculate(Double a1, Double a2) { return a1 - a2; } },
    TIMES { public Double calculate(Double a1, Double a2) { return a1 * a2; } },
    DIVIDE { public Double calculate(Double a1, Double a2) { return a1 / a2; } };

    abstract Double calculate(Double a1, Double a2);
}

// a type for arithmetic instructions
interface AInstr {
    // void eval(Stack<Double> stack);    // Problem 2
}

class Push implements AInstr {
    protected Double val;
}

class Calculate implements AInstr {
    protected Op op;
}

class Instrs {
    protected List<AInstr> instrs;

    public Instrs(List<AInstr> instrs) { this.instrs = instrs; }

    // public Double eval() {}  // Problem 2
}


class CalcTest {
    public static void main(String[] args) {
      // a test for Problem 1
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

  // a test for Problem 2
  // List<AInstr> is = new LinkedList<AInstr>();
  // is.add(new Push(1.0));
  // is.add(new Push(2.0));
  // is.add(new Calculate(Op.PLUS));
  // is.add(new Push(4.0));
  // is.add(new Calculate(Op.TIMES));
  // Instrs instrs = new Instrs(is);
  // System.out.println("instrs evaluates to " + instrs.eval());  // instrs evaluates to 12.0

  // a test for Problem 3
  // System.out.println("aexp converts to " + aexp.compile());

    }
}