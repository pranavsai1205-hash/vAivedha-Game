extends Node2D

# ANANTHA playable vertical slice.
# Controls: WASD / Arrow keys = move, E or Space = interact, T = next timeline, R = reset.

const WORLD_NAMES := ["CITY OF ECHOES", "KINGDOM OF THE WEAVER", "VELOCITY ZERO", "THE HOLLOW TIMELINE", "THE PEACEFUL WORLD"]
const RASAS := ["Shringara", "Raudra", "Veera", "Bhayanaka", "Shanta"]
const WORLD_COLORS := [Color("#171c3d"), Color("#291b31"), Color("#102c43"), Color("#10151c"), Color("#1c3a37")]
const SPEED := 250.0

var player := Vector2(240, 390)
var world_index := 0
var memory_count := 0
var dialogue_text := "Aarav: I remember this place... but not from this life."
var dialogue_timer := 0.0
var encounter_cooldown := 0.0
var meera_visible := false
var memory_positions := [Vector2(580, 230), Vector2(880, 480), Vector2(1060, 260)]
var memories_found: Array[bool] = [false, false, false]
var font: Font
var reference_texture: Texture2D

func _ready() -> void:
    font = ThemeDB.fallback_font
    reference_texture = load("res://assets/reference_couple.png")
    queue_redraw()

func _process(delta: float) -> void:
    _move_player(delta)
    dialogue_timer = max(0.0, dialogue_timer - delta)
    encounter_cooldown = max(0.0, encounter_cooldown - delta)
    _check_memory_and_encounter()
    if Input.is_action_just_pressed("next_world"):
        _next_world()
    if Input.is_action_just_pressed("reset"):
        _reset_world()
    if Input.is_action_just_pressed("interact"):
        _interact()
    queue_redraw()

func _move_player(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    player += direction * SPEED * delta
    player.x = clamp(player.x, 55.0, 1225.0)
    player.y = clamp(player.y, 135.0, 650.0)

func _check_memory_and_encounter() -> void:
    for i in range(memory_positions.size()):
        if not memories_found[i] and player.distance_to(memory_positions[i]) < 58.0:
            memories_found[i] = true
            memory_count += 1
            dialogue_text = "Memory %d/3 recovered. A golden thread pulls toward Meera." % memory_count
            dialogue_timer = 5.0
    if player.distance_to(Vector2(1040, 420)) < 100.0 and encounter_cooldown <= 0.0:
        meera_visible = true
        encounter_cooldown = 8.0
        dialogue_text = "Meera: Some paths can be walked forever... and still never arrive."
        dialogue_timer = 6.0
    elif encounter_cooldown <= 0.0:
        meera_visible = false

func _interact() -> void:
    if player.distance_to(Vector2(1040, 420)) < 150.0:
        dialogue_text = "Aarav: I will follow the echo.\nMeera: Then learn what the journey is asking of you."
        dialogue_timer = 7.0
    else:
        dialogue_text = "The world is listening. Find the glowing memory fragments."
        dialogue_timer = 4.0

func _next_world() -> void:
    world_index = (world_index + 1) % WORLD_NAMES.size()
    _reset_world()
    dialogue_text = "Timeline shift: " + WORLD_NAMES[world_index] + "\nRasa: " + RASAS[world_index]
    dialogue_timer = 5.0

func _reset_world() -> void:
    player = Vector2(240, 390)
    memory_count = 0
    memories_found = [false, false, false]
    meera_visible = false
    encounter_cooldown = 0.0

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), WORLD_COLORS[world_index])
    _draw_background_layers()
    _draw_hud()
    _draw_memories()
    _draw_meera_encounter()
    _draw_player()
    _draw_dialogue()

func _draw_background_layers() -> void:
    for i in range(12):
        var x := float((i * 113 + world_index * 37) % 1280)
        var y := float(150 + ((i * 71) % 480))
        draw_circle(Vector2(x, y), 2.5 + float(i % 3), Color(1.0, 0.75, 0.35, 0.22))
    draw_line(Vector2(0, 110), Vector2(1280, 110), Color(1, 0.75, 0.4, 0.35), 2.0)
    draw_string(font, Vector2(60, 82), "ANANTHA // FATE BETWEEN LIVES", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f6d79b"))
    draw_string(font, Vector2(60, 120), "Timeline: " + WORLD_NAMES[world_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#d3c7ff"))
    draw_string(font, Vector2(930, 82), "T: shift timeline   R: reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#a7b3c9"))

func _draw_memories() -> void:
    for i in range(memory_positions.size()):
        if memories_found[i]:
            continue
        var p := memory_positions[i]
        draw_circle(p, 25.0, Color(1.0, 0.73, 0.26, 0.15))
        draw_circle(p, 12.0, Color("#ffd16a"))
        draw_circle(p, 5.0, Color("#fff2bf"))
        draw_string(font, p + Vector2(-32, 43), "MEMORY", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e9c987"))

func _draw_player() -> void:
    draw_circle(player + Vector2(0, 24), 22.0, Color(0, 0, 0, 0.25))
    draw_circle(player, 18.0, Color("#d6b08b"))
    draw_rect(Rect2(player + Vector2(-16, 18), Vector2(32, 42)), Color("#e7e0d6"), true)
    draw_line(player + Vector2(-12, 32), player + Vector2(-28, 52), Color("#e7e0d6"), 8.0)
    draw_line(player + Vector2(12, 32), player + Vector2(28, 52), Color("#e7e0d6"), 8.0)
    draw_line(player + Vector2(-8, 60), player + Vector2(-12, 83), Color("#252536"), 8.0)
    draw_line(player + Vector2(8, 60), player + Vector2(12, 83), Color("#252536"), 8.0)
    draw_string(font, player + Vector2(-26, 108), "AARAV", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#f4dfbc"))

func _draw_meera_encounter() -> void:
    var target := Vector2(1040, 420)
    if meera_visible:
        for r in range(4):
            draw_arc(target, 55.0 + r * 14.0, 0, TAU, 48, Color(1.0, 0.78, 0.32, 0.18), 3.0)
        draw_circle(target, 20.0, Color("#f4d2a1"))
        draw_colored_polygon(PackedVector2Array([target + Vector2(-30, 25), target + Vector2(30, 25), target + Vector2(58, 110), target + Vector2(-58, 110)]), Color(1.0, 0.76, 0.35, 0.8))
        draw_string(font, target + Vector2(-38, 145), "MEERA", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#ffe4a4"))
    else:
        draw_circle(target, 8.0, Color(1.0, 0.8, 0.4, 0.35))
        draw_string(font, target + Vector2(-65, 38), "THE ECHO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.8, 0.4, 0.45))

func _draw_dialogue() -> void:
    if dialogue_timer <= 0.0:
        dialogue_text = "Explore with WASD. Collect memories. Approach the golden echo."
    draw_rect(Rect2(42, 570, 1196, 105), Color(0.02, 0.02, 0.06, 0.86), true)
    draw_rect(Rect2(42, 570, 1196, 105), Color(1.0, 0.75, 0.35, 0.5), false, 2.0)
    draw_string(font, Vector2(65, 610), dialogue_text, HORIZONTAL_ALIGNMENT_LEFT, 1130, 20, Color("#f4ead6"))
    draw_string(font, Vector2(65, 652), "E / SPACE: interact    |    Golden orbs: memory fragments    |    Meera: recurring fate encounter", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#b6b7d0"))

func _draw_hud() -> void:
    draw_string(font, Vector2(930, 120), "Memories: %d / 3" % memory_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f4d99a"))
    draw_string(font, Vector2(930, 145), "Rasa: " + RASAS[world_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#c6b8f4"))
