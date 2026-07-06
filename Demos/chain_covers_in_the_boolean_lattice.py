"""
Numerical demonstrations for the chain-cover lower bound of the Boolean lattice.

Main theorem: any family of chains whose union covers every subset of an
n-element set must contain at least C(n, floor(n/2)) chains -- the size of the
middle layer, which is an antichain of maximum size.

This file is self-contained: it depends only on the Python standard library.
Run `python demo.py` to see the demonstrations.
"""

from __future__ import annotations

from itertools import combinations
from math import comb, log2, pi, sqrt
from typing import Dict, FrozenSet, List, Tuple


# ---------------------------------------------------------------------------
# Basic combinatorial helpers
# ---------------------------------------------------------------------------

def all_subsets(n: int) -> List[FrozenSet[int]]:
    """Return every subset of {0, ..., n-1} as a frozenset."""
    ground = range(n)
    result: List[FrozenSet[int]] = []
    for k in range(n + 1):
        for combo in combinations(ground, k):
            result.append(frozenset(combo))
    return result


def middle_layer(n: int) -> List[FrozenSet[int]]:
    """All subsets of size floor(n/2): the widest antichain of the lattice."""
    k = n // 2
    return [frozenset(c) for c in combinations(range(n), k)]


def middle_layer_size(n: int) -> int:
    """The chain-cover lower bound: C(n, floor(n/2))."""
    return comb(n, n // 2)


def counting_bound(n: int) -> float:
    """The weaker length-based lower bound: 2^n / (n+1)."""
    return (2 ** n) / (n + 1)


# ---------------------------------------------------------------------------
# Order-theoretic predicates
# ---------------------------------------------------------------------------

def comparable(s: FrozenSet[int], t: FrozenSet[int]) -> bool:
    """True iff s subseteq t or t subseteq s."""
    return s <= t or t <= s


def is_chain(family: List[FrozenSet[int]]) -> bool:
    """True iff every pair in `family` is comparable under inclusion."""
    return all(comparable(a, b) for a, b in combinations(family, 2))


def is_antichain(family: List[FrozenSet[int]]) -> bool:
    """True iff no two distinct members of `family` are comparable."""
    return all(not comparable(a, b) for a, b in combinations(family, 2))


# ---------------------------------------------------------------------------
# Symmetric chain decomposition via bracket matching (achieves the bound)
# ---------------------------------------------------------------------------

def _bracket_key(bits: Tuple[int, ...]) -> Tuple[int, ...]:
    """
    Parenthesis-matching key for a bit string: the canonical bottom of its chain.

    Treat 1 as '(' (open) and 0 as ')' (close). Match each close with the
    nearest unmatched open to its left. Matched positions keep their values;
    setting every *unmatched* position to 0 yields the minimum element of the
    symmetric chain, which serves as a unique key for that chain.
    """
    stack: List[int] = []
    matched: set[int] = set()
    for i, b in enumerate(bits):
        if b == 1:
            stack.append(i)
        else:  # b == 0, a close bracket -- match with nearest unmatched open
            if stack:
                open_i = stack.pop()
                matched.add(open_i)
                matched.add(i)
    return tuple(bits[i] if i in matched else 0 for i in range(len(bits)))


def symmetric_chain_decomposition(n: int) -> List[List[FrozenSet[int]]]:
    """
    Partition all 2^n subsets into C(n, floor(n/2)) symmetric chains.

    Two subsets lie on the same chain iff they share the same matched-bracket
    skeleton; within a chain, the free (unmatched) positions are filled from all
    zeros up to all ones, giving a strictly increasing chain of subsets.
    """
    groups: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for subset_bits in range(2 ** n):
        bits = tuple((subset_bits >> i) & 1 for i in range(n))
        key = _bracket_key(bits)
        groups.setdefault(key, []).append(bits)

    chains: List[List[FrozenSet[int]]] = []
    for _key, members in groups.items():
        members_sorted = sorted(members, key=lambda b: sum(b))
        chain_sets = [frozenset(i for i, v in enumerate(b) if v == 1)
                      for b in members_sorted]
        chains.append(chain_sets)
    return chains


# ---------------------------------------------------------------------------
# Verification of a covering family against the theorem
# ---------------------------------------------------------------------------

def covers_all(n: int, chains: List[List[FrozenSet[int]]]) -> bool:
    """True iff the union of the chains contains every subset of {0,...,n-1}."""
    covered = set()
    for c in chains:
        covered.update(c)
    return len(covered) == 2 ** n


def verify_lower_bound(n: int, chains: List[List[FrozenSet[int]]]) -> bool:
    """
    Check the theorem for a specific covering family: it must be a family of
    genuine chains, it must cover everything, and its size must be at least the
    middle-layer bound.
    """
    assert all(is_chain(c) for c in chains), "some family member is not a chain"
    assert covers_all(n, chains), "family does not cover the lattice"
    return len(chains) >= middle_layer_size(n)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_middle_layer_is_antichain(n: int = 5) -> None:
    print(f"[1] Middle layer of B_{n} is an antichain")
    M = middle_layer(n)
    print(f"    |M_{n}| = {len(M)} = C({n},{n//2}) = {middle_layer_size(n)}")
    print(f"    is_antichain(M) = {is_antichain(M)}")
    print()


def demo_scd_achieves_bound(n: int = 5) -> None:
    print(f"[2] Symmetric chain decomposition of B_{n}")
    chains = symmetric_chain_decomposition(n)
    print(f"    number of chains = {len(chains)}")
    print(f"    lower bound C({n},{n//2}) = {middle_layer_size(n)}")
    print(f"    all are genuine chains = {all(is_chain(c) for c in chains)}")
    print(f"    covers every subset   = {covers_all(n, chains)}")
    print(f"    verify_lower_bound    = {verify_lower_bound(n, chains)}")
    print()


def demo_bound_comparison(max_n: int = 12) -> None:
    print("[3] Antichain bound vs. counting bound")
    print(f"    {'n':>3} {'C(n,n/2)':>12} {'2^n/(n+1)':>14} {'ratio':>8} "
          f"{'sqrt(2n/pi)':>12}")
    for n in range(1, max_n + 1):
        anti = middle_layer_size(n)
        cnt = counting_bound(n)
        ratio = anti / cnt
        asymp = sqrt(2 * n / pi)
        print(f"    {n:>3} {anti:>12} {cnt:>14.2f} {ratio:>8.3f} {asymp:>12.3f}")
    print()


def demo_log_scale_gap(max_n: int = 200) -> None:
    print("[4] Logarithmic gap approaches (1/2) log2(n) + const")
    for n in (10, 50, 100, max_n):
        gap = log2(middle_layer_size(n)) - log2(counting_bound(n))
        predicted = 0.5 * log2(n) + 0.5 * log2(2 / pi)
        print(f"    n={n:>4}: log2 gap = {gap:8.4f}   "
              f"(1/2)log2 n + c = {predicted:8.4f}")
    print()


def demo_divisor_lattice(exponents: Tuple[int, ...] = (2, 1, 3)) -> None:
    print(f"[5] Divisor-lattice generalization, exponents {exponents}")
    # peak coefficient of prod_i (1 + x + ... + x^{e_i})
    poly: List[int] = [1]
    for e in exponents:
        factor = [1] * (e + 1)
        new = [0] * (len(poly) + len(factor) - 1)
        for i, a in enumerate(poly):
            for j, b in enumerate(factor):
                new[i + j] += a * b
        poly = new
    peak = max(poly)
    print(f"    Gaussian product polynomial coefficients = {poly}")
    print(f"    chain-cover number = peak coefficient    = {peak}")
    if all(e == 1 for e in exponents):
        k = len(exponents)
        print(f"    squarefree check: C({k},{k//2}) = {comb(k, k // 2)}")
    print()


def main() -> None:
    print("=" * 68)
    print("Chain covers in the Boolean lattice: numerical demonstrations")
    print("=" * 68)
    print()
    demo_middle_layer_is_antichain(5)
    demo_scd_achieves_bound(5)
    demo_bound_comparison(12)
    demo_log_scale_gap(200)
    demo_divisor_lattice((2, 1, 3))
    demo_divisor_lattice((1, 1, 1, 1))


if __name__ == "__main__":
    main()
