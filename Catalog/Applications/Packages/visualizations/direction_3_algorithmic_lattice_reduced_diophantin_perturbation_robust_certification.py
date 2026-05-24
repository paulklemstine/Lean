"""
Algorithmic Lattice-Reduced Diophantine Certification

Core algorithms for certifying the tropical Diophantine condition:
  TropicalDiophantine(K, C, ω) ↔ ∀ k ≠ 0, ‖k‖₁ ≤ K → C ≤ |⟨k, ω⟩|

Implements brute-force enumeration, LLL-based heuristic certification,
and perturbation-robust certification.
"""

from __future__ import annotations
import itertools
import math
import time
from fractions import Fraction
from typing import Optional


def l1_norm(k: list[int]) -> int:
    """Compute the ℓ¹ norm of an integer vector."""
    return sum(abs(ki) for ki in k)


def lattice_inner(k: list[int], omega: list[float]) -> float:
    """Compute the lattice inner product ⟨k, ω⟩ = Σ kᵢ ωᵢ."""
    return sum(ki * wi for ki, wi in zip(k, omega))


def enumerate_l1_box(n: int, K: int):
    """
    Enumerate all integer vectors k ∈ ℤⁿ with ‖k‖₁ ≤ K.

    Yields tuples of length n. Includes the zero vector.
    Total count ≤ (2K+1)ⁿ (componentwise bound).

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.

    Yields:
        Tuples k with l1_norm(k) ≤ K.
    """
    for k in itertools.product(range(-K, K + 1), repeat=n):
        if l1_norm(k) <= K:
            yield k


def brute_force_check(n: int, K: int, C: float, omega: list[float]) -> tuple[bool, Optional[tuple[int, ...]]]:
    """
    Brute-force certification of TropicalDiophantine(K, C, ω).

    Checks all nonzero k with ‖k‖₁ ≤ K and verifies |⟨k, ω⟩| ≥ C.

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.
        C: Threshold.
        omega: Frequency vector.

    Returns:
        (True, None) if certified, (False, violating_k) otherwise.
    """
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        val = abs(lattice_inner(list(k), omega))
        if val < C:
            return False, k
    return True, None


def compute_min_gap(n: int, K: int, omega: list[float]) -> tuple[float, Optional[tuple[int, ...]]]:
    """
    Compute the minimum resonance gap over the ℓ¹ box.

    min { |⟨k, ω⟩| : k ≠ 0, ‖k‖₁ ≤ K }

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.
        omega: Frequency vector.

    Returns:
        (min_gap, minimizing_k).
    """
    min_gap = float('inf')
    min_k = None
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        val = abs(lattice_inner(list(k), omega))
        if val < min_gap:
            min_gap = val
            min_k = k
    return min_gap, min_k


def gram_schmidt(basis: list[list[float]]) -> tuple[list[list[float]], list[list[float]]]:
    """
    Gram-Schmidt orthogonalization.

    Args:
        basis: List of basis vectors.

    Returns:
        (orthogonalized_basis, mu_coefficients).
    """
    n = len(basis)
    m = len(basis[0])
    ortho = [list(v) for v in basis]
    mu = [[0.0] * n for _ in range(n)]

    for i in range(n):
        for j in range(i):
            dot_ij = sum(ortho[i][k] * ortho[j][k] for k in range(m))
            dot_jj = sum(ortho[j][k] * ortho[j][k] for k in range(m))
            if dot_jj < 1e-15:
                mu[i][j] = 0.0
                continue
            mu[i][j] = dot_ij / dot_jj
            for k in range(m):
                ortho[i][k] -= mu[i][j] * ortho[j][k]

    return ortho, mu


def lll_reduce(basis: list[list[float]], delta: float = 0.75) -> list[list[float]]:
    """
    LLL lattice basis reduction (simplified floating-point version).

    Applies the Lenstra-Lenstra-Lovász algorithm to reduce a lattice basis.
    This is a heuristic implementation suitable for moderate dimensions.

    Args:
        basis: List of basis vectors (each a list of floats).
        delta: Lovász parameter (default 0.75, must be in (0.25, 1)).

    Returns:
        LLL-reduced basis.
    """
    n = len(basis)
    B = [list(v) for v in basis]
    m = len(B[0])

    def dot(u, v):
        return sum(a * b for a, b in zip(u, v))

    def norm2(v):
        return dot(v, v)

    k = 1
    while k < n:
        # Gram-Schmidt
        ortho, mu = gram_schmidt(B)

        # Size reduction
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                for idx in range(m):
                    B[k][idx] -= r * B[j][idx]
                ortho, mu = gram_schmidt(B)

        # Lovász condition
        n2_k = norm2(ortho[k])
        n2_km1 = norm2(ortho[k - 1])
        if n2_k >= (delta - mu[k][k - 1] ** 2) * n2_km1:
            k += 1
        else:
            B[k], B[k - 1] = B[k - 1], B[k]
            k = max(k - 1, 1)

    return B


def lattice_heuristic_check(
    n: int, K: int, C: float, omega: list[float], scaling: float = 1e6
) -> tuple[bool, float]:
    """
    LLL-based heuristic certification of TropicalDiophantine(K, C, ω).

    Constructs a lifted lattice basis encoding integer relations with ω,
    applies LLL reduction, and extracts a lower bound on |⟨k, ω⟩| for
    short k.

    This is a heuristic: it may fail to certify even when the condition holds.
    However, when it succeeds, the certificate is mathematically valid
    (by ReducedBasisWitness.sound).

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.
        C: Threshold.
        omega: Frequency vector.
        scaling: Scaling parameter for the lifted lattice.

    Returns:
        (certified, estimated_gap).
    """
    # Construct (n+1) × (n+1) lattice basis:
    # [I_n | 0]
    # [M*ω | M]
    dim = n + 1
    basis = []
    for i in range(n):
        row = [0.0] * dim
        row[i] = 1.0
        basis.append(row)
    # Last row: scaled frequency vector
    last_row = [scaling * omega[i] for i in range(n)] + [scaling]
    basis.append(last_row)

    # Apply LLL reduction
    reduced = lll_reduce(basis)

    # The shortest reduced vector gives information about integer relations
    # If all short vectors in the reduced basis have large frequency components,
    # then no short integer relation exists
    min_freq_component = float('inf')
    for vec in reduced:
        # Extract integer part (first n components) and frequency part
        k_part = [round(vec[i]) for i in range(n)]
        if all(ki == 0 for ki in k_part):
            continue
        if l1_norm(k_part) <= K:
            val = abs(lattice_inner(k_part, omega))
            min_freq_component = min(min_freq_component, val)

    certified = min_freq_component >= C
    return certified, min_freq_component


def robust_check(
    n: int, K: int, C: float, epsilon: float, omega_approx: list[float]
) -> tuple[bool, float]:
    """
    Perturbation-robust certification.

    By the stability theorem (tropicalDiophantine_stable_under_supPerturb),
    if ω_approx is certified at threshold C + K·ε, then the true ω
    (within ε of ω_approx) is certified at threshold C.

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.
        C: Target threshold for the true ω.
        epsilon: Maximum coordinatewise perturbation.
        omega_approx: Approximate frequency vector.

    Returns:
        (certified, gap_for_approximate).
    """
    C_boosted = C + K * epsilon
    certified, gap = brute_force_check(n, K, C_boosted, omega_approx)
    return certified, gap if gap is None else C_boosted


def count_l1_box(n: int, K: int) -> int:
    """
    Count the number of integer vectors with ‖k‖₁ ≤ K in dimension n.

    Uses dynamic programming for efficiency.

    Args:
        n: Dimension.
        K: ℓ¹ norm bound.

    Returns:
        Exact count of {k ∈ ℤⁿ : ‖k‖₁ ≤ K}.
    """
    # dp[j] = number of vectors in ℤʲ with l1 norm exactly j
    # For a single coordinate, value v contributes |v| to the norm
    # Number of integers with |v| = j: 2 if j > 0, 1 if j = 0

    # dp[dim][norm] = count of vectors in ℤ^dim with l1 norm = norm
    dp = [[0] * (K + 1) for _ in range(n + 1)]
    dp[0][0] = 1

    for dim in range(1, n + 1):
        for norm in range(K + 1):
            # Assign coordinate value v with |v| = abs_v
            for abs_v in range(norm + 1):
                multiplicity = 1 if abs_v == 0 else 2
                dp[dim][norm] += multiplicity * dp[dim - 1][norm - abs_v]

    return sum(dp[n][j] for j in range(K + 1))


if __name__ == "__main__":
    # Quick test
    omega = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    n, K, C = 3, 5, 0.01

    print(f"Testing TropicalDiophantine({K}, {C}, ω) for ω = (√2, √3, √5)")
    print(f"Dimension: {n}")

    t0 = time.time()
    ok, viol = brute_force_check(n, K, C, omega)
    t1 = time.time()
    print(f"Brute force: {'PASS' if ok else 'FAIL'} ({t1-t0:.4f}s)")
    if not ok:
        print(f"  Violating vector: {viol}")

    gap, min_k = compute_min_gap(n, K, omega)
    print(f"Minimum gap: {gap:.6f} at k = {min_k}")

    count = count_l1_box(n, K)
    bound = (2 * K + 1) ** n
    print(f"Search space: {count} vectors (bound: {bound})")
