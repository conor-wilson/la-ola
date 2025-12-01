extends Node

const BASE_URL = "https://mexican-wave-backend.sp202gm.workers.dev/"
const LEADERBOARD_ID = "01KBC0G6E5FSDNRD2X372KAYZ4"

var leaderboard_scores = {}
var user_id = null
var player_name = null
var leaderboards_loaded = false

func _ready():
	user_id = SaveManager.get_value("userId")
	if user_id == null:
		user_id = UuidGenerator.new().as_string()
		SaveManager.set_value("userId", user_id)

	player_name = SaveManager.get_value("name")
	if player_name == null:
		set_player_name()

	fetch_scores(LEADERBOARD_ID, user_id)

func _send_request(method: HTTPClient.Method, url: String, body = null, headers := []):
	var http = AwaitableHTTPRequest.new()
	add_child(http)

	var data = ""
	if body != null:
		data = JSON.stringify(body)
		headers.append("Content-Type: application/json")

	var res = await http.async_request(BASE_URL + url, headers, method, data)
	http.queue_free()
	return res

func fetch_scores(leaderboard_id, _user_id=""):
	var res = await _send_request(HTTPClient.METHOD_GET, "get_scores/%s?userId=%s" % [leaderboard_id, _user_id])
	var scores = res.body_as_json()
	leaderboard_scores[leaderboard_id] = scores
	leaderboards_loaded = true

func get_board_scores(leaderboard_id):
	var ref_scores = leaderboard_scores[leaderboard_id]
	var scores = ref_scores.duplicate(true)

	scores.map(func(s): s["is_player"] = false)
	scores.append({
		"name": player_name if SaveManager.get_value("nameChosen") == true else "You",
		"is_player": true,
		"score": SaveManager.get_value("EndlessRunner_HighScore", 0),
	})

	scores.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)

	for i in range(0, scores.size()):
		scores[i]["position"] = i + 1

	return scores

func is_ready() -> bool:
	return leaderboards_loaded

func set_player_name(_name=""):
	var res = await _send_request(HTTPClient.METHOD_POST, "set_name", {"userId": user_id, "name": _name})
	player_name = res.body_as_string()
	SaveManager.set_value("name", player_name)

func start_run():
	_send_request(HTTPClient.METHOD_POST, "start_run", {"userId": user_id, "leaderboardId": LEADERBOARD_ID})

func end_run(score):
	_send_request(HTTPClient.METHOD_POST, "end_run", {"userId": user_id, "leaderboardId": LEADERBOARD_ID, "score": score})

func post_score(score):
	_send_request(HTTPClient.METHOD_POST, "post_score", {"userId": user_id, "leaderboardId": LEADERBOARD_ID, "score": score})
