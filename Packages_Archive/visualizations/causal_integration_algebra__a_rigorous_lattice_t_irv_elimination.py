def round_loser(active: list[int], scores: list[float]) -> int:
    return min(active, key=lambda i: scores[i])

def irv_elimination_order(active: list[int], scores: list[float]) -> list[int]:
    active = list(active)
    order: list[int] = []
    while len(active) > 1:
        loser = round_loser(active, scores)
        order.append(loser)
        active.remove(loser)
    order.append(active[0])
    return order

def irv_winner(active: list[int], scores: list[float]) -> int:
    return irv_elimination_order(active, scores)[-1]