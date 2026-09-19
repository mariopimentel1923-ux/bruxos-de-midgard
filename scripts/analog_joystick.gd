extends Control
signal direction_changed(value)
var active=false
var center=Vector2.ZERO
var knob=Vector2.ZERO
var radius=72.0

func _ready():
    mouse_filter=Control.MOUSE_FILTER_STOP
    center=size/2
    knob=center
    queue_redraw()

func _draw():
    draw_circle(center,radius,Color(0.05,0.08,0.10,0.55))
    draw_circle(center,radius,Color(0.75,0.85,0.9,0.55),false,3.0)
    draw_circle(knob,30.0,Color(0.75,0.85,0.9,0.78))

func _gui_input(e):
    if e is InputEventScreenTouch:
        active=e.pressed
        if active:
            _move(e.position)
        else:
            knob=center
            direction_changed.emit(Vector2.ZERO)
            queue_redraw()
    elif e is InputEventScreenDrag and active:
        _move(e.position)
    elif e is InputEventMouseButton:
        active=e.pressed
        if active: _move(e.position)
        else:
            knob=center
            direction_changed.emit(Vector2.ZERO)
            queue_redraw()
    elif e is InputEventMouseMotion and active:
        _move(e.position)

func _move(p):
    var d=p-center
    if d.length()>radius: d=d.normalized()*radius
    knob=center+d
    direction_changed.emit(d/radius)
    queue_redraw()
