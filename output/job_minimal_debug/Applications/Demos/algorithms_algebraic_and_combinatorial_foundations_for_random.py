"""
Algorithms for Random Matrix Foundations

Type-hinted implementations of the key mathematical structures
formalized in Lean 4.
"""

from typing import List, Callable, Tuple
import math


def catalan_number(n: int) -> int:
    """Compute the n-th Catalan number using the binomial coefficient formula.

    C(n) = C(2n, n) / (n + 1)

    >>> [catalan_number(i) for i in range(8)]
    [1, 1, 2, 5, 14, 42, 132, 429]
    """
    return math.comb(2 * n, n) // (n + 1)


def catalan_hankel_det(n: int) -> int:
    """Compute det[C(i+j)]_{0<=i,j<=n}, the Catalan Hankel determinant.

    Conjecture: this equals 1 for all n >= 0.

    >>> [catalan_hankel_det(i) for i in range(6)]
    [1, 1, 1, 1, 1, 1]
    """
    import numpy as np
    H = np.array([[catalan_number(i + j) for j in range(n + 1)] for i in range(n + 1)],
                 dtype=float)
    return int(round(np.linalg.det(H)))


def free_cumulants_from_moments(moments: List[float]) -> List[float]:
    """Compute free cumulants from moments via the moment-cumulant formula.

    Uses the explicit formulas for the first 4 relations:
      m(1) = κ(1)
      m(2) = κ(2) + κ(1)²
      m(3) = κ(3) + 3·κ(1)·κ(2) + κ(1)³
      m(4) = κ(4) + 4·κ(1)·κ(3) + 2·κ(2)² + 6·κ(1)²·κ(2) + κ(1)⁴

    Args:
        moments: [m(1), m(2), m(3), m(4)] (at least 1, at most 4)

    Returns:
        Free cumulants [κ(1), κ(2), κ(3), κ(4)] (same length as input)
    """
    n = len(moments)
    kappa: List[float] = []

    if n >= 1:
        k1 = moments[0]
        kappa.append(k1)

    if n >= 2:
        k2 = moments[1] - k1 ** 2
        kappa.append(k2)

    if n >= 3:
        k3 = moments[2] - 3 * k1 * k2 - k1 ** 3
        kappa.append(k3)

    if n >= 4:
        k4 = moments[3] - 4 * k1 * k3 - 2 * k2 ** 2 - 6 * k1 ** 2 * k2 - k1 ** 4
        kappa.append(k4)

    return kappa


def stieltjes_transform_semicircle(z: complex) -> complex:
    """Compute the Stieltjes transform G(z) of the semicircle distribution.

    G(z) = (z - sqrt(z² - 4)) / 2

    where the branch of sqrt is chosen so that Im(G) < 0 for Im(z) > 0.

    Satisfies the fixed-point equation G = 1/(z - G),
    equivalently G² - zG + 1 = 0.
    """
    disc = z ** 2 - 4
    sqrt_disc = disc ** 0.5
    # Choose branch with correct sign of imaginary part
    G = (z - sqrt_disc) / 2
    if z.imag > 0 and G.imag > 0:
        G = (z + sqrt_disc) / 2
    return G


def semicircle_density(x: float) -> float:
    """The Wigner semicircle density: ρ(x) = (1/(2π)) * sqrt(4 - x²) for |x| ≤ 2.

    The moments of this distribution are:
      ∫ x^{2k} ρ(x) dx = C(k)  (k-th Catalan number)
      ∫ x^{2k+1} ρ(x) dx = 0   (by symmetry)
    """
    if abs(x) > 2:
        return 0.0
    return (1 / (2 * math.pi)) * math.sqrt(4 - x ** 2)


def projection_kernel_from_eigenvectors(
    eigvecs: List[List[float]], rank: int
) -> List[List[float]]:
    """Construct a projection kernel K(x,y) = Σ_{i=1}^{r} φ_i(x) φ_i(y)
    from orthonormal eigenvectors.

    This kernel satisfies K² = K and Tr(K) = rank.

    Args:
        eigvecs: list of eigenvector arrays (each of length n)
        rank: number of eigenvectors to use

    Returns:
        The n×n kernel matrix K
    """
    n = len(eigvecs[0])
    K = [[0.0] * n for _ in range(n)]
    for r in range(min(rank, len(eigvecs))):
        for i in range(n):
            for j in range(n):
                K[i][j] += eigvecs[r][i] * eigvecs[r][j]
    return K


def wigner_matrix_sample(n: int) -> List[List[float]]:
    """Generate a sample from the Gaussian Unitary Ensemble (GUE).

    Returns an n×n symmetric matrix with:
    - diagonal entries ~ N(0, 1)
    - off-diagonal entries ~ N(0, 1/2) (symmetric)
    - Normalized by 1/sqrt(n)
    """
    import random
    M = [[0.0] * n for _ in range(n)]
    for i in range(n):
        M[i][i] = random.gauss(0, 1) / math.sqrt(n)
        for j in range(i + 1, n):
            val = random.gauss(0, 1 / math.sqrt(2)) / math.sqrt(n)
            M[i][j] = val
            M[j][i] = val
    return M


def verify_catalan_recurrence(n_max: int = 20) -> bool:
    """Verify (n+2)*C(n+1) = (4n+2)*C(n) for n = 0, ..., n_max."""
    for n in range(n_max + 1):
        lhs = (n + 2) * catalan_number(n + 1)
        rhs = (4 * n + 2) * catalan_number(n)
        if lhs != rhs:
            return False
    return True


if __name__ == "__main__":
    # Demonstrate Catalan numbers
    print("Catalan numbers C(0)..C(10):")
    print([catalan_number(i) for i in range(11)])

    # Verify recurrence
    print(f"\nCatalan recurrence verified up to n=20: {verify_catalan_recurrence()}")

    # Hankel determinants
    print("\nCatalan Hankel determinants det[C(i+j)] for n=0..7:")
    print([catalan_hankel_det(i) for i in range(8)])

    # Free cumulants of semicircle
    semicircle_moments = [0, 1, 0, 2]  # m(1)=0, m(2)=1, m(3)=0, m(4)=2
    kappas = free_cumulants_from_moments(semicircle_moments)
    print(f"\nSemicircle moments: {semicircle_moments}")
    print(f"Free cumulants: {kappas}")
    print("(Expected: κ = [0, 1, 0, 0] for unit semicircle)")
