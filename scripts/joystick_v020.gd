extends Control
signal moved(v)
var active=false
var knob=Vector2(80,80)
func _draw():
    draw_circle(Vector2(80,80),68,Color(0.02,0.03,0.04,0.48))
    draw_arc(Vector2(80,80),68,0,TAU,40,Color(0.85,0.75,0.55,0.8),3)
    draw_circle(knob,27,Color(0.25,0.28,0.30,0.9))
func _gui_input(e):
    if e is InputEventScreenTouch:
        active=e.pressed
        if active: set_stick(e.position)
        else: release()
    elif e is InputEventScreenDrag and active: set_stick(e.position)
    elif e is InputEventMouseButton:
        active=e.pressed
        if active: set_stick(e.position)
        else: release()
    elif e is InputEventMouseMotion and active: set_stick(e.position)
func set_stick(p):
    var d=p-Vector2(80,80)
    if d.length()>68: d=d.normalized()*68
    knob=Vector2(80,80)+d
    moved.emit(d/68.0); queue_redraw()
func release():
    knob=Vector2(80,80); moved.emit(Vector2.ZERO); queue_redraw()
