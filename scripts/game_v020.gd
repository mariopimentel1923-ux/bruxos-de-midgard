extends Control

const HEROES=[
 {"n":"EIRA","r":"FOGO","s":"F","c":Color("#b64b35"),"fam":"LOBO","fs":"L"},
 {"n":"KELLEN","r":"ÁGUA","s":"A","c":Color("#397cac"),"fam":"CORUJA","fs":"C"},
 {"n":"NYA","r":"FERRO","s":"Fe","c":Color("#7e878c"),"fam":"CORVO","fs":"R"},
 {"n":"TORIN","r":"TERRA","s":"T","c":Color("#52784c"),"fam":"RAPOSA","fs":"P"}
]
var hi=0
var pname=""
var stage=0
var world
var player
var familiar
var joy=Vector2.ZERO
var objective
var hint
var battle
var turn_player=true
var phase=0
var hp=20
var enemy_hp=12
var mana=1
var max_mana=1
var enemy_timer=0.0
var msg
var turn_label
var phase_labels=[]
var enemy_unit_hp=3
var own_unit=false

func _ready(): title()
func wipe():
    world=null; player=null; familiar=null; battle=null; joy=Vector2.ZERO
    for x in get_children(): x.queue_free()
    await get_tree().process_frame

func rect(parent,pos,size,color):
    var r=ColorRect.new(); r.position=pos; r.size=size; r.color=color; parent.add_child(r); return r
func lab(parent,text,pos,size,fs=20,color=Color.WHITE):
    var l=Label.new(); l.text=text; l.position=pos; l.size=size
    l.add_theme_font_size_override("font_size",fs); l.add_theme_color_override("font_color",color); parent.add_child(l); return l
func btn(parent,text,pos,size,cb):
    var b=Button.new(); b.text=text; b.position=pos; b.size=size; b.add_theme_font_size_override("font_size",17); b.pressed.connect(cb); parent.add_child(b); return b
func fullbg(color):
    var r=ColorRect.new(); r.color=color; r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(r)

func title():
    await wipe(); fullbg(Color("#14242d"))
    rect(self,Vector2(0,390),Vector2(1280,330),Color("#173746"))
    for i in range(8):
        var m=Polygon2D.new(); var x=i*190.0-100
        m.polygon=PackedVector2Array([Vector2(x,390),Vector2(x+100,150+(i%3)*35),Vector2(x+230,390)])
        m.color=Color("#304650") if i%2 else Color("#263a42"); add_child(m)
    for i in range(11):
        rect(self,Vector2(80+i*105,390-(i%3)*10),Vector2(62,38),Color("#4d3b31"))
        rect(self,Vector2(95+i*105,405-(i%3)*10),Vector2(8,8),Color("#e0a34b"))
    var t=lab(self,"BRUXOS DE MIDGARD",Vector2(250,85),Vector2(780,70),45,Color("#e9dec5")); t.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var s=lab(self,"O CAMINHO DAS RUNAS",Vector2(340,155),Vector2(600,40),19,Color("#c1aa75")); s.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    btn(self,"NOVA JORNADA",Vector2(465,295),Vector2(350,58),name_screen)
    btn(self,"CONTINUAR",Vector2(465,365),Vector2(350,58),continue_game)
    btn(self,"CRÉDITOS",Vector2(465,435),Vector2(350,58),credits)

func name_screen():
    await wipe(); fullbg(Color("#10191f"))
    var t=lab(self,"SUA JORNADA COMEÇA",Vector2(340,120),Vector2(600,55),34,Color("#e9dec5")); t.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var e=LineEdit.new(); e.name="Name"; e.placeholder_text="Seu nome"; e.position=Vector2(390,280); e.size=Vector2(500,64); e.add_theme_font_size_override("font_size",23); add_child(e)
    btn(self,"CONTINUAR",Vector2(465,385),Vector2(350,58),name_ok); btn(self,"VOLTAR",Vector2(45,640),Vector2(170,48),title)
func name_ok():
    pname=(get_node("Name") as LineEdit).text.strip_edges()
    if pname=="": pname="Eirik"
    hero_screen()

func hero_screen():
    await wipe(); fullbg(Color("#0e171c"))
    var t=lab(self,"ESCOLHA SEU APRENDIZ",Vector2(330,30),Vector2(620,55),33,Color("#e9dec5")); t.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var q=lab(self,"Quatro personagens. Quatro reinos. O familiar será encontrado na primeira missão.",Vector2(230,85),Vector2(820,40),16,Color("#bdb39e")); q.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    for i in range(4): hero_card(i,Vector2(55+i*305,150))
    btn(self,"VOLTAR",Vector2(45,650),Vector2(170,45),name_screen)

func hero_card(i,pos):
    var h=HEROES[i]; var p=Panel.new(); p.position=pos; p.size=Vector2(270,445)
    var sb=StyleBoxFlat.new(); sb.bg_color=Color("#121a1e"); sb.border_color=h.c; sb.set_border_width_all(3)
    sb.corner_radius_top_left=10; sb.corner_radius_top_right=10; sb.corner_radius_bottom_left=10; sb.corner_radius_bottom_right=10
    p.add_theme_stylebox_override("panel",sb); add_child(p)
    # simple live vector portrait
    var head=ColorRect.new(); head.color=Color("#d2aa85"); head.position=Vector2(105,45); head.size=Vector2(55,62); p.add_child(head)
    var body=Polygon2D.new(); body.polygon=PackedVector2Array([Vector2(55,260),Vector2(80,115),Vector2(190,115),Vector2(215,260)]); body.color=h.c; p.add_child(body)
    var rune=Label.new(); rune.text=h.s; rune.position=Vector2(105,145); rune.size=Vector2(60,50); rune.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; rune.add_theme_font_size_override("font_size",26); p.add_child(rune)
    var n=lab(p,h.n,Vector2(10,275),Vector2(250,35),24); n.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var r=lab(p,"REINO DE "+h.r,Vector2(10,315),Vector2(250,30),16,h.c); r.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var desc=["Calma e disciplinada. O fogo exige controle.","Curioso e impulsivo. Aprende explorando.","Inventiva e inquieta. Quer entender tudo.","Protetor e tradicional. Preservar exige coragem."][i]
    var d=lab(p,desc,Vector2(25,352),Vector2(220,50),13,Color("#d0c7b5")); d.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    btn(p,"ESCOLHER",Vector2(50,405),Vector2(170,32),select_hero.bind(i))

func select_hero(i): hi=i; stage=0; enter_world()
func continue_game():
    if pname=="": name_screen()
    else: enter_world()

# ---------- REAL-TIME WORLD ----------
func enter_world():
    await wipe()
    world=Control.new(); world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(world)
    draw_map()
    player=actor(HEROES[hi].c,HEROES[hi].s,Vector2(610,430),42); world.add_child(player)
    var halvar=actor(Color("#695c50"),"H",Vector2(650,220),46); world.add_child(halvar)
    var hn=lab(halvar,"HALVAR",Vector2(-25,-24),Vector2(95,22),12,Color("#f2dfb1")); hn.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    if stage>=2:
        familiar=fam_actor(Vector2(590,465)); world.add_child(familiar)
    hud()

func draw_map():
    rect(world,Vector2.ZERO,Vector2(1280,720),Color("#4d694b"))
    var river=Polygon2D.new(); river.polygon=PackedVector2Array([Vector2(0,520),Vector2(1280,440),Vector2(1280,610),Vector2(0,690)]); river.color=Color("#315d70"); world.add_child(river)
    var road=Polygon2D.new(); road.polygon=PackedVector2Array([Vector2(555,720),Vector2(725,720),Vector2(700,0),Vector2(580,0)]); road.color=Color("#82765e"); world.add_child(road)
    for pos in [Vector2(150,130),Vector2(325,265),Vector2(850,145),Vector2(995,285)]:
        var h=Control.new(); h.position=pos; h.size=Vector2(150,115); world.add_child(h)
        rect(h,Vector2(10,38),Vector2(130,72),Color("#6b4c37"))
        var roof=Polygon2D.new(); roof.polygon=PackedVector2Array([Vector2(0,45),Vector2(75,-5),Vector2(150,45)]); roof.color=Color("#383230"); h.add_child(roof)
        rect(h,Vector2(61,72),Vector2(28,38),Color("#271e19"))
    for i in range(16):
        var t=Control.new(); t.position=Vector2(25+(i*79)%1190,80+(i*137)%530); t.size=Vector2(40,62); world.add_child(t)
        rect(t,Vector2(16,30),Vector2(8,30),Color("#4b382a"))
        var c=Polygon2D.new(); c.polygon=PackedVector2Array([Vector2(20,0),Vector2(0,44),Vector2(40,44)]); c.color=Color("#294b36"); t.add_child(c)
    var g=Panel.new(); g.position=Vector2(565,10); g.size=Vector2(150,58); world.add_child(g)
    var gl=lab(g,"RUÍNAS  ↑",Vector2(20,15),Vector2(115,28),17,Color("#d8e7e7")); gl.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

func actor(color,symbol,pos,sz):
    var a=Control.new(); a.position=pos; a.size=Vector2(sz,60)
    var body=Polygon2D.new(); body.polygon=PackedVector2Array([Vector2(5,55),Vector2(10,22),Vector2(sz-10,22),Vector2(sz-5,55)]); body.color=color; a.add_child(body)
    rect(a,Vector2(sz/2-10,3),Vector2(20,22),Color("#d2aa85"))
    var r=lab(a,symbol,Vector2(5,29),Vector2(sz-10,24),14); r.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    return a

func fam_actor(pos):
    var f=Control.new(); f.position=pos; f.size=Vector2(36,36)
    rect(f,Vector2.ZERO,Vector2(36,36),Color(0.04,0.04,0.04,0.75))
    var l=lab(f,HEROES[hi].fs,Vector2(2,5),Vector2(32,26),17,Color("#f0d9a6")); l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    return f

func hud():
    rect(self,Vector2(0,0),Vector2(1280,72),Color(0.02,0.03,0.035,0.82))
    objective=lab(self,"",Vector2(260,12),Vector2(760,45),18,Color("#efe5ce")); objective.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    hint=lab(self,"",Vector2(420,585),Vector2(440,38),17,Color("#ffe39b")); hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var j=preload("res://scripts/joystick_v020.gd").new(); j.position=Vector2(35,520); j.size=Vector2(160,160); j.moved.connect(set_joy); add_child(j)
    btn(self,"INTERAGIR",Vector2(1040,575),Vector2(200,64),interact)
    btn(self,"MENU",Vector2(1140,15),Vector2(110,42),title)
    update_objective()

func set_joy(v): joy=v
func update_objective():
    if not is_instance_valid(objective): return
    objective.text=["OBJETIVO • Fale com Mestre Halvar","OBJETIVO • Siga pela estrada norte","OBJETIVO • Ajude o animal nas ruínas","OBJETIVO • Retorne a Halvar","OBJETIVO • Enfrente a criatura rúnica"][stage]

func _process(delta):
    if is_instance_valid(player) and is_instance_valid(world):
        var k=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
        var d=joy if joy.length()>0.08 else k
        if d.length()>0.02:
            player.position+=d.normalized()*190*delta
            player.position.x=clamp(player.position.x,25.0,1210.0); player.position.y=clamp(player.position.y,78.0,650.0)
            player.rotation=sin(Time.get_ticks_msec()/90.0)*0.025
        else: player.rotation=0
        if is_instance_valid(familiar):
            familiar.position=familiar.position.lerp(player.position+Vector2(-48,28),min(1.0,delta*3.2))
        world_events()
    if is_instance_valid(battle) and not turn_player and enemy_timer>0:
        enemy_timer-=delta
        if enemy_timer<=0: enemy_action()

func world_events():
    hint.text=""
    if stage==0 and player.position.distance_to(Vector2(650,220))<125: hint.text="INTERAGIR • Mestre Halvar"
    elif stage==1 and player.position.y<115:
        stage=2
        if not is_instance_valid(familiar):
            familiar=fam_actor(Vector2(640,120)); world.add_child(familiar)
        update_objective(); dialog("UM SOM NAS RUÍNAS","Há um animal ferido junto às pedras antigas. Ele observa você, mas não foge.",func(): pass)
    elif stage==2 and player.position.distance_to(Vector2(640,120))<125: hint.text="INTERAGIR • Ajudar "+HEROES[hi].fam
    elif stage==3 and player.position.distance_to(Vector2(650,220))<125: hint.text="INTERAGIR • Mestre Halvar"
    elif stage==4: hint.text="INTERAGIR • Iniciar duelo"

func interact():
    if stage==0 and player.position.distance_to(Vector2(650,220))<140:
        dialog("MESTRE HALVAR","As pedras ao norte voltaram a emitir luz. Vá às ruínas e observe antes de agir.",func(): stage=1; update_objective())
    elif stage==2 and player.position.distance_to(Vector2(640,120))<140:
        dialog(HEROES[hi].fam,"Você liberta o animal dos fragmentos rúnicos. Ele se levanta e decide seguir você.",func(): stage=3; update_objective())
    elif stage==3 and player.position.distance_to(Vector2(650,220))<140:
        dialog("MESTRE HALVAR","Ele não segue você apenas por gratidão. Há algo reagindo ao vínculo entre vocês.",func(): stage=4; update_objective())
    elif stage==4: start_battle()

func dialog(who,text,after):
    var p=Panel.new(); p.position=Vector2(245,465); p.size=Vector2(790,195); add_child(p)
    var n=lab(p,who,Vector2(25,18),Vector2(720,28),20,Color("#e5c77e"))
    var t=lab(p,text,Vector2(25,55),Vector2(735,78),17,Color("#eee7d7")); t.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    var b=btn(p,"CONTINUAR",Vector2(590,140),Vector2(170,38),func(): p.queue_free(); after.call())

# ---------- DYNAMIC BATTLE ----------
func start_battle():
    await wipe()
    battle=Control.new(); battle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(battle)
    rect(battle,Vector2.ZERO,Vector2(1280,720),Color("#132029"))
    rect(battle,Vector2(50,135),Vector2(1180,190),Color("#29242a"))
    rect(battle,Vector2(50,345),Vector2(1180,180),Color("#1c2b26"))
    hp=20; enemy_hp=12; mana=1; max_mana=1; enemy_unit_hp=3; own_unit=false
    battle_ui(); player_turn_start()

func battle_ui():
    lab(battle,"CRIATURA RÚNICA",Vector2(30,18),Vector2(280,35),21,Color("#f0d9d0"))
    var e=lab(battle,"",Vector2(30,55),Vector2(260,30),17); e.name="EnemyHP"
    var p=lab(battle,"",Vector2(930,20),Vector2(320,35),17); p.name="PlayerHP"; p.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    turn_label=lab(battle,"",Vector2(390,12),Vector2(500,48),27); turn_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    phase_labels=[]
    for i in range(6):
        var x=lab(battle,["INÍCIO","COMPRA","PREPARAÇÃO","COMBATE","2ª PREP.","FIM"][i],Vector2(270+i*125,72),Vector2(118,30),13,Color("#777d80")); x.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; phase_labels.append(x)
    msg=lab(battle,"",Vector2(300,105),Vector2(680,34),16,Color("#ead9b6")); msg.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    field_card("GUARDIÃO RÚNICO","2 / 3",Vector2(530,185),Color("#6b3940"))
    hand_card("TERRENO\n"+HEROES[hi].r,"0",Vector2(180,555),0)
    hand_card("APRENDIZ\nRÚNICO","1",Vector2(380,555),1)
    hand_card("GOLPE\nRÚNICO","2",Vector2(580,555),2)
    hand_card("PROTEÇÃO","2",Vector2(780,555),3)
    btn(battle,"AVANÇAR FASE",Vector2(1030,615),Vector2(205,58),next_phase)
    update_battle()

func field_card(n,stats,pos,color):
    var p=Panel.new(); p.position=pos; p.size=Vector2(220,120); battle.add_child(p)
    rect(p,Vector2.ZERO,Vector2(220,120),color)
    var a=lab(p,n,Vector2(10,14),Vector2(200,48),16); a.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var s=lab(p,stats,Vector2(60,78),Vector2(100,28),20); s.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

func hand_card(n,cost,pos,id):
    var b=btn(battle,cost+" MANA\n\n"+n,pos,Vector2(170,135),play_card.bind(id)); b.name="Card"+str(id)

func player_turn_start():
    turn_player=true; phase=0; mana=max_mana
    turn_label.text="SEU TURNO"; turn_label.add_theme_color_override("font_color",Color("#8fd6ff"))
    msg.text="Seu turno começou."; highlight_phase(); update_battle()

func next_phase():
    if not turn_player: return
    phase+=1
    if phase>5: enemy_turn()
    else:
        msg.text=["Início.","Você comprou uma carta.","Jogue terrenos, criaturas ou magias.","Declare ataques.","Você pode jogar novamente.","Finalize o turno."][phase]
        highlight_phase()

func highlight_phase():
    for i in range(phase_labels.size()):
        phase_labels[i].add_theme_color_override("font_color",Color("#f2ce72") if i==phase else Color("#777d80"))

func play_card(id):
    if not turn_player: msg.text="Aguarde o oponente."; return
    if phase!=2 and phase!=4: msg.text="Jogue cartas durante a Preparação."; return
    if id==0:
        max_mana=min(7,max_mana+1); mana+=1; msg.text="Terreno baixado • +1 mana."
    elif id==1:
        if mana<1: msg.text="Mana insuficiente."; return
        mana-=1
        if not own_unit:
            own_unit=true; field_card("APRENDIZ RÚNICO","2 / 2",Vector2(530,380),HEROES[hi].c)
        msg.text="Aprendiz Rúnico entrou no campo."
    elif id==2:
        if mana<2: msg.text="Mana insuficiente."; return
        mana-=2; enemy_unit_hp-=2; flash(Vector2(635,220),"-2")
        if enemy_unit_hp<=0: enemy_hp-=2; msg.text="Guardião destruído • 2 de dano atravessaram."
        else: msg.text="Golpe Rúnico causou 2 no Guardião."
    elif id==3:
        if mana<2: msg.text="Mana insuficiente."; return
        mana-=2; hp=min(20,hp+3); flash(Vector2(1080,55),"+3"); msg.text="Proteção restaurou 3 de vida."
    update_battle(); battle_end()

func enemy_turn():
    turn_player=false
    turn_label.text="TURNO DO OPONENTE"; turn_label.add_theme_color_override("font_color",Color("#ff958b"))
    msg.text="O oponente está pensando..."
    for x in phase_labels: x.add_theme_color_override("font_color",Color("#555b5e"))
    enemy_timer=1.1; update_battle()

func enemy_action():
    msg.text="Guardião Rúnico ataca você!"
    hp-=2; flash(Vector2(1080,55),"-2"); update_battle()
    if battle_end(): return
    await get_tree().create_timer(0.9).timeout
    max_mana=min(7,max_mana+1); player_turn_start()

func flash(pos,text):
    var l=lab(battle,text,pos,Vector2(90,42),28,Color("#77e397") if text.begins_with("+") else Color("#ff6f66"))
    var tw=create_tween(); tw.tween_property(l,"position",pos+Vector2(0,-45),0.55); tw.parallel().tween_property(l,"modulate:a",0.0,0.55); tw.tween_callback(l.queue_free)

func update_battle():
    if not is_instance_valid(battle): return
    battle.get_node("EnemyHP").text="Vida: %d / 12"%enemy_hp
    battle.get_node("PlayerHP").text="%s • %d/20 • Mana %d/%d"%[pname,hp,mana,max_mana]

func battle_end():
    if enemy_hp<=0:
        turn_label.text="VITÓRIA"; msg.text="A criatura cai. A runa quebrada reage ao seu familiar."; turn_player=false; return true
    if hp<=0:
        turn_label.text="DERROTA"; msg.text="Você desperta novamente em Skeldal."; turn_player=false
        btn(battle,"VOLTAR A SKELDAL",Vector2(520,300),Vector2(250,55),enter_world); return true
    return false

func credits():
    await wipe(); fullbg(Color("#10191f"))
    var t=lab(self,"BRUXOS DE MIDGARD",Vector2(340,180),Vector2(600,60),36,Color("#e9dec5")); t.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var x=lab(self,"O Caminho das Runas\n\nV0.2.0 • protótipo jogável",Vector2(390,280),Vector2(500,120),20,Color("#c8bfaa")); x.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    btn(self,"VOLTAR",Vector2(555,500),Vector2(170,50),title)
