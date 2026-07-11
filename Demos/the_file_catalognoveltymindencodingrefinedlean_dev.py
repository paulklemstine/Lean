"""
Graded Connectomes and the Combinatorics of Merged Minds
========================================================

Self-contained numerical demonstrations of the exact laws governing the
information content of neural connectomes:

  * slots(N)            = C(N, 2)          -- undirected synapse slots
  * directed_slots(N)   = N(N-1)           -- directed synapse slots
  * graded state count  = w ** slots(N)
  * description length   = slots(N) * log2(w)   bits
  * two-brain merge     : slots(M+N) = slots(M) + slots(N) + M*N
  * general merge law   : slots(sum Ni) = sum slots(Ni) + cross(L)
  * square-of-a-sum     : (sum Ni)^2 = sum Ni^2 + 2*cross(L)

Every function is inlined; the file has no third-party dependencies.
Run with:  python demo.py
"""

from __future__ import annotations

from math import comb, log2, floor
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Core combinatorial quantities
# --------------------------------------------------------------------------- #
def slots(n: int) -> int:
    """Number of undirected synapse slots on n neurons: C(n, 2)."""
    return comb(n, 2)


def directed_slots(n: int) -> int:
    """Number of directed synapse slots on n neurons: n(n-1) = 2*C(n,2)."""
    return n * (n - 1)


def graded_bits(n: int, w: int) -> float:
    """Exact description length (bits) of a w-graded connectome on n neurons.

    Implements the Graded Description-Length Law:
        log2(w ** slots(n)) = slots(n) * log2(w).
    """
    if w < 1:
        raise ValueError("weight alphabet size w must be >= 1")
    if w == 1:
        return 0.0
    return slots(n) * log2(w)


def cross_pairs(neuron_counts: List[int]) -> int:
    """Cross term sum_{i<j} Ni*Nj via a single suffix-sum pass (O(k))."""
    total = 0
    suffix = sum(neuron_counts)
    for x in neuron_counts:
        suffix -= x            # suffix now equals sum of counts strictly after x
        total += x * suffix
    return total


def merge_slots(neuron_counts: List[int]) -> int:
    """Total slots of the fused mind: sum slots(Ni) + cross(L)."""
    return sum(slots(n) for n in neuron_counts) + cross_pairs(neuron_counts)


def max_log2_weight(n: int, bit_budget: float) -> float:
    """Largest admissible log2(w) with slots(n)*log2(w) <= bit_budget.

    This is the numerically stable form of the optimal-weight-resolution
    rule: the optimal alphabet size is w* = floor(2 ** max_log2_weight),
    but for large budgets w* is astronomically large, so we report the
    exponent (the number of usable bits per slot) directly.
    """
    s = slots(n)
    if s == 0:
        return float("inf")  # no slots: any resolution is free
    return bit_budget / s


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_description_length() -> None:
    print("=" * 70)
    print("1. Graded description-length law:  log2(w^slots) = slots * log2 w")
    print("=" * 70)
    for n, w in [(4, 2), (4, 4), (10, 2), (10, 256), (100, 256)]:
        s = slots(n)
        lhs = log2(w ** s)                 # direct computation of the power
        rhs = graded_bits(n, w)            # bilinear closed form
        print(f"  N={n:>3}  w={w:>3}  slots={s:>5}  "
              f"log2(w^slots)={lhs:12.4f}  slots*log2 w={rhs:12.4f}  "
              f"match={abs(lhs - rhs) < 1e-6}")
    print()


def demo_boolean_and_premium() -> None:
    print("=" * 70)
    print("2. Boolean base case (w=2) and the strict grading premium (w>=3)")
    print("=" * 70)
    for n in [5, 20, 50]:
        s = slots(n)
        print(f"  N={n:>3}: Boolean cost (w=2) = {graded_bits(n, 2):.1f} bits "
              f"= slots = {s}")
    print("  Premium check  slots < slots*log2 w  for w>=3:")
    for n, w in [(5, 3), (20, 8), (50, 256)]:
        s = slots(n)
        print(f"    N={n:>3} w={w:>3}: {s} < {graded_bits(n, w):.1f}  -> "
              f"{s < graded_bits(n, w)}")
    print()


def demo_directed() -> None:
    print("=" * 70)
    print("3. Directed graded state count:  w^(N(N-1)) = (w^slots)^2")
    print("=" * 70)
    for n, w in [(4, 2), (5, 3)]:
        lhs = w ** directed_slots(n)
        rhs = (w ** slots(n)) ** 2
        print(f"  N={n} w={w}: w^(N(N-1))={lhs}  (w^slots)^2={rhs}  "
              f"match={lhs == rhs}")
    print()


def demo_merge_laws() -> None:
    print("=" * 70)
    print("4. Merge laws: two-brain, general merge, and square-of-a-sum")
    print("=" * 70)
    # Two-brain law
    for m, n in [(3, 4), (10, 7)]:
        lhs = slots(m + n)
        rhs = slots(m) + slots(n) + m * n
        print(f"  slots({m}+{n})={lhs} = slots({m})+slots({n})+{m}*{n}={rhs}  "
              f"match={lhs == rhs}")
    # General merge + superadditivity
    brains = [3, 5, 4, 6]
    total = sum(brains)
    intrinsic = sum(slots(b) for b in brains)
    cross = cross_pairs(brains)
    print(f"  brains={brains}: slots(sum)={slots(total)}  "
          f"intrinsic={intrinsic} + cross={cross} = {intrinsic + cross}  "
          f"match={slots(total) == intrinsic + cross}")
    # Square-of-a-sum identity
    lhs = total ** 2
    rhs = sum(b * b for b in brains) + 2 * cross
    print(f"  (sum)^2={lhs} = sum sq + 2*cross = {rhs}  match={lhs == rhs}")
    print()


def demo_explosion() -> None:
    print("=" * 70)
    print("5. Combinatorial explosion: relational fraction -> 1 - 1/k")
    print("=" * 70)
    n = 1000
    print(f"  Fusing k equal brains of n={n} neurons each:")
    for k in [2, 5, 10, 100, 1000]:
        brains = [n] * k
        intrinsic = sum(slots(b) for b in brains)
        cross = cross_pairs(brains)
        frac = cross / (intrinsic + cross)
        print(f"    k={k:>5}: relational fraction = {frac:.4f}   "
              f"(1 - 1/k = {1 - 1/k:.4f})")
    print()


def demo_budget() -> None:
    print("=" * 70)
    print("6. Optimal weight resolution under a fixed bit budget")
    print("=" * 70)
    budget = 1e12  # one terabit
    for n in [1000, 10000, 100000]:
        bits_per_slot = max_log2_weight(n, budget)
        # Optimal alphabet size w* = floor(2 ** bits_per_slot); only realise it
        # explicitly when the exponent is small enough to fit in memory.
        w_repr = (str(floor(2.0 ** bits_per_slot))
                  if bits_per_slot < 60 else f"2^{bits_per_slot:.2f}")
        print(f"  N={n:>7}: slots={slots(n):>12}  "
              f"max log2(w) per slot = {bits_per_slot:8.4f}  "
              f"optimal w* = {w_repr}")
    print()


def main() -> None:
    demo_description_length()
    demo_boolean_and_premium()
    demo_directed()
    demo_merge_laws()
    demo_explosion()
    demo_budget()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
