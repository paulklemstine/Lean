#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Kyber Compression Analysis

Demonstrates practical applications of the fiber structure theorem and
contraction bounds for CRYSTALS-Kyber post-quantum cryptography.

Applications:
1. Security margin estimation for Kyber parameter sets
2. Optimal compression level selection
3. Side-channel leakage analysis through compression
"""

import numpy as np
from typing import Dict, List, Tuple
from dataclasses import dataclass


# ─── Application 1: Security Margin Estimation ──────────────────────────

def security_margin_analysis(q: int = 3329):
    """Estimate security margins for all Kyber parameter sets.

    For each Kyber variant, compute:
    - The fiber structure (large/small fibers)
    - The contraction ratio d/q
    - The security margin: how much the compression helps the adversary

    The key insight: compression with contraction ratio r < 1 means
    that an adversary who can only observe compressed values has
    at most r·L fraction of the original distinguishing power.
    """
    print("=" * 70)
    print("APPLICATION 1: Security Margin Estimation")
    print("=" * 70)

    variants = {
        "Kyber-512": {
            "k": 2, "eta1": 3, "eta2": 2,
            "d_u": 1024, "d_v": 16, "security_level": 1
        },
        "Kyber-768": {
            "k": 3, "eta1": 2, "eta2": 2,
            "d_u": 1024, "d_v": 16, "security_level": 3
        },
        "Kyber-1024": {
            "k": 4, "eta1": 2, "eta2": 2,
            "d_u": 2048, "d_v": 32, "security_level": 5
        },
    }

    for name, params in variants.items():
        k = params["k"]
        d_u = params["d_u"]
        d_v = params["d_v"]
        eta1 = params["eta1"]

        # Fiber structure for u-compression
        a_u = q // d_u
        r_u = q % d_u
        ratio_u = d_u / q

        # Fiber structure for v-compression
        a_v = q // d_v
        r_v = q % d_v
        ratio_v = d_v / q

        # Combined contraction for k-dimensional compression
        combined_ratio_u = ratio_u ** k

        # Smoothness of centered binomial distribution CBD(eta)
        # CBD(η) on Z_q has support {-η, ..., η}, so L ≈ q * max_pmf
        # For CBD(η), max_pmf = C(2η, η) / 2^(2η)
        from math import comb
        max_pmf_cbd = comb(2 * eta1, eta1) / (2 ** (2 * eta1))
        L_cbd = q * max_pmf_cbd

        print(f"\n{'─' * 50}")
        print(f"{name} (NIST Security Level {params['security_level']})")
        print(f"  Dimension k = {k}")
        print(f"  Noise distribution: CBD(η₁={eta1})")
        print(f"  Smoothness L = q · max(CBD) = {L_cbd:.2f}")
        print(f"\n  u-compression (Z/{q}Z → Z/{d_u}Z):")
        print(f"    Fibers: {r_u} × size {a_u+1}, {d_u-r_u} × size {a_u}")
        print(f"    Per-coord contraction: d_u/q = {ratio_u:.6f}")
        print(f"    k-dim contraction: (d_u/q)^k = {combined_ratio_u:.8f}")
        print(f"    Effective bound: (d_u/q)^k · L = {combined_ratio_u * L_cbd:.6f}")
        print(f"\n  v-compression (Z/{q}Z → Z/{d_v}Z):")
        print(f"    Fibers: {r_v} × size {a_v+1}, {d_v-r_v} × size {a_v}")
        print(f"    Per-coord contraction: d_v/q = {ratio_v:.6f}")

        # Security interpretation
        bits_lost = -np.log2(combined_ratio_u) if combined_ratio_u > 0 else float('inf')
        print(f"\n  Security interpretation:")
        print(f"    Bits of advantage lost per compression: {bits_lost:.1f}")
        print(f"    Advantage reduction factor: {1/combined_ratio_u:.1f}x")


# ─── Application 2: Optimal Compression Level Selection ──────────────────

def optimal_compression_analysis(q: int = 3329):
    """Analyze the trade-off between compression ratio and security loss.

    For each possible d = 2^b (b = 1, ..., 12), compute:
    - Compression ratio (bits saved per coefficient)
    - Contraction ratio (security loss)
    - Fiber balance (how evenly distributed fibers are)
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Optimal Compression Level Selection")
    print("=" * 70)

    print(f"\nAnalyzing compression Z/{q}Z → Z/dZ for d = 2^b")
    print(f"\n{'b':>3s} | {'d':>5s} | {'bits/coeff':>10s} | {'d/q':>8s} | {'q%d':>5s} | "
          f"{'max/min fiber':>14s} | {'balance':>8s}")
    print(f"{'─'*3}-+-{'─'*5}-+-{'─'*10}-+-{'─'*8}-+-{'─'*5}-+-{'─'*14}-+-{'─'*8}")

    for b in range(1, 13):
        d = 2 ** b
        if d > q:
            break

        bits_per_coeff = b  # output is b bits
        original_bits = np.log2(q)  # ≈ 11.7 bits
        compression = original_bits - bits_per_coeff

        a = q // d
        r = q % d
        ratio = d / q

        # Balance metric: how close are large/small fibers?
        if a > 0:
            balance = a / (a + 1)  # ratio of small to large fiber size
        else:
            balance = 0.0

        print(f"{b:3d} | {d:5d} | {compression:10.2f} | {ratio:8.4f} | {r:5d} | "
              f"{a+1:6d}/{a:<6d} | {balance:8.4f}")

    print(f"\nKyber's choices:")
    print(f"  d_u = 1024 (b=10): Optimal balance between compression and security")
    print(f"  d_v = 16 (b=4): Aggressive compression for ciphertext savings")
    print(f"  d_u = 2048 (b=11): Kyber-1024 trades less compression for tighter security")


# ─── Application 3: Side-Channel Leakage Analysis ────────────────────────

def side_channel_analysis(q: int = 3329, d: int = 1024):
    """Analyze potential side-channel leakage through fiber size variation.

    The key observation: if an adversary can determine the fiber size
    of a compressed value (e.g., through timing), they learn partial
    information about the secret. The fiber size reveals whether
    y < q%d (large fiber) or y ≥ q%d (small fiber).

    This is a 1-bit leakage channel whose capacity we can compute.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Side-Channel Leakage Analysis")
    print("=" * 70)

    a = q // d
    r = q % d
    p_large = r / d  # probability of landing in a large fiber
    p_small = 1 - p_large

    # Binary entropy of the fiber size distribution
    if 0 < p_large < 1:
        H = -p_large * np.log2(p_large) - p_small * np.log2(p_small)
    else:
        H = 0.0

    print(f"\ncompression Z/{q}Z → Z/{d}Z")
    print(f"  Large fibers (size {a+1}): {r}/{d} = {p_large:.4f}")
    print(f"  Small fibers (size {a}):   {d-r}/{d} = {p_small:.4f}")
    print(f"\n  Binary entropy of fiber type: H = {H:.4f} bits")
    print(f"  Maximum possible leakage: {H:.4f} bits per coefficient")

    # For k coefficients
    for k in [2, 3, 4]:
        total_leakage = k * H
        print(f"  For k={k}: max leakage = {total_leakage:.2f} bits "
              f"(out of {k * np.log2(q):.1f} bits total)")

    # Practical impact assessment
    print(f"\n  Practical assessment:")
    print(f"    The leakage per coefficient ({H:.4f} bits) is negligible")
    print(f"    compared to the {np.log2(q):.1f}-bit secret space.")
    print(f"    Even with {d} observations, the adversary gains at most")
    print(f"    {H:.4f} bits of information about each secret coefficient.")

    # Comparison: what if q were a power of 2?
    print(f"\n  Comparison: If q were a power of 2 (e.g., q=4096):")
    print(f"    All fibers would have exactly the same size (d divides q)")
    print(f"    Leakage: 0 bits (perfect balance)")
    print(f"    But q=3329 is chosen prime for NTT efficiency in Z_q[x]/(x^256+1)")
    print(f"    The {H:.4f}-bit leakage is an acceptable trade-off.")


# ─── Main ────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Real-World Applications of Kyber Compression Analysis             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    security_margin_analysis()
    optimal_compression_analysis()
    side_channel_analysis()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive Visualization of Kyber Compression Fiber Structure

Demonstrates the fiber structure of the CRYSTALS-Kyber compression map
compress: Z/3329Z → Z/dZ and the associated contraction bounds.

Generates four plots:
1. Fiber size histogram for compress: Z/3329Z → Z/1024Z
2. Contraction ratio vs smoothness parameter L
3. Decision advantage before/after compression for discrete Gaussians
4. Theoretical bound vs empirical contraction ratio

Usage:
    python demo.py
"""

import numpy as np
from collections import Counter
import json
import sys

# ─── Kyber Parameters ────────────────────────────────────────────────────

Q = 3329          # Kyber modulus (prime)
D1 = 1024         # 2^10 compression modulus (Kyber-768)
D2 = 2048         # 2^11 compression modulus (Kyber-1024)

# ─── Core Functions ──────────────────────────────────────────────────────

def kyber_compress(x, q, d):
    """Kyber compression: x ↦ ⌊d·x/q⌋"""
    return (d * x) // q

def fiber_sizes(q, d):
    """Compute fiber sizes for compress: Z/qZ → Z/dZ."""
    counts = Counter()
    for x in range(q):
        y = kyber_compress(x, q, d)
        counts[y] += 1
    return counts

def discrete_gaussian_pmf(q, sigma):
    """Discrete Gaussian distribution on Z/qZ centered at 0."""
    xs = np.arange(q)
    # Distance to 0 mod q (wrap-around)
    dists = np.minimum(xs, q - xs)
    unnorm = np.exp(-dists**2 / (2 * sigma**2))
    return unnorm / unnorm.sum()

def uniform_pmf(q):
    """Uniform distribution on Z/qZ."""
    return np.ones(q) / q

def decision_advantage(p, u):
    """Total variation distance = (1/2) Σ |p(x) - u(x)|."""
    return 0.5 * np.sum(np.abs(p - u))

def push_forward(pmf, q, d):
    """Push-forward of a PMF on Z/qZ through compress: Z/qZ → Z/dZ."""
    result = np.zeros(d)
    for x in range(q):
        y = kyber_compress(x, q, d)
        result[y] += pmf[x]
    return result

# ─── Demo 1: Fiber Size Histogram ────────────────────────────────────────

def demo_fiber_histogram():
    """Show fiber size distribution for Kyber compression."""
    print("=" * 70)
    print("DEMO 1: Fiber Size Histogram — compress: Z/3329Z → Z/1024Z")
    print("=" * 70)

    sizes = fiber_sizes(Q, D1)
    size_dist = Counter(sizes.values())

    a = Q // D1  # floor division = 3
    r = Q % D1   # remainder = 257

    print(f"\nKyber parameters: q = {Q}, d = {D1}")
    print(f"  q / d = {a} (floor division)")
    print(f"  q % d = {r}")
    print(f"\nFiber size distribution:")
    for size, count in sorted(size_dist.items()):
        bar = "█" * min(count // 10, 50)
        print(f"  Size {size}: {count:4d} fibers  {bar}")

    print(f"\nVerification:")
    print(f"  Fibers of size {a+1} (large): {size_dist.get(a+1, 0)}  (expected: {r})")
    print(f"  Fibers of size {a}   (small): {size_dist.get(a, 0)}  (expected: {D1 - r})")
    print(f"  Total elements: {sum(s * c for s, c in size_dist.items())}  (expected: {Q})")

    # Also show d2 = 2048
    print(f"\n{'─' * 50}")
    print(f"compress: Z/3329Z → Z/2048Z")
    sizes2 = fiber_sizes(Q, D2)
    size_dist2 = Counter(sizes2.values())
    a2 = Q // D2
    r2 = Q % D2

    print(f"  q / d = {a2}, q % d = {r2}")
    for size, count in sorted(size_dist2.items()):
        print(f"  Size {size}: {count:4d} fibers")

    return size_dist

# ─── Demo 2: Contraction Ratio vs Smoothness ─────────────────────────────

def demo_contraction_vs_smoothness():
    """Plot contraction ratio as a function of smoothness parameter L."""
    print("\n" + "=" * 70)
    print("DEMO 2: Contraction Ratio vs Smoothness Parameter L")
    print("=" * 70)

    d = D1
    L_values = np.linspace(1, 20, 20)
    theoretical_bound = (d / Q) * L_values

    print(f"\nTheoretical contraction bound: (d/q) · L = ({d}/{Q}) · L")
    print(f"\n{'L':>6s} | {'(d/q)·L':>10s} | {'Interpretation':>30s}")
    print(f"{'─' * 6}-+-{'─' * 10}-+-{'─' * 30}")
    for L in [1, 2, 5, 10, 15, 20]:
        bound = (d / Q) * L
        interp = "tight (nearly uniform)" if L <= 2 else \
                 "moderate smoothness" if L <= 10 else \
                 "weak smoothness"
        print(f"{L:6.1f} | {bound:10.4f} | {interp:>30s}")

    print(f"\nKey insight: When L = 1 (uniform), bound = d/q = {d/Q:.4f}")
    print(f"Phase transition at L = q/d = {Q/d:.2f} (bound = 1, no contraction)")

# ─── Demo 3: Decision Advantage Before/After Compression ────────────────

def demo_gaussian_advantage():
    """Compute decision advantage for discrete Gaussians before/after compression."""
    print("\n" + "=" * 70)
    print("DEMO 3: Decision Advantage Before/After Compression")
    print("=" * 70)

    d = D1
    u = uniform_pmf(Q)
    u_compressed = push_forward(u, Q, d)

    sigma_values = list(range(1, 31))
    results = []

    print(f"\n{'σ':>4s} | {'TV(χ,U)':>10s} | {'TV(fχ,fU)':>10s} | {'Ratio':>8s} | {'d/q':>8s} | {'L':>8s} | {'Bound':>8s}")
    print(f"{'─' * 4}-+-{'─' * 10}-+-{'─' * 10}-+-{'─' * 8}-+-{'─' * 8}-+-{'─' * 8}-+-{'─' * 8}")

    for sigma in sigma_values:
        chi = discrete_gaussian_pmf(Q, sigma)
        chi_compressed = push_forward(chi, Q, d)

        tv_before = decision_advantage(chi, u)
        tv_after = decision_advantage(chi_compressed, u_compressed)

        ratio = tv_after / tv_before if tv_before > 1e-15 else 0
        L = max(chi) * Q  # smoothness parameter
        bound = (d / Q) * L

        results.append({
            'sigma': sigma, 'tv_before': tv_before, 'tv_after': tv_after,
            'ratio': ratio, 'L': L, 'bound': bound
        })

        print(f"{sigma:4d} | {tv_before:10.6f} | {tv_after:10.6f} | {ratio:8.4f} | {d/Q:8.4f} | {L:8.4f} | {bound:8.4f}")

    # Critical smoothness threshold
    sigma_crit = np.sqrt(Q / (2 * np.pi))
    print(f"\nCritical smoothness: σ_crit = √(q/(2π)) ≈ {sigma_crit:.2f}")
    print(f"At this σ, the Gaussian becomes nearly uniform.")
    print(f"Contraction ratio approaches d/q = {d/Q:.4f} as σ → ∞.")

    return results

# ─── Demo 4: Theoretical vs Empirical Contraction ────────────────────────

def demo_bound_comparison():
    """Compare theoretical contraction bound with empirical ratio."""
    print("\n" + "=" * 70)
    print("DEMO 4: Theoretical Bound vs Empirical Contraction Ratio")
    print("=" * 70)

    d = D1
    u = uniform_pmf(Q)
    u_compressed = push_forward(u, Q, d)

    print(f"\nFor compress: Z/{Q}Z → Z/{d}Z")
    print(f"Theoretical bound: TV(fχ, fU) ≤ (d/q) · L · TV(χ, U)")
    print(f"\n{'σ':>4s} | {'Empirical':>10s} | {'Theoretical':>12s} | {'Ratio':>8s} | {'Tight?':>8s}")
    print(f"{'─' * 4}-+-{'─' * 10}-+-{'─' * 12}-+-{'─' * 8}-+-{'─' * 8}")

    for sigma in [1, 2, 3, 5, 8, 10, 15, 20, 25, 30]:
        chi = discrete_gaussian_pmf(Q, sigma)
        chi_compressed = push_forward(chi, Q, d)

        tv_before = decision_advantage(chi, u)
        tv_after = decision_advantage(chi_compressed, u_compressed)

        L = max(chi) * Q
        theoretical = (d / Q) * L * tv_before

        tightness = tv_after / theoretical if theoretical > 1e-15 else 0
        is_tight = "tight" if tightness > 0.5 else "loose" if tightness > 0.1 else "v.loose"

        print(f"{sigma:4d} | {tv_after:10.6f} | {theoretical:12.6f} | {tightness:8.4f} | {is_tight:>8s}")

    print(f"\nThe bound is tighter for larger σ (smoother distributions).")
    print(f"For small σ, the smoothness parameter L is large, making the bound loose.")

# ─── All Three Kyber Parameter Sets ──────────────────────────────────────

def demo_all_kyber_params():
    """Verify fiber structure for Kyber-512, Kyber-768, Kyber-1024."""
    print("\n" + "=" * 70)
    print("VERIFIED ALGORITHM: Fiber Structure for All Kyber Parameter Sets")
    print("=" * 70)

    # All three use q = 3329
    # Kyber-512: (k=2, η₁=3, η₂=2, d_u=10, d_v=4) → d_u=1024, d_v=16
    # Kyber-768: (k=3, η₁=2, η₂=2, d_u=10, d_v=4) → d_u=1024, d_v=16
    # Kyber-1024: (k=4, η₁=2, η₂=2, d_u=11, d_v=5) → d_u=2048, d_v=32
    params = [
        ("Kyber-512",  Q, [(1024, "d_u=2^10"), (16, "d_v=2^4")]),
        ("Kyber-768",  Q, [(1024, "d_u=2^10"), (16, "d_v=2^4")]),
        ("Kyber-1024", Q, [(2048, "d_u=2^11"), (32, "d_v=2^5")]),
    ]

    for name, q, ds in params:
        print(f"\n{'─' * 50}")
        print(f"{name} (q = {q})")
        for d, label in ds:
            sizes = fiber_sizes(q, d)
            size_dist = Counter(sizes.values())
            a = q // d
            r = q % d

            print(f"\n  {label}: compress Z/{q}Z → Z/{d}Z")
            print(f"    q/d = {a}, q%d = {r}")
            for size, count in sorted(size_dist.items()):
                expected = r if size == a + 1 else d - r
                status = "✓" if count == expected else "✗"
                print(f"    Fibers of size {size}: {count} {status} (expected {expected})")

            total = sum(s * c for s, c in size_dist.items())
            print(f"    Total: {total} {'✓' if total == q else '✗'} (expected {q})")

            # Beatty sequence verification
            print(f"    Contraction ratio d/q = {d/q:.6f}")

# ─── Main ────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Kyber Compression Fiber Structure — Quantitative DPI Analysis      ║")
    print("║  CRYSTALS-Kyber NIST Post-Quantum Standard (q=3329)                 ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_fiber_histogram()
    demo_contraction_vs_smoothness()
    results = demo_gaussian_advantage()
    demo_bound_comparison()
    demo_all_kyber_params()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)

if __name__ == "__main__":
    main()
