"""
demo.py — The Oracle Counting Barrier: numerical demonstrations.

Self-contained Python (standard library only) demonstrating every headline result
of the package:

  * oracle_card                      : |Oracle N| = 3 ** N
  * oracle_not_covered (generic)     : |P| < a ** N  =>  some oracle escapes
  * budget_gap_exists                : every fixed budget b ** k is outrun by 3 ** N
  * binary_insufficient              : 2 ** N < 3 ** N for N >= 1
  * computable_fraction_tendsto_zero : C / 3 ** N -> 0
  * binary_fraction_eq               : 2 ** N / 3 ** N == (2/3) ** N
  * binary_fraction_tendsto_zero     : (2/3) ** N -> 0
  * oracle_diagonal_escape           : explicit Cantor-diagonal escaping oracle
  * oracle_comp_card                 : |Oracle N -> Oracle N| = 3 ** (N * 3 ** N)
  * oracle_comp_jump                 : 3 ** N < 3 ** (N * 3 ** N) for N >= 1
  * consistent_oracles_escape        : independent 3-block defeats sub-3**k budgets

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, List, Optional, Tuple


# ----------------------------------------------------------------------------- #
# Core counting facts
# ----------------------------------------------------------------------------- #

def oracle_card(n: int, a: int = 3) -> int:
    """Number of a-valued oracles on n statements: a ** n  (Theorem oracle_card)."""
    return a ** n


def composition_card(n: int) -> int:
    """|Oracle N -> Oracle N| = 3 ** (N * 3 ** N)  (Theorem oracle_comp_card)."""
    return 3 ** (n * (3 ** n))


def reachable_fraction(n: int, budget: int, a: int = 3) -> Fraction:
    """Exact fraction of a-valued oracles a budget of `budget` programs can reach."""
    total = oracle_card(n, a)
    return Fraction(min(budget, total), total)


def binary_fraction(n: int) -> Fraction:
    """Binary-reachable fraction 2 ** N / 3 ** N, which equals (2/3) ** N exactly."""
    return Fraction(2 ** n, 3 ** n)


def smallest_n_outrunning_budget(b: int, k: int) -> int:
    """Smallest N with b ** k < 3 ** N  (constructive budget_gap_exists)."""
    budget = b ** k
    n = 0
    while not (budget < 3 ** n):
        n += 1
    return n


# ----------------------------------------------------------------------------- #
# Constructive Cantor diagonal  (Theorem oracle_diagonal_escape)
# ----------------------------------------------------------------------------- #

def diagonal_escape(descriptions: List[List[int]], a: int) -> List[int]:
    """
    Given N descriptions, each an a-valued oracle on N statements
    (descriptions[i][j] in {0,...,a-1}), return the explicit escaping oracle
    g[i] = (descriptions[i][i] + 1) % a.

    Requires a >= 2 so the diagonal flip always changes the value.
    """
    assert a >= 2, "diagonal flip needs an alphabet of at least two verdicts"
    n = len(descriptions)
    return [(descriptions[i][i] + 1) % a for i in range(n)]


def verify_escape(descriptions: List[List[int]], g: List[int]) -> bool:
    """Certify that g equals none of the descriptions (it escapes all of them)."""
    return all(descriptions[i] != g for i in range(len(descriptions)))


# ----------------------------------------------------------------------------- #
# Generic coverage barrier  (Theorem oracle_not_covered_generic)
# ----------------------------------------------------------------------------- #

def find_uncovered_oracle(
    programs: List[Tuple[int, ...]], n: int, a: int = 3
) -> Optional[Tuple[int, ...]]:
    """
    Brute-force witness of the coverage barrier: if |programs| < a ** n, return some
    a-valued oracle not appearing in `programs`; else return None. Demonstrates the
    pigeonhole content for small n.
    """
    covered = set(programs)
    for oracle in product(range(a), repeat=n):
        if oracle not in covered:
            return oracle
    return None


# ----------------------------------------------------------------------------- #
# Robustness to logical structure  (Theorem consistent_oracles_escape)
# ----------------------------------------------------------------------------- #

def consistent_block_lower_bound(k: int) -> int:
    """An independent 3-valued block of size k contributes >= 3 ** k consistent oracles."""
    return 3 ** k


def consistency_barrier_bites(program_count: int, k: int) -> bool:
    """True iff a sub-3**k program space must miss some consistent oracle."""
    return program_count < consistent_block_lower_bound(k)


# ----------------------------------------------------------------------------- #
# Demonstrations
# ----------------------------------------------------------------------------- #

def demo_census() -> None:
    print("=" * 70)
    print("1. The Census of Oracles:  |Oracle N| = 3 ** N")
    print("=" * 70)
    for n in [0, 1, 2, 5, 10, 20, 100]:
        print(f"   N = {n:>3}:  3 ** N = {oracle_card(n):,}")
    print()


def demo_information_deficit() -> None:
    print("=" * 70)
    print("2. Information deficit and the exact geometric law (2/3) ** N")
    print("=" * 70)
    print(f"   {'N':>4} | {'2**N':>22} | {'3**N':>26} | {'2**N/3**N == (2/3)**N':>22}")
    print("   " + "-" * 80)
    for n in [0, 1, 2, 5, 10, 20]:
        bf = binary_fraction(n)
        geom = Fraction(2, 3) ** n
        assert bf == geom, "binary_fraction_eq failed!"
        ok = "EXACT" if bf == geom else "MISMATCH"
        print(f"   {n:>4} | {2 ** n:>22,} | {3 ** n:>26,} | {float(bf):>18.10f}  {ok}")
    print("   binary_insufficient: 2**N < 3**N strictly for N >= 1, equal at N = 0.")
    print()


def demo_fraction_vanishes() -> None:
    print("=" * 70)
    print("3. Computable fraction -> 0  for any constant budget C")
    print("=" * 70)
    for C in [1_000, 10 ** 9]:
        print(f"   budget C = {C:,}")
        for n in [5, 10, 20, 40]:
            frac = reachable_fraction(n, C)
            print(f"      N = {n:>3}:  C / 3**N = {float(frac):.3e}")
    print()


def demo_budget_gap() -> None:
    print("=" * 70)
    print("4. Every fixed budget b**k is eventually outrun by 3 ** N")
    print("=" * 70)
    for (b, k) in [(2, 10), (2, 64), (10, 100)]:
        n = smallest_n_outrunning_budget(b, k)
        print(f"   budget {b}**{k} = {b**k:.3e};  smallest N with b**k < 3**N is N = {n}")
        print(f"      3**{n} = {3 ** n:.3e}  >  {b ** k:.3e}")
    print()


def demo_diagonal() -> None:
    print("=" * 70)
    print("5. Constructive Cantor diagonal: an EXPLICIT escaping oracle")
    print("=" * 70)
    a = 3
    descriptions = [
        [0, 1, 2, 0],
        [1, 1, 1, 1],
        [2, 2, 2, 2],
        [0, 0, 0, 0],
    ]
    g = diagonal_escape(descriptions, a)
    print(f"   {len(descriptions)} descriptions (rows) over alphabet {{0,1,2}}:")
    for i, row in enumerate(descriptions):
        print(f"      f[{i}] = {row}   (diagonal entry f[{i}][{i}] = {row[i]})")
    print(f"   diagonal escape g = {g}   (g[i] = (f[i][i] + 1) mod 3)")
    print(f"   escapes every description? {verify_escape(descriptions, g)}")
    print()


def demo_coverage_witness() -> None:
    print("=" * 70)
    print("6. Coverage barrier witness: |P| < 3**N forces an uncovered oracle")
    print("=" * 70)
    n, a = 3, 3  # 27 oracles
    programs = [(0, 0, 0), (1, 1, 1), (2, 2, 2), (0, 1, 2)]  # only 4 programs
    miss = find_uncovered_oracle(programs, n, a)
    print(f"   N = {n}, alphabet a = {a}, total oracles = {a**n}")
    print(f"   program space size |P| = {len(programs)} < {a**n}")
    print(f"   an uncovered oracle: {miss}")
    print()


def demo_finite_jump() -> None:
    print("=" * 70)
    print("7. The finite Turing jump:  3**N  <  3 ** (N * 3 ** N)")
    print("=" * 70)
    for n in [1, 2, 3]:
        evals = oracle_card(n)
        comps = composition_card(n)
        digits = len(str(comps))
        print(f"   N = {n}:  |Oracle N| = {evals:,}")
        print(f"          |Oracle N -> Oracle N| = 3**(N*3**N) has {digits:,} digits")
        print(f"          jump holds (eval < comp)? {evals < comps}")
    print()


def demo_robustness() -> None:
    print("=" * 70)
    print("8. Robustness: an independent 3-block defeats sub-3**k budgets")
    print("=" * 70)
    for k, prog in [(3, 20), (5, 200), (10, 10 ** 4)]:
        bound = consistent_block_lower_bound(k)
        bites = consistency_barrier_bites(prog, k)
        print(f"   independent block size k = {k}: >= 3**k = {bound:,} consistent oracles")
        print(f"      program space {prog:,} < 3**k ?  barrier still bites: {bites}")
    print()


def main() -> None:
    demo_census()
    demo_information_deficit()
    demo_fraction_vanishes()
    demo_budget_gap()
    demo_diagonal()
    demo_coverage_witness()
    demo_finite_jump()
    demo_robustness()
    print("All demonstrations complete — every headline result reproduced numerically.")


if __name__ == "__main__":
    main()
