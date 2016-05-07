//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
class Stage1Demo{
    Stage1Demo(){
        }

    public static void main(String[] args){
        int TEST_NUM = 5000;
        Channel ch = new Channel();
        System.out.println("Demo1: First test with 2 senders and 1 receiver");
        Stage1Demo.MyThread t1 = new Stage1Demo.MyThread(ch,0,TEST_NUM);
        Stage1Demo.MyThread t2 = new Stage1Demo.MyThread(ch,0,TEST_NUM);
        Stage1Demo.MyThread t3 = new Stage1Demo.MyThread(ch,1,TEST_NUM*2);

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
        ch = new Channel();

        System.out.println("Demo1: Second test with 1 sender and 2 receivers");
        Stage1Demo.MyThread t4 = new Stage1Demo.MyThread(ch,1,TEST_NUM);
        Stage1Demo.MyThread t5 = new Stage1Demo.MyThread(ch,1,TEST_NUM);
        Stage1Demo.MyThread t6 = new Stage1Demo.MyThread(ch,0,TEST_NUM * 2);

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
        System.out.println("Demo1: test2 done");
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
                        Object res = ch.Send(i);
                        System.out.println("Thread " + Thread.currentThread().getId() +" *Send finish sent:" + res.toString());
                    }
                    else{
                        System.out.println("Thread " + Thread.currentThread().getId() + " *Recv");
                        Object res = ch.Recv();
                        System.out.println("Thread " + Thread.currentThread().getId() + " *Recv finish get:" + res.toString());
                    }
                }
            } catch (InterruptedException ie)
            {
                System.out.println("Error");
            }
        }
    }
}