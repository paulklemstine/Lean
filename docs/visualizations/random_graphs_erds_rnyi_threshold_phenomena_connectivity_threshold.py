import math
def connectivity_threshold(n: int) -> float:
    """Critical p for connectivity in G(n,p)."""
    if n <= 1: return 0.0
    return math.log(n) / n

# Example
for n in [100, 1000, 10000]:
    print(f"n={n}: p*={connectivity_threshold(n):.6f}")