import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

public class ChannelObject
{
    public Object o;
    public Condition c;

    public ChannelObject()
    {
        this.c = null;
        this.o = null;
    }

    public ChannelObject(Condition c)
    {
        this.c = c;
        this.o = null;
    }

    public Condition getCondition()
    {
        return c;
    }

    public void waitCom() throws InterruptedException
    {
        c.await();
    }
}