public class Connexion
{
    PrintWriter out;
    BufferedReader in;
    Socket socket;
    String name;
    ReadSocket reader;
    
    public Connexion(Socket socket)
    {
        try {
            this.socket = socket;
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out = new PrintWriter(socket.getOutputStream());
            reader = new ReadSocket(socket.getLocalAddress().toString(), out, in);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public Connexion(Socket socket, BufferedReader in, PrintWriter out)
    {
        this.in = in;
        this.out = out;
        this.socket = socket;
        reader = new ReadSocket(socket.getLocalAddress().toString(), out, in);
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