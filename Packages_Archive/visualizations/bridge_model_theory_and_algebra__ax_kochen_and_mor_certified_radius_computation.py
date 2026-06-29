def certified_robustness_radius(scores: dict[int, float], lipschitz_K: float) -> float:
    """Compute certified L-infinity robustness radius for IRV classifier."""
    active = dict(scores)
    gaps = []
    while len(active) > 1:
        sv = sorted(active.items(), key=lambda x: x[1])
        gaps.append(sv[1][1] - sv[0][1])
        del active[sv[0][0]]
    gamma = min(gaps) if gaps else float('inf')
    return gamma / (2 * lipschitz_K) if lipschitz_K > 0 else float('inf')