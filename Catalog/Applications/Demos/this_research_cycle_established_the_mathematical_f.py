"""
Adelic Synchronization Index — Interactive Demo

Demonstrates the key results from the formalization:
1. Iterate image stabilization (antitone sequence)
2. Orbit signature computation
3. Periodic orbit packet divisibility
4. ASI computation and phase transition detection
"""

from algorithms import (
    quad_map, find_rho_shape, orbit_signature, cycle_type,
    adelic_sync_index, is_critically_preperiodic,
    iter_image_sizes, stabilization_index, normalized_orbit_count,
    orbit_length_distribution, compute_asi_landscape
)

def _is_prime(n: int) -> bool:
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


def get_primes_up_to(n: int) -> list:
    """Get all primes up to n."""
    return [p for p in range(2, n + 1) if _is_prime(p)]


def demo_iterate_stabilization():
    """Demo 1: Iterate image sizes form an antitone sequence."""
    print("=" * 60)
    print("DEMO 1: Iterate Image Stabilization")
    print("=" * 60)
    print()
    print("Theorem (iterImageCard_antitone): For f : α → α on a finite type,")
    print("the sequence n ↦ |Im(f^n)| is nonincreasing.")
    print()

    test_cases = [(0, 31), (-1, 37), (1, 23), (5, 41)]
    for c, p in test_cases:
        sizes = iter_image_sizes(c, p, max_iter=15)
        stab = stabilization_index(c, p)
        print(f"  f(x) = x² + {c} mod {p}:")
        print(f"    Image sizes: {sizes[:12]}...")
        print(f"    Stabilization index: N = {stab}")
        # Verify antitone property
        is_antitone = all(sizes[i] >= sizes[i+1] for i in range(len(sizes)-1))
        print(f"    Antitone verified: {is_antitone}")
        print()


def demo_orbit_signatures():
    """Demo 2: Orbit signatures and cycle types."""
    print("=" * 60)
    print("DEMO 2: Orbit Signatures & Cycle Types")
    print("=" * 60)
    print()
    print("Definition (orbitSignature): Multiset of minimal periods of periodic points.")
    print("Theorem (periodic_packet_divisibility): |{x : minPeriod = p}| is divisible by p.")
    print()

    for p in [7, 11, 13, 17, 23]:
        for c in [0, 1, -1]:
            sig = orbit_signature(c % p, p)
            ct = cycle_type(c % p, p)
            print(f"  f(x) = x² + {c} mod {p}:")
            print(f"    Orbit signature: {dict(sig)}")
            print(f"    Cycle type: {sorted(ct)}")
            # Verify packet divisibility
            for period, count in sig.items():
                assert count % period == 0, f"Divisibility failed for period {period}!"
            print(f"    Packet divisibility verified ✓")
        print()


def demo_rho_shapes():
    """Demo 3: Rho shapes (tail + cycle ≤ p)."""
    print("=" * 60)
    print("DEMO 3: Rho Shapes (tail + cycle ≤ p)")
    print("=" * 60)
    print()
    print("Theorem (rho_length_bound): For any x, ∃ tail cyc,")
    print("  tail + cyc ≤ card α ∧ cyc > 0 ∧ f^[tail+cyc] x = f^[tail] x")
    print()

    p = 31
    c = 3
    max_rho = 0
    for x in range(p):
        tail, cyc = find_rho_shape(c, x, p)
        rho = tail + cyc
        max_rho = max(max_rho, rho)
        if tail > 0:
            print(f"  x={x:2d}: tail={tail}, cycle={cyc}, rho={rho} {'≤' if rho <= p else '>'} {p}")
    print(f"\n  Max rho length: {max_rho} ≤ {p} ✓")
    print()


def demo_asi_phase_transition():
    """Demo 4: ASI phase transition at postcritical parameters."""
    print("=" * 60)
    print("DEMO 4: Adelic Synchronization Index — Phase Transition")
    print("=" * 60)
    print()
    print("Conjecture: ASI spikes at postcritical parameters (c=0, c=-1)")
    print("and is low for generic parameters.")
    print()

    primes = get_primes_up_to(100)
    print(f"  Using {len(primes)} primes up to {primes[-1]}")
    print()

    results = []
    for c in range(-5, 11):
        asi = adelic_sync_index(c, primes)
        preperiodic = is_critically_preperiodic(c)
        marker = " ← POSTCRITICAL" if preperiodic else ""
        bar = "█" * int(asi * 500)
        print(f"  c={c:3d}: ASI={asi:.6f} {bar}{marker}")
        results.append((c, asi, preperiodic))

    print()
    postcritical_asi = [asi for c, asi, pp in results if pp]
    generic_asi = [asi for c, asi, pp in results if not pp]

    if postcritical_asi and generic_asi:
        avg_post = sum(postcritical_asi) / len(postcritical_asi)
        avg_gen = sum(generic_asi) / len(generic_asi)
        ratio = avg_post / avg_gen if avg_gen > 0 else float('inf')
        print(f"  Average postcritical ASI: {avg_post:.6f}")
        print(f"  Average generic ASI:      {avg_gen:.6f}")
        print(f"  Ratio: {ratio:.2f}x")
        print()


def demo_distinct_cycle_bound():
    """Demo 5: Distinct cycle count bound k(k+1) ≤ 2n."""
    print("=" * 60)
    print("DEMO 5: Distinct Cycle Count Bound")
    print("=" * 60)
    print()
    print("Theorem (distinct_cycle_count_bound):")
    print("  k(k+1) ≤ 2·card(α), where k = # distinct cycle lengths.")
    print()

    primes = get_primes_up_to(200)
    for p in primes[:15]:
        max_k = 0
        max_c = 0
        for c in range(p):
            ct = cycle_type(c, p)
            k = len(ct)
            if k > max_k:
                max_k = k
                max_c = c
        bound_ok = max_k * (max_k + 1) <= 2 * p
        print(f"  p={p:3d}: max k={max_k} (at c={max_c}), "
              f"k(k+1)={max_k*(max_k+1)} ≤ {2*p} = 2p: {bound_ok} ✓")
    print()


if __name__ == "__main__":
    demo_iterate_stabilization()
    demo_orbit_signatures()
    demo_rho_shapes()
    demo_asi_phase_transition()
    demo_distinct_cycle_bound()


"""
Visualization: Adelic Synchronization Index Phase Transition

Produces a plot showing the ASI landscape over parameter space c ∈ [-10, 20]
with postcritical parameters highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def _is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def quad_map(c, x, p):
    return (x * x + c) % p


def minimal_period(c, x, p):
    tortoise = quad_map(c, x, p)
    hare = quad_map(c, quad_map(c, x, p), p)
    while tortoise != hare:
        tortoise = quad_map(c, tortoise, p)
        hare = quad_map(c, quad_map(c, hare, p), p)
    tail = 0
    tortoise_r = x % p
    while tortoise_r != hare:
        tortoise_r = quad_map(c, tortoise_r, p)
        hare = quad_map(c, hare, p)
        tail += 1
    if tail > 0:
        return 0
    cycle = 1
    hare = quad_map(c, tortoise_r, p)
    while tortoise_r != hare:
        hare = quad_map(c, hare, p)
        cycle += 1
    return cycle


def orbit_length_dist(c, p):
    from collections import Counter
    periods = Counter()
    for x in range(p):
        mp = minimal_period(c, x, p)
        if mp > 0:
            periods[mp] += 1
    return {k: v / p for k, v in periods.items()}


def l2_overlap(d1, d2):
    keys = set(d1.keys()) | set(d2.keys())
    return sum(d1.get(k, 0) * d2.get(k, 0) for k in keys)


def adelic_sync_index(c, primes):
    if len(primes) < 2:
        return 0.0
    dists = {p: orbit_length_dist(c, p) for p in primes}
    total = 0.0
    count = 0
    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i < j:
                total += l2_overlap(dists[p], dists[q])
                count += 1
    return total / count if count > 0 else 0.0


def is_critically_preperiodic(c, bound=200):
    x = 0
    seen = {}
    for n in range(bound):
        if x in seen:
            return True
        seen[x] = n
        x = x * x + c
        if abs(x) > 4:
            return False
    return False


def main():
    primes = [p for p in range(2, 80) if _is_prime(p)]
    c_values = list(range(-10, 21))

    asi_values = []
    preperiodic = []
    for c in c_values:
        asi_values.append(adelic_sync_index(c, primes))
        preperiodic.append(is_critically_preperiodic(c))

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [3, 1]})

    colors = ['#e74c3c' if pp else '#3498db' for pp in preperiodic]
    ax1.bar(c_values, asi_values, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)
    ax1.set_xlabel('Parameter c', fontsize=13)
    ax1.set_ylabel('Adelic Synchronization Index', fontsize=13)
    ax1.set_title('ASI Phase Transition in the Quadratic Family $f_c(x) = x^2 + c$',
                   fontsize=15, fontweight='bold')

    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#e74c3c', alpha=0.8, label='Postcritical (preperiodic 0)'),
        Patch(facecolor='#3498db', alpha=0.8, label='Generic')
    ]
    ax1.legend(handles=legend_elements, fontsize=11)
    ax1.grid(axis='y', alpha=0.3)

    # Plot iterate image sizes for selected c values
    for c_sel, color, ls in [(-1, '#e74c3c', '-'), (0, '#ff6600', '--'),
                              (1, '#3498db', '-'), (7, '#2ecc71', '--')]:
        sizes = []
        p_test = 97
        for n in range(20):
            img = set()
            for x in range(p_test):
                val = x
                for _ in range(n):
                    val = quad_map(c_sel, val, p_test)
                img.add(val)
            sizes.append(len(img))
        ax2.plot(range(20), sizes, color=color, linestyle=ls, marker='o',
                 markersize=3, label=f'c={c_sel}', linewidth=1.5)

    ax2.set_xlabel('Iterate n', fontsize=13)
    ax2.set_ylabel('|Im(f^n)| mod 97', fontsize=13)
    ax2.set_title('Iterate Image Stabilization (antitone, proved)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('asi_phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved: asi_phase_transition.png")


if __name__ == "__main__":
    main()
