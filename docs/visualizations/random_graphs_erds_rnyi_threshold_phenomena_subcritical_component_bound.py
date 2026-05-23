import math
def subcritical_component_bound(n: int, k: int, c: float) -> float:
    """P[component >= k] <= n * (c*exp(1-c))^k for G(n,c/n), c<1."""
    if c >= 1 or k <= 0: return 1.0
    return min(1.0, n * (c * math.exp(1 - c)) ** k)

# Example
for k in [5, 10, 20]:
    print(f"k={k}: bound={subcritical_component_bound(1000, k, 0.5):.2e}")