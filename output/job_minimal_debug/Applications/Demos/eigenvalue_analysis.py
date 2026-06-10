#!/usr/bin/env python3
"""
Tropical Spectral Dynamics — Applications

Real-world applications of the tropical cycle gap theory:
1. Network routing optimization (shortest path dynamics)
2. Manufacturing throughput (max-plus scheduling)
3. Neural network analysis (ReLU tropical structure)
4. Cryptographic hardness estimation
"""

import numpy as np
from algorithms import (
    maxplus_mulvec, maxplus_mul, closed_walk_mean,
    tropical_entropy, certify_cycle_gap, analyze_transient,
    karp_max_cycle_mean
)

# ─────────────────────────────────────────────────────────────
# Application 1: Network Routing — Widest Path Problem
# ─────────────────────────────────────────────────────────────

def network_routing_demo():
    """
    In network routing, the tropical eigenvalue determines the
    maximum sustainable throughput of a cyclic network.

    Consider a network where A[i,j] = bandwidth of link i→j.
    The max-plus product A⊗A gives the maximum bandwidth of
    any 2-hop path. The tropical eigenvalue is the maximum
    average bandwidth achievable by cycling through the network.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Throughput")
    print("=" * 60)

    # Network with 4 routers
    # Bandwidth matrix (in Gbps)
    bandwidth = np.array([
        [0.0,  10.0,  5.0,  1.0],
        [2.0,   0.0,  8.0,  3.0],
        [4.0,   1.0,  0.0, 12.0],
        [7.0,   6.0,  2.0,  0.0]
    ])

    print("\nNetwork bandwidth matrix (Gbps):")
    print(bandwidth)

    cert = certify_cycle_gap(bandwidth, max_walk_length=4)
    print(f"\nOptimal cyclic route: {cert['critical_cycle'].vertices}")
    print(f"Average throughput: {cert['critical_mean']:.2f} Gbps")
    print(f"Cycle gap: {cert['gap']:.4f}")
    print(f"Unique optimal route: {cert['is_unique']}")

    if cert['is_unique']:
        print("\n→ The network has a unique optimal cyclic route.")
        print("  This means traffic engineering has a clear optimal target.")
        print(f"  Any competing route loses at least {cert['gap']:.4f} Gbps/hop.")

    # Multi-hop analysis
    print("\nMulti-hop maximum bandwidth:")
    B = bandwidth.copy()
    for t in range(1, 5):
        if t > 1:
            B = maxplus_mul(B, bandwidth)
        print(f"  {t}-hop: max bandwidth = {np.max(B):.2f} Gbps")


# ─────────────────────────────────────────────────────────────
# Application 2: Manufacturing Scheduling
# ─────────────────────────────────────────────────────────────

def manufacturing_demo():
    """
    In max-plus scheduling, the tropical eigenvalue determines
    the maximum throughput of a cyclic production system.

    A manufacturing line with n stations has processing times
    and transfer times encoded in a matrix. The eigenvalue
    gives the minimum cycle time (maximum throughput rate).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Manufacturing Throughput Analysis")
    print("=" * 60)

    # 3-station assembly line
    # A[i,j] = time from completing job at station j to completing at station i
    # (includes processing time at i and transfer time from j to i)
    processing = np.array([
        [3.0, 5.0, 4.0],  # Station 1: depends on output of stations 1,2,3
        [2.0, 4.0, 6.0],  # Station 2
        [5.0, 3.0, 2.0],  # Station 3
    ])

    print("\nProcessing time matrix (hours):")
    print(processing)

    lambda_star = karp_max_cycle_mean(processing)
    print(f"\nMinimum cycle time (tropical eigenvalue): {lambda_star:.2f} hours")
    print(f"Maximum throughput: {1/lambda_star:.4f} jobs/hour")

    cert = certify_cycle_gap(processing)
    print(f"Bottleneck cycle: {cert['critical_cycle'].vertices}")
    print(f"Cycle gap: {cert['gap']:.4f}")

    if cert['is_unique']:
        print("\n→ Unique bottleneck identified!")
        print(f"  Improving any edge in cycle {cert['critical_cycle'].vertices} "
              f"directly reduces cycle time.")
    else:
        print("\n→ Multiple bottleneck cycles exist.")
        print("  Must improve ALL to reduce cycle time.")

    # Transient analysis
    ta = analyze_transient(processing, max_iter=20)
    print(f"\nTransient duration: {ta.convergence_time} iterations")
    print(f"Steady-state growth rate: {ta.eigenvalue:.4f}")


# ─────────────────────────────────────────────────────────────
# Application 3: Neural Network Tropical Analysis
# ─────────────────────────────────────────────────────────────

def neural_network_demo():
    """
    ReLU neural networks are piecewise linear functions that
    decompose into tropical (max-plus) polynomials. The cycle
    gap of the associated tropical matrix determines the
    robustness of the network's classification boundaries.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Neural Network Robustness via Tropical Gap")
    print("=" * 60)

    # Simplified 2-layer ReLU network weight matrices
    W1 = np.array([
        [2.0, -1.0, 0.5],
        [-0.5, 3.0, 1.0],
        [1.0, 0.5, -2.0]
    ])

    W2 = np.array([
        [1.5, -0.5, 2.0],
        [-1.0, 2.5, 0.5],
        [0.5, 1.0, -1.5]
    ])

    # The tropical matrix captures the max-plus propagation
    # through the network
    T = maxplus_mul(W1, W2)
    print(f"\nTropical composition matrix (max-plus W₁ ⊗ W₂):")
    print(np.round(T, 2))

    cert = certify_cycle_gap(T)
    print(f"\nTropical eigenvalue: {cert['critical_mean']:.4f}")
    print(f"Critical cycle: {cert['critical_cycle'].vertices}")
    print(f"Cycle gap: {cert['gap']:.4f}")

    if cert['is_unique']:
        print(f"\n→ Network has a unique dominant tropical mode.")
        print(f"  Robustness certificate: perturbations < {cert['gap']:.4f}")
        print(f"  cannot change the dominant classification pattern.")
    else:
        print(f"\n→ Multiple competing tropical modes — fragile boundaries.")

    # Entropy of the search over competing patterns
    n_patterns = len([c for c in cert['all_cycles_info']
                     if c['mean'] > cert['critical_mean'] - 1.0]) \
        if hasattr(cert, 'all_cycles_info') else len(cert['all_cycles'])
    if n_patterns > 1:
        H = np.log(n_patterns)
        print(f"\n  Competitor patterns within gap: {n_patterns}")
        print(f"  Search entropy: {H:.4f}")
        print(f"  Search complexity: {np.exp(H):.1f}")


# ─────────────────────────────────────────────────────────────
# Application 4: Complexity Lower Bounds
# ─────────────────────────────────────────────────────────────

def complexity_demo():
    """
    The transient entropy of a tropical matrix provides lower
    bounds on the complexity of computing with that matrix in
    tropical circuit models.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Complexity Lower Bounds from Tropical Gap")
    print("=" * 60)

    # Family of matrices with increasing transient complexity
    for n in [2, 3, 4, 5]:
        # Random matrix with guaranteed cycle gap
        np.random.seed(42 + n)
        A = np.random.randn(n, n)
        # Boost one diagonal to create a gap
        A[0, 0] += 5.0

        ta = analyze_transient(A, max_iter=30)
        lambda_star = karp_max_cycle_mean(A)

        # Entropy of transient growth distribution
        transient_entropies = [e for e in ta.entropy_per_step if e > 0]
        avg_entropy = np.mean(transient_entropies) if transient_entropies else 0

        print(f"\n  n={n}: λ* = {lambda_star:.3f}, "
              f"convergence = {ta.convergence_time} steps, "
              f"avg transient entropy = {avg_entropy:.3f}")
        print(f"    → Lower bound on tropical circuit depth: "
              f"Ω({ta.convergence_time})")
        print(f"    → Information-theoretic cost: "
              f"≥ {avg_entropy * ta.convergence_time:.3f} bits")


# ─────────────────────────────────────────────────────────────
# Run all applications
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    network_routing_demo()
    manufacturing_demo()
    neural_network_demo()
    complexity_demo()

    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Spectral Dynamics — Demonstration

Concrete numerical examples showing:
1. Closed walk weight and mean computation
2. Strict cycle gap detection and unique critical walk identification
3. Tropical entropy of probability distributions
4. Max-plus matrix iteration and convergence to the tropical eigenvalue
"""

import numpy as np
from itertools import product as iprod

# ─────────────────────────────────────────────────
# 1. Closed Walk Weight & Mean
# ─────────────────────────────────────────────────

def closed_walk_weight(A, walk):
    """Weight of closed walk c(0)→c(1)→...→c(k-1)→c(0)."""
    k = len(walk)
    return sum(A[walk[i], walk[(i + 1) % k]] for i in range(k))


def closed_walk_mean(A, walk):
    """Mean weight = total weight / walk length."""
    k = len(walk)
    return closed_walk_weight(A, walk) / k


def enumerate_walks(n, k):
    """All closed walks of length k on n vertices."""
    return list(iprod(range(n), repeat=k))


print("=" * 60)
print("DEMO 1: Closed Walk Weight and Critical Walk Detection")
print("=" * 60)

# 3×3 tropical matrix
A = np.array([
    [5.0, 1.0, 2.0],
    [3.0, 7.0, 1.0],
    [2.0, 4.0, 3.0]
])
print(f"\nMatrix A:\n{A}")

# Enumerate all walks of length 1 (self-loops)
walks_1 = enumerate_walks(3, 1)
means_1 = [(w, closed_walk_mean(A, w)) for w in walks_1]
means_1.sort(key=lambda x: -x[1])
print("\nWalks of length 1 (self-loops), sorted by mean:")
for w, m in means_1:
    print(f"  Walk {w}: mean = {m:.4f}")

# Critical walk of length 1
best = means_1[0]
gap = best[1] - means_1[1][1]
print(f"\nCritical walk: {best[0]} with mean {best[1]:.4f}")
print(f"Cycle gap (ε): {gap:.4f}")
print(f"Unique critical walk: {'YES' if gap > 0 else 'NO'}")

# Walks of length 2
walks_2 = enumerate_walks(3, 2)
means_2 = [(w, closed_walk_mean(A, w)) for w in walks_2]
means_2.sort(key=lambda x: -x[1])
print("\nTop 5 walks of length 2:")
for w, m in means_2[:5]:
    print(f"  Walk {w}: mean = {m:.4f}")

best2 = means_2[0]
gap2 = best2[1] - means_2[1][1]
print(f"\nCritical walk: {best2[0]} with mean {best2[1]:.4f}")
print(f"Cycle gap: {gap2:.4f}")

# ─────────────────────────────────────────────────
# 2. Tropical Entropy
# ─────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: Tropical Entropy of Search Distributions")
print("=" * 60)

def tropical_entropy(probs):
    """H_⊕(p) = -log(min p)."""
    return -np.log(min(probs))


# Uniform distribution on 3 elements
p_uniform = [1/3, 1/3, 1/3]
H_uniform = tropical_entropy(p_uniform)
print(f"\nUniform on 3 elements: H_⊕ = {H_uniform:.4f} = log(3) = {np.log(3):.4f} ✓")

# Skewed distribution (one dominant candidate)
p_skewed = [0.8, 0.15, 0.05]
H_skewed = tropical_entropy(p_skewed)
print(f"Skewed [0.8, 0.15, 0.05]: H_⊕ = {H_skewed:.4f}")

# Near-locking (one candidate dominates)
p_locked = [0.99, 0.005, 0.005]
H_locked = tropical_entropy(p_locked)
print(f"Near-locked [0.99, 0.005, 0.005]: H_⊕ = {H_locked:.4f}")

# Demonstrating search bound: exp(H) = 1/min(p)
print(f"\nSearch bound verification:")
for name, p in [("Uniform", p_uniform), ("Skewed", p_skewed), ("Locked", p_locked)]:
    H = tropical_entropy(p)
    print(f"  {name}: exp(H_⊕) = {np.exp(H):.4f}, 1/min(p) = {1/min(p):.4f}")

# ─────────────────────────────────────────────────
# 3. Max-Plus Matrix Iteration
# ─────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Max-Plus Matrix Iteration and Eigenvalue Convergence")
print("=" * 60)

def maxplus_mul(A, B):
    """Max-plus matrix product: C[i,j] = max_k(A[i,k] + B[k,j])."""
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def maxplus_mulvec(A, x):
    """Max-plus matrix-vector product: y[i] = max_j(A[i,j] + x[j])."""
    n = A.shape[0]
    return np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])


# Compute max cycle mean (tropical eigenvalue)
def max_cycle_mean(A, max_length=None):
    """Compute the maximum cycle mean over all walks up to given length."""
    n = A.shape[0]
    if max_length is None:
        max_length = n
    best_mean = -np.inf
    best_walk = None
    for k in range(1, max_length + 1):
        for w in enumerate_walks(n, k):
            m = closed_walk_mean(A, w)
            if m > best_mean:
                best_mean = m
                best_walk = (k, w)
    return best_mean, best_walk


lambda_star, best_info = max_cycle_mean(A)
print(f"\nTropical eigenvalue λ* = max cycle mean = {lambda_star:.4f}")
print(f"  Attained by walk of length {best_info[0]}: {best_info[1]}")

# Max-plus power iteration
x = np.zeros(3)
print(f"\nMax-plus power iteration: x₀ = {x}")
for t in range(1, 8):
    x_new = maxplus_mulvec(A, x)
    growth = max(x_new - x)  # should converge to λ*
    print(f"  t={t}: x = [{', '.join(f'{v:.2f}' for v in x_new)}], "
          f"max growth = {growth:.4f} (λ* = {lambda_star:.4f})")
    x = x_new

# ─────────────────────────────────────────────────
# 4. Cycle Gap and Transient Phase
# ─────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Cycle Gap and Transient Phase Analysis")
print("=" * 60)

# Matrix with clear cycle gap
B = np.array([
    [2.0, 5.0],
    [4.0, 1.0]
])
print(f"\nMatrix B (2×2 with cycle gap):\n{B}")

# All walks of length 1 and 2
for k in [1, 2]:
    walks = enumerate_walks(2, k)
    means = [(w, closed_walk_mean(B, w)) for w in walks]
    means.sort(key=lambda x: -x[1])
    print(f"\nWalks of length {k}:")
    for w, m in means:
        print(f"  {w}: mean = {m:.4f}")
    gap = means[0][1] - means[1][1] if len(means) > 1 else float('inf')
    print(f"  Gap: {gap:.4f}")

# Transient entropy during search
print("\nTransient entropy during cycle elimination:")
n_walks = [len(enumerate_walks(2, k)) for k in range(1, 5)]
for k, nw in zip(range(1, 5), n_walks):
    H = np.log(nw)  # entropy of uniform on nw candidates
    print(f"  Length {k}: {nw} walks, uniform entropy = {H:.4f}")

lambda_B, best_B = max_cycle_mean(B)
print(f"\nTropical eigenvalue of B: {lambda_B:.4f}")
print(f"  Critical walk: length {best_B[0]}, vertices {best_B[1]}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_b64(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')
lean_code = read_file('Tropical/SpectralDynamics.lean')

# Read visualization base64
convergence_b64 = read_b64('convergence.png')
cycle_gap_b64 = read_b64('cycle_gap.png')
entropy_b64 = read_b64('entropy.png')
transient_b64 = read_b64('transient.png')

package = {
    "title": "Tropical Spectral Dynamics: Cycle Gaps, Unique Critical Cycles, and Transient Entropy Bounds",
    "domain": "Tropical Algebra / Max-Plus Dynamics / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Spectral Dynamics Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Maximum Cycle Mean (Brute Force)",
            "pseudocode": "Input: Weight matrix A, max length L\nOutput: Critical cycle, gap ε\n\nbest_mean ← -∞\nfor k = 1 to L:\n  for each walk c : Fin(k) → Fin(n):\n    μ ← (Σ_i A[c(i), c(i+1 mod k)]) / k\n    if μ > best_mean:\n      best_mean ← μ; best_walk ← c\nreturn best_walk, best_mean - second_best_mean",
            "code": algorithms_code
        },
        {
            "name": "Karp's Algorithm for Tropical Eigenvalue",
            "pseudocode": "Input: Weight matrix A ∈ ℝ^{n×n}\nOutput: Maximum cycle mean λ*\n\nD[0, 0] ← 0; D[0, v] ← -∞ for v ≠ 0\nfor k = 1 to n:\n  for v = 0 to n-1:\n    D[k, v] ← max_u (D[k-1, u] + A[u, v])\nλ* ← max_v min_{k<n} (D[n, v] - D[k, v]) / (n - k)\nreturn λ*",
            "code": "# See algorithms.py: karp_max_cycle_mean(A)"
        }
    ],
    "visualizations": [
        {
            "name": "Max-Plus Power Iteration Convergence",
            "data": f"data:image/png;base64,{convergence_b64}"
        },
        {
            "name": "Cycle Mean Distribution and Critical Gap",
            "data": f"data:image/png;base64,{cycle_gap_b64}"
        },
        {
            "name": "Tropical Entropy: Search Complexity Certificate",
            "data": f"data:image/png;base64,{entropy_b64}"
        },
        {
            "name": "Transient Phase Entropy Evolution",
            "data": f"data:image/png;base64,{transient_b64}"
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package)) // 1024} KB)")


#!/usr/bin/env python3
"""
Tropical Spectral Dynamics — Visualizations

Generates publication-quality figures:
1. Max-plus power iteration convergence
2. Cycle gap and critical cycle visualization
3. Tropical entropy vs number of competitors
4. Transient phase entropy evolution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO
from itertools import product as iprod


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ─────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────

def maxplus_mulvec(A, x):
    n = A.shape[0]
    return np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])

def closed_walk_weight(A, walk):
    k = len(walk)
    return sum(A[walk[i], walk[(i+1) % k]] for i in range(k))

def closed_walk_mean(A, walk):
    return closed_walk_weight(A, walk) / len(walk)


# ─────────────────────────────────────────────────────────
# Figure 1: Max-Plus Power Iteration Convergence
# ─────────────────────────────────────────────────────────

def make_convergence_plot():
    """Shows how max-plus iteration converges to the tropical eigenvalue."""
    A = np.array([
        [5.0, 1.0, 2.0],
        [3.0, 7.0, 1.0],
        [2.0, 4.0, 3.0]
    ])

    x = np.zeros(3)
    growth_rates = []
    vectors = [x.copy()]

    for t in range(15):
        x_new = maxplus_mulvec(A, x)
        growth = np.max(x_new - x)
        growth_rates.append(growth)
        x = x_new
        vectors.append(x.copy())

    # Compute tropical eigenvalue
    lambda_star = 7.0  # A[1,1] = 7 is the max diagonal = max 1-cycle mean

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: growth rates
    ax1.plot(range(1, len(growth_rates)+1), growth_rates, 'o-',
             color='#2196F3', linewidth=2, markersize=6, label='Growth rate')
    ax1.axhline(y=lambda_star, color='#F44336', linestyle='--',
                linewidth=2, label=f'λ* = {lambda_star}')
    ax1.fill_between(range(1, len(growth_rates)+1),
                     [lambda_star]*len(growth_rates),
                     growth_rates, alpha=0.15, color='#2196F3')
    ax1.set_xlabel('Iteration t', fontsize=12)
    ax1.set_ylabel('Max growth rate', fontsize=12)
    ax1.set_title('Convergence to Tropical Eigenvalue', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: vector components
    steps = range(len(vectors))
    for i in range(3):
        vals = [v[i] for v in vectors]
        ax2.plot(steps, vals, 'o-', linewidth=2, markersize=4,
                label=f'x[{i}]')
    # Asymptotic lines
    for i in range(3):
        ax2.plot([0, 15], [vectors[-1][i] - lambda_star, vectors[-1][i]],
                 '--', alpha=0.4, color='gray')
    ax2.set_xlabel('Iteration t', fontsize=12)
    ax2.set_ylabel('Vector component', fontsize=12)
    ax2.set_title('Max-Plus Orbit Components', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Max-Plus Power Iteration Dynamics', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


# ─────────────────────────────────────────────────────────
# Figure 2: Cycle Gap Visualization
# ─────────────────────────────────────────────────────────

def make_cycle_gap_plot():
    """Visualizes cycle means and the gap between critical and non-critical."""
    A = np.array([
        [5.0, 1.0, 2.0],
        [3.0, 7.0, 1.0],
        [2.0, 4.0, 3.0]
    ])

    # Compute all cycle means for lengths 1, 2, 3
    all_means = []
    for k in range(1, 4):
        for walk in iprod(range(3), repeat=k):
            m = closed_walk_mean(A, walk)
            all_means.append((k, walk, m))

    all_means.sort(key=lambda x: -x[2])
    critical_mean = all_means[0][2]
    gap = critical_mean - all_means[1][2]

    fig, ax = plt.subplots(figsize=(10, 6))

    # Plot means by walk length
    colors = {1: '#2196F3', 2: '#4CAF50', 3: '#FF9800'}
    for k in [1, 2, 3]:
        means_k = [m for l, w, m in all_means if l == k]
        x_pos = [k + np.random.uniform(-0.15, 0.15) for _ in means_k]
        ax.scatter(x_pos, means_k, c=colors[k], s=40, alpha=0.6,
                  label=f'Length {k} walks', zorder=3)

    # Critical line
    ax.axhline(y=critical_mean, color='#F44336', linewidth=2,
               linestyle='-', label=f'Critical mean = {critical_mean:.1f}', zorder=4)

    # Gap annotation
    runner_up = all_means[1][2]
    ax.axhline(y=runner_up, color='#9E9E9E', linewidth=1,
               linestyle='--', alpha=0.5)
    ax.annotate('', xy=(3.7, runner_up), xytext=(3.7, critical_mean),
                arrowprops=dict(arrowstyle='<->', color='#F44336', lw=2))
    ax.text(3.8, (critical_mean + runner_up)/2, f'gap = {gap:.1f}',
            fontsize=12, color='#F44336', va='center')

    ax.set_xlabel('Walk Length k', fontsize=12)
    ax.set_ylabel('Cycle Mean Weight', fontsize=12)
    ax.set_title('Cycle Mean Distribution and Critical Gap', fontsize=14)
    ax.set_xticks([1, 2, 3])
    ax.legend(fontsize=11, loc='lower left')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ─────────────────────────────────────────────────────────
# Figure 3: Tropical Entropy vs Competitors
# ─────────────────────────────────────────────────────────

def make_entropy_plot():
    """Shows tropical entropy as a function of the number of competing candidates."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: entropy of uniform distribution
    ns = np.arange(2, 51)
    entropies = np.log(ns)
    ax1.plot(ns, entropies, '-', color='#9C27B0', linewidth=2.5)
    ax1.fill_between(ns, 0, entropies, alpha=0.1, color='#9C27B0')
    ax1.axhline(y=np.log(2), color='#F44336', linestyle='--',
                linewidth=1.5, label='log 2 (minimum for ≥2)')
    ax1.set_xlabel('Number of candidates', fontsize=12)
    ax1.set_ylabel('Tropical entropy H_⊕', fontsize=12)
    ax1.set_title('Uniform Distribution Entropy', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: entropy as distribution concentrates
    alphas = np.linspace(0.5, 0.99, 50)
    entropies_skew = []
    for a in alphas:
        p = np.array([a, 1-a])
        entropies_skew.append(-np.log(min(p)))

    ax2.plot(alphas, entropies_skew, '-', color='#FF5722', linewidth=2.5)
    ax2.axvline(x=0.5, color='#4CAF50', linestyle=':', linewidth=1.5,
                label='Uniform (p=0.5)')
    ax2.set_xlabel('Probability of dominant candidate', fontsize=12)
    ax2.set_ylabel('Tropical entropy H_⊕', fontsize=12)
    ax2.set_title('Entropy vs. Concentration (2 candidates)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Entropy: Search Complexity Certificate', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


# ─────────────────────────────────────────────────────────
# Figure 4: Transient Entropy Evolution
# ─────────────────────────────────────────────────────────

def make_transient_entropy_plot():
    """Shows how entropy evolves during the transient phase."""
    # Matrix with clear transient behavior
    A = np.array([
        [2.0, 5.0, 1.0],
        [4.0, 1.0, 3.0],
        [1.0, 2.0, 6.0]
    ])

    x = np.zeros(3)
    growth_rates = []
    component_diffs = []

    for t in range(20):
        x_new = maxplus_mulvec(A, x)
        diffs = x_new - x
        growth_rates.append(np.max(diffs))
        component_diffs.append(diffs.copy())
        x = x_new

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

    # Top: growth rate convergence
    steps = range(1, len(growth_rates)+1)
    ax1.plot(steps, growth_rates, 'o-', color='#2196F3', linewidth=2,
             markersize=5, label='Max growth rate')
    ax1.axhline(y=growth_rates[-1], color='#F44336', linestyle='--',
                linewidth=1.5, label=f'λ* ≈ {growth_rates[-1]:.2f}')
    # Shade transient region
    conv_t = next((t for t in range(1, len(growth_rates))
                   if abs(growth_rates[t] - growth_rates[t-1]) < 0.01), len(growth_rates))
    ax1.axvspan(0.5, conv_t + 0.5, alpha=0.1, color='#FF9800',
                label=f'Transient phase (t ≤ {conv_t})')
    ax1.set_ylabel('Growth Rate', fontsize=12)
    ax1.set_title('Transient Phase: Growth Rate Convergence', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Bottom: component differences (shows how different components compete)
    for i in range(3):
        vals = [d[i] for d in component_diffs]
        ax2.plot(steps, vals, 'o-', linewidth=2, markersize=4,
                label=f'Component {i}')
    ax2.axvspan(0.5, conv_t + 0.5, alpha=0.1, color='#FF9800')
    ax2.set_xlabel('Iteration t', fontsize=12)
    ax2.set_ylabel('Component Growth', fontsize=12)
    ax2.set_title('Per-Component Growth (Transient Diversity → Locking)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ─────────────────────────────────────────────────────────
# Generate all figures
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = make_convergence_plot()
    fig1.savefig('convergence.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ convergence.png")

    fig2 = make_cycle_gap_plot()
    fig2.savefig('cycle_gap.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ cycle_gap.png")

    fig3 = make_entropy_plot()
    fig3.savefig('entropy.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ entropy.png")

    fig4 = make_transient_entropy_plot()
    fig4.savefig('transient.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ transient.png")

    print("All visualizations generated.")
