import javax.swing.*;
import java.util.*;
import java.net.*;
import java.io.*;

Boolean isServer = false;
int nbOfClientsConnected = 0;
String[] clientsBanned;
String[] connected = new String[16];
boolean[] spectator = new boolean[17];
Connexion[] clientsConnected = new Connexion[16];
Connexion client;
ConnexionsAcceptor acceptor;
int myid = -1;
int menu = 0;
int turn = -1;
Game currentGame;

void setup()
{
    size(640, 480);
    if (readBool("Host ?", "Do you want to host ?")) {
        isServer = true;
        acceptor = new ConnexionsAcceptor();
    } else {
        try {
            client = new Connexion(new Socket(readString("IP Address", "Enter the ip address of the server"), readInteger("Port", "Enter port")));
        } catch(Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, e + "", "Communication Error", JOptionPane.ERROR_MESSAGE);
            exit();
        }
    }
}

void checkDisconnectedClients()
{
    for (int i = 0; i < clientsConnected.length; i++) {
        if (clientsConnected[i] != null && !clientsConnected[i].reader.isAlive()) {
            println("Client with id " + i + " (ip: " + clientsConnected[i].socket.getLocalAddress().toString() + ") disconnected");
            clientsConnected[i] = null;
            connected[i] = null;
            spectator[i + 1] = false;
            nbOfClientsConnected--;
            for (int j = 0; j < clientsConnected.length; j++) {
                if (clientsConnected[j] != null) {
                    clientsConnected[j].out.println("disconnected " + i);
                    clientsConnected[j].out.flush();
                }
            }
        }
    }
}

void draw()
{
    try {
        background(0);
        textSize(10);
        if (isServer)
            checkDisconnectedClients();
        else
            text("Connected on " + client.socket.getLocalAddress().toString() + "   " + (spectator[0] ? "Playing" : "Spectating"), 0, 10);
        for (int i = 0; i < connected.length; i++)
            if (mouseX <= 30 && mouseY <= i * 10 + 10 && mouseY > i * 10 && isServer) {
                fill(255, 0, 0);
                text("XX", 0, 10 + 10 * i + (isServer ? 0 : 10));
                fill(255, 128, 0);
                text("XX", 15, 10 + 10 * i + (isServer ? 0 : 10));
                fill(255);
                text("- " + (connected[i] == null ? "empty" : connected[i]), 30, 10 + 10 * i + (isServer ? 0 : 10));
            } else
                text(i + " - " + (connected[i] == null ? "empty" : connected[i] + "   " + (spectator[i + 1] ? "Spectating" : "Playing")), 0, 10 + 10 * i + (isServer ? 0 : 10));
        textSize(15);
        if (mouseX < 150 && mouseY >= 285 && mouseY <= 300)
            text("Switch to " + (spectator[myid + 1] ? "player" : "spectator"), 0, 300);
        else
            text("You are " + (spectator[myid + 1] ? "spectating" : "playing"), 0, 300);
        switch (menu) {
        case 0:
            text("Pendu", 580, 20);
            break;
        case 1:
            text("Pictionary", 560, 20);
            break;
        case 2:
            if (((Pendu)currentGame).word == null)
                text((((Pendu)currentGame).chooseTurn == -1 ? "Host" : "Player " + ((Pendu)currentGame).chooseTurn) + " is choosing a word", 100, 10);
            while (((Pendu)currentGame).chooseTurn == myid && ((Pendu)currentGame).word == null) {
                ((Pendu)currentGame).word = readString("Enter a word to guess", "Word").toLowerCase();
                if (((Pendu)currentGame).isWordValid())
                    if (isServer) {
                        notifyConnections("length " + ((Pendu)currentGame).word.length());
                        ((Pendu)currentGame).showed = "";
                        ((Pendu)currentGame).wordLength = ((Pendu)currentGame).word.length();
                        for (int i = 0; i < ((Pendu)currentGame).wordLength; i++)
                            ((Pendu)currentGame).showed = ((Pendu)currentGame).showed + "_";
                    } else
                        client.out.println("word " + ((Pendu)currentGame).word);
                else {
                    while (!((Pendu)currentGame).isWordValid())
                        ((Pendu)currentGame).word = readString("Invalid word\nThere needs to be only letters\n\nEnter a word to guess", "Word").toLowerCase();
                    if (isServer) {
                        notifyConnections("length " + ((Pendu)currentGame).word.length());
                        ((Pendu)currentGame).showed = "";
                        ((Pendu)currentGame).wordLength = ((Pendu)currentGame).word.length();
                        for (int i = 0; i < ((Pendu)currentGame).wordLength; i++)
                            ((Pendu)currentGame).showed = ((Pendu)currentGame).showed + "_";
                    } else
                        client.out.println("word " + ((Pendu)currentGame).word);
                }
            }
            textSize(20);
            text(((Pendu)currentGame).showed, 335 - ((Pendu)currentGame).word.length() * 5, 250);
            if (((Pendu)currentGame).chooseTurn == myid) {
                textSize(10);
                text("The word is: \"" + ((Pendu)currentGame).word + "\"", 560 - ((Pendu)currentGame).word.length() * 5.00001, 10);
            }
            break;
        case 3:
        }
    } catch (Exception e) {
        e.printStackTrace();
        if (isServer)
            notifyConnections("error " + e);
        JOptionPane.showMessageDialog(null, "Unexpected error in main chunk: " + e, "Error", JOptionPane.ERROR_MESSAGE);
        exit();
    }
}