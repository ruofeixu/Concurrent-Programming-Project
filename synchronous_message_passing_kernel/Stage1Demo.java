import java.util.*;

class Stage1Demo{
    Stage1Demo(){
        }

    public static void main(String[] args){
        int TEST_NUM = 10;
        Channel ch = new Channel();

        System.out.println("Demo1: First test with 2 senders and 1 receiver");
        Stage1Demo.MyThread t1 = new Stage1Demo.MyThread(ch,0,TEST_NUM);
        //Stage1Demo.MyThread t2 = new Stage1Demo.MyThread(ch,0,TEST_NUM);
        Stage1Demo.MyThread t3 = new Stage1Demo.MyThread(ch,1,TEST_NUM);

        t1.start();
        //t2.start();
        t3.start();

        System.out.println("Demo1: test1 Done");

        /*
        System.out.println("Demo1: Second test with 1 sender and 2 receivers");
        Stage1Demo.MyThread t4 = new Stage1Demo.MyThread(ch,1,TEST_NUM);
        Stage1Demo.MyThread t5 = new Stage1Demo.MyThread(ch,1,TEST_NUM);
        Stage1Demo.MyThread t6 = new Stage1Demo.MyThread(ch,0,TEST_NUM);

        t4.start();
        t5.start();
        t6.start();
        System.out.println("Demo1: test2 Done");
        */
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
                        Object res = ch.Send(i);
                        System.out.println("*Send" + res.toString());
                    }
                    else{
                        Object res = ch.Recv();
                        if(res == null)
                            System.out.println("*Recv null");

                        System.out.println("*Recv" + res.toString());
                    }
                }
            } catch (InterruptedException ie)
            {
                System.out.println("Error");
            }
        }
    }
}