extends Control
signal direction_changed(value: Vector2)

@export var radius := 84.0
@export var knob_radius := 34.0
var direction := Vector2.ZERO
var active_touch := -1

func _ready():
    mouse_filter = Control.MOUSE_FILTER_STOP
    custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
    queue_redraw()

func _draw():
    var c := size * 0.5
    draw_circle(c, radius, Color(0.025,0.035,0.04,0.68))
    draw_arc(c, radius-2.0, 0, TAU, 64, Color(0.76,0.67,0.50,0.82), 3.0)
    draw_circle(c, radius*0.58, Color(0.10,0.12,0.13,0.72))
    var kp := c + direction * (radius-knob_radius-8.0)
    draw_circle(kp, knob_radius, Color(0.57,0.54,0.48,0.96))
    draw_arc(kp, knob_radius, 0, TAU, 40, Color(0.94,0.87,0.70,0.95), 3.0)

func set_from_local(p: Vector2):
    var delta := p - size * 0.5
    direction = delta / max(1.0, radius-knob_radius-8.0)
    if direction.length() > 1.0:
        direction = direction.normalized()
    if direction.length() < 0.08:
        direction = Vector2.ZERO
    direction_changed.emit(direction)
    queue_redraw()

func release():
    active_touch = -1
    direction = Vector2.ZERO
    direction_changed.emit(direction)
    queue_redraw()

func _gui_input(event):
    if event is InputEventScreenTouch:
        if event.pressed and active_touch == -1:
            active_touch = event.index
            set_from_local(event.position)
            accept_event()
        elif not event.pressed and event.index == active_touch:
            release()
            accept_event()
    elif event is InputEventScreenDrag and event.index == active_touch:
        set_from_local(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            active_touch = -2
            set_from_local(event.position)
        elif active_touch == -2:
            release()
    elif event is InputEventMouseMotion and active_touch == -2:
        set_from_local(event.position)
