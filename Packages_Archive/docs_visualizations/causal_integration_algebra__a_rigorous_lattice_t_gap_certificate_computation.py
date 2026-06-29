def round_loser(active: list[int], scores: list[float]) -> int:
    return min(active, key=lambda i: scores[i])

def elimination_gap_certificate(active: list[int], scores: list[float]) -> float:
    active = list(active)
    min_gap = float('inf')
    while len(active) > 1:
        loser = round_loser(active, scores)
        gap = min(scores[j] - scores[loser] for j in active if j != loser)
        min_gap = min(min_gap, gap)
        active.remove(loser)
    return min_gap

def certified_robustness_radius(active: list[int], scores: list[float], K: float = 1.0) -> float:
    gamma = elimination_gap_certificate(active, scores)
    return gamma / (2.0 * K) if K > 0 else float('inf')