class Pendu extends Game
{
    int turn;
    int chooseTurn;
    int wordLength;
    String word;
    String missedLetters = "";
    String showed = "";
    
    public Pendu()
    {
        name = "Pendu";
        showed = "";
        turn = 0;
        chooseTurn = -1;
    }
    
    boolean isWordValid()
    {
        char[] array;
        
        if (word == null)
            return false;
        array = word.toCharArray();
        for (int i = 0; i < array.length; i++)
            if ((array[i] < 'a' || array[i] > 'z') && array[i] != '-')
                return false;
        return true;
    }
    
    void serverRoutine()
    {
        super.serverRoutine();
        if (chooseTurn == -2 || spectator[chooseTurn + 1] || (chooseTurn >= 0 && clientsConnected[chooseTurn] == null)) {
            if (chooseTurn < -1)
                chooseTurn = -1;
            for (int i = chooseTurn; (spectator[chooseTurn + 1] || (chooseTurn >= 0 && clientsConnected[chooseTurn] == null)); chooseTurn = (chooseTurn + 2) % spectator.length - 1) {
                if (chooseTurn == i) {
                    chooseTurn = -2;
                    break;
                }
            }
            notifyConnections("choose " + chooseTurn);
        }
        if (turn == -2 || chooseTurn == turn || spectator[turn + 1] || (turn >= 0 && clientsConnected[turn] == null)) {
            if (turn < -1)
                turn = -1;
            for (int i = turn; (chooseTurn == turn || spectator[turn + 1] || (turn >= 0 && clientsConnected[turn] == null)); turn = (turn + 2) % spectator.length - 1) {
                if (turn == i) {
                    turn = -2;
                    break;
                }
            }
            notifyConnections("turn " + turn);
        }
    }
    
    void clientRoutine()
    {
        super.clientRoutine();
        while (chooseTurn == myid && word == null) {
            word = readString("Enter a word to guess", "Word").toLowerCase();
            if (((Pendu)currentGame).isWordValid())
                if (isServer) {
                    notifyConnections("length " + word.length());
                    showed = "";
                    wordLength = word.length();
                    for (int i = 0; i < wordLength; i++)
                        showed = showed + "_";
                } else
                    client.out.println("word " + word);
            else {
                while (!isWordValid())
                    word = readString("Invalid word\nThere needs to be only letters\n\nEnter a word to guess", "Word").toLowerCase();
                if (isServer) {
                    notifyConnections("length " + word.length());
                    showed = "";
                    wordLength = word.length();
                    for (int i = 0; i < wordLength; i++)
                        if (word.charAt(i) == '-') {
                            showed = showed + "-";
                            notifyConnections("letter " + i + " -");
                        } else
                            showed = showed + "_";
                } else
                    client.out.println("word " + word);
            }
        }
    }
    
    void displayElements()
    {
        super.displayElements();
        if (word == null)
            text((chooseTurn < 0 ? "The host" : "Player " + (1 + chooseTurn)) + " is choosing a word", 400, 15);
        else
            text((turn < 0 ? "The host" : "Player " + (1 + turn)) + " is choosing a letter", 400, 15);
        textSize(20);
        text(showed, 335 - showed.length() * 5, 250);
        if (chooseTurn == myid) {
            textSize(10);
            text("The word is: \"" + word + "\"", 560 - word.length() * 5.00001, 10);
        }
    }
    
    void keyPressed(int keyCode, char key) {
        if (key >= 'A' && key <= 'Z')
            key -= 'A' + 'a';
        if (turn == myid && key >= 'a' && key <= 'z') {
            if (isServer) {
                char[] array = word.toCharArray();
                char letter = key;
                boolean found = false;
                
                for (int i = 0; i < array.length; i++) {
                    if (array[i] == letter && showed.charAt(i) == '_') {
                        notifyConnections("letter " + letter + " " + i);
                        found = true;
                        showed = showed.subSequence(0, i - 1).toString() + letter + showed.subSequence(i, wordLength).toString();
                    }
                }
                if (!found) {
                    notifyConnections("missed " + letter);
                    missedLetters += letter;
                }
                turn += 1;
                notifyConnections("turn " + turn);
            } else {
                client.out.println("pressed " + key);
                client.out.flush();
            }
        }
    }
    
    void useRecievedData(String data)
    {
        if (data.startsWith("word") && isServer) {
            word = data.subSequence(5, data.length()).toString();
            if (!isWordValid())
                return;
            wordLength = word.length();
            notifyConnections("length " + word.length());
            showed = "";
            for (int i = 0; i < wordLength; i++)
                if (word.charAt(i) == '-') {
                    showed = showed + "-";
                    notifyConnections("letter - " + i);
                } else
                    showed = showed + "_";
        } else if (data.startsWith("length") && word == null) {
            wordLength = Integer.parseInt(data.subSequence(7, data.length()).toString());
            word = "";
            showed = "";
            for (int i = 0; i < wordLength; i++)
                showed = showed + "_";
        } else if (data.startsWith("end")) {
            wordLength = 0;
            turn = -1;
            chooseTurn = -1;
            word = null;
        } else if (data.startsWith("turn")) {
            turn = Integer.parseInt(data.subSequence(5, data.length()).toString());
        } else if (data.startsWith("choose")) {
            chooseTurn = Integer.parseInt(data.subSequence(7, data.length()).toString());
        } else if (data.startsWith("letter")) {
            int pos = Integer.parseInt(data.subSequence(9, data.length()).toString());
            char letter = data.charAt(7);
            
            showed = showed.subSequence(0, pos).toString() + letter + showed.subSequence(pos + 1, wordLength).toString();
        } else if (data.startsWith("missed")) {
            missedLetters += data.charAt(7);
        } else if (data.startsWith("pressed") && isServer) {
            char[] array = word.toCharArray();
            char letter = data.subSequence(8, data.length()).charAt(0);
            boolean found = false;
            
            for (int i = 0; i < array.length; i++) {
                if (array[i] == letter && showed.charAt(i) == '_') {
                    notifyConnections("letter " + letter + " " + i);
                    found = true;
                    showed = showed.subSequence(0, i).toString() + letter + showed.subSequence(i + 1, wordLength).toString();
                }
            }
            if (!found) {
                notifyConnections("missed " + letter);
                missedLetters += letter;
            }
            turn += 1;
            notifyConnections("turn " + turn);
        } else
            super.useRecievedData(data);
    }
}
