//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.*;
import java.util.concurrent.*;


//essential class for this project
//sender and receiver communicate through a channel

public class Channel {

    private  final ConcurrentLinkedQueue<ChannelObject> sendQueue;
    private  final ConcurrentLinkedQueue<ChannelObject> receiveQueue;
    private final ReentrantLock lock;

    public Channel()
    {
        lock = new ReentrantLock();
        sendQueue = new ConcurrentLinkedQueue<ChannelObject>();
        receiveQueue = new ConcurrentLinkedQueue<ChannelObject>();
    }

    public Channel(ReentrantLock lock)
    {
        this.lock = lock;
        sendQueue = new ConcurrentLinkedQueue<ChannelObject>();
        receiveQueue = new ConcurrentLinkedQueue<ChannelObject>();
    }

    public ReentrantLock getLock()
    {
        return lock;
    }

    //Send an object to receiver if no receiver on the receive Queue put the object to send Queue
    public Object Send(Object o) throws InterruptedException
    {
        ChannelObject co = null;
        lock.lock();
        try {
            if(receiveQueue.isEmpty()){
                co = new ChannelObject(lock.newCondition());
                co.o = o;
                sendQueue.add(co); //add the object to the sendqueue
                co.waitCom(); //wait until a receiver signal it
            }
            else {
                co = receiveQueue.poll();
                co.o = o;
                co.getCondition().signal(); //signal the receiver polling from receivequeue
            }
            return o;
        }finally {
            lock.unlock();
        }
    }

    public Object Recv() throws InterruptedException
    {
        Object o = null;
        ChannelObject co = null;
        lock.lock();
        try {
            if (sendQueue.isEmpty()){
                co = new ChannelObject(lock.newCondition());
                receiveQueue.add(co); //add a Channel object to receive queue
                co.waitCom(); // wait sender send an object to the channel object and signal it
                o = co.o; //get an object from sender
            }
            else {
                co = sendQueue.poll();
                o = co.o;
                co.getCondition().signal();
            }
            return o;
        }finally {
            lock.unlock();
        }
    }

    //this method for event syc and selection list select
    public ChannelObject eventSend(Object o) throws InterruptedException
    {
        ChannelObject co;
        if(receiveQueue.isEmpty())
            return null;
        co = receiveQueue.peek();
        if(!lock.hasWaiters(co.getCondition())) //if no one wait for signal then stop polling that avoid double polling
            return null;
        co = receiveQueue.poll(); //poll channel object from queue
        co.o = o; //assign object to the channel object
        co.getCondition().signal();
        return co;
    }

    //this method for event syc and selection list select
    public ChannelObject eventRecv() throws InterruptedException
    {
        ChannelObject co;
        Object o;
        if(sendQueue.isEmpty())
            return null;
        co = sendQueue.peek();
        if(!lock.hasWaiters(co.getCondition())) //if no one wait for signal then stop polling that avoid double polling
            return null;
        co = sendQueue.poll();
        o = co.o; //get object from channel object
        co.getCondition().signal();
        return co;
    }

    public  ChannelObject enqueueSendQueue(ChannelObject co) throws InterruptedException
    {
        sendQueue.add(co);
        return co;
    }

    public ChannelObject enqueueRecvQueue(ChannelObject co) throws InterruptedException
    {
        receiveQueue.add(co);
        return co;
    }

    public boolean removeObject(ChannelObject co)
    {
        boolean r1 = sendQueue.remove(co);
        boolean r2 = receiveQueue.remove(co);
        return r1 || r2;
    }
}