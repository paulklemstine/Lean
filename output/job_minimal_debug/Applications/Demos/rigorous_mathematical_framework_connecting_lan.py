"""
Tropical Proof Thermodynamics — Interactive Demo

Demonstrates the key theorems through numerical examples.
"""

from algorithms import (
    thermodynamic_depth, boundary_difference, step_erasure,
    is_monotone, find_bottleneck, verify_telescoping,
    uniform_erasure_trace, erasure_vector, tropical_distance,
    tropical_norm, compose_morphisms, proof_certificate_check
)
import math


def demo_telescoping():
    """Demonstrate the Telescoping Theorem: depth = h[0] - h[n] for monotone traces."""
    print("=" * 60)
    print("DEMO 1: Telescoping Theorem")
    print("=" * 60)

    # Example 1: Uniform erasure
    h = uniform_erasure_trace(5, 2.0)
    print(f"\nUniform trace (n=5, δ=2): {h}")
    holds, depth, bd = verify_telescoping(h)
    print(f"  Depth = {depth:.4f}, Boundary difference = {bd:.4f}")
    print(f"  Telescoping holds: {holds}")
    print(f"  Step erasures: {erasure_vector(h)}")

    # Example 2: Non-uniform monotone trace
    h2 = [10.0, 7.0, 5.0, 2.0, 1.0, 0.0]
    print(f"\nNon-uniform monotone trace: {h2}")
    holds2, depth2, bd2 = verify_telescoping(h2)
    print(f"  Depth = {depth2:.4f}, Boundary difference = {bd2:.4f}")
    print(f"  Telescoping holds: {holds2}")
    print(f"  Step erasures: {erasure_vector(h2)}")

    # Example 3: Non-monotone trace (telescoping doesn't apply)
    h3 = [5.0, 3.0, 7.0, 1.0]
    print(f"\nNon-monotone trace: {h3}")
    depth3 = thermodynamic_depth(h3)
    bd3 = boundary_difference(h3)
    print(f"  Depth = {depth3:.4f}, Boundary difference = {bd3:.4f}")
    print(f"  Monotone: {is_monotone(h3)}")
    print(f"  Depth ≠ boundary difference (as expected for non-monotone)")
    print(f"  Step erasures: {erasure_vector(h3)}")


def demo_concentration():
    """Demonstrate the Erasure Concentration Inequality."""
    print("\n" + "=" * 60)
    print("DEMO 2: Erasure Concentration (Bottleneck Detection)")
    print("=" * 60)

    traces = [
        ("Uniform", [10.0, 8.0, 6.0, 4.0, 2.0, 0.0]),
        ("Front-heavy", [10.0, 2.0, 1.5, 1.0, 0.5, 0.0]),
        ("Back-heavy", [10.0, 9.5, 9.0, 8.5, 2.0, 0.0]),
        ("Single-step", [10.0, 10.0, 10.0, 10.0, 10.0, 0.0]),
    ]

    for name, h in traces:
        n = len(h) - 1
        depth = thermodynamic_depth(h)
        threshold = depth / n
        idx, max_erasure = find_bottleneck(h)
        print(f"\n{name}: {h}")
        print(f"  Depth = {depth:.4f}, n = {n}")
        print(f"  Threshold D/n = {threshold:.4f}")
        print(f"  Bottleneck at step {idx}: erasure = {max_erasure:.4f}")
        print(f"  Concentration satisfied: {max_erasure >= threshold - 1e-10}")
        print(f"  Erasure vector: {erasure_vector(h)}")


def demo_reversibility():
    """Demonstrate the reversibility characterization."""
    print("\n" + "=" * 60)
    print("DEMO 3: Reversibility Characterization")
    print("=" * 60)

    h = [8.0, 8.0, 5.0, 5.0, 3.0, 0.0]
    print(f"\nTrace: {h}")
    print(f"  Monotone: {is_monotone(h)}")
    ev = erasure_vector(h)
    for i, e in enumerate(ev):
        status = "REVERSIBLE" if abs(e) < 1e-10 else f"IRREVERSIBLE (erasure={e:.2f})"
        print(f"  Step {i}: h[{i}]={h[i]} → h[{i+1}]={h[i+1]}, {status}")


def demo_tropical_metric():
    """Demonstrate the tropical metric and its connection to depth."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Metric and Depth-Distance Equivalence")
    print("=" * 60)

    # Triangle inequality
    points = [(0.0, 3.0, 7.0), (1.0, 5.0, 2.0), (10.0, 3.0, 8.0)]
    print("\nTropical Triangle Inequality:")
    for a, b, c in points:
        d_ac = tropical_distance(a, c)
        d_ab = tropical_distance(a, b)
        d_bc = tropical_distance(b, c)
        print(f"  d({a},{c})={d_ac:.2f} ≤ d({a},{b})+d({b},{c})="
              f"{d_ab:.2f}+{d_bc:.2f}={d_ab+d_bc:.2f}: {d_ac <= d_ab + d_bc + 1e-10}")

    # Depth = tropical distance for monotone traces
    print("\nDepth-Distance Equivalence (monotone traces):")
    for h in [[10, 7, 3, 0], [5, 4, 3, 2, 1], [100, 50, 25, 0]]:
        h = [float(x) for x in h]
        depth = thermodynamic_depth(h)
        td = tropical_distance(h[0], h[-1])
        print(f"  Trace {h}: depth={depth:.2f}, tropical_dist={td:.2f}, equal={abs(depth-td)<1e-10}")


def demo_composition():
    """Demonstrate superadditive composition."""
    print("\n" + "=" * 60)
    print("DEMO 5: Superadditive Composition")
    print("=" * 60)

    # Two morphisms
    morphisms = [
        ((10.0, 7.0, 4.0), (7.0, 3.0, 5.0)),  # costs exceed boundary
        ((10.0, 7.0, 3.0), (7.0, 3.0, 4.0)),  # costs equal boundary
        ((10.0, 5.0, 8.0), (5.0, 1.0, 6.0)),  # costs exceed boundary
    ]

    for (s1, t1, c1), (s2, t2, c2) in morphisms:
        s_comp, t_comp, c_comp = compose_morphisms(s1, t1, c1, s2, t2, c2)
        boundary = s_comp - t_comp
        print(f"\n  f=({s1}→{t1}, cost={c1}) ∘ g=({s2}→{t2}, cost={c2})")
        print(f"  Composed: ({s_comp}→{t_comp}, cost={c_comp})")
        print(f"  Boundary diff = {boundary:.2f} ≤ cost = {c_comp:.2f}: {boundary <= c_comp + 1e-10}")
        print(f"  Wasted erasure = {c_comp - boundary:.2f}")


def demo_depth_lower_bound():
    """Demonstrate the depth lower bound for Boolean proof certificates."""
    print("\n" + "=" * 60)
    print("DEMO 6: Depth Lower Bound for Boolean Proof Certificates")
    print("=" * 60)

    test_cases = [
        ("AND(4 bits), C=3", [math.log(3), math.log(2), math.log(1.5), 0.0], 3),
        ("PARITY(8 bits), C=7", [math.log(7), math.log(5), math.log(3), math.log(1.5), 0.0], 7),
        ("Large circuit, C=100", uniform_erasure_trace(10, math.log(100)/10), 100),
    ]

    for name, h, C in test_cases:
        satisfied, explanation = proof_certificate_check(h, C)
        print(f"\n  {name}:")
        print(f"    Trace: {[f'{x:.4f}' for x in h]}")
        print(f"    {explanation}")


def demo_exponential_gap():
    """Demonstrate the exponential gap: linear depth from bounded complexity."""
    print("\n" + "=" * 60)
    print("DEMO 7: Exponential Gap — Linear Depth from Bounded Complexity")
    print("=" * 60)

    print("\nUniform erasure traces with δ=1:")
    for n in [5, 10, 50, 100, 500]:
        h = uniform_erasure_trace(n, 1.0)
        depth = thermodynamic_depth(h)
        initial = h[0]
        print(f"  n={n:4d}: initial entropy = {initial:.1f}, depth = {depth:.1f}, "
              f"ratio depth/initial = {depth/initial:.1f}")

    print("\n  → Depth grows linearly with n while initial entropy = n")
    print("    (Both grow linearly here, but for fixed-statement proofs,")
    print("     initial entropy is bounded while depth can grow without bound.)")


if __name__ == "__main__":
    demo_telescoping()
    demo_concentration()
    demo_reversibility()
    demo_tropical_metric()
    demo_composition()
    demo_depth_lower_bound()
    demo_exponential_gap()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Proof Trace Thermodynamics

Standalone matplotlib visualization of proof traces, erasure vectors,
and the Telescoping Theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def step_erasure(h, i):
    return max(0.0, h[i] - h[i + 1])


def erasure_vector(h):
    return [step_erasure(h, i) for i in range(len(h) - 1)]


def thermodynamic_depth(h):
    return sum(erasure_vector(h))


def plot_trace_and_erasure(ax1, ax2, h, title, color='steelblue'):
    """Plot entropy trace and erasure vector side by side."""
    n = len(h) - 1
    steps = list(range(n + 1))
    ev = erasure_vector(h)

    # Entropy trace
    ax1.plot(steps, h, 'o-', color=color, linewidth=2, markersize=8)
    ax1.fill_between(steps, h, alpha=0.15, color=color)
    ax1.set_xlabel('Step', fontsize=11)
    ax1.set_ylabel('Entropy', fontsize=11)
    ax1.set_title(f'{title}\nEntropy Trace', fontsize=12, fontweight='bold')
    ax1.set_xticks(steps)
    ax1.grid(True, alpha=0.3)

    # Erasure vector
    colors = ['#d32f2f' if e > 0 else '#4caf50' for e in ev]
    bars = ax2.bar(range(n), ev, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    depth = thermodynamic_depth(h)
    ax2.axhline(y=depth / n, color='orange', linestyle='--', linewidth=2,
                label=f'D/n = {depth/n:.2f}')
    ax2.set_xlabel('Step', fontsize=11)
    ax2.set_ylabel('Erasure', fontsize=11)
    ax2.set_title(f'Erasure Vector (D={depth:.2f})', fontsize=12, fontweight='bold')
    ax2.set_xticks(range(n))
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)


def main():
    fig, axes = plt.subplots(4, 2, figsize=(14, 18))
    fig.suptitle('Tropical Proof Thermodynamics\nEntropy Traces and Erasure Vectors',
                 fontsize=16, fontweight='bold', y=0.98)

    traces = [
        ([10, 8, 6, 4, 2, 0], "Uniform Erasure", '#1976d2'),
        ([10, 2, 1.5, 1, 0.5, 0], "Front-Heavy Bottleneck", '#d32f2f'),
        ([10, 9.5, 9, 8.5, 2, 0], "Back-Heavy Bottleneck", '#388e3c'),
        ([8, 8, 5, 5, 3, 0], "Mixed Reversible/Irreversible", '#7b1fa2'),
    ]

    for row, (h, title, color) in enumerate(traces):
        h = [float(x) for x in h]
        plot_trace_and_erasure(axes[row, 0], axes[row, 1], h, title, color)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('proof_traces.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: proof_traces.png")


def plot_telescoping_verification():
    """Plot verification of the Telescoping Theorem across many traces."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    np.random.seed(42)
    depths = []
    boundaries = []
    n_traces = 200

    for _ in range(n_traces):
        n = np.random.randint(3, 20)
        # Generate monotone trace
        h = [10.0]
        for _ in range(n):
            h.append(h[-1] - np.random.exponential(0.5))
            if h[-1] < 0:
                h[-1] = 0
        d = thermodynamic_depth(h)
        b = h[0] - h[-1]
        depths.append(d)
        boundaries.append(b)

    ax1.scatter(boundaries, depths, alpha=0.6, s=30, c='steelblue', edgecolors='navy', linewidth=0.5)
    ax1.plot([0, max(boundaries)], [0, max(boundaries)], 'r--', linewidth=2, label='y = x')
    ax1.set_xlabel('Boundary Difference (h₀ - hₙ)', fontsize=12)
    ax1.set_ylabel('Thermodynamic Depth D(T)', fontsize=12)
    ax1.set_title('Telescoping Theorem Verification\n(200 random monotone traces)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Non-monotone traces
    nm_depths = []
    nm_boundaries = []
    for _ in range(n_traces):
        n = np.random.randint(3, 15)
        h = list(np.random.uniform(0, 10, n + 1))
        d = thermodynamic_depth(h)
        b = h[0] - h[-1]
        nm_depths.append(d)
        nm_boundaries.append(b)

    ax2.scatter(nm_boundaries, nm_depths, alpha=0.6, s=30, c='#d32f2f', edgecolors='darkred', linewidth=0.5)
    ax2.plot([min(nm_boundaries), max(nm_boundaries)],
             [min(nm_boundaries), max(nm_boundaries)], 'b--', linewidth=2, label='y = x')
    ax2.set_xlabel('Boundary Difference (h₀ - hₙ)', fontsize=12)
    ax2.set_ylabel('Thermodynamic Depth D(T)', fontsize=12)
    ax2.set_title('Non-Monotone Traces\n(Depth ≥ Boundary Diff, but ≠)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('telescoping_verification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: telescoping_verification.png")


if __name__ == "__main__":
    main()
    plot_telescoping_verification()
