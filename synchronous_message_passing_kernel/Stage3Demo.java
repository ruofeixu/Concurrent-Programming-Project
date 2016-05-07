//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.concurrent.locks.ReentrantLock;
class Stage3Demo{
    Stage3Demo(){
    }

    public static void main(String[] args){
        int TEST_NUM = 5000;
        ReentrantLock lock =  new ReentrantLock();
        Channel ch1 = new Channel(lock);
        Channel ch2 = new Channel(lock);
        SelectionList sl = new SelectionList();
        sl.addEvent(new RecvEvent(ch1));
        sl.addEvent(new RecvEvent(ch2));
        System.out.println("Demo3: First test with 2 sender events and 2 receiver events in SelectionList");
        Stage3Demo.MyThread t1 = new Stage3Demo.MyThread(ch1,0,TEST_NUM);
        Stage3Demo.MyThread t2 = new Stage3Demo.MyThread(ch2,0,TEST_NUM);
        Stage3Demo.MySelectThread t3 = new Stage3Demo.MySelectThread(sl,TEST_NUM*2);

        t1.start();
        t2.start();
        t3.start();

        try {
            t1.join();
            t2.join();
            t3.join();
            System.out.println("Demo1: test1 done");
            Thread.sleep(1000);
        }catch (InterruptedException ie)
        {

        }

        ReentrantLock lock2 =  new ReentrantLock();
        Channel ch3 = new Channel(lock2);
        Channel ch4 = new Channel(lock2);
        SelectionList sl2 = new SelectionList();
        sl2.addEvent(new SendEvent(1,ch3));
        sl2.addEvent(new SendEvent(2,ch4));
        System.out.println("Demo3: Second test with 2 sender events in Selection list and 2 receiver events");
        Stage3Demo.MyThread t4 = new Stage3Demo.MyThread(ch3,1,TEST_NUM);
        Stage3Demo.MyThread t5 = new Stage3Demo.MyThread(ch4,1,TEST_NUM);
        Stage3Demo.MySelectThread t6 = new Stage3Demo.MySelectThread(sl2, TEST_NUM * 2);

        t4.start();
        t5.start();
        t6.start();

        try {
            t4.join();
            t5.join();
            t6.join();
        }catch (InterruptedException ie)
        {

        }
        System.out.println("Demo3: test2 done");
    }

    static class MyThread extends Thread{
        Channel ch;
        int type; //0 sender, 1 receiver
        int messagesNum;

        MyThread(Channel ch, int type, int num)
        {
            this.ch = ch;
            this.type = type;
            this.messagesNum = num;
        }

        public void run() {
            try{
                for(int i = 0; i < messagesNum; i++)
                {
                    if(type == 0) {
                        System.out.println("Thread " + Thread.currentThread().getId() + " *Send " + i);
                        SendEvent se = new SendEvent(i,ch);
                        Object res = se.sync();
                        System.out.println("Thread " + Thread.currentThread().getId() +" *Send finish sent:" + res.toString());
                    }
                    else{
                        System.out.println("Thread " + Thread.currentThread().getId() + " *Recv");
                        RecvEvent re = new RecvEvent(ch);
                        Object res = re.sync();
                        System.out.println("Thread " + Thread.currentThread().getId() + " *Recv finish get:" + res.toString());
                    }
                }
            } catch (InterruptedException ie)
            {
                System.out.println("Error");
            }
        }
    }

    static class MySelectThread extends Thread{
        SelectionList sl;
        int messagesNum;

        MySelectThread(SelectionList sl, int num)
        {
            this.sl = sl;
            this.messagesNum = num;
            Thread.currentThread().setPriority(Thread.MAX_PRIORITY);
        }

        public void run() {
            try{
                for(int i = 0; i < messagesNum; i++)
                {
                    System.out.println("Thread " + Thread.currentThread().getId() + " *Select " + i);
                    Object res = sl.select();
                    System.out.println("Thread " + Thread.currentThread().getId() +" *Select finish get:" + res.toString());
                }
            } catch (InterruptedException ie)
            {
                System.out.println("Error");
            }
        }
    }

}