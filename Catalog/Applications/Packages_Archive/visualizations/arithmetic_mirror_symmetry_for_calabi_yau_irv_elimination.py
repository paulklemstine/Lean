def irv_elimination_order(scores: dict[str, float]) -> list[str]:
    """IRV sequential elimination. Returns [first_eliminated, ..., winner]."""
    active = dict(scores)
    order = []
    while len(active) > 1:
        loser = min(active, key=lambda c: active[c])
        order.append(loser)
        del active[loser]
    order.append(next(iter(active)))
    return order
