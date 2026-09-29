Leaderboard beta data is currently local.

GameState.set_quest_score(quest_id, score, time_seconds) stores each completed quest.
Leaderboard.tscn reads GameState.player_name and GameState.total_score for the current run.
Replace the placeholder rows in Leaderboard.gd when real player persistence is added.
