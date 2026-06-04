#!/usr/bin/env python3
"""
Algorithms for Tropical Satake Isomorphism

Type-hinted implementations of key algorithms from the tropical Satake theory.
"""

from itertools import permutations
from typing import List, Callable, Tuple, Optional
from functools import lru_cache


def tropical_schur(w: List[int], x: List[int]) -> int:
    """
    Compute the tropical Schur polynomial.

    tropSchur(w, x) = min_{σ ∈ Sₙ} Σᵢ w(σ(i)) · x(i)

    This is the orbit-min construction: minimize the inner product ⟨σ(w), x⟩
    over all permutations σ of the weight vector w.

    Time complexity: O(n! · n) — exhaustive search over permutations.
    For practical use with large n, approximate algorithms or the
    Hungarian algorithm provide polynomial-time alternatives.

    Args:
        w: Weight vector (list of integers)
        x: Evaluation point (list of integers, same length as w)

    Returns:
        The minimum inner product over all permutations of w
    """
    n = len(w)
    assert len(x) == n, "Weight and evaluation vectors must have the same length"

    min_val = float('inf')
    for perm in permutations(range(n)):
        val = sum(w[perm[i]] * x[i] for i in range(n))
        if val < min_val:
            min_val = val
    return int(min_val)


def satake_transform(
    f: Callable[[List[int]], int],
    x: List[int]
) -> int:
    """
    Compute the Satake transform (orbit-min symmetrization).

    S(f)(x) = min_{σ ∈ Sₙ} f(x ∘ σ)

    Symmetrizes any function by minimizing over the Weyl group orbit of x.

    Args:
        f: A function from ℤⁿ to ℤ
        x: Evaluation point

    Returns:
        The minimum of f over all permutations of x
    """
    n = len(x)
    min_val = float('inf')
    for perm in permutations(range(n)):
        permuted_x = [x[perm[i]] for i in range(n)]
        val = f(permuted_x)
        if val < min_val:
            min_val = val
    return int(min_val)


def tropical_hecke_conv(
    f: Callable[[List[int]], int],
    g: Callable[[List[int]], int],
    x: List[int]
) -> int:
    """
    Compute the tropical Hecke convolution.

    (f ⊛ g)(x) = min_{σ ∈ Sₙ} [f(x) + g(x ∘ σ)]

    For Weyl-invariant g, this collapses to f(x) + g(x).

    Args:
        f, g: Functions from ℤⁿ to ℤ
        x: Evaluation point

    Returns:
        The tropical convolution value
    """
    n = len(x)
    f_val = f(x)
    min_val = float('inf')
    for perm in permutations(range(n)):
        permuted_x = [x[perm[i]] for i in range(n)]
        val = f_val + g(permuted_x)
        if val < min_val:
            min_val = val
    return int(min_val)


def tropical_demazure(
    i: int,
    f: Callable[[List[int]], int],
    x: List[int]
) -> int:
    """
    Apply the tropical Demazure operator Dᵢ.

    Dᵢ(f)(x) = min(f(x), f(sᵢ·x) + xᵢ - x_{i+1})

    where sᵢ swaps coordinates i and i+1.

    Args:
        i: Index of the simple transposition (0-indexed)
        f: Function from ℤⁿ to ℤ
        x: Evaluation point

    Returns:
        The Demazure-transformed value
    """
    n = len(x)
    assert 0 <= i < n - 1, f"Index {i} out of range for dimension {n}"

    si_x = list(x)
    si_x[i], si_x[i + 1] = si_x[i + 1], si_x[i]

    return min(f(x), f(si_x) + x[i] - x[i + 1])


def is_dominant(w: List[int]) -> bool:
    """Check if a weight vector is dominant (weakly decreasing)."""
    return all(w[i] >= w[i + 1] for i in range(len(w) - 1))


def dominant_representative(w: List[int]) -> List[int]:
    """Return the dominant (weakly decreasing) representative of the Weyl orbit."""
    return sorted(w, reverse=True)


def weyl_rho(n: int) -> List[int]:
    """The Weyl rho vector ρ = (n-1, n-2, ..., 1, 0)."""
    return [n - 1 - i for i in range(n)]


def verify_super_additivity(
    w1: List[int],
    w2: List[int],
    x: List[int]
) -> Tuple[int, int, int, bool]:
    """
    Verify the super-additivity inequality:
    tropSchur(w₁) + tropSchur(w₂) ≤ tropSchur(w₁ + w₂)

    Returns:
        (lhs, rhs, gap, holds) where gap = rhs - lhs
    """
    n = len(w1)
    w_sum = [w1[i] + w2[i] for i in range(n)]
    lhs = tropical_schur(w1, x) + tropical_schur(w2, x)
    rhs = tropical_schur(w_sum, x)
    return lhs, rhs, rhs - lhs, lhs <= rhs


def verify_weyl_invariance(
    w: List[int],
    x: List[int]
) -> bool:
    """Verify that tropSchur(w, ·) is Weyl-invariant at x."""
    base = tropical_schur(w, x)
    for perm in permutations(range(len(x))):
        px = [x[perm[i]] for i in range(len(x))]
        if tropical_schur(w, px) != base:
            return False
    return True


if __name__ == "__main__":
    # Quick self-test
    print("Running self-tests...")

    # Test 1: GL₂ example
    assert tropical_schur([3, 1], [2, 5]) == 11
    assert tropical_schur([3, 1], [5, 2]) == 11  # Symmetry
    print("  ✓ GL₂ example")

    # Test 2: Weyl invariance
    assert verify_weyl_invariance([5, 3, 1], [2, 7, 4])
    print("  ✓ Weyl invariance")

    # Test 3: Super-additivity
    for _ in range(10):
        import random
        n = 3
        w1 = [random.randint(-5, 5) for _ in range(n)]
        w2 = [random.randint(-5, 5) for _ in range(n)]
        x = [random.randint(-5, 5) for _ in range(n)]
        _, _, _, holds = verify_super_additivity(w1, w2, x)
        assert holds, f"Super-additivity failed for w1={w1}, w2={w2}, x={x}"
    print("  ✓ Super-additivity (10 random tests)")

    # Test 4: Satake = tropSchur
    w = [4, 2, 1]
    mono = lambda x: sum(w[i] * x[i] for i in range(len(w)))
    for x in [[1, 0, -1], [2, 3, 1]]:
        assert satake_transform(mono, x) == tropical_schur(w, x)
    print("  ✓ Satake transform = tropSchur")

    # Test 5: Dominant representative
    assert dominant_representative([1, 5, 3]) == [5, 3, 1]
    assert is_dominant([5, 3, 1])
    assert not is_dominant([1, 5, 3])
    print("  ✓ Dominant representative")

    print("\nAll self-tests passed!")
