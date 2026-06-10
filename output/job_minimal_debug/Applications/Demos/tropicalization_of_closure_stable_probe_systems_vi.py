#!/usr/bin/env python3
"""
Tropical Probe Valuation — Demonstration

Numerical examples illustrating the main theorems:
1. Tropical reconstruction formula
2. Defect decomposition
3. Strict drop detection
4. Valuation certificate pipeline
"""

from algorithms import (
    FilteredClosureSystem, TropicalProbeCertificate,
    TropicalProbeProfile, tropical_reconstruction,
    defect_decomposition_check, detect_strict_drops,
    make_threshold_system, tropicalize_probe
)
from typing import FrozenSet, Dict
import math


def example_1_threshold_system():
    """Example 1: Threshold closure system with integer weights.

    Universe = {0,...,7}, weight(i) = i.
    cl_r(A) = A ∪ {x : weight(x) ≤ r}.

    Probe p(x) = 10 - x (decreasing).
    """
    print("=" * 60)
    print("Example 1: Threshold Closure System")
    print("=" * 60)

    U = frozenset(range(8))
    weights = {i: float(i) for i in range(8)}
    sys = make_threshold_system(U, weights)

    probe = lambda x: float(10 - x)
    tpp = TropicalProbeProfile(sys, probe)

    A = frozenset([0, 1])
    scales = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]

    print(f"\nUniverse: {sorted(U)}")
    print(f"Seed A = {sorted(A)}")
    print(f"Probe p(x) = 10 - x")
    print(f"Scales: {scales}")

    # Compute profiles
    profiles = tropical_reconstruction(tpp, A, scales)
    print("\nTropical profiles (min of p over cl_r(A)):")
    for s, v in profiles.items():
        cl = sys.closure(s, A)
        defect = sys.scale_defect(A, 0.0, s) if s > 0 else frozenset()
        print(f"  scale {s:.1f}: profile = {v:.1f}, "
              f"|cl| = {len(cl)}, |defect(0,s)| = {len(defect)}")

    # Verify reconstruction formula
    print("\nVerifying reconstruction formula: profile(s) = min(profile(r), defect(r,s))")
    for i in range(1, len(scales)):
        r, s = scales[i-1], scales[i]
        prof_r = profiles[r]
        dv = tpp.defect_value(A, r, s)
        expected = min(prof_r, dv)
        actual = profiles[s]
        ok = "✓" if abs(expected - actual) < 1e-12 else "✗"
        print(f"  [{ok}] r={r:.1f}, s={s:.1f}: "
              f"min({prof_r:.1f}, {dv:.1f}) = {expected:.1f} == {actual:.1f}")

    # Detect strict drops
    drops = detect_strict_drops(tpp, A, scales)
    print(f"\nStrict profile drops (Theorem 5): {len(drops)} found")
    for r, s, drop in drops:
        print(f"  scale {r:.1f} -> {s:.1f}: drop = {drop:.1f}")


def example_2_defect_decomposition():
    """Example 2: Verify defect decomposition across three scales."""
    print("\n" + "=" * 60)
    print("Example 2: Defect Decomposition (Theorem 4)")
    print("=" * 60)

    U = frozenset(range(10))
    weights = {i: float(i) for i in range(10)}
    sys = make_threshold_system(U, weights)

    probe = lambda x: float(x * x)  # quadratic probe
    tpp = TropicalProbeProfile(sys, probe)

    A = frozenset([0])

    # Test decomposition for all triples r ≤ s ≤ t
    triples = [(0.0, 3.0, 6.0), (1.0, 4.0, 8.0), (0.0, 5.0, 9.0)]
    for r, s, t in triples:
        lhs, rhs, match = defect_decomposition_check(tpp, A, r, s, t)
        ok = "✓" if match else "✗"
        print(f"  [{ok}] r={r:.0f}, s={s:.0f}, t={t:.0f}: "
              f"defect(r,t) = {lhs:.1f}, "
              f"min(defect(r,s), defect(s,t)) = {rhs:.1f}")


def example_3_valuation_certificate():
    """Example 3: Tropicalization via valuation certificates."""
    print("\n" + "=" * 60)
    print("Example 3: Valuation Certificate Pipeline")
    print("=" * 60)

    U = frozenset(range(8))
    weights = {i: float(i) for i in range(8)}
    sys = make_threshold_system(U, weights)

    # Original probe: p(x) = 2^x (exponential)
    probe = lambda x: 2.0 ** x

    # Valuation: v(y) = log2(y) — the tropical image
    log_cert = TropicalProbeCertificate(val=lambda y: math.log2(y) if y > 0 else float('inf'))

    # Tropicalized probe: v(p(x)) = log2(2^x) = x
    trop_probe = tropicalize_probe(probe, log_cert)

    A = frozenset([0, 1])
    scales = [0.0, 2.0, 4.0, 6.0]

    print(f"\nOriginal probe p(x) = 2^x")
    print(f"Valuation v(y) = log2(y)")
    print(f"Tropicalized probe (v∘p)(x) = x")
    print(f"Seed A = {sorted(A)}")

    # Compare original and tropicalized profiles
    tpp_orig = TropicalProbeProfile(sys, probe)
    tpp_trop = TropicalProbeProfile(sys, trop_probe)

    prof_orig = tropical_reconstruction(tpp_orig, A, scales)
    prof_trop = tropical_reconstruction(tpp_trop, A, scales)

    print(f"\n{'Scale':>6} {'Original':>12} {'Tropical':>12} {'v(Original)':>12}")
    print("-" * 48)
    for s in scales:
        v_orig = math.log2(prof_orig[s]) if prof_orig[s] > 0 else float('inf')
        print(f"{s:6.1f} {prof_orig[s]:12.2f} {prof_trop[s]:12.2f} {v_orig:12.2f}")

    print("\nNote: v(Original) = Tropical, confirming functoriality!")


def example_4_antitone_profile():
    """Example 4: Demonstrate antitonicity of tropical profiles."""
    print("\n" + "=" * 60)
    print("Example 4: Profile Antitonicity (Theorem 2)")
    print("=" * 60)

    U = frozenset(range(12))
    weights = {i: float(i) for i in range(12)}
    sys = make_threshold_system(U, weights)

    probe = lambda x: float(20 - 2 * x)
    tpp = TropicalProbeProfile(sys, probe)

    A = frozenset([0])
    scales = list(range(12))

    profiles = tropical_reconstruction(tpp, A, [float(s) for s in scales])

    print(f"\nProbe p(x) = 20 - 2x, Seed A = {{0}}")
    print(f"\n{'Scale':>6} {'Profile':>10} {'Antitone?':>10}")
    print("-" * 30)
    prev = float('inf')
    all_antitone = True
    for s in scales:
        p = profiles[float(s)]
        ok = "✓" if p <= prev + 1e-12 else "✗"
        if p > prev + 1e-12:
            all_antitone = False
        print(f"{s:6d} {p:10.1f} {ok:>10}")
        prev = p

    print(f"\nAll transitions antitone: {'Yes ✓' if all_antitone else 'No ✗'}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Probe Valuation — Numerical Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    example_1_threshold_system()
    example_2_defect_decomposition()
    example_3_valuation_certificate()
    example_4_antitone_profile()

    print("\n" + "=" * 60)
    print("All examples completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Probe Profile Evolution

Shows how the tropical (min-plus) profile evolves across scales,
with defect contributions highlighted.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_threshold_closure(universe, weights, scale, seed):
    """cl_r(A) = A ∪ {x : w(x) ≤ r}"""
    return seed | frozenset(x for x in universe if weights.get(x, float('inf')) <= scale)


def compute_profile(closure_set, probe):
    if not closure_set:
        return float('inf')
    return min(probe(x) for x in closure_set)


def main():
    # Setup
    n = 12
    U = frozenset(range(n))
    weights = {i: float(i) for i in range(n)}
    A = frozenset([0, 1])
    scales = np.linspace(0, n - 1, 50)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Tropical Probe Profile Evolution", fontsize=16, fontweight='bold')

    # Panel 1: Linear probe
    ax = axes[0, 0]
    probe = lambda x: float(20 - 2 * x)
    profiles = []
    for s in scales:
        cl = make_threshold_closure(U, weights, s, A)
        profiles.append(compute_profile(cl, probe))
    ax.plot(scales, profiles, 'b-', linewidth=2, label='Tropical profile')
    ax.fill_between(scales, profiles, alpha=0.15, color='blue')
    ax.set_title('Linear Probe: p(x) = 20 - 2x')
    ax.set_xlabel('Scale r')
    ax.set_ylabel('min p(x) over cl_r(A)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Quadratic probe
    ax = axes[0, 1]
    probe = lambda x: float((x - 6) ** 2)
    profiles = []
    for s in scales:
        cl = make_threshold_closure(U, weights, s, A)
        profiles.append(compute_profile(cl, probe))
    ax.plot(scales, profiles, 'r-', linewidth=2, label='Tropical profile')
    ax.fill_between(scales, profiles, alpha=0.15, color='red')
    ax.set_title('Quadratic Probe: p(x) = (x-6)²')
    ax.set_xlabel('Scale r')
    ax.set_ylabel('min p(x) over cl_r(A)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Defect values (reconstruction formula visualization)
    ax = axes[1, 0]
    probe = lambda x: float(20 - 2 * x)
    discrete_scales = list(range(n))
    profiles = []
    defect_vals = []
    for i, s in enumerate(discrete_scales):
        cl = make_threshold_closure(U, weights, float(s), A)
        profiles.append(compute_profile(cl, probe))
        if i > 0:
            defect = make_threshold_closure(U, weights, float(s), A) - \
                     make_threshold_closure(U, weights, float(discrete_scales[i-1]), A)
            dv = compute_profile(defect, probe) if defect else float('inf')
            defect_vals.append(dv)
        else:
            defect_vals.append(float('inf'))

    ax.bar(discrete_scales, profiles, alpha=0.4, color='blue', label='Profile')
    finite_dv = [(s, d) for s, d in zip(discrete_scales, defect_vals) if d < float('inf')]
    if finite_dv:
        ax.bar([s for s, _ in finite_dv], [d for _, d in finite_dv],
               alpha=0.4, color='orange', label='Defect value')
    ax.set_title('Reconstruction: profile(s) = min(profile(r), defect)')
    ax.set_xlabel('Scale')
    ax.set_ylabel('Value')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: Multi-probe comparison
    ax = axes[1, 1]
    probes = [
        (lambda x: float(15 - x), 'p₁(x) = 15 - x', 'blue'),
        (lambda x: float(abs(x - 5)), 'p₂(x) = |x - 5|', 'red'),
        (lambda x: float(x % 4 + 1), 'p₃(x) = (x mod 4) + 1', 'green'),
    ]
    for probe_fn, label, color in probes:
        profiles = []
        for s in scales:
            cl = make_threshold_closure(U, weights, s, A)
            profiles.append(compute_profile(cl, probe_fn))
        ax.plot(scales, profiles, linewidth=2, label=label, color=color)
    ax.set_title('Multi-Probe Tropical Profiles')
    ax.set_xlabel('Scale r')
    ax.set_ylabel('min p(x) over cl_r(A)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_profiles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_profiles.png")


if __name__ == "__main__":
    main()
