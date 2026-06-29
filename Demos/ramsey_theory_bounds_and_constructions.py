"""
demo.py — Numerical demonstrations for two-colour Ramsey theory.

This self-contained script illustrates, with concrete computation, the results
formalised in the accompanying paper:

  * the exact values R(3,3) = 6, R(3,4) = 9, R(4,4) = 18 (lower bounds verified
    by exhaustively certifying the extremal colourings: pentagon, Mobius ladder,
    Paley graph);
  * the Erdos-Szekeres recursion R(s,t) <= R(s-1,t) + R(s,t-1) and the binomial
    bound R(s+1,t+1) <= C(s+t, s);
  * the exponential diagonal upper bound R(k+1,k+1) <= 4^k;
  * the probabilistic (Erdos) lower bound: the largest n with
    2*C(n,k) < 2^C(k,2) certifies R(k,k) > n; e.g. R(10,10) > 16;
  * the even-diagonal sandwich 2^(m-1) < R(2m,2m) <= 4^(2m-1) for m >= 4.

Run with:  python3 demo.py
Only the Python standard library is used.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Callable, Iterable


# ---------------------------------------------------------------------------
# Generic graph machinery on vertex set {0, ..., n-1}
# ---------------------------------------------------------------------------

def edges(n: int) -> list[tuple[int, int]]:
    """All unordered pairs (i, j) with i < j on n vertices."""
    return list(combinations(range(n), 2))


def is_red_clique(adj: Callable[[int, int], bool], subset: tuple[int, ...]) -> bool:
    """True iff every pair in `subset` is red-adjacent (a clique of the red graph)."""
    return all(adj(a, b) for a, b in combinations(subset, 2))


def is_blue_clique(adj: Callable[[int, int], bool], subset: tuple[int, ...]) -> bool:
    """True iff every pair in `subset` is blue (NOT red-adjacent): a clique of the complement."""
    return all(not adj(a, b) for a, b in combinations(subset, 2))


def has_mono_clique(n: int, adj: Callable[[int, int], bool], s: int, t: int) -> bool:
    """True iff the colouring `adj` on K_n has a red K_s or a blue K_t."""
    for subset in combinations(range(n), s):
        if is_red_clique(adj, subset):
            return True
    for subset in combinations(range(n), t):
        if is_blue_clique(adj, subset):
            return True
    return False


# ---------------------------------------------------------------------------
# The three classical extremal colourings (the lower-bound witnesses)
# ---------------------------------------------------------------------------

def pentagon_adj(a: int, b: int) -> bool:
    """C_5 on Z/5: a ~ b iff |a - b| == 1 (mod 5). Witnesses R(3,3) > 5."""
    d = (a - b) % 5
    return d == 1 or d == 4


def mobius_ladder_adj(a: int, b: int) -> bool:
    """C_8(1,4) on Z/8: a ~ b iff (a - b) mod 8 in {1, 4} (or its negation). R(3,4) > 8."""
    d = (a - b) % 8
    return d in (1, 4, 7)  # +-1 and +-4 == 4 (4 == -4 mod 8)


QR17: frozenset[int] = frozenset({1, 2, 4, 8, 9, 13, 15, 16})  # nonzero squares mod 17


def paley17_adj(a: int, b: int) -> bool:
    """Paley graph on Z/17: a ~ b iff (a - b) mod 17 is a nonzero quadratic residue. R(4,4) > 17."""
    return ((a - b) % 17) in QR17


# ---------------------------------------------------------------------------
# Erdos-Szekeres recursion and binomial bound (upper bounds)
# ---------------------------------------------------------------------------

def erdos_szekeres_table(max_s: int, max_t: int) -> dict[tuple[int, int], int]:
    """Upper bounds R(s,t) <= R(s-1,t) + R(s,t-1) with base R(1,t)=R(s,1)=1."""
    R: dict[tuple[int, int], int] = {}
    for s in range(1, max_s + 1):
        for t in range(1, max_t + 1):
            if s == 1 or t == 1:
                R[(s, t)] = 1
            else:
                R[(s, t)] = R[(s - 1, t)] + R[(s, t - 1)]
    return R


def binomial_bound(s: int, t: int) -> int:
    """R(s,t) <= C(s+t-2, s-1) for s,t >= 1."""
    return comb(s + t - 2, s - 1)


def diagonal_exponential_bound(k: int) -> int:
    """R(k+1, k+1) <= 4^k."""
    return 4 ** k


# ---------------------------------------------------------------------------
# Probabilistic lower bound (Erdos union bound)
# ---------------------------------------------------------------------------

def probabilistic_lower_bound(k: int) -> int:
    """
    Largest n such that the union bound 2*C(n,k) < 2^C(k,2) holds.
    Such n certifies R(k,k) > n.
    """
    threshold = 2 ** comb(k, 2)
    best = k - 1  # R(k,k) > k-1 trivially
    n = k
    while 2 * comb(n, k) < threshold:
        best = n
        n += 1
    return best


def even_diagonal_sandwich(m: int) -> tuple[int, int]:
    """For m >= 4 returns (lower, upper) with lower < R(2m,2m) <= upper."""
    assert m >= 4, "sandwich proved for m >= 4"
    return (2 ** (m - 1), 4 ** (2 * m - 1))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_exact_values() -> None:
    print("=" * 64)
    print("EXACT RAMSEY VALUES (lower bounds via extremal colourings)")
    print("=" * 64)

    # R(3,3) = 6 : pentagon escapes on 5 vertices.
    escapes = not has_mono_clique(5, pentagon_adj, 3, 3)
    print(f"Pentagon C_5 has no mono triangle (5 -/-> (3,3)): {escapes}")
    print("  => R(3,3) > 5; with the binomial bound 6 -> (3,3), R(3,3) = 6")

    # R(3,4) = 9 : Mobius ladder escapes on 8 vertices.
    escapes = not has_mono_clique(8, mobius_ladder_adj, 3, 4)
    print(f"Mobius ladder C_8(1,4): no red K_3, no blue K_4 (8 -/-> (3,4)): {escapes}")
    print("  => R(3,4) > 8; with the parity upper bound 9 -> (3,4), R(3,4) = 9")

    # R(4,4) = 18 : Paley graph escapes on 17 vertices.
    escapes = not has_mono_clique(17, paley17_adj, 4, 4)
    print(f"Paley graph on Z/17: no mono K_4 (17 -/-> (4,4)): {escapes}")
    print("  => R(4,4) > 17; with the recursive bound 18 -> (4,4), R(4,4) = 18")
    print()


def demo_upper_bounds() -> None:
    print("=" * 64)
    print("ERDOS-SZEKERES RECURSION AND BINOMIAL BOUND")
    print("=" * 64)
    R = erdos_szekeres_table(5, 5)
    for (s, t) in [(3, 3), (3, 4), (4, 4), (4, 5), (5, 5)]:
        print(f"  recursion R({s},{t}) <= {R[(s, t)]:>3} ;"
              f"  binomial C({s + t - 2},{s - 1}) = {binomial_bound(s, t)}")
    print()
    print("Diagonal exponential bound R(k+1,k+1) <= 4^k:")
    for k in range(1, 6):
        print(f"  R({k + 1},{k + 1}) <= 4^{k} = {diagonal_exponential_bound(k)}")
    print()


def demo_lower_bounds() -> None:
    print("=" * 64)
    print("PROBABILISTIC (ERDOS) LOWER BOUND")
    print("=" * 64)
    for k in range(3, 13):
        n = probabilistic_lower_bound(k)
        print(f"  R({k},{k}) > {n:>4}   (largest n with 2*C(n,{k}) < 2^C({k},2))")
    print()
    print(f"Highlight: counting bound gives R(10,10) > {probabilistic_lower_bound(10)};")
    print("  the crude exponential form 2*n^k < 2^C(k,2) gives the certified R(10,10) > 16")
    print("  [2*16^10 = 2^41 < 2^45 = 2^C(10,2)]")
    print()
    print("Even-diagonal sandwich  2^(m-1) < R(2m,2m) <= 4^(2m-1):")
    for m in range(4, 8):
        lo, hi = even_diagonal_sandwich(m)
        print(f"  m={m}: {lo} < R({2 * m},{2 * m}) <= {hi}")
    print()


def main() -> None:
    demo_exact_values()
    demo_upper_bounds()
    demo_lower_bounds()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
