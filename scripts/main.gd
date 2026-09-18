extends Node2D

const SAVE_PATH := "user://savegame.json"
const VERSION := "0.1.1"
const JOYSTICK := preload("res://scripts/virtual_joystick.gd")

var save_data := {
    "name": "", "avatar": 0, "origin": "Fogo", "familiar": "Lobo",
    "position": [640.0, 515.0],
    "quest": "Fale com seu professor no Salão das Runas",
    "professor_met": false
}
var screen := "menu"
var ui: CanvasLayer
var world: Node2D
var player: CharacterBody2D
var familiar_node: Node2D
var professor: Node2D
var dialogue_panel: PanelContainer
var touch_dir := Vector2.ZERO
var player_trail: Array[Vector2] = []

var origins = [
    {"name":"Fogo","symbol":"🔥","desc":"Cinzas, coragem e transformação.","color":Color("b95538")},
    {"name":"Água","symbol":"🌊","desc":"Fiordes, conhecimento e adaptação.","color":Color("3c75a6")},
    {"name":"Ferro","symbol":"⚙","desc":"Forjas, disciplina e criação.","color":Color("7c858f")},
    {"name":"Terra","symbol":"🌿","desc":"Raízes, comunidade e crescimento.","color":Color("4d7d50")}
]
var familiars = [
    {"name":"Lobo","symbol":"🐺","desc":"Uivo de Guerra: fortalece uma criatura."},
    {"name":"Corvo","symbol":"🐦","desc":"Visão: ajuda a encontrar a carta certa."},
    {"name":"Raposa","symbol":"🦊","desc":"Astúcia: troca uma carta da mão."},
    {"name":"Coruja","symbol":"🦉","desc":"Presságio: observa o futuro do grimório."}
]

func _ready():
    if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
        DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
    ui = CanvasLayer.new()
    add_child(ui)
    show_menu()

func clear_scene():
    for c in get_children():
        if c != ui:
            c.queue_free()
    for c in ui.get_children():
        c.queue_free()
    touch_dir = Vector2.ZERO

func panel_style(bg:Color, border:=Color("8e7655"), width:=2, radius:=10) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 18
    s.content_margin_right = 18
    s.content_margin_top = 10
    s.content_margin_bottom = 10
    return s

func bg_panel(color:Color) -> ColorRect:
    var r := ColorRect.new()
    r.color = color
    r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    return r

func title_label(text:String, size:int=44) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size",size)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l.add_theme_color_override("font_color",Color("f1eadb"))
    l.add_theme_color_override("font_shadow_color",Color(0,0,0,0.9))
    l.add_theme_constant_override("shadow_offset_x",2)
    l.add_theme_constant_override("shadow_offset_y",3)
    return l

func make_button(text:String, callable:Callable, min_size:=Vector2(300,58)) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = min_size
    b.add_theme_font_size_override("font_size",22)
    b.add_theme_stylebox_override("normal",panel_style(Color("15191be8"),Color("8e7655"),2,8))
    b.add_theme_stylebox_override("hover",panel_style(Color("2b3032f2"),Color("d0b37a"),3,8))
    b.add_theme_stylebox_override("pressed",panel_style(Color("0b0e10f2"),Color("d0b37a"),3,8))
    b.pressed.connect(callable)
    return b

func center_box() -> VBoxContainer:
    var box := VBoxContainer.new()
    box.set_anchors_preset(Control.PRESET_CENTER)
    box.position = Vector2(-235,-205)
    box.size = Vector2(470,410)
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation",12)
    return box

func show_menu():
    screen = "menu"
    clear_scene()
    var bg := TextureRect.new()
    bg.texture = load("res://assets/menu_bg.jpg")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    ui.add_child(bg)
    var shade := ColorRect.new()
    shade.color = Color(0.01,0.015,0.02,0.22)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui.add_child(shade)
    var box := VBoxContainer.new()
    box.position = Vector2(430,235)
    box.size = Vector2(420,360)
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation",10)
    ui.add_child(box)
    box.add_child(make_button("NOVA JORNADA",show_name,Vector2(420,58)))
    var cont := make_button("CONTINUAR",load_game,Vector2(420,58))
    cont.disabled = not FileAccess.file_exists(SAVE_PATH)
    box.add_child(cont)
    box.add_child(make_button("OPÇÕES",func(): popup_message("Opções","Áudio, desempenho e personalização dos controles chegarão em uma próxima revisão."),Vector2(420,58)))
    box.add_child(make_button("CRÉDITOS",func(): popup_message("Créditos","Bruxos de Midgard — O Caminho das Runas\nV0.1.1"),Vector2(420,58)))
    var v := Label.new()
    v.text = "V%s" % VERSION
    v.position = Vector2(1215,18)
    v.add_theme_color_override("font_color",Color("e8deca"))
    ui.add_child(v)

func show_name():
    screen = "creation"
    clear_scene()
    ui.add_child(bg_panel(Color("101a21")))
    var box := center_box()
    ui.add_child(box)
    box.add_child(title_label("SUA JORNADA COMEÇA",38))
    box.add_child(title_label("Como seu aprendiz será chamado?",21))
    var edit := LineEdit.new()
    edit.placeholder_text = "Nome do aprendiz"
    edit.max_length = 18
    edit.custom_minimum_size = Vector2(420,55)
    edit.add_theme_font_size_override("font_size",22)
    box.add_child(edit)
    box.add_child(make_button("Continuar",func():
        save_data.name = edit.text.strip_edges() if edit.text.strip_edges() != "" else "Eirik"
        show_avatar()
    ))
    box.add_child(make_button("Voltar",show_menu,Vector2(200,50)))

func show_avatar():
    clear_scene()
    ui.add_child(bg_panel(Color("12212a")))
    var root := VBoxContainer.new()
    root.position = Vector2(120,55)
    root.size = Vector2(1040,610)
    root.add_theme_constant_override("separation",16)
    ui.add_child(root)
    root.add_child(title_label("ESCOLHA SEU APRENDIZ",36))
    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation",20)
    grid.add_theme_constant_override("v_separation",18)
    root.add_child(grid)
    var names := ["Aprendiz do Norte","Aprendiz das Montanhas","Aprendiz Rúnico","Aprendiz do Norte","Aprendiz das Montanhas","Aprendiz Rúnica"]
    var symbols := ["🧙","🧙","🧙","🧙‍♀","🧙‍♀","🧙‍♀"]
    for i in 6:
        var b := make_button("%s\n%s" % [symbols[i],names[i]],func(idx=i): save_data.avatar=idx; show_origin(),Vector2(320,145))
        grid.add_child(b)
    root.add_child(make_button("Voltar",show_name,Vector2(200,48)))

func show_origin():
    clear_scene()
    ui.add_child(bg_panel(Color("12212a")))
    var root := VBoxContainer.new()
    root.position = Vector2(140,55)
    root.size = Vector2(1000,620)
    root.add_theme_constant_override("separation",14)
    ui.add_child(root)
    root.add_child(title_label("ESCOLHA SUA REGIÃO DE ORIGEM",36))
    var note := title_label("Sua origem é seu primeiro caminho — não seu destino.",20)
    note.add_theme_color_override("font_color",Color("d6b56b"))
    root.add_child(note)
    for o in origins:
        var b := make_button("%s  %s — %s" % [o.symbol,o.name,o.desc],func(n=o.name): save_data.origin=n; show_familiar(),Vector2(1000,78))
        root.add_child(b)
    root.add_child(make_button("Voltar",show_avatar,Vector2(200,48)))

func show_familiar():
    clear_scene()
    ui.add_child(bg_panel(Color("12212a")))
    var root := VBoxContainer.new()
    root.position = Vector2(140,55)
    root.size = Vector2(1000,620)
    root.add_theme_constant_override("separation",14)
    ui.add_child(root)
    root.add_child(title_label("ESCOLHA SEU PRIMEIRO FAMILIAR",36))
    root.add_child(title_label("Ele caminhará ao seu lado e futuramente ajudará nos duelos.",19))
    for f in familiars:
        root.add_child(make_button("%s  %s — %s" % [f.symbol,f.name,f.desc],func(n=f.name): save_data.familiar=n; show_intro(),Vector2(1000,78)))
    root.add_child(make_button("Voltar",show_origin,Vector2(200,48)))

func show_intro():
    clear_scene()
    ui.add_child(bg_panel(Color("0b141a")))
    var box := center_box()
    box.position = Vector2(-330,-210)
    box.size = Vector2(660,420)
    ui.add_child(box)
    box.add_child(title_label("SKELDAL",48))
    var txt := Label.new()
    txt.text = "%s cresceu entre os caminhos de %s.\nHoje, acompanhado por seu %s, chega a Skeldal para iniciar seu aprendizado.\n\nQuatro caminhos são conhecidos em Midgard. Nenhum possui toda a verdade." % [save_data.name,save_data.origin,save_data.familiar]
    txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    txt.custom_minimum_size = Vector2(650,170)
    txt.add_theme_font_size_override("font_size",20)
    box.add_child(txt)
    box.add_child(make_button("Entrar em Skeldal",func(): save_game(); start_world()))

func start_world():
    screen = "world"
    clear_scene()
    world = Node2D.new()
    add_child(world)
    build_world()
    build_hud()

func add_poly(points:PackedVector2Array,color:Color,z:=0):
    var p := Polygon2D.new()
    p.polygon = points
    p.color = color
    p.z_index = z
    world.add_child(p)

func add_rect(pos:Vector2,size:Vector2,color:Color,z:=0):
    add_poly(PackedVector2Array([pos,pos+Vector2(size.x,0),pos+size,pos+Vector2(0,size.y)]),color,z)

func add_path(points:PackedVector2Array,width:float):
    var line := Line2D.new()
    line.points = points
    line.width = width
    line.default_color = Color("a99b7f")
    line.joint_mode = Line2D.LINE_JOINT_ROUND
    line.begin_cap_mode = Line2D.LINE_CAP_ROUND
    line.end_cap_mode = Line2D.LINE_CAP_ROUND
    world.add_child(line)
    var edge := Line2D.new()
    edge.points = points
    edge.width = width + 12
    edge.default_color = Color("6f6858")
    edge.z_index = -1
    edge.joint_mode = Line2D.LINE_JOINT_ROUND
    world.add_child(edge)

func add_building(pos:Vector2,size:Vector2,label:String,color:Color):
    add_rect(pos+Vector2(5,8),size,Color(0,0,0,0.28),1)
    add_rect(pos,size,color,2)
    add_poly(PackedVector2Array([pos+Vector2(-18,18),pos+Vector2(size.x/2,-38),pos+Vector2(size.x+18,18)]),color.darkened(0.28),3)
    add_rect(pos+Vector2(size.x*0.42,size.y-52),Vector2(size.x*0.16,52),Color("3b291f"),4)
    add_rect(pos+Vector2(18,55),Vector2(28,30),Color("e7a448"),4)
    add_rect(pos+Vector2(size.x-46,55),Vector2(28,30),Color("e7a448"),4)
    var l := Label.new()
    l.text = label
    l.position = pos+Vector2(8,size.y-27)
    l.add_theme_font_size_override("font_size",15)
    l.add_theme_color_override("font_color",Color("f0e5cf"))
    l.z_index = 5
    world.add_child(l)

func add_tree(pos:Vector2,scale_v:=1.0):
    var trunk := Polygon2D.new()
    trunk.position = pos
    trunk.polygon = PackedVector2Array([Vector2(-5,12),Vector2(5,12),Vector2(7,38),Vector2(-7,38)])
    trunk.color = Color("55402f")
    trunk.z_index = 2
    world.add_child(trunk)
    for y in [0,-20,-38]:
        var crown := Polygon2D.new()
        crown.position = pos+Vector2(0,y)
        crown.polygon = PackedVector2Array([Vector2(0,-42)*scale_v,Vector2(-31,24)*scale_v,Vector2(31,24)*scale_v])
        crown.color = Color("234d3c").lightened(float(-y)/250.0)
        crown.z_index = 3
        world.add_child(crown)

func build_world():
    add_rect(Vector2.ZERO,Vector2(1280,720),Color("647b61"),-5)
    # river and shore
    add_poly(PackedVector2Array([Vector2(0,600),Vector2(1280,555),Vector2(1280,720),Vector2(0,720)]),Color("2d6c80"),-2)
    for y in [585,615,650,690]:
        var water := Line2D.new()
        water.points = PackedVector2Array([Vector2(0,y),Vector2(300,y-10),Vector2(620,y+4),Vector2(900,y-12),Vector2(1280,y)])
        water.width = 3
        water.default_color = Color(0.35,0.72,0.78,0.35)
        world.add_child(water)
    add_path(PackedVector2Array([Vector2(640,720),Vector2(640,500),Vector2(620,350),Vector2(640,190),Vector2(640,0)]),92)
    add_path(PackedVector2Array([Vector2(80,405),Vector2(350,390),Vector2(640,350),Vector2(930,385),Vector2(1200,405)]),72)
    add_building(Vector2(480,65),Vector2(320,170),"SALÃO DAS RUNAS",Color("574b43"))
    add_building(Vector2(115,150),Vector2(230,135),"FORJA",Color("684c38"))
    add_building(Vector2(930,145),Vector2(225,140),"TAVERNA",Color("604b3c"))
    add_building(Vector2(115,430),Vector2(210,110),"CASAS",Color("625144"))
    add_building(Vector2(940,425),Vector2(220,115),"MERCADO",Color("6e5742"))
    # dock
    add_rect(Vector2(760,555),Vector2(34,165),Color("6a4a31"),1)
    add_rect(Vector2(720,565),Vector2(120,28),Color("765338"),2)
    for x in range(30,1250,95):
        if x < 400 or x > 850:
            add_tree(Vector2(x,90 + (x%3)*18),0.85)
    for p in [Vector2(55,335),Vector2(370,470),Vector2(410,530),Vector2(860,470),Vector2(1210,330),Vector2(1180,500)]:
        add_tree(p,0.9)
    # stones and flowers
    for p in [Vector2(385,300),Vector2(875,310),Vector2(350,565),Vector2(900,540)]:
        add_rect(p,Vector2(18,12),Color("7f8177"),2)
    professor = Node2D.new()
    professor.position = Vector2(640,280)
    professor.z_index = 10
    world.add_child(professor)
    draw_person(professor,Color("d8c3a6"),Color("4e6178"),"!")
    player = CharacterBody2D.new()
    var pos = save_data.position
    player.position = Vector2(float(pos[0]),float(pos[1]))
    player.z_index = 11
    world.add_child(player)
    draw_person(player,Color("d6b28c"),origin_color(save_data.origin),"")
    familiar_node = Node2D.new()
    familiar_node.position = player.position+Vector2(-42,24)
    familiar_node.z_index = 10
    world.add_child(familiar_node)
    draw_familiar(familiar_node)
    player_trail.clear()
    for i in 30:
        player_trail.append(player.position)

func draw_person(n:Node2D,skin:Color,robe:Color,mark:String):
    var shadow := Polygon2D.new()
    shadow.polygon = PackedVector2Array([Vector2(-19,35),Vector2(19,35),Vector2(14,44),Vector2(-14,44)])
    shadow.color = Color(0,0,0,0.28)
    n.add_child(shadow)
    var cloak := Polygon2D.new()
    cloak.polygon = PackedVector2Array([Vector2(-14,2),Vector2(14,2),Vector2(21,39),Vector2(-21,39)])
    cloak.color = robe
    n.add_child(cloak)
    var head := Polygon2D.new()
    head.polygon = PackedVector2Array([Vector2(-11,-17),Vector2(11,-17),Vector2(13,4),Vector2(-13,4)])
    head.color = skin
    n.add_child(head)
    var hair := Polygon2D.new()
    hair.polygon = PackedVector2Array([Vector2(-13,-18),Vector2(12,-20),Vector2(15,-9),Vector2(-14,-8)])
    hair.color = Color("3a281f")
    n.add_child(hair)
    if mark != "":
        var l := Label.new()
        l.text = mark
        l.position = Vector2(-6,-57)
        l.add_theme_font_size_override("font_size",28)
        l.add_theme_color_override("font_color",Color("f0c45c"))
        n.add_child(l)

func draw_familiar(n:Node2D):
    var body := Polygon2D.new()
    body.polygon = PackedVector2Array([Vector2(-18,1),Vector2(8,-8),Vector2(21,1),Vector2(14,16),Vector2(-15,15)])
    body.color = Color("697680")
    n.add_child(body)
    var l := Label.new()
    l.text = {"Lobo":"🐺","Corvo":"🐦","Raposa":"🦊","Coruja":"🦉"}.get(save_data.familiar,"🐺")
    l.position = Vector2(-14,-34)
    l.add_theme_font_size_override("font_size",24)
    n.add_child(l)

func origin_color(n:String) -> Color:
    for o in origins:
        if o.name == n:
            return o.color
    return Color("596b87")

func build_hud():
    var top := PanelContainer.new()
    top.position = Vector2(18,18)
    top.size = Vector2(455,92)
    top.add_theme_stylebox_override("panel",panel_style(Color("0c1215dc"),Color("8e7655"),2,10))
    ui.add_child(top)
    var vb := VBoxContainer.new()
    top.add_child(vb)
    var l := Label.new()
    l.text = "%s   •   %s   •   %s" % [save_data.name,save_data.origin,save_data.familiar]
    l.add_theme_font_size_override("font_size",19)
    vb.add_child(l)
    var q := Label.new()
    q.text = "Missão: " + save_data.quest
    q.add_theme_font_size_override("font_size",15)
    q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vb.add_child(q)
    var menu := make_button("☰",func(): save_game(); show_menu(),Vector2(58,52))
    menu.position = Vector2(1200,18)
    ui.add_child(menu)
    var joy = JOYSTICK.new()
    joy.position = Vector2(35,515)
    joy.size = Vector2(168,168)
    joy.direction_changed.connect(func(v): touch_dir=v)
    ui.add_child(joy)
    var interact := make_button("✋\nInteragir",interact,Vector2(145,105))
    interact.position = Vector2(1090,570)
    interact.add_theme_font_size_override("font_size",19)
    ui.add_child(interact)

func _process(delta):
    if screen != "world" or not is_instance_valid(player):
        return
    var dir := Input.get_vector("move_left","move_right","move_up","move_down")
    if touch_dir != Vector2.ZERO:
        dir = touch_dir
    if dir.length() > 1.0:
        dir = dir.normalized()
    player.velocity = dir * 205.0
    player.move_and_slide()
    player.position.x = clamp(player.position.x,25.0,1255.0)
    player.position.y = clamp(player.position.y,245.0,570.0)
    player_trail.push_front(player.position)
    if player_trail.size() > 30:
        player_trail.pop_back()
    if player_trail.size() > 18:
        familiar_node.position = familiar_node.position.lerp(player_trail[18],min(1.0,delta*7.0))
    if Input.is_action_just_pressed("interact"):
        interact()

func interact():
    if not is_instance_valid(player) or not is_instance_valid(professor):
        return
    if player.position.distance_to(professor.position) < 125:
        show_dialogue()
    else:
        popup_message("Explorar Skeldal","Aproxime-se do professor marcado com ! no Salão das Runas.")

func show_dialogue():
    if dialogue_panel and is_instance_valid(dialogue_panel):
        dialogue_panel.queue_free()
    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(235,450)
    dialogue_panel.size = Vector2(810,215)
    dialogue_panel.add_theme_stylebox_override("panel",panel_style(Color("0c1215f2"),Color("a48a61"),2,12))
    ui.add_child(dialogue_panel)
    var vb := VBoxContainer.new()
    dialogue_panel.add_child(vb)
    var name := Label.new()
    name.text = "Mestre Halvar"
    name.add_theme_font_size_override("font_size",24)
    name.add_theme_color_override("font_color",Color("d6b56b"))
    vb.add_child(name)
    var text := Label.new()
    text.text = "%s... sua origem em %s ensinou seu primeiro caminho. Mas nenhum reino possui toda a verdade. Se deseja tornar-se um grande bruxo, deverá aprender a ouvir antes de dominar." % [save_data.name,save_data.origin]
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    text.add_theme_font_size_override("font_size",18)
    vb.add_child(text)
    vb.add_child(make_button("Continuar",func():
        save_data.professor_met=true
        save_data.quest="Conheça Skeldal e prepare-se para seu primeiro duelo"
        save_game()
        dialogue_panel.queue_free()
        popup_message("Missão concluída","O Primeiro Chamado foi iniciado.\n\nNa V0.2, Mestre Halvar entregará seu primeiro grimório e ensinará o duelo de runas.")
    ,Vector2(200,44)))

func save_game():
    if is_instance_valid(player):
        save_data.position = [player.position.x,player.position.y]
    var f := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(save_data))
        f.close()

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
    var parsed = JSON.parse_string(f.get_as_text())
    f.close()
    if typeof(parsed) == TYPE_DICTIONARY:
        save_data.merge(parsed,true)
    start_world()

func popup_message(title:String,body:String):
    var p := AcceptDialog.new()
    p.title = title
    p.dialog_text = body
    p.min_size = Vector2i(620,260)
    ui.add_child(p)
    p.popup_centered()
