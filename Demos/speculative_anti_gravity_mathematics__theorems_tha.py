"""
Anti-Gravity Theorems in the Cryptographic Hardness Hierarchy
=============================================================

Numerical demonstration of the formally verified results about the
one-way-function (OWF) stratum.

A theorem of the stratum is modelled by a single natural number, its
*dependency index* ``depth``.  From it we read off two invariants:

    weight(T)          = depth                      (gravitational mass)
    proofComplexity(T) = Omega(depth)               (number of prime factors
                                                     with multiplicity =
                                                     irreducible reduction steps)

This script exercises the *main* theorem (the Anti-Gravity Trade-off
``2 ** proofComplexity <= weight``) and its consequences: anti-gravity
theorems, the prime-witness family ``2 ** p``, cofinality, and the
constructive "nearest floating theorem" map underlying the Density Theorem.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import List


# --------------------------------------------------------------------------
# Model: the two invariants of a theorem, read off its dependency index.
# --------------------------------------------------------------------------

def prime_factors_list(n: int) -> List[int]:
    """Prime factors of ``n`` with multiplicity (Mathlib's primeFactorsList).

    Mirrors ``Nat.primeFactorsList``; returns ``[]`` for ``n in (0, 1)``.
    """
    if n < 2:
        return []
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        while m % d == 0:
            factors.append(d)
            m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def weight(depth: int) -> int:
    """weight(T) = T.depth  (Lean: OWFStratum.weight)."""
    return depth


def proof_complexity(depth: int) -> int:
    """proofComplexity(T) = Omega(depth)  (Lean: OWFStratum.proofComplexity)."""
    return len(prime_factors_list(depth))


def is_anti_gravity(depth: int) -> bool:
    """IsAntiGravity T  <->  2 ** proofComplexity = weight  (Lean: IsAntiGravity)."""
    return 2 ** proof_complexity(depth) == weight(depth)


def prime_witness(p: int) -> int:
    """primeWitness p = <2 ** p>  (Lean: OWFStratum.primeWitness)."""
    return 2 ** p


def nearest_floating_theorem(w: int) -> int:
    """Smallest anti-gravity dependency index of weight >= w.

    Constructive realisation of ``basic_open_contains_antiGravity``:
    returns the witness 2 ** ceil(log2 w) covering the basic open Ici(w).
    """
    p = 0
    while 2 ** p < w:
        p += 1
    return prime_witness(p)


# --------------------------------------------------------------------------
# Demo 1 — The Anti-Gravity Trade-off holds for every positive weight.
# --------------------------------------------------------------------------

def demo_tradeoff(limit: int = 200) -> None:
    print("=" * 70)
    print("Demo 1: Anti-Gravity Trade-off   2 ** proofComplexity <= weight")
    print("=" * 70)
    worst_slack = None
    for depth in range(1, limit + 1):
        lhs = 2 ** proof_complexity(depth)
        rhs = weight(depth)
        assert lhs <= rhs, f"trade-off VIOLATED at depth={depth}"
        slack = rhs - lhs
        if worst_slack is None or slack < worst_slack[1]:
            worst_slack = (depth, slack)
    print(f"  Verified 2**Omega(n) <= n for all 1 <= n <= {limit}.  OK")
    print(f"  proofComplexity <= log2(weight) confirmed numerically.")
    print(f"  Tightest non-trivial slack (rhs-lhs) at depth={worst_slack[0]} "
          f"(slack {worst_slack[1]}).")
    print()


# --------------------------------------------------------------------------
# Demo 2 — Prime witnesses 2**p attain equality (they float).
# --------------------------------------------------------------------------

def demo_prime_witnesses(max_p: int = 16) -> None:
    print("=" * 70)
    print("Demo 2: Prime witnesses 2**p achieve equality (anti-gravity)")
    print("=" * 70)
    print(f"  {'p':>3} | {'weight=2**p':>12} | {'proofComplexity':>15} | floats?")
    print("  " + "-" * 50)
    for p in range(0, max_p + 1):
        depth = prime_witness(p)
        pc = proof_complexity(depth)
        assert pc == p, "proofComplexity(2**p) must equal p"
        assert is_anti_gravity(depth)
        if p <= 8 or p == max_p:
            print(f"  {p:>3} | {depth:>12} | {pc:>15} | {is_anti_gravity(depth)}")
    print("  Every prime witness floats: proofComplexity = log2(weight).")
    print()


# --------------------------------------------------------------------------
# Demo 3 — Density: every "from weight w up" region contains a floater.
# --------------------------------------------------------------------------

def demo_density(thresholds: List[int]) -> None:
    print("=" * 70)
    print("Demo 3: Density Theorem -- nearest floating theorem above a threshold")
    print("=" * 70)
    print(f"  {'threshold w':>12} | {'nearest 2**p >= w':>18} | "
          f"{'proofComplexity':>15} | floats?")
    print("  " + "-" * 64)
    for w in thresholds:
        witness = nearest_floating_theorem(w)
        assert witness >= w
        assert is_anti_gravity(witness)
        print(f"  {w:>12} | {witness:>18} | "
              f"{proof_complexity(witness):>15} | {is_anti_gravity(witness)}")
    print("  Each basic open Ici(w) is met by an anti-gravity theorem.")
    print()


# --------------------------------------------------------------------------
# Demo 4 — How rare are floaters? Fraction is regime-dependent, not 10%.
# --------------------------------------------------------------------------

def demo_fraction(limit: int = 4096) -> None:
    print("=" * 70)
    print("Demo 4: Anti-gravity fraction among indices 1..N (regime-dependent)")
    print("=" * 70)
    floaters = [n for n in range(1, limit + 1) if is_anti_gravity(n)]
    # Among 1..N the floaters are exactly the powers of two.
    powers = [2 ** p for p in range(0, limit.bit_length()) if 2 ** p <= limit]
    assert floaters == powers, "anti-gravity indices in [1,N] are powers of two"
    frac = len(floaters) / limit
    print(f"  N = {limit}: {len(floaters)} floaters = powers of two = {floaters}")
    print(f"  fraction = {frac:.5f}  (~ log2(N)/N, decays -- NOT a fixed 10%).")
    print("  The robust, proved statement is topological DENSITY, not a fraction.")
    print()


if __name__ == "__main__":
    demo_tradeoff(limit=200)
    demo_prime_witnesses(max_p=16)
    demo_density(thresholds=[3, 5, 17, 100, 1000, 65537])
    demo_fraction(limit=4096)
    print("All demonstrations completed successfully.")
