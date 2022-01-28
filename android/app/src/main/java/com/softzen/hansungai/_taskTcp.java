package com.softzen.hansungai;

import android.os.AsyncTask;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.List;

public class _taskTcp extends AsyncTask<Void, String,Boolean> {
    String TAG ="ojjj on taskTcp";
    Vals val = Vals.get_instance();
    Socket _sock;
    public List<String> queue;
    PrintWriter out;
    InputStream in;
    public _taskTcp(List<String> queue) {
        this.queue = queue;
    }

    @Override
    protected Boolean doInBackground(Void... voids) {
        while(true) {
            try {
                if(tryConnect() == Vals.STATE_DISCONN) break;
                queue.clear();
                coreLogic();
            } catch (InterruptedException e) {
                //e.printStackTrace();
            }
        }
        return true;
    }
    private void coreLogic() {
        int check = 0;
        while (true) {
            try {
                check++;
                if (isCancelled()) break;
                if (check == 5) {
                    check = 0;
                    if (!checkConnect()) break;
                }
                if (queue.size() == 0) {
                    Thread.sleep(val.interval / 2);
                    continue;
                }
                String target = queue.get(0);
                queue.remove(0);
                out.println(target);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            //publishProgress(null);
        }
    }

    @Override
    protected void onCancelled(Boolean aBoolean) {
        super.onCancelled(aBoolean);
        //out.println("{log, goodbye baby}");
        }
    private int tryConnect() throws InterruptedException {
        while (true) {
            if (isCancelled()) return Vals.STATE_DISCONN;
            try {
                InetAddress servAdr = InetAddress.getByName(val.ip);
                _sock = new Socket(servAdr, Integer.parseInt(val.port));
                break;
            } catch (IOException e) {
                Thread.sleep(5000);
            }
        }

        try {
            out = new PrintWriter(new BufferedWriter(
                    new OutputStreamWriter(_sock.getOutputStream())), true);
            in = _sock.getInputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }

        out.println("{who,id:"+val.macid+",ver:"+val.version+"}");
        String msg = read();
        //Log.d(TAG, "conn result: "+msg);
        if(msg ==  "bye"){
            try {
                disConnect();
            } catch (IOException e) {
                e.printStackTrace();
            }
            Log.d(TAG, "version low");
            return Vals.STATE_DISCONN;
        }
        else return Vals.STATE_CONN;
    }
    private int disConnect() throws IOException {
        _sock.close();
        return Vals.STATE_DISCONN;
    }
    private boolean checkConnect(){
        out.println("{echo,}");
        //out.println("{log, conn check}");
        if(read() == null) return false;
        return true;
    }
    private String read(){
        byte[] arr = new byte[512];
        try {
            int readcount = in.read(arr);
            if (readcount == -1) {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
        return new String(arr);
    }
}