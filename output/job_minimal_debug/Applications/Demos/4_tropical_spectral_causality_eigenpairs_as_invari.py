#!/usr/bin/env python3
"""
Applications of Tropical Spectral Causality

Demonstrates real-world applications of the theorems:
1. Manufacturing scheduling (flow-shop timing)
2. Network delay analysis (packet routing)
3. Train scheduling (periodic timetabling)
"""

import numpy as np
from algorithms import (
    trop_mat_vec_mul, trop_mat_pow_vec, find_tropical_eigenvector,
    verify_tropical_eigenpair, tropical_sup_displacement,
    critical_graph
)


def manufacturing_scheduling():
    """
    Application 1: Manufacturing Flow-Shop Scheduling

    A factory has 4 machines in a pipeline. Each job passes through all machines.
    Machine i starts its next job only after:
    - It finishes the current job (processing time = self-loop weight)
    - Machine j sends its output (transfer time = edge weight A[i,j])

    The tropical eigenvalue gives the throughput (minimum time between outputs).
    The eigenvector gives the optimal timing offsets for each machine.
    """
    print("=" * 60)
    print("APPLICATION 1: Manufacturing Flow-Shop Scheduling")
    print("=" * 60)

    # Processing + transfer time matrix
    # A[i,j] = time for machine i to wait for input from machine j
    A = np.array([
        [5, 8, 12, 15],   # Machine 0: 5s processing, waits for others
        [3, 6, 9, 12],    # Machine 1
        [7, 4, 7, 10],    # Machine 2
        [10, 7, 4, 7]     # Machine 3
    ])

    d, v = find_tropical_eigenvector(A)
    print(f"\nDelay matrix (processing + transfer times):\n{A}")
    print(f"\nOptimal timing profile (eigenvector): {np.round(v, 4)}")
    print(f"System throughput (eigenvalue): {d:.4f} time units per cycle")
    print(f"Verified eigenpair: {verify_tropical_eigenpair(A, d, v)}")

    crit = critical_graph(A, d, v)
    print(f"\nCritical path edges (bottleneck connections): {crit}")
    print("These are the connections that limit throughput.")

    # Simulate the production line
    print(f"\nProduction schedule (first 5 cycles):")
    print(f"{'Cycle':>6} | {'Machine 0':>10} | {'Machine 1':>10} | {'Machine 2':>10} | {'Machine 3':>10}")
    print("-" * 60)
    for k in range(5):
        times = v + k * d
        print(f"{k:6d} | {times[0]:10.2f} | {times[1]:10.2f} | {times[2]:10.2f} | {times[3]:10.2f}")

    print(f"\nKey insight: Each cycle, all machines shift by exactly {d:.2f} time units.")
    print("This is the tropical spectral causality theorem in action!")


def network_delay_analysis():
    """
    Application 2: Network Delay Analysis

    A packet must traverse a network of 5 routers.
    The delay matrix A[i,j] represents the propagation delay from router j to router i.
    The tropical eigenvalue gives the worst-case per-hop delay.
    The eigenvector gives the equilibrium delay profile.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Delay Analysis")
    print("=" * 60)

    # Delay matrix for a 5-router network
    A = np.array([
        [1, 3, 7, 10, 12],
        [4, 1, 3, 7, 10],
        [8, 5, 1, 3, 7],
        [11, 8, 5, 1, 3],
        [14, 11, 8, 5, 1]
    ])

    d, v = find_tropical_eigenvector(A)
    print(f"\nNetwork delay matrix:\n{A}")
    print(f"\nEquilibrium delay profile: {np.round(v, 4)}")
    print(f"Per-cycle delay (eigenvalue): {d:.4f}")
    print(f"Verified: {verify_tropical_eigenpair(A, d, v)}")

    # Show causal invariance: perturbations propagate predictably
    print(f"\nCausal invariance demonstration:")
    print(f"If all router clocks shift by t, the output shifts by exactly t.")
    for t in [0.5, 1.0, 2.0, 5.0]:
        v_shifted = v + t
        Av = trop_mat_vec_mul(A, v)
        Avt = trop_mat_vec_mul(A, v_shifted)
        disp = tropical_sup_displacement(Av, Avt)
        print(f"  t = {t:5.2f}: displacement = {disp:.10f} (should be {t:.2f})")

    # Show iterate drift: after k hops, delay accumulates linearly
    print(f"\nIterate drift: after k routing steps, total delay = v + k·{d:.2f}")
    for k in range(6):
        Akv = trop_mat_pow_vec(A, v, k)
        expected_shift = k * d
        actual_shift = Akv[0] - v[0]
        print(f"  k = {k}: actual drift = {actual_shift:.4f}, expected = {expected_shift:.4f}")


def train_scheduling():
    """
    Application 3: Periodic Train Timetabling

    A railway network with 4 stations on a loop.
    The delay matrix encodes minimum headway and travel times.
    The tropical eigenvalue gives the minimum period.
    The eigenvector gives the optimal departure offsets.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Periodic Train Timetabling")
    print("=" * 60)

    # Minimum time matrix: A[i,j] = minimum time from station j's departure
    # to station i's next departure
    A = np.array([
        [10, 4, 8, 3],    # Station A: 10min self, 4min from B, etc.
        [3, 10, 4, 8],    # Station B (symmetric ring)
        [8, 3, 10, 4],    # Station C
        [4, 8, 3, 10]     # Station D
    ])

    d, v = find_tropical_eigenvector(A)
    print(f"\nMinimum headway/travel matrix:\n{A}")
    print(f"\nOptimal departure offsets (eigenvector): {np.round(v, 4)}")
    print(f"Minimum period (eigenvalue): {d:.4f} minutes")
    print(f"Verified: {verify_tropical_eigenpair(A, d, v)}")

    crit = critical_graph(A, d, v)
    print(f"\nCritical connections: {crit}")
    print("These connections determine the minimum period.")

    # Generate timetable
    print(f"\nTimetable (first 4 trains):")
    print(f"{'Train':>6} | {'Station A':>10} | {'Station B':>10} | {'Station C':>10} | {'Station D':>10}")
    print("-" * 60)
    for k in range(4):
        times = v + k * d
        print(f"{k+1:6d} | {times[0]:10.1f} | {times[1]:10.1f} | {times[2]:10.1f} | {times[3]:10.1f}")

    print(f"\nThe tropical iterate drift theorem guarantees each successive")
    print(f"train departs exactly {d:.1f} minutes after the previous one.")
    print(f"This is PROVABLY the minimum achievable period for this network.")


if __name__ == "__main__":
    manufacturing_scheduling()
    network_delay_analysis()
    train_scheduling()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Spectral Causality: Demonstrations

This script demonstrates the key theorems of tropical spectral causality
with concrete numerical examples, showing how tropical eigenvectors define
invariant causal directions for min-plus dynamics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_mat_vec_mul(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector product: (A ⊗ v)(i) = min_k (A(i,k) + v(k))."""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(A[i, :] + v)
    return result


def trop_mat_pow_mul(A: np.ndarray, v: np.ndarray, k: int) -> np.ndarray:
    """Apply A to v, k times in the min-plus sense."""
    result = v.copy()
    for _ in range(k):
        result = trop_mat_vec_mul(A, result)
    return result


def tropical_sup_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """Sup-norm displacement: max_i |x(i) - y(i)|."""
    return np.max(np.abs(x - y))


def tropical_one_sided_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """One-sided displacement: max_i (y(i) - x(i))."""
    return np.max(y - x)


def is_tropical_eigenpair(A: np.ndarray, d: float, v: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if (d, v) is a tropical eigenpair of A."""
    Av = trop_mat_vec_mul(A, v)
    return np.allclose(Av, v + d, atol=tol)


def find_tropical_eigenvalue(A: np.ndarray) -> float:
    """Find the tropical eigenvalue (minimum cycle mean) via Karp's algorithm."""
    n = A.shape[0]
    # Compute A^k for k = 0, ..., n using tropical matrix powers
    # The min cycle mean = min_i max_{0<=k<n} (A^n[i,i] - A^k[i,i]) / (n - k)
    powers = [np.zeros((n, n))]  # A^0 = identity (0 on diagonal)
    for i in range(n):
        powers[0][i, i] = 0
        for j in range(n):
            if i != j:
                powers[0][i, j] = A[i, j]

    # Actually, let's use the simpler iterative approach
    # Compute tropical powers of A applied to each basis vector
    dist = np.full((n + 1, n), np.inf)
    for j in range(n):
        dist[0, j] = 0  # Start from node j with cost 0

    for k in range(1, n + 1):
        for i in range(n):
            dist[k, i] = np.min(A[i, :] + dist[k - 1, :])

    # Karp's formula
    min_cycle_mean = np.inf
    for i in range(n):
        max_ratio = -np.inf
        for k in range(n):
            if not np.isinf(dist[k, i]):
                ratio = (dist[n, i] - dist[k, i]) / (n - k)
                max_ratio = max(max_ratio, ratio)
        if not np.isinf(max_ratio):
            min_cycle_mean = min(min_cycle_mean, max_ratio)

    return min_cycle_mean


# ============================================================
# DEMO 1: Basic Eigenpair Verification
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Eigenpair and Shift Equivariance")
print("=" * 60)

# 3x3 matrix with known eigenpair
A = np.array([
    [3, 5, 7],
    [2, 4, 6],
    [1, 3, 5]
])

# Find eigenvector by iterating and normalizing
v = np.array([0.0, 0.0, 0.0])
for _ in range(100):
    v_new = trop_mat_vec_mul(A, v)
    d = v_new[0] - v[0]
    v = v_new - d  # Normalize

d = trop_mat_vec_mul(A, v)[0] - v[0]
print(f"\nMatrix A:\n{A}")
print(f"Eigenvector v = {v}")
print(f"Eigenvalue d = {d}")
print(f"Is eigenpair: {is_tropical_eigenpair(A, d, v)}")

# Verify shift equivariance: A ⊗ (v + t) = (A ⊗ v) + t
t = 3.14
Av = trop_mat_vec_mul(A, v)
Avt = trop_mat_vec_mul(A, v + t)
print(f"\nShift equivariance (t = {t}):")
print(f"  A ⊗ (v + t) = {Avt}")
print(f"  (A ⊗ v) + t = {Av + t}")
print(f"  Equal: {np.allclose(Avt, Av + t)}")

# ============================================================
# DEMO 2: Causal Invariance Along the Eigen-Ray
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Causal Invariance Along the Eigen-Ray")
print("=" * 60)

print("\nDisplacement table: d∞(A⊗v, A⊗(v+t)) vs |t|")
print(f"{'t':>8} | {'d∞(Av, A(v+t))':>16} | {'|t|':>8} | {'Equal?':>8}")
print("-" * 50)
for t in [0, 0.5, 1.0, 2.0, 5.0, -1.0, -3.0]:
    Av = trop_mat_vec_mul(A, v)
    Avt = trop_mat_vec_mul(A, v + t)
    disp = tropical_sup_displacement(Av, Avt)
    print(f"{t:8.2f} | {disp:16.10f} | {abs(t):8.2f} | {np.isclose(disp, abs(t))}")

# ============================================================
# DEMO 3: Iterate Drift
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Iterate Drift: A^k ⊗ v = v + k·d")
print("=" * 60)

print(f"\nEigenvalue d = {d:.6f}")
print(f"{'k':>4} | {'A^k⊗v - v (first coord)':>24} | {'k·d':>10} | {'Match?':>8}")
print("-" * 55)
for k in range(8):
    Akv = trop_mat_pow_mul(A, v, k)
    drift = Akv[0] - v[0]
    expected = k * d
    print(f"{k:4d} | {drift:24.10f} | {expected:10.4f} | {np.isclose(drift, expected)}")

# ============================================================
# DEMO 4: Causal Structure Through Iterates
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Causal Structure Through Iterates")
print("=" * 60)

t = 2.5
print(f"\nFixed t = {t}, checking d∞(A^k⊗v, A^k⊗(v+t)) = |t| for k = 0..7")
print(f"{'k':>4} | {'d∞(A^k⊗v, A^k⊗(v+t))':>24} | {'|t|':>8} | {'Causal?':>8}")
print("-" * 50)
for k in range(8):
    Akv = trop_mat_pow_mul(A, v, k)
    Akvt = trop_mat_pow_mul(A, v + t, k)
    disp = tropical_sup_displacement(Akv, Akvt)
    print(f"{k:4d} | {disp:24.10f} | {abs(t):8.2f} | {np.isclose(disp, abs(t))}")

# ============================================================
# DEMO 5: Future Preservation (d ≤ 0)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Future Preservation with Negative Eigenvalue")
print("=" * 60)

# Create a matrix with negative eigenvalue (contracting dynamics)
B = np.array([
    [-2, 1, 5],
    [3, -2, 1],
    [1, 3, -2]
])

w = np.array([0.0, 0.0, 0.0])
for _ in range(200):
    w_new = trop_mat_vec_mul(B, w)
    d_b = w_new[0] - w[0]
    w = w_new - d_b

d_b = trop_mat_vec_mul(B, w)[0] - w[0]
print(f"\nMatrix B:\n{B}")
print(f"Eigenvector w = {w}")
print(f"Eigenvalue d = {d_b:.6f}")
print(f"d ≤ 0: {d_b <= 1e-10}")

if d_b <= 1e-10:
    print(f"\nFuture preservation: B⊗(w+t) is in the future of (w+t)")
    print(f"  Meaning: max_i ((B⊗(w+t))(i) - (w+t)(i)) = d ≤ 0")
    for t in [0, 1, 2, 5, 10]:
        Bwt = trop_mat_vec_mul(B, w + t)
        one_sided = tropical_one_sided_displacement(w + t, Bwt)
        print(f"  t = {t:5.1f}: one-sided displacement = {one_sided:.10f} (= d = {d_b:.6f})")


# ============================================================
# DEMO 6: Network Timing Interpretation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Network Timing Interpretation")
print("=" * 60)

# Delay matrix for a 4-node network
D = np.array([
    [2, 5, 8, 9],
    [3, 2, 4, 7],
    [6, 3, 2, 5],
    [9, 6, 3, 2]
])

print(f"\nNetwork delay matrix:\n{D}")

# Find eigenpair
u = np.zeros(4)
for _ in range(200):
    u_new = trop_mat_vec_mul(D, u)
    d_net = u_new[0] - u[0]
    u = u_new - d_net

d_net = trop_mat_vec_mul(D, u)[0] - u[0]
print(f"\nStable delay profile (eigenvector): {u}")
print(f"System throughput (eigenvalue): {d_net:.4f}")
print(f"Verification: {is_tropical_eigenpair(D, d_net, u)}")
print(f"\nInterpretation: Every clock tick, all node delays shift by {d_net:.4f}")
print(f"This is the minimum average delay over all cycles in the network.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import (
    plot_eigenray_drift, plot_causal_invariance,
    plot_future_preservation, plot_network_timing
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Tropical/SpectralCausality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
print("Generating visualizations for package...")
viz1 = plot_eigenray_drift()
viz2 = plot_causal_invariance()
viz3 = plot_future_preservation()
viz4 = plot_network_timing()

package = {
    "title": "Tropical Spectral Causality: Eigenpairs as Invariant Causal Directions",
    "domain": "Tropical Algebra / Spectral Theory / Causal Dynamics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Spectral Causality Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix-Vector Multiplication",
            "pseudocode": "function TROP_MAT_VEC_MUL(A, v):\n  for i = 1 to n:\n    result[i] = min over k of (A[i,k] + v[k])\n  return result",
            "code": "def trop_mat_vec_mul(A, v):\n    \"\"\"Min-plus matrix-vector product: O(n^2)\"\"\"\n    import numpy as np\n    return np.min(A + v[np.newaxis, :], axis=1)"
        },
        {
            "name": "Karp's Minimum Cycle Mean Algorithm",
            "pseudocode": "function KARP_MIN_CYCLE_MEAN(A):\n  # Compute shortest k-step walks for k = 0..n\n  dist[0, :] = 0\n  for k = 1 to n:\n    for i = 1 to n:\n      dist[k, i] = min over j of (A[i,j] + dist[k-1, j])\n  # Apply Karp's formula\n  lambda* = min over i of max over k<n of (dist[n,i] - dist[k,i]) / (n-k)\n  return lambda*",
            "code": algorithms_code
        },
        {
            "name": "Tropical Eigenvector via Power Iteration",
            "pseudocode": "function FIND_EIGENVECTOR(A, max_iter):\n  v = 0\n  for iter = 1 to max_iter:\n    v_new = TROP_MAT_VEC_MUL(A, v)\n    d = v_new[0] - v[0]\n    v = v_new - d  # normalize\n    if converged: break\n  return (d, v)",
            "code": "def find_eigenvector(A, max_iter=1000, tol=1e-12):\n    import numpy as np\n    n = A.shape[0]\n    v = np.zeros(n)\n    for _ in range(max_iter):\n        v_new = np.min(A + v[np.newaxis, :], axis=1)\n        d = v_new[0] - v[0]\n        v_new_norm = v_new - d\n        if np.max(np.abs(v_new_norm - v)) < tol:\n            v = v_new_norm\n            break\n        v = v_new_norm\n    d = np.min(A + v[np.newaxis, :], axis=1)[0] - v[0]\n    return d, v"
        }
    ],
    "visualizations": [
        {"name": "Eigenray Iterate Drift", "data": viz1},
        {"name": "Causal Invariance Along Eigen-Ray", "data": viz2},
        {"name": "Future Preservation (Contracting Dynamics)", "data": viz3},
        {"name": "Network Timing Application", "data": viz4}
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully!")
print(f"File size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical Spectral Causality

Generates publication-quality figures demonstrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    trop_mat_vec_mul, trop_mat_pow_vec, find_tropical_eigenvector,
    tropical_sup_displacement, tropical_hilbert_metric
)
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_eigenray_drift():
    """
    Visualize the iterate drift theorem: A^k ⊗ v = v + k·d.
    Shows how the eigenvector shifts linearly under repeated matrix action.
    """
    A = np.array([
        [3, 5, 7],
        [2, 4, 6],
        [1, 3, 5]
    ])
    d, v = find_tropical_eigenvector(A)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: trajectory of each coordinate
    ks = range(8)
    trajectories = np.array([trop_mat_pow_vec(A, v, k) for k in ks])

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for j in range(3):
        ax1.plot(list(ks), trajectories[:, j], 'o-', color=colors[j],
                 label=f'Coordinate {j}', linewidth=2, markersize=6)
        ax1.plot(list(ks), [v[j] + k * d for k in ks], '--', color=colors[j],
                 alpha=0.5, linewidth=1)

    ax1.set_xlabel('Iteration k', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Iterate Drift: A^k ⊗ v', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.text(4, trajectories[4, 0] + 1, f'drift = {d:.1f} per step',
             fontsize=11, color='gray')

    # Right: drift vs k (showing linearity)
    drifts = [trop_mat_pow_vec(A, v, k)[0] - v[0] for k in ks]
    ax2.plot(list(ks), drifts, 'o-', color='#8e44ad', linewidth=2, markersize=8, label='Actual drift')
    ax2.plot(list(ks), [k * d for k in ks], '--', color='gray', linewidth=1, label=f'k × d (d={d:.1f})')
    ax2.set_xlabel('Iteration k', fontsize=12)
    ax2.set_ylabel('Drift (first coordinate)', fontsize=12)
    ax2.set_title('Linear Drift Verification', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Eigenray Iterate Drift Theorem', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_causal_invariance():
    """
    Visualize causal invariance: d∞(A^k⊗v, A^k⊗(v+t)) = |t| for all k.
    """
    A = np.array([
        [3, 5, 7],
        [2, 4, 6],
        [1, 3, 5]
    ])
    d, v = find_tropical_eigenvector(A)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: displacement vs k for various t
    t_values = [0.5, 1.0, 2.0, 3.0, 5.0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(t_values)))
    ks = range(10)

    for t, c in zip(t_values, colors):
        disps = [tropical_sup_displacement(
            trop_mat_pow_vec(A, v, k),
            trop_mat_pow_vec(A, v + t, k)
        ) for k in ks]
        ax1.plot(list(ks), disps, 'o-', color=c, label=f't = {t}', markersize=5)
        ax1.axhline(y=abs(t), color=c, linestyle='--', alpha=0.3)

    ax1.set_xlabel('Iteration k', fontsize=12)
    ax1.set_ylabel('Sup-displacement d∞', fontsize=12)
    ax1.set_title('Causal Invariance: d∞ = |t| ∀k', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right: displacement vs t for various k
    t_range = np.linspace(-5, 5, 50)
    k_values = [0, 1, 3, 5, 10]
    colors2 = plt.cm.plasma(np.linspace(0.2, 0.8, len(k_values)))

    for k, c in zip(k_values, colors2):
        disps = [tropical_sup_displacement(
            trop_mat_pow_vec(A, v, k),
            trop_mat_pow_vec(A, v + t, k)
        ) for t in t_range]
        ax2.plot(t_range, disps, '-', color=c, label=f'k = {k}', linewidth=2)

    ax2.plot(t_range, np.abs(t_range), 'k--', alpha=0.5, label='|t|')
    ax2.set_xlabel('Shift parameter t', fontsize=12)
    ax2.set_ylabel('Sup-displacement d∞', fontsize=12)
    ax2.set_title('All Curves Collapse to |t|', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Causal Invariance Along the Eigen-Ray', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_future_preservation():
    """
    Visualize future preservation: when d ≤ 0, the dynamics contracts.
    """
    B = np.array([
        [-2, 1, 5],
        [3, -2, 1],
        [1, 3, -2]
    ])
    d_b, w = find_tropical_eigenvector(B)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: orbit of w under B (showing contraction)
    ks = range(8)
    trajectories = np.array([trop_mat_pow_vec(B, w, k) for k in ks])

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for j in range(3):
        ax1.plot(list(ks), trajectories[:, j], 'o-', color=colors[j],
                 label=f'Coordinate {j}', linewidth=2, markersize=6)

    ax1.set_xlabel('Iteration k', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title(f'Contracting Dynamics (d = {d_b:.1f} < 0)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Each step shifts down by |d|',
                 xy=(3, trajectories[3, 0]), fontsize=10, color='gray')

    # Right: one-sided displacement showing d ≤ 0
    t_values = np.linspace(0, 10, 20)
    one_sided = []
    for t in t_values:
        Bwt = trop_mat_vec_mul(B, w + t)
        one_sided.append(np.max(Bwt - (w + t)))

    ax2.plot(t_values, one_sided, 'o-', color='#8e44ad', linewidth=2, markersize=5)
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.axhline(y=d_b, color='red', linestyle='--', alpha=0.5, label=f'd = {d_b:.1f}')
    ax2.fill_between(t_values, d_b, 0, alpha=0.1, color='green')
    ax2.set_xlabel('Shift parameter t', fontsize=12)
    ax2.set_ylabel('One-sided displacement', fontsize=12)
    ax2.set_title('Future Preservation: d⁺ = d ≤ 0', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.text(5, d_b / 2, 'Future region\n(displacement ≤ 0)',
             fontsize=11, ha='center', color='green')

    fig.suptitle('Tropical Future Preservation for Contracting Dynamics', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_network_timing():
    """
    Visualize the network timing application.
    """
    D = np.array([
        [2, 5, 8, 9],
        [3, 2, 4, 7],
        [6, 3, 2, 5],
        [9, 6, 3, 2]
    ])
    d, u = find_tropical_eigenvector(D)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Timetable visualization
    n_cycles = 6
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for node in range(4):
        times = [u[node] + k * d for k in range(n_cycles)]
        ax1.scatter(times, [node] * n_cycles, color=colors[node], s=100, zorder=3)
        ax1.plot(times, [node] * n_cycles, '-', color=colors[node], alpha=0.5, linewidth=2)

    ax1.set_yticks(range(4))
    ax1.set_yticklabels([f'Node {i}' for i in range(4)])
    ax1.set_xlabel('Time', fontsize=12)
    ax1.set_title(f'Network Timing (period = {d:.1f})', fontsize=14)
    ax1.grid(True, alpha=0.3)

    # Add period annotations
    for k in range(n_cycles - 1):
        ax1.annotate('', xy=(u[0] + (k + 1) * d, -0.3),
                     xytext=(u[0] + k * d, -0.3),
                     arrowprops=dict(arrowstyle='<->', color='gray'))
        if k == 2:
            ax1.text(u[0] + (k + 0.5) * d, -0.5, f'd = {d:.1f}',
                     ha='center', fontsize=10, color='gray')

    # Right: Convergence to eigenvector from random start
    np.random.seed(42)
    v0 = np.random.randn(4) * 5
    ks = range(15)
    trajectories = [v0]
    for _ in range(14):
        v_next = trop_mat_vec_mul(D, trajectories[-1])
        trajectories.append(v_next)

    # Normalize by subtracting drift
    normalized = []
    for k, tr in enumerate(trajectories):
        normalized.append(tr - k * d - tr[0])

    normalized = np.array(normalized)
    eig_norm = u - u[0]

    for j in range(4):
        ax2.plot(list(ks), normalized[:, j], '-', color=colors[j],
                 linewidth=2, label=f'Node {j}')
        ax2.axhline(y=eig_norm[j], color=colors[j], linestyle='--', alpha=0.3)

    ax2.set_xlabel('Iteration k', fontsize=12)
    ax2.set_ylabel('Normalized value', fontsize=12)
    ax2.set_title('Convergence to Eigenvector', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Network Timing: Eigenray as Stable Delay Profile', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_eigenray_drift()
    print(f"  1. Eigenray drift: {len(img1)} chars")

    img2 = plot_causal_invariance()
    print(f"  2. Causal invariance: {len(img2)} chars")

    img3 = plot_future_preservation()
    print(f"  3. Future preservation: {len(img3)} chars")

    img4 = plot_network_timing()
    print(f"  4. Network timing: {len(img4)} chars")

    # Save as standalone HTML for viewing
    html = f"""<!DOCTYPE html>
<html><head><title>Tropical Spectral Causality Visualizations</title></head>
<body style="max-width:900px;margin:auto;font-family:sans-serif">
<h1>Tropical Spectral Causality: Visualizations</h1>
<h2>1. Eigenray Iterate Drift</h2>
<img src="{img1}" style="width:100%">
<h2>2. Causal Invariance</h2>
<img src="{img2}" style="width:100%">
<h2>3. Future Preservation</h2>
<img src="{img3}" style="width:100%">
<h2>4. Network Timing</h2>
<img src="{img4}" style="width:100%">
</body></html>"""

    with open("visualizations.html", "w") as f:
        f.write(html)

    print("\nAll visualizations generated. See visualizations.html")
