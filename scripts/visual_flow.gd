extends Control
const ORIGINS=["FOGO","ÁGUA","FERRO","TERRA"]
const FAMILIARS=["LOBO","CORVO","RAPOSA","CORUJA"]
var player_name="Eirik"
var avatar=0
var origin=0
var familiar=0

func _ready(): show_menu()
func wipe():
    for c in get_children(): c.queue_free()
    await get_tree().process_frame
func bg(p):
    var t=TextureRect.new(); t.texture=load(p); t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    t.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(t)
func hit(pos,size,cb):
    var b=Button.new(); b.flat=true; b.text=""; b.position=pos; b.size=size
    b.modulate=Color(1,1,1,0.03); b.pressed.connect(cb); add_child(b)
func real_button(txt,pos,size,cb):
    var b=Button.new(); b.text=txt; b.position=pos; b.size=size; b.add_theme_font_size_override("font_size",20)
    b.pressed.connect(cb); add_child(b)
func show_menu():
    await wipe(); bg("res://assets/menu_reference.jpg")
    real_button("NOVA JORNADA",Vector2(470,300),Vector2(340,58),show_name)
    real_button("OPÇÕES",Vector2(470,370),Vector2(340,58),options)
    real_button("CRÉDITOS",Vector2(470,440),Vector2(340,58),credits)
func show_name():
    await wipe(); bg("res://assets/name_reference.jpg")
    var e=LineEdit.new(); e.name="Name"; e.placeholder_text="Digite seu nome..."
    e.position=Vector2(360,280); e.size=Vector2(560,60); e.add_theme_font_size_override("font_size",22); add_child(e)
    real_button("CONTINUAR",Vector2(440,390),Vector2(400,58),name_next)
    real_button("VOLTAR",Vector2(40,630),Vector2(190,50),show_menu)
func name_next():
    var e=get_node("Name"); var v=e.text.strip_edges(); player_name=v if v!="" else "Eirik"; show_chars()
func show_chars():
    await wipe(); bg("res://assets/characters_reference.jpg")
    for i in 6: hit(Vector2(25+i*207,135),Vector2(190,400),select_char.bind(i))
    real_button("VOLTAR",Vector2(40,630),Vector2(190,50),show_name)
func select_char(i): avatar=i; show_origins()
func show_origins():
    await wipe(); bg("res://assets/origins_reference.jpg")
    for i in 4: hit(Vector2(55+i*300,145),Vector2(270,430),select_origin.bind(i))
    real_button("VOLTAR",Vector2(40,630),Vector2(190,50),show_chars)
func select_origin(i): origin=i; show_familiars()
func show_familiars():
    await wipe(); bg("res://assets/familiars_reference.jpg")
    for i in 4: hit(Vector2(55+i*300,145),Vector2(270,430),select_familiar.bind(i))
    real_button("VOLTAR",Vector2(40,630),Vector2(190,50),show_origins)
func select_familiar(i): familiar=i; show_confirm()
func show_confirm():
    await wipe(); bg("res://assets/confirm_reference.jpg")
    var l=Label.new(); l.text="Nome: %s\nOrigem: %s\nFamiliar: %s"%[player_name,ORIGINS[origin],FAMILIARS[familiar]]
    l.position=Vector2(720,230); l.size=Vector2(420,180); l.add_theme_font_size_override("font_size",22); add_child(l)
    real_button("INICIAR JORNADA",Vector2(850,610),Vector2(350,58),finish)
    real_button("VOLTAR",Vector2(40,630),Vector2(190,50),show_familiars)
func finish(): popup("Criação concluída","Fluxo visual concluído. Próxima etapa: Skeldal.")
func options(): popup("Opções","Áudio será reativado após esta validação.")
func credits(): popup("Créditos","Bruxos de Midgard — O Caminho das Runas")
func popup(t,x):
    var a=AcceptDialog.new(); a.title=t; a.dialog_text=x; add_child(a); a.popup_centered()
