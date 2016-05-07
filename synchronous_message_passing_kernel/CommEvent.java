//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
public abstract class CommEvent
{
    public abstract Object sync() throws InterruptedException;
    public abstract ChannelObject poll() throws InterruptedException;
    public abstract ChannelObject enqueue() throws InterruptedException;
    public abstract Channel getChannel() throws InterruptedException;
}


