#!/usr/bin/env python3
"""Numerical demonstrations of record-composition assembly weights.

The script computes Euler zigzag numbers with the Entringer triangle, evaluates
shifted record weights, checks concatenation and last-block recurrences, and
optionally verifies small Euler numbers by direct permutation enumeration.
Only the Python standard library is required.
"""

from __future__ import annotations

from itertools import permutations
from math import comb
from typing import Dict, Iterable, Iterator, List, Sequence, Tuple

Composition = Tuple[int, ...]


def is_down_up(values: Sequence[int]) -> bool:
    """Return whether values descend, rise, descend, rise, and so on."""
    return all(
        (values[i] > values[i + 1]) if i % 2 == 0 else (values[i] < values[i + 1])
        for i in range(len(values) - 1)
    )


def euler_zigzag_table(max_n: int) -> List[int]:
    """Return E_0 through E_max_n using the Entringer triangle.

    Time complexity is O(max_n**2) integer additions; auxiliary space is
    O(max_n), excluding the returned list.
    """
    if max_n < 0:
        raise ValueError("max_n must be nonnegative")
    row = [1]
    result = [1]
    for n in range(1, max_n + 1):
        new_row = [0] * (n + 1)
        for k in range(1, n + 1):
            new_row[k] = new_row[k - 1] + row[n - k]
        row = new_row
        result.append(row[-1])
    return result


def euler_zigzag_bruteforce(n: int) -> int:
    """Count down-up permutations directly; intended only for small n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return sum(1 for p in permutations(range(1, n + 1)) if is_down_up(p))


def validate_composition(alpha: Sequence[int]) -> None:
    """Require positive parts, as appropriate for record compositions."""
    if any(not isinstance(a, int) or isinstance(a, bool) or a <= 0 for a in alpha):
        raise ValueError("a record composition must have positive integer parts")


def record_weight_from(
    start: int, alpha: Sequence[int], euler: Sequence[int] | None = None
) -> int:
    """Compute the shifted assembly weight W_start(alpha)."""
    if start < 0:
        raise ValueError("start must be nonnegative")
    validate_composition(alpha)
    max_index = max((2 * a - 1 for a in alpha), default=0)
    table = list(euler) if euler is not None else euler_zigzag_table(max_index)
    if len(table) <= max_index:
        raise ValueError("Euler table is too short")
    total = start
    weight = 1
    for a in alpha:
        total += a
        weight *= comb(2 * total - 1, 2 * a - 1) * table[2 * a - 1]
    return weight


def record_weight(alpha: Sequence[int], euler: Sequence[int] | None = None) -> int:
    """Compute W(alpha), the unshifted record-composition assembly weight."""
    return record_weight_from(0, alpha, euler)


def compositions(n: int) -> Iterator[Composition]:
    """Generate all compositions of n in lexicographic recursive order."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        yield ()
        return
    for first in range(1, n + 1):
        for suffix in compositions(n - first):
            yield (first,) + suffix


def weight_table(n: int) -> Dict[Composition, int]:
    """Return the assembly weight of every composition of n."""
    euler = euler_zigzag_table(max(0, 2 * n - 1))
    return {alpha: record_weight(alpha, euler) for alpha in compositions(n)}


def check_factorizations(examples: Iterable[Tuple[Composition, Composition]]) -> None:
    """Assert the concatenation and final-block identities on examples."""
    for alpha, beta in examples:
        euler = euler_zigzag_table(
            max((2 * a - 1 for a in alpha + beta), default=0)
        )
        lhs = record_weight(alpha + beta, euler)
        rhs = record_weight(alpha, euler) * record_weight_from(sum(alpha), beta, euler)
        assert lhs == rhs, (alpha, beta, lhs, rhs)
        if beta:
            prefix = alpha + beta[:-1]
            a = beta[-1]
            last_rhs = record_weight(prefix, euler) * comb(
                2 * (sum(prefix) + a) - 1, 2 * a - 1
            ) * euler[2 * a - 1]
            assert lhs == last_rhs, (prefix, a, lhs, last_rhs)


def main() -> None:
    """Print representative values and perform consistency checks."""
    euler = euler_zigzag_table(9)
    print("Euler zigzag numbers E_0,...,E_9:")
    print(euler)

    print("\nDirect enumeration check through n=7:")
    for n in range(0, 8):
        brute = euler_zigzag_bruteforce(n)
        print(f"  n={n}: triangle={euler[n]}, direct={brute}")
        assert brute == euler[n]

    selected: List[Composition] = [(1,), (2,), (3,), (1, 1), (1, 2), (2, 1), (1, 1, 1)]
    print("\nSelected record-composition assembly weights:")
    for alpha in selected:
        print(f"  W{alpha} = {record_weight(alpha, euler)}")

    assert record_weight((1, 1), euler) == 3
    assert record_weight((1, 2), euler) == 20
    assert record_weight((2, 1), euler) == 10
    for n in range(1, 6):
        assert record_weight((n,), euler) == euler[2 * n - 1]

    examples = [
        ((1,), (1,)),
        ((1,), (2,)),
        ((2,), (1,)),
        ((1, 1), (2,)),
        ((2, 1), (1, 1)),
    ]
    check_factorizations(examples)
    print("\nConcatenation and last-block recurrences: all checks passed.")

    print("\nAll composition weights for n=4:")
    for alpha, value in weight_table(4).items():
        print(f"  {alpha}: {value}")


if __name__ == "__main__":
    main()
