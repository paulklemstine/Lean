#!/usr/bin/env python3
"""
BSD Formal Verification Program — Algorithms

Implements the core algorithms underlying the BSD formal scaffold:

1. Local Euler factor computation from point counts
2. BSD algebraic side computation with certified positivity check
3. Gram matrix positive-definiteness verification
4. Tamagawa product computation with reindexing invariance check
5. Frobenius trace distribution (Sato-Tate) analysis
"""

import numpy as np
from typing import Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Local Euler Factor Computation
# ═══════════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   INPUT: prime p, point count N = #E(F_p)
#   OUTPUT: Euler polynomial coefficients [1, -a_p, p]
#
#   1. Compute a_p = p + 1 - N
#   2. Verify Hasse bound: |a_p| ≤ 2√p
#   3. Return coefficients [1, -a_p, p]
#
# Time complexity: O(1)
# Space complexity: O(1)
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class LocalEulerFactor:
    """Certified local Euler factor at a good prime."""
    p: int
    ap: int
    coeffs: list[int]   # [1, -a_p, p]
    hasse_verified: bool

    def evaluate(self, T: float) -> float:
        """Evaluate L_p(T) = 1 - a_p T + p T²."""
        return self.coeffs[0] + self.coeffs[1] * T + self.coeffs[2] * T**2


def compute_local_euler_factor(p: int, point_count: int) -> LocalEulerFactor:
    """
    Compute the local Euler factor from a prime and point count.

    Args:
        p: A prime number (the residue characteristic).
        point_count: The number of F_p-rational points on the curve, #E(F_p).

    Returns:
        A LocalEulerFactor with certified Hasse bound.

    Raises:
        ValueError: If the Hasse bound is violated (indicates bad input).

    Example:
        >>> factor = compute_local_euler_factor(5, 8)
        >>> factor.ap
        -2
        >>> factor.coeffs
        [1, 2, 5]
        >>> factor.hasse_verified
        True
    """
    ap = p + 1 - point_count
    hasse_bound = 2 * np.sqrt(p)
    hasse_ok = abs(ap) <= hasse_bound

    if not hasse_ok:
        raise ValueError(
            f"Hasse bound violated: |a_p| = {abs(ap)} > 2√p = {hasse_bound:.4f}. "
            f"Check that p={p} is prime and point_count={point_count} is correct."
        )

    return LocalEulerFactor(
        p=p,
        ap=ap,
        coeffs=[1, -ap, p],
        hasse_verified=True
    )


def verify_euler_factor_uniqueness(
    p1: int, ap1: int, p2: int, ap2: int
) -> bool:
    """
    Verify that two local data with the same (p, a_p) produce
    the same Euler polynomial.

    This implements the formal theorem `local_euler_factor_ext_of_trace`.

    Args:
        p1, ap1: Prime and trace for first data.
        p2, ap2: Prime and trace for second data.

    Returns:
        True if the Euler polynomials are identical (coefficientwise).
    """
    if p1 != p2 or ap1 != ap2:
        return False
    return [1, -ap1, p1] == [1, -ap2, p2]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: BSD Algebraic Side with Positivity Certificate
# ═══════════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   INPUT: Ω, Reg, |Sha|, ∏c_p, |E_tors|
#   OUTPUT: (algebraic_side, positivity_certificate)
#
#   1. Compute numerator = Ω × Reg × |Sha| × ∏c_p
#   2. Compute denominator = |E_tors|²
#   3. Check positivity: all inputs > 0 ⟹ result > 0
#   4. Return (numerator / denominator, certificate)
#
# Time complexity: O(1)
# Space complexity: O(1)
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class BSDAlgebraicSideResult:
    """Result of BSD algebraic side computation with certificate."""
    value: float
    is_positive: bool
    is_nonzero: bool
    components: dict


def compute_bsd_algebraic_side(
    real_period: float,
    regulator: float,
    sha_order: int,
    tamagawa_product: int,
    torsion_order: int
) -> BSDAlgebraicSideResult:
    """
    Compute the BSD algebraic side with positivity certificate.

    Formula: (Ω · Reg · |Sha| · ∏c_p) / |E_tors|²

    This implements the formal theorems `bsdAlgebraicSide_pos` and
    `bsdAlgebraicSide_ne_zero`.

    Args:
        real_period: The real period Ω (should be > 0).
        regulator: The regulator Reg (should be > 0).
        sha_order: The order of Sha (should be > 0).
        tamagawa_product: Product of Tamagawa numbers (should be > 0).
        torsion_order: Order of torsion subgroup (should be > 0).

    Returns:
        BSDAlgebraicSideResult with value and certificates.

    Example:
        >>> result = compute_bsd_algebraic_side(1.269, 1.0, 1, 5, 5)
        >>> result.is_positive
        True
    """
    numerator = real_period * regulator * sha_order * tamagawa_product
    denominator = torsion_order ** 2
    value = numerator / denominator

    all_positive = (
        real_period > 0 and regulator > 0 and
        sha_order > 0 and tamagawa_product > 0 and torsion_order > 0
    )

    all_nonzero = (
        real_period != 0 and regulator != 0 and
        sha_order != 0 and tamagawa_product != 0 and torsion_order != 0
    )

    return BSDAlgebraicSideResult(
        value=value,
        is_positive=all_positive,  # Theorem: all positive ⟹ value > 0
        is_nonzero=all_nonzero,     # Theorem: all nonzero ⟹ value ≠ 0
        components={
            'real_period': real_period,
            'regulator': regulator,
            'sha_order': sha_order,
            'tamagawa_product': tamagawa_product,
            'torsion_order': torsion_order,
            'numerator': numerator,
            'denominator': denominator,
        }
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Gram Matrix Positive-Definiteness and Regulator
# ═══════════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   INPUT: n×n symmetric matrix M (height pairing Gram matrix)
#   OUTPUT: (is_positive_definite, determinant, eigenvalues)
#
#   1. Verify symmetry: M = Mᵀ
#   2. Compute eigenvalues λ₁, ..., λ_n
#   3. Check all λ_i > 0
#   4. If positive definite, det(M) = ∏λ_i > 0
#   5. Return (True, det(M), eigenvalues)
#
# Time complexity: O(n³) for eigenvalue computation
# Space complexity: O(n²)
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class RegulatorResult:
    """Result of regulator computation with positive-definiteness certificate."""
    determinant: float
    is_positive_definite: bool
    is_symmetric: bool
    eigenvalues: np.ndarray
    condition_number: float


def verify_regulator_positivity(M: np.ndarray, tol: float = 1e-10) -> RegulatorResult:
    """
    Verify that a height pairing Gram matrix is positive definite
    and compute its determinant (the regulator).

    This implements the formal theorem `regulator_pos_of_posDef`.

    Args:
        M: A square symmetric matrix (the height pairing Gram matrix).
        tol: Tolerance for symmetry and positivity checks.

    Returns:
        RegulatorResult with determinant and certificates.

    Example:
        >>> M = np.array([[0.6823, -0.1597], [-0.1597, 0.3633]])
        >>> result = verify_regulator_positivity(M)
        >>> result.is_positive_definite
        True
        >>> result.determinant > 0
        True
    """
    n = M.shape[0]
    assert M.shape == (n, n), "Matrix must be square"

    # Check symmetry
    is_sym = np.allclose(M, M.T, atol=tol)

    # Compute eigenvalues (use eigvalsh for symmetric matrices)
    if is_sym:
        eigenvalues = np.linalg.eigvalsh(M)
    else:
        eigenvalues = np.real(np.linalg.eigvals(M))

    is_pd = bool(np.all(eigenvalues > tol))
    det = float(np.linalg.det(M))

    # Condition number
    if is_pd:
        cond = float(np.max(eigenvalues) / np.min(eigenvalues))
    else:
        cond = float('inf')

    return RegulatorResult(
        determinant=det,
        is_positive_definite=is_pd,
        is_symmetric=is_sym,
        eigenvalues=eigenvalues,
        condition_number=cond
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Tamagawa Product with Reindexing Invariance
# ═══════════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   INPUT: list of (prime, Tamagawa_number) pairs
#   OUTPUT: product, with invariance certificate
#
#   1. Sort pairs by prime (canonical ordering)
#   2. Compute product = ∏ c_p
#   3. Verify: product is independent of input ordering
#   4. Verify: all c_p > 0 ⟹ product > 0
#
# Time complexity: O(k log k) where k = number of bad primes
# Space complexity: O(k)
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TamagawaProductResult:
    """Result of Tamagawa product computation with invariance certificate."""
    product: int
    is_positive: bool
    bad_primes: list[int]
    factors: dict[int, int]


def compute_tamagawa_product(
    factors: dict[int, int]
) -> TamagawaProductResult:
    """
    Compute the Tamagawa product ∏ c_p with reindexing invariance.

    This implements `tamagawa_product_invariant` and `finset_prod_pos_of_pos`.

    Args:
        factors: Dictionary mapping bad primes to their Tamagawa numbers.

    Returns:
        TamagawaProductResult with product and certificates.

    Example:
        >>> result = compute_tamagawa_product({2: 2, 3: 2, 5: 2})
        >>> result.product
        8
        >>> result.is_positive
        True
    """
    product = 1
    for c in factors.values():
        product *= c

    all_positive = all(c > 0 for c in factors.values())
    bad_primes = sorted(factors.keys())

    return TamagawaProductResult(
        product=product,
        is_positive=all_positive and len(factors) >= 0,  # empty product = 1 > 0
        bad_primes=bad_primes,
        factors=factors
    )


def verify_reindexing_invariance(
    factors: dict[int, int],
    permuted_keys: Optional[list[int]] = None
) -> bool:
    """
    Verify that the Tamagawa product is invariant under reindexing.

    Args:
        factors: Original factor dictionary.
        permuted_keys: An alternative ordering of the keys.

    Returns:
        True if the products match under both orderings.
    """
    if permuted_keys is None:
        permuted_keys = sorted(factors.keys(), reverse=True)

    prod1 = 1
    for p in factors.keys():
        prod1 *= factors[p]

    prod2 = 1
    for p in permuted_keys:
        prod2 *= factors[p]

    return prod1 == prod2


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Sato-Tate Distribution Analysis
# ═══════════════════════════════════════════════════════════════════════

def sato_tate_cdf(theta: float) -> float:
    """
    CDF of the Sato-Tate distribution: F(θ) = (2/π)(θ/2 - sin(2θ)/4).

    Args:
        theta: Angle in [0, π].

    Returns:
        The cumulative probability.
    """
    return (2.0 / np.pi) * (theta / 2.0 - np.sin(2.0 * theta) / 4.0)


def frobenius_angle(ap: int, p: int) -> float:
    """
    Compute the Frobenius angle θ_p from the trace a_p and prime p.

    The angle satisfies a_p = 2√p cos(θ_p), so θ_p = arccos(a_p / (2√p)).

    Args:
        ap: Frobenius trace.
        p: Prime.

    Returns:
        Angle θ_p in [0, π].
    """
    x = ap / (2.0 * np.sqrt(p))
    # Clamp to [-1, 1] for numerical safety
    x = np.clip(x, -1.0, 1.0)
    return np.arccos(x)


def ks_statistic_sato_tate(angles: list[float]) -> float:
    """
    Compute the Kolmogorov-Smirnov statistic of Frobenius angles
    against the Sato-Tate distribution.

    Args:
        angles: List of Frobenius angles θ_p ∈ [0, π].

    Returns:
        The KS statistic D_N.
    """
    sorted_angles = np.sort(angles)
    n = len(sorted_angles)
    empirical_cdf = np.arange(1, n + 1) / n
    theoretical_cdf = np.array([sato_tate_cdf(theta) for theta in sorted_angles])

    d_plus = np.max(empirical_cdf - theoretical_cdf)
    d_minus = np.max(theoretical_cdf - (np.arange(0, n) / n))
    return max(d_plus, d_minus)


if __name__ == "__main__":
    # Quick self-test
    print("Algorithm self-tests:")

    # Test 1: Local Euler factor
    f = compute_local_euler_factor(5, 8)
    assert f.ap == -2
    assert f.coeffs == [1, 2, 5]
    assert f.hasse_verified
    print("  ✓ Local Euler factor computation")

    # Test 2: BSD algebraic side
    r = compute_bsd_algebraic_side(1.269, 1.0, 1, 5, 5)
    assert r.is_positive
    assert r.value > 0
    print("  ✓ BSD algebraic side positivity")

    # Test 3: Regulator positivity
    M = np.array([[0.6823, -0.1597], [-0.1597, 0.3633]])
    reg = verify_regulator_positivity(M)
    assert reg.is_positive_definite
    assert reg.determinant > 0
    print("  ✓ Regulator positivity from PosDef")

    # Test 4: Tamagawa product
    t = compute_tamagawa_product({2: 2, 3: 2, 5: 2})
    assert t.product == 8
    assert t.is_positive
    assert verify_reindexing_invariance({2: 2, 3: 2, 5: 2})
    print("  ✓ Tamagawa product invariance")

    print("\nAll self-tests passed.")
