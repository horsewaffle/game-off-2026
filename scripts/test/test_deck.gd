extends Node3D

var test_counter: int = 0

func _ready():
	run_card_test()



func run_card_test():
	print("[CARD INIT TEST]")
	test_counter = 0
	var test_id = "test_1"
	var test_name = "Test Card 1"
	var test_desc = "Used to test initialising cards"
	var card_1 = Card.new(test_id, test_name, test_desc, test_counter_increment)

	assert(card_1.id == test_id, "ID does not match")
	assert(card_1.name == test_name, "Name does not match")
	assert(card_1.description == test_desc, "Description does not match")

	card_1.activate()
	assert(test_counter == 1, "Callback function does not activate")
	print("[CARD INIT TEST PASS]")

func run_deck_test():
	print("[EMPTY DECK INIT TEST]")
	var test_deck = Deck.new([])
	assert(test_deck.get_roster_size() == 0, "Roster size should be 0 for empty deck")
	assert(test_deck.get_pool_size() == 0, "Roster size should be 0 for empty deck")
	assert(test_deck.draw_one() == null, "Drawing from empty deck should return null")
	print("[EMPTY DECK INIT TEST PASS]")

	print("[ADD CARD TO DECK TEST]")
	var test_card = Card.new("test_01", "Test Card", "Test Desc", null)
	test_deck.add_to_roster(test_card)
	assert(test_deck.get_roster_size() == 1, "Roster size should increment when adding card")
	assert(test_deck.get_pool_size() == 0, "Pool size should not increment when adding to roster")
	print("[ADD CARD TO DECK TEST PASS]")

	print("[RESET POOL TEST]")
	test_deck.reset_deck()
	assert(test_deck.get_roster_size() == test_deck.get_pool_size() == 1, "Pool should be reset to roster on deck reset")
	print("[RESET POOL TEST PASS]")

	print("[DRAW CARD TEST]")
	var drawn_card = test_deck.draw_one()
	assert(drawn_card == test_card, "Drawn card should be reference to card inserted to deck")
	assert(test_deck.get_roster_size() == 1, "Roster should be unaffected by drawing")
	assert(test_deck.get_pool_size() == 0, "Card should be removed from pool when drawn")
	print("[DRAW CARD TEST PASS]")

func test_counter_increment():
	test_counter += 1
