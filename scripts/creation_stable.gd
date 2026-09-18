extends Control

const NAMES = ["Aldar","Eira","Kellen","Nya","Torin","Siv"]
const FILES = ["aldar","eira","kellen","nya","torin","siv"]
const ORIGINS = [
    ["FOGO","Paixão, força e transformação."],
    ["ÁGUA","Conhecimento, planejamento e fluxo."],
    ["FERRO","Ordem, trabalho e técnica."],
    ["TERRA","Tradição, comunidade e equilíbrio."]
]
const FAMILIARS = [
    ["LOBO","Uivo de Guerra","Uma criatura recebe +2/+1 até o fim do turno, uma vez por batalha."],
    ["CORVO","Visão de Huginn","Olhe as 3 cartas do topo, escolha uma e reorganize as demais."],
    ["RAPOSA","Astúcia","Descarte uma carta e compre uma carta."],
    ["CORUJA","Presságio","Olhe as próximas 2 cartas; escolha a do topo e coloque a outra no fundo."]
]

var player_name := "Eirik"
var avatar := 0
var origin := 0
var familiar := 0

func _ready():
    show_menu()

func clear_ui():
    for n in get_children():
        n.queue_free()

func wait_clear():
    clear_ui()
    await get_tree().process_frame

func add_bg(darken:=0.0):
    var t=TextureRect.new()
    t.texture=load("res://assets/menu_maga_v012.jpg")
    t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    add_child(t)
    if darken>0:
        var sh=ColorRect.new()
        sh.color=Color(0,0,0,darken)
        sh.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        sh.mouse_filter=Control.MOUSE_FILTER_IGNORE
        add_child(sh)

func label_new(txt:String,fs:=22)->Label:
    var l=Label.new()
    l.text=txt
    l.add_theme_font_size_override("font_size",fs)
    l.add_theme_color_override("font_color",Color("f3ead9"))
    l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    return l

func button_new(txt:String,call:Callable,sz:=Vector2(420,58))->Button:
    var b=Button.new()
    b.text=txt
    b.custom_minimum_size=sz
    b.add_theme_font_size_override("font_size",20)
    b.pressed.connect(call)
    return b

func show_menu():
    await wait_clear()
    add_bg()
    # A arte já possui os quatro botões. Colocamos áreas clicáveis transparentes exatamente sobre eles.
    var calls=[continue_test,show_name,show_options,show_credits]
    for i in 4:
        var hit=Button.new()
        hit.flat=true
        hit.text=""
        hit.position=Vector2(530,260+i*64)
        hit.size=Vector2(320,55)
        hit.modulate=Color(1,1,1,0.025)
        hit.pressed.connect(calls[i])
        add_child(hit)

func continue_test():
    var a=AcceptDialog.new()
    a.title="Continuar"
    a.dialog_text="O sistema de save será reativado junto com Skeldal."
    add_child(a)
    a.popup_centered()

func show_options():
    var a=AcceptDialog.new()
    a.title="Opções"
    a.dialog_text="Áudio será reativado depois da validação desta etapa."
    add_child(a)
    a.popup_centered()

func show_credits():
    var a=AcceptDialog.new()
    a.title="Créditos"
    a.dialog_text="Bruxos de Midgard — O Caminho das Runas\nV0.1.2"
    add_child(a)
    a.popup_centered()

func header(txt:String,sub:String=""):
    var top=ColorRect.new()
    top.color=Color(0.02,0.04,0.055,0.93)
    top.position=Vector2(0,0)
    top.size=Vector2(1280,105)
    add_child(top)
    var h=label_new(txt,34)
    h.position=Vector2(190,15); h.size=Vector2(900,45); add_child(h)
    if sub!="":
        var s=label_new(sub,17)
        s.position=Vector2(210,62); s.size=Vector2(860,30); add_child(s)

func show_name():
    await wait_clear()
    add_bg(0.58)
    header("SUA JORNADA COMEÇA","Todo grande bruxo tem um nome.")
    var e=LineEdit.new()
    e.name="NameEdit"
    e.placeholder_text="Nome do aprendiz"
    e.position=Vector2(390,235)
    e.size=Vector2(500,60)
    e.add_theme_font_size_override("font_size",22)
    add_child(e)
    var go=button_new("CONTINUAR",confirm_name,Vector2(500,60))
    go.position=Vector2(390,330); add_child(go)
    var back=button_new("VOLTAR",show_menu,Vector2(220,50))
    back.position=Vector2(530,430); add_child(back)

func confirm_name():
    var e=get_node("NameEdit") as LineEdit
    var typed=e.text.strip_edges()
    player_name=typed if typed!="" else "Eirik"
    show_avatar()

func show_avatar():
    await wait_clear()
    var base=ColorRect.new()
    base.color=Color("071117")
    base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(base)
    header("ESCOLHA SEU APRENDIZ","A aparência é sua escolha. Sua origem será definida depois.")
    for i in 6:
        var card=TextureButton.new()
        card.texture_normal=load("res://assets/apprentice_%s.jpg"%FILES[i])
        card.ignore_texture_size=true
        card.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_COVERED
        card.position=Vector2(25+i*207,125)
        card.size=Vector2(185,385)
        card.pressed.connect(select_avatar.bind(i))
        add_child(card)
        var n=label_new(NAMES[i],18)
        n.position=Vector2(25+i*207,515)
        n.size=Vector2(185,28)
        add_child(n)
    var flow=label_new("PERSONAGEM   →   ORIGEM   →   FAMILIAR   →   CONFIRMAÇÃO",17)
    flow.position=Vector2(240,570); flow.size=Vector2(800,30); add_child(flow)
    var back=button_new("VOLTAR",show_name,Vector2(190,50))
    back.position=Vector2(30,640); add_child(back)

func select_avatar(i:int):
    avatar=i
    show_origin()

func show_origin():
    await wait_clear()
    add_bg(0.72)
    header("ESCOLHA SUA ORIGEM","Quatro caminhos. Nenhum deles define sozinho quem você será.")
    var intro=label_new("%s • aparência: %s"%[player_name,NAMES[avatar]],18)
    intro.position=Vector2(300,120); intro.size=Vector2(680,30); add_child(intro)
    for i in 4:
        var b=button_new(ORIGINS[i][0]+"\n"+ORIGINS[i][1],select_origin.bind(i),Vector2(700,82))
        b.position=Vector2(290,175+i*95)
        add_child(b)
    var back=button_new("VOLTAR",show_avatar,Vector2(190,50))
    back.position=Vector2(30,640); add_child(back)

func select_origin(i:int):
    origin=i
    show_familiar()

func show_familiar():
    await wait_clear()
    add_bg(0.72)
    header("ESCOLHA SEU FAMILIAR","Um companheiro estará sempre ao seu lado — apenas um fica ativo em batalha.")
    for i in 4:
        var text=FAMILIARS[i][0]+" — "+FAMILIARS[i][1]+"\n"+FAMILIARS[i][2]
        var b=button_new(text,select_familiar.bind(i),Vector2(820,92))
        b.position=Vector2(230,145+i*108)
        add_child(b)
    var back=button_new("VOLTAR",show_origin,Vector2(190,50))
    back.position=Vector2(30,640); add_child(back)

func select_familiar(i:int):
    familiar=i
    show_confirm()

func show_confirm():
    await wait_clear()
    add_bg(0.70)
    header("PRONTO PARA MIDGARD?","Confira suas escolhas antes de iniciar a jornada.")
    var box=ColorRect.new()
    box.color=Color(0.025,0.045,0.055,0.94)
    box.position=Vector2(350,145); box.size=Vector2(580,360); add_child(box)
    var summary=label_new(
        "Nome: %s\n\nAparência: %s\nOrigem: %s\nFamiliar: %s\n\n%s"%
        [player_name,NAMES[avatar],ORIGINS[origin][0],FAMILIARS[familiar][0],FAMILIARS[familiar][1]],23)
    summary.position=Vector2(385,180); summary.size=Vector2(510,280); add_child(summary)
    var go=button_new("INICIAR JORNADA",finish_creation,Vector2(420,60))
    go.position=Vector2(430,535); add_child(go)
    var back=button_new("VOLTAR",show_familiar,Vector2(190,50))
    back.position=Vector2(30,640); add_child(back)

func finish_creation():
    var a=AcceptDialog.new()
    a.title="Criação concluída"
    a.dialog_text="Tudo certo, %s.\n\nA próxima etapa abrirá Skeldal com estas escolhas preservadas."%player_name
    add_child(a)
    a.popup_centered()
