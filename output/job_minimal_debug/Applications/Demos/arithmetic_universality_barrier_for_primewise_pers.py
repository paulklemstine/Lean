#!/usr/bin/env python3
"""
Demo: Arithmetic Universality Barrier for Primewise Persistent Encodings

Demonstrates the key results of the barrier theorem through concrete
numerical examples and simulations.
"""

import math
import random
from collections import defaultdict
from typing import List, Tuple, Dict, Optional


def barcode_capacity(k: int, D: int) -> int:
    """
    Upper bound on the number of distinct (k, D)-bounded barcodes.
    Each barcode has at most k intervals with endpoints in {0, ..., D}.
    """
    return (D + 1) ** (2 * k)


def frobenius_poly_count(d: int, R: int) -> int:
    """
    Number of integer polynomials of degree d with coefficients in [-R, R].
    """
    return (2 * R + 1) ** (d + 1)


def barrier_threshold(k: int, D: int) -> int:
    """
    Minimum number of objects guaranteed to produce a collision.
    """
    return barcode_capacity(k, D) + 1


def hasse_bound(p: int) -> int:
    """
    Number of possible Frobenius traces for an elliptic curve at prime p.
    By Hasse's theorem, |a_p| <= 2*sqrt(p), so there are ~4*sqrt(p)+1 values.
    """
    return int(4 * math.sqrt(p)) + 1


def simulate_random_encoding(n_objects: int, capacity: int, seed: int = 42) -> Optional[Tuple[int, int]]:
    """
    Simulate random encoding of n_objects into a space of given capacity.
    Returns the first collision pair found, or None.
    """
    random.seed(seed)
    seen: Dict[int, int] = {}
    for i in range(n_objects):
        code = random.randint(0, capacity - 1)
        if code in seen:
            return (seen[code], i)
        seen[code] = i
    return None


def growth_rate_comparison(k: int, D: int, d: int, max_R: int = 50):
    """
    Compare barcode capacity vs Frobenius polynomial count for varying R.
    """
    cap = barcode_capacity(k, D)
    print(f"\nGrowth Rate Comparison: k={k}, D={D}, d={d}")
    print(f"{'R':>6} | {'Capacity':>15} | {'Frob Count':>15} | {'Barrier?':>10}")
    print("-" * 55)
    
    for R in range(0, max_R + 1, 5):
        frob = frobenius_poly_count(d, R)
        barrier = "YES" if frob > cap else "no"
        print(f"{R:>6} | {cap:>15,} | {frob:>15,} | {barrier:>10}")


def multi_prime_analysis(k: int, D: int, n_primes_range: range):
    """
    Analyze how multi-prime capacity grows with the number of primes.
    """
    per_prime_cap = barcode_capacity(k, D)
    print(f"\nMulti-Prime Capacity Analysis: k={k}, D={D}")
    print(f"Per-prime capacity: {per_prime_cap:,}")
    print(f"{'n_primes':>10} | {'Total Capacity':>25} | {'log2(Capacity)':>15}")
    print("-" * 55)
    
    for n in n_primes_range:
        total_cap = per_prime_cap ** n
        log2_cap = n * math.log2(per_prime_cap) if per_prime_cap > 0 else 0
        if total_cap < 10**20:
            print(f"{n:>10} | {total_cap:>25,} | {log2_cap:>15.1f}")
        else:
            print(f"{n:>10} | {'> 10^20':>25} | {log2_cap:>15.1f}")


def birthday_collision_probability(n: int, capacity: int) -> float:
    """
    Approximate probability of at least one collision among n random encodings
    in a space of given capacity (birthday paradox).
    """
    if n >= capacity:
        return 1.0
    # P(no collision) ≈ exp(-n(n-1)/(2*capacity))
    exponent = -n * (n - 1) / (2 * capacity)
    return 1.0 - math.exp(exponent)


def demo_birthday_paradox(k: int, D: int):
    """
    Show how the birthday paradox accelerates collisions.
    """
    cap = barcode_capacity(k, D)
    sqrt_cap = int(math.sqrt(cap))
    
    print(f"\nBirthday Paradox for (k={k}, D={D})-bounded barcodes")
    print(f"Capacity: {cap:,}")
    print(f"50% collision expected at ~{sqrt_cap:,} objects (sqrt of capacity)")
    print(f"{'n_objects':>12} | {'P(collision)':>15}")
    print("-" * 32)
    
    for frac in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        n = max(1, int(sqrt_cap * frac))
        prob = birthday_collision_probability(n, cap)
        print(f"{n:>12,} | {prob:>15.6f}")


def elliptic_curve_traces_simulation(n_curves: int = 100, max_prime: int = 50):
    """
    Simulate Frobenius traces for random elliptic curves and check
    for barcode collisions at various complexity bounds.
    """
    # Generate random trace vectors (simulating distinct curves)
    primes = [p for p in range(2, max_prime + 1) if all(p % d != 0 for d in range(2, int(math.sqrt(p)) + 1))]
    
    print(f"\nElliptic Curve Trace Simulation")
    print(f"Number of curves: {n_curves}")
    print(f"Primes used: {primes}")
    print(f"Number of primes: {len(primes)}")
    
    random.seed(123)
    trace_vectors = []
    for _ in range(n_curves):
        traces = tuple(random.randint(-int(2*math.sqrt(p)), int(2*math.sqrt(p))) for p in primes)
        trace_vectors.append(traces)
    
    n_distinct = len(set(trace_vectors))
    print(f"Distinct trace vectors: {n_distinct} out of {n_curves}")
    
    # Check if various (k, D) bounds can separate them
    print(f"\n{'(k, D)':>10} | {'Capacity':>15} | {'Can Separate?':>15}")
    print("-" * 45)
    for k, D in [(1, 5), (2, 5), (2, 10), (3, 10), (3, 20), (5, 10)]:
        cap = barcode_capacity(k, D)
        can_sep = "YES" if cap >= n_distinct else "NO"
        print(f"({k}, {D:>2}){' ':>4} | {cap:>15,} | {can_sep:>15}")


def main():
    print("=" * 60)
    print("ARITHMETIC UNIVERSALITY BARRIER")
    print("Primewise Persistent Encoding Obstruction Theorems")
    print("=" * 60)
    
    # Demo 1: Basic capacity bounds
    print("\n--- Demo 1: Barcode Capacity Bounds ---")
    for k in range(1, 6):
        for D in [5, 10, 20]:
            cap = barcode_capacity(k, D)
            thresh = barrier_threshold(k, D)
            print(f"  k={k}, D={D:>2}: capacity = {cap:>15,}, barrier at N = {thresh:>15,}")
    
    # Demo 2: Growth rate comparison
    print("\n--- Demo 2: Frobenius Polynomial Growth ---")
    growth_rate_comparison(k=3, D=10, d=2, max_R=50)
    
    # Demo 3: Multi-prime analysis
    print("\n--- Demo 3: Multi-Prime Capacity ---")
    multi_prime_analysis(k=2, D=5, n_primes_range=range(1, 8))
    
    # Demo 4: Birthday paradox
    print("\n--- Demo 4: Birthday Paradox Acceleration ---")
    demo_birthday_paradox(k=3, D=10)
    
    # Demo 5: Simulation
    print("\n--- Demo 5: Collision Detection Simulation ---")
    for k, D in [(2, 5), (3, 10)]:
        cap = barcode_capacity(k, D)
        n_obj = cap + 1
        collision = simulate_random_encoding(n_obj, cap)
        if collision:
            print(f"  k={k}, D={D}: collision between objects {collision[0]} and {collision[1]} "
                  f"(out of {n_obj:,} objects, capacity {cap:,})")
    
    # Demo 6: Elliptic curve traces
    print("\n--- Demo 6: Elliptic Curve Trace Analysis ---")
    elliptic_curve_traces_simulation()
    
    # Demo 7: Testable prediction
    print("\n--- Demo 7: Testable Prediction ---")
    k, D = 3, 10
    cap = barcode_capacity(k, D)
    print(f"  For (k={k}, D={D}): capacity = {cap:,} = 11^6")
    print(f"  Prediction: Among 1,771,562 elliptic curves, at least two")
    print(f"  must have identical (3,10)-bounded barcodes at any single prime.")
    print(f"  This is a mathematical certainty (proved in Lean).")
    
    k2, D2 = 2, 5
    cap2 = barcode_capacity(k2, D2)
    print(f"\n  Conjecture test bound: (k={k2}, D={D2}): capacity = {cap2:,}")
    print(f"  Conjecture: >1,296 elliptic curves of conductor ≤ 1000 have")
    print(f"  pairwise distinct Frobenius traces at primes ≤ 50.")
    
    print("\n" + "=" * 60)
    print("All demos completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Barcode Capacity vs Frobenius Growth

Shows the arithmetic universality barrier by plotting barcode capacity
against Frobenius polynomial count for varying parameters.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def barcode_capacity(k: int, D: int) -> int:
    return (D + 1) ** (2 * k)


def frobenius_count(d: int, R: int) -> int:
    return (2 * R + 1) ** (d + 1)


def hasse_trace_count(p: int) -> int:
    return int(4 * math.sqrt(p)) + 1


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Arithmetic Universality Barrier for Primewise Persistent Encodings',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: Capacity vs R for fixed (k, D) and varying d
    ax = axes[0, 0]
    R_vals = np.arange(1, 30)
    k, D = 3, 10
    cap = barcode_capacity(k, D)
    ax.axhline(y=cap, color='red', linestyle='--', linewidth=2, label=f'Capacity (k={k}, D={D})')
    for d in [1, 2, 3]:
        frob_vals = [(2*R+1)**(d+1) for R in R_vals]
        ax.plot(R_vals, frob_vals, linewidth=2, label=f'Frob poly count (d={d})')
    ax.set_yscale('log')
    ax.set_xlabel('Coefficient range R')
    ax.set_ylabel('Count (log scale)')
    ax.set_title('Frobenius Polynomial Count vs Barcode Capacity')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Capacity growth with k for fixed D
    ax = axes[0, 1]
    k_vals = range(1, 8)
    for D in [3, 5, 10, 20]:
        caps = [barcode_capacity(k, D) for k in k_vals]
        ax.plot(list(k_vals), caps, 'o-', linewidth=2, label=f'D={D}')
    ax.set_yscale('log')
    ax.set_xlabel('Number of intervals k')
    ax.set_ylabel('Capacity (log scale)')
    ax.set_title('Barcode Capacity Growth with k')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Multi-prime capacity
    ax = axes[1, 0]
    n_vals = range(1, 10)
    for k, D in [(1, 3), (2, 5), (3, 10)]:
        per_prime = barcode_capacity(k, D)
        multi_caps = [per_prime ** n for n in n_vals]
        ax.plot(list(n_vals), multi_caps, 's-', linewidth=2,
                label=f'(k={k},D={D}), C={per_prime:,}')
    ax.set_yscale('log')
    ax.set_xlabel('Number of primes n')
    ax.set_ylabel('Total capacity (log scale)')
    ax.set_title('Multi-Prime Capacity Growth')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Birthday paradox — expected collisions
    ax = axes[1, 1]
    for k, D in [(2, 5), (3, 10), (4, 15)]:
        cap = barcode_capacity(k, D)
        n_objs = np.arange(1, int(3 * math.sqrt(cap)) + 1, max(1, int(math.sqrt(cap) / 50)))
        probs = [1 - math.exp(-n*(n-1)/(2*cap)) if n < cap else 1.0 for n in n_objs]
        ax.plot(n_objs / math.sqrt(cap), probs, linewidth=2,
                label=f'(k={k},D={D}), C={cap:,}')
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('Objects / √Capacity')
    ax.set_ylabel('P(collision)')
    ax.set_title('Birthday Paradox: Collision Probability')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('barrier_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved barrier_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hasse Bound vs Barcode Capacity at Each Prime

Shows how the Frobenius trace range at each prime eventually exceeds
any fixed barcode capacity, demonstrating the barrier.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


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


def get_primes(up_to: int) -> list:
    return [p for p in range(2, up_to + 1) if is_prime(p)]


def hasse_trace_count(p: int) -> int:
    return int(4 * math.sqrt(p)) + 1


def barcode_capacity(k: int, D: int) -> int:
    return (D + 1) ** (2 * k)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Hasse Bound vs Barcode Capacity', fontsize=13, fontweight='bold')
    
    primes = get_primes(500)
    
    # Plot 1: Trace count at each prime vs capacity thresholds
    ax = axes[0]
    trace_counts = [hasse_trace_count(p) for p in primes]
    ax.scatter(primes, trace_counts, s=8, alpha=0.6, color='blue', label='Hasse trace count 4√p+1')
    
    for k, D, color in [(1, 5, 'green'), (2, 3, 'orange'), (2, 5, 'red')]:
        cap = barcode_capacity(k, D)
        if cap < max(trace_counts) * 5:
            ax.axhline(y=cap, color=color, linestyle='--', linewidth=1.5,
                      label=f'Cap(k={k},D={D})={cap}')
    
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Count')
    ax.set_title('Single-Prime Trace Count vs Capacity')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Cumulative multi-prime capacity vs cumulative trace space
    ax = axes[1]
    primes_short = primes[:30]
    
    for k, D in [(1, 3), (2, 5)]:
        cap = barcode_capacity(k, D)
        cum_cap = [cap ** (i + 1) for i in range(len(primes_short))]
        ax.plot(range(1, len(primes_short) + 1), cum_cap, 'o-', markersize=3,
                linewidth=1.5, label=f'Cap^n (k={k},D={D})')
    
    cum_trace = []
    running = 1
    for p in primes_short:
        running *= hasse_trace_count(p)
        cum_trace.append(running)
    ax.plot(range(1, len(primes_short) + 1), cum_trace, 's-', markersize=3,
            linewidth=2, color='blue', label='∏ trace_count(p_i)')
    
    ax.set_yscale('log')
    ax.set_xlabel('Number of primes used')
    ax.set_ylabel('Capacity / Trace space (log)')
    ax.set_title('Cumulative Multi-Prime Analysis')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('hasse_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved hasse_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Refinement Monotonicity and Capacity Landscape

Shows how barcode capacity increases monotonically with refinement
of the (k, D) parameters, and the resulting capacity landscape.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def barcode_capacity(k: int, D: int) -> int:
    return (D + 1) ** (2 * k)


def information_bits(k: int, D: int) -> float:
    if D + 1 <= 0:
        return 0.0
    return 2 * k * math.log2(D + 1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Refinement Monotonicity and Capacity Landscape', fontsize=13, fontweight='bold')
    
    # Plot 1: Heatmap of log2(capacity) over (k, D)
    ax = axes[0]
    k_range = range(1, 9)
    D_range = range(1, 21)
    
    Z = np.zeros((len(list(k_range)), len(list(D_range))))
    for i, k in enumerate(k_range):
        for j, D in enumerate(D_range):
            Z[i, j] = information_bits(k, D)
    
    im = ax.imshow(Z, origin='lower', aspect='auto',
                   extent=[min(D_range)-0.5, max(D_range)+0.5,
                           min(k_range)-0.5, max(k_range)+0.5],
                   cmap='viridis')
    ax.set_xlabel('Max endpoint D')
    ax.set_ylabel('Max intervals k')
    ax.set_title('Information Content (bits) = 2k·log₂(D+1)')
    plt.colorbar(im, ax=ax, label='bits per prime')
    
    # Plot 2: Capacity curves showing monotonicity
    ax = axes[1]
    D_vals = np.arange(1, 25)
    
    for k in [1, 2, 3, 4, 5]:
        caps = [(D+1)**(2*k) for D in D_vals]
        ax.plot(D_vals, caps, linewidth=2, label=f'k={k}')
    
    # Show the refinement arrows
    k1, D1 = 2, 5
    k2, D2 = 3, 10
    cap1 = barcode_capacity(k1, D1)
    cap2 = barcode_capacity(k2, D2)
    ax.annotate(f'({k1},{D1}): {cap1:,}', xy=(D1, cap1), fontsize=8,
                xytext=(D1+2, cap1*2),
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red')
    ax.annotate(f'({k2},{D2}): {cap2:,}', xy=(D2, cap2), fontsize=8,
                xytext=(D2+2, cap2*2),
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red')
    
    ax.set_yscale('log')
    ax.set_xlabel('Max endpoint D')
    ax.set_ylabel('Capacity (log scale)')
    ax.set_title('Capacity Growth: (D+1)^(2k)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('refinement_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved refinement_visualization.png")


if __name__ == "__main__":
    main()
