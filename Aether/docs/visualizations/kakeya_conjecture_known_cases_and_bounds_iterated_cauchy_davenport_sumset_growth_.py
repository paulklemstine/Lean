from __future__ import annotations
from typing import Set, Tuple

Point = Tuple[int, int]


def iterated_sumset_growth(seed: Set[int], num_steps: int, p: int) -> list[int]:
    """Cauchy-Davenport iterated sumset growth in Z/p.

    Computes |kA| for k = 0, 1, ..., num_steps where kA = A + A + ... + A
    (k copies, with 0A = {0}), and returns the list of cardinalities.

    Each step forms the pointwise sumset modulo p; by the Cauchy-Davenport
    inequality the size grows by at least |A|-1 per step until it saturates at p.

    Complexity: O(num_steps * p * |seed|) time, O(p) space.
    """
    current: Set[int] = {0}
    sizes: list[int] = [len(current)]
    for _ in range(num_steps):
        current = {(a + x) % p for a in seed for x in current}
        sizes.append(len(current))
        if len(current) == p:  # saturated: stays the whole group forever
            sizes.extend([p] * (num_steps - len(sizes) + 1))
            break
    return sizes[: num_steps + 1]


def predicted_growth(seed_size: int, num_steps: int, p: int) -> list[int]:
    """The proven lower bound min(p, k*(|A|-1)+1) for k = 0..num_steps."""
    return [min(p, k * (seed_size - 1) + 1) for k in range(num_steps + 1)]
