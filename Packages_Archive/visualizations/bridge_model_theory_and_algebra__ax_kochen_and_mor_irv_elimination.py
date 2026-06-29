def irv_eliminate(scores: dict[int, float]) -> list[int]:
    """Run instant-runoff elimination. Returns [first_eliminated, ..., winner]."""
    active = dict(scores)
    order = []
    while len(active) > 1:
        loser = min(active, key=lambda k: active[k])
        order.append(loser)
        del active[loser]
    order.append(next(iter(active)))
    return order