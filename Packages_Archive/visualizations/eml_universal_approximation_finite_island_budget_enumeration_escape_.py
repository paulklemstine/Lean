from __future__ import annotations
from typing import List

def K_upper_bound(k: int) -> int:
    return 2 * k + 2

def generators_within_budget(n: int) -> List[int]:
    return [k for k in range(0, n) if K_upper_bound(k) <= n]

def report_escape(n_max: int = 12) -> None:
    for n in range(2, n_max + 1, 2):
        ks = generators_within_budget(n)
        print(f'budget n={n}: generators {ks}, count {len(ks)}')
