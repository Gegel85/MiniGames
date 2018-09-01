class Pendu extends Game
{
    int turn;
    int chooseTurn;
    int wordLength;
    String word;
    String missedLetters = "";
    String showed = "";
    int timer = 0;
    
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
            for (int i = (chooseTurn <= -1 ? spectator.length - 1 : chooseTurn - 1); (spectator[chooseTurn + 1] || (chooseTurn >= 0 && clientsConnected[chooseTurn] == null)); chooseTurn = (chooseTurn + 2) % spectator.length - 1) {
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
            for (int i = (turn == -1 ? spectator.length - 1 : turn - 1); (chooseTurn == turn || spectator[turn + 1] || (turn >= 0 && clientsConnected[turn] == null)); turn = (turn + 2) % spectator.length - 1) {
                if (turn == i) {
                    turn = -2;
                    break;
                }
            }
            notifyConnections("turn " + turn);
        }
        if (word != null && (!showed.contains("_") || missedLetters.length() == 11)) {
            timer = 0;
            notifyConnections("end");
            wordLength = 0;
            turn = -1;
            word = null;
            chooseTurn++;
            notifyConnections("turn " + turn);
            notifyConnections("choose " + chooseTurn);
        }
    }
    
    void clientRoutine()
    {
        super.clientRoutine();
        if (timer < 120)
            timer++;
        while (chooseTurn == myid && word == null && timer >= 120) {
            while (!isWordValid())
                word = readString((word == null ? "" : "Invalid word\nThere needs to be only letters\n\n") + "Enter a word to guess", "Word").toLowerCase();
            if (isServer) {
                notifyConnections("length " + word.length());
                showed = "";
                wordLength = word.length();
                for (int i = 0; i < wordLength; i++)
                    if (word.charAt(i) == '-') {
                        showed = showed + "-";
                        notifyConnections("letter - " + i);
                    } else
                        showed = showed + "_";
            } else {
                client.out.println("word " + word);
                client.out.flush();
                showed = "";
                wordLength = word.length();
                for (int i = 0; i < wordLength; i++)
                    showed = showed + "_";
            }
            missedLetters = "";
        }
    }
    
    void displayElements()
    {
        super.displayElements();
        fill(255);
        if (word == null)
            text((chooseTurn < 0 ? "The host" : "Player " + (1 + chooseTurn)) + " is choosing a word", 400, 15);
        else
            text((turn < 0 ? "The host" : "Player " + (1 + turn)) + " is choosing a letter", 400, 15);
        textSize(20);
        text(showed, 335 - showed.length() * 5, 250);
        textSize(15);
        for (int i = 0; i < missedLetters.length(); i++)
            text(missedLetters.charAt(i), i * 10 + 100, 400);
        if (chooseTurn == myid && word != null) {
            textSize(10);
            text("The word is: \"" + word + "\"", 560 - word.length() * 5.00001, 40);
        }
        stroke(255);
        fill(0);
        switch (missedLetters.length()) {
            default:
                line(500, 370, 510, 385);
            case 10:
                line(500, 370, 490, 385);
            case 9:
                line(500, 360, 510, 355);
            case 8:
                line(500, 360, 490, 355);
            case 7:
                line(500, 350, 500, 370);
            case 6:
                ellipse(480, 310, 40, 40);
            case 5:
                line(500, 300, 500, 310);
            case 4:
                line(425, 315, 440, 300);
            case 3:
                line(425, 300, 500, 300);
            case 2:
                line(425, 430, 425, 300);
            case 1:
                ellipse(400, 430, 50, 50);
                fill(0);
                noStroke();
                rect(400, 450, 60, 30);
            case 0:
        }
    }
    
    void keyPressed(int keyCode, char key) {
        if (key >= 'A' && key <= 'Z')
            key -= 'A' + 'a';
        if (turn == myid && key >= 'a' && key <= 'z' && word != null) {
            if (isServer) {
                char[] array = word.toCharArray();
                char letter = key;
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
            notifyConnections("length " + wordLength);
            showed = "";
            missedLetters = "";
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
            missedLetters = "";
            for (int i = 0; i < wordLength; i++)
                showed = showed + "_";
        } else if (data.startsWith("end")) {
            word = null;
            wordLength = 0;
            turn = -1;
            chooseTurn = -1;
            timer = 0;
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
