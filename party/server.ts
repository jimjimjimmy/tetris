import type * as Party from "partykit/server";

// DRIFT multiplayer server.
// Each room = one match. Max 2 players.
// First to connect = p1 (floats up). Second = p2 (falls down).
// Broadcasts all messages from one client to the other.

export default class DriftServer implements Party.Server {
  constructor(readonly room: Party.Room) {}

  onConnect(conn: Party.Connection) {
    const connections = [...this.room.getConnections()];
    const count = connections.length;

    // Third+ player: reject immediately.
    if (count > 2) {
      conn.send(JSON.stringify({ type: "error", message: "room_full" }));
      conn.close();
      return;
    }

    // Assign role based on join order.
    const role = count === 1 ? "p1" : "p2";
    conn.send(JSON.stringify({ type: "role", role }));

    // Second player joined: notify both that match is ready.
    if (count === 2) {
      for (const c of connections) {
        c.send(JSON.stringify({ type: "ready" }));
      }
    }
  }

  onClose(conn: Party.Connection) {
    // Notify remaining player that opponent left.
    for (const c of this.room.getConnections()) {
      if (c.id !== conn.id) {
        c.send(JSON.stringify({ type: "opponent_left" }));
      }
    }
  }

  onMessage(message: string, sender: Party.Connection) {
    // Relay message to the other player only.
    for (const conn of this.room.getConnections()) {
      if (conn.id !== sender.id) {
        conn.send(message);
      }
    }
  }
}

export const onFetch = () => new Response("DRIFT game server OK");
