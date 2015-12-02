// Name: Victor Frolov

import java.util.concurrent.*;
    
class NoMoreRoomException extends Exception {}

class FastDivideFilter extends DivideFilter {
    FastDivideFilter(int capacity) {
        super(capacity);
    }

    boolean anyEvenlyDivides(Integer i) {
        double inputNb = Math.sqrt(i);
        try {
            for (Integer value : this.storedDivisors) {
                if (value > inputNb) {
                    return false;
                }
                if (i % value == 0) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
}

class DivideFilter {
    protected int totalDivisors;
    protected Integer[] storedDivisors;

    
    DivideFilter(int capacity) {
        this.storedDivisors = new Integer[capacity];
        this.totalDivisors = 0;
    }

    boolean anyEvenlyDivides(Integer i) {
        try {
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
        return (this.storedDivisors.length == this.totalDivisors) ? true : false;
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
    private Integer max;
    private BlockingQueue<Integer> output;

    Generator(Integer max, BlockingQueue<Integer> output) {
        this.max = max;
        this.output = output;
    }

    public void run() {
        for (int i = 2; i < this.max; i++) {
            Helpers.put(output, i);          
        }
        Helpers.put(output, -1);
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
    private BlockingQueue<Integer> input;

    Printer(BlockingQueue<Integer> input) {
        this.input = input;
    }

    public void run() {
        while(true) {
            int currentValue = Helpers.take(input);
            if (currentValue == -1) {
                return;
            } else {
                System.out.println(currentValue);
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
    private FastDivideFilter filter;
    public BlockingQueue<Integer> input, output;
    private Integer filterSize, queueSize;

    Sieve(BlockingQueue<Integer> input,
      BlockingQueue<Integer> output,
      Integer filterSize,
      Integer queueSize) {

        this.input = input;
        this.output = output;
        this.filterSize = filterSize;
        this.queueSize = queueSize;
        this.filter = new FastDivideFilter(filterSize);
    }

    public void run() {
        int timeToStop = -1;

        while(true) {
            int currentNumber = Helpers.take(input);
            if (currentNumber == timeToStop) {
                Helpers.put(output, currentNumber);
                return;
            } else if (!filter.anyEvenlyDivides(currentNumber)) {
                Helpers.put(output, currentNumber);
                if (!filter.full()) {
                    try {
                        filter.addDivisor(new Integer(currentNumber));
                    } catch(NoMoreRoomException e) {

                    }
                    if(filter.full()) {
                        BlockingQueue<Integer> newOutput = new ArrayBlockingQueue<Integer>(queueSize);
                        ArrayBlockingQueue<Integer> reconfiguredOutput = new ArrayBlockingQueue<Integer>(queueSize);
                        newOutput = this.output;
                        this.output = reconfiguredOutput;
                        Sieve s = new Sieve(reconfiguredOutput,newOutput,filterSize, queueSize);
                        new Thread(s).start();
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
        tester.test2(20);
        tester.test2(5);
        tester.test3(20);
        tester.test3(5);
        tester.test3(2);

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

    void test2(Integer filterSize) {
        BlockingQueue<Integer> input = new ArrayBlockingQueue<Integer>(10);
        BlockingQueue<Integer> output = new ArrayBlockingQueue<Integer>(10);

        Sieve sieve = new Sieve(input, output, filterSize, 10);
        Thread t2 = new Thread(sieve);
        t2.start();

        for(int i = 2; i < 25; i++) {
            Helpers.put(input, i);
        }

        Helpers.put(input, -1);
        assert(Helpers.take(output) == 2);
        assert(Helpers.take(output) == 3);
        assert(Helpers.take(output) == 5);
        assert(Helpers.take(output) == 7);
        assert(Helpers.take(output) == 11);
        assert(Helpers.take(output) == 13);
        assert(Helpers.take(output) == 17);
        assert(Helpers.take(output) == 19);
        assert(Helpers.take(output) == 23);
        assert(Helpers.take(output) == -1);
        Helpers.join(t2);
        assert(input.isEmpty());
        assert(output.isEmpty());

    }
    void test3
    (Integer filterSize) {
        BlockingQueue<Integer> input = new ArrayBlockingQueue<Integer>(10);
        BlockingQueue<Integer> output = new ArrayBlockingQueue<Integer>(10);

        Sieve sieve = new Sieve(input, output, filterSize, 10);
        Thread t = new Thread(sieve);
        t.start();

        for(int i = 2; i < 5; i++) {
            Helpers.put(input, i);
        }

        Helpers.put(input, -1);
        assert(Helpers.take(output) == 2);
        assert(Helpers.take(output) == 3);
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
        BlockingQueue<Integer> input = new ArrayBlockingQueue<Integer>(queueSize);
        BlockingQueue<Integer> output = new ArrayBlockingQueue<Integer>(queueSize);
        
        Generator gen = new Generator(max, input);
        Thread genThread = new Thread(gen);
        genThread.start();

        Sieve sieve = new Sieve(input, output, filterSize, queueSize);
        Thread sieveThread = new Thread(sieve);
        sieveThread.start();

        Printer print = new Printer(output);
        Thread printThread = new Thread(print);
        printThread.start();
        
        Helpers.join(genThread);
        Helpers.join(sieveThread);
        Helpers.join(printThread);

        long tEnd = System.currentTimeMillis();
        long tDiff = tEnd - tStart;
        System.out.format("Run time: %d minutes, %.2f seconds%n", tDiff/60000, (tDiff % 60000) / 1000.0);
    }
}



/*
 * 1) How many CPUs cores does your machine have?
My machine has 8 cores

 * 2) What is the run time for each of:
 *      java HW6 10000 1 1
 Runtime: 5.81 seconds

 *      java HW6 10000 1 10
 Runtime: 0.89 seconds

 *      java HW6 10000 10 1
 Runtime: 0.34

 *      java HW6 10000 10 10
 Runtime: 0.18

 *    What conclusions can you make from these times?
 
 Queue size has an incredible effect on the speed, making it process 17 times faster by increasing the queue size tenfold. Filtersize also matters of course, and also greatly 
 increases speed, but queue is still of more importance. Increasing both makes the process of finding primes up to 10,0000 go from 5.81 seconds to 0.18 seconds,
 incredibly more efficient.

 * 3) Use a system monitor (e.g. Task Manager on Windows, Activity 
 *    Monitor on Mac, top on linux or Mac) to observe your CPU
 *    utilization for each of:
 *      java HW6 100000 10 10
 *      java HW6 100000 10000 10
 *    What conclusions can you make from these observations?

With a blockingqueue of size 10,000, the CPU load is far less than with blockingqueues of size 10. There were giant spikes in activity, presumably because many queues had to be created.
The system load peaked greatly with size 10, whereas the peak for 10,000, although much smaller than with size 10, was mostly user based.

 * 4) Try a few different values of <filterSize> and <queueSize>
 *    and see which produce the lowest run time for: 
 *      java HW6 10000000 <filterSize> <queueSize>
 *    List the run times for each pair of values you tried.
 
java HW6 10000000 10000000 10000000 took 19 minutes, 14.00 seconds. CPU load was relatively low.
java HW6 10000000 10000 10000 took  2 minutes, 58.40 seconds, CPU load was insanely high, computer was lagging, CPU usage was at 90%.
java HW6 10000000 1000 1000 took 3 minutes, 7.96 seconds, CPU load was insanely high, at 96.39%.
java HW6 10000000 100000 10000000 took 4 minutes, 30.64 seconds.
java HW6 10000000 10000 10000000 took 3 minutes, 6.97 seconds


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
 
java HW6 10000000 10000000 10000000 took 0 minutes, 6.39 seconds
java HW6 10000000 10000 10000 strangely took longer (especially when in the previous question it was way faster) at  0 minutes, 8.21 seconds
java HW6 10000000 1000 1000 took 0 minutes, 27.40 seconds
java HW6 10000000 100000 10000000 took 0 minutes, 7.39 seconds
java HW6 10000000 10000 10000000 0 minutes, 18.32 seconds

*/





