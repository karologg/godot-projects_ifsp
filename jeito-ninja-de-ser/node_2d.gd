extends Node2D

# URL da API pública Open-Meteo (São Paulo)
const API_URL = "https://api.open-meteo.com/v1/forecast?latitude=-23.5505&longitude=-46.6333¤t=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m"

# Referências aos nós da cena
@onready var http_request = $HTTPRequest
@onready var label        = $Label
@onready var botao        = $Button

func _ready() -> void:
	# Conecta o sinal do botão à função de requisição
	botao.pressed.connect(_on_botao_pressionado)
	
	# Conecta o sinal do HTTPRequest que avisa quando a resposta chegar
	http_request.request_completed.connect(_on_request_completed)

func _on_botao_pressionado() -> void:
	label.text = "Buscando dados..."
	
	# Faz a requisição GET para a URL da API
	var erro = http_request.request(API_URL)
	
	# Verifica se houve erro ao iniciar a requisição
	if erro != OK:
		label.text = "Erro ao iniciar requisição!"

# Esta função é chamada automaticamente quando a resposta chega
func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	# Verifica se o código HTTP indica sucesso (200)
	if response_code != 200:
		label.text = "Erro HTTP: %d" % response_code
		return

	# Converte os bytes da resposta em texto
	var texto_json = body.get_string_from_utf8()

	# Faz o parse do JSON e converte em Dictionary
	var dados = JSON.parse_string(texto_json)

	# Verifica se o parse deu certo
	if dados == null:
		label.text = "Erro ao interpretar JSON!"
		return

	# Navega no JSON: dados → "current_weather" → "temperature"
	var temperatura = dados["current"]["temperature_2m"]
	var vento       = dados["current"]["wind_speed_10m"]

	# Exibe o resultado na Label
	label.text = "🌡️ Temperatura em São Paulo:\n%s°C  |  💨 Vento: %s km/h" % [temperatura, vento]
