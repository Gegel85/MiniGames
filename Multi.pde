public class Connexion {
    PrintWriter out;
    BufferedReader in;
    Socket socket;
    String buffer;
    String name;
    ReadSocket reader;
    
    public class ReadSocket extends Thread {
        public Boolean getData() {
            try {
                buffer = in.readLine();
                if (buffer.startsWith("error") && !isServer) {
                    JOptionPane.showMessageDialog(null, "Internal server error: " + buffer.subSequence(6, buffer.length()), "Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                } else if (buffer.startsWith("banned") && !isServer) {
                    JOptionPane.showMessageDialog(null, "You are banned from this server", "Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                } else if (buffer.startsWith("kicked") && !isServer) {
                    JOptionPane.showMessageDialog(null, "You have been kicked from this server", "Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                } else if (buffer.startsWith("already connected") && !isServer) {
                    JOptionPane.showMessageDialog(null, "You are already connected on this server", "Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                } else if (buffer.startsWith("no space") && !isServer) {
                    JOptionPane.showMessageDialog(null, "There are no space left in the server", "Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                } else if (buffer.startsWith("change menu") && !isServer) {
                    menu = Integer.parseInt(buffer.subSequence(12, buffer.length()).toString());
                } else if (buffer.startsWith("connected") && !isServer) {
                    for (int i = 0; i < connected.length; i++)
                        if (connected[i] == null) {
                            if (compareStrings(buffer.subSequence(10, buffer.length()).toString(), client.socket.getLocalAddress().toString()))
                                myid = i;
                            connected[i] = buffer.subSequence(10, buffer.length()).toString();
                            break;
                        }
                } else if (buffer.startsWith("disconnected") && !isServer) {
                    connected[Integer.parseInt(buffer.subSequence(13, buffer.length()).toString())] = null;
                } else if (buffer.startsWith("spectator")) {
                    spectator[Integer.parseInt(buffer.subSequence(10, buffer.length()).toString())] = !spectator[Integer.parseInt(buffer.subSequence(10, buffer.length()).toString())];
                    if (isServer) {
                        notifyConnections(buffer);
                    }
                }
            } catch(Exception e) {
                if (!isServer) {
                    JOptionPane.showMessageDialog(null, e + "", "Communication Error", JOptionPane.ERROR_MESSAGE);
                    exit();
                }
                return (false);
            }
            return (true);
        }
        
        public ReadSocket(String name) {
            super(name);
            this.start();
        }
       
       
        public void run() {
            while(getData());
        }
    }
    
    public Connexion(Socket socket) {
        try {
            this.socket = socket;
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out = new PrintWriter(socket.getOutputStream());
            reader = new ReadSocket(socket.getLocalAddress().toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public Connexion(Socket socket, BufferedReader in, PrintWriter out) {
        this.in = in;
        this.out = out;
        this.socket = socket;
        reader = new ReadSocket(socket.getLocalAddress().toString());
    }
}

void notifyConnections(String message)
{
    for (int i = 0; i < clientsConnected.length; i++)
        if (clientsConnected[i] != null) {
            clientsConnected[i].out.println(message);
            clientsConnected[i].out.flush();
        }
}
