#!/usr/bin/env python3
"""Numerical demonstrations of sharp many-fold sumset growth.

The script uses only the Python standard library.  It checks the deterministic
container barrier, constructs equality examples, enumerates explicit sumsets,
and prints a small parameter table contrasting the sharp linear barrier with
the proposed logarithmic research scale.
"""

from __future__ import annotations

from itertools import product
from math import log
from typing import Iterable, Sequence


def sumset(sets: Sequence[Iterable[int]]) -> set[int]:
    """Return all sums formed by selecting one integer from each input set."""
    normalized = [tuple(set(values)) for values in sets]
    if not normalized or any(len(values) == 0 for values in normalized):
        return set()
    return {sum(choice) for choice in product(*normalized)}


def iterative_sumset(sets: Sequence[Iterable[int]]) -> set[int]:
    """Compute a many-fold sumset by successive pairwise additions."""
    total = {0}
    for values in sets:
        current = set(values)
        if not current:
            return set()
        total = {x + a for x in total for a in current}
    return total


def sharp_lower_bound(cardinalities: Sequence[int]) -> int:
    """Return 1 + sum(m_i - 1), the sharp integer sumset lower bound."""
    if not cardinalities or any(size <= 0 for size in cardinalities):
        raise ValueError("all cardinalities must be positive")
    return 1 + sum(size - 1 for size in cardinalities)


def uniform_lower_bound(t: int, k: int) -> int:
    """Return t(k-1)+1 for t nonempty sets of size at least k."""
    if t < 1 or k < 1:
        raise ValueError("t and k must be positive")
    return t * (k - 1) + 1


def automatic_avoidance(n: int, t: int, k: int) -> bool:
    """Decide whether size alone proves no qualifying sumset fits in [n]."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return n <= t * (k - 1)


def aligned_progressions(t: int, k: int, step: int = 1) -> list[set[int]]:
    """Construct t common-step progressions attaining the sharp bound."""
    if t < 1 or k < 1 or step < 1:
        raise ValueError("t, k, and step must be positive")
    progression = {step * j for j in range(k)}
    return [set(progression) for _ in range(t)]


def logarithmic_threshold(n: int, t: int, delta: float, constant: float = 1.0) -> float:
    """Evaluate C log(n)/(log(1/delta))^(1/(t-1))."""
    if n <= 1 or t < 2 or not 0.0 < delta < 1.0 or constant <= 0.0:
        raise ValueError("need n>1, t>=2, 0<delta<1, and C>0")
    return constant * log(n) / (log(1.0 / delta) ** (1.0 / (t - 1)))


def demonstrate_small_cases() -> None:
    """Print the two concrete exclusion examples and equality cases."""
    cases = [(3, 2, 3), (3, 3, 2)]
    print("SMALL AUTOMATIC-AVOIDANCE CASES")
    for n, t, k in cases:
        lower = uniform_lower_bound(t, k)
        print(
            f"  n={n}, t={t}, k={k}: every sumset has at least {lower} "
            f"points; [n] has {n}; avoidance={automatic_avoidance(n,t,k)}"
        )

    print("\nSHARPNESS AT THE FIRST FEASIBLE CONTAINER")
    for t, k in [(2, 3), (3, 2), (4, 4)]:
        parts = aligned_progressions(t, k)
        result = iterative_sumset(parts)
        expected = uniform_lower_bound(t, k)
        assert result == set(range(expected))
        print(
            f"  t={t}, k={k}: sumset={sorted(result)}, "
            f"cardinality={len(result)}={expected}"
        )


def demonstrate_nonuniform_case() -> None:
    """Show exact growth for aligned sets of unequal cardinalities."""
    sizes = [2, 5, 7]
    parts = [set(range(size)) for size in sizes]
    result = sumset(parts)
    bound = sharp_lower_bound(sizes)
    assert len(result) == bound
    print("\nNONUNIFORM EQUALITY CASE")
    print(f"  sizes={sizes}; lower bound={bound}; actual size={len(result)}")


def demonstrate_scales() -> None:
    """Contrast the deterministic linear cutoff with the conjectural scale."""
    print("\nLINEAR BARRIER VERSUS LOGARITHMIC TARGET (C=1, delta=0.25)")
    print("       n   t   smallest k auto-excluded   logarithmic expression")
    for n in (100, 1_000, 10_000, 1_000_000):
        for t in (2, 3, 4):
            # n <= t(k-1), hence k >= ceil(n/t)+1.
            smallest = (n + t - 1) // t + 1
            target = logarithmic_threshold(n, t, 0.25)
            print(f"{n:8d}  {t:2d}  {smallest:24d}   {target:22.3f}")


def main() -> None:
    demonstrate_small_cases()
    demonstrate_nonuniform_case()
    demonstrate_scales()
    print("\nAll numerical assertions passed.")


if __name__ == "__main__":
    main()
