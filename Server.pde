public class ConnectionsAcceptor extends Thread {
    ServerSocket ss;

    public void accept() {
        int found = 0;
        Socket socket = null;
        Connection Connection;
        PrintWriter out;
        int index;
    
        try {
            socket = ss.accept();
            if (nbOfClientsConnected == 16) {
                out = new PrintWriter(socket.getOutputStream());
                out.println("no space");
                out.flush();
                synchronized (this) {
                    wait(1);
                }
                socket.close();
                return;
            }
            for (int i = 0; clientsBanned != null && i < clientsBanned.length; i++)
                if (compareStrings(clientsBanned[i], socket.getLocalAddress().toString())) {
                    out = new PrintWriter(socket.getOutputStream());
                    out.println("banned");
                    out.flush();
                    synchronized (this) {
                        wait(1);
                    }
                    socket.close();
                    return;
                }
            for (int i = 0; clientsConnected != null && i < clientsConnected.length; i++)
                if (clientsConnected[i] != null && compareStrings(clientsConnected[i].socket.getLocalAddress().toString(), socket.getLocalAddress().toString()))
                    found++;
            if (found > 0) {
                println("Client with ip " + socket.getLocalAddress().toString() + " is already connected");
                out = new PrintWriter(socket.getOutputStream());
                out.println("already connected");
                out.flush();
                synchronized (this) {
                    wait(1);
                }
                socket.close();
                return;
            }
            Connection = new Connection(socket);
            index = AddToConnectionArray(connected, clientsConnected, Connection);
            nbOfClientsConnected++;
            Connection.out.println("change menu " + menu);
            for (int i = 0; i < clientsConnected.length; i++)
                if (i == index) {
                    Connection.out.println("connected " + Connection.socket.getLocalAddress().toString());
                } else if (clientsConnected[i] != null) {
                    Connection.out.println("connected " + clientsConnected[i].socket.getLocalAddress().toString());
                    clientsConnected[i].out.println("connected " + Connection.socket.getLocalAddress().toString());
                    clientsConnected[i].out.flush();
                }
            for (int i = 0; i < spectator.length; i++)
                if (spectator[i])
                    Connection.out.println("spectator " + i);
            Connection.out.flush();
            println("Client n°" + nbOfClientsConnected + " connected with IP " + socket.getLocalAddress().toString() + " id: " + index);
        } catch(Exception e) {
            JOptionPane.showMessageDialog(null, e + "", "Connection Error", JOptionPane.ERROR_MESSAGE);
            try {
                if (socket != null) {
                    out = new PrintWriter(socket.getOutputStream());
                    out.println("error " + e);
                    out.flush();
                    synchronized (this) {
                        wait(1);
                    }
                    socket.close();
                }
            } catch(Exception f) {
                f.printStackTrace();
            }
            return;
        }
    }

    public ConnectionsAcceptor() {
        try {
            ss = new ServerSocket(readInteger("Port", "Enter port"));
        } catch(Exception e) {
            JOptionPane.showMessageDialog(null, e + "", "Server creation error", JOptionPane.ERROR_MESSAGE);
            exit();
        }
        this.start();
    }

    public void run() {
        while(true)
            accept();
    }
}