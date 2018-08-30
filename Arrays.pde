int AddToConnexionArray(String[] strings, Connexion[] array, Connexion newConnexion)
{
    for (int i = 0; i < array.length; i++)
        if (array[i] == null) {
            strings[i] = newConnexion.socket.getLocalAddress().toString();
            array[i] = newConnexion;
            return i;
        }
    return -1;
}

String[] AddToStringArray(String[] oldArray, String newString)
{
    String[] newArray = oldArray == null ? new String[1] : Arrays.copyOf(oldArray, oldArray.length + 1);
    
    newArray[oldArray == null ? 0 : oldArray.length] = newString;
    return newArray;
}

Boolean compareStrings(String str1, String str2)
{
    char[] array1;
    char[] array2;
    
    if (str1 == null && str2 == null)
        return (true);
    else if (str1 == null || str2 == null)
        return (false);
    else if (str1.toCharArray().length != str2.toCharArray().length)
        return (false);
    array1 = str1.toCharArray();
    array2 = str2.toCharArray();
    for (int i = 0; i < array1.length; i++)
        if (array1[i] != array2[i])
            return (false);
    return (true);
}

int firstSpace(String str)
{
    char[] array = str.toCharArray();
    
    for (int i = 0; i < array.length; i++)
        if (array[i] == ' ')
            return (i);
    return str.length();
}