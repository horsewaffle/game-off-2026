class_name Deck

var roster: Array[Card]
var pool: Array[Card]

func _init(starter_roster: Array[Card]):
    self.roster = starter_roster

func reset_deck() -> void:
    self.pool = self.roster.duplicate()

func draw_one() -> Card:
    if pool.size() > 0:
        var pool_index = randi_range(0, pool.size())
        var drawn_card = pool.pop_at(pool_index)
        return drawn_card
    else:
        # TODO: Error handling for empty deck case here
        return null

func add_to_roster(card: Card):
    roster.append(card)

func remove_from_roster(card: Card):
    var target_index = roster.find(card)
    roster.pop_at(target_index)