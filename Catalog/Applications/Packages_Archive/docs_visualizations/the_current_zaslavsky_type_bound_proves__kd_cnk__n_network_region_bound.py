from math import comb, log2
from typing import List

def zaslavsky(m: int, n: int) -> int:
    return sum(comb(m, k) for k in range(n + 1))

def network_region_bound(input_dim: int, hidden_widths: List[int]) -> int:
    """Max linear regions for a ReLU network."""
    result = 1
    for w in hidden_widths:
        result *= zaslavsky(w, input_dim)
    return result

# Compare architectures with same total neurons (N=20, d=5)
architectures = [
    ('1x20', [20]),
    ('2x10', [10, 10]),
    ('4x5',  [5, 5, 5, 5]),
    ('5x4',  [4, 4, 4, 4, 4]),
    ('10x2', [2]*10),
    ('20x1', [1]*20),
]
for name, widths in architectures:
    bound = network_region_bound(5, widths)
    print(f'{name:>6}: {bound:>12,} regions (log2 = {log2(bound):.1f})')