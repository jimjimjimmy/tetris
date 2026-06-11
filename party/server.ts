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
  // Connection ids of the (up to 2) REAL players, in join order. A rejected
  // third+ connection is never added here, so its later close does NOT trigger
  // an "opponent_left" to the two players. Stable for the life of an active
  // match (no hibernation while traffic flows).
  players: string[] = [];

  constructor(readonly room: Party.Room) {}

  private send(id: string, payload: string) {
    const c = this.room.getConnection(id);
    if (c) c.send(payload);
  }

  onConnect(conn: Party.Connection) {
    // Third+ player: reject immediately and do NOT register as a player.
    if (this.players.length >= 2) {
      conn.send(JSON.stringify({ type: "error", message: "room_full" }));
      conn.close();
      return;
    }

    // Register and assign role by join order.
    const role = this.players.length === 0 ? "p1" : "p2";
    this.players.push(conn.id);
    conn.send(JSON.stringify({ type: "role", role }));

    // Second player joined: notify both that match is ready, with a shared seed.
    if (this.players.length === 2) {
      const seed = makeSeed();
      const payload = JSON.stringify({ type: "ready", seed });
      for (const id of this.players) this.send(id, payload);
    }
  }

  onClose(conn: Party.Connection) {
    // Only a REAL player's departure notifies the opponent. A rejected extra
    // connection closing is ignored (it was never a player).
    if (!this.players.includes(conn.id)) return;
    this.players = this.players.filter((id) => id !== conn.id);
    const payload = JSON.stringify({ type: "opponent_left" });
    for (const id of this.players) this.send(id, payload);
  }

  onMessage(message: string, sender: Party.Connection) {
    // Ignore traffic from non-players (shouldn't happen -- they're closed).
    if (!this.players.includes(sender.id)) return;

    // Rematch: a player requests a fresh match. The SERVER mints a new shared
    // seed and broadcasts it to BOTH players (including the requester) so both
    // boards reset to the same new piece sequence.
    let parsed: any = null;
    try { parsed = JSON.parse(message); } catch (_) { parsed = null; }

    if (parsed && parsed.type === "rematch_request") {
      const seed = makeSeed();
      const payload = JSON.stringify({ type: "rematch", seed });
      for (const id of this.players) this.send(id, payload);
      return;
    }

    // All other messages: relay to the OTHER player only.
    for (const id of this.players) {
      if (id !== sender.id) this.send(id, message);
    }
  }
}

export const onFetch = () => new Response("DRIFT game server OK");
