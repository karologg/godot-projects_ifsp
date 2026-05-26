extends Node2D

# URL base da API pública dattebayo
const API_URL = "https://dattebayo-api.onrender.com/characters/"

# Referências aos nós da cena
@onready var http_request = $HTTPRequest
@onready var line_edit    = $HBoxContainer/LineEdit
@onready var botao        = $HBoxContainer/Button
@onready var label_id     = $HBoxContainer/LabelID
@onready var label_nome   = $HBoxContainer/LabelNome
@onready var label_pai    = $HBoxContainer/LabelPai
@onready var label_mae    = $HBoxContainer/LabelMae

# Onde os Jutsus serão adicionados
@onready var vbox_container = $HBoxContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	# Conecta os sinais
	botao.pressed.connect(_on_botao_pressionado)
	http_request.request_completed.connect(_on_request_completed)

func _on_botao_pressionado() -> void:
	# Pega o texto digitado pelo usuário e remove espaços extras
	var id_personagem = line_edit.text.strip_edges()
	
	# Validação simples: se estiver vazio, avisa o usuário
	if id_personagem == "":
		label_nome.text = "Por favor, digite um ID!"
		return
		
	label_nome.text = "Buscando dados do personagem..."
	
	# Monta a URL final
	var url_final = API_URL + id_personagem
	
	# Faz a requisição GET
	var erro = http_request.request(url_final)
	
	if erro != OK:
		label_nome.text = "Erro ao iniciar requisição!"

# Chamado quando a resposta da API chega
func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	# Se o ID não existir, a API vai retornar 404
	if response_code == 404:
		label_nome.text = "Personagem não encontrado!"
		return
	elif response_code != 200:
		label_nome.text = "Erro HTTP: %d" % response_code
		return

	# Converte os bytes da resposta em texto
	var texto_json = body.get_string_from_utf8()

	# Faz o parse do JSON
	var data = JSON.parse_string(texto_json)

	if data == null:
		label_nome.text = "Erro ao interpretar JSON!"
		return

	# Extraindo as informações básicas do JSON
	var id = data.get("id", 0)
	var nome = data.get("name", "Desconhecido")
	
	# Checagem de segurança para a família
	var pai = "Desconhecido"
	var mae = "Desconhecido"
	if data.has("family") and data["family"] is Dictionary:
		pai = data["family"].get("father", "Desconhecido")
		mae = data["family"].get("mother", "Desconhecido")

	# Atualizando os textos das labels fixas
	label_id.text   = "ID: %s" % str(id)
	label_nome.text = "Nome: %s" % nome
	label_pai.text  = "Pai: %s" % pai
	label_mae.text  = "Mãe: %s" % mae

	# --- Lógica solicitada para popular os Jutsus ---
	
	# 1. Limpa a lista anterior para não acumular jutsus de buscas passadas
	for child in vbox_container.get_children():
		child.queue_free()

	# Pega o array de jutsus da API (se não houver, assume uma lista vazia)
	var jutsus = data.get("jutsu", [])

	# 2. Adiciona um novo nó Label dinamicamente para cada jutsu da lista
	for jutsu in jutsus:
		var lbl = Label.new()
		lbl.text = "• " + jutsu
		vbox_container.add_child(lbl)
		
	# Caso o personagem não tenha jutsus na API, adiciona um aviso amigável
	if jutsus.size() == 0:
		var lbl_vazio = Label.new()
		lbl_vazio.text = "Nenhum jutsu registrado."
		vbox_container.add_child(lbl_vazio)
