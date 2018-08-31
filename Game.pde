class Game
{
    String name;
    int points[] = new int[clientsConnected.length + 1];
    
    void useRecievedData(String data)
    {
        if (data.startsWith("spectator")) {
            spectator[Integer.parseInt(data.subSequence(10, data.length()).toString())] = !spectator[Integer.parseInt(data.subSequence(10, data.length()).toString())];
            if (isServer)
                notifyConnections(data);
        }
    }
    
    void serverRoutine()
    {
        
    }
    
    void clientRoutine()
    {
        
    }
    
    void displayElements()
    {
      
    }
    
    void keyPressed(int keyCode, char key) {
        
    }
}