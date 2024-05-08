extends Node

# Karten-Daten
var suits = ["C", "D", "H", "S"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

var deck = []

# UI
@onready var player_hand_container = $PlayerHand
@onready var stand_button = $UI/StandButton
@onready var hit_button = $UI/HitButton

# Funktion zum Erstellen eines neuen Kartendecks
func create_deck():
	for suit in suits:
		for rank in ranks:
			deck.append({"suit": suit, "rank": rank})
	return deck

# Funktion zum Mischen des Decks
func shuffle_deck(deck):
	deck.shuffle()
	return deck

# Funktion zum Austeilen der Karten
func deal_cards(deck, number):
	var cards = []
	for i in range(number):
		cards.append(deck.pop_front())
	return cards

# Spielstart
func start_game():
	var deck = shuffle_deck(create_deck())
	var player_cards = deal_cards(deck, 2)
	display_cards(player_cards)

# Karten im UI anzeigen
func display_cards(cards):
	for card in cards:
		var card_instance = preload("res://scenes/card.tscn").instantiate()
		card_instance.set_card(card.suit, card.rank)
		player_hand_container.add_child(card_instance)

func _ready():
	start_game()
	hit_button.connect("pressed", Callable(self, "_on_hit_button_pressed"))
	stand_button.connect("pressed", Callable(self, "_on_stand_button_pressed"))

func _on_hit_button_pressed():
	print("Hit")
	if deck.size() > 0:
		var new_card = deal_cards(deck, 1)
		display_cards(new_card)
	else:
		print("Deck ist leer.")

func _on_stand_button_pressed():
	print("Stand")
