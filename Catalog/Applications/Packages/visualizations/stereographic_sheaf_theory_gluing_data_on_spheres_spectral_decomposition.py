"""
Algorithms for Stereographic Sheaf Cohomology

Implements the key algorithms from the research paper:
1. Stereographic projection and its inverse
2. Spectral decomposition under involutions
3. Čech cohomology computation for two-chart covers
4. Mayer-Vietoris exactness verification
"""
from typing import Callable, Tuple, List
import numpy as np


def stereo_proj(t: float) -> Tuple[float, float]:
    """
    Stereographic projection from R to S^1.

    Maps t ∈ R to (2t/(1+t²), (1-t²)/(1+t²)) on the unit circle.
    Complexity: O(1) time, O(1) space.

    >>> stereo_proj(0)
    (0.0, 1.0)
    >>> stereo_proj(1)
    (1.0, 0.0)
    """
    d = 1 + t**2
    return (2*t/d, (1-t**2)/d)


def stereo_inv(x: float, y: float) -> float:
    """
    Inverse stereographic projection from S^1 to R.

    Maps (x, y) on S^1 (with y ≠ -1) to t = x/(1+y).
    Complexity: O(1).

    >>> stereo_inv(0, 1)
    0.0
    >>> abs(stereo_inv(1, 0) - 1.0) < 1e-12
    True
    """
    assert abs(y + 1) > 1e-15, "Point (x, -1) is the north pole (not in chart)"
    return x / (1 + y)


def conformal_factor(t: float) -> float:
    """
    Conformal factor λ(t) = 2/(1+t²) of stereographic projection.

    This measures how much the projection distorts infinitesimal lengths.
    Always in (0, 2], maximum at t=0.
    Complexity: O(1).
    """
    return 2.0 / (1 + t**2)


def spectral_decompose(phi: Callable[[float], float], g: float) -> Tuple[float, float]:
    """
    Spectral decomposition of g under involution phi.

    Decomposes g = s + a where:
    - s = (g + phi(g))/2 is the symmetric part (phi(s) = s)
    - a = (g - phi(g))/2 is the antisymmetric part (phi(a) = -a)

    Requires: phi is an involution (phi(phi(x)) = x for all x).
    Complexity: O(T_phi) where T_phi is cost of evaluating phi.

    Args:
        phi: Involution function R -> R
        g: Element to decompose

    Returns:
        (symmetric_part, antisymmetric_part)

    >>> spectral_decompose(lambda x: -x, 5.0)
    (0.0, 5.0)
    >>> spectral_decompose(lambda x: x, 5.0)
    (5.0, 0.0)
    """
    phi_g = phi(g)
    return ((g + phi_g) / 2, (g - phi_g) / 2)


def tate_norm(phi: Callable[[float], float], g: float) -> float:
    """
    Tate cohomology norm map N(g) = g + phi(g).

    This is the norm map in group cohomology of Z/2Z.
    Image always lies in the +1 eigenspace of phi.
    Complexity: O(T_phi).
    """
    return g + phi(g)


def difference_map(phi: Callable[[float], float], g: float) -> float:
    """
    Difference map D(g) = g - phi(g).

    Image always lies in the -1 eigenspace of phi.
    Satisfies N(D(g)) = 0 and D(N(g)) = 0 (Mayer-Vietoris exactness).
    Complexity: O(T_phi).
    """
    return g - phi(g)


def cech_differential(phi: Callable, a: float, b: float) -> float:
    """
    Čech differential δ(a, b) = phi(a) - b.

    For a two-chart cover with transition phi:
    - δ = 0 iff (a, b) represents a global section
    - H^1 = coker(δ)
    Complexity: O(T_phi).
    """
    return phi(a) - b


def compute_h0_zmod(n: int, phi: Callable[[int], int]) -> List[int]:
    """
    Compute H^0 (fixed points of phi) in Z/nZ.

    Args:
        n: Modulus
        phi: Involution on Z/nZ (function int -> int, values mod n)

    Returns:
        List of fixed points

    Complexity: O(n) time, O(k) space where k = |H^0|.

    >>> compute_h0_zmod(5, lambda x: (-x) % 5)
    [0]
    >>> compute_h0_zmod(6, lambda x: (-x) % 6)
    [0, 3]
    """
    return [x for x in range(n) if phi(x) % n == x]


def verify_mayer_vietoris(phi: Callable, values: List[float], tol: float = 1e-12) -> bool:
    """
    Verify Mayer-Vietoris exactness N∘D = D∘N = 0.

    Tests the fundamental exact sequence property on a list of values.
    Complexity: O(k * T_phi) where k = len(values).

    Args:
        phi: Involution
        values: Test values
        tol: Numerical tolerance

    Returns:
        True if exactness holds for all test values
    """
    for g in values:
        # Test N(D(g)) = 0
        Dg = difference_map(phi, g)
        NDg = tate_norm(phi, Dg)
        if abs(NDg) > tol:
            return False
        # Test D(N(g)) = 0
        Ng = tate_norm(phi, g)
        DNg = difference_map(phi, Ng)
        if abs(DNg) > tol:
            return False
    return True


def exactness_witness(phi: Callable, g: float) -> float:
    """
    Given g with N(g) = 0, find h such that g = h - phi(h).

    Uses the explicit witness h = g/2 from the Mayer-Vietoris theorem.
    Complexity: O(1).

    Precondition: tate_norm(phi, g) ≈ 0.
    """
    return g / 2


def iterated_tate_norm(phi: Callable, g: float, n: int) -> float:
    """
    Compute N^n(g) = N(N(...N(g)...)) with n applications.

    Complexity: O(n * T_phi).
    """
    result = g
    for _ in range(n):
        result = tate_norm(phi, result)
    return result


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Negation involution
    neg = lambda x: -x

    print("H^0(Z/7Z, negation):", compute_h0_zmod(7, lambda x: (-x) % 7))
    print("H^0(Z/6Z, negation):", compute_h0_zmod(6, lambda x: (-x) % 6))

    print("\nMayer-Vietoris exactness (negation):",
          verify_mayer_vietoris(neg, [1.0, -3.5, 7.2, 0.0, 100.0]))

    print("\nSpectral decomposition of g=5 under negation:",
          spectral_decompose(neg, 5.0))

    print("\nIterated Tate norms (negation, g=42):")
    for k in range(5):
        print(f"  N^{k+1}(42) = {iterated_tate_norm(neg, 42, k+1)}")

    # Verify stereographic projection
    print("\nStereographic projection roundtrip:")
    for t in [0, 1, -1, 0.5, 3.14]:
        x, y = stereo_proj(t)
        t_back = stereo_inv(x, y)
        print(f"  t={t:6.2f} -> ({x:.4f}, {y:.4f}) -> {t_back:.4f} {'✓' if abs(t-t_back) < 1e-10 else '✗'}")
