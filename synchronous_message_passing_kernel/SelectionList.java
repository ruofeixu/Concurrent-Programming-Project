//cpts 483
//ruofei xu
//11237005
//synchrounous message passing kernel
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

//this class suppose to contain multiple comm event
//once called select() it will find a complementary event to do a communiction
public class SelectionList
{
    private List<CommEvent> list;
    public SelectionList()
    {
        list = new ArrayList<CommEvent>();
    }

    //add new event to the list
    public void addEvent(CommEvent ce)
    {
        list.add(ce);
    }

    //find a complementary event to do communicaton
    public synchronized Object select() throws InterruptedException
    {
        if(list.size() == 0) {
            return null;
        }

        ChannelObject co = null;
        ReentrantLock lock = list.get(0).getChannel().getLock();//assume all the events using same lock
        lock.lock();
        try {
            for (CommEvent ce : list) {//try to poll each event
                co = ce.poll();
                if (co != null) { //if succeed return object
                    return co.o;
                }
            }

            //a list keep tracking the object and its channel that would push to the queue in the channel
            List<Tuple<ChannelObject,Channel>> coList = new ArrayList<Tuple<ChannelObject,Channel>>();
            Condition con = lock.newCondition(); //all channel object is on a same condition

            //add all object to their channel
            for (CommEvent ce : list) {
                ChannelObject cob = ce.enqueue();
                cob.c = con;
                Tuple<ChannelObject,Channel> cc = new Tuple<ChannelObject,Channel>(cob,ce.getChannel());
                coList.add(cc);
            }

            con.await(); //await a succeed communication

            //only one commucation should be done
            //remove rest of object on the queue
            for (Tuple<ChannelObject,Channel> coc : coList) {
                ChannelObject cob = coc.x;
                Channel channel = coc.y;
                if(!channel.removeObject(cob)) {//the one cannot remove is the succeed one
                    co = cob;
                }
            }

            if(co==null) {
                return null;
            }

            return co.o;
        }finally {
            lock.unlock();
        }
    }
}