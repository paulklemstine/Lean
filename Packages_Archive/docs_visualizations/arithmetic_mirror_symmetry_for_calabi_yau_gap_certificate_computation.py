def compute_elimination_gap_certificate(scores: dict[str, float]) -> float:
    """Compute the full elimination gap certificate gamma.
    This is the minimum gap across all rounds of IRV elimination.
    """
    active = dict(scores)
    min_gap = float('inf')
    while len(active) > 1:
        sorted_vals = sorted(active.values())
        gap = sorted_vals[1] - sorted_vals[0]
        min_gap = min(min_gap, gap)
        loser = min(active, key=lambda c: active[c])
        del active[loser]
    return min_gap
