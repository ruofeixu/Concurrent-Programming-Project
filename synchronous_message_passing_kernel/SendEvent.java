//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.Semaphore;

//Send event keep potential send object and channel reference
//Send object once sync get called
public class SendEvent extends CommEvent
{
    private Channel c;
    private Object o;
    private ChannelObject co;
    private ReentrantLock lock;

    public SendEvent(Object o, Channel c)
    {
        this.o = o;
        this.c = c;
        this.co = null;
        this.lock = c.getLock();
    }


    //send object
    public synchronized Object sync() throws InterruptedException
    {
        lock.lock();
        try {
            co = poll(); //try to send object
            if (co == null) { //if failed
                co = enqueue(); //add object to the queue
                co.waitCom(); //wait receiver
            } else {
                return co.o;
            }
            return o;
        }finally {
            lock.unlock();
        }
    }

    public ChannelObject poll() throws InterruptedException
    {
        co = c.eventSend(o);
        return co;
    }

    //add object to the enqueue
    public ChannelObject enqueue() throws InterruptedException
    {
        co = new ChannelObject(lock.newCondition());
        co.o = o;
        return c.enqueueSendQueue(co);
    }

    public Channel getChannel()
    {
        return c;
    }
}