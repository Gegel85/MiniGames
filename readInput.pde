int readInteger(String message, String title){
    String realMessage = message;
    boolean valid = false;
    int nbr = 0;
    
    while(!valid) { 
        String str = JOptionPane.showInputDialog(null , realMessage , title , JOptionPane.OK_OPTION);
        try {
            nbr = Integer.parseInt(str);
            valid = true;
        } catch(Exception e) {
            valid = false;
            realMessage = "This is not an integer.\n\n" + message;
        }
    }
    return nbr;
}

String readString(String message, String title)
{
    return JOptionPane.showInputDialog(null , message , title , JOptionPane.PLAIN_MESSAGE);
}

Boolean readBool(String message,String title){
    return JOptionPane.showOptionDialog(null , message, title, JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null, null, null) == JOptionPane.YES_OPTION;
}
