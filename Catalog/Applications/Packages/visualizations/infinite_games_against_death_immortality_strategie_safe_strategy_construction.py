def safe_strategy(game):
    def strategy(hist):
        safe_move = check_safe_escape(game, hist)
        return safe_move if safe_move is not None else 0
    return strategy