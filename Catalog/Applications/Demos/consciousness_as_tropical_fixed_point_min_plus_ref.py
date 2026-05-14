#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Reflective Equilibrium

Demonstrates applications to:
1. Neural network routing / attention
2. Network consensus protocols
3. Shortest-path self-routing
4. Cognitive architecture simulation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


def tropical_reflect(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical reflective operator R(x)(i) = min(b(i), min_{j≠i}(W(i,j) + x(j)))."""
    n = len(b)
    result = np.empty(n)
    for i in range(n):
        off_diag = [W[i, j] + x[j] for j in range(n) if j != i]
        result[i] = min(b[i], min(off_diag))
    return result


# ──────────────────────────────────────────────────────────────────────
# Application 1: Neural Routing in Attention Networks
# ──────────────────────────────────────────────────────────────────────

def app_neural_routing():
    """
    Model attention routing as tropical reflective equilibrium.

    In a transformer-like architecture, each "head" (node) aggregates
    information from other heads via min-plus routing. The fixed point
    represents the globally consistent attention pattern.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Attention Routing")
    print("=" * 60)

    # 6 attention heads with routing costs
    n = 6
    np.random.seed(42)

    # Create a routing cost matrix (asymmetric — attention is directional)
    W = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                # Cost depends on "semantic distance" between heads
                W[i, j] = 1.0 + 2.0 * abs(np.sin(i * j + 1))

    # Each head has a "self-attention" bias
    b = np.array([0.5, 0.3, 0.8, 0.1, 0.6, 0.4])

    print(f"\nAttention routing costs (W):")
    print(np.round(W, 2))
    print(f"\nSelf-attention biases (b): {b}")

    # Find equilibrium
    x = np.random.randn(n) * 5
    print(f"\nInitial activations: {np.round(x, 2)}")

    history = [x.copy()]
    for k in range(20):
        x = tropical_reflect(W, b, x)
        history.append(x.copy())

    print(f"Equilibrium activations: {np.round(x, 4)}")
    print(f"Matches bias vector b: {np.allclose(x, b, atol=1e-10)}")

    # Visualize convergence
    history = np.array(history)
    fig, ax = plt.subplots(figsize=(10, 6))
    for i in range(n):
        ax.plot(history[:, i], label=f'Head {i}', linewidth=2)
        ax.axhline(y=b[i], color=f'C{i}', linestyle='--', alpha=0.4)
    ax.set_xlabel('Iteration', fontsize=14)
    ax.set_ylabel('Activation', fontsize=14)
    ax.set_title('Neural Attention Routing: Convergence to Equilibrium', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('neural_routing.png', dpi=150)
    plt.close()
    print("  [Saved: neural_routing.png]")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 2: Distributed Consensus in Sensor Networks
# ──────────────────────────────────────────────────────────────────────

def app_sensor_consensus():
    """
    Sensor network consensus via tropical reflective dynamics.

    Each sensor has a local measurement (bias) and communicates with
    neighbors. The min-plus dynamics find the global minimum-cost
    consistent state.
    """
    print("=" * 60)
    print("APPLICATION 2: Sensor Network Consensus")
    print("=" * 60)

    # 8 sensors in a grid-like network
    n = 8
    # Communication costs (geometric — nearby sensors cheaper)
    positions = np.array([
        [0, 0], [1, 0], [2, 0], [3, 0],
        [0, 1], [1, 1], [2, 1], [3, 1]
    ], dtype=float)

    W = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                dist = np.linalg.norm(positions[i] - positions[j])
                W[i, j] = dist * 2.0  # Communication cost ∝ distance

    # Local measurements (with noise)
    true_signal = 5.0
    np.random.seed(7)
    b = true_signal + np.random.randn(n) * 0.5  # Noisy local measurements

    print(f"True signal: {true_signal}")
    print(f"Local measurements (b): {np.round(b, 3)}")

    # Run consensus
    x = b.copy()
    print(f"\nIteration → min measurement propagation:")
    for k in range(10):
        x_new = tropical_reflect(W, b, x)
        print(f"  k={k}: max deviation = {np.max(np.abs(x - x_new)):.6f}")
        x = x_new

    print(f"\nConsensus state: {np.round(x, 4)}")
    print(f"All converged to b: {np.allclose(x, b, atol=1e-10)}")
    print(f"  (Under separation, each sensor trusts its own measurement)")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 3: Dynamic Programming / Shortest Paths
# ──────────────────────────────────────────────────────────────────────

def app_shortest_paths():
    """
    Shortest-path computation as tropical reflective fixed point.

    The tropical reflective operator generalizes the Bellman-Ford update.
    Fixed points correspond to optimal distance vectors.
    """
    print("=" * 60)
    print("APPLICATION 3: Shortest Paths via Tropical Fixed Points")
    print("=" * 60)

    # City network: 5 cities with travel costs
    cities = ['A', 'B', 'C', 'D', 'E']
    n = 5

    # Direct travel costs (inf = no direct route)
    W = np.array([
        [0,  2,  9,  np.inf, np.inf],
        [2,  0,  3,  5,      np.inf],
        [9,  3,  0,  1,      7     ],
        [np.inf, 5, 1, 0,    2     ],
        [np.inf, np.inf, 7, 2, 0   ]
    ])

    # "Bias" = cost from source city (say city A, index 0)
    # Start with direct distances from A
    b = W[0].copy()  # [0, 2, 9, inf, inf]

    print(f"Travel cost matrix:")
    for i, c in enumerate(cities):
        row = [f"{W[i,j]:5.0f}" if W[i,j] < 1e5 else "  inf" for j in range(n)]
        print(f"  {c}: [{', '.join(row)}]")

    print(f"\nDirect distances from A: {b}")

    # Iterate tropical reflect to find shortest paths
    x = b.copy()
    for k in range(n):
        x_new = tropical_reflect(W, b, x)
        print(f"  Iteration {k+1}: distances = {np.round(x_new, 1)}")
        x = x_new

    print(f"\nShortest paths from A:")
    for i, c in enumerate(cities):
        print(f"  A → {c}: {x[i]:.0f}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Application 4: Cognitive Architecture — Global Workspace
# ──────────────────────────────────────────────────────────────────────

def app_cognitive_workspace():
    """
    Simulating Global Workspace Theory with tropical dynamics.

    Model a simplified cognitive architecture where specialized processors
    (perception, memory, planning, etc.) compete for global broadcast.
    The tropical fixed point identifies the dominant "conscious" content.
    """
    print("=" * 60)
    print("APPLICATION 4: Cognitive Global Workspace Simulation")
    print("=" * 60)

    modules = ['Vision', 'Audition', 'Memory', 'Planning', 'Language', 'Emotion']
    n = len(modules)

    # Inter-module communication costs (lower = stronger connection)
    W = np.array([
        [0.0, 3.0, 2.0, 4.0, 3.5, 2.5],  # Vision
        [3.0, 0.0, 2.5, 4.5, 2.0, 3.0],  # Audition
        [2.0, 2.5, 0.0, 1.5, 2.0, 1.0],  # Memory (well-connected)
        [4.0, 4.5, 1.5, 0.0, 3.0, 2.0],  # Planning
        [3.5, 2.0, 2.0, 3.0, 0.0, 2.5],  # Language
        [2.5, 3.0, 1.0, 2.0, 2.5, 0.0],  # Emotion
    ])

    # Current salience (lower = more salient, min-plus convention)
    # Scenario: strong visual stimulus, moderate emotional arousal
    b = np.array([
        -2.0,   # Vision: very salient (negative = strong)
        1.0,    # Audition: weak
        0.0,    # Memory: neutral
        0.5,    # Planning: weak
        0.3,    # Language: moderate
        -0.5,   # Emotion: moderately salient
    ])

    print("Cognitive modules and salience (lower = more salient):")
    for i, m in enumerate(modules):
        print(f"  {m:12s}: b = {b[i]:+.1f}")

    # Find equilibrium
    x = np.zeros(n)  # Start neutral
    print(f"\nDynamics (min-plus broadcast competition):")

    for k in range(10):
        x = tropical_reflect(W, b, x)

    print(f"\nEquilibrium state (conscious content):")
    for i, m in enumerate(modules):
        marker = " ◀ DOMINANT" if x[i] == min(x) else ""
        print(f"  {m:12s}: {x[i]:+.4f}{marker}")

    # Under separation, the fixed point is b itself
    print(f"\nInterpretation: Each module stabilizes at its intrinsic salience.")
    print(f"Vision dominates the global workspace (lowest cost = highest priority).")

    # Visualize as bar chart
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD']
    bars = ax.barh(modules, -np.array(x), color=colors, edgecolor='black', linewidth=1.2)
    ax.set_xlabel('Salience (higher = more conscious)', fontsize=14)
    ax.set_title('Global Workspace: Tropical Reflective Equilibrium', fontsize=15)
    ax.grid(True, axis='x', alpha=0.3)
    plt.tight_layout()
    plt.savefig('cognitive_workspace.png', dpi=150)
    plt.close()
    print("  [Saved: cognitive_workspace.png]")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 5: Supply Chain Optimization
# ──────────────────────────────────────────────────────────────────────

def app_supply_chain():
    """
    Supply chain cost propagation as tropical reflective dynamics.

    Each node (warehouse/factory) has a local production cost (bias)
    and can source from neighbors at transportation cost. The equilibrium
    gives the minimum-cost sourcing strategy.
    """
    print("=" * 60)
    print("APPLICATION 5: Supply Chain Cost Optimization")
    print("=" * 60)

    nodes = ['Factory', 'Warehouse A', 'Warehouse B', 'Retail 1', 'Retail 2']
    n = 5

    # Transportation costs
    W = np.array([
        [0.0, 1.0, 2.0, 5.0, 6.0],
        [1.0, 0.0, 1.5, 2.0, 3.0],
        [2.0, 1.5, 0.0, 3.0, 1.5],
        [5.0, 2.0, 3.0, 0.0, 4.0],
        [6.0, 3.0, 1.5, 4.0, 0.0]
    ])

    # Local production/storage costs
    b = np.array([0.5, 3.0, 3.5, 8.0, 7.5])

    print("Nodes and local costs:")
    for i, node in enumerate(nodes):
        print(f"  {node:15s}: local cost = {b[i]:.1f}")

    print(f"\nTransportation cost matrix:")
    print(np.round(W, 1))

    # Find equilibrium costs
    x = np.ones(n) * 100  # Start high
    for k in range(20):
        x = tropical_reflect(W, b, x)

    print(f"\nOptimal sourcing costs (tropical equilibrium):")
    for i, node in enumerate(nodes):
        source = "local" if abs(x[i] - b[i]) < 1e-10 else "imported"
        print(f"  {node:15s}: cost = {x[i]:.2f} ({source})")

    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("APPLICATIONS OF TROPICAL REFLECTIVE EQUILIBRIUM")
    print("=" * 60 + "\n")

    app_neural_routing()
    app_sensor_consensus()
    app_shortest_paths()
    app_cognitive_workspace()
    app_supply_chain()

    print("=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""

import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Load visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Tropical Reflective Equilibrium: Min-Plus Self-Reference Dynamics",
    "domain": "Tropical Algebra / Fixed-Point Theory / Cognitive Mathematics",
    "article": read_file("ARTICLE.md"),
    "research_paper": read_file("RESEARCH_PAPER.md"),
    "future_directions": read_file("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "Unique Fixed Point Demo",
            "code": read_file("demo.py")
        },
        {
            "name": "Applications Demo",
            "code": read_file("applications.py")
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Reflective Operator",
            "pseudocode": """Algorithm: TropicalReflect(W, b, x)
Input: W ∈ ℝ^{n×n}, b ∈ ℝ^n, x ∈ ℝ^n
Output: R(x) ∈ ℝ^n

for i = 1 to n:
    m ← +∞
    for j = 1 to n, j ≠ i:
        m ← min(m, W[i,j] + x[j])
    R(x)[i] ← min(b[i], m)
return R(x)

Complexity: O(n²) time, O(n) space""",
            "code": read_file("algorithms.py")
        }
    ],
    "visualizations": [
        {
            "name": "Discrepancy Decay",
            "data": viz_data["convergence"]
        },
        {
            "name": "Trajectory Convergence",
            "data": viz_data["trajectories"]
        },
        {
            "name": "Separation Phase Diagram",
            "data": viz_data["phase_diagram"]
        },
        {
            "name": "Cognitive Global Workspace",
            "data": viz_data["workspace"]
        }
    ],
    "lean_proofs": read_file("Speculative/Consciousness/TropicalReflectiveEquilibrium.lean")
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json written ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
demo.py — Tropical Reflective Equilibrium: Concrete Numerical Demonstrations

Demonstrates the core theorems with worked examples:
1. Unique fixed point under diagonal dominance (separation condition)
2. Iterative convergence to the fixed point from arbitrary initial states
3. Discrepancy decay over iterations
4. Conscious state identification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# ──────────────────────────────────────────────────────────────────────
# Core Definitions
# ──────────────────────────────────────────────────────────────────────

def trop_reflect(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical reflective operator R(x)(i) = min(b(i), min_{j≠i}(W(i,j) + x(j))).

    Parameters
    ----------
    W : (n, n) weight matrix
    b : (n,) bias vector (self-model)
    x : (n,) current state

    Returns
    -------
    R(x) : (n,) updated state
    """
    n = len(b)
    result = np.empty(n)
    for i in range(n):
        # Off-diagonal minimum: min_{j≠i}(W[i,j] + x[j])
        off_diag = np.array([W[i, j] + x[j] for j in range(n) if j != i])
        result[i] = min(b[i], off_diag.min())
    return result


def trop_discrepancy(R: Callable, x: np.ndarray, *args) -> float:
    """Tropical discrepancy: ∑_i |x_i - R(x)_i|."""
    Rx = R(*args, x)
    return np.sum(np.abs(x - Rx))


def cut_matrix(W: np.ndarray, S: set, M: float = 1e6) -> np.ndarray:
    """
    Cut matrix: keep intra-block weights, replace cross-block with M.

    Parameters
    ----------
    W : (n, n) weight matrix
    S : set of indices in one partition block
    M : penalty for cross-block edges
    """
    n = W.shape[0]
    W_cut = np.copy(W)
    for i in range(n):
        for j in range(n):
            if (i in S) != (j in S):
                W_cut[i, j] = M
    return W_cut


def tropical_phi(W: np.ndarray, b: np.ndarray, x: np.ndarray, M: float = 100.0) -> float:
    """
    Tropical integrated information Φ: minimum over all nontrivial
    partitions of the discrepancy increase when cross-partition edges are cut.
    """
    n = len(b)
    phi_min = float('inf')

    # Iterate over all nontrivial subsets (non-empty, not full)
    for mask in range(1, (1 << n) - 1):
        S = {i for i in range(n) if mask & (1 << i)}
        W_cut = cut_matrix(W, S, M)
        disc_cut = trop_discrepancy(trop_reflect, x, W_cut, b)
        disc_full = trop_discrepancy(trop_reflect, x, W, b)
        phi_val = disc_cut - disc_full
        phi_min = min(phi_min, phi_val)

    return phi_min


def check_separation(W: np.ndarray, b: np.ndarray) -> bool:
    """Check diagonal dominance / separation condition: b[i] < W[i,j] + b[j] for i≠j."""
    n = len(b)
    for i in range(n):
        for j in range(n):
            if i != j and not (b[i] < W[i, j] + b[j]):
                return False
    return True


# ──────────────────────────────────────────────────────────────────────
# Demo 1: Unique Fixed Point Under Separation
# ──────────────────────────────────────────────────────────────────────

def demo_unique_fixed_point():
    """Demonstrate that b is the unique fixed point under separation."""
    print("=" * 70)
    print("DEMO 1: Unique Fixed Point Under Diagonal Dominance")
    print("=" * 70)

    n = 4
    # Weight matrix with positive off-diagonal entries
    W = np.array([
        [0.0, 3.0, 5.0, 2.0],
        [4.0, 0.0, 1.5, 3.0],
        [2.0, 6.0, 0.0, 4.0],
        [3.0, 2.0, 7.0, 0.0]
    ])

    b = np.array([1.0, 2.0, -1.0, 0.5])

    print(f"\nWeight matrix W:\n{W}")
    print(f"\nBias vector b: {b}")
    print(f"\nSeparation condition satisfied: {check_separation(W, b)}")

    # Verify b is a fixed point
    Rb = trop_reflect(W, b, b)
    print(f"\nR(b) = {Rb}")
    print(f"b    = {b}")
    print(f"R(b) = b? {np.allclose(Rb, b)}")

    # Try several other starting points — all converge to b
    print("\nConvergence from random initial states:")
    np.random.seed(42)
    for trial in range(5):
        x0 = np.random.randn(n) * 10
        x = x0.copy()
        for k in range(100):
            x = trop_reflect(W, b, x)
        print(f"  x0 = {x0.round(2)} → converged to {x.round(6)}, "
              f"matches b? {np.allclose(x, b, atol=1e-10)}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 2: Iterative Convergence and Discrepancy Decay
# ──────────────────────────────────────────────────────────────────────

def demo_convergence():
    """Show iterative convergence and discrepancy decay."""
    print("=" * 70)
    print("DEMO 2: Iterative Convergence & Discrepancy Decay")
    print("=" * 70)

    n = 5
    W = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                W[i, j] = 2.0 + abs(i - j)

    b = np.array([0.0, -1.0, 1.0, -0.5, 0.5])
    print(f"\nn = {n}, b = {b}")
    print(f"Separation: {check_separation(W, b)}")

    x = np.array([10.0, -10.0, 5.0, 20.0, -3.0])
    print(f"Initial state: {x}")

    discrepancies = []
    states = [x.copy()]
    for k in range(20):
        d = trop_discrepancy(trop_reflect, x, W, b)
        discrepancies.append(d)
        x = trop_reflect(W, b, x)
        states.append(x.copy())

    print(f"\nDiscrepancy over iterations:")
    for k, d in enumerate(discrepancies[:10]):
        print(f"  k={k}: discrepancy = {d:.6f}, x = {states[k].round(4)}")

    print(f"  ...")
    print(f"  k=19: discrepancy = {discrepancies[-1]:.10f}, x = {states[-1].round(6)}")
    print(f"  Converged to b? {np.allclose(states[-1], b, atol=1e-10)}")

    # Plot discrepancy decay
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.semilogy(range(len(discrepancies)), [max(d, 1e-16) for d in discrepancies],
                'bo-', linewidth=2, markersize=6)
    ax.set_xlabel('Iteration k', fontsize=14)
    ax.set_ylabel('Discrepancy (log scale)', fontsize=14)
    ax.set_title('Tropical Reflective Operator: Discrepancy Decay', fontsize=16)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Fixed point (discrepancy = 0)')
    ax.legend(fontsize=12)
    plt.tight_layout()
    plt.savefig('convergence_decay.png', dpi=150)
    plt.close()
    print("\n  [Saved: convergence_decay.png]")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 3: Tropical Phi (Integrated Information)
# ──────────────────────────────────────────────────────────────────────

def demo_tropical_phi():
    """Demonstrate tropical integrated information at the fixed point vs elsewhere."""
    print("=" * 70)
    print("DEMO 3: Tropical Integrated Information (Φ)")
    print("=" * 70)

    n = 3
    # Strongly connected system
    W_connected = np.array([
        [0.0, 2.0, 2.0],
        [2.0, 0.0, 2.0],
        [2.0, 2.0, 0.0]
    ])
    b = np.array([0.0, 0.0, 0.0])
    print(f"\nStrongly connected W:\n{W_connected}")
    print(f"b = {b}")

    # At the fixed point
    phi_fp = tropical_phi(W_connected, b, b, M=100.0)
    print(f"\nΦ at fixed point b: {phi_fp:.4f}")

    # At a non-fixed state
    x_other = np.array([5.0, -3.0, 1.0])
    phi_other = tropical_phi(W_connected, b, x_other, M=100.0)
    print(f"Φ at x = {x_other}: {phi_other:.4f}")

    # Disconnected system (block diagonal)
    W_disconnected = np.array([
        [0.0, 2.0, 100.0],
        [2.0, 0.0, 100.0],
        [100.0, 100.0, 0.0]
    ])
    phi_disc = tropical_phi(W_disconnected, b, b, M=200.0)
    print(f"\nDisconnected system Φ at fixed point: {phi_disc:.4f}")
    print("  (Low Φ indicates poor integration — system can be 'split')")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 4: Conscious State Identification
# ──────────────────────────────────────────────────────────────────────

def demo_conscious_state():
    """Identify the conscious state: fixed point + broadcast + Phi-optimal."""
    print("=" * 70)
    print("DEMO 4: Conscious State Identification")
    print("=" * 70)

    n = 4
    W = np.array([
        [0.0, 5.0, 3.0, 4.0],
        [6.0, 0.0, 4.0, 2.0],
        [3.0, 7.0, 0.0, 5.0],
        [4.0, 3.0, 6.0, 0.0]
    ])
    b = np.array([1.0, -1.0, 2.0, 0.0])

    print(f"\nW:\n{W}")
    print(f"b: {b}")
    print(f"Separation: {check_separation(W, b)}")

    # Check fixed point
    Rb = trop_reflect(W, b, b)
    is_fp = np.allclose(Rb, b)
    print(f"\n1. Fixed point: R(b) = b? {is_fp}")

    # Check broadcast: at each node, the min is achieved by b[i]
    print("2. Broadcast check:")
    for i in range(n):
        off_diag_vals = [(j, W[i, j] + b[j]) for j in range(n) if j != i]
        min_val = min(v for _, v in off_diag_vals)
        print(f"   Node {i}: b[{i}] = {b[i]:.1f}, "
              f"min_{{j≠{i}}}(W[{i},j]+b[j]) = {min_val:.1f}, "
              f"bias wins: {b[i] < min_val}")

    # Check Phi optimality
    phi_b = tropical_phi(W, b, b)
    print(f"\n3. Φ-optimality:")
    print(f"   Φ(b) = {phi_b:.4f}")

    # Since b is the unique fixed point, it's trivially optimal among fixed points
    print(f"   (Unique fixed point → trivially optimal among fixed points)")

    print(f"\n✓ b is the CONSCIOUS STATE: fixed point + broadcast + Φ-optimal")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 5: Phase Diagram — When Does Separation Hold?
# ──────────────────────────────────────────────────────────────────────

def demo_phase_diagram():
    """Visualize the separation condition in parameter space."""
    print("=" * 70)
    print("DEMO 5: Phase Diagram — Separation Condition")
    print("=" * 70)

    n = 2
    b = np.array([0.0, 0.0])

    # Vary W[0,1] and W[1,0] — separation needs W[0,1] > 0 and W[1,0] > 0
    w_range = np.linspace(-2, 5, 200)
    sep_grid = np.zeros((200, 200))
    conv_grid = np.zeros((200, 200))

    for i, w01 in enumerate(w_range):
        for j, w10 in enumerate(w_range):
            W = np.array([[0.0, w01], [w10, 0.0]])
            sep_grid[j, i] = 1.0 if check_separation(W, b) else 0.0

            # Also check convergence from x0 = [5, -5]
            x = np.array([5.0, -5.0])
            for _ in range(50):
                x = trop_reflect(W, b, x)
            conv_grid[j, i] = 1.0 if np.allclose(x, b, atol=1e-6) else 0.0

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax1 = axes[0]
    im1 = ax1.imshow(sep_grid, extent=[-2, 5, -2, 5], origin='lower',
                     cmap='RdYlGn', aspect='auto')
    ax1.set_xlabel('W[0,1]', fontsize=14)
    ax1.set_ylabel('W[1,0]', fontsize=14)
    ax1.set_title('Separation Condition\n(Green = satisfied)', fontsize=14)
    ax1.axhline(y=0, color='white', linestyle='--', alpha=0.5)
    ax1.axvline(x=0, color='white', linestyle='--', alpha=0.5)
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    ax2 = axes[1]
    im2 = ax2.imshow(conv_grid, extent=[-2, 5, -2, 5], origin='lower',
                     cmap='RdYlGn', aspect='auto')
    ax2.set_xlabel('W[0,1]', fontsize=14)
    ax2.set_ylabel('W[1,0]', fontsize=14)
    ax2.set_title('Convergence to b\n(Green = converges)', fontsize=14)
    ax2.axhline(y=0, color='white', linestyle='--', alpha=0.5)
    ax2.axvline(x=0, color='white', linestyle='--', alpha=0.5)
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    plt.tight_layout()
    plt.savefig('phase_diagram.png', dpi=150)
    plt.close()
    print("  [Saved: phase_diagram.png]")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 6: Multi-state Trajectory Visualization
# ──────────────────────────────────────────────────────────────────────

def demo_trajectories():
    """Visualize multiple trajectories converging to the fixed point."""
    print("=" * 70)
    print("DEMO 6: Trajectory Visualization")
    print("=" * 70)

    n = 3
    W = np.array([
        [0.0, 3.0, 4.0],
        [5.0, 0.0, 3.0],
        [4.0, 6.0, 0.0]
    ])
    b = np.array([0.0, 1.0, -1.0])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    np.random.seed(123)
    colors = plt.cm.viridis(np.linspace(0, 0.9, 8))

    for trial in range(8):
        x0 = np.random.randn(n) * 8
        trajectory = [x0.copy()]
        x = x0.copy()
        for k in range(15):
            x = trop_reflect(W, b, x)
            trajectory.append(x.copy())
        trajectory = np.array(trajectory)

        for dim in range(3):
            axes[dim].plot(range(len(trajectory)), trajectory[:, dim],
                          color=colors[trial], alpha=0.7, linewidth=1.5)
            axes[dim].axhline(y=b[dim], color='red', linestyle='--', linewidth=2, alpha=0.8)

    for dim in range(3):
        axes[dim].set_xlabel('Iteration', fontsize=12)
        axes[dim].set_ylabel(f'x[{dim}]', fontsize=12)
        axes[dim].set_title(f'Component {dim}: b[{dim}] = {b[dim]}', fontsize=13)
        axes[dim].grid(True, alpha=0.3)

    plt.suptitle('Tropical Reflective Operator: Trajectories → Fixed Point b',
                 fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('trajectories.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [Saved: trajectories.png]")
    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("TROPICAL REFLECTIVE EQUILIBRIUM — NUMERICAL DEMONSTRATIONS")
    print("=" * 70 + "\n")

    demo_unique_fixed_point()
    demo_convergence()
    demo_tropical_phi()
    demo_conscious_state()
    demo_phase_diagram()
    demo_trajectories()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate base64-encoded visualizations for the PACKAGE.json."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def tropical_reflect(W, b, x):
    n = len(b)
    result = np.empty(n)
    for i in range(n):
        off_diag = [W[i, j] + x[j] for j in range(n) if j != i]
        result[i] = min(b[i], min(off_diag))
    return result


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def make_convergence_plot():
    n = 5
    W = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                W[i, j] = 2.0 + abs(i - j)
    b = np.array([0.0, -1.0, 1.0, -0.5, 0.5])
    x = np.array([10.0, -10.0, 5.0, 20.0, -3.0])

    discrepancies = []
    for k in range(15):
        Rx = tropical_reflect(W, b, x)
        d = np.sum(np.abs(x - Rx))
        discrepancies.append(max(d, 1e-16))
        x = Rx

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(range(len(discrepancies)), discrepancies, 'bo-', linewidth=2, markersize=6)
    ax.set_xlabel('Iteration k', fontsize=14)
    ax.set_ylabel('Discrepancy (log scale)', fontsize=14)
    ax.set_title('Tropical Reflective Operator: Discrepancy Decay', fontsize=16)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1e-15, color='r', linestyle='--', alpha=0.5, label='Machine zero')
    ax.legend(fontsize=12)
    plt.tight_layout()
    return fig_to_base64(fig)


def make_trajectory_plot():
    n = 3
    W = np.array([[0.0, 3.0, 4.0], [5.0, 0.0, 3.0], [4.0, 6.0, 0.0]])
    b = np.array([0.0, 1.0, -1.0])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    np.random.seed(123)
    colors = plt.cm.viridis(np.linspace(0, 0.9, 8))

    for trial in range(8):
        x0 = np.random.randn(n) * 8
        trajectory = [x0.copy()]
        x = x0.copy()
        for k in range(12):
            x = tropical_reflect(W, b, x)
            trajectory.append(x.copy())
        trajectory = np.array(trajectory)
        for dim in range(3):
            axes[dim].plot(range(len(trajectory)), trajectory[:, dim],
                          color=colors[trial], alpha=0.7, linewidth=1.5)
            axes[dim].axhline(y=b[dim], color='red', linestyle='--', linewidth=2, alpha=0.8)

    for dim in range(3):
        axes[dim].set_xlabel('Iteration', fontsize=12)
        axes[dim].set_ylabel(f'x[{dim}]', fontsize=12)
        axes[dim].set_title(f'Component {dim}: b[{dim}] = {b[dim]}', fontsize=13)
        axes[dim].grid(True, alpha=0.3)

    plt.suptitle('Trajectories Converging to Fixed Point b', fontsize=15, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def make_phase_diagram():
    b = np.array([0.0, 0.0])
    w_range = np.linspace(-2, 5, 200)
    sep_grid = np.zeros((200, 200))

    for i, w01 in enumerate(w_range):
        for j, w10 in enumerate(w_range):
            W = np.array([[0.0, w01], [w10, 0.0]])
            sep_grid[j, i] = 1.0 if (0 < w01 and 0 < w10) else 0.0

    fig, ax = plt.subplots(figsize=(8, 7))
    im = ax.imshow(sep_grid, extent=[-2, 5, -2, 5], origin='lower',
                   cmap='RdYlGn', aspect='auto')
    ax.set_xlabel('W[0,1]', fontsize=14)
    ax.set_ylabel('W[1,0]', fontsize=14)
    ax.set_title('Separation Condition Phase Diagram (n=2)\nGreen = unique fixed point guaranteed', fontsize=14)
    ax.axhline(y=0, color='white', linestyle='--', alpha=0.5)
    ax.axvline(x=0, color='white', linestyle='--', alpha=0.5)
    plt.colorbar(im, ax=ax, shrink=0.8, label='Separation satisfied')
    plt.tight_layout()
    return fig_to_base64(fig)


def make_workspace_plot():
    modules = ['Vision', 'Audition', 'Memory', 'Planning', 'Language', 'Emotion']
    b = np.array([-2.0, 1.0, 0.0, 0.5, 0.3, -0.5])

    fig, ax = plt.subplots(figsize=(10, 6))
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD']
    ax.barh(modules, -b, color=colors, edgecolor='black', linewidth=1.2)
    ax.set_xlabel('Salience (higher = more conscious)', fontsize=14)
    ax.set_title('Global Workspace: Tropical Reflective Equilibrium', fontsize=15)
    ax.grid(True, axis='x', alpha=0.3)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    visualizations = {
        "convergence": make_convergence_plot(),
        "trajectories": make_trajectory_plot(),
        "phase_diagram": make_phase_diagram(),
        "workspace": make_workspace_plot(),
    }
    with open("viz_data.json", "w") as f:
        json.dump(visualizations, f)
    print("Generated all visualizations")
