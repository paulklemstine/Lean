import math

def compute_gap_certificate(scores: dict[int, float]) -> float:
    """Compute minimum gap across all IRV elimination rounds. O(m^2) time."""
    active = dict(scores)
    min_gap = math.inf
    while len(active) > 1:
        loser = min(active, key=lambda k: (active[k], k))
        gap = min(v for k, v in active.items() if k != loser) - active[loser]
        min_gap = min(min_gap, gap)
        del active[loser]
    return min_gap

def certified_radius(gamma: float, K: float) -> float:
    """Certified L-inf robustness radius: r* = gamma / (2K)."""
    return gamma / (2 * K) if K > 0 else float('inf')

# Example
scores = {0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0, 4: 4.2}
gamma = compute_gap_certificate(scores)
K = 2.5  # Lipschitz constant of score function
print(f"Min gap: {gamma:.3f}, Lipschitz K: {K}, Certified radius: {certified_radius(gamma, K):.4f}")
