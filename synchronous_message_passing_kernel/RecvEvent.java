//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

//Recv event keep potential receive channel reference
//Recv object once sync get called
public class RecvEvent extends CommEvent
{
    private Channel c;
    private ChannelObject co;
    private ReentrantLock lock;

    public RecvEvent(Channel c)
    {
        this.c = c;
        this.co = null;
        this.lock = c.getLock();
    }

    public Object sync() throws InterruptedException
    {
        Object o = null;
        lock.lock();
        try {
            co = poll();
            if (co == null) {
                co = enqueue();
                co.waitCom();
                return co.o;
            } else {
                return co.o;
            }

        }finally {
            lock.unlock();
        }
    }

    public ChannelObject poll() throws InterruptedException
    {
        return c.eventRecv();
    }

    //add object to the enqueue
    public ChannelObject enqueue() throws InterruptedException
    {
        co = new ChannelObject(lock.newCondition());
        return c.enqueueRecvQueue(co);
    }

    public Channel getChannel()
    {
       return c;
    }
}