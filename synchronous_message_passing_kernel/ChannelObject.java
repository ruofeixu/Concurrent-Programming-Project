//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

//this class is a container for channel communication
public class ChannelObject
{
    public volatile Object o; //transfer object
    public volatile Condition c; //lock condition for await and signal

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

    public void wakeUp()
    {
        c.signal();
    }

    public void waitCom() throws InterruptedException
    {
            c.await();
    }
}