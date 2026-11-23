class_name CardFunctions

const MAX_BIT: int = 8

static func bsr1(damage: int):
	return damage * 2

static func bsr2(damage: int):
	return damage * 4
	
static func bm81(damage:int):
	var out = String.num_int64(damage, 2).pad_zeros(MAX_BIT)
	var length = out.length()
	out[length-8] = "1"
	return out.bin_to_int()

static func get_card_info(card_id: String):
	match(card_id):
		"bsr1":
			return ["Bitshift Right 1", "1", "R"]
		"bsr2":
			return ["Bitshift Right 2", "2", "R"]
		"bm81":
			return ["Bitmask 8 =1", "8", "1"]
