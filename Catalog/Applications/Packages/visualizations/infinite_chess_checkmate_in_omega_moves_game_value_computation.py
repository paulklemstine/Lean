def game_value(pos):
    if not pos.moves:
        return 0
    return max(game_value(child) for child in pos.moves) + 1