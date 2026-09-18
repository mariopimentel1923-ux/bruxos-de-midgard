extends Control

@onready var status: Label = $Status

func _ready():
    status.text = "MENU OK • V0.1.2"
    $Menu/NovaJornada.pressed.connect(_nova_jornada)
    $Menu/Continuar.pressed.connect(_continuar)
    $Menu/Opcoes.pressed.connect(_opcoes)
    $Menu/Creditos.pressed.connect(_creditos)
    $Voltar.pressed.connect(_voltar)

func _nova_jornada():
    status.text = "NOVA JORNADA respondeu corretamente."

func _continuar():
    status.text = "CONTINUAR respondeu corretamente."

func _opcoes():
    $Info.visible = true
    $Info/Texto.text = "OPÇÕES\n\nMúsica e volume serão reativados depois que o menu estiver validado."
    $Menu.visible = false
    $Voltar.visible = true

func _creditos():
    $Info.visible = true
    $Info/Texto.text = "CRÉDITOS\n\nBruxos de Midgard\nO Caminho das Runas\n\nProtótipo V0.1.2"
    $Menu.visible = false
    $Voltar.visible = true

func _voltar():
    $Info.visible = false
    $Menu.visible = true
    $Voltar.visible = false
    status.text = "MENU OK • V0.1.2"
