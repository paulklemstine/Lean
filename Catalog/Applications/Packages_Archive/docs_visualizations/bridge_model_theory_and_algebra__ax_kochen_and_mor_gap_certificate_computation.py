def compute_gap_certificate(scores: dict[int, float]) -> tuple[float, list[tuple[int, float]]]:
    """Compute gap certificate. Returns (min_gap, per_round_gaps)."""
    active = dict(scores)
    gaps = []
    while len(active) > 1:
        sorted_vals = sorted(active.items(), key=lambda x: x[1])
        loser_id, loser_score = sorted_vals[0]
        second_score = sorted_vals[1][1]
        gaps.append((loser_id, second_score - loser_score))
        del active[loser_id]
    min_gap = min(g for _, g in gaps) if gaps else float('inf')
    return min_gap, gaps