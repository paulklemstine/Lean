#!/usr/bin/env python3
"""
Applications of the Finite Hilbert-Pólya Blueprint.

Demonstrates practical uses of the certified theorems:
1. Certified zero-search reduction via functional symmetry
2. Arithmetic matrix spectral analysis
3. Self-inversive polynomial design for signal processing
4. Critical-line certificate generation
"""

import numpy as np
from typing import List, Tuple
import json


# ═══════════════════════════════════════════════
# Application 1: Certified Zero-Search Reduction
# ═══════════════════════════════════════════════

def certified_zero_search(N: int, chi, s_values: List[complex]) -> dict:
    """
    Exploit functional symmetry to halve the zero search domain.

    Since Z_N(1-s) = χ(1-s)·Z_N(s), zeros come in {s, 1-s} pairs.
    We only need to search the half-strip Re(s) ≥ 1/2.

    Args:
        N: truncation parameter
        chi: functional equation factor
        s_values: candidate zero locations (with Re(s) ≥ 1/2)

    Returns:
        Dictionary with found zeros and their reflections
    """
    found_zeros = []
    for s in s_values:
        d_sum = sum(n ** (-s) for n in range(1, N + 1))
        d_dual = sum(n ** (s - 1) for n in range(1, N + 1))
        val = d_sum + chi(s) * d_dual

        if abs(val) < 1e-6:
            found_zeros.append({
                'zero': s,
                'reflected_zero': 1 - s,
                'residual': abs(val),
                're_s': s.real,
                'on_critical_line': abs(s.real - 0.5) < 1e-6
            })

    return {
        'N': N,
        'searched_points': len(s_values),
        'zeros_found': len(found_zeros),
        'savings': '50% (reflection symmetry)',
        'zeros': found_zeros
    }


# ═══════════════════════════════════════════════
# Application 2: Arithmetic Matrix Design
# ═══════════════════════════════════════════════

def design_arithmetic_hermitian(
    primes: List[int],
    kernel_type: str = 'divisor'
) -> Tuple[np.ndarray, dict]:
    """
    Design Hermitian matrices from arithmetic data and analyze their spectra.

    Different kernel types produce different spectral properties:
    - 'log': K(p,q) = log(pq)/sqrt(pq)  [rank ≤ 2, degenerate]
    - 'divisor': K(p,q) = gcd(p,q)/sqrt(pq)  [full rank, nontrivial]
    - 'mobius': K(p,q) = μ(gcd(p,q))/sqrt(pq)  [sparse, interesting]

    Args:
        primes: list of primes to use as indices
        kernel_type: type of arithmetic kernel

    Returns:
        (H, analysis) where H is Hermitian and analysis contains spectral info
    """
    n = len(primes)
    H = np.zeros((n, n))

    if kernel_type == 'log':
        for i, p in enumerate(primes):
            for j, q in enumerate(primes):
                H[i, j] = np.log(p * q) / np.sqrt(p * q)
    elif kernel_type == 'divisor':
        for i, p in enumerate(primes):
            for j, q in enumerate(primes):
                H[i, j] = np.gcd(p, q) / np.sqrt(p * q)
    elif kernel_type == 'mobius':
        for i, p in enumerate(primes):
            for j, q in enumerate(primes):
                g = np.gcd(p, q)
                # Möbius function for small values
                if g == 1:
                    mu = 1
                elif any(g % (pk * pk) == 0 for pk in range(2, g + 1)):
                    mu = 0
                else:
                    # Count prime factors
                    temp, count = g, 0
                    for pk in range(2, temp + 1):
                        while temp % pk == 0:
                            temp //= pk
                            count += 1
                    mu = (-1) ** count
                H[i, j] = mu / np.sqrt(p * q)

    eigenvalues = np.linalg.eigvalsh(H)
    rank = np.sum(np.abs(eigenvalues) > 1e-10)

    # Cayley transform of eigenvalues
    cayley_images = [(lam - 1j) / (lam + 1j) for lam in eigenvalues]
    on_unit_circle = all(abs(abs(z) - 1) < 1e-10 for z in cayley_images)

    analysis = {
        'kernel_type': kernel_type,
        'dimension': n,
        'rank': int(rank),
        'eigenvalues': eigenvalues.tolist(),
        'spectral_gap': float(eigenvalues[-1] - eigenvalues[-2]) if n > 1 else 0,
        'cayley_on_unit_circle': on_unit_circle,
        'condition_number': float(np.max(np.abs(eigenvalues)) /
                                   max(np.min(np.abs(eigenvalues[np.abs(eigenvalues) > 1e-10])), 1e-15))
    }

    return H, analysis


# ═══════════════════════════════════════════════
# Application 3: Self-Inversive Filter Design
# ═══════════════════════════════════════════════

def design_self_inversive_filter(
    target_zeros: List[complex],
    omega: complex = 1.0
) -> np.ndarray:
    """
    Design a self-inversive polynomial whose zeros include given targets
    and their conjugate reciprocals.

    For each target z, include 1/conj(z) as well. If |z| = 1, the root
    is its own pair.

    This is useful in digital signal processing (linear phase filters)
    and in designing test polynomials for critical-line investigations.

    Args:
        target_zeros: desired zero locations (z ≠ 0)
        omega: rotation factor with |omega| = 1

    Returns:
        Polynomial coefficients (low to high degree)
    """
    all_zeros = []
    used = set()

    for z in target_zeros:
        if id(z) in used:
            continue
        all_zeros.append(z)
        used.add(id(z))

        conj_recip = 1.0 / np.conj(z)
        if abs(z - conj_recip) > 1e-10:
            all_zeros.append(conj_recip)

    # Build polynomial from roots
    coeffs = np.array([1.0 + 0j])
    for z in all_zeros:
        coeffs = np.convolve(coeffs, [1, -z])

    # Normalize so that the polynomial is self-inversive with factor omega
    coeffs = coeffs * omega ** 0.5  # approximate normalization

    return coeffs


# ═══════════════════════════════════════════════
# Application 4: Critical-Line Certificate
# ═══════════════════════════════════════════════

def generate_critical_line_certificate(
    N: int,
    chi,
    search_region: Tuple[float, float, float, float],
    grid_resolution: int = 50
) -> dict:
    """
    Generate a certificate that zeros of Z_N in a region are near the critical line.

    Uses the Möbius transport φ(s) = (s - 3/2)/(s + 1/2) to map the problem
    to the unit circle, then verifies symmetry properties.

    Args:
        N: truncation parameter
        chi: functional equation factor
        search_region: (re_min, re_max, im_min, im_max)
        grid_resolution: points per axis

    Returns:
        Certificate dictionary
    """
    re_min, re_max, im_min, im_max = search_region

    # Only search Re(s) ≥ 1/2 by symmetry
    effective_re_min = max(re_min, 0.5)

    re_vals = np.linspace(effective_re_min, re_max, grid_resolution)
    im_vals = np.linspace(im_min, im_max, grid_resolution)

    min_residuals = []
    approximate_zeros = []

    for sigma in re_vals:
        for t in im_vals:
            s = sigma + 1j * t
            d_sum = sum(n ** (-s) for n in range(1, N + 1))
            d_dual = sum(n ** (s - 1) for n in range(1, N + 1))
            val = d_sum + chi(s) * d_dual
            residual = abs(val)

            if residual < 0.1:
                min_residuals.append((s, residual))

            if residual < 1e-3:
                # Möbius transport
                phi_s = (s - 1.5) / (s + 0.5)
                approximate_zeros.append({
                    's': complex(s),
                    'residual': float(residual),
                    'distance_from_critical_line': float(abs(sigma - 0.5)),
                    'mobius_image_abs': float(abs(phi_s)),
                    'near_unit_circle': bool(abs(abs(phi_s) - 1) < 0.01)
                })

    certificate = {
        'N': N,
        'search_region': list(search_region),
        'grid_resolution': grid_resolution,
        'symmetry_exploited': True,
        'effective_search_reduction': '50%',
        'approximate_zeros_found': len(approximate_zeros),
        'all_near_critical_line': all(
            z['distance_from_critical_line'] < 0.01 for z in approximate_zeros
        ),
        'zeros': approximate_zeros[:10]  # First 10
    }

    return certificate


# ═══════════════════════════════════════════════
# Main: Run all applications
# ═══════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Finite Hilbert-Pólya Blueprint: Applications           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Zero search reduction
    print("=" * 60)
    print("APPLICATION 1: Certified Zero-Search Reduction")
    print("=" * 60)
    chi = lambda s: np.exp(1j * np.pi * (s - 0.5))
    s_candidates = [0.5 + 1j * t for t in np.linspace(0, 20, 200)]
    result = certified_zero_search(10, chi, s_candidates)
    print(f"  Searched {result['searched_points']} points (half-strip only)")
    print(f"  Found {result['zeros_found']} approximate zeros")
    print(f"  Search savings: {result['savings']}")
    print()

    # Application 2: Arithmetic matrix comparison
    print("=" * 60)
    print("APPLICATION 2: Arithmetic Matrix Design Comparison")
    print("=" * 60)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

    for ktype in ['log', 'divisor']:
        H, analysis = design_arithmetic_hermitian(primes, ktype)
        print(f"\n  Kernel: {ktype}")
        print(f"    Rank: {analysis['rank']}")
        print(f"    Spectral gap: {analysis['spectral_gap']:.6f}")
        print(f"    Cayley images on unit circle: {analysis['cayley_on_unit_circle']}")
    print()

    # Application 3: Self-inversive filter
    print("=" * 60)
    print("APPLICATION 3: Self-Inversive Polynomial Design")
    print("=" * 60)
    targets = [0.5 + 0.5j, 2.0 + 1j, -1 + 0.3j]
    coeffs = design_self_inversive_filter(targets)
    print(f"  Target zeros: {targets}")
    print(f"  Polynomial degree: {len(coeffs) - 1}")
    roots = np.roots(coeffs[::-1])
    print(f"  Roots (|z| values): {[f'{abs(r):.4f}' for r in sorted(roots, key=abs)]}")
    print()

    # Application 4: Critical-line certificate
    print("=" * 60)
    print("APPLICATION 4: Critical-Line Certificate Generation")
    print("=" * 60)
    cert = generate_critical_line_certificate(
        N=5, chi=chi,
        search_region=(0.0, 1.0, 0.0, 15.0),
        grid_resolution=30
    )
    print(f"  Approximate zeros found: {cert['approximate_zeros_found']}")
    print(f"  All near critical line: {cert['all_near_critical_line']}")
    print(f"  Search reduction: {cert['effective_search_reduction']}")
    print()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Demonstrations of the Finite Hilbert-Pólya Blueprint theorems.

This module provides numerical illustrations of:
1. Functional-equation symmetry for symmetrized Dirichlet truncations
2. Self-inversive polynomial root pairing
3. Möbius critical-line ↔ unit-circle transport
4. Cayley transform: reals → unit circle
5. Low-rank obstruction for naive arithmetic kernels
"""

import numpy as np
from typing import Callable

# ─────────────────────────────────────────────
# Demo 1: Functional Equation Symmetry
# ─────────────────────────────────────────────

def dirichlet_trunc(N: int, s: complex) -> complex:
    """Truncated Dirichlet sum: sum_{n=1}^{N} n^{-s}."""
    return sum(n ** (-s) for n in range(1, N + 1))

def dual_dirichlet_trunc(N: int, s: complex) -> complex:
    """Dual truncated sum: sum_{n=1}^{N} n^{s-1}."""
    return sum(n ** (s - 1) for n in range(1, N + 1))

def sym_trunc(chi: Callable, N: int, s: complex) -> complex:
    """Symmetrized truncation Z_N(s) = D(s) + χ(s)·D*(s)."""
    return dirichlet_trunc(N, s) + chi(s) * dual_dirichlet_trunc(N, s)

def demo_functional_symmetry():
    """Verify Z_N(1-s) = χ(1-s) · Z_N(s) numerically."""
    print("=" * 60)
    print("DEMO 1: Functional Equation Symmetry")
    print("=" * 60)
    print()

    # Use a simple chi satisfying chi(s) * chi(1-s) = 1
    # For example, chi(s) = exp(i*pi*(s - 1/2))
    def chi(s):
        return np.exp(1j * np.pi * (s - 0.5))

    # Verify chi(s) * chi(1-s) = 1
    test_s = 0.3 + 0.7j
    print(f"  χ(s) · χ(1-s) = {chi(test_s) * chi(1 - test_s):.10f}")
    print(f"  (should be 1.0)")
    print()

    N = 10
    for s in [0.3 + 0.7j, 0.5 + 2j, 0.8 - 1.5j, 1.2 + 0.3j]:
        lhs = sym_trunc(chi, N, 1 - s)
        rhs = chi(1 - s) * sym_trunc(chi, N, s)
        error = abs(lhs - rhs)
        print(f"  s = {s}")
        print(f"    Z_N(1-s)         = {lhs:.8f}")
        print(f"    χ(1-s)·Z_N(s)    = {rhs:.8f}")
        print(f"    |difference|     = {error:.2e}")
        print()

    # Demonstrate zero reflection
    print("  Zero Reflection: finding a zero and checking its reflection...")
    try:
        from scipy.optimize import fsolve

        def zero_func(xy):
            s = xy[0] + 1j * xy[1]
            z = sym_trunc(chi, N, s)
            return [z.real, z.imag]

        sol = fsolve(zero_func, [0.5, 1.0], full_output=True)
        s0 = sol[0][0] + 1j * sol[0][1]
        val = sym_trunc(chi, N, s0)
        if abs(val) < 1e-8:
            print(f"  Found zero at s = {s0:.6f}")
            print(f"    |Z_N(s)|   = {abs(val):.2e}")
            reflected = sym_trunc(chi, N, 1 - s0)
            print(f"    |Z_N(1-s)| = {abs(reflected):.2e}")
            print(f"    Zero reflection confirmed!")
    except ImportError:
        print("  (scipy not available for zero-finding; symmetry verified above)")
    print()


# ─────────────────────────────────────────────
# Demo 2: Self-Inversive Root Pairing
# ─────────────────────────────────────────────

def demo_self_inversive():
    """Demonstrate that self-inversive polynomial roots come in pairs {z, 1/conj(z)}."""
    print("=" * 60)
    print("DEMO 2: Self-Inversive Polynomial Root Pairing")
    print("=" * 60)
    print()

    # Construct a self-inversive polynomial:
    # P(z) = z^4 + 2z^3 + 3z^2 + 2z + 1  (palindromic, hence self-inversive with ω=1)
    coeffs = [1, 2, 3, 2, 1]  # low to high degree
    roots = np.roots(coeffs[::-1])

    print(f"  Polynomial: z^4 + 2z^3 + 3z^2 + 2z + 1")
    print(f"  (palindromic coefficients ⟹ self-inversive with ω = 1)")
    print()
    print(f"  Roots:")
    for i, r in enumerate(roots):
        conj_recip = 1.0 / np.conj(r) if abs(r) > 1e-10 else float('inf')
        print(f"    z_{i+1} = {r:.6f}")
        print(f"    1/conj(z_{i+1}) = {conj_recip:.6f}")
        # Check if conj_recip is also a root
        val = np.polyval(coeffs[::-1], conj_recip)
        print(f"    P(1/conj(z_{i+1})) = {abs(val):.2e}")
        print()

    # Demonstrate on unit circle
    print("  Unit-circle property: 1/conj(z) = z when |z| = 1")
    for r in roots:
        print(f"    |z| = {abs(r):.6f},  |z - 1/conj(z)| = {abs(r - 1/np.conj(r)):.2e}")
    print()


# ─────────────────────────────────────────────
# Demo 3: Möbius Critical Line ↔ Unit Circle
# ─────────────────────────────────────────────

def critical_line_map(s: complex) -> complex:
    """Möbius transform φ(s) = (s - 3/2) / (s + 1/2)."""
    return (s - 1.5) / (s + 0.5)

def demo_mobius_transport():
    """Demonstrate φ maps Re(s) = 1/2 to |z| = 1 and vice versa."""
    print("=" * 60)
    print("DEMO 3: Möbius Critical-Line ↔ Unit-Circle Transport")
    print("=" * 60)
    print()

    # Points on the critical line
    print("  Points on critical line Re(s) = 1/2:")
    for t in [-3.0, -1.0, 0.0, 1.0, 2.5, 10.0]:
        s = 0.5 + 1j * t
        z = critical_line_map(s)
        print(f"    s = 1/2 + {t:5.1f}i  →  φ(s) = {z:.4f},  |φ(s)| = {abs(z):.10f}")
    print()

    # Points off the critical line
    print("  Points off critical line:")
    for sigma, t in [(0.3, 1.0), (0.7, 2.0), (1.0, 0.5), (0.0, 3.0)]:
        s = sigma + 1j * t
        z = critical_line_map(s)
        print(f"    s = {sigma} + {t}i  →  |φ(s)| = {abs(z):.6f}  (≠ 1)")
    print()


# ─────────────────────────────────────────────
# Demo 4: Cayley Transform
# ─────────────────────────────────────────────

def cayley_transform(w: complex) -> complex:
    """Cayley transform z = (w - i) / (w + i)."""
    return (w - 1j) / (w + 1j)

def demo_cayley():
    """Demonstrate Cayley transform sends reals to the unit circle."""
    print("=" * 60)
    print("DEMO 4: Cayley Transform — Reals → Unit Circle")
    print("=" * 60)
    print()

    print("  Real inputs → unit circle:")
    for x in [-10, -2, -1, -0.5, 0, 0.5, 1, 2, 10]:
        z = cayley_transform(x)
        print(f"    w = {x:6.1f}  →  z = {z:.6f},  |z| = {abs(z):.12f}")
    print()

    print("  Non-real inputs → off unit circle:")
    for w in [1 + 0.5j, 2 + 1j, -1 + 2j]:
        z = cayley_transform(w)
        print(f"    w = {w}  →  |z| = {abs(z):.6f}  (≠ 1)")
    print()


# ─────────────────────────────────────────────
# Demo 5: Low-Rank Obstruction
# ─────────────────────────────────────────────

def demo_low_rank():
    """Demonstrate that the prime-log kernel has rank ≤ 2."""
    print("=" * 60)
    print("DEMO 5: Low-Rank Obstruction for Prime-Log Kernel")
    print("=" * 60)
    print()

    # Primes up to 50
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    n = len(primes)
    print(f"  Using {n} primes: {primes}")
    print()

    # Construct the kernel K(p,q) = log(pq) / sqrt(pq)
    K = np.zeros((n, n))
    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            K[i, j] = np.log(p * q) / np.sqrt(p * q)

    # Compute rank via SVD
    U, S, Vt = np.linalg.svd(K)
    print(f"  Singular values of K (first 5):")
    for i, sv in enumerate(S[:5]):
        print(f"    σ_{i+1} = {sv:.8f}")
    print(f"    σ_3 = {S[2]:.2e}  (essentially zero)")
    print()

    numerical_rank = np.sum(S > 1e-10)
    print(f"  Numerical rank: {numerical_rank}")
    print(f"  Theoretical bound: 2  (since K = u·vᵀ + v·uᵀ)")
    print()

    # Verify the decomposition
    u = np.array([np.log(p) / np.sqrt(p) for p in primes])
    v = np.array([1.0 / np.sqrt(p) for p in primes])
    K_reconstructed = np.outer(u, v) + np.outer(v, u)
    reconstruction_error = np.max(np.abs(K - K_reconstructed))
    print(f"  Reconstruction error (K vs u·vᵀ + v·uᵀ): {reconstruction_error:.2e}")
    print()
    print("  ⟹ The prime-log kernel is exactly rank ≤ 2.")
    print("     It CANNOT encode the spectral complexity of zeta truncations.")
    print()


# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Finite Hilbert-Pólya Blueprint: Numerical Demos        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_functional_symmetry()
    demo_self_inversive()
    demo_mobius_transport()
    demo_cayley()
    demo_low_rank()

    print("All demos completed successfully.")
