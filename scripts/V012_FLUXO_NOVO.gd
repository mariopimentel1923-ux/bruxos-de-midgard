extends Control
# BRUXOS DE MIDGARD - V0.1.2 CLEAN BUILD
# Este é o ÚNICO script carregado por main.tscn nesta versão.
const ORIGENS=["FOGO","ÁGUA","FERRO","TERRA"]
const FAMILIARES=["LOBO","CORVO","RAPOSA","CORUJA"]
var nome="Eirik"
var personagem=0
var origem=0
var familiar=0

func _ready():
    tela_menu()

func limpar():
    for n in get_children():
        n.queue_free()
    await get_tree().process_frame

func fundo(arquivo:String):
    var t=TextureRect.new()
    t.texture=load(arquivo)
    t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    t.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(t)

func botao(texto:String,pos:Vector2,tam:Vector2,acao:Callable):
    var b=Button.new()
    b.text=texto
    b.position=pos
    b.size=tam
    b.add_theme_font_size_override("font_size",20)
    b.pressed.connect(acao)
    add_child(b)

func hotspot(pos:Vector2,tam:Vector2,acao:Callable):
    var b=Button.new()
    b.flat=true
    b.text=""
    b.position=pos
    b.size=tam
    b.modulate=Color(1,1,1,0.025)
    b.pressed.connect(acao)
    add_child(b)

func tela_menu():
    await limpar()
    fundo("res://assets/V012_MENU_NOVO.jpg")
    botao("NOVA JORNADA",Vector2(470,300),Vector2(340,58),tela_nome)
    botao("OPÇÕES",Vector2(470,370),Vector2(340,58),opcoes)
    botao("CRÉDITOS",Vector2(470,440),Vector2(340,58),creditos)

func tela_nome():
    await limpar()
    fundo("res://assets/V012_NOME_NOVO.jpg")
    var e=LineEdit.new()
    e.name="CampoNome"
    e.placeholder_text="Digite seu nome..."
    e.position=Vector2(360,280)
    e.size=Vector2(560,62)
    e.add_theme_font_size_override("font_size",22)
    add_child(e)
    botao("CONTINUAR",Vector2(440,390),Vector2(400,58),confirmar_nome)
    botao("VOLTAR",Vector2(40,630),Vector2(190,50),tela_menu)

func confirmar_nome():
    var e=get_node("CampoNome") as LineEdit
    var digitado=e.text.strip_edges()
    nome=digitado if digitado!="" else "Eirik"
    tela_personagens()

func tela_personagens():
    await limpar()
    fundo("res://assets/V012_PERSONAGENS_NOVO.jpg")
    for i in 6:
        hotspot(Vector2(25+i*207,135),Vector2(190,400),escolher_personagem.bind(i))
    botao("VOLTAR",Vector2(40,630),Vector2(190,50),tela_nome)

func escolher_personagem(i:int):
    personagem=i
    tela_origens()

func tela_origens():
    await limpar()
    fundo("res://assets/V012_ORIGENS_NOVO.jpg")
    for i in 4:
        hotspot(Vector2(55+i*300,145),Vector2(270,430),escolher_origem.bind(i))
    botao("VOLTAR",Vector2(40,630),Vector2(190,50),tela_personagens)

func escolher_origem(i:int):
    origem=i
    tela_familiares()

func tela_familiares():
    await limpar()
    fundo("res://assets/V012_FAMILIARES_NOVO.jpg")
    for i in 4:
        hotspot(Vector2(55+i*300,145),Vector2(270,430),escolher_familiar.bind(i))
    botao("VOLTAR",Vector2(40,630),Vector2(190,50),tela_origens)

func escolher_familiar(i:int):
    familiar=i
    tela_confirmacao()

func tela_confirmacao():
    await limpar()
    fundo("res://assets/V012_CONFIRMACAO_NOVO.jpg")
    var l=Label.new()
    l.text="Nome: %s\nPersonagem: %d\nOrigem: %s\nFamiliar: %s" % [nome,personagem+1,ORIGENS[origem],FAMILIARES[familiar]]
    l.position=Vector2(710,225)
    l.size=Vector2(440,190)
    l.add_theme_font_size_override("font_size",22)
    add_child(l)
    botao("INICIAR JORNADA",Vector2(850,610),Vector2(350,58),finalizar)
    botao("VOLTAR",Vector2(40,630),Vector2(190,50),tela_familiares)

func finalizar():
    aviso("Tudo certo","Fluxo novo validado. Próxima etapa: Skeldal.")

func opcoes():
    aviso("Opções","Áudio permanece desligado neste teste.")

func creditos():
    aviso("Créditos","Bruxos de Midgard — O Caminho das Runas")

func aviso(titulo:String,texto:String):
    var a=AcceptDialog.new()
    a.title=titulo
    a.dialog_text=texto
    add_child(a)
    a.popup_centered()
