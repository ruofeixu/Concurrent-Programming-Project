import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

public class SendEvent extends CommEvent
{
    private Channel c;
    private Object o;
    public SendEvent(Object o, Channel c)
    {
        this.o = o;
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

    public Object poll() throws InterruptedException
    {
        return c.eventSend(o);
    }

    public ChannelObject enqueue() throws InterruptedException
    {
        return c.enqueueSendQueue(o);
    }

    public Channel getChannel()
    {
        return c;
    }
}