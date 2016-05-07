//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
class Stage2Demo{
    Stage2Demo(){
    }

    public static void main(String[] args){
        int TEST_NUM = 5000;
        Channel ch = new Channel();
        System.out.println("Demo2: First test with 2 senders and 1 receiver");
        Stage2Demo.MyThread t1 = new Stage2Demo.MyThread(ch,0,TEST_NUM);
        Stage2Demo.MyThread t2 = new Stage2Demo.MyThread(ch,0,TEST_NUM);
        Stage2Demo.MyThread t3 = new Stage2Demo.MyThread(ch,1,TEST_NUM*2);

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

        System.out.println("Demo1: Second test with 1 sender and 2 receivers");
        Stage2Demo.MyThread t4 = new Stage2Demo.MyThread(ch,1,TEST_NUM);
        Stage2Demo.MyThread t5 = new Stage2Demo.MyThread(ch,1,TEST_NUM);
        Stage2Demo.MyThread t6 = new Stage2Demo.MyThread(ch,0,TEST_NUM * 2);

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
        System.out.println("Demo2: test2 done");
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
}