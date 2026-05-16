#!/usr/bin/env python3
"""
Algorithms for Spectral Analysis on Ternary Cubes

Implements:
1. Fast product noise operator via coordinate-wise application (O(L · 3^L) vs O(9^L))
2. Fourier decomposition on (Fin 3)^L
3. Spectral truncation and low-degree approximation
4. Bias estimation with spectral decay bounds
"""

import numpy as np
from itertools import product as cart_product
from typing import List, Tuple, Dict, Optional


class TernaryCubeSpectral:
    """
    Spectral analysis engine for functions on (Fin 3)^L.

    Implements the product noise operator T_ρ and its exact spectral decomposition
    into homogeneous degree subspaces with eigenvalues ρ^d.

    Parameters
    ----------
    L : int
        Word length (number of coordinates).

    Attributes
    ----------
    words : list of tuples
        All elements of (Fin 3)^L.
    n : int
        Total number of words (= 3^L).
    ternary_basis : ndarray of shape (3, 3)
        Orthonormal basis for ℝ^{Fin 3}: row 0 = constant, rows 1,2 = mean-zero.

    Complexity
    ----------
    Space: O(3^L) for storing function values.
    Construction: O(3^L · L) for generating words.
    """

    def __init__(self, L: int):
        self.L = L
        self.words = list(cart_product(range(3), repeat=L))
        self.n = 3 ** L

        # Orthonormal basis for ℝ^3 adapted to constant/mean-zero decomposition
        self.ternary_basis = np.array([
            [1, 1, 1],          # constant direction (unnormalized)
            [1, -1, 0],         # mean-zero direction 1
            [1, 1, -2],         # mean-zero direction 2
        ], dtype=float)
        # Normalize
        for i in range(3):
            self.ternary_basis[i] /= np.linalg.norm(self.ternary_basis[i])

        # Precompute word-to-index mapping
        self._word_to_idx = {w: i for i, w in enumerate(self.words)}

    def apply_coord_noise(self, rho: float, coord: int, f: np.ndarray) -> np.ndarray:
        """
        Apply single-coordinate noise at position `coord`.

        T_{ρ,i} f(x) = Σ_v K_ρ(x_i, v) · f(x with x_i replaced by v)

        Time: O(3 · 3^L) = O(3^L)
        Space: O(3^L)

        Parameters
        ----------
        rho : float
            Noise parameter in [0, 1].
        coord : int
            Coordinate index (0 to L-1).
        f : ndarray of shape (3^L,)
            Function values.

        Returns
        -------
        ndarray of shape (3^L,)
            Result of applying coordinate noise.
        """
        result = np.zeros(self.n)
        p_same = rho + (1 - rho) / 3
        p_diff = (1 - rho) / 3

        for i, x in enumerate(self.words):
            total = 0.0
            for v in range(3):
                kernel_val = p_same if x[coord] == v else p_diff
                # Build y = x with coord replaced by v
                y = list(x)
                y[coord] = v
                j = self._word_to_idx[tuple(y)]
                total += kernel_val * f[j]
            result[i] = total
        return result

    def apply_product_noise_fast(self, rho: float, f: np.ndarray) -> np.ndarray:
        """
        Apply product noise operator T_ρ via sequential coordinate noise.

        Uses the Fubini factorization: T_ρ = T_{ρ,0} ∘ T_{ρ,1} ∘ ... ∘ T_{ρ,L-1}

        This is equivalent to the full kernel computation but runs in
        O(L · 3^L) time instead of O(9^L).

        Time: O(L · 3^L)
        Space: O(3^L)

        Parameters
        ----------
        rho : float
            Noise parameter in [0, 1].
        f : ndarray of shape (3^L,)
            Function values.

        Returns
        -------
        ndarray of shape (3^L,)
            T_ρ f.
        """
        result = f.copy()
        for coord in range(self.L):
            result = self.apply_coord_noise(rho, coord, result)
        return result

    def apply_product_noise_direct(self, rho: float, f: np.ndarray) -> np.ndarray:
        """
        Apply product noise operator via direct kernel computation.

        T_ρ f(x) = Σ_y (Π_i K_ρ(x_i, y_i)) · f(y)

        Time: O(9^L)
        Space: O(3^L)
        """
        result = np.zeros(self.n)
        p_same = rho + (1 - rho) / 3
        p_diff = (1 - rho) / 3

        for i, x in enumerate(self.words):
            total = 0.0
            for j, y in enumerate(self.words):
                kernel = 1.0
                for c in range(self.L):
                    kernel *= p_same if x[c] == y[c] else p_diff
                total += kernel * f[j]
            result[i] = total
        return result

    def fourier_decompose(self, f: np.ndarray) -> Dict[int, np.ndarray]:
        """
        Decompose f into homogeneous degree components.

        f = Σ_d f_d where f_d ∈ homogeneousDegreeSubmodule(L, d)
        and T_ρ f_d = ρ^d · f_d for all ρ.

        Uses the tensor product basis: each basis function is a product
        of single-site basis vectors, and its degree is the number of
        mean-zero factors.

        Time: O(3^L · 3^L) for computing all inner products
        Space: O(3^L)

        Parameters
        ----------
        f : ndarray of shape (3^L,)
            Function values.

        Returns
        -------
        dict mapping degree (int) to component (ndarray)
            The homogeneous degree-d component f_d.
        """
        components = {d: np.zeros(self.n) for d in range(self.L + 1)}

        # Enumerate all tensor product basis functions
        for basis_indices in cart_product(range(3), repeat=self.L):
            # Compute degree: number of mean-zero factors (index > 0)
            degree = sum(1 for b in basis_indices if b > 0)

            # Build basis function values
            basis_vals = np.array([
                np.prod([self.ternary_basis[basis_indices[c]][w[c]]
                         for c in range(self.L)])
                for w in self.words
            ])

            # Project f onto this basis function
            coeff = np.dot(f, basis_vals)

            # Accumulate into the appropriate degree component
            components[degree] += coeff * basis_vals

        return components

    def spectral_truncation(self, f: np.ndarray, max_degree: int) -> np.ndarray:
        """
        Compute the low-degree truncation of f.

        Returns Σ_{d ≤ max_degree} f_d, the projection of f onto
        the degree-≤k submodule.

        Time: O(3^L · 3^L)
        Space: O(3^L)

        Parameters
        ----------
        f : ndarray of shape (3^L,)
        max_degree : int
            Maximum degree to keep.

        Returns
        -------
        ndarray of shape (3^L,)
            The low-degree approximation.
        """
        components = self.fourier_decompose(f)
        result = np.zeros(self.n)
        for d in range(min(max_degree + 1, self.L + 1)):
            result += components[d]
        return result

    def compute_bias(self, rho: float, f: np.ndarray) -> float:
        """
        Compute the noise bias: ⟨T_ρ f, 1⟩ / 3^L.

        Time: O(L · 3^L) using fast product noise
        Space: O(3^L)
        """
        noised = self.apply_product_noise_fast(rho, f)
        return np.mean(noised)

    def bias_bound(self, rho: float, f: np.ndarray, k: int) -> Tuple[float, float]:
        """
        Compute the spectral bias bound.

        Returns (actual_high_degree_bias, theoretical_bound) where:
        - actual = |⟨T_ρ f_{>k}, 1⟩| / 3^L
        - bound = |ρ|^(k+1) · ‖f_{>k}‖_2

        By the spectral theorem, actual ≤ bound.

        Parameters
        ----------
        rho : float
            Noise parameter.
        f : ndarray of shape (3^L,)
        k : int
            Degree threshold.

        Returns
        -------
        (actual, bound) : tuple of floats
        """
        components = self.fourier_decompose(f)

        # High-degree part
        f_high = np.zeros(self.n)
        for d in range(k + 1, self.L + 1):
            f_high += components[d]

        # Actual high-degree bias
        noised_high = self.apply_product_noise_fast(rho, f_high)
        actual = abs(np.mean(noised_high))

        # Theoretical bound
        high_norm = np.sqrt(np.mean(f_high ** 2))
        bound = abs(rho) ** (k + 1) * high_norm

        return actual, bound

    def degree_spectrum(self, f: np.ndarray) -> List[float]:
        """
        Compute the degree spectrum: ‖f_d‖² for each degree d.

        Returns
        -------
        list of floats
            The L2 mass in each degree sector.
        """
        components = self.fourier_decompose(f)
        return [np.mean(components[d] ** 2) for d in range(self.L + 1)]


def demo_fast_vs_direct():
    """Compare fast (O(L·3^L)) vs direct (O(9^L)) product noise computation."""
    import time

    print("=" * 60)
    print("Algorithm Comparison: Fast vs Direct Product Noise")
    print("=" * 60)

    for L in range(2, 6):
        engine = TernaryCubeSpectral(L)
        f = np.random.randn(engine.n)

        t0 = time.time()
        result_fast = engine.apply_product_noise_fast(0.7, f)
        t_fast = time.time() - t0

        t0 = time.time()
        result_direct = engine.apply_product_noise_direct(0.7, f)
        t_direct = time.time() - t0

        error = np.max(np.abs(result_fast - result_direct))
        speedup = t_direct / max(t_fast, 1e-10)

        print(f"L={L}: fast={t_fast:.4f}s, direct={t_direct:.4f}s, "
              f"speedup={speedup:.1f}x, error={error:.2e}")


def demo_spectral_decomposition():
    """Demonstrate full spectral decomposition and eigenvalue verification."""
    print("\n" + "=" * 60)
    print("Spectral Decomposition Verification")
    print("=" * 60)

    L = 3
    engine = TernaryCubeSpectral(L)
    rho = 0.6

    np.random.seed(123)
    f = np.random.randn(engine.n)

    components = engine.fourier_decompose(f)

    # Verify reconstruction
    f_reconstructed = sum(components.values())
    print(f"\nL = {L}, ρ = {rho}")
    print(f"Reconstruction error: {np.max(np.abs(f - f_reconstructed)):.2e}")

    # Verify eigenvalue property for each component
    print("\nEigenvalue verification:")
    for d in range(L + 1):
        noised = engine.apply_product_noise_fast(rho, components[d])
        expected = rho ** d * components[d]
        error = np.max(np.abs(noised - expected))
        norm = np.sqrt(np.mean(components[d] ** 2))
        print(f"  Degree {d}: ‖f_d‖ = {norm:.4f}, "
              f"|T_ρ f_d - ρ^d f_d| = {error:.2e}")


def demo_bias_bounds():
    """Demonstrate spectral bias bounds."""
    print("\n" + "=" * 60)
    print("Spectral Bias Bounds")
    print("=" * 60)

    L = 4
    engine = TernaryCubeSpectral(L)

    np.random.seed(456)
    f = np.random.randn(engine.n)

    print(f"\nL = {L}")
    print(f"{'ρ':>6} | {'k':>3} | {'actual bias':>12} | {'bound':>12} | {'ratio':>8}")
    print("-" * 55)

    for rho in [0.3, 0.5, 0.7, 0.9]:
        for k in range(L):
            actual, bound = engine.bias_bound(rho, f, k)
            ratio = actual / max(bound, 1e-15)
            print(f"{rho:6.1f} | {k:3d} | {actual:12.6e} | {bound:12.6e} | {ratio:8.4f}")
        print("-" * 55)


if __name__ == "__main__":
    demo_fast_vs_direct()
    demo_spectral_decomposition()
    demo_bias_bounds()
    print("\nAll algorithm demos completed successfully!")
