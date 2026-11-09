class_name Card

var name: String
var description: String
var times_activated: int
var on_activate: Callable

func _init(card_name, card_desc, card_on_activate) -> void:
    self.name = card_name
    self.description = card_desc
    self.on_activate = card_on_activate

    

