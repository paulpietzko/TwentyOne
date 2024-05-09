extends Node

# Karten-Daten
var suits = ["C", "D", "H", "S"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

# UI
@onready var player_hand_container = $PlayerHand
@onready var dealer_hand_container = $DealerHand
@onready var stand_button = $UI/StandButton
@onready var hit_button = $UI/HitButton
@onready var player_score_label = $UI/PlayerScore
@onready var dealer_score_label = $UI/DealerScore
@onready var message_label = $UI/MessageLabel

# Spielvariablen
var player_score = 0
var dealer_score = 0
var game_over = false
var deck = []

func create_deck():
	deck.clear()
	for suit in suits:
		for rank in ranks:
			deck.append({"suit": suit, "rank": rank})
	deck.shuffle()

func deal_cards(container, number, reveal=true):
	var cards = []
	for i in range(number):
		if deck.size() == 0:
			print("Deck ist leer.")
			return cards
		var card_data = deck.pop_front()
		var card_instance = preload("res://scenes/card.tscn").instantiate()
		card_instance.set_card(card_data.suit, card_data.rank)
		if not reveal:
			card_instance.hide()
		container.add_child(card_instance)
		cards.append(card_instance)
	return cards

func update_scores():
	player_score = calculate_score(player_hand_container.get_children())
	dealer_score = calculate_score(dealer_hand_container.get_children())
	player_score_label.text = str(player_score)
	dealer_score_label.text = str(dealer_score)
	check_game_state()

func calculate_score(cards):
	var score = 0
	var aces = 0
	for card in cards:
		if card.rank in ["J", "Q", "K"]:
			score += 10
		elif card.rank == "A":
			aces += 1
		else:
			score += int(card.rank)
	for i in range(aces):
		if score + 11 > 21:
			score += 1
		else:
			score += 11
	return score

func check_game_state():
	if player_score > 21:
		message_label.text = "Überkauft! Spieler verliert."
		game_over = true
	elif dealer_score > 21:
		message_label.text = "Dealer überkauft! Spieler gewinnt."
		game_over = true
	if game_over:
		stand_button.disabled = true
		hit_button.disabled = true

func _on_hit_button_pressed():
	if not game_over:
		var new_cards = deal_cards(player_hand_container, 1)
		if new_cards.size() > 0:
			update_scores()
		if game_over:
			message_label.text = "Spiel beendet. Bitte neu starten."

func _on_stand_button_pressed():
	if game_over:
		return

	reveal_dealer_cards()
	update_scores()

	while dealer_score < 17 and deck.size() > 0:
		deal_cards(dealer_hand_container, 1)
		update_scores()
		if dealer_score >= 17 or game_over:
			break

	check_game_state()

func start_game():
	create_deck()
	deal_cards(player_hand_container, 2)
	deal_cards(dealer_hand_container, 2, false)

func reveal_dealer_cards():
	var dealer_cards = dealer_hand_container.get_children()
	for card in dealer_cards:
		card.show()

func _ready():
	start_game()
	hit_button.connect("pressed", Callable(self, "_on_hit_button_pressed"))
	stand_button.connect("pressed", Callable(self, "_on_stand_button_pressed"))
