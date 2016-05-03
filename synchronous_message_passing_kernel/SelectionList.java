import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

public class SelectionList
{
    private List<CommEvent> list;
    public SelectionList()
    {
        list = new ArrayList<CommEvent>();
    }

    public void addEvent(CommEvent ce)
    {
        list.add(ce);
    }

    public Object select() throws InterruptedException
    {
        if(list.size() == 0)
            return null;

        Object o = null;
        for (CommEvent ce : list) {
            o = ce.poll();
            if(o != null)
            {
                return o;
            }
        }

        Channel ch = list.get(0).getChannel();
        ReentrantLock lock = ch.getLock();
        Condition con = lock.newCondition();
        List<ChannelObject> coList = new ArrayList<ChannelObject>();

        for (CommEvent ce : list) {
            ChannelObject co = ce.enqueue();
            co.c = con;
            coList.add(co);
        }
        con.await();

        for (CommEvent ce : list) {
            o = ce.poll();
            if(o != null)
            {
                break;
            }
        }

        for (ChannelObject co : coList) {
            ch.removeObject(co);
        }

        return o;
    }
}