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
            int pos = Integer.parseInt(data.subSequence(7, firstSpace(data.subSequence(7, data.length()).toString())).toString());
            char letter = data.subSequence(7, firstSpace(data.subSequence(7, data.length()).toString())).charAt(0);
            
            showed = showed.subSequence(0, pos - 1).toString() + letter + showed.subSequence(pos, wordLength).toString();
        } else if (data.startsWith("missed")) {
            missedLetters += data.subSequence(7, firstSpace(data.subSequence(7, data.length()).toString())).charAt(0);
        } else if (data.startsWith("pressed") && isServer) {
            char[] array = word.toCharArray();
            char letter = data.subSequence(8, firstSpace(data.subSequence(7, data.length()).toString())).charAt(0);
            boolean found = false;
            
            for (int i = 0; i < array.length; i++) {
                if (array[i] == letter && showed.charAt(i) == '_') {
                    notifyConnections("letter " + i + " " + letter);
                    found = true;
                    showed = showed.subSequence(0, i - 1).toString() + letter + showed.subSequence(i, wordLength).toString();
                }
            }
            if (!found) {
                notifyConnections("missed " + letter);
                missedLetters += letter;
            }
        } else
            super.useRecievedData(data);
    }
}