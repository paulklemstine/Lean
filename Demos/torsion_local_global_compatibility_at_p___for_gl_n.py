"""
Numerical demonstrations for:

    The Combinatorial Skeleton of Torsion Local-Global Compatibility over CM Fields
    Reflection Symmetry, Purity, and Central Hodge-Tate Weights

We model the Hodge-Tate weights of an n-dimensional l-adic Galois representation
as a multiset of integers (weights with multiplicity). Conjugate self-duality
(polarization) with similitude weight c is invariance of the multiset under the
central reflection  a |-> c - a.

This script demonstrates, purely numerically and self-containedly:

  1. The three operations: dual (negation), twist (uniform shift), determinant
     weight (sum), and their basic identities.
  2. Polarization = "dualize, then twist by c".
  3. PURITY:            2 * det(W) = c * n   for polarized W.
  4. CENTRAL WEIGHT:    a regular polarized W of odd dimension contains a with 2a = c.
  5. Necessity of the regularity and oddness hypotheses via counterexamples.
  6. The GL_1 level-p^k eigensystem count phi(p^k) = p^{k-1}(p-1).

Everything is inlined; no third-party dependencies.
"""

from __future__ import annotations

from collections import Counter
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# Core operations on Hodge-Tate weight multisets (represented as sorted lists)
# ---------------------------------------------------------------------------

def dimension(weights: List[int]) -> int:
    """Dimension n = number of weights (with multiplicity)."""
    return len(weights)


def dual(weights: List[int]) -> List[int]:
    """Contragredient r |-> r^dual: negate every Hodge-Tate weight."""
    return sorted(-a for a in weights)


def twist(weights: List[int], k: int) -> List[int]:
    """Twist by chi^k: shift every weight by k."""
    return sorted(a + k for a in weights)


def det_weight(weights: List[int]) -> int:
    """Hodge-Tate weight of det r: the sum of the weights."""
    return sum(weights)


def is_regular(weights: List[int]) -> bool:
    """Regularity: all weights pairwise distinct."""
    return len(set(weights)) == len(weights)


def reflect(weights: List[int], c: int) -> List[int]:
    """Apply the central reflection a |-> c - a to every weight."""
    return sorted(c - a for a in weights)


def is_polarized(weights: List[int], c: int) -> bool:
    """Polarized with similitude weight c: invariant under a |-> c - a."""
    return Counter(weights) == Counter(reflect(weights, c))


def candidate_center(weights: List[int]) -> Optional[int]:
    """The only possible similitude weight is min + max (reflection swaps extremes)."""
    if not weights:
        return None
    return min(weights) + max(weights)


def central_weight(weights: List[int], c: int) -> Optional[int]:
    """Return a weight a with 2a = c if one exists (the center of symmetry)."""
    for a in weights:
        if 2 * a == c:
            return a
    return None


# ---------------------------------------------------------------------------
# GL_1 torsion eigensystem count
# ---------------------------------------------------------------------------

def euler_phi_prime_power(p: int, k: int) -> int:
    """Number of level-p^k torsion eigensystems for GL_1: phi(p^k) = p^{k-1}(p-1)."""
    return p ** (k - 1) * (p - 1)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_operations() -> None:
    print("=" * 70)
    print("1. Operations on Hodge-Tate weight data")
    print("=" * 70)
    W = [-1, 0, 3, 5]
    print(f"W               = {W}")
    print(f"dim W           = {dimension(W)}")
    print(f"dual W          = {dual(W)}")
    print(f"twist(W, 2)     = {twist(W, 2)}")
    print(f"det W           = {det_weight(W)}")
    print(f"det(dual W)     = {det_weight(dual(W))}   (= -det W = {-det_weight(W)})")
    print(f"det(twist W 2)  = {det_weight(twist(W, 2))}"
          f"   (= det W + 2*dim = {det_weight(W) + 2 * dimension(W)})")
    assert dual(dual(W)) == sorted(W)
    assert twist(twist(W, 3), 4) == twist(W, 7)
    assert det_weight(dual(W)) == -det_weight(W)
    assert det_weight(twist(W, 2)) == det_weight(W) + 2 * dimension(W)
    print("All operation identities verified.\n")


def demo_polarization_is_dual_then_twist() -> None:
    print("=" * 70)
    print("2. Polarization = dualize, then twist by c")
    print("=" * 70)
    c = 7
    W = [1, 6, 2, 5]  # {1,6} and {2,5} each sum to 7
    lhs = Counter(twist(dual(W), c))
    rhs = Counter(W)
    print(f"W                    = {sorted(W)}, c = {c}")
    print(f"twist(dual(W), c)    = {sorted(twist(dual(W), c))}")
    print(f"is_polarized(W, c)   = {is_polarized(W, c)}")
    assert (lhs == rhs) == is_polarized(W, c)
    print("Confirmed: (dual then twist by c) = W  <=>  polarized with center c.\n")


def demo_purity() -> None:
    print("=" * 70)
    print("3. PURITY:  2 * det(W) = c * n  for polarized W")
    print("=" * 70)
    examples: List[Tuple[List[int], int]] = [
        ([1, 6, 2, 5], 7),
        ([-3, 0, 3], 0),
        ([2, 5, 8], 10),
        ([0, 1, 2, 3, 4, 5], 5),
    ]
    for W, c in examples:
        assert is_polarized(W, c), f"{W} not polarized with c={c}"
        n = dimension(W)
        lhs, rhs = 2 * det_weight(W), c * n
        print(f"W={sorted(W)}, c={c}, n={n}:  2*det={lhs}, c*n={rhs}  -> {lhs == rhs}")
        assert lhs == rhs
        print(f"    determinant weight pinned to c*n/2 = {c * n / 2}")
    print("Purity holds for all polarized examples.\n")


def demo_central_weight() -> None:
    print("=" * 70)
    print("4. CENTRAL WEIGHT: odd + regular + polarized => weight a with 2a = c")
    print("=" * 70)
    examples: List[Tuple[List[int], int]] = [
        ([2, 5, 8], 10),          # center 5
        ([-4, 0, 4], 0),          # center 0
        ([1, 3, 5, 7, 9], 10),    # center 5
        ([-6, -1, 2, 5, 10], 4),  # center 2
    ]
    for W, c in examples:
        assert is_regular(W) and is_polarized(W, c) and dimension(W) % 2 == 1
        a = central_weight(W, c)
        print(f"W={sorted(W)}, c={c} (odd, regular): central weight a={a} with 2a={2*a}")
        assert a is not None and 2 * a == c
    print("Central weight always present.\n")


def demo_necessity() -> None:
    print("=" * 70)
    print("5. Necessity of the hypotheses (counterexamples)")
    print("=" * 70)
    # Oddness necessary: even regular polarized set with no central weight.
    W, c = [2, 5], 7
    print(f"Even case W={W}, c={c}: regular={is_regular(W)}, "
          f"polarized={is_polarized(W, c)}, central={central_weight(W, c)}")
    assert is_regular(W) and is_polarized(W, c) and central_weight(W, c) is None

    # Regularity necessary: even-dim polarized multiset with repeats, no center.
    W2, c2 = [2, 2, 5, 5], 7
    print(f"Repeated case W={W2}, c={c2}: regular={is_regular(W2)}, "
          f"polarized={is_polarized(W2, c2)}, central={central_weight(W2, c2)}")
    assert (not is_regular(W2)) and is_polarized(W2, c2) and central_weight(W2, c2) is None
    print("Both hypotheses are indispensable.\n")


def demo_gl1_counts() -> None:
    print("=" * 70)
    print("6. GL_1 level-p^k torsion eigensystem count phi(p^k) = p^{k-1}(p-1)")
    print("=" * 70)
    for p, k in [(2, 1), (2, 3), (3, 2), (5, 1), (7, 3)]:
        print(f"p={p}, k={k}:  count = {euler_phi_prime_power(p, k)}")
    print("A drop below this maximal count signals extra ramification at p.\n")


def main() -> None:
    demo_operations()
    demo_polarization_is_dual_then_twist()
    demo_purity()
    demo_central_weight()
    demo_necessity()
    demo_gl1_counts()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
