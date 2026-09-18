extends Node2D

const SAVE_PATH := "user://savegame_v012.json"
const VERSION := "0.1.2-fix1"
const JOYSTICK := preload("res://scripts/virtual_joystick.gd")
const APPRENTICES := ["Aldar","Eira","Kellen","Nya","Torin","Siv"]
const APPRENTICE_FILES := ["aldar","eira","kellen","nya","torin","siv"]

var save_data := {
    "name":"", "avatar":0, "origin":"Fogo", "familiar":"Lobo",
    "position":[640.0,520.0], "stage":0,
    "quest":"Fale com Mestre Halvar", "rune_found":false, "tutorial_won":false
}
var ui:CanvasLayer
var world:Node2D
var player:CharacterBody2D
var familiar_node:Node2D
var professor:Node2D
var rune_node:Node2D
var touch_dir:=Vector2.ZERO
var screen:="menu"
var music:AudioStreamPlayer
var music_on:=true
var music_volume:=0.55
var battle_mana:=0
var battle_enemy_hp:=8
var battle_turn:=1
var battle_creature:=false
var battle_log:Label

var origins=[
    {"name":"Fogo","desc":"Paixão, criação e transformação.","color":Color("b6533c")},
    {"name":"Água","desc":"Sabedoria, fluxo e adaptação.","color":Color("3e78a8")},
    {"name":"Ferro","desc":"Disciplina, técnica e construção.","color":Color("7e8791")},
    {"name":"Terra","desc":"Vida, tradição e resistência.","color":Color("557f50")}
]
var familiars=[
    {"name":"Lobo","desc":"Uivo de Guerra — fortalece um aliado."},
    {"name":"Corvo","desc":"Visão — ajuda a encontrar a carta certa."},
    {"name":"Raposa","desc":"Astúcia — renova uma opção da mão."},
    {"name":"Coruja","desc":"Presságio — observa o que está por vir."}
]

func _ready():
    ui=CanvasLayer.new()
    add_child(ui)
    setup_music()
    show_menu()

func setup_music():
    music=AudioStreamPlayer.new()
    music.stream=load("res://assets/skeldal_ambient_original.wav")
    music.volume_db=linear_to_db(music_volume)
    music.finished.connect(_on_music_finished)
    add_child(music)
    music.play()


func _on_music_finished():
    if music_on:
        music.play()

func _on_music_toggled(value:bool):
    music_on=value
    if music_on:
        if not music.playing:
            music.play()
    else:
        music.stop()

func _on_volume_changed(value:float):
    music_volume=value
    music.volume_db=linear_to_db(max(value,0.001))

func show_credits():
    popup("Créditos","Bruxos de Midgard — V0.1.2\nProtótipo independente em desenvolvimento.\nTrilha desta versão: composição procedural original.")

func confirm_name(edit:LineEdit):
    var chosen=edit.text.strip_edges()
    save_data.name=chosen if chosen!="" else "Eirik"
    show_avatar()

func select_avatar(idx:int):
    save_data.avatar=idx
    show_avatar_detail(idx)

func select_origin(origin_name:String):
    save_data.origin=origin_name
    show_familiar()

func select_familiar(familiar_name:String):
    save_data.familiar=familiar_name
    show_confirm()

func begin_journey():
    save_data.stage=0
    save_game()
    start_world()

func _on_joystick_direction(value:Vector2):
    touch_dir=value

func save_and_menu():
    save_game()
    show_menu()

func clear_scene():
    for c in get_children():
        if c!=ui and c!=music:
            c.queue_free()
    for c in ui.get_children():
        c.queue_free()
    touch_dir=Vector2.ZERO

func style(bg:Color,border:=Color("9b8059"),w:=2,r:=9)->StyleBoxFlat:
    var s=StyleBoxFlat.new()
    s.bg_color=bg; s.border_color=border
    s.set_border_width_all(w); s.set_corner_radius_all(r)
    s.content_margin_left=14; s.content_margin_right=14
    s.content_margin_top=9; s.content_margin_bottom=9
    return s

func button(text:String,callable:Callable,size:=Vector2(300,58))->Button:
    var b=Button.new()
    b.text=text; b.custom_minimum_size=size
    b.add_theme_font_size_override("font_size",20)
    b.add_theme_stylebox_override("normal",style(Color("11181de8")))
    b.add_theme_stylebox_override("hover",style(Color("26333bed"),Color("d5b36f"),3))
    b.add_theme_stylebox_override("pressed",style(Color("080c0fed"),Color("d5b36f"),3))
    b.pressed.connect(callable)
    return b

func label(text:String,size:=20,center:=false)->Label:
    var l=Label.new(); l.text=text
    l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",Color("f0e7d5"))
    l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    if center: l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    return l

func full_bg(path:String,darken:=0.0):
    var bg=TextureRect.new()
    bg.texture=load(path); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    ui.add_child(bg)
    if darken>0:
        var sh=ColorRect.new(); sh.color=Color(0,0,0,darken)
        sh.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui.add_child(sh)

func show_menu():
    screen="menu"; clear_scene()
    full_bg("res://assets/menu_bg_v012.jpg",0.10)
    var title=label("BRUXOS DE MIDGARD",54,true); title.position=Vector2(90,45); title.size=Vector2(610,70); ui.add_child(title)
    var sub=label("O CAMINHO DAS RUNAS",23,true); sub.position=Vector2(120,112); sub.size=Vector2(550,40); ui.add_child(sub)
    var box=VBoxContainer.new(); box.position=Vector2(110,205); box.size=Vector2(390,390)
    box.add_theme_constant_override("separation",11); ui.add_child(box)
    var cont=button("CONTINUAR",load_game,Vector2(390,58)); cont.disabled=not FileAccess.file_exists(SAVE_PATH); box.add_child(cont)
    box.add_child(button("NOVA JORNADA",show_name,Vector2(390,58)))
    box.add_child(button("OPÇÕES",show_options,Vector2(390,58)))
    box.add_child(button("CRÉDITOS",show_credits,Vector2(390,58)))
    var v=label("V0.1.2 FIX 1",16); v.position=Vector2(1195,18); ui.add_child(v)

func show_options():
    clear_scene(); full_bg("res://assets/menu_bg_v012.jpg",0.55)
    var p=PanelContainer.new(); p.position=Vector2(365,125); p.size=Vector2(550,470); p.add_theme_stylebox_override("panel",style(Color("091016f2"))); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",18); p.add_child(vb)
    vb.add_child(label("OPÇÕES",38,true))
    var toggle=CheckButton.new(); toggle.text="Música"; toggle.button_pressed=music_on; toggle.add_theme_font_size_override("font_size",22)
    toggle.toggled.connect(_on_music_toggled); vb.add_child(toggle)
    var vol=HSlider.new(); vol.min_value=0; vol.max_value=1; vol.step=0.05; vol.value=music_volume
    vol.value_changed.connect(_on_volume_changed); vb.add_child(label("Volume",18)); vb.add_child(vol)
    vb.add_child(label("Controles: joystick analógico à esquerda e Interagir à direita.\nOrientação: paisagem com rotação para os dois lados.",17))
    vb.add_child(button("VOLTAR",show_menu,Vector2(250,50)))

func show_name():
    clear_scene(); full_bg("res://assets/menu_bg_v012.jpg",0.58)
    var p=PanelContainer.new(); p.position=Vector2(370,170); p.size=Vector2(540,350); p.add_theme_stylebox_override("panel",style(Color("091016f3"))); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",16); p.add_child(vb)
    vb.add_child(label("SUA JORNADA COMEÇA",34,true)); vb.add_child(label("Como seu aprendiz será chamado?",20,true))
    var e=LineEdit.new(); e.placeholder_text="Nome do aprendiz"; e.max_length=18; e.custom_minimum_size=Vector2(470,55); e.add_theme_font_size_override("font_size",22); vb.add_child(e)
    var next_btn=button("CONTINUAR",Callable(self,"confirm_name").bind(e),Vector2(470,55)); vb.add_child(next_btn)
    vb.add_child(button("VOLTAR",show_menu,Vector2(220,48)))

func show_avatar():
    screen="creation"; clear_scene()
    var bg=ColorRect.new(); bg.color=Color("081116"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui.add_child(bg)
    var head=label("ESCOLHA SEU APRENDIZ",34,true); head.position=Vector2(260,18); head.size=Vector2(760,45); ui.add_child(head)
    var note=label("A aparência é sua escolha. A origem virá depois.",18,true); note.position=Vector2(310,62); note.size=Vector2(660,30); ui.add_child(note)
    for i in 6:
        var card=TextureButton.new()
        card.texture_normal=load("res://assets/apprentice_%s.jpg" % APPRENTICE_FILES[i])
        card.ignore_texture_size=true; card.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_COVERED
        card.position=Vector2(28+i*205,112); card.size=Vector2(190,395)
        card.pressed.connect(Callable(self,"select_avatar").bind(i))
        ui.add_child(card)
        var n=label(APPRENTICES[i],18,true); n.position=Vector2(28+i*205,512); n.size=Vector2(190,28); ui.add_child(n)
    var steps=label("1  PERSONAGEM        2  ORIGEM        3  FAMILIAR        4  CONFIRMAÇÃO",17,true); steps.position=Vector2(210,570); steps.size=Vector2(860,35); ui.add_child(steps)
    var back=button("← VOLTAR",show_name,Vector2(190,52)); back.position=Vector2(30,635); ui.add_child(back)

func show_avatar_detail(idx:int):
    var p=PanelContainer.new(); p.position=Vector2(840,90); p.size=Vector2(405,560); p.add_theme_stylebox_override("panel",style(Color("071016f6"),Color("d2ac64"),3)); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",10); p.add_child(vb)
    vb.add_child(label(APPRENTICES[idx],31,true))
    var tex=TextureRect.new(); tex.texture=load("res://assets/apprentice_%s.jpg" % APPRENTICE_FILES[idx]); tex.custom_minimum_size=Vector2(300,315); tex.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; tex.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED; vb.add_child(tex)
    vb.add_child(label("Aprendiz. Sem reino definido.\nA origem e a magia serão escolhidas no próximo passo.",17,true))
    vb.add_child(button("ESCOLHER ESTE",show_origin,Vector2(330,52)))

func show_origin():
    clear_scene(); full_bg("res://assets/menu_bg_v012.jpg",0.62)
    var p=PanelContainer.new(); p.position=Vector2(150,70); p.size=Vector2(980,590); p.add_theme_stylebox_override("panel",style(Color("081016f2"))); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",12); p.add_child(vb)
    vb.add_child(label("ESCOLHA SUA ORIGEM",34,true)); vb.add_child(label("Agora sua roupa e seus primeiros ensinamentos ganham a identidade do reino.",18,true))
    for o in origins:
        var b=button("%s — %s" % [o.name,o.desc],Callable(self,"select_origin").bind(o.name),Vector2(900,78)); vb.add_child(b)
    vb.add_child(button("VOLTAR",show_avatar,Vector2(200,48)))

func show_familiar():
    clear_scene(); full_bg("res://assets/menu_bg_v012.jpg",0.64)
    var p=PanelContainer.new(); p.position=Vector2(150,70); p.size=Vector2(980,590); p.add_theme_stylebox_override("panel",style(Color("081016f2"))); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",12); p.add_child(vb)
    vb.add_child(label("ESCOLHA SEU FAMILIAR",34,true))
    for f in familiars:
        vb.add_child(button("%s — %s" % [f.name,f.desc],Callable(self,"select_familiar").bind(f.name),Vector2(900,82)))
    vb.add_child(button("VOLTAR",show_origin,Vector2(200,48)))

func show_confirm():
    clear_scene(); full_bg("res://assets/menu_bg_v012.jpg",0.65)
    var p=PanelContainer.new(); p.position=Vector2(330,110); p.size=Vector2(620,500); p.add_theme_stylebox_override("panel",style(Color("081016f2"),Color("d2ac64"),3)); ui.add_child(p)
    var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",16); p.add_child(vb)
    vb.add_child(label("PRONTO PARA MIDGARD?",36,true))
    vb.add_child(label("%s\nAparência: %s\nOrigem: %s\nFamiliar: %s" % [save_data.name,APPRENTICES[int(save_data.avatar)],save_data.origin,save_data.familiar],22,true))
    vb.add_child(label("Sua origem é seu primeiro caminho — não seu destino.",18,true))
    vb.add_child(button("COMEÇAR JORNADA",begin_journey,Vector2(470,60)))
    vb.add_child(button("VOLTAR",show_familiar,Vector2(220,48)))

func start_world():
    screen="world"; clear_scene()
    world=Node2D.new(); add_child(world)
    var bg=Sprite2D.new(); bg.texture=load("res://assets/skeldal_v012.jpg"); bg.position=Vector2(640,360); bg.scale=Vector2(1280.0/bg.texture.get_width(),720.0/bg.texture.get_height()); bg.z_index=-10; world.add_child(bg)
    professor=Node2D.new(); professor.position=Vector2(760,330); world.add_child(professor); marker(professor,"!",Color("e5bd63"))
    player=CharacterBody2D.new(); var pos=save_data.position; player.position=Vector2(float(pos[0]),float(pos[1])); player.z_index=10; world.add_child(player); draw_player(player)
    familiar_node=Node2D.new(); familiar_node.position=player.position+Vector2(-42,28); familiar_node.z_index=9; world.add_child(familiar_node); marker(familiar_node,familiar_symbol(),Color("d9d2bd"))
    build_hud()

func draw_player(n:Node2D):
    var shadow=Polygon2D.new(); shadow.polygon=PackedVector2Array([Vector2(-18,24),Vector2(18,24),Vector2(13,32),Vector2(-13,32)]); shadow.color=Color(0,0,0,0.35); n.add_child(shadow)
    var body=Polygon2D.new(); body.polygon=PackedVector2Array([Vector2(-13,-5),Vector2(13,-5),Vector2(18,27),Vector2(-18,27)]); body.color=origin_color(); n.add_child(body)
    var head=Polygon2D.new(); head.polygon=PackedVector2Array([Vector2(-10,-23),Vector2(10,-23),Vector2(11,-5),Vector2(-11,-5)]); head.color=Color("d5ae86"); n.add_child(head)
    var hair=Polygon2D.new(); hair.polygon=PackedVector2Array([Vector2(-12,-25),Vector2(11,-26),Vector2(13,-16),Vector2(-13,-15)]); hair.color=Color("3a281f"); n.add_child(hair)

func marker(n:Node2D,text:String,c:Color):
    var l=label(text,30,true); l.position=Vector2(-24,-45); l.size=Vector2(48,48); l.add_theme_color_override("font_color",c); n.add_child(l)

func familiar_symbol()->String:
    return {"Lobo":"🐺","Corvo":"🐦","Raposa":"🦊","Coruja":"🦉"}.get(save_data.familiar,"🐺")

func origin_color()->Color:
    for o in origins:
        if o.name==save_data.origin: return o.color
    return Color("65758a")

func build_hud():
    var p=PanelContainer.new(); p.position=Vector2(18,18); p.size=Vector2(510,100); p.add_theme_stylebox_override("panel",style(Color("071016e8"))); ui.add_child(p)
    var vb=VBoxContainer.new(); p.add_child(vb)
    vb.add_child(label("%s  •  %s  •  %s" % [save_data.name,save_data.origin,save_data.familiar],18))
    vb.add_child(label("MISSÃO: "+save_data.quest,15))
    var joy=JOYSTICK.new(); joy.position=Vector2(35,515); joy.size=Vector2(168,168); joy.direction_changed.connect(_on_joystick_direction); ui.add_child(joy)
    var inter=button("INTERAGIR",interact,Vector2(150,95)); inter.position=Vector2(1085,580); ui.add_child(inter)
    var menu=button("☰",save_and_menu,Vector2(58,52)); menu.position=Vector2(1200,18); ui.add_child(menu)

func _process(delta):
    if screen!="world" or not is_instance_valid(player): return
    var d=Input.get_vector("move_left","move_right","move_up","move_down")
    if touch_dir!=Vector2.ZERO: d=touch_dir
    if d.length()>1: d=d.normalized()
    player.velocity=d*220.0; player.move_and_slide()
    player.position.x=clamp(player.position.x,60.0,1220.0); player.position.y=clamp(player.position.y,165.0,640.0)
    if is_instance_valid(familiar_node): familiar_node.position=familiar_node.position.lerp(player.position+Vector2(-38,28),min(1.0,delta*5.0))
    if Input.is_action_just_pressed("interact"): interact()

func interact():
    if save_data.stage==0:
        if player.position.distance_to(professor.position)<150:
            professor_dialogue()
        else: popup("Dica","Procure Mestre Halvar, marcado com ! perto do centro de Skeldal.")
    elif save_data.stage==1:
        popup("Rumo às ruínas","Halvar abriu o caminho para as ruínas ao norte.",start_ruins)
    else:
        popup("Skeldal","Explore a vila. A próxima parte da história continuará em uma futura versão.")

func professor_dialogue():
    popup("Mestre Halvar","%s, andar por Midgard é fácil. Difícil é aprender a escolher.\n\nAntes das ruínas, você precisa aprender a defender seu grimório." % save_data.name,start_battle)

func start_battle():
    screen="battle"; clear_scene(); full_bg("res://assets/battle_v012.jpg",0.48)
    battle_mana=0; battle_enemy_hp=8; battle_turn=1; battle_creature=false
    var title=label("PRIMEIRO DUELO — TREINO DE HALVAR",28,true); title.position=Vector2(260,20); title.size=Vector2(760,40); ui.add_child(title)
    var enemy=PanelContainer.new(); enemy.position=Vector2(850,75); enemy.size=Vector2(360,150); enemy.add_theme_stylebox_override("panel",style(Color("151018e8"),Color("a94d43"))); ui.add_child(enemy)
    var ev=VBoxContainer.new(); enemy.add_child(ev); ev.add_child(label("Lobo Sombrio",25,true)); var eh=label("Vida: 8 / 8",21,true); eh.name="EnemyHP"; ev.add_child(eh)
    battle_log=label("Halvar: primeiro, baixe um Terreno para gerar mana.",18,true); battle_log.position=Vector2(220,245); battle_log.size=Vector2(840,60); ui.add_child(battle_log)
    build_battle_hand()

func build_battle_hand():
    for n in ui.get_children():
        if n.name.begins_with("Card"): n.queue_free()
    var cards=[
        ["TERRENO\nVale Rúnico","Gera 1 mana",0],
        ["CRIATURA\nAprendiz de Skeldal","2/2 • custo 1",1],
        ["MAGIA\nFaísca Rúnica","3 de dano • custo 1",2],
        ["DEFESA\nRuna de Proteção","Recupere 2 • custo 1",3]
    ]
    for i in 4:
        var b=button(cards[i][0]+"\n"+cards[i][1],Callable(self,"play_card").bind(i),Vector2(245,150))
        b.name="Card%d"%i; b.position=Vector2(115+i*265,485); ui.add_child(b)
    var pass=button("PASSAR TURNO",pass_turn,Vector2(210,55)); pass.name="CardPass"; pass.position=Vector2(1030,400); ui.add_child(pass)
    update_battle()

func play_card(idx:int):
    if idx==0:
        battle_mana+=1; battle_log.text="Você canalizou um Vale Rúnico. Mana disponível: %d."%battle_mana
    elif idx==1:
        if battle_mana<1: battle_log.text="Você precisa de mana. Jogue um Terreno primeiro."; return
        battle_mana-=1; battle_creature=true; battle_log.text="Aprendiz de Skeldal entrou em campo. No próximo turno ele poderá atacar."
    elif idx==2:
        if battle_mana<1: battle_log.text="Sem mana para conjurar Faísca Rúnica."; return
        battle_mana-=1; battle_enemy_hp-=3; battle_log.text="Faísca Rúnica causa 3 de dano!"
    elif idx==3:
        if battle_mana<1: battle_log.text="Sem mana para a Runa de Proteção."; return
        battle_mana-=1; battle_log.text="A runa envolve você. Halvar aprova sua cautela."
    update_battle()
    if battle_enemy_hp<=0: battle_win()

func pass_turn():
    battle_turn+=1
    battle_mana+=1
    if battle_creature:
        battle_enemy_hp-=2; battle_log.text="Seu Aprendiz ataca e causa 2. Um novo turno começa; você recebe 1 mana."
    else:
        battle_log.text="Novo turno. Você recebe 1 mana. Tente colocar uma criatura em campo."
    update_battle()
    if battle_enemy_hp<=0: battle_win()

func update_battle():
    var hp=ui.find_child("EnemyHP",true,false)
    if hp: hp.text="Vida: %d / 8"%max(0,battle_enemy_hp)
    var old=ui.find_child("ManaInfo",true,false)
    if old: old.queue_free()
    var m=label("Turno %d     Mana: %d     Sua vida: 20" % [battle_turn,battle_mana],20,true); m.name="ManaInfo"; m.position=Vector2(390,420); m.size=Vector2(500,40); ui.add_child(m)

func battle_win():
    save_data.tutorial_won=true; save_data.stage=1; save_data.quest="Investigue as ruínas ao norte"; save_game()
    popup("Vitória!","Você venceu seu primeiro duelo.\n\nRecompensa: Fragmento de Grimório — Faísca Rúnica.\nHalvar agora permite que você investigue as ruínas.",start_ruins)

func start_ruins():
    screen="ruins"; clear_scene(); full_bg("res://assets/ruins_v012.jpg",0.18)
    var title=label("RUÍNAS ANTIGAS — NORTE DE SKELDAL",25,true); title.position=Vector2(280,20); title.size=Vector2(720,40); ui.add_child(title)
    var info=PanelContainer.new(); info.position=Vector2(20,70); info.size=Vector2(390,115); info.add_theme_stylebox_override("panel",style(Color("071016e8"))); ui.add_child(info)
    var iv=VBoxContainer.new(); info.add_child(iv); iv.add_child(label("MISSÃO",17)); iv.add_child(label("Investigue o brilho entre as pedras.",18))
    var rune=button("◇\nEXAMINAR RUNA",find_rune,Vector2(220,105)); rune.position=Vector2(535,330); ui.add_child(rune)
    var back=button("← SKELDAL",start_world,Vector2(180,52)); back.position=Vector2(30,640); ui.add_child(back)

func find_rune():
    save_data.rune_found=true; save_data.stage=2; save_data.quest="Leve o fragmento desconhecido a Halvar"; save_game()
    popup("Um sinal nas ruínas","A pedra pulsa sob seus dedos.\n\nFogo, Água, Ferro, Terra... mas este símbolo não pertence a nenhum dos quatro caminhos.\n\nUma quinta runa?",start_world)

func popup(title:String,body:String,next:=Callable()):
    var p=AcceptDialog.new(); p.title=title; p.dialog_text=body; p.min_size=Vector2i(650,300); ui.add_child(p)
    if next.is_valid(): p.confirmed.connect(next)
    p.popup_centered()

func save_game():
    if is_instance_valid(player): save_data.position=[player.position.x,player.position.y]
    var f=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(save_data)); f.close()

func load_game():
    var f=FileAccess.open(SAVE_PATH,FileAccess.READ)
    if not f: return
    var d=JSON.parse_string(f.get_as_text()); f.close()
    if typeof(d)==TYPE_DICTIONARY: save_data.merge(d,true)
    start_world()
