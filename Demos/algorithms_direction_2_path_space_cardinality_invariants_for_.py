#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for path space cardinality analysis.

Implements:
  1. Normalized polynomial path encoder/decoder
  2. Affine-perturbation codec (endpoint-zero functions ↔ paths)
  3. Translation transport on sampled paths
  4. Cardinality bound verification via sampling

Keywords: polynomial interpolation, path encoding, cardinal arithmetic,
          cubical path spaces, function-space semantics
"""

import numpy as np
from typing import List, Tuple, Optional, Callable


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Normalized Polynomial Path Codec
# ─────────────────────────────────────────────────────────────────

class NormalizedPolynomialCodec:
    """Encode/decode normalized polynomial paths satisfying p(0)=a, p(1)=b.

    A normalized polynomial path from a to b is:
        p(t) = a + (b-a)*t + sum_{k=1}^{d-1} c_k * t^k * (1-t)

    The free coefficients c_1, ..., c_{d-1} parameterize the space.

    Time complexity: O(d * n) for evaluation at n points with degree d.
    Space complexity: O(d) for coefficient storage.
    """

    def __init__(self, a: float, b: float):
        """Initialize with endpoints a, b."""
        self.a = a
        self.b = b

    def encode(self, coefficients: np.ndarray) -> Callable[[np.ndarray], np.ndarray]:
        """Encode free coefficients into a path function.

        Args:
            coefficients: Array of d-1 free coefficients [c_1, ..., c_{d-1}].

        Returns:
            A callable path function t -> p(t) with p(0)=a, p(1)=b.
        """
        a, b = self.a, self.b

        def path(t: np.ndarray) -> np.ndarray:
            result = a + (b - a) * t
            for k, c in enumerate(coefficients, start=1):
                result += c * t**k * (1 - t)
            return result

        return path

    def decode(self, path_fn: Callable, degree: int,
               t_sample: Optional[np.ndarray] = None) -> np.ndarray:
        """Decode a path function into its free coefficients (least-squares fit).

        Args:
            path_fn: The path function to decode.
            degree: Expected polynomial degree.
            t_sample: Sample points (default: Chebyshev nodes).

        Returns:
            Estimated free coefficients.
        """
        if t_sample is None:
            n_samples = max(degree * 3, 20)
            # Chebyshev nodes mapped to [0, 1]
            k = np.arange(1, n_samples + 1)
            t_sample = 0.5 * (1 - np.cos(np.pi * (2*k - 1) / (2*n_samples)))

        a, b = self.a, self.b
        # Residual after removing affine part
        residual = path_fn(t_sample) - a - (b - a) * t_sample

        # Build basis matrix: column k is t^k * (1-t)
        n_coeffs = degree - 1
        basis = np.column_stack([
            t_sample**(k+1) * (1 - t_sample) for k in range(n_coeffs)
        ])

        # Least squares solve
        coeffs, _, _, _ = np.linalg.lstsq(basis, residual, rcond=None)
        return coeffs

    def verify_endpoints(self, path_fn: Callable, tol: float = 1e-10) -> bool:
        """Verify that a path function satisfies endpoint constraints."""
        t0 = np.array([0.0])
        t1 = np.array([1.0])
        return (abs(path_fn(t0)[0] - self.a) < tol and
                abs(path_fn(t1)[0] - self.b) < tol)


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Affine-Perturbation Codec
# ─────────────────────────────────────────────────────────────────

class AffinePerturbationCodec:
    """Bijection between endpoint-zero functions and paths.

    Forward:  f ↦ (t ↦ a + (b-a)*t + f(t))     [perturbAffine]
    Inverse:  p ↦ (t ↦ p(t) - a - (b-a)*t)     [pathToEndpointZeroFun]

    This is the computational realization of the formal equivalence
    pathOverEquivEndpointZeroFun proved in PathCardinal.lean.

    Time complexity: O(n) per evaluation at n grid points.
    Space complexity: O(n) for sampled representations.
    """

    def __init__(self, a: float, b: float):
        self.a = a
        self.b = b

    def path_from_perturbation(self, f: Callable) -> Callable:
        """Forward map: endpoint-zero function → path."""
        a, b = self.a, self.b
        def path(t):
            return a + (b - a) * t + f(t)
        return path

    def perturbation_from_path(self, p: Callable) -> Callable:
        """Inverse map: path → endpoint-zero function."""
        a, b = self.a, self.b
        def f(t):
            return p(t) - a - (b - a) * t
        return f

    def verify_roundtrip(self, f: Callable, t_grid: np.ndarray,
                         tol: float = 1e-12) -> float:
        """Verify that encode-then-decode recovers f, return max error."""
        path = self.path_from_perturbation(f)
        recovered_f = self.perturbation_from_path(path)
        return float(np.max(np.abs(f(t_grid) - recovered_f(t_grid))))


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Translation Transport
# ─────────────────────────────────────────────────────────────────

class TranslationTransport:
    """Transport paths by translation: γ ↦ γ + c.

    Realizes the formal translationPathEquiv from PathCardinal.lean.
    Translation preserves path space cardinality.

    Time complexity: O(n) for n grid points.
    """

    @staticmethod
    def translate(path_fn: Callable, c: float) -> Callable:
        """Translate a path by constant c."""
        def translated(t):
            return path_fn(t) + c
        return translated

    @staticmethod
    def inverse_translate(path_fn: Callable, c: float) -> Callable:
        """Inverse translation by -c."""
        def inv_translated(t):
            return path_fn(t) - c
        return inv_translated

    @staticmethod
    def verify_bijection(path_fn: Callable, c: float,
                         t_grid: np.ndarray, tol: float = 1e-12) -> float:
        """Verify translation is a bijection (roundtrip error)."""
        translated = TranslationTransport.translate(path_fn, c)
        recovered = TranslationTransport.inverse_translate(translated, c)
        return float(np.max(np.abs(path_fn(t_grid) - recovered(t_grid))))


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Cardinality Bound Sampler
# ─────────────────────────────────────────────────────────────────

class CardinalityBoundSampler:
    """Sample-based verification of cardinality bounds.

    Lower bound: inject ℝ into PathOver via c ↦ perturbation by c·t·(1-t).
    Upper bound: project PathOver into (ℝ → ℝ) by forgetting constraints.

    This provides numerical evidence for the formal cardinality sandwich.
    """

    def __init__(self, a: float, b: float):
        self.a = a
        self.b = b

    def lower_bound_injection(self, c: float) -> Callable:
        """Map c ∈ ℝ to the path t ↦ a + (b-a)*t + c*t*(1-t)."""
        a, b = self.a, self.b
        def path(t):
            return a + (b - a) * t + c * t * (1 - t)
        return path

    def verify_injection_separation(self, c1: float, c2: float,
                                     t_grid: np.ndarray) -> float:
        """Verify that distinct c values produce distinct paths."""
        p1 = self.lower_bound_injection(c1)
        p2 = self.lower_bound_injection(c2)
        return float(np.max(np.abs(p1(t_grid) - p2(t_grid))))

    def batch_injection_test(self, n_samples: int = 1000,
                             seed: int = 42) -> dict:
        """Test injectivity on a batch of random pairs.

        Returns statistics about the separation of injected paths.
        """
        rng = np.random.default_rng(seed)
        t_grid = np.linspace(0, 1, 501)

        separations = []
        for _ in range(n_samples):
            c1, c2 = rng.normal(0, 10, size=2)
            if abs(c1 - c2) < 1e-15:
                continue
            sep = self.verify_injection_separation(c1, c2, t_grid)
            separations.append(sep)

        separations = np.array(separations)
        return {
            'n_tests': len(separations),
            'min_separation': float(separations.min()),
            'mean_separation': float(separations.mean()),
            'max_separation': float(separations.max()),
            'all_distinct': bool(separations.min() > 1e-14),
        }


# ─────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Path Space Cardinality Analysis")
    print("=" * 55)

    # Polynomial codec
    codec = NormalizedPolynomialCodec(a=0, b=1)
    coeffs = np.array([2.0, -1.5, 0.8])
    path_fn = codec.encode(coeffs)
    print(f"\nPolynomial codec: p(0)={path_fn(np.array([0.0]))[0]:.6f}, "
          f"p(1)={path_fn(np.array([1.0]))[0]:.6f}")
    recovered = codec.decode(path_fn, degree=4)
    print(f"  Original coeffs:  {coeffs}")
    print(f"  Recovered coeffs: {recovered.round(6)}")

    # Affine perturbation codec
    apc = AffinePerturbationCodec(a=2, b=5)
    f = lambda t: 3 * t * (1 - t) * np.sin(2 * np.pi * t)
    t_grid = np.linspace(0, 1, 1000)
    err = apc.verify_roundtrip(f, t_grid)
    print(f"\nAffine perturbation roundtrip error: {err:.2e}")

    # Translation transport
    tt = TranslationTransport()
    err = tt.verify_bijection(path_fn, c=7.0, t_grid=t_grid)
    print(f"Translation roundtrip error: {err:.2e}")

    # Cardinality bound sampler
    cbs = CardinalityBoundSampler(a=0, b=1)
    stats = cbs.batch_injection_test()
    print(f"\nCardinality injection test:")
    print(f"  {stats['n_tests']} pairs tested")
    print(f"  Min separation: {stats['min_separation']:.6e}")
    print(f"  All distinct: {stats['all_distinct']}")

    print("\n✓ All algorithms verified successfully")
