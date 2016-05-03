import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

public class RecvEvent extends CommEvent
{
    private Channel c;
    public RecvEvent(Channel c)
    {
        this.c = c;
    }

    public Object sync() throws InterruptedException
    {
        ChannelObject co;
        Object o = poll();
        if(o == null)
        {
            ReentrantLock lock = c.getLock();
            co = enqueue();
            co.c = lock.newCondition();
            co.waitCom();
        }
        else
        {
            return o;
        }
        return poll();
    }

    //private ?
    public Object poll() throws InterruptedException
    {
        return c.eventRecv();
    }

    public ChannelObject enqueue() throws InterruptedException
    {
        return c.enqueueRecvQueue();
    }

    public Channel getChannel()
    {
       return c;
    }
}