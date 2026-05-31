#!/usr/bin/env python3
"""
Collatz Undecidability — Demonstration Script

Numerical examples illustrating the key concepts from the Collatz
undecidability research: orbit complexity, stopping time growth,
tropical distance, and the bounded verification hierarchy.
"""

from algorithms import (
    collatz_orbit, stopping_time, peak_value, compute_orbit_complexity,
    accel_step, syracuse_orbit, tropical_orbit_distance,
    max_stopping_time, stopping_time_growth_test, verify_collatz_up_to,
    parity_sequence
)
import math


def demo_orbit_complexity():
    """Demonstrate orbit complexity measurement."""
    print("=" * 60)
    print("DEMO 1: Orbit Complexity Profiles")
    print("=" * 60)
    print()
    
    # Famous examples with high stopping times
    examples = [7, 15, 27, 97, 171, 649, 871, 6171, 77031, 837799]
    
    print(f"{'n':>8} | {'σ(n)':>6} | {'peak':>10} | {'excursion':>10} | {'complexity':>12}")
    print("-" * 60)
    
    for n in examples:
        oc = compute_orbit_complexity(n)
        print(f"{n:>8} | {oc.stop_time:>6} | {oc.peak:>10} | "
              f"{oc.excursion:>10.2f} | {oc.complexity:>12.2f}")
    
    print()
    print("Note: 27 has an orbit that peaks at 9232 (342x its starting value)")
    print("before eventually reaching 1 — a classic 'excursion' orbit.")
    print()


def demo_stopping_time_growth():
    """Test the Θ(log²N) conjecture for stopping time growth."""
    print("=" * 60)
    print("DEMO 2: Stopping Time Growth — Testing Θ(log²N) Conjecture")
    print("=" * 60)
    print()
    
    results = stopping_time_growth_test([3, 5, 7, 9, 11, 13, 15])
    
    print(f"{'k':>3} | {'N=2^k':>8} | {'max σ':>6} | {'(log₂N)²':>8} | {'ratio':>8}")
    print("-" * 45)
    
    for k, data in results.items():
        print(f"{k:>3} | {data['N']:>8} | {data['max_stopping_time']:>6} | "
              f"{data['log2_N_squared']:>8} | {data['ratio']:>8.3f}")
    
    print()
    print("If the conjecture holds, the ratio column should stabilize.")
    print("A diverging ratio would disprove the quadratic bound conjecture.")
    print()


def demo_bounded_verification():
    """Demonstrate the bounded verification hierarchy."""
    print("=" * 60)
    print("DEMO 3: Bounded Verification Hierarchy")
    print("=" * 60)
    print()
    
    bounds = [10, 100, 1000, 10000, 100000]
    
    for N in bounds:
        verified = verify_collatz_up_to(N)
        max_st, argmax = max_stopping_time(N)
        print(f"collatzUpTo({N:>6}): {'✓' if verified else '✗'} | "
              f"hardest case: n={argmax}, σ={max_st}")
    
    print()
    print("Key insight: each collatzUpTo(N) is a finite, decidable statement.")
    print("The full conjecture ∀n≥1, reachesOne(n) is Π₁ — fundamentally different.")
    print("This is the gap that undecidability could exploit.")
    print()


def demo_tropical_distance():
    """Demonstrate tropical orbit distance."""
    print("=" * 60)
    print("DEMO 4: Tropical Orbit Distance")
    print("=" * 60)
    print()
    
    # Show how orbit points relate via tropical distance
    orbit_27 = collatz_orbit(27)[:20]
    print("First 20 values of orbit(27):")
    print(orbit_27)
    print()
    
    print("Tropical distances between consecutive orbit points:")
    dists = []
    for i in range(len(orbit_27) - 1):
        d = tropical_orbit_distance(orbit_27[i], orbit_27[i+1])
        dists.append(d)
        print(f"  d({orbit_27[i]:>5}, {orbit_27[i+1]:>5}) = {d}")
    
    print(f"\nAverage tropical step distance: {sum(dists)/len(dists):.2f}")
    print("In a 'random walk' model, even steps decrease tropical valuation by 1")
    print("and odd steps increase it by ≤ 2. Net drift determines convergence.")
    print()


def demo_parity_encoding():
    """Demonstrate parity sequence encoding of orbits."""
    print("=" * 60)
    print("DEMO 5: Parity Sequence Encoding")
    print("=" * 60)
    print()
    
    examples = [7, 27, 97]
    for n in examples:
        seq = parity_sequence(n, 30)
        binary = ''.join(str(b) for b in seq)
        even_count = seq.count(0)
        odd_count = seq.count(1)
        print(f"n={n:>3}: {binary}")
        print(f"        even={even_count}, odd={odd_count}, ratio={even_count/odd_count:.2f}")
        print()
    
    print("The parity sequence completely determines the orbit.")
    print("Even/odd ratio > 2 guarantees net descent (orbit convergence).")
    print("The Collatz conjecture is equivalent to: every parity sequence")
    print("eventually has enough even steps to drive the orbit to 1.")
    print()


def demo_syracuse():
    """Demonstrate the Syracuse (odd-only) formulation."""
    print("=" * 60)
    print("DEMO 6: Syracuse Formulation")
    print("=" * 60)
    print()
    
    odd_starts = [1, 3, 7, 15, 27, 97, 171]
    for n in odd_starts:
        try:
            syrac = syracuse_orbit(n, 50)
            print(f"Syracuse({n:>3}): {syrac[:10]}{'...' if len(syrac)>10 else ''}")
        except ValueError:
            pass
    
    print()
    print("The Syracuse function skips even steps, focusing on odd-to-odd dynamics.")
    print("This 'compressed' view reveals the essential multiplicative structure.")
    print()


def demo_certificate():
    """Demonstrate Collatz certificates."""
    print("=" * 60)
    print("DEMO 7: Collatz Certificates")
    print("=" * 60)
    print()
    
    for n in [7, 27, 97]:
        orbit = collatz_orbit(n)
        st = len(orbit) - 1
        pk = max(orbit)
        print(f"Certificate for n={n}:")
        print(f"  Steps: {st}")
        print(f"  Peak:  {pk}")
        print(f"  Orbit: {orbit[:15]}{'...' if len(orbit) > 15 else ''}")
        print(f"  Final: ...{orbit[-5:]}")
        print(f"  Valid: orbit[0]={orbit[0]}, orbit[-1]={orbit[-1]}")
        print()
    
    print("A certificate is a finite witness of reachability.")
    print("Certificate existence is Σ₁ while non-existence is Π₁.")
    print()


if __name__ == "__main__":
    demo_orbit_complexity()
    demo_stopping_time_growth()
    demo_bounded_verification()
    demo_tropical_distance()
    demo_parity_encoding()
    demo_syracuse()
    demo_certificate()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("This demonstration illustrates the key concepts connecting")
    print("Collatz dynamics to proof-theoretic complexity:")
    print()
    print("1. Orbit complexity grows unpredictably — small numbers can")
    print("   produce enormous excursions before converging.")
    print("2. Stopping times grow roughly as (log N)², but establishing")
    print("   this rigorously requires understanding deep number-theoretic")
    print("   structure.")
    print("3. Bounded verification (collatzUpTo N) is decidable for each N,")
    print("   but the universal claim may be independent of formal systems.")
    print("4. The tropical valuation perspective connects Collatz to")
    print("   geometric and algebraic frameworks.")


#!/usr/bin/env python3
"""
Collatz Orbit Visualization — Stopping Time vs. Bit-Length Scatter

Standalone visualization showing the relationship between starting value
and stopping time for the first N natural numbers, colored by peak excursion.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import math
import numpy as np


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1

def compute_orbit_data(n):
    """Return (stopping_time, peak, excursion) for n."""
    current = n
    steps = 0
    peak = n
    for _ in range(10000):
        if current == 1:
            break
        current = collatz_step(current)
        peak = max(peak, current)
        steps += 1
    return steps, peak, peak / n if n > 0 else 0

def main():
    N = 5000
    data = []
    for n in range(1, N + 1):
        st, pk, exc = compute_orbit_data(n)
        bit_len = math.ceil(math.log2(n + 1))
        data.append((n, st, pk, exc, bit_len))

    ns = [d[0] for d in data]
    sts = [d[1] for d in data]
    excs = [d[3] for d in data]
    bit_lens = [d[4] for d in data]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Collatz Orbit Complexity Analysis', fontsize=16, fontweight='bold')

    # Plot 1: Stopping time vs n
    ax1 = axes[0, 0]
    colors1 = [math.log2(e + 1) for e in excs]
    sc1 = ax1.scatter(ns, sts, c=colors1, cmap='viridis', s=1, alpha=0.6)
    ax1.set_xlabel('Starting value n')
    ax1.set_ylabel('Stopping time σ(n)')
    ax1.set_title('Stopping Time Distribution')
    plt.colorbar(sc1, ax=ax1, label='log₂(excursion + 1)')

    # Plot 2: Stopping time vs bit-length
    ax2 = axes[0, 1]
    ax2.scatter(bit_lens, sts, c='steelblue', s=1, alpha=0.4)
    # Add quadratic trend line
    max_bl = max(bit_lens)
    bl_range = np.arange(1, max_bl + 1)
    # Fit: σ ≈ C * (bit_len)²
    avg_ratios = []
    for bl in range(1, max_bl + 1):
        vals = [d[1] for d in data if d[4] == bl]
        if vals:
            avg_ratios.append(max(vals) / (bl * bl) if bl > 0 else 0)
    if avg_ratios:
        C_est = np.median(avg_ratios)
        ax2.plot(bl_range, C_est * bl_range**2, 'r-', linewidth=2,
                 label=f'σ ≈ {C_est:.1f} · (log₂n)²')
        ax2.legend()
    ax2.set_xlabel('Bit-length ⌈log₂(n)⌉')
    ax2.set_ylabel('Stopping time σ(n)')
    ax2.set_title('Stopping Time vs Bit-Length (Θ(log²N) Test)')

    # Plot 3: Excursion distribution (log scale)
    ax3 = axes[1, 0]
    log_excs = [math.log10(e) if e > 0 else 0 for e in excs]
    ax3.hist(log_excs, bins=50, color='coral', edgecolor='darkred', alpha=0.7)
    ax3.set_xlabel('log₁₀(peak/n)')
    ax3.set_ylabel('Count')
    ax3.set_title('Excursion Distribution')
    ax3.axvline(x=0, color='black', linestyle='--', alpha=0.5, label='No excursion')
    ax3.legend()

    # Plot 4: Max stopping time growth
    ax4 = axes[1, 1]
    powers = list(range(2, 13))
    max_sts = []
    log_sqs = []
    for k in powers:
        bound = min(2**k, N)
        max_st = max(d[1] for d in data if d[0] <= bound)
        max_sts.append(max_st)
        log_sqs.append(k * k)
    
    ax4.plot(powers, max_sts, 'bo-', label='max σ(n) for n ≤ 2^k', markersize=6)
    ax4.plot(powers, [7.0 * k**2 for k in powers], 'r--',
             label='7 · k² reference', alpha=0.7)
    ax4.set_xlabel('k (where N = 2^k)')
    ax4.set_ylabel('Maximum stopping time')
    ax4.set_title('Stopping Time Growth Rate')
    ax4.legend()

    plt.tight_layout()
    plt.savefig('collatz_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved collatz_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Valuation Walk Visualization

Shows the Collatz orbit as a walk in tropical (log) space,
revealing the underlying random-walk structure.
"""

import matplotlib.pyplot as plt
import math


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def tropical_walk(n, max_steps=500):
    """Compute the tropical valuation walk: log₂ of each orbit value."""
    walk = []
    current = n
    for _ in range(max_steps):
        if current < 1:
            break
        walk.append(math.log2(current) if current > 0 else 0)
        if current == 1 and len(walk) > 1:
            break
        current = collatz_step(current)
    return walk


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Collatz Orbits as Tropical Valuation Walks', fontsize=16, fontweight='bold')

    # Famous orbits
    examples = [(27, 'coral'), (97, 'steelblue'), (871, 'forestgreen'), (6171, 'purple')]
    
    # Plot 1: Tropical walks overlaid
    ax1 = axes[0, 0]
    for n, color in examples:
        walk = tropical_walk(n)
        ax1.plot(range(len(walk)), walk, color=color, alpha=0.8, label=f'n={n}')
    ax1.axhline(y=0, color='black', linestyle=':', alpha=0.3)
    ax1.set_xlabel('Step k')
    ax1.set_ylabel('log₂(orbit value)')
    ax1.set_title('Tropical Walks (log₂ scale)')
    ax1.legend()

    # Plot 2: Step increments (Δ log₂)
    ax2 = axes[0, 1]
    for n, color in examples[:2]:
        walk = tropical_walk(n)
        deltas = [walk[i+1] - walk[i] for i in range(len(walk)-1)]
        ax2.plot(range(len(deltas)), deltas, color=color, alpha=0.6, label=f'n={n}')
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.axhline(y=-1, color='blue', linestyle='--', alpha=0.3, label='Even step: -1')
    ax2.axhline(y=math.log2(3), color='red', linestyle='--', alpha=0.3,
                label=f'Odd bound: +log₂3≈{math.log2(3):.2f}')
    ax2.set_xlabel('Step k')
    ax2.set_ylabel('Δ log₂(orbit)')
    ax2.set_title('Tropical Step Increments')
    ax2.legend(fontsize=8)

    # Plot 3: Cumulative tropical drift for many starting values
    ax3 = axes[1, 0]
    N = 200
    for n in range(2, N, 3):
        walk = tropical_walk(n, max_steps=100)
        if len(walk) > 1:
            # Normalize by starting valuation
            normalized = [w - walk[0] for w in walk]
            ax3.plot(range(len(normalized)), normalized, color='gray', alpha=0.1)
    
    # Highlight a few
    for n, color in [(27, 'coral'), (97, 'steelblue')]:
        walk = tropical_walk(n, max_steps=200)
        normalized = [w - walk[0] for w in walk]
        ax3.plot(range(len(normalized)), normalized, color=color, alpha=0.9,
                 linewidth=2, label=f'n={n}')
    
    ax3.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax3.set_xlabel('Step k')
    ax3.set_ylabel('Normalized tropical walk (v(k) - v(0))')
    ax3.set_title('Tropical Drift (n=2..200)')
    ax3.legend()

    # Plot 4: Histogram of tropical walk slopes
    ax4 = axes[1, 1]
    slopes = []
    for n in range(2, 1000):
        walk = tropical_walk(n)
        if len(walk) > 10:
            slope = (walk[-1] - walk[0]) / len(walk)
            slopes.append(slope)
    
    ax4.hist(slopes, bins=50, color='mediumpurple', edgecolor='indigo', alpha=0.7)
    ax4.axvline(x=0, color='black', linestyle='--', alpha=0.5)
    mean_slope = sum(slopes) / len(slopes)
    ax4.axvline(x=mean_slope, color='red', linestyle='-', linewidth=2,
                label=f'Mean slope = {mean_slope:.4f}')
    ax4.set_xlabel('Average tropical slope per step')
    ax4.set_ylabel('Count')
    ax4.set_title('Distribution of Tropical Drift Rates')
    ax4.legend()

    plt.tight_layout()
    plt.savefig('tropical_walks.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_walks.png")


if __name__ == "__main__":
    main()
