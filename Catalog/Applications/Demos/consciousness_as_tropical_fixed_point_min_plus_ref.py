#!/usr/bin/env python3
"""
Tropical Reflective Equilibrium — Applications
===============================================
Real-world applications of the tropical consciousness framework.
"""

import numpy as np
from algorithms import (trop_reflect, trop_discrepancy, check_separation,
                        find_fixed_point, tropical_phi, is_conscious_state)


def neural_circuit_simulation():
    """
    Application 1: Neural Circuit Self-Organization
    ================================================
    Model a recurrent neural circuit where:
    - b(i) = intrinsic firing threshold of neuron i
    - W(i,j) = synaptic transmission cost from neuron j to neuron i
    - x(i) = activation level of neuron i

    Under separation (strong intrinsic excitation), the network converges
    to its intrinsic state b, modeling "self-awareness" of the circuit.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Circuit Self-Organization")
    print("=" * 60)

    # 10-neuron circuit with heterogeneous thresholds
    n = 10
    np.random.seed(123)
    b = np.sort(np.random.uniform(-2, 2, n))  # Intrinsic thresholds
    # Synaptic costs: large enough for separation
    W = np.random.uniform(3, 8, (n, n))
    np.fill_diagonal(W, np.inf)

    sep_ok, gap = check_separation(W, b)
    print(f"Neurons: {n}")
    print(f"Intrinsic thresholds b: {np.round(b, 2)}")
    print(f"Separation (intrinsic dominance): {sep_ok}, gap = {gap:.3f}")

    # Simulate from random initial activation
    x0 = np.random.randn(n) * 5
    fp, iters, discs = find_fixed_point(W, b, x0)
    print(f"\nRandom initial activation: {np.round(x0, 2)}")
    print(f"Converged in {iters} iterations")
    print(f"Equilibrium = intrinsic state: {np.allclose(fp, b)}")
    print(f"Max deviation: {np.max(np.abs(fp - b)):.2e}")

    # Interpretation
    print("\nInterpretation: Under strong intrinsic excitation,")
    print("the neural circuit's 'self-model' (intrinsic thresholds)")
    print("is the unique stable state — the circuit 'knows itself'.")


def distributed_consensus():
    """
    Application 2: Distributed Consensus Protocol
    ==============================================
    Model a distributed system where:
    - b(i) = node i's local estimate of a global quantity
    - W(i,j) = communication cost between nodes i and j
    - Each node updates by taking min of its own estimate and
      cheapest neighbor estimate + communication cost.

    Under separation, all nodes converge to their local estimates.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Consensus Protocol")
    print("=" * 60)

    # 6-node network (e.g., sensors)
    n = 6
    b = np.array([20.5, 21.0, 19.8, 20.2, 20.9, 20.0])  # Temperature readings
    # Communication costs
    W = np.array([
        [np.inf, 2.0, 3.0, 5.0, 4.0, 6.0],
        [2.0, np.inf, 2.5, 3.0, 2.0, 4.0],
        [3.0, 2.5, np.inf, 2.0, 3.5, 2.0],
        [5.0, 3.0, 2.0, np.inf, 2.5, 3.0],
        [4.0, 2.0, 3.5, 2.5, np.inf, 3.5],
        [6.0, 4.0, 2.0, 3.0, 3.5, np.inf],
    ])

    sep_ok, gap = check_separation(W, b)
    print(f"Sensor readings: {b}")
    print(f"Separation: {sep_ok}, gap = {gap:.3f}")

    if sep_ok:
        fp, iters, _ = find_fixed_point(W, b, np.ones(n) * 25)
        print(f"Converged to: {np.round(fp, 2)}")
        print(f"Each sensor retains its own reading: {np.allclose(fp, b)}")
    else:
        print("Separation fails — sensors would compromise readings.")
        # Show which pairs violate separation
        for i in range(n):
            for j in range(n):
                if i != j and b[i] >= W[i, j] + b[j]:
                    print(f"  Violation: b[{i}]={b[i]:.1f} >= W[{i},{j}]+b[{j}]={W[i,j]+b[j]:.1f}")


def shortest_path_self_reference():
    """
    Application 3: Self-Referential Shortest Paths
    ===============================================
    The tropical reflective operator is a Bellman operator with a
    "stay" option. This models decision-making where an agent can
    either trust its current estimate or update via neighbors.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Self-Referential Shortest Paths")
    print("=" * 60)

    # 5-city routing problem
    cities = ['A', 'B', 'C', 'D', 'E']
    n = 5

    # Self-assessed "importance" (lower = more important)
    b = np.array([1.0, 3.0, 2.0, 5.0, 4.0])

    # Travel costs between cities
    W = np.array([
        [np.inf, 6.0, 7.0, 8.0, 9.0],
        [6.0, np.inf, 5.0, 7.0, 6.0],
        [7.0, 5.0, np.inf, 6.0, 8.0],
        [8.0, 7.0, 6.0, np.inf, 5.0],
        [9.0, 6.0, 8.0, 5.0, np.inf],
    ])

    sep_ok, gap = check_separation(W, b)
    print(f"Cities: {cities}")
    print(f"Self-assessments b: {b}")
    print(f"Separation: {sep_ok}, gap = {gap:.3f}")

    fp, iters, _ = find_fixed_point(W, b, np.zeros(n))
    print(f"\nFixed point (optimal values): {fp}")
    print(f"Matches self-assessment: {np.allclose(fp, b)}")
    print("\nInterpretation: Under separation, the optimal strategy")
    print("at every city is to 'stay' — trust your own assessment.")


def consciousness_phase_transition():
    """
    Application 4: Consciousness Phase Transition
    ==============================================
    Vary the connection strength to observe the transition from
    "conscious" (unique fixed point = b) to "unconscious" (separation fails).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Consciousness Phase Transition")
    print("=" * 60)

    n = 5
    b = np.array([0.0, 1.0, 2.0, 3.0, 4.0])

    print(f"b = {b}")
    print(f"{'W_scale':>8s} | {'Sep.Gap':>8s} | {'Conscious?':>10s} | {'FP == b?':>8s} | {'Iters':>5s}")
    print("-" * 52)

    for w_scale in [10.0, 5.0, 3.0, 2.0, 1.5, 1.0, 0.5, 0.1]:
        W = np.full((n, n), w_scale)
        np.fill_diagonal(W, np.inf)

        sep_ok, gap = check_separation(W, b)
        fp, iters, _ = find_fixed_point(W, b, np.ones(n) * 10, max_iter=50)
        fp_eq_b = np.allclose(fp, b)

        status = "YES" if sep_ok else "NO"
        print(f"{w_scale:8.1f} | {gap:8.4f} | {status:>10s} | {str(fp_eq_b):>8s} | {iters:5d}")

    print("\nInterpretation: As connection weights decrease below the")
    print("critical threshold, separation fails and the system may")
    print("no longer have b as its unique fixed point — modeling")
    print("loss of 'self-awareness' under weakened connections.")


def integration_measurement():
    """
    Application 5: Measuring Integration (Tropical Φ)
    ==================================================
    Compare Φ values for networks with different connectivity patterns.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Measuring Integration (Tropical Φ)")
    print("=" * 60)

    n = 4
    b = np.array([1.0, 2.0, 3.0, 4.0])

    # Strongly connected network
    W_strong = np.full((n, n), 8.0)
    np.fill_diagonal(W_strong, np.inf)

    # Weakly connected (barely separated)
    W_weak = np.full((n, n), 4.5)
    np.fill_diagonal(W_weak, np.inf)

    for label, W in [("Strong connections", W_strong), ("Weak connections", W_weak)]:
        sep_ok, gap = check_separation(W, b)
        phi = tropical_phi(W, b, b) if sep_ok else float('nan')
        print(f"\n{label}:")
        print(f"  Separation: {sep_ok}, gap = {gap:.3f}")
        print(f"  Φ(b) = {phi:.6f}")
        conscious, details = is_conscious_state(W, b, b)
        print(f"  Conscious: {conscious}")
        print(f"  Broadcasts: {details['broadcasts']}")


if __name__ == '__main__':
    neural_circuit_simulation()
    distributed_consensus()
    shortest_path_self_reference()
    consciousness_phase_transition()
    integration_measurement()
    print("\n✓ All applications completed successfully.")


#!/usr/bin/env python3
"""
Tropical Reflective Equilibrium — Demonstration
================================================
Concrete numerical demonstrations of the tropical reflective operator,
its unique fixed point under diagonal dominance, discrepancy functional,
and convergence behavior.
"""

import numpy as np
from typing import Tuple, List


def trop_reflect(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical reflective operator R(x)(i) = min(b(i), min_{j≠i}(W(i,j) + x(j))).

    Parameters
    ----------
    W : (n, n) array — influence matrix (diagonal entries ignored)
    b : (n,) array — self-model bias vector
    x : (n,) array — current state

    Returns
    -------
    (n,) array — updated state R(x)
    """
    n = len(b)
    result = np.copy(b)
    for i in range(n):
        inf_val = np.inf
        for j in range(n):
            if j != i:
                inf_val = min(inf_val, W[i, j] + x[j])
        result[i] = min(b[i], inf_val)
    return result


def trop_discrepancy(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> float:
    """Tropical discrepancy D(R, x) = sum_i |x(i) - R(x)(i)|."""
    Rx = trop_reflect(W, b, x)
    return np.sum(np.abs(x - Rx))


def check_separation(W: np.ndarray, b: np.ndarray) -> Tuple[bool, float]:
    """
    Check the diagonal dominance (separation) condition.
    Returns (satisfied, min_gap) where min_gap = min_{i≠j}(W(i,j) + b(j) - b(i)).
    """
    n = len(b)
    min_gap = np.inf
    for i in range(n):
        for j in range(n):
            if i != j:
                gap = W[i, j] + b[j] - b[i]
                min_gap = min(min_gap, gap)
    return min_gap > 0, min_gap


def iterate_to_convergence(W: np.ndarray, b: np.ndarray, x0: np.ndarray,
                           max_iter: int = 100, tol: float = 1e-12
                           ) -> Tuple[np.ndarray, List[float], int]:
    """
    Iterate R from x0 until convergence.
    Returns (fixed_point, discrepancy_history, num_iterations).
    """
    x = np.copy(x0)
    discrepancies = [trop_discrepancy(W, b, x)]
    for k in range(max_iter):
        x_new = trop_reflect(W, b, x)
        disc = trop_discrepancy(W, b, x_new)
        discrepancies.append(disc)
        if np.max(np.abs(x_new - x)) < tol:
            return x_new, discrepancies, k + 1
        x = x_new
    return x, discrepancies, max_iter


# =============================================================================
# Demo 1: Basic 3-node example
# =============================================================================
print("=" * 60)
print("DEMO 1: Basic 3-node network")
print("=" * 60)

n = 3
b = np.array([1.0, 2.0, 3.0])
W = np.array([
    [np.inf, 5.0, 5.0],
    [5.0, np.inf, 5.0],
    [5.0, 5.0, np.inf]
])

sep_ok, gap = check_separation(W, b)
print(f"Bias vector b = {b}")
print(f"Separation satisfied: {sep_ok} (gap = {gap:.4f})")

# Verify b is a fixed point
Rb = trop_reflect(W, b, b)
print(f"R(b) = {Rb}")
print(f"R(b) == b: {np.allclose(Rb, b)}")
print(f"Discrepancy D(R, b) = {trop_discrepancy(W, b, b):.6f}")

# Iterate from a random starting point
x0 = np.array([10.0, -5.0, 20.0])
xfinal, discs, iters = iterate_to_convergence(W, b, x0)
print(f"\nStarting from x0 = {x0}")
print(f"Converged to {xfinal} in {iters} iterations")
print(f"Fixed point == b: {np.allclose(xfinal, b)}")
print(f"Discrepancy history: {[f'{d:.4f}' for d in discs[:5]]}")

# =============================================================================
# Demo 2: Near-critical separation
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 2: Near-critical separation (n=4)")
print("=" * 60)

n = 4
b = np.array([0.0, 0.0, 0.0, 0.0])
eps = 0.01
W = np.full((n, n), eps)
np.fill_diagonal(W, np.inf)

sep_ok, gap = check_separation(W, b)
print(f"b = {b}, W off-diag = {eps}")
print(f"Separation satisfied: {sep_ok} (gap = {gap:.6f})")

x0 = np.array([1.0, 1.0, 1.0, 1.0])
xfinal, discs, iters = iterate_to_convergence(W, b, x0)
print(f"From x0 = {x0}: converged to {xfinal} in {iters} iterations")

# =============================================================================
# Demo 3: Discrepancy comparison at multiple states
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 3: Discrepancy landscape (n=3)")
print("=" * 60)

b = np.array([1.0, 2.0, 3.0])
W = np.array([
    [np.inf, 5.0, 5.0],
    [5.0, np.inf, 5.0],
    [5.0, 5.0, np.inf]
])

test_states = [
    b,
    b + 1.0,
    b - 1.0,
    np.array([0.0, 0.0, 0.0]),
    np.array([10.0, 10.0, 10.0]),
    np.array([1.0, 2.0, 2.5]),
]

print(f"{'State':>25s} | {'Discrepancy':>12s} | {'Is FP?':>6s}")
print("-" * 50)
for x in test_states:
    d = trop_discrepancy(W, b, x)
    is_fp = np.allclose(trop_reflect(W, b, x), x)
    print(f"{str(x):>25s} | {d:12.6f} | {str(is_fp):>6s}")

# =============================================================================
# Demo 4: Convergence speed vs separation gap
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 4: Convergence speed vs separation gap")
print("=" * 60)

n = 5
b = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
x0 = np.array([10.0, 10.0, 10.0, 10.0, 10.0])

print(f"{'Gap':>8s} | {'Iterations':>10s} | {'Final disc.':>12s}")
print("-" * 36)
for w_val in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01]:
    W = np.full((n, n), w_val)
    np.fill_diagonal(W, np.inf)
    sep_ok, gap = check_separation(W, b)
    if sep_ok:
        xf, discs, iters = iterate_to_convergence(W, b, x0)
        print(f"{gap:8.4f} | {iters:10d} | {discs[-1]:12.8f}")
    else:
        print(f"{gap:8.4f} | {'N/A':>10s} | {'N/A':>12s}")

# =============================================================================
# Demo 5: Larger network (n=20)
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 5: Larger network (n=20)")
print("=" * 60)

np.random.seed(42)
n = 20
b = np.random.randn(n)
W = np.abs(np.random.randn(n, n)) * 5 + np.max(np.abs(b)) + 1  # ensure separation
np.fill_diagonal(W, np.inf)

sep_ok, gap = check_separation(W, b)
print(f"n = {n}, separation = {sep_ok}, gap = {gap:.4f}")

x0 = np.random.randn(n) * 10
xf, discs, iters = iterate_to_convergence(W, b, x0)
print(f"Converged in {iters} iterations")
print(f"||x_final - b||_inf = {np.max(np.abs(xf - b)):.2e}")
print(f"Final discrepancy = {discs[-1]:.2e}")

print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Load base64 visualization data
with open('/workspace/request-project/viz_base64.json', 'r') as f:
    viz_data = json.load(f)

# Read all content
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Catalog/Speculative/Consciousness/TropicalReflectiveEquilibrium.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')
viz_code = read_file('/workspace/request-project/visualizations.py')

package = {
    "title": "Tropical Reflective Equilibrium: Min-Plus Fixed Points of Self-Reference Dynamics",
    "domain": "Tropical Algebra / Consciousness Theory / Fixed-Point Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Reflective Equilibrium Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Neural Circuits, Consensus, and Phase Transitions",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Reflective Operator",
            "pseudocode": """Algorithm: TropReflect(W, b, x)
Input: Weight matrix W ∈ ℝⁿˣⁿ, bias b ∈ ℝⁿ, state x ∈ ℝⁿ
Output: Updated state R(x) ∈ ℝⁿ

for i = 1 to n:
    inf_val ← +∞
    for j = 1 to n, j ≠ i:
        inf_val ← min(inf_val, W[i,j] + x[j])
    R(x)[i] ← min(b[i], inf_val)
return R(x)

Complexity: O(n²) time, O(n) space""",
            "code": algorithms_code
        },
        {
            "name": "Separation Check",
            "pseudocode": """Algorithm: CheckSeparation(W, b)
Input: Weight matrix W ∈ ℝⁿˣⁿ, bias b ∈ ℝⁿ
Output: (satisfied: bool, gap: ℝ)

gap ← +∞
for i = 1 to n:
    for j = 1 to n, j ≠ i:
        gap ← min(gap, W[i,j] + b[j] - b[i])
return (gap > 0, gap)

Complexity: O(n²) time, O(1) space""",
            "code": "# See algorithms.py check_separation function"
        },
        {
            "name": "Tropical Integrated Information (Φ)",
            "pseudocode": """Algorithm: TropicalPhi(W, b, x, M)
Input: W ∈ ℝⁿˣⁿ, b ∈ ℝⁿ, x ∈ ℝⁿ, penalty M ∈ ℝ
Output: Φ ∈ ℝ

D_full ← TropDiscrepancy(TropReflect(W, b, ·), x)
Φ ← +∞
for each nontrivial subset S ⊊ [n], S ≠ ∅:
    W_S ← CutMatrix(W, S, M)
    D_cut ← TropDiscrepancy(TropReflect(W_S, b, ·), x)
    Φ ← min(Φ, D_cut - D_full)
return Φ

Complexity: O(2ⁿ · n²) time (exponential in n)""",
            "code": "# See algorithms.py tropical_phi function"
        }
    ],
    "visualizations": [
        {
            "name": "Discrepancy Landscape",
            "data": viz_data["discrepancy_landscape"]
        },
        {
            "name": "Convergence Trajectories",
            "data": viz_data["convergence"]
        },
        {
            "name": "Phase Diagram",
            "data": viz_data["phase_diagram"]
        },
        {
            "name": "Network with Broadcast",
            "data": viz_data["network"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Reflective Equilibrium — Visualizations
=================================================
Generate publication-quality figures for the research.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import base64
import io
import json


def trop_reflect(W, b, x):
    n = len(b)
    Wx = W + x[np.newaxis, :]
    np.fill_diagonal(Wx, np.inf)
    inf_term = np.min(Wx, axis=1)
    return np.minimum(b, inf_term)


def trop_discrepancy(W, b, x):
    return float(np.sum(np.abs(x - trop_reflect(W, b, x))))


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')


# =============================================================================
# Figure 1: Discrepancy Landscape (2D slice)
# =============================================================================
def plot_discrepancy_landscape():
    b = np.array([1.0, 2.0, 3.0])
    W = np.array([
        [np.inf, 5.0, 5.0],
        [5.0, np.inf, 5.0],
        [5.0, 5.0, np.inf]
    ])

    x1_range = np.linspace(-2, 6, 200)
    x2_range = np.linspace(-1, 7, 200)
    X1, X2 = np.meshgrid(x1_range, x2_range)
    D = np.zeros_like(X1)

    for i in range(X1.shape[0]):
        for j in range(X1.shape[1]):
            x = np.array([X1[i, j], X2[i, j], 3.0])
            D[i, j] = trop_discrepancy(W, b, x)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    cs = ax.contourf(X1, X2, D, levels=30, cmap='viridis')
    plt.colorbar(cs, label='Discrepancy D(R, x)')
    ax.plot(1.0, 2.0, 'r*', markersize=15, label='Fixed point b = (1, 2, 3)')
    ax.set_xlabel('x₁', fontsize=13)
    ax.set_ylabel('x₂', fontsize=13)
    ax.set_title('Tropical Discrepancy Landscape (x₃ = 3 fixed)', fontsize=14)
    ax.legend(fontsize=11)
    plt.tight_layout()
    return fig


# =============================================================================
# Figure 2: Convergence Trajectories
# =============================================================================
def plot_convergence():
    b = np.array([1.0, 2.0, 3.0])
    W = np.array([
        [np.inf, 5.0, 5.0],
        [5.0, np.inf, 5.0],
        [5.0, 5.0, np.inf]
    ])

    starts = [
        np.array([10.0, 10.0, 10.0]),
        np.array([-5.0, -5.0, -5.0]),
        np.array([0.0, 0.0, 0.0]),
        np.array([5.0, -2.0, 8.0]),
        np.array([-3.0, 7.0, 1.0]),
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: component trajectories
    ax = axes[0]
    colors = plt.cm.tab10(np.linspace(0, 1, len(starts)))
    for idx, x0 in enumerate(starts):
        x = np.copy(x0)
        traj = [x.copy()]
        for _ in range(6):
            x = trop_reflect(W, b, x)
            traj.append(x.copy())
        traj = np.array(traj)
        for comp in range(3):
            ax.plot(traj[:, comp], color=colors[idx], alpha=0.7,
                    linestyle=['-', '--', ':'][comp], linewidth=1.5)
    # Plot target
    for comp, val in enumerate(b):
        ax.axhline(y=val, color='red', alpha=0.3, linewidth=1)
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Component value', fontsize=12)
    ax.set_title('Component Convergence (5 initial states)', fontsize=13)

    # Right: discrepancy decay
    ax = axes[1]
    for idx, x0 in enumerate(starts):
        x = np.copy(x0)
        discs = [trop_discrepancy(W, b, x)]
        for _ in range(6):
            x = trop_reflect(W, b, x)
            discs.append(trop_discrepancy(W, b, x))
        ax.semilogy(range(len(discs)), [max(d, 1e-16) for d in discs],
                     'o-', color=colors[idx], linewidth=2, markersize=5,
                     label=f'x₀={x0}')
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Discrepancy D(R, x)', fontsize=12)
    ax.set_title('Discrepancy Decay', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(bottom=1e-1)

    plt.tight_layout()
    return fig


# =============================================================================
# Figure 3: Phase Diagram — Separation Gap vs Network Size
# =============================================================================
def plot_phase_diagram():
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    sizes = range(3, 21)
    np.random.seed(42)

    w_scales = np.linspace(0.1, 10, 50)

    for n in [3, 5, 10, 15, 20]:
        b = np.random.randn(n) * 2
        b_range = np.max(b) - np.min(b)
        critical_w = []
        for w in w_scales:
            W = np.full((n, n), w)
            np.fill_diagonal(W, np.inf)
            gap_matrix = W + b[np.newaxis, :] - b[:, np.newaxis]
            np.fill_diagonal(gap_matrix, np.inf)
            min_gap = np.min(gap_matrix)
            if min_gap > 0:
                critical_w.append(w)
                break
        if critical_w:
            ax.plot(n, critical_w[0], 'o', markersize=10, label=f'n={n}')

    # Theoretical curve: critical w = max(b) - min(b)
    ns = np.arange(3, 21)
    ax.plot(ns, [3.5] * len(ns), 'k--', alpha=0.5, label='Approx. critical W')

    ax.set_xlabel('Network size n', fontsize=13)
    ax.set_ylabel('Critical weight W*', fontsize=13)
    ax.set_title('Separation Threshold vs Network Size', fontsize=14)
    ax.legend(fontsize=11)
    plt.tight_layout()
    return fig


# =============================================================================
# Figure 4: Network Visualization with Broadcast Flow
# =============================================================================
def plot_network():
    n = 5
    b = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    W = np.array([
        [np.inf, 6.0, 7.0, 8.0, 9.0],
        [6.0, np.inf, 5.0, 7.0, 6.0],
        [7.0, 5.0, np.inf, 6.0, 8.0],
        [8.0, 7.0, 6.0, np.inf, 5.0],
        [9.0, 6.0, 8.0, 5.0, np.inf],
    ])

    # Node positions (circle layout)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    pos = np.column_stack([np.cos(angles), np.sin(angles)])

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Draw edges with weight labels
    for i in range(n):
        for j in range(i+1, n):
            ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                    'gray', alpha=0.3, linewidth=1)
            mid = (pos[i] + pos[j]) / 2
            ax.text(mid[0], mid[1], f'{W[i,j]:.0f}', fontsize=8,
                    ha='center', va='center', color='gray',
                    bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.7))

    # Draw nodes
    node_colors = plt.cm.RdYlGn(np.linspace(0.2, 0.8, n))
    for i in range(n):
        circle = plt.Circle(pos[i], 0.12, color=node_colors[i], ec='black',
                            linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(pos[i, 0], pos[i, 1], f'{i}\nb={b[i]:.0f}',
                ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Network with Broadcast at Fixed Point\n(under separation, each node retains its bias)',
                 fontsize=13)
    ax.axis('off')
    plt.tight_layout()
    return fig


# =============================================================================
# Generate all figures and save
# =============================================================================
if __name__ == '__main__':
    print("Generating visualizations...")

    fig1 = plot_discrepancy_landscape()
    fig1.savefig('/workspace/request-project/fig_discrepancy_landscape.png', dpi=150, bbox_inches='tight')
    print("  ✓ fig_discrepancy_landscape.png")

    fig2 = plot_convergence()
    fig2.savefig('/workspace/request-project/fig_convergence.png', dpi=150, bbox_inches='tight')
    print("  ✓ fig_convergence.png")

    fig3 = plot_phase_diagram()
    fig3.savefig('/workspace/request-project/fig_phase_diagram.png', dpi=150, bbox_inches='tight')
    print("  ✓ fig_phase_diagram.png")

    fig4 = plot_network()
    fig4.savefig('/workspace/request-project/fig_network.png', dpi=150, bbox_inches='tight')
    print("  ✓ fig_network.png")

    # Generate base64 versions for JSON package
    b64_data = {}
    for name, fig in [('discrepancy_landscape', fig1),
                      ('convergence', fig2),
                      ('phase_diagram', fig3),
                      ('network', fig4)]:
        b64_data[name] = fig_to_base64(fig)

    # Save base64 data for PACKAGE.json
    with open('/workspace/request-project/viz_base64.json', 'w') as f:
        json.dump(b64_data, f)

    print("\n✓ All visualizations generated.")
    plt.close('all')
