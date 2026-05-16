#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Spectral Theory

1. Manufacturing scheduling (cycle time optimization)
2. Network routing (max-bandwidth paths)
3. Neural network analysis (ReLU tropical structure)
"""

import numpy as np

def manufacturing_scheduling():
    """
    Application: Cyclic manufacturing schedule optimization.

    A factory has 4 machines operating in a cycle. A_ij represents
    the minimum time between completion of machine j and the start
    of machine i (including processing + transfer time).

    The tropical eigenvalue λ gives the minimum cycle time (throughput),
    and the eigenvector gives optimal start time offsets.
    """
    print("=" * 60)
    print("APPLICATION 1: Manufacturing Cycle Time Optimization")
    print("=" * 60)

    # Processing + transfer times between machines
    A = np.array([
        [10,  5,  3,  7],   # Machine 0 after each
        [ 4, 12,  6,  2],   # Machine 1 after each
        [ 8,  1,  9,  4],   # Machine 2 after each
        [ 3,  5,  2, 11]    # Machine 3 after each
    ], dtype=float)

    print(f"\nProcessing/transfer matrix (minutes):\n{A}")

    # Compute spectral value (= cycle time)
    from algorithms import csr_eigenvector
    lam, v, crit_nodes, crit_edges = csr_eigenvector(A)

    print(f"\nMinimum cycle time: {lam:.1f} minutes")
    print(f"Optimal start offsets: {np.round(v, 2)}")
    print(f"Bottleneck machines: {crit_nodes}")
    print(f"Critical path edges: {crit_edges}")
    print(f"\nInterpretation: Every {lam:.1f} minutes, one unit completes.")
    print("The critical path determines the throughput bottleneck.")


def network_max_bandwidth():
    """
    Application: Maximum bandwidth path in a network.

    In a communication network, A_ij = log(bandwidth) of link j→i.
    The tropical eigenvalue gives the max sustainable throughput
    for cyclic routing patterns.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Throughput Analysis")
    print("=" * 60)

    # Log-bandwidth matrix (log Mbps)
    A = np.array([
        [0.0, 2.3, 1.5],   # Server 0
        [1.8, 0.0, 2.0],   # Server 1
        [2.5, 1.2, 0.0]    # Server 2
    ], dtype=float)

    print(f"\nLog-bandwidth matrix (ln Mbps):\n{np.round(A, 2)}")

    from algorithms import csr_eigenvector
    lam, v, crit_nodes, crit_edges = csr_eigenvector(A)

    print(f"\nMax cycle throughput: e^{lam:.3f} = {np.exp(lam):.2f} Mbps")
    print(f"Optimal buffer levels: {np.round(v, 3)}")
    print(f"Bottleneck links: {crit_edges}")


def relu_tropical_analysis():
    """
    Application: Tropical analysis of ReLU network layer.

    A single-layer ReLU network computes max(Wx + b, 0).
    In the tropical limit, this becomes a max-plus linear map.
    The tropical eigenvalue controls the growth rate under iteration.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: ReLU Network Tropical Growth Rate")
    print("=" * 60)

    # Weight matrix of a ReLU layer
    W = np.array([
        [0.5, 1.2, -0.3],
        [0.8, -0.1, 0.9],
        [-0.2, 0.7, 0.4]
    ], dtype=float)

    print(f"\nReLU weight matrix W:\n{np.round(W, 2)}")

    from algorithms import csr_eigenvector, tropical_power_iteration
    lam, v, crit_nodes, _ = csr_eigenvector(W)

    print(f"\nTropical growth rate (eigenvalue): {lam:.4f}")
    print(f"Invariant direction (eigenvector): {np.round(v, 4)}")
    print(f"Critical neurons: {crit_nodes}")

    if lam > 0:
        print("\n→ Network amplifies signals (growth rate > 0)")
        print(f"  After k iterations, signals grow by ~{lam:.3f} per step")
    elif lam < 0:
        print("\n→ Network attenuates signals (growth rate < 0)")
    else:
        print("\n→ Network is at critical balance")

    # Simulate tropical iteration
    print("\nTropical power iteration convergence:")
    x = np.zeros(3)
    for k in range(8):
        x_new = np.array([max(W[i, j] + x[j] for j in range(3)) for i in range(3)])
        growth = np.mean(x_new - x) if k > 0 else 0
        print(f"  k={k}: x = {np.round(x, 3)}, growth = {growth:.4f}")
        x = x_new


if __name__ == "__main__":
    manufacturing_scheduling()
    network_max_bandwidth()
    relu_tropical_analysis()


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""
import json
import sys

# Read files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
defs_lean = read_file('Tropical/Defs.lean')
existence_lean = read_file('Tropical/Existence.lean')

# Generate visualizations
from visualizations import visualize_critical_graph, visualize_convergence, visualize_cycle_means
viz_crit = visualize_critical_graph()
viz_conv = visualize_convergence()
viz_cycle = visualize_cycle_means()

package = {
    "title": "Certified Tropical Eigenvector Existence: Spectral Theory at the Interface of Graph Algorithms, Max-Plus Algebra, and Difference Constraints",
    "domain": "Tropical Algebra / Max-Plus Spectral Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Spectral Theory Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Karp's Maximum Cycle Mean Algorithm",
            "pseudocode": "Input: n×n weight matrix A\nOutput: Maximum cycle mean λ\n\n1. Initialize dp[0][i] = 0 for all i\n2. For k = 1 to n:\n     For i = 0 to n-1:\n       dp[k][i] = max_j (dp[k-1][j] + A[j][i])\n3. λ = max_i min_{k<n} (dp[n][i] - dp[k][i]) / (n - k)\n\nTime: O(n³), Space: O(n²)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Critical Graph Structure",
            "data": f"data:image/png;base64,{viz_crit}"
        },
        {
            "name": "Tropical Power Iteration Convergence",
            "data": f"data:image/png;base64,{viz_conv}"
        },
        {
            "name": "Cycle Mean Distribution",
            "data": f"data:image/png;base64,{viz_cycle}"
        }
    ],
    "lean_proofs": defs_lean + "\n\n" + existence_lean
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
demo.py — Tropical Spectral Theory: Concrete Numerical Examples

Demonstrates the tropical (max-plus) Perron–Frobenius mechanism:
1. Compute the tropical spectral value (maximum cycle mean)
2. Construct the potential/subeigenvector
3. Identify the critical graph
4. Verify eigenvector equality on critical nodes
"""

import numpy as np
from itertools import product

def trop_mul_vec(A, v):
    """Tropical (max-plus) matrix-vector product: (A ⊗ v)_i = max_j (A_ij + v_j)."""
    n = A.shape[0]
    return np.array([max(A[i, j] + v[j] for j in range(n)) for i in range(n)])

def all_cycles(n, max_length=None):
    """Generate all directed cycles of length 1..max_length in the complete graph on n vertices."""
    if max_length is None:
        max_length = n
    for k in range(1, max_length + 1):
        for cycle in product(range(n), repeat=k):
            yield cycle

def cycle_weight(A, cycle):
    """Total weight of a directed cycle."""
    return sum(A[cycle[i], cycle[(i+1) % len(cycle)]] for i in range(len(cycle)))

def cycle_mean(A, cycle):
    """Mean weight of a directed cycle."""
    return cycle_weight(A, cycle) / len(cycle)

def tropical_spectral_value(A):
    """Compute the tropical spectral value: max cycle mean over all cycles of length 1..n."""
    n = A.shape[0]
    best = -np.inf
    best_cycle = None
    for cycle in all_cycles(n):
        m = cycle_mean(A, cycle)
        if m > best:
            best = m
            best_cycle = cycle
    return best, best_cycle

def walk_weight(A, i, walk):
    """Weight of a walk i → walk[0] → walk[1] → ... → walk[-1]."""
    if len(walk) == 0:
        return 0.0
    w = A[i, walk[0]]
    for k in range(len(walk) - 1):
        w += A[walk[k], walk[k+1]]
    return w

def best_walk_weight(A, i, m):
    """Maximum weight among all walks of length m from vertex i."""
    n = A.shape[0]
    if m == 0:
        return 0.0
    best = -np.inf
    for walk in product(range(n), repeat=m):
        w = walk_weight(A, i, walk)
        if w > best:
            best = w
    return best

def potential(A, lam, i):
    """Potential function: max_{m < n} (bestWalk(i, m) - m * lam)."""
    n = A.shape[0]
    return max(best_walk_weight(A, i, m) - m * lam for m in range(n))

def construct_subeigenvector(A):
    """Construct the tropical subeigenvector at the spectral value."""
    n = A.shape[0]
    lam, best_cycle = tropical_spectral_value(A)
    v = np.array([potential(A, lam, i) for i in range(n)])
    return lam, v, best_cycle

def identify_critical_graph(A, lam, v, tol=1e-10):
    """Identify critical edges and nodes."""
    n = A.shape[0]
    critical_edges = []
    critical_nodes = set()
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] + v[j] - lam - v[i]) < tol:
                critical_edges.append((i, j))
                critical_nodes.add(i)
    return critical_edges, critical_nodes

def verify_subeigenvector(A, lam, v, tol=1e-10):
    """Verify subeigenvector condition: (A ⊗ v)_i ≤ lam + v_i for all i."""
    tv = trop_mul_vec(A, v)
    return all(tv[i] <= lam + v[i] + tol for i in range(A.shape[0]))

def verify_eigenvector_on_critical(A, lam, v, critical_nodes, tol=1e-10):
    """Verify eigenvector equality on critical nodes."""
    tv = trop_mul_vec(A, v)
    return all(abs(tv[i] - lam - v[i]) < tol for i in critical_nodes)


def demo_example_1():
    """Simple 3×3 example."""
    print("=" * 60)
    print("EXAMPLE 1: Simple 3×3 Matrix")
    print("=" * 60)

    A = np.array([
        [1, 3, 2],
        [4, 1, 5],
        [2, 3, 1]
    ], dtype=float)

    print(f"\nMatrix A:\n{A}")

    lam, v, best_cycle = construct_subeigenvector(A)
    print(f"\nTropical spectral value λ = {lam:.4f}")
    print(f"Optimal cycle: {best_cycle}")
    print(f"Subeigenvector v = {v}")

    tv = trop_mul_vec(A, v)
    print(f"\nTropical product (A ⊗ v) = {tv}")
    print(f"λ + v = {lam + v}")

    critical_edges, critical_nodes = identify_critical_graph(A, lam, v)
    print(f"\nCritical edges: {critical_edges}")
    print(f"Critical nodes: {critical_nodes}")

    is_sub = verify_subeigenvector(A, lam, v)
    print(f"\nSubeigenvector verified: {is_sub}")

    is_eig = verify_eigenvector_on_critical(A, lam, v, critical_nodes)
    print(f"Eigenvector on critical: {is_eig}")

    for i in range(A.shape[0]):
        gap = tv[i] - lam - v[i]
        status = "TIGHT (critical)" if i in critical_nodes else f"slack = {gap:.4f}"
        print(f"  Node {i}: (A⊗v)_i = {tv[i]:.4f}, λ+v_i = {lam+v[i]:.4f} → {status}")


def demo_example_2():
    """Scheduling application: job processing times."""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Job Scheduling (Max-Plus Dynamics)")
    print("=" * 60)

    # 4-machine cyclic production: A_ij = time for machine i after machine j
    A = np.array([
        [0, 5, 3, 7],
        [4, 0, 6, 2],
        [8, 1, 0, 4],
        [3, 5, 2, 0]
    ], dtype=float)

    print(f"\nProcessing time matrix A:\n{A}")

    lam, v, best_cycle = construct_subeigenvector(A)
    print(f"\nCycle time (tropical eigenvalue) λ = {lam:.4f}")
    print(f"Bottleneck cycle: {best_cycle}")
    print(f"Optimal schedule offsets v = {v}")

    critical_edges, critical_nodes = identify_critical_graph(A, lam, v)
    print(f"\nCritical path edges: {critical_edges}")
    print(f"Critical machines: {critical_nodes}")

    is_sub = verify_subeigenvector(A, lam, v)
    is_eig = verify_eigenvector_on_critical(A, lam, v, critical_nodes)
    print(f"\nSubeigenvector: {is_sub}, Critical equality: {is_eig}")


def demo_example_3():
    """Difference constraints / shortest path duality."""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Difference Constraints Duality")
    print("=" * 60)

    A = np.array([
        [2, 6],
        [5, 3]
    ], dtype=float)

    print(f"\nMatrix A:\n{A}")

    lam, v, _ = construct_subeigenvector(A)
    print(f"\nSpectral value λ = {lam:.4f}")
    print(f"Subeigenvector v = {v}")

    print("\nDifference constraints (v_j - v_i ≤ λ - A_ij):")
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            lhs = v[j] - v[i]
            rhs = lam - A[i, j]
            satisfied = "✓" if lhs <= rhs + 1e-10 else "✗"
            tight = " (TIGHT)" if abs(lhs - rhs) < 1e-10 else ""
            print(f"  v_{j} - v_{i} = {lhs:.2f} ≤ {rhs:.2f} = λ - A_{i}{j} {satisfied}{tight}")


def demo_min_max_duality():
    """Min-plus / Max-plus duality."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Min-Plus / Max-Plus Duality")
    print("=" * 60)

    A = np.array([
        [1, 4, 2],
        [3, 2, 5],
        [4, 1, 3]
    ], dtype=float)

    print(f"\nMax-plus matrix A:\n{A}")

    lam_max, v_max, _ = construct_subeigenvector(A)
    print(f"\nMax-plus: λ = {lam_max:.4f}, v = {v_max}")

    # Negation duality: min-plus on -A with -v, eigenvalue -λ
    B = -A
    lam_min, v_min, _ = construct_subeigenvector(B)

    print(f"Min-plus on -A: λ = {lam_min:.4f}, v = {v_min}")
    print(f"\nDuality check: λ_max = {lam_max:.4f}, -λ_min(-A) = {-lam_min:.4f}")
    print(f"Match: {abs(lam_max + lam_min) < 1e-10}")


if __name__ == "__main__":
    demo_example_1()
    demo_example_2()
    demo_example_3()
    demo_min_max_duality()


#!/usr/bin/env python3
"""
visualizations.py — Tropical Spectral Theory Visualizations

Generates figures illustrating key concepts:
1. Critical graph structure
2. Tropical power convergence
3. Subeigenvector / eigenvector comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import base64
from io import BytesIO

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def visualize_critical_graph():
    """Visualize the critical graph of a 4×4 matrix."""
    A = np.array([
        [1, 3, 2, 0],
        [4, 1, 5, 2],
        [2, 3, 1, 4],
        [1, 2, 3, 2]
    ], dtype=float)

    n = 4
    from algorithms import csr_eigenvector
    lam, v, crit_nodes, crit_edges = csr_eigenvector(A)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Node positions (circle layout)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    pos = {i: (np.cos(angles[i]), np.sin(angles[i])) for i in range(n)}

    # Left: Full graph with critical edges highlighted
    ax1.set_title('Weighted Digraph with Critical Edges', fontsize=14, fontweight='bold')
    ax1.set_xlim(-1.8, 1.8)
    ax1.set_ylim(-1.8, 1.8)
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Draw all edges
    for i in range(n):
        for j in range(n):
            if i != j:
                is_crit = (i, j) in crit_edges
                color = '#e74c3c' if is_crit else '#bdc3c7'
                width = 2.5 if is_crit else 0.8
                alpha = 1.0 if is_crit else 0.3

                dx = pos[j][0] - pos[i][0]
                dy = pos[j][1] - pos[i][1]
                ax1.annotate('', xy=(pos[j][0]-0.12*dx, pos[j][1]-0.12*dy),
                           xytext=(pos[i][0]+0.12*dx, pos[i][1]+0.12*dy),
                           arrowprops=dict(arrowstyle='->', color=color,
                                         lw=width, connectionstyle='arc3,rad=0.15'),
                           alpha=alpha)

    # Draw nodes
    for i in range(n):
        color = '#e74c3c' if i in crit_nodes else '#3498db'
        circle = plt.Circle(pos[i], 0.15, color=color, zorder=5)
        ax1.add_patch(circle)
        ax1.text(pos[i][0], pos[i][1], str(i), ha='center', va='center',
                fontsize=14, fontweight='bold', color='white', zorder=6)

    ax1.text(0, -1.5, f'λ = {lam:.2f}', ha='center', fontsize=13,
            style='italic', color='#2c3e50')

    # Right: Subeigenvector values and gap
    ax2.set_title('Tropical Action vs Eigenvalue Bound', fontsize=14, fontweight='bold')
    tv = np.array([max(A[i, j] + v[j] for j in range(n)) for i in range(n)])
    bound = lam + v

    x_pos = np.arange(n)
    width = 0.35
    bars1 = ax2.bar(x_pos - width/2, tv, width, label='(A⊗v)ᵢ', color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x_pos + width/2, bound, width, label='λ + vᵢ', color='#e74c3c', alpha=0.8)

    for i in range(n):
        gap = bound[i] - tv[i]
        marker = '=' if abs(gap) < 1e-8 else f'+{gap:.2f}'
        color = '#27ae60' if abs(gap) < 1e-8 else '#f39c12'
        ax2.text(i, max(tv[i], bound[i]) + 0.2, marker,
                ha='center', fontsize=11, fontweight='bold', color=color)

    ax2.set_xlabel('Node index', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_xticks(x_pos)
    ax2.legend(fontsize=11)
    ax2.grid(axis='y', alpha=0.3)

    legend_crit = mpatches.Patch(color='#e74c3c', label='Critical (equality)')
    legend_slack = mpatches.Patch(color='#f39c12', label='Slack (strict inequality)')

    plt.tight_layout()
    fig.savefig('critical_graph.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def visualize_convergence():
    """Visualize tropical power iteration convergence."""
    A = np.array([
        [1, 3, 2],
        [4, 1, 5],
        [2, 3, 1]
    ], dtype=float)

    n = 3
    from algorithms import karp_max_cycle_mean
    lam_true, _ = karp_max_cycle_mean(A)

    # Power iteration
    x = np.zeros(n)
    growth_rates = []
    normalized_vecs = []

    for k in range(20):
        x_new = np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])
        if k > 0:
            growth = np.mean(x_new - x)
            growth_rates.append(growth)
        normalized_vecs.append(x - np.mean(x))
        x = x_new

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Growth rate convergence
    ax1.set_title('Growth Rate Convergence to λ', fontsize=14, fontweight='bold')
    ax1.plot(range(1, len(growth_rates)+1), growth_rates, 'o-', color='#3498db',
            linewidth=2, markersize=6, label='Growth rate')
    ax1.axhline(y=lam_true, color='#e74c3c', linestyle='--', linewidth=2,
               label=f'True λ = {lam_true:.3f}')
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Average growth', fontsize=12)
    ax1.legend(fontsize=11)
    ax1.grid(alpha=0.3)

    # Right: Normalized vector convergence
    ax2.set_title('Normalized Eigenvector Convergence', fontsize=14, fontweight='bold')
    vecs = np.array(normalized_vecs)
    colors = ['#3498db', '#e74c3c', '#27ae60']
    for i in range(n):
        ax2.plot(range(len(vecs)), vecs[:, i], 'o-', color=colors[i],
                linewidth=2, markersize=4, label=f'v_{i}', alpha=0.8)
    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Normalized component', fontsize=12)
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    fig.savefig('convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def visualize_cycle_means():
    """Visualize cycle mean distribution and spectral value."""
    A = np.array([
        [1, 3, 2],
        [4, 1, 5],
        [2, 3, 1]
    ], dtype=float)

    n = 3
    from itertools import product as iproduct

    means = []
    for k in range(1, n+1):
        for cycle in iproduct(range(n), repeat=k):
            w = sum(A[cycle[i], cycle[(i+1) % k]] for i in range(k))
            means.append(w / k)

    from algorithms import karp_max_cycle_mean
    lam, _ = karp_max_cycle_mean(A)

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.set_title('Distribution of Cycle Means', fontsize=14, fontweight='bold')
    ax.hist(means, bins=30, color='#3498db', alpha=0.7, edgecolor='white')
    ax.axvline(x=lam, color='#e74c3c', linestyle='--', linewidth=2.5,
              label=f'λ (max cycle mean) = {lam:.3f}')
    ax.set_xlabel('Cycle Mean', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.legend(fontsize=12)
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    fig.savefig('cycle_means.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_crit = visualize_critical_graph()
    print(f"  Critical graph: {len(b64_crit)} chars")
    b64_conv = visualize_convergence()
    print(f"  Convergence: {len(b64_conv)} chars")
    b64_cycle = visualize_cycle_means()
    print(f"  Cycle means: {len(b64_cycle)} chars")
    print("Done. Figures saved as PNG.")
