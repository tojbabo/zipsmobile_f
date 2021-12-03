package com.example.zipsmobile_f;

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
    Socket _sock;
    public List<String> queue;
    String macid;


    public _taskTcp(String id,List<String> queue) {
        this.queue = queue;
        this.macid = id;
    }

    @Override
    protected Boolean doInBackground(Void... voids) {
        InetAddress servAdr = null;

        int flag = Vals.STATE_DISCONN;
        int check =0;
        while(true) {
            try {
                flag = tryConnect();
                if(flag == Vals.STATE_DISCONN) break;

                queue.clear();
                PrintWriter out = new PrintWriter(new BufferedWriter(
                        new OutputStreamWriter(_sock.getOutputStream())), true);
                InputStream in = _sock.getInputStream();

                out.println("{who,id:"+macid+",ver:"+Vals.version+"}");


                while (flag == Vals.STATE_CONN) {
                    Thread.sleep(5000);
                    //out.println("{log,hi["+check+"]}");

                   check++;
                   if (isCancelled()) break;

                   if (check == 5) {
                       check = 0;
                       if(!checkConnect(out, in)){
                           flag = disConnect();
                           break;
                       }
                   }
                   if (queue.size() == 0) {
                       Thread.sleep(Vals.interval/2);
                       continue;
                   }
                   String target = queue.get(0);
                   queue.remove(0);
                   out.println(target);

//                    publishProgress(null);
                }

                if (isCancelled() == true) break;
            } catch (InterruptedException | IOException e) {
                e.printStackTrace();
            }
        }

        return true;
    }

    @Override
    protected void onCancelled(Boolean aBoolean) {super.onCancelled(aBoolean);}

    private int tryConnect() throws InterruptedException {
        while (true) {
            if (isCancelled()) return Vals.STATE_DISCONN;
            try {
                InetAddress servAdr = InetAddress.getByName(Vals.ip);
                _sock = new Socket(servAdr, Integer.parseInt(Vals.tcpport));

                break;
            } catch (IOException e) {
                Thread.sleep(5000);
            }
        }
        return Vals.STATE_CONN;
    }
    private int disConnect() throws IOException {
        _sock.close();
        return Vals.STATE_DISCONN;
    }
    private boolean checkConnect(PrintWriter out, InputStream in){
        out.println("{echo,}");
        //out.println("{log, conn check}");
        byte[] arr = new byte[512];
        try {
            int readcount = in.read(arr);
            if (readcount == -1) {
                return false;
            }
        } catch (Exception e) {
            return  false;
        }
        return true;
    }
}
