#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Demonstration Script

Demonstrates key concepts:
1. Hyperbolic primes and their bijection with odd rational primes
2. Brahmagupta multiplication in the hyperbolic arithmetic monoid
3. Growth of hyperbolic groups
4. Hyperbolic prime counting and density conjecture verification
5. Poincaré disk conformal factor computation
"""

import math
from typing import List, Tuple, Optional


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def lorentz_norm_sq(a: int, b: int) -> int:
    """Lorentzian norm squared: a² - b²."""
    return a * a - b * b


def is_hyp_prime(a: int, b: int) -> bool:
    """Check if (a, b) is a hyperbolic prime: |a² - b²| is prime."""
    return is_prime(abs(lorentz_norm_sq(a, b)))


def brahmagupta_product(a1: int, b1: int, a2: int, b2: int) -> Tuple[int, int]:
    """Brahmagupta composition: (a1,b1) × (a2,b2) in the hyperbolic arithmetic monoid."""
    return (a1 * a2 + b1 * b2, a1 * b2 + b1 * a2)


def hyp_growth(k: int, r: int) -> int:
    """Growth function of a group with k generators: (2k+1)^r."""
    return (2 * k + 1) ** r


def conformal_factor(z_norm_sq: float) -> float:
    """Conformal factor of the Poincaré metric at a point with |z|² = z_norm_sq."""
    return 2.0 / (1.0 - z_norm_sq)


def hyp_dist_from_origin(z_norm: float) -> float:
    """Hyperbolic distance from the origin to a point with |z| = z_norm."""
    return math.log((1 + z_norm) / (1 - z_norm))


def cons_hyp_prime_count(N: int) -> int:
    """Count n in [1, N] such that 2n+1 is prime."""
    return sum(1 for n in range(1, N + 1) if is_prime(2 * n + 1))


def verify_density_conjecture(N: int) -> bool:
    """Verify the hyperbolic prime density conjecture for a given N ≥ 10."""
    if N < 10:
        return True
    log2_N = math.log2(N)
    lower_bound = N // (3 * int(log2_N) + 1)
    count = cons_hyp_prime_count(N)
    return lower_bound <= count


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_hyperbolic_primes():
    """Demonstrate hyperbolic primes and the consecutive bijection."""
    print("=" * 60)
    print("HYPERBOLIC PRIMES: Consecutive Family (n+1, n)")
    print("=" * 60)
    print(f"{'n':>4} | {'(a, b)':>10} | {'a²-b²':>6} | {'Prime?':>6}")
    print("-" * 40)
    for n in range(1, 25):
        a, b = n + 1, n
        norm = lorentz_norm_sq(a, b)
        prime = is_prime(norm)
        marker = "✓ HYP PRIME" if prime else ""
        print(f"{n:>4} | ({a:>3}, {b:>2}) | {norm:>6} | {marker}")
    print()


def demo_brahmagupta():
    """Demonstrate Brahmagupta multiplication."""
    print("=" * 60)
    print("BRAHMAGUPTA MULTIPLICATION")
    print("=" * 60)
    pairs = [(2, 1), (3, 2), (4, 3), (5, 4)]
    for a1, b1 in pairs:
        for a2, b2 in pairs:
            a3, b3 = brahmagupta_product(a1, b1, a2, b2)
            n1, n2, n3 = lorentz_norm_sq(a1, b1), lorentz_norm_sq(a2, b2), lorentz_norm_sq(a3, b3)
            print(f"  ({a1},{b1}) × ({a2},{b2}) = ({a3},{b3})")
            print(f"    Norms: {n1} × {n2} = {n3}  (check: {n1 * n2 == n3})")
    print()


def demo_growth():
    """Demonstrate exponential growth of hyperbolic groups."""
    print("=" * 60)
    print("EXPONENTIAL GROWTH OF HYPERBOLIC GROUPS")
    print("=" * 60)
    k = 2  # Free group on 2 generators
    print(f"Group with k={k} generators (free group F₂)")
    print(f"{'Radius r':>10} | {'Ball size (2k+1)^r':>20} | {'3^r lower bound':>20}")
    print("-" * 55)
    for r in range(0, 16):
        g = hyp_growth(k, r)
        lb = 3 ** r
        print(f"{r:>10} | {g:>20,} | {lb:>20,}")
    print()


def demo_poincare_disk():
    """Demonstrate Poincaré disk metric properties."""
    print("=" * 60)
    print("POINCARÉ DISK: Conformal Factor and Hyperbolic Distance")
    print("=" * 60)
    print(f"{'|z|':>6} | {'|z|²':>8} | {'λ(z)':>10} | {'d_H(0,z)':>12}")
    print("-" * 45)
    for i in range(0, 10):
        z_norm = i * 0.1
        z_norm_sq = z_norm ** 2
        lam = conformal_factor(z_norm_sq)
        d = hyp_dist_from_origin(z_norm) if z_norm > 0 else 0.0
        print(f"{z_norm:>6.1f} | {z_norm_sq:>8.2f} | {lam:>10.4f} | {d:>12.6f}")
    # Near boundary
    for z_norm in [0.95, 0.99, 0.999, 0.9999]:
        z_norm_sq = z_norm ** 2
        lam = conformal_factor(z_norm_sq)
        d = hyp_dist_from_origin(z_norm)
        print(f"{z_norm:>6.4f} | {z_norm_sq:>8.6f} | {lam:>10.2f} | {d:>12.6f}")
    print()


def demo_density_conjecture():
    """Verify the hyperbolic prime density conjecture computationally."""
    print("=" * 60)
    print("HYPERBOLIC PRIME DENSITY CONJECTURE VERIFICATION")
    print("=" * 60)
    print(f"{'N':>8} | {'Count':>8} | {'Lower bound':>12} | {'Holds?':>8} | {'Density':>8}")
    print("-" * 55)
    for N in [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000]:
        count = cons_hyp_prime_count(N)
        log2_N = int(math.log2(N))
        lower = N // (3 * log2_N + 1)
        holds = lower <= count
        density = count / N
        print(f"{N:>8} | {count:>8} | {lower:>12} | {'✓' if holds else '✗':>8} | {density:>8.4f}")
    print()


def demo_modular_group():
    """Demonstrate modular group matrix computations."""
    print("=" * 60)
    print("MODULAR GROUP: S and T Generators")
    print("=" * 60)
    S = [[0, -1], [1, 0]]
    T = [[1, 1], [0, 1]]

    def mat_mul(A, B):
        return [[A[0][0]*B[0][0]+A[0][1]*B[1][0], A[0][0]*B[0][1]+A[0][1]*B[1][1]],
                [A[1][0]*B[0][0]+A[1][1]*B[1][0], A[1][0]*B[0][1]+A[1][1]*B[1][1]]]

    def mat_pow(A, n):
        result = [[1, 0], [0, 1]]
        for _ in range(n):
            result = mat_mul(result, A)
        return result

    print(f"S = {S}")
    print(f"T = {T}")
    S2 = mat_mul(S, S)
    print(f"S² = {S2}  (should be -I)")
    ST = mat_mul(S, T)
    ST3 = mat_pow(ST, 3)
    print(f"(ST)³ = {ST3}  (should be -I)")

    for n in range(1, 8):
        Tn = mat_pow(T, n)
        print(f"T^{n} = {Tn}")
    print()


if __name__ == "__main__":
    demo_hyperbolic_primes()
    demo_brahmagupta()
    demo_growth()
    demo_poincare_disk()
    demo_density_conjecture()
    demo_modular_group()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Exponential Growth of Hyperbolic Groups

Compares the growth of balls in:
- Euclidean groups (linear: 2r+1)
- Hyperbolic groups with k generators (exponential: (2k+1)^r)
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    radii = list(range(0, 16))

    # Left: Linear scale
    ax1 = axes[0]
    euclidean = [2 * r + 1 for r in radii]
    hyp_k1 = [(2 * 1 + 1) ** r for r in radii]
    hyp_k2 = [(2 * 2 + 1) ** r for r in radii]
    hyp_k3 = [(2 * 3 + 1) ** r for r in radii]

    ax1.semilogy(radii, euclidean, 'k-o', linewidth=2, markersize=6, label='ℤ (Euclidean, 2r+1)')
    ax1.semilogy(radii, hyp_k1, 'b-s', linewidth=2, markersize=5, label='F₁ (k=1, 3^r)')
    ax1.semilogy(radii, hyp_k2, 'r-^', linewidth=2, markersize=5, label='F₂ (k=2, 5^r)')
    ax1.semilogy(radii, hyp_k3, 'g-d', linewidth=2, markersize=5, label='F₃ (k=3, 7^r)')
    ax1.set_xlabel('Radius r', fontsize=12)
    ax1.set_ylabel('Ball size (log scale)', fontsize=12)
    ax1.set_title('Growth: Euclidean vs Hyperbolic Groups', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Cumulative growth and bound
    ax2 = axes[1]
    k = 2
    cumulative = []
    c = 0
    for r in radii:
        c += (2 * k + 1) ** r
        cumulative.append(c)

    upper = [(2 * k + 1) ** (r + 1) for r in radii]

    ax2.semilogy(radii, cumulative, 'b-o', linewidth=2, markersize=6,
                 label='Σ G(2,r) (cumulative)')
    ax2.semilogy(radii, upper, 'r--s', linewidth=2, markersize=5,
                 label='G(2, r+1) (upper bound)')
    ax2.semilogy(radii, [5 ** r for r in radii], 'g:^', linewidth=1.5, markersize=4,
                 label='5^r (ball at radius r)')
    ax2.set_xlabel('Radius R', fontsize=12)
    ax2.set_ylabel('Count (log scale)', fontsize=12)
    ax2.set_title('Cumulative Growth Bound (k=2)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('growth_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved growth_comparison.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk with Hyperbolic Lattice Points

Plots the Poincaré disk with:
- The boundary circle
- Hyperbolic lattice points (orbit of origin under modular group approximation)
- Color-coded by hyperbolic distance from origin
- Conformal factor heatmap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import math


def conformal_factor(x: float, y: float) -> float:
    """Poincaré disk conformal factor at (x, y)."""
    r_sq = x * x + y * y
    if r_sq >= 1.0:
        return float('inf')
    return 2.0 / (1.0 - r_sq)


def hyp_dist(x: float, y: float) -> float:
    """Hyperbolic distance from origin to (x, y)."""
    r = math.sqrt(x * x + y * y)
    if r >= 1.0 or r == 0.0:
        return 0.0
    return math.log((1 + r) / (1 - r))


def mobius_transform(a: float, b: float, c: float, d: float,
                     zr: float, zi: float):
    """Apply Möbius transformation (az+b)/(cz+d) to z = zr + i*zi."""
    # Numerator: (a*zr + b) + i*(a*zi), denominator: (c*zr + d) + i*(c*zi)
    nr = a * zr + b
    ni = a * zi
    dr = c * zr + d
    di = c * zi
    denom = dr * dr + di * di
    if denom < 1e-15:
        return None
    wr = (nr * dr + ni * di) / denom
    wi = (ni * dr - nr * di) / denom
    return wr, wi


def generate_lattice_points(depth: int = 6):
    """Generate orbit points of origin under PSL(2,Z)-like transformations."""
    # Map upper half-plane to disk: z -> (z - i)/(z + i)
    # We'll directly generate points in the disk using Möbius transforms
    points = [(0.0, 0.0)]
    seen = set()
    seen.add((0, 0))

    # Use translations and inversions in the disk model
    # T: z -> z+1 in upper half plane, maps to a rotation-like transform in disk
    # S: z -> -1/z maps to another transform

    # Simpler: generate points as tanh(n * step) along various directions
    for n in range(1, depth + 1):
        r = math.tanh(n * 0.3)  # Evenly spaced in hyperbolic metric
        for k in range(max(1, 6 * n)):
            theta = 2 * math.pi * k / max(1, 6 * n)
            x = r * math.cos(theta)
            y = r * math.sin(theta)
            key = (round(x, 4), round(y, 4))
            if key not in seen:
                seen.add(key)
                points.append((x, y))

    return points


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Conformal factor heatmap
    ax1 = axes[0]
    N = 200
    x = np.linspace(-0.99, 0.99, N)
    y = np.linspace(-0.99, 0.99, N)
    X, Y = np.meshgrid(x, y)
    Z = np.zeros_like(X)
    for i in range(N):
        for j in range(N):
            r_sq = X[i, j] ** 2 + Y[i, j] ** 2
            if r_sq < 1.0:
                Z[i, j] = 2.0 / (1.0 - r_sq)
            else:
                Z[i, j] = np.nan

    im = ax1.pcolormesh(X, Y, Z, cmap='hot', vmin=2, vmax=20, shading='auto')
    circle = Circle((0, 0), 1, fill=False, color='white', linewidth=2)
    ax1.add_patch(circle)
    ax1.set_xlim(-1.1, 1.1)
    ax1.set_ylim(-1.1, 1.1)
    ax1.set_aspect('equal')
    ax1.set_title('Poincaré Disk: Conformal Factor λ(z) = 2/(1-|z|²)', fontsize=12)
    ax1.set_xlabel('Re(z)')
    ax1.set_ylabel('Im(z)')
    plt.colorbar(im, ax=ax1, label='λ(z)')

    # Right: Hyperbolic lattice points
    ax2 = axes[1]
    points = generate_lattice_points(8)

    # Color by hyperbolic distance
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    dists = [hyp_dist(p[0], p[1]) for p in points]

    circle2 = Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax2.add_patch(circle2)

    scatter = ax2.scatter(xs, ys, c=dists, cmap='viridis', s=15, zorder=5)
    ax2.scatter([0], [0], c='red', s=100, marker='*', zorder=10, label='Origin')

    ax2.set_xlim(-1.1, 1.1)
    ax2.set_ylim(-1.1, 1.1)
    ax2.set_aspect('equal')
    ax2.set_title('Hyperbolic Lattice Points\n(colored by hyperbolic distance)', fontsize=12)
    ax2.set_xlabel('Re(z)')
    ax2.set_ylabel('Im(z)')
    ax2.legend(loc='upper right')
    plt.colorbar(scatter, ax=ax2, label='d_H(0, z)')

    plt.tight_layout()
    plt.savefig('poincare_disk.png', dpi=150, bbox_inches='tight')
    print("Saved poincare_disk.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hyperbolic Prime Distribution

Plots:
1. Hyperbolic prime counting function vs PNT prediction
2. Density of hyperbolic primes with conjecture bound
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def cons_hyp_prime_count(N: int) -> int:
    return sum(1 for n in range(1, N + 1) if is_prime(2 * n + 1))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Data
    Ns = list(range(10, 5001, 10))
    counts = []
    c = 0
    idx = 0
    for n in range(1, 5001):
        if is_prime(2 * n + 1):
            c += 1
        if n == Ns[idx]:
            counts.append(c)
            idx += 1
            if idx >= len(Ns):
                break

    # PNT prediction: π(2N+1)/2 ≈ N / (2 ln(2N+1)) ≈ N / (2 ln N) for large N
    pnt_pred = [N / (2 * math.log(max(N, 2))) for N in Ns]

    # Conjecture lower bound: N / (3 * log2(N) + 1)
    conj_bound = [N // (3 * int(math.log2(max(N, 2))) + 1) for N in Ns]

    # Left: Counting function
    ax1 = axes[0]
    ax1.plot(Ns, counts, 'b-', linewidth=1.5, label='π_H(N) (actual)')
    ax1.plot(Ns, pnt_pred, 'r--', linewidth=1.5, label='N/(2 ln N) (PNT prediction)')
    ax1.plot(Ns, conj_bound, 'g:', linewidth=1.5, label='N/(3 log₂N + 1) (conjecture bound)')
    ax1.set_xlabel('N', fontsize=12)
    ax1.set_ylabel('Count of hyperbolic primes', fontsize=12)
    ax1.set_title('Hyperbolic Prime Counting Function', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Density ratio
    ax2 = axes[1]
    density_ratio = [counts[i] / pnt_pred[i] if pnt_pred[i] > 0 else 0 for i in range(len(Ns))]
    ax2.plot(Ns, density_ratio, 'b-', linewidth=1.0, alpha=0.7)
    ax2.axhline(y=1.0, color='r', linestyle='--', linewidth=1.5, label='PNT prediction ratio = 1')
    ax2.set_xlabel('N', fontsize=12)
    ax2.set_ylabel('π_H(N) / (N/(2 ln N))', fontsize=12)
    ax2.set_title('Ratio: Actual / PNT Prediction', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0.5, 1.5)

    plt.tight_layout()
    plt.savefig('hyperbolic_primes.png', dpi=150, bbox_inches='tight')
    print("Saved hyperbolic_primes.png")


if __name__ == "__main__":
    main()
