import java.awt.event.KeyEvent;

void keyPressed()
{
    try {
        if ((keyCode == LEFT || keyCode == RIGHT) && menu >= 0 && menu <= 1 && isServer) {
            menu = abs(menu + (keyCode == LEFT ? -1 : 1)) % 2;
            notifyConnections("change menu " + menu);
        } else if (keyCode == KeyEvent.VK_ENTER && menu >= 0 && menu <= 1 && isServer) {
            menu += 2;
            if (menu == 2)
                currentGame = new Pendu();
            ((Pendu)currentGame).showed = "";
            notifyConnections("change menu " + menu);
        }
        if (keyCode == 27 && isServer) {
            keyCode = 0;
            key = 0;
            if (menu > 1) {
                menu -= 2;
                notifyConnections("change menu " + menu);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        if (isServer)
            notifyConnections("error " + e);
        JOptionPane.showMessageDialog(null, "Unexpected error in main chunk: " + e, "Error", JOptionPane.ERROR_MESSAGE);
        exit();
    }
}

void mousePressed()
{
    try {
        if (mouseX <= 15 && (mouseY - 1) / 10 < clientsConnected.length && isServer && clientsConnected[(mouseY - 1) / 10] != null) {
            clientsBanned = AddToStringArray(clientsBanned, clientsConnected[(mouseY - 1) / 10].socket.getLocalAddress().toString());
            clientsConnected[(mouseY - 1) / 10].out.println("banned");
            clientsConnected[(mouseY - 1) / 10].out.flush();
            try {
                synchronized (this) {
                   this.wait(1);
                }
                clientsConnected[(mouseY - 1) / 10].socket.close();
            } catch (Exception e) {}
        } else if (mouseX <= 30 && (mouseY - 1) / 10 < clientsConnected.length && isServer && clientsConnected[(mouseY - 1) / 10] != null) {
            clientsConnected[(mouseY - 1) / 10].out.println("kicked");
            clientsConnected[(mouseY - 1) / 10].out.flush();
            try {
                synchronized (this) {
                   this.wait(1);
                }
                clientsConnected[(mouseY - 1) / 10].socket.close();
            } catch (Exception e) {}
        } else if (mouseX < 150 && mouseY >= 285 && mouseY <= 300) {
            if (isServer) {
                notifyConnections("spectator 0");
                spectator[0] = !spectator[0];
            } else {
                client.out.println("spectator " + (myid + 1));
                client.out.flush();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        if (isServer)
            notifyConnections("error " + e);
        JOptionPane.showMessageDialog(null, "Unexpected error in main chunk: " + e, "Error", JOptionPane.ERROR_MESSAGE);
        exit();
    }
}