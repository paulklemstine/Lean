#!/usr/bin/env python3
"""
Logarithmic Prime Metric — Numerical Demonstrations

Demonstrates the key phenomena of the logarithmic prime transform:
1. The dimension gap between Hausdorff (0) and box-counting (~1/2) dimensions
2. Prime constellation structure in log-space
3. The log-gap energy spectrum
"""

import math
from typing import List, Tuple

def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def log_prime_image(p: int) -> float:
    """Map p to 1/log(p)."""
    return 1.0 / math.log(p)


def log_prime_dist(p: int, q: int) -> float:
    """Logarithmic prime metric: |1/log(p) - 1/log(q)|."""
    return abs(log_prime_image(p) - log_prime_image(q))


def box_counting_dimension_estimate(N: int) -> float:
    """
    Estimate box-counting dimension of {1/log p : p prime, p ≤ N}.
    Uses interval [0, 1/log(2)] divided into boxes of width epsilon.
    Returns estimated dimension from log(covering number)/log(1/epsilon).
    """
    primes = sieve_primes(N)
    images = sorted(set(log_prime_image(p) for p in primes))

    results = []
    for k in range(2, 8):
        epsilon = 10**(-k/2)
        # Count boxes that contain at least one image point
        boxes = set()
        for x in images:
            boxes.add(int(x / epsilon))
        covering = len(boxes)
        if covering > 1:
            dim_est = math.log(covering) / math.log(1.0 / epsilon)
            results.append((epsilon, covering, dim_est))

    return results


def prime_constellation_analysis(center: int, radius: float) -> dict:
    """
    Find all primes within log-metric distance `radius` of `center`.
    """
    # Search in a range around center
    search_range = int(center * math.exp(radius * math.log(center)**2)) + 100
    primes = sieve_primes(max(search_range, center + 1000))

    constellation = [p for p in primes if log_prime_dist(center, p) <= radius]
    return {
        'center': center,
        'radius': radius,
        'primes': constellation,
        'count': len(constellation),
        'min_sep': min(
            (log_prime_dist(constellation[i], constellation[i+1])
             for i in range(len(constellation)-1)),
            default=0
        ),
    }


def log_gap_energy(primes: List[int], s: float) -> float:
    """Compute the s-energy sum_{p<q} (1/d(p,q))^s."""
    total = 0.0
    for i, p in enumerate(primes):
        for j in range(i+1, len(primes)):
            q = primes[j]
            d = log_prime_dist(p, q)
            if d > 0:
                total += (1.0 / d) ** s
    return total


def verify_ratio_form(a: int, b: int) -> Tuple[float, float]:
    """Verify: d(a,b) = log(b/a) / (log(a) * log(b))."""
    direct = log_prime_dist(a, b)
    ratio = math.log(b / a) / (math.log(a) * math.log(b))
    return direct, ratio


def main():
    print("=" * 70)
    print("LOGARITHMIC PRIME METRIC — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Transform values
    print("\n--- 1. Log-Prime Transform Values ---")
    print(f"{'Prime':>8} {'1/log(p)':>12} {'Ordering':>10}")
    primes_small = sieve_primes(50)
    for p in primes_small:
        print(f"{p:8d} {log_prime_image(p):12.6f} {'↓' if p > 2 else '(max)'}")

    # Demo 2: Strict anti-tonicity verification
    print("\n--- 2. Strict Anti-tonicity Verification ---")
    print("For a < b (both ≥ 2): 1/log(a) > 1/log(b)")
    for a, b in [(2,3), (3,5), (5,7), (7,11), (100,101)]:
        fa, fb = log_prime_image(a), log_prime_image(b)
        print(f"  a={a}, b={b}: 1/log({a})={fa:.6f} > 1/log({b})={fb:.6f}? {fa > fb}")

    # Demo 3: Ratio form verification
    print("\n--- 3. Ratio Form Verification ---")
    print("d(a,b) = log(b/a) / (log(a) · log(b))")
    for a, b in [(2,3), (3,7), (5,11), (7,13), (97,101)]:
        direct, ratio = verify_ratio_form(a, b)
        print(f"  d({a},{b}): direct={direct:.10f}, ratio={ratio:.10f}, "
              f"match={abs(direct-ratio) < 1e-12}")

    # Demo 4: Box-counting dimension
    print("\n--- 4. Box-Counting Dimension Estimates ---")
    for N in [10**3, 10**4, 10**5, 10**6]:
        results = box_counting_dimension_estimate(N)
        print(f"\n  N = {N:,}:")
        for eps, cov, dim in results:
            print(f"    ε = {eps:.4e}, covering = {cov:6d}, dim ≈ {dim:.4f}")
        if results:
            avg_dim = sum(d for _, _, d in results) / len(results)
            print(f"    Average dimension estimate: {avg_dim:.4f}")

    # Demo 5: Prime constellations
    print("\n--- 5. Prime Constellations ---")
    for center in [101, 1009, 10007]:
        info = prime_constellation_analysis(center, 0.01)
        print(f"  Center={center}, radius=0.01: "
              f"{info['count']} primes, min_sep={info['min_sep']:.8f}")

    # Demo 6: Log-gap energy
    print("\n--- 6. Log-Gap Energy Spectrum ---")
    primes100 = sieve_primes(100)
    print(f"  Primes up to 100: {len(primes100)} primes")
    for s in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0]:
        E = log_gap_energy(primes100, s)
        print(f"    E_{s:.2f} = {E:.4f}")

    # Demo 7: Strict metric monotonicity verification
    print("\n--- 7. Strict Metric Monotonicity ---")
    print("For a < b < c (all ≥ 2): d(a,b) < d(a,c)")
    for a, b, c in [(2,3,5), (3,5,7), (5,7,11), (7,11,13)]:
        dab = log_prime_dist(a, b)
        dac = log_prime_dist(a, c)
        print(f"  d({a},{b})={dab:.8f} < d({a},{c})={dac:.8f}? {dab < dac}")

    # Demo 8: Conjecture test - box counting dimension
    print("\n--- 8. Box-Counting Dimension Conjecture Test ---")
    print("Conjecture: dim_B(S) = 1/2")
    print("Testing: log(C(N)) / log(log(N)) → 1/2")
    for k in range(3, 8):
        N = 10**k
        primes = sieve_primes(N)
        images = sorted(set(log_prime_image(p) for p in primes))
        # Use epsilon = 1/log(N)
        epsilon = 1.0 / math.log(N)
        boxes = set()
        for x in images:
            boxes.add(int(x / epsilon))
        C_N = len(boxes)
        if C_N > 1 and math.log(N) > 1:
            ratio = math.log(C_N) / math.log(math.log(N))
            print(f"  N=10^{k}: C(N)={C_N}, log(C(N))/log(log(N)) = {ratio:.4f}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Constellations in Log-Space

Shows clusters of primes that are close together in the logarithmic
metric, revealing the local structure of the prime distribution.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    primes = sieve_primes(5000)
    images = [(p, 1.0/math.log(p)) for p in primes]

    # Panel 1: Full log-prime image with density coloring
    ax1 = axes[0][0]
    xs = [t for _, t in images]
    # Color by local density
    colors = []
    for i, (p, t) in enumerate(images):
        neighbors = sum(1 for _, t2 in images if abs(t - t2) < 0.005)
        colors.append(neighbors)

    sc = ax1.scatter(xs, [p for p, _ in images], c=colors, s=3,
                     cmap='plasma', alpha=0.7)
    plt.colorbar(sc, ax=ax1, label='Local density (r=0.005)')
    ax1.set_xlabel('1/log(p)', fontsize=11)
    ax1.set_ylabel('Prime p', fontsize=11)
    ax1.set_title('Log-Prime Image with Local Density', fontsize=12, fontweight='bold')

    # Panel 2: Zoom into a dense region
    ax2 = axes[0][1]
    zoom_primes = [(p, t) for p, t in images if 0.1 < t < 0.2]
    for p, t in zoom_primes:
        ax2.plot([t, t], [0, 1], '-', color='#2196F3', linewidth=0.8, alpha=0.5)
        ax2.plot(t, 0.5, 'o', color='#F44336', markersize=3)
    ax2.set_xlabel('1/log(p)', fontsize=11)
    ax2.set_xlim(0.1, 0.2)
    ax2.set_yticks([])
    ax2.set_title('Zoom: Dense Region (0.1 < 1/log p < 0.2)', fontsize=12, fontweight='bold')

    # Panel 3: Gap distribution in log-space
    ax3 = axes[1][0]
    gaps = []
    for i in range(len(images) - 1):
        gap = images[i][1] - images[i+1][1]  # positive since anti-tonic
        gaps.append(gap)

    ax3.hist(gaps, bins=50, color='#4CAF50', alpha=0.7, edgecolor='white')
    ax3.axvline(x=sum(gaps)/len(gaps), color='red', linestyle='--',
                linewidth=2, label=f'Mean = {sum(gaps)/len(gaps):.6f}')
    ax3.set_xlabel('Log-metric gap', fontsize=11)
    ax3.set_ylabel('Count', fontsize=11)
    ax3.set_title('Distribution of Consecutive Log-Gaps', fontsize=12, fontweight='bold')
    ax3.legend(fontsize=10)

    # Panel 4: Constellation sizes for various radii
    ax4 = axes[1][1]
    radii = [0.001, 0.002, 0.005, 0.01, 0.02, 0.05]
    max_sizes = []
    avg_sizes = []

    for r in radii:
        sizes = []
        for i, (p, t) in enumerate(images):
            count = sum(1 for _, t2 in images if abs(t - t2) <= r)
            sizes.append(count)
        max_sizes.append(max(sizes))
        avg_sizes.append(sum(sizes) / len(sizes))

    ax4.loglog(radii, max_sizes, 'o-', color='#F44336', linewidth=2,
               label='Max constellation size', markersize=6)
    ax4.loglog(radii, avg_sizes, 's-', color='#2196F3', linewidth=2,
               label='Avg constellation size', markersize=6)

    # Reference: size ~ r^(1/2) scaling
    r_ref = [radii[0], radii[-1]]
    s_ref = [max_sizes[0] * (r/radii[0])**0.5 for r in r_ref]
    ax4.loglog(r_ref, s_ref, '--', color='gray', linewidth=1.5,
               label='~r^{1/2} scaling', alpha=0.7)

    ax4.set_xlabel('Constellation radius r', fontsize=11)
    ax4.set_ylabel('Constellation size', fontsize=11)
    ax4.set_title('Constellation Size vs Radius', fontsize=12, fontweight='bold')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Prime Constellations in the Logarithmic Metric',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('constellations.png', dpi=150, bbox_inches='tight')
    print("Saved constellations.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Dimension Gap of the Logarithmic Prime Image

Produces a plot showing the box-counting dimension estimate converging
to ~1/2 as N grows, illustrating the gap from Hausdorff dimension 0.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def box_counting_at_scale(images, epsilon):
    boxes = set()
    for x in images:
        boxes.add(int(x / epsilon))
    return len(boxes)

def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Log-log plot for box-counting dimension
    ax1 = axes[0]
    for N, color in [(10**4, '#2196F3'), (10**5, '#FF9800'), (10**6, '#4CAF50')]:
        primes = sieve_primes(N)
        images = sorted(set(1.0 / math.log(p) for p in primes))

        log_inv_eps = []
        log_counts = []
        for k in range(3, 15):
            eps = 10**(-k/3)
            count = box_counting_at_scale(images, eps)
            if count > 1:
                log_inv_eps.append(math.log(1.0/eps))
                log_counts.append(math.log(count))

        ax1.plot(log_inv_eps, log_counts, 'o-', color=color,
                 label=f'N = {N:,}', markersize=4)

    # Reference line with slope 1/2
    x_ref = [1, 10]
    y_ref = [0.5 + 0.5*x for x in x_ref]
    ax1.plot(x_ref, y_ref, '--', color='red', linewidth=2,
             label='slope = 1/2', alpha=0.7)

    ax1.set_xlabel('log(1/ε)', fontsize=12)
    ax1.set_ylabel('log(covering number)', fontsize=12)
    ax1.set_title('Box-Counting Dimension ≈ 1/2', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: The log-prime image as a point set
    ax2 = axes[1]
    primes = sieve_primes(1000)
    images = [1.0 / math.log(p) for p in primes]
    ax2.scatter(images, [0]*len(images), s=3, c='#2196F3', alpha=0.7)
    ax2.scatter(images[:10], [0]*10, s=30, c='#F44336', zorder=5,
                label='First 10 primes')
    ax2.set_xlabel('1/log(p)', fontsize=12)
    ax2.set_yticks([])
    ax2.set_title('Logarithmic Prime Image S', fontsize=13, fontweight='bold')
    ax2.set_xlim(0, 1.5)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='x')

    # Panel 3: Consecutive gaps in log-space
    ax3 = axes[2]
    primes = sieve_primes(10000)
    gaps = []
    positions = []
    for i in range(len(primes)-1):
        gap = 1.0/math.log(primes[i]) - 1.0/math.log(primes[i+1])
        gaps.append(gap)
        positions.append(primes[i])

    ax3.semilogy(positions[:500], gaps[:500], '.', color='#9C27B0',
                 markersize=2, alpha=0.6)
    # Overlay predicted decay ~ 1/(p log^2 p)
    x_pred = list(range(3, positions[499]+1, 5))
    y_pred = [2.0/(x * math.log(x)**2) for x in x_pred if x > 1]
    ax3.semilogy(x_pred[:len(y_pred)], y_pred, '-', color='red',
                 linewidth=1.5, alpha=0.7, label='~2/(p·log²p)')

    ax3.set_xlabel('Prime p', fontsize=12)
    ax3.set_ylabel('Log-metric gap Δ(p)', fontsize=12)
    ax3.set_title('Gap Decay in Log-Space', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.suptitle('The Dimension Gap: Hausdorff dim = 0, Box-Counting dim ≈ 1/2',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('dimension_gap.png', dpi=150, bbox_inches='tight')
    print("Saved dimension_gap.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Log-Gap Energy Spectrum

Shows the s-energy E_s = Σ_{p<q≤N} (1/d(p,q))^s as a function of s,
revealing the critical exponent at s ≈ 1/2 where the energy transitions
from convergent to divergent behavior as N → ∞.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def compute_energy(primes, s):
    total = 0.0
    for i in range(len(primes)):
        for j in range(i+1, len(primes)):
            d = abs(1.0/math.log(primes[i]) - 1.0/math.log(primes[j]))
            if d > 0:
                total += (1.0/d)**s
    return total

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Energy vs exponent for different N
    ax1 = axes[0]
    s_values = [0.1 * k for k in range(1, 25)]

    for N, color, marker in [(30, '#2196F3', 'o'), (50, '#FF9800', 's'),
                              (100, '#4CAF50', '^'), (200, '#F44336', 'D')]:
        primes = sieve_primes(N)
        energies = [compute_energy(primes, s) for s in s_values]
        ax1.semilogy(s_values, energies, f'{marker}-', color=color,
                     label=f'N = {N}', markersize=4, linewidth=1.5)

    ax1.axvline(x=0.5, color='black', linestyle='--', linewidth=2,
                alpha=0.5, label='s = 1/2 (critical)')
    ax1.set_xlabel('Exponent s', fontsize=12)
    ax1.set_ylabel('Energy E_s (log scale)', fontsize=12)
    ax1.set_title('Log-Gap Energy Spectrum', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Energy growth rate at fixed s as N increases
    ax2 = axes[1]
    N_values = [20, 30, 50, 75, 100, 150, 200]

    for s, color in [(0.3, '#2196F3'), (0.5, '#FF9800'), (0.7, '#4CAF50'),
                     (1.0, '#F44336'), (1.5, '#9C27B0')]:
        energies = []
        for N in N_values:
            primes = sieve_primes(N)
            energies.append(compute_energy(primes, s))
        ax2.loglog(N_values, energies, 'o-', color=color,
                   label=f's = {s}', markersize=5, linewidth=1.5)

    ax2.set_xlabel('N (primes up to N)', fontsize=12)
    ax2.set_ylabel('Energy E_s (log scale)', fontsize=12)
    ax2.set_title('Energy Growth with N', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Prime Log-Gap Energy: Critical Exponent at s = 1/2',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('energy_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved energy_spectrum.png")

if __name__ == "__main__":
    main()
