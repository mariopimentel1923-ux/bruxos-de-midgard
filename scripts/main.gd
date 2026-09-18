extends Node2D

const SAVE_PATH := "user://savegame.json"
const VERSION := "0.1.0"

var save_data := {
    "name": "",
    "avatar": 0,
    "origin": "Fogo",
    "familiar": "Lobo",
    "position": [640.0, 500.0],
    "quest": "Fale com seu professor no Salão das Runas",
    "professor_met": false
}
var screen := "menu"
var ui: CanvasLayer
var world: Node2D
var player: CharacterBody2D
var familiar_node: Node2D
var professor: Node2D
var interact_button: Button
var dialogue_panel: PanelContainer
var touch_dir := Vector2.ZERO
var player_trail: Array[Vector2] = []

var origins = [
    {"name":"Fogo", "symbol":"🔥", "desc":"Cinzas, coragem e transformação.", "color":Color("b95538")},
    {"name":"Água", "symbol":"🌊", "desc":"Fiordes, conhecimento e adaptação.", "color":Color("3c75a6")},
    {"name":"Ferro", "symbol":"⚙", "desc":"Forjas, disciplina e criação.", "color":Color("7c858f")},
    {"name":"Terra", "symbol":"🌿", "desc":"Raízes, comunidade e crescimento.", "color":Color("4d7d50")}
]
var familiars = [
    {"name":"Lobo", "symbol":"🐺", "desc":"Uivo de Guerra: fortalece uma criatura."},
    {"name":"Corvo", "symbol":"🐦", "desc":"Visão: ajuda a encontrar a carta certa."},
    {"name":"Raposa", "symbol":"🦊", "desc":"Astúcia: troca uma carta da mão."},
    {"name":"Coruja", "symbol":"🦉", "desc":"Presságio: observa o futuro do grimório."}
]

func _ready():
    ui = CanvasLayer.new()
    add_child(ui)
    show_menu()

func clear_scene():
    for c in get_children():
        if c != ui: c.queue_free()
    for c in ui.get_children(): c.queue_free()
    touch_dir = Vector2.ZERO

func bg_panel(color: Color) -> ColorRect:
    var r=ColorRect.new(); r.color=color; r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); return r

func title_label(text:String, size:int=44) -> Label:
    var l=Label.new(); l.text=text; l.add_theme_font_size_override("font_size",size); l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; return l

func make_button(text:String, callable:Callable, min_size:=Vector2(300,58)) -> Button:
    var b=Button.new(); b.text=text; b.custom_minimum_size=min_size; b.add_theme_font_size_override("font_size",22); b.pressed.connect(callable); return b

func center_box() -> VBoxContainer:
    var box=VBoxContainer.new(); box.set_anchors_preset(Control.PRESET_CENTER); box.position=Vector2(-240,-220); box.size=Vector2(480,440); box.alignment=BoxContainer.ALIGNMENT_CENTER; box.add_theme_constant_override("separation",14); return box

func show_menu():
    screen="menu"; clear_scene()
    ui.add_child(bg_panel(Color("172536")))
    var deco=ColorRect.new(); deco.color=Color("243d4b"); deco.position=Vector2(0,470); deco.size=Vector2(1280,250); ui.add_child(deco)
    var box=center_box(); ui.add_child(box)
    box.add_child(title_label("BRUXOS DE MIDGARD",52))
    var sub=title_label("O Caminho das Runas",24); sub.modulate=Color("d6b56b"); box.add_child(sub)
    var rune=title_label("ᚠ   ᚢ   ᚦ   ᚱ",28); rune.modulate=Color("93c9cf"); box.add_child(rune)
    box.add_child(make_button("Nova Jornada", func(): show_name()))
    var cont=make_button("Continuar", func(): load_game()); cont.disabled=not FileAccess.file_exists(SAVE_PATH); box.add_child(cont)
    box.add_child(make_button("Opções", func(): popup_message("Opções", "Configurações de áudio, desempenho e controles chegarão nas próximas versões.")))
    box.add_child(make_button("Créditos", func(): popup_message("Créditos", "Bruxos de Midgard — protótipo V0.1.0\nConcebido como um RPG nórdico de exploração e duelos de runas.")))
    var v=Label.new(); v.text="V%s • Protótipo offline" % VERSION; v.position=Vector2(20,680); ui.add_child(v)

func show_name():
    screen="creation"; clear_scene(); ui.add_child(bg_panel(Color("13212c")))
    var box=center_box(); ui.add_child(box); box.add_child(title_label("Sua jornada começa",40))
    var info=title_label("Como seu aprendiz será chamado?",22); box.add_child(info)
    var edit=LineEdit.new(); edit.placeholder_text="Nome do aprendiz"; edit.max_length=18; edit.custom_minimum_size=Vector2(420,55); edit.add_theme_font_size_override("font_size",22); box.add_child(edit)
    box.add_child(make_button("Continuar", func():
        save_data.name = edit.text.strip_edges() if edit.text.strip_edges() != "" else "Eirik"
        show_avatar()
    ))
    box.add_child(make_button("Voltar", show_menu, Vector2(200,50)))

func show_avatar():
    clear_scene(); ui.add_child(bg_panel(Color("172536")))
    var root=VBoxContainer.new(); root.position=Vector2(120,70); root.size=Vector2(1040,590); root.add_theme_constant_override("separation",18); ui.add_child(root)
    root.add_child(title_label("Escolha seu aprendiz",38))
    var grid=GridContainer.new(); grid.columns=3; grid.add_theme_constant_override("h_separation",20); grid.add_theme_constant_override("v_separation",20); root.add_child(grid)
    var names=["Aprendiz do Norte","Aprendiz das Montanhas","Aprendiz Rúnico","Aprendiz do Norte","Aprendiz das Montanhas","Aprendiz Rúnica"]
    var symbols=["🧙","🧙","🧙","🧙‍♀","🧙‍♀","🧙‍♀"]
    for i in 6:
        var b=Button.new(); b.text="%s\n%s" % [symbols[i],names[i]]; b.custom_minimum_size=Vector2(320,150); b.add_theme_font_size_override("font_size",22); b.pressed.connect(func(idx=i): save_data.avatar=idx; show_origin()); grid.add_child(b)
    root.add_child(make_button("Voltar", show_name, Vector2(200,48)))

func show_origin():
    clear_scene(); ui.add_child(bg_panel(Color("172536")))
    var root=VBoxContainer.new(); root.position=Vector2(140,60); root.size=Vector2(1000,610); root.add_theme_constant_override("separation",16); ui.add_child(root)
    root.add_child(title_label("Escolha sua região de origem",38))
    var note=title_label("Sua origem é seu primeiro caminho — não seu destino.",20); note.modulate=Color("d6b56b"); root.add_child(note)
    for o in origins:
        var b=Button.new(); b.text="%s  %s — %s" % [o.symbol,o.name,o.desc]; b.custom_minimum_size=Vector2(1000,82); b.add_theme_font_size_override("font_size",22); b.modulate=o.color.lightened(0.35); b.pressed.connect(func(n=o.name): save_data.origin=n; show_familiar()); root.add_child(b)
    root.add_child(make_button("Voltar", show_avatar, Vector2(200,48)))

func show_familiar():
    clear_scene(); ui.add_child(bg_panel(Color("172536")))
    var root=VBoxContainer.new(); root.position=Vector2(140,65); root.size=Vector2(1000,600); root.add_theme_constant_override("separation",16); ui.add_child(root)
    root.add_child(title_label("Escolha seu primeiro familiar",38))
    root.add_child(title_label("Ele caminhará ao seu lado e, futuramente, ajudará nos duelos.",19))
    for f in familiars:
        var b=Button.new(); b.text="%s  %s — %s" % [f.symbol,f.name,f.desc]; b.custom_minimum_size=Vector2(1000,82); b.add_theme_font_size_override("font_size",21); b.pressed.connect(func(n=f.name): save_data.familiar=n; show_intro()); root.add_child(b)
    root.add_child(make_button("Voltar", show_origin, Vector2(200,48)))

func show_intro():
    clear_scene(); ui.add_child(bg_panel(Color("0d1720")))
    var box=center_box(); ui.add_child(box)
    box.add_child(title_label("SKELDAL",48))
    var txt=Label.new(); txt.text="%s cresceu entre os caminhos de %s.\nHoje, acompanhado por seu %s, chega a Skeldal para iniciar seu aprendizado.\n\nQuatro caminhos são conhecidos em Midgard. Nenhum possui toda a verdade." % [save_data.name,save_data.origin,save_data.familiar]; txt.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; txt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; txt.custom_minimum_size=Vector2(600,170); txt.add_theme_font_size_override("font_size",20); box.add_child(txt)
    box.add_child(make_button("Entrar em Skeldal", func(): save_game(); start_world()))

func start_world():
    screen="world"; clear_scene(); world=Node2D.new(); add_child(world); build_world(); build_hud(); set_process(true)

func build_world():
    var ground=Polygon2D.new(); ground.polygon=PackedVector2Array([Vector2(0,0),Vector2(1280,0),Vector2(1280,720),Vector2(0,720)]); ground.color=Color("9eb6ad"); world.add_child(ground)
    # river
    add_rect(Vector2(0,570),Vector2(1280,150),Color("4e8395"))
    add_rect(Vector2(540,520),Vector2(200,200),Color("9a8971"))
    # paths
    add_rect(Vector2(560,0),Vector2(160,570),Color("b7aa8f")); add_rect(Vector2(180,310),Vector2(920,100),Color("b7aa8f"))
    # buildings
    add_building(Vector2(470,60),Vector2(340,180),"SALÃO DAS RUNAS",Color("65554a"))
    add_building(Vector2(120,120),Vector2(250,145),"FORJA",Color("755b48"))
    add_building(Vector2(910,110),Vector2(250,145),"TAVERNA",Color("6b5848"))
    add_building(Vector2(120,430),Vector2(230,120),"CASAS",Color("6c5c4e"))
    add_building(Vector2(920,430),Vector2(230,120),"MERCADO",Color("75624e"))
    # trees
    for p in [Vector2(40,50),Vector2(80,330),Vector2(400,430),Vector2(830,420),Vector2(1190,300),Vector2(1140,40),Vector2(30,470)]: add_tree(p)
    professor=Node2D.new(); professor.position=Vector2(640,275); world.add_child(professor); draw_person(professor,Color("d5d0c8"),Color("596b87"),"!")
    player=CharacterBody2D.new(); var pos=save_data.position; player.position=Vector2(float(pos[0]),float(pos[1])); world.add_child(player); draw_person(player,Color("d6b28c"),origin_color(save_data.origin),"")
    familiar_node=Node2D.new(); familiar_node.position=player.position+Vector2(-45,25); world.add_child(familiar_node); draw_familiar(familiar_node)
    player_trail.clear(); for i in 30: player_trail.append(player.position)

func add_rect(pos:Vector2,size:Vector2,color:Color):
    var p=Polygon2D.new(); p.position=pos; p.polygon=PackedVector2Array([Vector2.ZERO,Vector2(size.x,0),size,Vector2(0,size.y)]); p.color=color; world.add_child(p)
func add_building(pos:Vector2,size:Vector2,label:String,color:Color):
    add_rect(pos,size,color); var roof=Polygon2D.new(); roof.polygon=PackedVector2Array([pos+Vector2(-15,15),pos+Vector2(size.x/2,-35),pos+Vector2(size.x+15,15)]); roof.color=color.darkened(0.25); world.add_child(roof); var l=Label.new(); l.text=label; l.position=pos+Vector2(10,size.y-30); l.add_theme_font_size_override("font_size",16); world.add_child(l)
func add_tree(pos:Vector2):
    var t=Node2D.new(); t.position=pos; world.add_child(t); var c=Polygon2D.new(); c.polygon=PackedVector2Array([Vector2(0,-35),Vector2(-28,25),Vector2(28,25)]); c.color=Color("315c4a"); t.add_child(c)
func draw_person(n:Node2D,skin:Color,robe:Color,mark:String):
    var body=Polygon2D.new(); body.polygon=PackedVector2Array([Vector2(-15,5),Vector2(15,5),Vector2(22,40),Vector2(-22,40)]); body.color=robe; n.add_child(body); var head=Polygon2D.new(); head.polygon=PackedVector2Array([Vector2(-11,-15),Vector2(11,-15),Vector2(13,5),Vector2(-13,5)]); head.color=skin; n.add_child(head); if mark!="": var l=Label.new(); l.text=mark; l.position=Vector2(-5,-55); l.add_theme_font_size_override("font_size",28); n.add_child(l)
func draw_familiar(n:Node2D):
    var body=Polygon2D.new(); body.polygon=PackedVector2Array([Vector2(-16,0),Vector2(13,-7),Vector2(22,7),Vector2(8,18),Vector2(-17,14)]); body.color=Color("7f8992"); n.add_child(body); var l=Label.new(); l.text={"Lobo":"🐺","Corvo":"🐦","Raposa":"🦊","Coruja":"🦉"}.get(save_data.familiar,"🐺"); l.position=Vector2(-14,-35); l.add_theme_font_size_override("font_size",24); n.add_child(l)
func origin_color(n:String)->Color:
    for o in origins: if o.name==n: return o.color
    return Color("596b87")

func build_hud():
    var top=PanelContainer.new(); top.position=Vector2(18,18); top.size=Vector2(500,100); ui.add_child(top); var vb=VBoxContainer.new(); top.add_child(vb); var l=Label.new(); l.text="%s • Origem: %s • Familiar: %s" % [save_data.name,save_data.origin,save_data.familiar]; l.add_theme_font_size_override("font_size",20); vb.add_child(l); var q=Label.new(); q.text="Missão: "+save_data.quest; q.add_theme_font_size_override("font_size",17); vb.add_child(q)
    var menu=make_button("☰", func(): save_game(); show_menu(),Vector2(60,55)); menu.position=Vector2(1195,20); ui.add_child(menu)
    interact_button=make_button("Interagir", interact,Vector2(150,60)); interact_button.position=Vector2(1090,630); ui.add_child(interact_button)
    # touch dpad
    var dirs=[{"t":"↑","p":Vector2(105,570),"v":Vector2.UP},{"t":"↓","p":Vector2(105,650),"v":Vector2.DOWN},{"t":"←","p":Vector2(25,650),"v":Vector2.LEFT},{"t":"→","p":Vector2(185,650),"v":Vector2.RIGHT}]
    for d in dirs:
        var b=Button.new(); b.text=d.t; b.position=d.p; b.size=Vector2(70,55); b.add_theme_font_size_override("font_size",28); b.button_down.connect(func(v=d.v): touch_dir=v); b.button_up.connect(func(): touch_dir=Vector2.ZERO); ui.add_child(b)

func _process(delta):
    if screen!="world" or not is_instance_valid(player): return
    var dir=Input.get_vector("move_left","move_right","move_up","move_down")
    if touch_dir!=Vector2.ZERO: dir=touch_dir
    player.velocity=dir.normalized()*190.0; player.move_and_slide(); player.position.x=clamp(player.position.x,25.0,1255.0); player.position.y=clamp(player.position.y,260.0,545.0)
    player_trail.push_front(player.position); if player_trail.size()>30: player_trail.pop_back()
    if player_trail.size()>18: familiar_node.position=familiar_node.position.lerp(player_trail[18],min(1.0,delta*6.0))
    if Input.is_action_just_pressed("interact"): interact()

func interact():
    if not is_instance_valid(player) or not is_instance_valid(professor): return
    if player.position.distance_to(professor.position)<125:
        show_dialogue()
    else:
        popup_message("Explorar Skeldal", "Aproxime-se do professor marcado com ! no Salão das Runas.")

func show_dialogue():
    if dialogue_panel and is_instance_valid(dialogue_panel): dialogue_panel.queue_free()
    dialogue_panel=PanelContainer.new(); dialogue_panel.position=Vector2(250,450); dialogue_panel.size=Vector2(780,210); ui.add_child(dialogue_panel); var vb=VBoxContainer.new(); dialogue_panel.add_child(vb)
    var name=Label.new(); name.text="Mestre Halvar"; name.add_theme_font_size_override("font_size",24); vb.add_child(name)
    var text=Label.new(); text.text="%s... sua origem em %s ensinou seu primeiro caminho. Mas nenhum reino possui toda a verdade. Se deseja tornar-se um grande bruxo, deverá aprender a ouvir antes de dominar." % [save_data.name,save_data.origin]; text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; text.add_theme_font_size_override("font_size",19); vb.add_child(text)
    var b=make_button("Continuar", func(): save_data.professor_met=true; save_data.quest="Conheça Skeldal e prepare-se para seu primeiro duelo"; save_game(); dialogue_panel.queue_free(); popup_message("Missão concluída", "O Primeiro Chamado foi iniciado.\n\nNa V0.2, Mestre Halvar entregará seu primeiro grimório e ensinará o duelo de runas."),Vector2(200,45)); vb.add_child(b)

func save_game():
    if is_instance_valid(player): save_data.position=[player.position.x,player.position.y]
    var f=FileAccess.open(SAVE_PATH,FileAccess.WRITE); if f: f.store_string(JSON.stringify(save_data)); f.close()
func load_game():
    if not FileAccess.file_exists(SAVE_PATH): return
    var f=FileAccess.open(SAVE_PATH,FileAccess.READ); var parsed=JSON.parse_string(f.get_as_text()); f.close(); if typeof(parsed)==TYPE_DICTIONARY: save_data.merge(parsed,true); start_world()
func popup_message(title:String,body:String):
    var p=AcceptDialog.new(); p.title=title; p.dialog_text=body; p.min_size=Vector2i(620,260); ui.add_child(p); p.popup_centered()
