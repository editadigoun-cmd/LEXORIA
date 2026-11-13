const { neon } = require("@neondatabase/serverless");
const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET, POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type" };
module.exports = async (req, res) => {
  Object.entries(cors).forEach(([key, value]) => res.setHeader(key, value));
  if (req.method === "OPTIONS") return res.status(204).end();
  if (!process.env.DATABASE_URL) return res.status(500).json({ error: "Database not configured" });
  try {
    const sql = neon(process.env.DATABASE_URL);
    const action = String(req.query.action || "");
    if (req.method === "GET" && action === "health") {
      const rows = await sql`SELECT current_database() AS database, now() AS server_time`;
      return res.status(200).json({ ok: true, database: rows[0].database, serverTime: rows[0].server_time });
    }
    if (req.method === "POST" && action === "profile") {
      const name = String(req.body?.name || "Joueur").trim().slice(0, 20) || "Joueur";
      const avatar = String(req.body?.avatarKey || "spark").slice(0, 40);
      const playerId = req.body?.playerId;
      if (playerId && /^[0-9a-f-]{36}$/i.test(String(playerId))) {
        const rows = await sql`UPDATE player_profiles SET player_name = ${name}, avatar_key = ${avatar}, updated_at = now() WHERE id = ${playerId} RETURNING id, player_name, avatar_key, created_at`;
        if (rows.length) return res.status(200).json({ profile: rows[0] });
      }
      const rows = await sql`INSERT INTO player_profiles (player_name, avatar_key) VALUES (${name}, ${avatar}) RETURNING id, player_name, avatar_key, created_at`;
      return res.status(201).json({ profile: rows[0] });
    }
    if (req.method === "POST" && action === "result") {
      const { playerId, mode = "solo", score = 0, wordsFound = 0, wordsTotal = 0, completed = false, durationSeconds = 0 } = req.body || {};
      if (!playerId || !/^[0-9a-f-]{36}$/i.test(String(playerId))) return res.status(400).json({ error: "Invalid playerId" });
      const safeScore = Math.max(0, Math.min(1000000, Number(score) || 0));
      const safeFound = Math.max(0, Math.min(1000, Number(wordsFound) || 0));
      const safeTotal = Math.max(safeFound, Math.min(1000, Number(wordsTotal) || 0));
      const safeDuration = Math.max(0, Math.min(86400, Number(durationSeconds) || 0));
      const safeMode = ["solo", "daily", "duel", "challenge"].includes(mode) ? mode : "solo";
      const rows = await sql`INSERT INTO game_results (player_id, mode, score, words_found, words_total, completed, duration_seconds) VALUES (${playerId}, ${safeMode}, ${safeScore}, ${safeFound}, ${safeTotal}, ${Boolean(completed)}, ${safeDuration}) RETURNING id, played_at`;
      return res.status(201).json({ result: rows[0] });
    }
    if (req.method === "GET" && action === "leaderboard") {
      const rows = await sql`SELECT p.player_name AS name, MAX(g.score) AS best_score, COUNT(g.id)::int AS games_played FROM game_results g JOIN player_profiles p ON p.id = g.player_id GROUP BY p.id, p.player_name ORDER BY best_score DESC LIMIT 50`;
      return res.status(200).json({ leaderboard: rows });
    }
    return res.status(404).json({ error: "Unknown action" });
  } catch (error) {
    console.error("LEXORIA API error", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};