import type * as Party from "partykit/server";

// DRIFT multiplayer server.
// Each room = one match. Max 2 players.
// First to connect = p1 (floats up). Second = p2 (falls down).
// Relays gameplay messages from one client to the other.
//
// The server is also the authority for the shared random seed: when the
// match becomes ready (and on every rematch) it generates ONE seed and
// broadcasts it to BOTH players so their piece-sequence PRNGs stay in
// lockstep (same pieces, same order, on both phones).

function makeSeed(): number {
  // 32-bit unsigned seed.
  return (Math.floor(Math.random() * 0xffffffff) >>> 0);
}

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

    // Second player joined: notify both that match is ready, with a shared seed.
    if (count === 2) {
      const seed = makeSeed();
      for (const c of connections) {
        c.send(JSON.stringify({ type: "ready", seed }));
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
    // Rematch: a player requests a fresh match. The SERVER mints a new shared
    // seed and broadcasts it to BOTH players (including the requester) so both
    // boards reset to the same new piece sequence.
    let parsed: any = null;
    try { parsed = JSON.parse(message); } catch (_) { parsed = null; }

    if (parsed && parsed.type === "rematch_request") {
      const seed = makeSeed();
      const payload = JSON.stringify({ type: "rematch", seed });
      for (const c of this.room.getConnections()) {
        c.send(payload);
      }
      return;
    }

    // All other messages: relay to the other player only.
    for (const conn of this.room.getConnections()) {
      if (conn.id !== sender.id) {
        conn.send(message);
      }
    }
  }
}

export const onFetch = () => new Response("DRIFT game server OK");
