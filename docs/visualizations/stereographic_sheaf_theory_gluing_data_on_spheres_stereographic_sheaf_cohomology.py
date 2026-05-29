"""
Stereographic Sheaf Theory: Algorithms
=======================================
Core algorithms for computing with stereographic sheaves,
Čech cohomology, and gluing data.
"""
import numpy as np
from typing import Callable, Tuple, List, Optional


class StereoGluingDatum:
    """A gluing datum for a stereographic sheaf.

    The transition function phi: G -> G is an involutive group homomorphism.
    For our computational purposes, G is a finite-dimensional real vector space.

    Attributes:
        transition: A linear map R^n -> R^n that is an involution (phi^2 = id).
        dim: Dimension of the section space.

    Time complexity: O(n^2) for applying transition (matrix multiplication).
    Space complexity: O(n^2) for storing the transition matrix.
    """

    def __init__(self, transition_matrix: np.ndarray):
        """Initialize with a transition matrix.

        Args:
            transition_matrix: An n×n matrix A such that A^2 = I.

        Raises:
            ValueError: If the matrix is not involutive.
        """
        n = transition_matrix.shape[0]
        self.matrix = transition_matrix
        self.dim = n
        # Verify involutive property
        A2 = transition_matrix @ transition_matrix
        if not np.allclose(A2, np.eye(n), atol=1e-10):
            raise ValueError("Transition matrix must be involutive (A^2 = I)")

    def apply(self, v: np.ndarray) -> np.ndarray:
        """Apply the transition map to a vector. O(n^2)."""
        return self.matrix @ v

    @staticmethod
    def trivial(n: int) -> 'StereoGluingDatum':
        """The trivial gluing datum: phi = id. O(n^2)."""
        return StereoGluingDatum(np.eye(n))

    @staticmethod
    def negation(n: int) -> 'StereoGluingDatum':
        """The negation gluing datum: phi = -id. O(n^2)."""
        return StereoGluingDatum(-np.eye(n))

    @staticmethod
    def reflection(n: int, axis: int) -> 'StereoGluingDatum':
        """Reflection in one axis: phi(x)_i = -x_i if i == axis, x_i otherwise. O(n^2)."""
        A = np.eye(n)
        A[axis, axis] = -1
        return StereoGluingDatum(A)


def cech_differential(datum: StereoGluingDatum, a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Compute the Čech differential d(a, b) = phi(a) - b.

    Args:
        datum: The gluing datum with transition phi.
        a: Section over U_N (north chart).
        b: Section over U_S (south chart).

    Returns:
        The Čech differential phi(a) - b.

    Time complexity: O(n^2) for the matrix multiplication.
    """
    return datum.apply(a) - b


def compute_H0(datum: StereoGluingDatum) -> Tuple[np.ndarray, int]:
    """Compute H^0 = ker(phi - I) = eigenspace of phi for eigenvalue 1.

    Returns:
        basis: Matrix whose columns form a basis for H^0.
        rank: Dimension of H^0.

    Time complexity: O(n^3) for eigenvalue decomposition.
    Space complexity: O(n^2).
    """
    # H^0 = {g : phi(g) = g} = ker(phi - I)
    A_minus_I = datum.matrix - np.eye(datum.dim)
    # Find null space via SVD
    U, S, Vt = np.linalg.svd(A_minus_I)
    null_mask = S < 1e-10
    # Also include dimensions beyond S (if matrix is not square or rank-deficient)
    null_space = Vt[len(S) - np.sum(~null_mask):].T
    if null_mask.any():
        extra = Vt[null_mask].T
        if null_space.size == 0:
            null_space = extra
        else:
            null_space = np.hstack([null_space, extra]) if extra.size > 0 else null_space

    # More robust: use eigendecomposition
    eigenvalues, eigenvectors = np.linalg.eig(datum.matrix)
    h0_indices = np.where(np.abs(eigenvalues - 1) < 1e-10)[0]
    basis = eigenvectors[:, h0_indices].real
    rank = len(h0_indices)

    return basis, rank


def compute_H0_antisym(datum: StereoGluingDatum) -> Tuple[np.ndarray, int]:
    """Compute the -1 eigenspace = {g : phi(g) = -g} = ker(phi + I).

    Returns:
        basis: Matrix whose columns form a basis for the -1 eigenspace.
        rank: Dimension of the -1 eigenspace.

    Time complexity: O(n^3) for eigenvalue decomposition.
    """
    eigenvalues, eigenvectors = np.linalg.eig(datum.matrix)
    h1_indices = np.where(np.abs(eigenvalues + 1) < 1e-10)[0]
    basis = eigenvectors[:, h1_indices].real
    rank = len(h1_indices)
    return basis, rank


def spectral_decomposition(datum: StereoGluingDatum, g: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Decompose g into symmetric + antisymmetric parts under the involution.

    Given phi involutive, write g = s + a where phi(s) = s and phi(a) = -a.
    s = (g + phi(g))/2, a = (g - phi(g))/2.

    Args:
        datum: Gluing datum with involutive transition.
        g: Vector to decompose.

    Returns:
        (s, a): Symmetric and antisymmetric components.

    Time complexity: O(n^2).
    """
    phi_g = datum.apply(g)
    s = (g + phi_g) / 2
    a = (g - phi_g) / 2
    return s, a


def euler_characteristic(datum: StereoGluingDatum) -> int:
    """Compute the Euler characteristic chi = dim(H^0) - dim(H^0_anti).

    For a two-chart cover with involutive transition,
    chi = dim(+1 eigenspace) - dim(-1 eigenspace).

    Returns:
        The Euler characteristic (integer).

    Time complexity: O(n^3).
    """
    _, rank_plus = compute_H0(datum)
    _, rank_minus = compute_H0_antisym(datum)
    return rank_plus - rank_minus


def stereo_proj(t: float) -> Tuple[float, float]:
    """Stereographic projection R -> S^1.

    Args:
        t: Real parameter.

    Returns:
        (x, y) on the unit circle.

    Time complexity: O(1).
    """
    d = 1 + t**2
    return (2*t/d, (1-t**2)/d)


def stereo_conformal_factor(t: float) -> float:
    """Conformal factor of stereographic projection: 2/(1+t^2).

    Time complexity: O(1).
    """
    return 2.0 / (1 + t**2)


def zmod_negation_fixed_points(p: int) -> List[int]:
    """Find elements x in Z/pZ such that -x = x (mod p).

    Args:
        p: The modulus.

    Returns:
        List of fixed points.

    Time complexity: O(p).
    """
    return [x for x in range(p) if (2 * x) % p == 0]


# Example usage
if __name__ == "__main__":
    print("=== Stereographic Sheaf Algorithms ===\n")

    # 1. Trivial gluing in R^3
    D = StereoGluingDatum.trivial(3)
    basis, rank = compute_H0(D)
    print(f"Trivial gluing in R^3: H^0 rank = {rank} (should be 3)")

    # 2. Negation gluing in R^3
    D = StereoGluingDatum.negation(3)
    basis, rank = compute_H0(D)
    print(f"Negation gluing in R^3: H^0 rank = {rank} (should be 0)")

    # 3. Reflection gluing in R^3
    D = StereoGluingDatum.reflection(3, 0)
    basis_p, rank_p = compute_H0(D)
    basis_m, rank_m = compute_H0_antisym(D)
    print(f"Reflection(axis=0) in R^3: H^0 rank = {rank_p}, H^0_anti rank = {rank_m}")
    print(f"  Euler char = {rank_p} - {rank_m} = {euler_characteristic(D)}")

    # 4. Spectral decomposition
    g = np.array([1.0, 2.0, 3.0])
    s, a = spectral_decomposition(D, g)
    print(f"\nSpectral decomposition of {g}:")
    print(f"  Symmetric part:     {s}")
    print(f"  Antisymmetric part: {a}")
    print(f"  Sum:                {s + a}")
    print(f"  phi(s) = s: {np.allclose(D.apply(s), s)}")
    print(f"  phi(a) = -a: {np.allclose(D.apply(a), -a)}")

    # 5. ZMod conjecture
    print(f"\nZMod negation fixed points:")
    for p in [2, 3, 5, 7, 11, 13, 17, 19]:
        fps = zmod_negation_fixed_points(p)
        print(f"  Z/{p}Z: {fps} {'(conjecture fails)' if len(fps) > 1 else ''}")
