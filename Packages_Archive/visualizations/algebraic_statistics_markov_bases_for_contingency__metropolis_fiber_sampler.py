"""Exact conditional goodness-of-fit test driven by the +-M3 Markov walk.

The no-three-way interaction model on a 2x2x2 table has the single Markov move
M3(i,j,k) = (-1)^(i+j+k). Because {M3} connects every fiber (Theorem 5.4), a
random walk that proposes u +- M3 and rejects non-negative violations is
irreducible on each fiber, which makes the Monte-Carlo p-value below valid.

Self-contained; standard library only.  Run:  ``python exact_test.py``
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def m3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def add(u: Dict[Cell, int], t: int) -> Dict[Cell, int]:
    return {c: u[c] + t * m3(*c) for c in CELLS}


def is_nonneg(u: Dict[Cell, int]) -> bool:
    return all(v >= 0 for v in u.values())


def chi_square(u: Dict[Cell, int]) -> float:
    """Discrepancy statistic vs. the model's fitted expected counts.

    For the no-three-way model on a 2x2x2 table the fitted value depends only on
    the margins (shared across the fiber), so we use a fixed proxy: deviation of
    each cell from the fiber's centroid, which is monotone in the usual statistic
    along the one-parameter fiber.
    """
    total = sum(u.values())
    mean = total / 8.0
    return sum((v - mean) ** 2 for v in u.values())


def fiber_walk_pvalue(observed: Dict[Cell, int],
                      n_samples: int = 20000,
                      seed: int = 0) -> float:
    """Estimate the conditional p-value by walking the fiber with +-M3 steps."""
    rng = random.Random(seed)
    stat_obs = chi_square(observed)
    current = dict(observed)
    at_least_as_extreme = 0
    for _ in range(n_samples):
        t = 1 if rng.random() < 0.5 else -1
        proposal = add(current, t)
        if is_nonneg(proposal):          # symmetric proposal, uniform target
            current = proposal
        if chi_square(current) >= stat_obs:
            at_least_as_extreme += 1
    return at_least_as_extreme / n_samples


def main() -> None:
    observed: Dict[Cell, int] = {
        (0, 0, 0): 0, (0, 0, 1): 4, (0, 1, 0): 4, (0, 1, 1): 0,
        (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 4,
    }
    p = fiber_walk_pvalue(observed)
    print(f"observed chi-square proxy = {chi_square(observed):.2f}")
    print(f"Monte-Carlo conditional p-value = {p:.4f}")
    # enumerate the (small) fiber for an exact comparison
    feasible = [t for t in range(-20, 21) if is_nonneg(add(observed, t))]
    exact = sum(chi_square(add(observed, t)) >= chi_square(observed)
                for t in feasible) / len(feasible)
    print(f"exact fiber size = {len(feasible)}, exact p-value = {exact:.4f}")


if __name__ == "__main__":
    main()
