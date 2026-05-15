import numpy as np

NEGINF = float("-inf")

def karp_cycle_mean(G: np.ndarray) -> float:
    """Compute maximum cycle mean using Karp's algorithm.
    
    Complexity: O(m^3) time, O(m^2) space.
    """
    m = G.shape[0]
    F = np.full((m + 1, m), NEGINF)
    F[0, :] = 0.0
    
    for k in range(1, m + 1):
        for i in range(m):
            for j in range(m):
                if F[k-1, j] != NEGINF and G[j, i] != NEGINF:
                    F[k, i] = max(F[k, i], F[k-1, j] + G[j, i])
    
    lam_star = NEGINF
    for i in range(m):
        if F[m, i] == NEGINF:
            continue
        min_val = float("inf")
        for k in range(m):
            if F[k, i] == NEGINF:
                continue
            val = (F[m, i] - F[k, i]) / (m - k)
            min_val = min(min_val, val)
        if min_val != float("inf"):
            lam_star = max(lam_star, min_val)
    
    return lam_star

# Example
G = np.array([
    [1.0, 3.0, NEGINF],
    [NEGINF, 2.0, 1.0],
    [4.0, NEGINF, 0.0]
])
print(f"Maximum cycle mean: {karp_cycle_mean(G):.4f}")  # Expected: 2.6667
