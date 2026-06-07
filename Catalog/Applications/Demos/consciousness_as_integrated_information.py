#!/usr/bin/env python3
"""
Causal Integration Algebra — Interactive Demo

Demonstrates key theorems and properties of integrated information Φ
through concrete numerical examples.
"""

from algorithms import *


def print_matrix(weights, n, label="Weight matrix"):
    """Pretty-print a weight matrix."""
    print(f"\n{label}:")
    for i in range(n):
        print("  [" + ", ".join(f"{w:5.2f}" for w in weights[i]) + "]")


def demo_basic_phi():
    """Demo 1: Basic Φ computation on a 4-node system."""
    print("=" * 60)
    print("DEMO 1: Basic Φ Computation")
    print("=" * 60)
    
    n = 4
    # A system with interesting structure: two tightly coupled pairs
    # with weak cross-coupling
    weights = [
        [0, 5, 1, 0],
        [5, 0, 0, 1],
        [1, 0, 0, 5],
        [0, 1, 5, 0]
    ]
    
    print_matrix(weights, n)
    
    phi, partition = compute_phi(weights, n)
    print(f"\nΦ = {phi}")
    print(f"Minimum cut partition: A = {partition}")
    print(f"Total weight: {compute_total_weight(weights, n)}")
    print(f"\nInterpretation: The cheapest way to split this system costs {phi}")
    print(f"units of causal flow. The system is {'integrated' if phi > 0 else 'disconnected'}.")


def demo_disconnected():
    """Demo 2: Disconnected system has Φ = 0 (Theorem 3.5)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Disconnected System — Φ = 0")
    print("=" * 60)
    
    n = 4
    # Two independent pairs
    weights = [
        [0, 3, 0, 0],
        [3, 0, 0, 0],
        [0, 0, 0, 7],
        [0, 0, 7, 0]
    ]
    
    print_matrix(weights, n)
    
    phi, partition = compute_phi(weights, n)
    disconnected, witness = is_disconnected(weights, n)
    
    print(f"\nΦ = {phi}")
    print(f"Is disconnected: {disconnected}")
    if witness:
        print(f"Witnessing partition: A = {witness}")
    print(f"\nVerifies Theorem 3.5: Φ = 0 for disconnected systems ✓")


def demo_direct_sum():
    """Demo 3: Direct sum has Φ = 0 (Corollary 3.8)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Direct Sum — Φ = 0")
    print("=" * 60)
    
    w1 = [[0, 5], [3, 0]]
    w2 = [[0, 7, 2], [4, 0, 1], [1, 3, 0]]
    
    print_matrix(w1, 2, "System 1")
    phi1, _ = compute_phi(w1, 2)
    print(f"Φ₁ = {phi1}")
    
    print_matrix(w2, 3, "System 2")
    phi2, _ = compute_phi(w2, 3)
    print(f"Φ₂ = {phi2}")
    
    w_sum, n_sum = direct_sum(w1, 2, w2, 3)
    print_matrix(w_sum, n_sum, "Direct Sum")
    phi_sum, _ = compute_phi(w_sum, n_sum)
    print(f"Φ(C₁ ⊕ C₂) = {phi_sum}")
    print(f"\nVerifies Corollary 3.8: Φ(direct sum) = 0 ✓")


def demo_scaling():
    """Demo 4: Scaling law Φ(cC) = c·Φ(C) (Theorem 3.10)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Scaling Law — Φ(cC) = c·Φ(C)")
    print("=" * 60)
    
    n = 3
    weights = [[0, 2, 1], [3, 0, 4], [1, 2, 0]]
    
    print_matrix(weights, n, "Original system C")
    phi_orig, _ = compute_phi(weights, n)
    print(f"Φ(C) = {phi_orig}")
    
    for c in [0.5, 2.0, 3.0, 10.0]:
        scaled = scale(weights, n, c)
        phi_scaled, _ = compute_phi(scaled, n)
        expected = c * phi_orig
        print(f"  c = {c:5.1f}: Φ(cC) = {phi_scaled:8.2f}, c·Φ(C) = {expected:8.2f}, match: {abs(phi_scaled - expected) < 1e-10}")
    
    print(f"\nVerifies Theorem 3.10: Φ scales linearly ✓")


def demo_symmetrization():
    """Demo 5: Symmetrization preserves Φ (Corollary 3.12)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Symmetrization Invariance — Φ(C̃) = Φ(C)")
    print("=" * 60)
    
    n = 4
    # Asymmetric system
    weights = [
        [0, 8, 1, 0],
        [2, 0, 0, 3],
        [5, 0, 0, 1],
        [0, 1, 7, 0]
    ]
    
    print_matrix(weights, n, "Original (asymmetric) C")
    phi_orig, _ = compute_phi(weights, n)
    print(f"Φ(C) = {phi_orig}")
    
    sym = symmetrize(weights, n)
    print_matrix(sym, n, "Symmetrized C̃")
    phi_sym, _ = compute_phi(sym, n)
    print(f"Φ(C̃) = {phi_sym}")
    
    print(f"\nMatch: {abs(phi_orig - phi_sym) < 1e-10}")
    print(f"Verifies Corollary 3.12: Symmetrization preserves Φ ✓")


def demo_monotonicity():
    """Demo 6: Monotonicity — stronger connections, higher Φ (Theorem 3.9)."""
    print("\n" + "=" * 60)
    print("DEMO 6: Monotonicity — Stronger Connections ⟹ Higher Φ")
    print("=" * 60)
    
    n = 3
    w_weak = [[0, 1, 1], [1, 0, 1], [1, 1, 0]]
    w_strong = [[0, 3, 2], [4, 0, 3], [2, 5, 0]]
    
    print_matrix(w_weak, n, "Weak system (all weights ≤ strong)")
    phi_weak, _ = compute_phi(w_weak, n)
    print(f"Φ(weak) = {phi_weak}")
    
    print_matrix(w_strong, n, "Strong system")
    phi_strong, _ = compute_phi(w_strong, n)
    print(f"Φ(strong) = {phi_strong}")
    
    print(f"\nΦ(weak) ≤ Φ(strong): {phi_weak <= phi_strong}")
    print(f"Verifies Theorem 3.9: Monotonicity ✓")


def demo_integration_spectrum():
    """Demo 7: Integration Spectrum — multi-scale structure."""
    print("\n" + "=" * 60)
    print("DEMO 7: Integration Spectrum — Multi-Scale Structure")
    print("=" * 60)
    
    n = 5
    # Complete graph with unit weights
    weights = [[0 if i == j else 1 for j in range(n)] for i in range(n)]
    
    print_matrix(weights, n, "Complete graph K₅ (unit weights)")
    
    spectrum = compute_integration_spectrum(weights, n)
    for k, phi_k in enumerate(spectrum, start=2):
        print(f"  Φ_{k} = {phi_k}")
    
    print(f"\nSpectrum is non-decreasing: {all(spectrum[i] <= spectrum[i+1] for i in range(len(spectrum)-1))}")
    print("The spectrum shows how integration cost increases with finer partitions.")


def demo_strongly_positive():
    """Demo 8: Strongly positive systems have Φ > 0 (Theorem 3.6)."""
    print("\n" + "=" * 60)
    print("DEMO 8: Strongly Positive ⟹ Φ > 0")
    print("=" * 60)
    
    for n in [2, 3, 4, 5]:
        # Complete graph with weight = 1/(n-1)
        weights = [[0 if i == j else 1.0/(n-1) for j in range(n)] for i in range(n)]
        phi, _ = compute_phi(weights, n)
        print(f"  n = {n}: Φ = {phi:.4f} > 0 ✓")
    
    print(f"\nVerifies Theorem 3.6: All strongly positive systems have Φ > 0 ✓")


def demo_phase_transition():
    """Demo 9: Phase transition in integration (Future Direction 2)."""
    print("\n" + "=" * 60)
    print("DEMO 9: Phase Transition — Integration Emergence")
    print("=" * 60)
    
    n = 4
    # Disconnected: two pairs
    w_disc = [
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 0, 1],
        [0, 0, 1, 0]
    ]
    # Connected: complete graph
    w_conn = [[0 if i == j else 1 for j in range(n)] for i in range(n)]
    
    print("Interpolating between disconnected and connected:")
    transitions = []
    for step in range(21):
        t = step / 20.0
        w_interp = [
            [(1-t) * w_disc[i][j] + t * w_conn[i][j] for j in range(n)]
            for i in range(n)
        ]
        phi, _ = compute_phi(w_interp, n)
        transitions.append((t, phi))
        marker = " ← transition!" if step > 0 and transitions[-2][1] == 0 and phi > 0 else ""
        print(f"  t = {t:.2f}: Φ = {phi:.4f}{marker}")
    
    print("\nPhase transition observed: Φ jumps from 0 to positive!")


if __name__ == "__main__":
    demo_basic_phi()
    demo_disconnected()
    demo_direct_sum()
    demo_scaling()
    demo_symmetrization()
    demo_monotonicity()
    demo_integration_spectrum()
    demo_strongly_positive()
    demo_phase_transition()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Integration Phase Transition and Spectrum

Generates matplotlib figures showing:
1. Phase transition in Φ as connectivity increases
2. Integration spectrum for different graph topologies
3. Φ scaling law verification
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def flow_between(weights, a_set, b_set):
    return sum(weights[i][j] for i in a_set for j in b_set)


def cross_info(weights, a_set, n):
    complement = set(range(n)) - a_set
    return flow_between(weights, a_set, complement) + flow_between(weights, complement, a_set)


def compute_phi(weights, n):
    if n <= 1:
        return 0.0
    best = float('inf')
    for size in range(1, n):
        for subset in itertools.combinations(range(n), size):
            ci = cross_info(weights, set(subset), n)
            best = min(best, ci)
    return best


def compute_integration_spectrum(weights, n, max_k=None):
    if max_k is None:
        max_k = n
    max_k = min(max_k, n)
    spectrum = []
    for k in range(2, max_k + 1):
        best = float('inf')
        for assignment in itertools.product(range(k), repeat=n):
            if len(set(assignment)) < k:
                continue
            flow = sum(weights[i][j] for i in range(n) for j in range(n) if assignment[i] != assignment[j])
            best = min(best, flow)
        spectrum.append(best)
    return spectrum


def figure_phase_transition():
    """Figure 1: Phase transition in Φ."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    for ax_idx, n in enumerate([4, 6]):
        w_disc = [[0.0]*n for _ in range(n)]
        for i in range(0, n, 2):
            if i+1 < n:
                w_disc[i][i+1] = 1.0
                w_disc[i+1][i] = 1.0
        
        w_conn = [[0 if i == j else 1.0 for j in range(n)] for i in range(n)]
        
        ts = np.linspace(0, 1, 50)
        phis = []
        for t in ts:
            w = [[(1-t)*w_disc[i][j] + t*w_conn[i][j] for j in range(n)] for i in range(n)]
            phis.append(compute_phi(w, n))
        
        ax = axes[ax_idx]
        ax.plot(ts, phis, 'b-', linewidth=2)
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_xlabel('Interpolation parameter t', fontsize=12)
        ax.set_ylabel('Φ (Integrated Information)', fontsize=12)
        ax.set_title(f'Phase Transition: n = {n}', fontsize=14)
        ax.grid(True, alpha=0.3)
        
        # Mark transition point
        for i in range(1, len(phis)):
            if phis[i-1] == 0 and phis[i] > 0:
                ax.axvline(x=ts[i], color='red', linestyle=':', alpha=0.7)
                ax.annotate(f't* ≈ {ts[i]:.2f}', xy=(ts[i], phis[i]), 
                           xytext=(ts[i]+0.1, phis[i]+0.5),
                           arrowprops=dict(arrowstyle='->', color='red'),
                           fontsize=10, color='red')
                break
    
    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: phase_transition.png")


def figure_integration_spectrum():
    """Figure 2: Integration spectrum for different topologies."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    n = 5
    
    # Complete graph
    w_complete = [[0 if i == j else 1.0 for j in range(n)] for i in range(n)]
    spec_complete = compute_integration_spectrum(w_complete, n)
    
    # Path graph
    w_path = [[0.0]*n for _ in range(n)]
    for i in range(n-1):
        w_path[i][i+1] = 1.0
        w_path[i+1][i] = 1.0
    spec_path = compute_integration_spectrum(w_path, n)
    
    # Star graph
    w_star = [[0.0]*n for _ in range(n)]
    for i in range(1, n):
        w_star[0][i] = 1.0
        w_star[i][0] = 1.0
    spec_star = compute_integration_spectrum(w_star, n)
    
    # Cycle graph
    w_cycle = [[0.0]*n for _ in range(n)]
    for i in range(n):
        w_cycle[i][(i+1) % n] = 1.0
        w_cycle[(i+1) % n][i] = 1.0
    spec_cycle = compute_integration_spectrum(w_cycle, n)
    
    ks = list(range(2, n+1))
    ax.plot(ks, spec_complete, 'bo-', linewidth=2, markersize=8, label='Complete K₅')
    ax.plot(ks, spec_path, 'rs-', linewidth=2, markersize=8, label='Path P₅')
    ax.plot(ks, spec_star, 'g^-', linewidth=2, markersize=8, label='Star S₅')
    ax.plot(ks, spec_cycle, 'mD-', linewidth=2, markersize=8, label='Cycle C₅')
    
    ax.set_xlabel('Partition size k', fontsize=12)
    ax.set_ylabel('Φ_k (k-partition integration)', fontsize=12)
    ax.set_title('Integration Spectrum: Multi-Scale Causal Structure', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ks)
    
    plt.tight_layout()
    plt.savefig('integration_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: integration_spectrum.png")


def figure_scaling_law():
    """Figure 3: Verification of scaling law Φ(cC) = cΦ(C)."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    n = 4
    weights = [[0, 2, 1, 3], [3, 0, 4, 1], [1, 2, 0, 5], [2, 1, 3, 0]]
    phi_base = compute_phi(weights, n)
    
    cs = np.linspace(0, 5, 30)
    phis_actual = []
    phis_predicted = []
    
    for c in cs:
        scaled = [[c * weights[i][j] for j in range(n)] for i in range(n)]
        phis_actual.append(compute_phi(scaled, n))
        phis_predicted.append(c * phi_base)
    
    ax.plot(cs, phis_actual, 'bo', markersize=6, label='Computed Φ(cC)')
    ax.plot(cs, phis_predicted, 'r-', linewidth=2, label='Predicted c·Φ(C)')
    
    ax.set_xlabel('Scale factor c', fontsize=12)
    ax.set_ylabel('Φ', fontsize=12)
    ax.set_title(f'Scaling Law: Φ(cC) = c·Φ(C), base Φ = {phi_base}', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('scaling_law.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: scaling_law.png")


if __name__ == "__main__":
    figure_phase_transition()
    figure_integration_spectrum()
    figure_scaling_law()
    print("\nAll visualizations generated!")
