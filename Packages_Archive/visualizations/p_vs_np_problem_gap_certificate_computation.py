def compute_gap_certificate(scores: dict[int, float]) -> float:
    """Compute the gap certificate parameter gamma for IRV elimination.
    Returns the minimum gap across all elimination rounds.
    Time: O(m^2), Space: O(m) where m = number of candidates."""
    remaining = dict(scores)
    min_gap = float('inf')
    while len(remaining) > 1:
        loser = min(remaining, key=remaining.get)
        loser_score = remaining[loser]
        round_gap = min(remaining[j] - loser_score for j in remaining if j != loser)
        min_gap = min(min_gap, round_gap)
        del remaining[loser]
    return min_gap