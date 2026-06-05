#!/usr/bin/env python3
"""
Integrated Information Theory — Numerical Demonstrations

Demonstrates the key theorems from the IIT formalization:
1. Superadditivity of Φ
2. Complete zero-integration characterization  
3. Linear scaling
4. Integration defect subadditivity
5. Exclusion principle
"""

from algorithms import (
    CausalMechanism, verify_superadditivity, verify_scaling,
    verify_defect_subadditivity, find_exclusion_maximum, integration_profile
)


def print_header(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def demo_basic_examples() -> None:
    """Show Φ for basic graph types."""
    print_header("Basic Examples: Φ for Standard Graph Types")
    
    for n in [3, 4, 5, 6]:
        complete = CausalMechanism.complete(n)
        path = CausalMechanism.path(n)
        cycle = CausalMechanism.cycle(n)
        
        print(f"\n  n = {n} states:")
        print(f"    Complete graph: Φ = {complete.phi():.1f}, "
              f"W = {complete.total_weight():.0f}, "
              f"efficiency = {complete.efficiency():.3f}")
        print(f"    Path graph:     Φ = {path.phi():.1f}, "
              f"W = {path.total_weight():.0f}, "
              f"efficiency = {path.efficiency():.3f}")
        print(f"    Cycle graph:    Φ = {cycle.phi():.1f}, "
              f"W = {cycle.total_weight():.0f}, "
              f"efficiency = {cycle.efficiency():.3f}")


def demo_superadditivity() -> None:
    """Demonstrate Φ's superadditivity under mechanism addition."""
    print_header("Theorem: Superadditivity — Φ(M₁+M₂) ≥ Φ(M₁) + Φ(M₂)")
    
    # Example 1: Two paths on 4 nodes
    m1 = CausalMechanism([[0, 1, 0, 0], [1, 0, 0, 0],
                           [0, 0, 0, 1], [0, 0, 1, 0]])
    m2 = CausalMechanism([[0, 0, 1, 0], [0, 0, 0, 1],
                           [1, 0, 0, 0], [0, 1, 0, 0]])
    
    result = verify_superadditivity(m1, m2)
    print(f"\n  Example 1: Complementary connection patterns")
    print(f"    Φ(M₁) = {result['phi_m1']:.1f}")
    print(f"    Φ(M₂) = {result['phi_m2']:.1f}")
    print(f"    Φ(M₁) + Φ(M₂) = {result['phi_sum']:.1f}")
    print(f"    Φ(M₁ + M₂) = {result['phi_combined']:.1f}")
    print(f"    Superadditive: {result['superadditive']} "
          f"(excess = {result['excess']:.1f})")
    
    # Example 2: Two random-ish mechanisms
    m3 = CausalMechanism([[0, 2, 0, 1], [0, 0, 3, 0],
                           [1, 0, 0, 0], [0, 1, 2, 0]])
    m4 = CausalMechanism([[0, 0, 1, 2], [3, 0, 0, 1],
                           [0, 2, 0, 0], [1, 0, 0, 0]])
    
    result = verify_superadditivity(m3, m4)
    print(f"\n  Example 2: Asymmetric mechanisms")
    print(f"    Φ(M₃) = {result['phi_m1']:.1f}")
    print(f"    Φ(M₄) = {result['phi_m2']:.1f}")
    print(f"    Φ(M₃) + Φ(M₄) = {result['phi_sum']:.1f}")
    print(f"    Φ(M₃ + M₄) = {result['phi_combined']:.1f}")
    print(f"    Superadditive: {result['superadditive']} "
          f"(excess = {result['excess']:.1f})")


def demo_disconnection() -> None:
    """Demonstrate the disconnection theorem: Φ=0 ↔ disconnected."""
    print_header("Theorem: Φ = 0 ↔ System is Disconnected")
    
    # Connected system
    connected = CausalMechanism.complete(4)
    print(f"\n  Complete graph (4 nodes): Φ = {connected.phi():.1f}, "
          f"disconnected = {connected.has_zero_cut()}")
    
    # Disconnected system (two isolated pairs)
    disconnected = CausalMechanism([
        [0, 1, 0, 0], [1, 0, 0, 0],
        [0, 0, 0, 1], [0, 0, 1, 0]
    ])
    print(f"  Two isolated pairs:       Φ = {disconnected.phi():.1f}, "
          f"disconnected = {disconnected.has_zero_cut()}")
    
    # Weakly connected
    weak = CausalMechanism([
        [0, 1, 0.001, 0], [1, 0, 0, 0],
        [0, 0, 0, 1], [0, 0.001, 1, 0]
    ])
    print(f"  Weakly connected:         Φ = {weak.phi():.4f}, "
          f"disconnected = {weak.has_zero_cut()}")


def demo_scaling() -> None:
    """Demonstrate linear scaling: Φ(c·M) = c·Φ(M)."""
    print_header("Theorem: Linear Scaling — Φ(c·M) = c·Φ(M)")
    
    m = CausalMechanism.complete(4, w=1.0)
    for c in [0.5, 1.0, 2.0, 3.14, 10.0]:
        result = verify_scaling(c, m)
        print(f"  c = {c:5.2f}: Φ(M) = {result['phi_m']:.1f}, "
              f"c·Φ = {result['c_times_phi']:.2f}, "
              f"Φ(c·M) = {result['phi_scaled']:.2f}, "
              f"match = {result['matches']}")


def demo_defect() -> None:
    """Demonstrate integration defect subadditivity."""
    print_header("Theorem: Defect Subadditivity — D(M₁+M₂) ≤ D(M₁) + D(M₂)")
    
    m1 = CausalMechanism.path(5, w=2.0)
    m2 = CausalMechanism.cycle(5, w=1.0)
    
    result = verify_defect_subadditivity(m1, m2)
    print(f"\n  Path(5, w=2) + Cycle(5, w=1):")
    print(f"    D(M₁) = {result['defect_m1']:.2f}")
    print(f"    D(M₂) = {result['defect_m2']:.2f}")
    print(f"    D(M₁) + D(M₂) = {result['defect_sum']:.2f}")
    print(f"    D(M₁ + M₂) = {result['defect_combined']:.2f}")
    print(f"    Subadditive: {result['subadditive']} "
          f"(savings = {result['savings']:.2f})")


def demo_exclusion() -> None:
    """Demonstrate the exclusion principle."""
    print_header("Theorem: Exclusion — Maximum Φ Exists Among Mechanisms")
    
    mechanisms = [
        CausalMechanism.path(4),
        CausalMechanism.cycle(4),
        CausalMechanism.complete(4),
        CausalMechanism.complete(4, w=0.5),
    ]
    names = ["Path(4)", "Cycle(4)", "Complete(4,w=1)", "Complete(4,w=0.5)"]
    
    for name, m in zip(names, mechanisms):
        print(f"  {name:20s}: Φ = {m.phi():.1f}")
    
    idx, max_phi = find_exclusion_maximum(mechanisms)
    print(f"\n  Maximum Φ = {max_phi:.1f} achieved by: {names[idx]}")
    print(f"  (The 'conscious' grain of description)")


def demo_profile() -> None:
    """Show complete integration profile for an interesting mechanism."""
    print_header("Integration Profile: Brain-like Architecture")
    
    # Simulate a small brain-like network:
    # - 6 neurons in 2 clusters of 3
    # - Strong within-cluster connections (weight 3)
    # - Moderate between-cluster connections (weight 1)
    brain = CausalMechanism([
        [0, 3, 3, 1, 0, 0],
        [3, 0, 3, 0, 1, 0],
        [3, 3, 0, 0, 0, 1],
        [1, 0, 0, 0, 3, 3],
        [0, 1, 0, 3, 0, 3],
        [0, 0, 1, 3, 3, 0],
    ])
    
    profile = integration_profile(brain)
    print(f"\n  States: {profile['n_states']}")
    print(f"  Total weight: {profile['total_weight']:.0f}")
    print(f"  Φ (integrated information): {profile['phi']:.1f}")
    print(f"  Minimizing partition: {profile['minimizing_partition']} | "
          f"{profile['complement']}")
    print(f"  Integration defect: {profile['integration_defect']:.1f}")
    print(f"  Efficiency (Φ/W): {profile['efficiency']:.3f}")
    print(f"  Symmetric: {profile['is_symmetric']}")
    print(f"  Disconnected: {profile['is_disconnected']}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Integrated Information Theory — Algebraic Foundations  ║")
    print("║  23 Theorems Formally Verified in Lean 4                ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_basic_examples()
    demo_superadditivity()
    demo_disconnection()
    demo_scaling()
    demo_defect()
    demo_exclusion()
    demo_profile()
    
    print(f"\n{'='*60}")
    print("  All demonstrations complete.")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Integration Landscape

Shows how Φ varies across graph types and sizes, demonstrating
the key algebraic properties (superadditivity, scaling, efficiency).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def cut_weight(weights, subset):
    n = len(weights)
    complement = set(range(n)) - subset
    fw = sum(weights[i][j] for i in subset for j in complement)
    bw = sum(weights[i][j] for i in complement for j in subset)
    return fw + bw


def phi(weights):
    n = len(weights)
    if n < 2:
        return 0.0
    best = float('inf')
    for size in range(1, n):
        for combo in combinations(range(n), size):
            cw = cut_weight(weights, set(combo))
            best = min(best, cw)
    return best


def total_weight(weights):
    return sum(weights[i][j] for i in range(len(weights)) for j in range(len(weights)))


def complete_graph(n, w=1.0):
    return [[w if i != j else 0.0 for j in range(n)] for i in range(n)]


def path_graph(n, w=1.0):
    g = [[0.0]*n for _ in range(n)]
    for i in range(n-1):
        g[i][i+1] = w; g[i+1][i] = w
    return g


def cycle_graph(n, w=1.0):
    g = path_graph(n, w)
    if n >= 3:
        g[0][n-1] = w; g[n-1][0] = w
    return g


def star_graph(n, w=1.0):
    g = [[0.0]*n for _ in range(n)]
    for i in range(1, n):
        g[0][i] = w; g[i][0] = w
    return g


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Integrated Information Theory: Algebraic Properties of Φ',
             fontsize=16, fontweight='bold')

# Plot 1: Phi vs n for different graph types
ax = axes[0, 0]
ns = range(2, 9)
for graph_fn, label, marker in [
    (complete_graph, 'Complete', 'o'),
    (cycle_graph, 'Cycle', 's'),
    (path_graph, 'Path', '^'),
    (star_graph, 'Star', 'D'),
]:
    phis = [phi(graph_fn(n)) for n in ns]
    ax.plot(list(ns), phis, f'-{marker}', label=label, markersize=8, linewidth=2)
ax.set_xlabel('Number of states (n)', fontsize=12)
ax.set_ylabel('Φ (integrated information)', fontsize=12)
ax.set_title('Integration vs System Size', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Efficiency Φ/W vs n
ax = axes[0, 1]
for graph_fn, label, marker in [
    (complete_graph, 'Complete', 'o'),
    (cycle_graph, 'Cycle', 's'),
    (path_graph, 'Path', '^'),
    (star_graph, 'Star', 'D'),
]:
    effs = []
    for n in ns:
        g = graph_fn(n)
        w = total_weight(g)
        effs.append(phi(g) / w if w > 0 else 0)
    ax.plot(list(ns), effs, f'-{marker}', label=label, markersize=8, linewidth=2)
ax.set_xlabel('Number of states (n)', fontsize=12)
ax.set_ylabel('Efficiency Φ/W', fontsize=12)
ax.set_title('Integration Efficiency vs Size', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Superadditivity demonstration
ax = axes[1, 0]
ns_super = range(3, 8)
excesses = []
phi_sums = []
phi_combineds = []
for n in ns_super:
    m1 = path_graph(n, 1.0)
    m2 = cycle_graph(n, 1.0)
    combined = [[m1[i][j] + m2[i][j] for j in range(n)] for i in range(n)]
    p1, p2, pc = phi(m1), phi(m2), phi(combined)
    phi_sums.append(p1 + p2)
    phi_combineds.append(pc)
    excesses.append(pc - (p1 + p2))

x = np.arange(len(list(ns_super)))
width = 0.35
bars1 = ax.bar(x - width/2, phi_sums, width, label='Φ(M₁) + Φ(M₂)',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x + width/2, phi_combineds, width, label='Φ(M₁ + M₂)',
               color='coral', alpha=0.8)
ax.set_xlabel('Number of states', fontsize=12)
ax.set_ylabel('Integration value', fontsize=12)
ax.set_title('Superadditivity: Φ(M₁+M₂) ≥ Φ(M₁)+Φ(M₂)', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels([str(n) for n in ns_super])
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Plot 4: Scaling
ax = axes[1, 1]
base = complete_graph(4, 1.0)
base_phi = phi(base)
cs = np.linspace(0, 5, 20)
scaled_phis = [phi(complete_graph(4, c)) for c in cs]
theoretical = [c * base_phi for c in cs]
ax.plot(cs, scaled_phis, 'o', color='coral', markersize=8, label='Φ(c·M) computed',
        alpha=0.8)
ax.plot(cs, theoretical, '-', color='steelblue', linewidth=2, label='c·Φ(M) predicted')
ax.set_xlabel('Scale factor c', fontsize=12)
ax.set_ylabel('Integrated information', fontsize=12)
ax.set_title('Linear Scaling: Φ(c·M) = c·Φ(M)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phi_landscape.png', dpi=150, bbox_inches='tight')
print("Saved phi_landscape.png")
