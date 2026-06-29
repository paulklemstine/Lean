#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Kyber Compression Fiber Analysis

Implements the core algorithms from the research paper:
1. Fiber enumeration via the Beatty sequence decomposition
2. Decision advantage computation
3. Smooth contraction bound evaluation
4. Fiber contraction certificate generation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import Dict, List, Tuple, Optional
import numpy as np
from dataclasses import dataclass, field


@dataclass
class FiberContraction:
    """A fiber contraction certificate for compress: Z/qZ → Z/dZ.

    Attributes:
        q: Input modulus
        d: Output modulus
        floor_size: Size of small fibers (q // d)
        ceil_size: Size of large fibers (q // d + 1)
        num_large: Number of large fibers (q % d)
        num_small: Number of small fibers (d - q % d)
        contraction_ratio: The ratio d/q governing advantage contraction
    """
    q: int
    d: int
    floor_size: int = field(init=False)
    ceil_size: int = field(init=False)
    num_large: int = field(init=False)
    num_small: int = field(init=False)
    contraction_ratio: float = field(init=False)

    def __post_init__(self):
        assert self.q > 0 and self.d > 0, "q and d must be positive"
        assert self.d <= self.q, "d must be at most q"
        self.floor_size = self.q // self.d
        self.ceil_size = self.floor_size + 1
        self.num_large = self.q % self.d
        self.num_small = self.d - self.num_large
        self.contraction_ratio = self.d / self.q

    def verify(self) -> bool:
        """Verify the partition property: fiber sizes sum to q.

        Time complexity: O(1)
        """
        return (self.num_large * self.ceil_size +
                self.num_small * self.floor_size == self.q)

    def smooth_bound(self, L: float, tv_before: float) -> float:
        """Compute the smooth contraction bound.

        For an L-smooth distribution (max PMF ≤ L/q), the decision advantage
        after compression is bounded by (d/q) · L · TV(χ, U).

        Args:
            L: Smoothness parameter (max_x χ(x) * q)
            tv_before: Decision advantage before compression

        Returns:
            Upper bound on decision advantage after compression

        Time complexity: O(1)
        """
        return self.contraction_ratio * L * tv_before


def kyber_compress(x: int, q: int, d: int) -> int:
    """Kyber compression function: x ↦ ⌊d·x/q⌋.

    Maps an element of Z/qZ to Z/dZ via deterministic rounding.

    Args:
        x: Input in {0, 1, ..., q-1}
        q: Input modulus (typically 3329)
        d: Output modulus (typically 1024 or 2048)

    Returns:
        Compressed output in {0, 1, ..., d-1}

    Time complexity: O(1)
    Space complexity: O(1)

    Example:
        >>> kyber_compress(0, 3329, 1024)
        0
        >>> kyber_compress(3328, 3329, 1024)
        1023
    """
    return (d * x) // q


def enumerate_fibers(q: int, d: int) -> Dict[int, List[int]]:
    """Enumerate all fibers of the compression map.

    Computes {y: [x₁, x₂, ...]} where f(xᵢ) = y.

    Args:
        q: Input modulus
        d: Output modulus

    Returns:
        Dictionary mapping each output y to its fiber (list of inputs)

    Time complexity: O(q)
    Space complexity: O(q)

    Example:
        >>> fibers = enumerate_fibers(7, 3)
        >>> len(fibers[0])  # fiber of 0
        3
    """
    fibers: Dict[int, List[int]] = {y: [] for y in range(d)}
    for x in range(q):
        y = kyber_compress(x, q, d)
        fibers[y].append(x)
    return fibers


def beatty_fiber_sizes(q: int, d: int) -> Dict[int, int]:
    """Compute fiber sizes using the Beatty/floor-division formula.

    For the compression x ↦ ⌊d·x/q⌋, fiber(y) = {x : ⌊d·x/q⌋ = y},
    which is the set of integers in [y·q/d, (y+1)·q/d).
    The size is ⌊(y+1)·q/d⌋ - ⌊y·q/d⌋, which is either ⌊q/d⌋ or ⌊q/d⌋+1.

    By the division algorithm, q = d·a + r, and exactly r fibers have
    size a+1 (the "large" fibers), though which specific y values are
    large depends on the Beatty sequence structure.

    Args:
        q: Input modulus
        d: Output modulus

    Returns:
        Dictionary mapping each y to its exact fiber size

    Time complexity: O(d)
    Space complexity: O(d)

    Example:
        >>> sizes = beatty_fiber_sizes(3329, 1024)
        >>> sizes[0]  # large fiber
        4
        >>> sum(1 for s in sizes.values() if s == 4)  # count large
        257
    """
    # Compute exact fiber sizes: count of integers in [y*q/d, (y+1)*q/d)
    # Using ceiling arithmetic: count = ⌈(y+1)*q/d⌉ - ⌈y*q/d⌉
    def ceil_div(a: int, b: int) -> int:
        return (a + b - 1) // b
    return {y: ceil_div((y + 1) * q, d) - ceil_div(y * q, d) for y in range(d)}


def verify_beatty_structure(q: int, d: int) -> Tuple[bool, str]:
    """Verify that the actual fibers match the Beatty sequence prediction.

    Enumerates all fibers and checks that each matches the predicted size.

    Args:
        q: Input modulus
        d: Output modulus

    Returns:
        (success, message) tuple

    Time complexity: O(q)
    Space complexity: O(q)
    """
    fibers = enumerate_fibers(q, d)
    predicted = beatty_fiber_sizes(q, d)

    for y in range(d):
        actual = len(fibers[y])
        expected = predicted[y]
        if actual != expected:
            return False, f"Fiber {y}: actual={actual}, expected={expected}"

    return True, f"All {d} fibers match Beatty prediction (q={q}, d={d})"


def decision_advantage(p: np.ndarray, u: np.ndarray) -> float:
    """Compute decision advantage (total variation distance).

    TV(p, u) = (1/2) Σ |p(x) - u(x)|

    Args:
        p: First PMF (probability mass function)
        u: Second PMF

    Returns:
        Total variation distance in [0, 1]

    Time complexity: O(n) where n = len(p)
    """
    return 0.5 * np.sum(np.abs(p - u))


def push_forward_pmf(pmf: np.ndarray, q: int, d: int) -> np.ndarray:
    """Push-forward of a PMF through the compression map.

    (f_* p)(y) = Σ_{x: f(x)=y} p(x)

    Args:
        pmf: Input PMF on Z/qZ
        q: Input modulus
        d: Output modulus

    Returns:
        Output PMF on Z/dZ

    Time complexity: O(q)
    Space complexity: O(d)
    """
    result = np.zeros(d)
    for x in range(q):
        y = kyber_compress(x, q, d)
        result[y] += pmf[x]
    return result


def discrete_gaussian(q: int, sigma: float) -> np.ndarray:
    """Discrete Gaussian distribution on Z/qZ.

    ρ_σ(x) ∝ exp(-dist(x,0)² / (2σ²))
    where dist(x, 0) = min(x, q-x) is the wrap-around distance.

    Args:
        q: Modulus
        sigma: Standard deviation parameter

    Returns:
        PMF array of length q

    Time complexity: O(q)
    """
    xs = np.arange(q)
    dists = np.minimum(xs, q - xs).astype(float)
    unnorm = np.exp(-dists**2 / (2 * sigma**2))
    return unnorm / unnorm.sum()


def compute_contraction_table(
    q: int, d: int, sigma_range: range
) -> List[Dict[str, float]]:
    """Compute contraction ratio table for discrete Gaussians.

    For each σ, computes the decision advantage before and after compression,
    the empirical contraction ratio, and the theoretical bound.

    Args:
        q: Input modulus
        d: Output modulus
        sigma_range: Range of σ values to test

    Returns:
        List of result dictionaries

    Time complexity: O(|sigma_range| · q)
    """
    u = np.ones(q) / q
    u_compressed = push_forward_pmf(u, q, d)
    results = []

    for sigma in sigma_range:
        chi = discrete_gaussian(q, sigma)
        chi_compressed = push_forward_pmf(chi, q, d)

        tv_before = decision_advantage(chi, u)
        tv_after = decision_advantage(chi_compressed, u_compressed)

        L = float(max(chi) * q)
        ratio = tv_after / tv_before if tv_before > 1e-15 else 0.0
        bound = (d / q) * L * tv_before

        results.append({
            'sigma': sigma,
            'tv_before': tv_before,
            'tv_after': tv_after,
            'ratio': ratio,
            'L': L,
            'bound': bound,
            'bound_ratio': tv_after / bound if bound > 1e-15 else 0.0,
        })

    return results


def generate_certificate(q: int, d: int) -> FiberContraction:
    """Generate a verified fiber contraction certificate.

    Creates the certificate and verifies the partition property.

    Args:
        q: Input modulus
        d: Output modulus

    Returns:
        Verified FiberContraction instance

    Raises:
        AssertionError: If verification fails

    Example:
        >>> cert = generate_certificate(3329, 1024)
        >>> cert.num_large
        257
        >>> cert.contraction_ratio
        0.30758...
    """
    cert = FiberContraction(q=q, d=d)
    assert cert.verify(), "Partition verification failed!"

    # Also verify against actual enumeration
    ok, msg = verify_beatty_structure(q, d)
    assert ok, msg

    return cert


# ─── Example Usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Kyber Compression Fiber Analysis — Algorithm Demonstrations")
    print("=" * 60)

    # Generate certificates for all Kyber parameter sets
    for name, d in [("Kyber-512/768 (d_u)", 1024),
                     ("Kyber-512/768 (d_v)", 16),
                     ("Kyber-1024 (d_u)", 2048),
                     ("Kyber-1024 (d_v)", 32)]:
        cert = generate_certificate(3329, d)
        print(f"\n{name}: compress Z/3329Z → Z/{d}Z")
        print(f"  Floor size: {cert.floor_size}")
        print(f"  Ceil size:  {cert.ceil_size}")
        print(f"  Large fibers: {cert.num_large}")
        print(f"  Small fibers: {cert.num_small}")
        print(f"  Contraction ratio: {cert.contraction_ratio:.6f}")
        print(f"  Verified: {cert.verify()}")

    # Contraction table
    print("\n" + "=" * 60)
    print("Contraction Table (q=3329, d=1024)")
    results = compute_contraction_table(3329, 1024, range(1, 31))
    print(f"{'σ':>4s} | {'TV before':>10s} | {'TV after':>10s} | {'Ratio':>8s} | {'Bound':>10s}")
    print(f"{'─'*4}-+-{'─'*10}-+-{'─'*10}-+-{'─'*8}-+-{'─'*10}")
    for r in results:
        print(f"{r['sigma']:4d} | {r['tv_before']:10.6f} | {r['tv_after']:10.6f} | "
              f"{r['ratio']:8.4f} | {r['bound']:10.6f}")
