public abstract class CommEvent
{
    public abstract Object sync() throws InterruptedException;
    public abstract Object poll() throws InterruptedException;
    public abstract ChannelObject enqueue() throws InterruptedException;
    public abstract Channel getChannel() throws InterruptedException;
}


