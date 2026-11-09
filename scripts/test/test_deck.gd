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

func test_counter_increment():
	test_counter += 1
