extends Control
# BRUXOS DE MIDGARD V0.1.3 - PRIMEIRA VERSAO JOGAVEL
const NOMES=["ALDAR","EIRA","KELLEN","NYA","TORIN","SIV"]
const ORIGENS=["FOGO","ÁGUA","FERRO","TERRA"]
const FAMILIARES=["LOBO","CORVO","RAPOSA","CORUJA"]
var nome="Eirik"
var personagem=0
var origem=0
var familiar=0
var touch_dir=Vector2.ZERO
var player=null
var quest=false
var herb=false
var ruin=false
var battle_enemy=8
var battle_player=20
var mana=1
var turn=1
var status_label=null

func _ready(): tela_menu()
func limpar():
    touch_dir=Vector2.ZERO
    player=null
    for n in get_children(): n.queue_free()
    await get_tree().process_frame
func fundo(path):
    var t=TextureRect.new(); t.texture=load(path); t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    t.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(t)
func botao(txt,pos,tam,cb):
    var b=Button.new(); b.text=txt; b.position=pos; b.size=tam; b.add_theme_font_size_override("font_size",18)
    b.pressed.connect(cb); add_child(b); return b
func hotspot(pos,tam,cb):
    var b=Button.new(); b.flat=true; b.text=""; b.position=pos; b.size=tam
    b.modulate=Color(1,1,1,0.025); b.pressed.connect(cb); add_child(b)
func titulo(txt):
    var l=Label.new(); l.text=txt; l.position=Vector2(260,28); l.size=Vector2(760,50)
    l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; l.add_theme_font_size_override("font_size",32)
    l.add_theme_color_override("font_color",Color("f2e7cf")); add_child(l)
func tela_menu():
    await limpar(); fundo("res://assets/menu_aprovado.jpg")
    # Hitboxes align with the four painted buttons in the approved menu.
    hotspot(Vector2(605,238),Vector2(385,66),continuar)
    hotspot(Vector2(605,314),Vector2(385,66),tela_nome)
    hotspot(Vector2(605,390),Vector2(385,66),opcoes)
    hotspot(Vector2(605,466),Vector2(385,66),creditos)
func continuar():
    if nome!="Eirik" or quest: entrar_skeldal()
    else: aviso("Continuar","Comece uma Nova Jornada primeiro.")
func tela_nome():
    await limpar(); fundo("res://assets/nome_fundo.jpg")
    var shade=ColorRect.new(); shade.color=Color(0.01,0.02,0.03,0.82); shade.position=Vector2(270,110); shade.size=Vector2(740,500); add_child(shade)
    titulo("SUA JORNADA COMEÇA")
    var sub=Label.new(); sub.text="Todo grande bruxo tem um nome.\nComo você será lembrado em Midgard?"
    sub.position=Vector2(365,180); sub.size=Vector2(550,80); sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    sub.add_theme_font_size_override("font_size",20); add_child(sub)
    var e=LineEdit.new(); e.name="Nome"; e.placeholder_text="Digite seu nome..."
    e.position=Vector2(370,290); e.size=Vector2(540,62); e.add_theme_font_size_override("font_size",22); add_child(e)
    botao("CONTINUAR",Vector2(440,390),Vector2(400,58),nome_ok)
    botao("VOLTAR",Vector2(40,640),Vector2(180,50),tela_menu)
func nome_ok():
    var v=(get_node("Nome") as LineEdit).text.strip_edges(); nome=v if v!="" else "Eirik"; tela_personagens()
func tela_personagens():
    await limpar(); fundo("res://assets/personagens_aprovados.jpg")
    # Exact cards from approved art, left-to-right.
    for i in 6: hotspot(Vector2(30+i*203,135),Vector2(185,405),escolher_personagem.bind(i))
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),tela_nome)
func escolher_personagem(i):
    personagem=i; tela_origens()
func tela_origens():
    await limpar(); fundo("res://assets/origens_aprovadas.jpg")
    for i in 4: hotspot(Vector2(45+i*300,125),Vector2(270,480),escolher_origem.bind(i))
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),tela_personagens)
func escolher_origem(i):
    origem=i; tela_familiares()
func tela_familiares():
    await limpar(); fundo("res://assets/familiares_aprovados.jpg")
    for i in 4: hotspot(Vector2(45+i*300,125),Vector2(270,480),escolher_familiar.bind(i))
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),tela_origens)
func escolher_familiar(i):
    familiar=i; tela_confirmacao()
func tela_confirmacao():
    await limpar(); fundo("res://assets/menu_aprovado.jpg")
    var sh=ColorRect.new(); sh.color=Color(0.01,0.025,0.035,0.90); sh.position=Vector2(560,110); sh.size=Vector2(620,470); add_child(sh)
    titulo("PRONTO PARA MIDGARD?")
    var l=Label.new(); l.text="Nome: %s\n\nAparência: %s\nOrigem: %s\nFamiliar: %s\n\nSua origem é seu primeiro caminho,\nnão seu destino."%[nome,NOMES[personagem],ORIGENS[origem],FAMILIARES[familiar]]
    l.position=Vector2(630,190); l.size=Vector2(480,300); l.add_theme_font_size_override("font_size",23); add_child(l)
    botao("INICIAR JORNADA",Vector2(720,500),Vector2(350,58),entrar_skeldal)
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),tela_familiares)

func entrar_skeldal():
    await limpar(); fundo("res://assets/skeldal.jpg")
    var shade=ColorRect.new(); shade.color=Color(0,0,0,0.08); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shade.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(shade)
    player=ColorRect.new(); player.color=Color(0.25,0.75,1.0,0.95); player.position=Vector2(620,390); player.size=Vector2(24,34); add_child(player)
    var rune=Label.new(); rune.text="ᚱ"; rune.position=Vector2(-4,-5); rune.size=Vector2(32,38); rune.add_theme_font_size_override("font_size",28); player.add_child(rune)
    var js=preload("res://scripts/analog_joystick.gd").new(); js.position=Vector2(45,500); js.size=Vector2(180,180); js.direction_changed.connect(joy); add_child(js)
    botao("INTERAGIR",Vector2(1050,570),Vector2(190,65),interagir_skeldal)
    botao("☰",Vector2(1190,20),Vector2(60,50),tela_menu)
    botao("MAPA",Vector2(1030,20),Vector2(140,50),tela_mapa)
    status_label=Label.new(); status_label.text="Skeldal • Procure Mestre Halvar"; status_label.position=Vector2(350,20); status_label.size=Vector2(580,42)
    status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; status_label.add_theme_font_size_override("font_size",20); add_child(status_label)

func joy(v): touch_dir=v
func _process(delta):
    if player!=null and is_instance_valid(player):
        var k=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
        var d=touch_dir if touch_dir.length()>0.08 else k
        player.position+=d*220.0*delta
        player.position.x=clamp(player.position.x,230.0,1020.0)
        player.position.y=clamp(player.position.y,130.0,610.0)

func interagir_skeldal():
    if not quest:
        tela_missao()
    elif not herb:
        tela_exploracao()
    elif not ruin:
        tela_ruinas()
    else:
        tela_duelo()

func tela_missao():
    await limpar(); fundo("res://assets/missao.jpg")
    var l=Label.new(); l.text="Mestre Halvar\n\nHá algo estranho nas ruínas ao norte.\nInvestigue os símbolos e traga o que encontrar."
    l.position=Vector2(570,250); l.size=Vector2(600,220); l.add_theme_font_size_override("font_size",22); add_child(l)
    botao("ACEITAR MISSÃO",Vector2(700,520),Vector2(350,60),aceitar_missao)
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),entrar_skeldal)
func aceitar_missao():
    quest=true; tela_exploracao()

func tela_exploracao():
    await limpar(); fundo("res://assets/exploracao.jpg")
    titulo("FLORESTA AO NORTE")
    if not herb:
        botao("COLETAR ERVA RÚNICA",Vector2(790,520),Vector2(350,60),coletar_erva)
    else:
        botao("SEGUIR PARA AS RUÍNAS",Vector2(790,520),Vector2(350,60),tela_ruinas)
    botao("VOLTAR A SKELDAL",Vector2(35,640),Vector2(220,48),entrar_skeldal)
func coletar_erva():
    herb=true; aviso("Item coletado","Erva Rúnica adicionada ao inventário.")
    await get_tree().create_timer(0.35).timeout
    tela_ruinas()

func tela_ruinas():
    await limpar(); fundo("res://assets/ruinas.jpg")
    titulo("UM SINAL NAS RUÍNAS")
    var l=Label.new(); l.text="Um símbolo diferente...\nUma quinta runa?"; l.position=Vector2(400,470); l.size=Vector2(480,90)
    l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; l.add_theme_font_size_override("font_size",23); add_child(l)
    botao("EXAMINAR RUNA",Vector2(465,575),Vector2(350,58),examinar_runa)
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),tela_exploracao)
func examinar_runa():
    ruin=true; tela_duelo()

func tela_duelo():
    await limpar(); fundo("res://assets/duelo.jpg")
    battle_enemy=8; battle_player=20; mana=1; turn=1
    criar_hud_batalha()
func criar_hud_batalha():
    status_label=Label.new(); status_label.position=Vector2(390,35); status_label.size=Vector2(500,80)
    status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; status_label.add_theme_font_size_override("font_size",22); add_child(status_label)
    atualizar_batalha()
    botao("MONTANHA (+1 mana)",Vector2(110,570),Vector2(235,70),carta_montanha)
    botao("APRENDIZ (1)\n2 dano",Vector2(360,570),Vector2(235,70),carta_aprendiz)
    botao("BOLA DE FOGO (3)\n4 dano",Vector2(610,570),Vector2(235,70),carta_fogo)
    botao("PROTEGER (2)\n+3 vida",Vector2(860,570),Vector2(235,70),carta_proteger)
    botao("PASSAR",Vector2(1110,570),Vector2(130,70),passar_turno)
func atualizar_batalha():
    if status_label: status_label.text="Lobo Sombrio: %d/8   •   %s: %d/20   •   Mana: %d   •   Turno %d"%[battle_enemy,nome,battle_player,mana,turn]
func carta_montanha():
    mana+=1; atualizar_batalha()
func carta_aprendiz():
    if mana>=1: mana-=1; battle_enemy-=2; resolver_batalha()
func carta_fogo():
    if mana>=3: mana-=3; battle_enemy-=4; resolver_batalha()
    else: aviso("Mana insuficiente","Você precisa de 3 de mana.")
func carta_proteger():
    if mana>=2: mana-=2; battle_player=min(20,battle_player+3); resolver_batalha()
    else: aviso("Mana insuficiente","Você precisa de 2 de mana.")
func passar_turno():
    battle_player-=2; turn+=1; mana=min(7,turn); resolver_batalha()
func resolver_batalha():
    if battle_enemy<=0:
        aviso("Vitória!","O Lobo Sombrio foi derrotado.\nVocê encontrou um Fragmento Rúnico.")
        ruin=true; herb=true
    elif battle_player<=0:
        aviso("Derrota","Você retorna a Skeldal para se recuperar.")
    atualizar_batalha()

func tela_mapa():
    await limpar(); fundo("res://assets/mapa.jpg")
    botao("VOLTAR",Vector2(35,640),Vector2(180,48),entrar_skeldal)

func opcoes(): aviso("Opções","Áudio será incluído depois da validação desta versão jogável.")
func creditos(): aviso("Créditos","Bruxos de Midgard — O Caminho das Runas\nProtótipo independente.")
func aviso(t,x):
    var a=AcceptDialog.new(); a.title=t; a.dialog_text=x; add_child(a); a.popup_centered()
