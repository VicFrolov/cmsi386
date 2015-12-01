import java.util.concurrent.*;
    
class NoMoreRoomException extends Exception {}

class DivideFilter {
    int capacity;
    int totalDivisors;
    Integer[] storedDivisors;

    
    DivideFilter(int capacity) {
        this.capacity = capacity;
        this.storedDivisors = new Integer[capacity];
        this.totalDivisors = 0;
    }

    boolean anyEvenlyDivides(Integer i) {
        try {
            if (this.totalDivisors == 0) {
                return false;
            }
            for (Integer value : this.storedDivisors) {
                if (i % value == 0) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }

    void addDivisor(Integer i) throws NoMoreRoomException {
        if (this.totalDivisors == this.storedDivisors.length) {
            throw new NoMoreRoomException();
        } else {
            this.storedDivisors[this.totalDivisors] = i;
            this.totalDivisors++;
        }
    }

    boolean full() {
        return (this.capacity == this.totalDivisors) ? true : false;
    }
}

class TestDivideFilter {
    public static void main(String[] args) {
        TestDivideFilter tester = new TestDivideFilter();
        tester.test1();
        tester.test2();
    }

    void test1() {
        DivideFilter filter = new DivideFilter(1);
        assert(filter.anyEvenlyDivides(125) == false);

        try {
            filter.addDivisor(5);
            assert(filter.anyEvenlyDivides(125) == true);
        } catch(NoMoreRoomException e) {
            assert(false); 
        }

        assert(filter.full());

        try {
            filter.addDivisor(7);
            assert(false);
        } catch (NoMoreRoomException e) {

        }
    }

    void test2() {
        DivideFilter filter2 = new DivideFilter(2);
        assert(filter2.anyEvenlyDivides(0) == false);

        try {
            filter2.addDivisor(2);
            filter2.addDivisor(3);
            assert(filter2.anyEvenlyDivides(12));
        } catch(NoMoreRoomException e) {
            assert(false);
        }

        assert(filter2.full());

        try {
            filter2.addDivisor(100);
            assert(false);
        } catch(NoMoreRoomException e) {

        }

    }

}

class Helpers {    
    public static <E> void put(BlockingQueue<E> queue, E elem) {
        while(true) {
            try {
                queue.put(elem);
                return;
            } catch(InterruptedException e) {

            }
        }
    }
    
    public static <E> E take(BlockingQueue<E> queue) {
        while(true) {
            try {
                return queue.take();
            } catch(InterruptedException e) {

            }
        }
    }

    public static void join(Thread t) {
        while(true) {
            try {
                t.join();
                return;
            } catch(InterruptedException e) {

            }
        }
    }
}

class Generator implements Runnable {
    Integer max;
    BlockingQueue<Integer> output;

    Generator(Integer max, BlockingQueue<Integer> output) {
        this.max = max;
        this.output = output;
    }

    public void run() {
        for (int i = 2; i < this.max; i++) {
            try {
                this.output.put(i);
            } catch(InterruptedException e) {
        
            }            
        }

        try {
            this.output.put(-1);            
        } catch (InterruptedException e) {

        }
        return;
    }
}

class TestGenerator {
    public static void main(String[] args) {
        BlockingQueue<Integer> queue = new ArrayBlockingQueue<Integer>(5);
        Generator gen = new Generator(100, queue);


        Thread t = new Thread(gen);
        t.start();
        
        for (int i = 2; i < 100; i++) {
            assert(Helpers.take(queue) == i);
        }


        Helpers.join(t);

        assert(Helpers.take(queue) == -1);
        assert(queue.isEmpty());
    }
}

class Printer implements Runnable {
    BlockingQueue<Integer> input;

    Printer(BlockingQueue<Integer> input) {
        this.input = input;
    }

    public void run() {
        for (Integer i : input) {
            if (i == -1) {
                return;
            } else {
                System.out.println(Helpers.take(input));
            }
        }
    }
}

class TestPrinter {
    public static void main(String[] args){
        BlockingQueue<Integer> queue = new ArrayBlockingQueue<Integer>(11);
        Printer printer = new Printer(queue);
        Generator gen = new Generator(11, queue);
        gen.run();
        printer.run();
        assert(Helpers.take(queue) == -1);
        assert(queue.isEmpty());
    }
}


class Sieve implements Runnable {
    DivideFilter filter;
    BlockingQueue<Integer> input, output;
    Integer filterSize, queueSize;

    Sieve(BlockingQueue<Integer> input,
      BlockingQueue<Integer> output,
      Integer filterSize,
      Integer queueSize) {

        this.input = input;
        this.output = output;
        this.filterSize = filterSize;
        this.queueSize = queueSize;
        this.filter = new DivideFilter(filterSize);
    }

    public void run() {
        int timeToStop = -1;
        while(true) {
            for (Integer i : input) {
                int currentNumber = Helpers.take(input);
                if (i == timeToStop) {
                    Helpers.put(output, currentNumber);
                    return;
                } else if (!filter.anyEvenlyDivides(i)) {
                    Helpers.put(output, currentNumber);
                    if (!filter.full()) {
                        try {
                            filter.addDivisor(new Integer(i));
                        } catch(NoMoreRoomException e) {
                            e.getMessage();
                        }
                    } else {
                        BlockingQueue<Integer> newOutput = new ArrayBlockingQueue<Integer>(queueSize);
                        Sieve newSieve = new Sieve(output,newOutput,filterSize, queueSize);
                        Thread t = new Thread(newSieve);
                        t.start();
                        t.stop();

                    }
                }
            }
        }
    }
}

// $ java -ea TestSieve
class TestSieve {
    public static void main(String[] args) {
    TestSieve tester = new TestSieve();
    tester.test(20);
    tester.test(5);

    }

    void test(Integer filterSize) {
        BlockingQueue<Integer> input = new ArrayBlockingQueue<Integer>(10);
        BlockingQueue<Integer> output = new ArrayBlockingQueue<Integer>(10);

        Sieve sieve = new Sieve(input, output, filterSize, 10);
        Thread t = new Thread(sieve);
        t.start();

        for(int i = 2; i < 15; i++) {
            Helpers.put(input, i);
        }

        Helpers.put(input, -1);
        assert(Helpers.take(output) == 2);
        assert(Helpers.take(output) == 3);
        assert(Helpers.take(output) == 5);
        assert(Helpers.take(output) == 7);
        assert(Helpers.take(output) == 11);
        assert(Helpers.take(output) == 13);
        assert(Helpers.take(output) == -1);

        Helpers.join(t);


        assert(input.isEmpty());
        assert(output.isEmpty());

    }
}

class HW6 {
    public static void main(String[] args) {
    Integer max = Integer.parseInt(args[0]);
    Integer filterSize = Integer.parseInt(args[1]);
    Integer queueSize = Integer.parseInt(args[2]);

    long tStart = System.currentTimeMillis();
    
    // TODO: Construct and start a pipeline containing the
    // generator, a single sieve, and a printer.
    long tEnd = System.currentTimeMillis();

    long tDiff = tEnd - tStart;
    System.out.format("Run time: %d minutes, %.2f seconds%n", tDiff/60000, (tDiff % 60000) / 1000.0);
    }
}

/* Part 4: Experiments
 *
 * For this part, make sure to run on a multi-core machine. 
 *
 * 1) How many CPUs cores does your machine have?
 * 
 * 2) What is the run time for each of:
 *      java HW6 10000 1 1
 *      java HW6 10000 1 10
 *      java HW6 10000 10 1
 *      java HW6 10000 10 10
 *    What conclusions can you make from these times?
 * 
 * 3) Use a system monitor (e.g. Task Manager on Windows, Activity 
 *    Monitor on Mac, top on linux or Mac) to observe your CPU
 *    utilization for each of:
 *      java HW6 100000 10 10
 *      java HW6 100000 10000 10
 *    What conclusions can you make from these observations?
 *
 * 4) Try a few different values of <filterSize> and <queueSize>
 *    and see which produce the lowest run time for: 
 *      java HW6 10000000 <filterSize> <queueSize>
 *    List the run times for each pair of values you tried.
 */

/* Part 5: Extra Credit
 *
 * Define a FastDivideFilter class that extends DivideFilter and
 * overrides its anyEvenlyDivides method. For each input number, only
 * test divisibility of primes less than its square root (use
 * Math.sqrt()). Hint: it will help if the primes are stored in
 * increasing order in the FastDivideFilter. List the run time of each
 * pair of <filterSize> and <queueSize> used in experiment #4 with
 * this optimization.
 */