//import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.*;
import java.util.concurrent.*;

public class Channel {
    //private final SynchronousQueue<ChannelObject> sendQueue;
    //private final SynchronousQueue<ChannelObject> receiveQueue;
    private  final ConcurrentLinkedQueue<ChannelObject> sendQueue;
    private  final ConcurrentLinkedQueue<ChannelObject> receiveQueue;
    private final ReentrantLock lock;
    public Channel()
    {
        lock = new ReentrantLock();
        //sendQueue = new SynchronousQueue<ChannelObject>();
        //receiveQueue = new SynchronousQueue<ChannelObject>();
        sendQueue = new ConcurrentLinkedQueue<ChannelObject>();
        receiveQueue = new ConcurrentLinkedQueue<ChannelObject>();
    }

    public Channel(ReentrantLock lock)
    {
        this.lock = lock;
        //sendQueue = new SynchronousQueue<ChannelObject>();
        //receiveQueue = new SynchronousQueue<ChannelObject>();
        sendQueue = new ConcurrentLinkedQueue<ChannelObject>();
        receiveQueue = new ConcurrentLinkedQueue<ChannelObject>();
    }

    public ReentrantLock getLock()
    {
        return lock;
    }

    public Object Send(Object o) throws InterruptedException
    {
        lock.lock();
        try {
            if(receiveQueue.isEmpty()){
                ChannelObject co = new ChannelObject(lock.newCondition());
                co.o = o;
                sendQueue.add(co);
                co.waitCom();
            }
            else {
                ChannelObject co = receiveQueue.poll();
                co.o = o;
                sendQueue.add(co);
                co.getCondition().signal();
            }
            return o;
        }finally {
            lock.unlock();
        }
    }

    public Object Recv() throws InterruptedException
    {
        Object o = null;
        lock.lock();
        try {
            if(sendQueue.isEmpty()){
                ChannelObject co = new ChannelObject(lock.newCondition());
                receiveQueue.add(co);
                co.waitCom();
            }
            ChannelObject co = sendQueue.poll();
            o = co.o;
            co.getCondition().signal();
            return o;
        }finally {
            lock.unlock();
        }
    }

    public Object eventSend(Object o) throws InterruptedException
    {
        lock.lock();
        try{
            if(receiveQueue.isEmpty())
                return null;
            return Send(o);
        }finally {
            lock.unlock();
        }
    }

    public Object eventRecv() throws InterruptedException
    {
        lock.lock();
        try{
            if(sendQueue.isEmpty())
                return null;
            return Recv();
        }finally {
            lock.unlock();
        }
    }

    public ChannelObject enqueueSendQueue(Object o) throws InterruptedException
    {
        lock.lock();
        try{
            ChannelObject co = new ChannelObject();
            sendQueue.add(co);
            return co;
        }finally {
            lock.unlock();
        }
    }

    public ChannelObject enqueueRecvQueue() throws InterruptedException
    {
        lock.lock();
        try {
            ChannelObject co = new ChannelObject();
            receiveQueue.add(co);
            return co;
        }finally {
            lock.unlock();
        }
    }

    public void removeObject(ChannelObject co)
    {
        lock.lock();
        try {
            sendQueue.remove(co);
            receiveQueue.remove(co);
        }finally {
            lock.unlock();
        }
    }
}