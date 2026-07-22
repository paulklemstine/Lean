from itertools import product
from typing import Callable, List, Tuple

Config = Tuple[int, ...]
LocalRule = Callable[[int, int, int], int]

def wolfram(number: int) -> LocalRule:
    def rule(l: int, m: int, r: int) -> int:
        return (number >> ((l << 2) | (m << 1) | r)) & 1
    return rule

def global_map(rule: LocalRule, c: Config) -> Config:
    n = len(c)
    return tuple(rule(c[(i - 1) % n], c[i], c[(i + 1) % n]) for i in range(n))

def is_bijective(rule: LocalRule, n: int) -> bool:
    cfgs = [tuple(b) for b in product((0, 1), repeat=n)]
    return len({global_map(rule, c) for c in cfgs}) == len(cfgs)

def classify_reversible(max_n: int = 8) -> List[int]:
    """Return the elementary rules reversible on all rings Z/n, 2 <= n <= max_n."""
    survivors = set(range(256))
    for n in range(2, max_n + 1):
        survivors &= {r for r in range(256) if is_bijective(wolfram(r), n)}
    return sorted(survivors)
