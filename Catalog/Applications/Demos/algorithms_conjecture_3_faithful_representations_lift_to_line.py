#!/usr/bin/env python3
"""
Algorithms for Finite Abelian Harmonic Analysis

Implements:
  1. Character table construction for arbitrary finite abelian groups
  2. Discrete Fourier Transform (DFT) on finite abelian groups
  3. Convolution via spectral methods
  4. Spectral decomposition of translation-invariant operators
  5. Random walk analysis via character eigenvalues

All algorithms are derived from the formally verified theory:
  - Characters are eigenvectors of convolution (convolution_eigenvalue_formula)
  - Characters separate points (characters_separate_points)
  - Characters are orthogonal (charVec_orthogonality)
  - |Char(G)| = |G| (card_monoidHom_eq)
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from itertools import product as cartesian_product


class FiniteAbelianGroup:
    """
    Representation of a finite abelian group as a product of cyclic groups.

    A group Z/n1 x Z/n2 x ... x Z/nk is specified by its list of orders
    [n1, n2, ..., nk]. Elements are tuples of integers.

    Time complexity: O(1) for group operations, O(|G|) for iteration.
    Space complexity: O(k) per element where k is the number of cyclic factors.
    """

    def __init__(self, orders: List[int]):
        """
        Initialize a finite abelian group.

        Args:
            orders: List of positive integers specifying cyclic factor orders.
                    E.g., [2, 3] represents Z/2Z × Z/3Z.
        """
        assert all(n > 0 for n in orders), "All orders must be positive"
        self.orders = list(orders)
        self.rank = len(orders)
        self.order = 1
        for n in orders:
            self.order *= n
        self._elements = None
        self._elem_to_idx = None

    @property
    def elements(self) -> List[Tuple[int, ...]]:
        """List all group elements."""
        if self._elements is None:
            self._elements = list(cartesian_product(*(range(n) for n in self.orders)))
        return self._elements

    @property
    def elem_to_idx(self) -> dict:
        """Map from element tuple to its index."""
        if self._elem_to_idx is None:
            self._elem_to_idx = {e: i for i, e in enumerate(self.elements)}
        return self._elem_to_idx

    def identity(self) -> Tuple[int, ...]:
        """Return the identity element."""
        return tuple(0 for _ in self.orders)

    def add(self, a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        """Group operation (component-wise addition mod orders)."""
        return tuple((ai + bi) % ni for ai, bi, ni in zip(a, b, self.orders))

    def neg(self, a: Tuple[int, ...]) -> Tuple[int, ...]:
        """Group inverse (component-wise negation mod orders)."""
        return tuple((-ai) % ni for ai, ni in zip(a, self.orders))

    def __repr__(self):
        return " × ".join(f"Z/{n}Z" for n in self.orders)


def character_table(G: FiniteAbelianGroup) -> np.ndarray:
    """
    Construct the full character table of a finite abelian group.

    For G = Z/n1 × ... × Z/nk, character (k1,...,kk) at element (g1,...,gk) is:
        χ_{(k1,...,kk)}(g1,...,gk) = ∏_i exp(2πi · ki · gi / ni)

    Args:
        G: A finite abelian group

    Returns:
        |G| × |G| complex matrix where entry [i, j] = χ_i(g_j)

    Time complexity: O(|G|² · k) where k is the rank
    Space complexity: O(|G|²)

    Correctness: Verified by charVec_translate and charVec_orthogonality theorems.
    """
    n = G.order
    table = np.zeros((n, n), dtype=complex)

    char_labels = list(cartesian_product(*(range(o) for o in G.orders)))

    for i, klabel in enumerate(char_labels):
        for j, elem in enumerate(G.elements):
            val = 1.0 + 0j
            for k, g, order in zip(klabel, elem, G.orders):
                val *= np.exp(2j * np.pi * k * g / order)
            table[i, j] = val

    return table


def dft(G: FiniteAbelianGroup, f: np.ndarray) -> np.ndarray:
    """
    Discrete Fourier Transform on a finite abelian group.

    Computes f_hat(χ) = ∑_g f(g) · χ(g)^{-1} for all characters χ.

    This is the Fourier coefficient (mulFourierCoeff in the formal development).

    Args:
        G: A finite abelian group
        f: Function values as array of length |G|

    Returns:
        Array of Fourier coefficients, one per character

    Time complexity: O(|G|²) in general; O(|G| log |G|) for cyclic groups via FFT
    Space complexity: O(|G|)

    Correctness: This computes exactly the eigenvalues from convolution_eigenvalue_formula.
    """
    table = character_table(G)
    return table.conj() @ f


def idft(G: FiniteAbelianGroup, f_hat: np.ndarray) -> np.ndarray:
    """
    Inverse Discrete Fourier Transform.

    Recovers f from its Fourier coefficients: f(g) = (1/|G|) ∑_χ f_hat(χ) · χ(g).

    Args:
        G: A finite abelian group
        f_hat: Fourier coefficients

    Returns:
        Function values as array

    Time complexity: O(|G|²)
    """
    table = character_table(G)
    return (table.T @ f_hat) / G.order


def spectral_convolve(G: FiniteAbelianGroup, f: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Compute convolution using spectral methods.

    Uses the convolution theorem: DFT(f * v) = DFT(f) · DFT(v)
    where · is pointwise multiplication.

    This is a direct application of convolution_eigenvalue_formula:
    characters diagonalize convolution, so convolution becomes
    pointwise multiplication in the spectral domain.

    Args:
        G: A finite abelian group
        f: First function (convolution kernel)
        v: Second function

    Returns:
        Convolution f * v

    Time complexity: O(|G|²) via DFT; O(|G| log |G|) if FFT available
    Space complexity: O(|G|)
    """
    f_hat = dft(G, f)
    v_hat = dft(G, v)
    return idft(G, f_hat * v_hat)


def direct_convolve(G: FiniteAbelianGroup, f: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Compute convolution directly (for verification).

    (f * v)(x) = ∑_y f(y) · v(y⁻¹ · x)

    Time complexity: O(|G|²)
    """
    n = G.order
    result = np.zeros(n, dtype=complex)
    for j, x in enumerate(G.elements):
        s = 0.0 + 0j
        for k, y in enumerate(G.elements):
            y_inv_x = G.add(G.neg(y), x)
            s += f[k] * v[G.elem_to_idx[y_inv_x]]
        result[j] = s
    return result


def spectral_decomposition(G: FiniteAbelianGroup, kernel: np.ndarray) -> dict:
    """
    Compute the full spectral decomposition of a convolution operator.

    Given a convolution kernel f, computes:
    - Eigenvalues: λ_χ = ∑_g f(g) · χ(g)⁻¹ for each character χ
    - Eigenvectors: the character vectors themselves

    This implements the convolution_eigenvalue_formula theorem:
    conv(f, charVec χ)(x) = λ_χ · charVec χ(x)

    Args:
        G: A finite abelian group
        kernel: Convolution kernel as array

    Returns:
        Dictionary with:
          'eigenvalues': array of eigenvalues
          'eigenvectors': character table (rows = eigenvectors)
          'spectral_gap': 1 - second largest |eigenvalue|
    """
    eigenvalues = dft(G, kernel)
    eigenvectors = character_table(G)

    sorted_abs = np.sort(np.abs(eigenvalues))[::-1]
    spectral_gap = 1 - sorted_abs[1] if len(sorted_abs) > 1 else 1.0

    return {
        'eigenvalues': eigenvalues,
        'eigenvectors': eigenvectors,
        'spectral_gap': spectral_gap,
        'sorted_abs_eigenvalues': sorted_abs,
    }


def mixing_time_estimate(G: FiniteAbelianGroup, kernel: np.ndarray,
                         epsilon: float = 0.01) -> float:
    """
    Estimate mixing time of a random walk on G with given transition kernel.

    Uses the spectral gap: t_mix ≈ (1/gap) · log(|G|/ε)

    The spectral gap is computed from the character eigenvalues, which is
    made rigorous by the convolution_eigenvalue_formula theorem.

    Args:
        G: A finite abelian group
        kernel: Transition kernel (probability distribution on G)
        epsilon: Target total variation distance

    Returns:
        Estimated mixing time in number of steps
    """
    decomp = spectral_decomposition(G, kernel)
    gap = decomp['spectral_gap']
    if gap <= 0:
        return float('inf')
    return (1.0 / gap) * np.log(G.order / epsilon)


def verify_all_properties(G: FiniteAbelianGroup) -> dict:
    """
    Verify all formally proved properties for a concrete group.

    Checks:
    1. Card: number of characters = |G|
    2. Orthogonality: character rows are orthogonal
    3. Self-inner-product: each character has self-inner-product |G|
    4. Separation: characters separate all points
    5. Nontrivial detection: every g ≠ 1 is detected
    6. Convolution eigenvector property

    Returns:
        Dictionary of verification results
    """
    table = character_table(G)
    n = G.order
    results = {}

    # 1. Cardinality
    results['card'] = (table.shape[0] == n)

    # 2. Orthogonality
    gram = table @ table.conj().T
    results['orthogonality'] = np.allclose(gram, n * np.eye(n), atol=1e-8)

    # 3. Self-inner-product
    self_ips = np.array([np.sum(table[i, :] * np.conj(table[i, :])) for i in range(n)])
    results['self_inner_product'] = np.allclose(self_ips, n, atol=1e-8)

    # 4. Separation
    separates = True
    for i in range(n):
        for j in range(i + 1, n):
            if np.allclose(table[:, i], table[:, j], atol=1e-10):
                separates = False
                break
    results['separation'] = separates

    # 5. Nontrivial detection
    identity_idx = G.elem_to_idx[G.identity()]
    detects = True
    for j in range(n):
        if j == identity_idx:
            continue
        if np.allclose(table[:, j], table[:, identity_idx], atol=1e-10):
            detects = False
            break
    results['detection'] = detects

    # 6. Convolution eigenvector
    np.random.seed(0)
    f = np.random.randn(n) + 1j * np.random.randn(n)
    conv_ok = True
    for i in range(n):
        chi = table[i, :]
        conv_result = direct_convolve(G, f, chi)
        eigenvalue = np.sum(f * np.conj(chi))
        if not np.allclose(conv_result, eigenvalue * chi, atol=1e-8):
            conv_ok = False
            break
    results['convolution_eigenvector'] = conv_ok

    return results


if __name__ == "__main__":
    # Example usage
    print("Algorithms for Finite Abelian Harmonic Analysis")
    print("=" * 50)

    G = FiniteAbelianGroup([4])
    print(f"\nGroup: {G}")
    print(f"Order: {G.order}")
    print(f"Elements: {G.elements}")

    table = character_table(G)
    print(f"\nCharacter table:\n{np.round(table, 4)}")

    f = np.array([1, 0, 0, 0], dtype=complex)  # delta function at identity
    f_hat = dft(G, f)
    print(f"\nDFT of delta: {np.round(f_hat, 4)}")

    f_back = idft(G, f_hat)
    print(f"IDFT recovery: {np.round(f_back, 4)}")

    # Verify all properties
    results = verify_all_properties(G)
    print(f"\nProperty verification:")
    for prop, ok in results.items():
        print(f"  {prop}: {'✓' if ok else '✗'}")
