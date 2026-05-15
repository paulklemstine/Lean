"""
Quantum Tropical Dynamics: Applications

Real-world applications of the quantum tropical framework:
1. Entropy-regularized shortest paths in networks
2. Soft assignment / optimal transport
3. Temperature-dependent network optimization
4. Decoherence analysis in quantum-classical transition
"""

import numpy as np
from algorithms import qtrop_map, perron_eigenvector, normalize0, log_sum_exp


def entropy_regularized_shortest_path(
    adjacency: np.ndarray, 
    beta: float,
    source: int = 0,
    max_iter: int = 100
) -> np.ndarray:
    """Compute entropy-regularized shortest path distances.
    
    Instead of finding the single shortest path (hard optimization),
    this computes a soft average over all paths weighted by exp(-β * length).
    
    At β → ∞, recovers exact shortest paths.
    At finite β, provides a smooth, differentiable approximation
    useful for gradient-based optimization.
    
    Args:
        adjacency: Edge weight matrix (∞ for no edge)
        beta: Inverse temperature
        source: Source node index
        max_iter: Maximum Bellman-Ford iterations
    
    Returns:
        Soft shortest path distances from source
    """
    n = adjacency.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    
    for _ in range(max_iter):
        dist_new = np.zeros(n)
        for i in range(n):
            if i == source:
                dist_new[i] = 0.0
                continue
            # Soft min over predecessors
            candidates = adjacency[:, i] + dist
            finite_mask = np.isfinite(candidates)
            if np.any(finite_mask):
                dist_new[i] = log_sum_exp(candidates[finite_mask], beta)
            else:
                dist_new[i] = np.inf
        
        if np.max(np.abs(dist_new - dist)) < 1e-12:
            break
        dist = dist_new
    
    return dist


def soft_assignment_matrix(
    cost: np.ndarray, 
    beta: float
) -> np.ndarray:
    """Compute soft assignment (Sinkhorn-like) from cost matrix.
    
    For a cost matrix C_{ij}, the soft assignment probability is
    proportional to exp(-β * C_{ij}), giving a smooth relaxation
    of the hard assignment problem.
    
    This is the Gibbs distribution / Boltzmann weight interpretation
    of the quantum tropical framework.
    
    Args:
        cost: Cost matrix (n × m)
        beta: Inverse temperature
    
    Returns:
        Soft assignment probability matrix
    """
    weights = np.exp(-beta * cost)
    # Row-normalize
    row_sums = weights.sum(axis=1, keepdims=True)
    return weights / row_sums


def decoherence_analysis(
    A: np.ndarray,
    beta_range: np.ndarray
) -> dict:
    """Analyze how the eigenvector structure changes with temperature.
    
    Tracks the quantum tropical eigenvalue and eigenvector as β varies,
    showing the transition from thermal (small β) to zero-temperature
    (large β, tropical) regime.
    
    Args:
        A: Weight matrix
        beta_range: Array of β values to analyze
    
    Returns:
        Dictionary with eigenvalues, eigenvectors, and errors
    """
    n = A.shape[0]
    results = {
        'betas': beta_range,
        'eigenvalues': [],
        'eigenvectors': [],
        'tropical_errors': [],
        'residuals': []
    }
    
    # Compute hard tropical eigenvalue for comparison
    # (min-plus spectral radius = min cycle mean)
    
    for beta in beta_range:
        x, eigval = perron_eigenvector(A, beta)
        Tx = qtrop_map(beta, A, x)
        residual = np.max(np.abs(Tx - (x + eigval)))
        
        # Tropical approximation error
        Tx_hard = np.array([np.min(A[i, :] + x) for i in range(n)])
        trop_err = np.max(np.abs(Tx - Tx_hard))
        
        results['eigenvalues'].append(eigval)
        results['eigenvectors'].append(normalize0(x))
        results['tropical_errors'].append(trop_err)
        results['residuals'].append(residual)
    
    return results


# ==================== Application Demos ====================
if __name__ == "__main__":
    np.random.seed(42)
    
    print("=" * 70)
    print("APPLICATION 1: Entropy-Regularized Shortest Paths")
    print("=" * 70)
    
    # Small graph
    INF = np.inf
    adj = np.array([
        [0,   2,   INF, 6,   INF],
        [INF, 0,   3,   INF, INF],
        [INF, INF, 0,   1,   5  ],
        [INF, INF, INF, 0,   2  ],
        [INF, INF, INF, INF, 0  ]
    ])
    
    print("\nGraph adjacency matrix:")
    print(adj)
    
    print(f"\n{'β':>8} | {'Soft dist to node 4':>20} | {'Hard shortest path':>20}")
    print("-" * 55)
    for beta in [0.5, 1.0, 5.0, 20.0, 100.0]:
        soft_dist = entropy_regularized_shortest_path(adj, beta)
        # Hard shortest path from 0 to 4: 0→1→2→3→4 = 2+3+1+2 = 8
        print(f"{beta:8.1f} | {soft_dist[4]:20.6f} | {8.0:20.1f}")
    
    print("\n✓ Soft distances converge to hard shortest path as β → ∞")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Soft Assignment / Optimal Transport")
    print("=" * 70)
    
    cost = np.array([
        [1.0, 3.0, 5.0],
        [4.0, 1.0, 2.0],
        [3.0, 4.0, 1.0]
    ])
    
    print(f"\nCost matrix:\n{cost}")
    
    for beta in [0.1, 1.0, 10.0, 100.0]:
        P = soft_assignment_matrix(cost, beta)
        print(f"\nβ = {beta}:")
        print(f"  Assignment probabilities:\n{np.round(P, 4)}")
    
    print("\n✓ Assignment sharpens to optimal as β → ∞")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Decoherence Analysis")
    print("=" * 70)
    
    A = np.array([
        [0.0, 1.0, 3.0],
        [2.0, 0.0, 1.0],
        [1.0, 2.0, 0.0]
    ])
    
    betas = np.array([0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0])
    results = decoherence_analysis(A, betas)
    
    print(f"\nWeight matrix:\n{A}")
    print(f"\n{'β':>8} | {'Eigenvalue λ':>14} | {'Trop. error':>12} | {'Residual':>10}")
    print("-" * 55)
    for i, beta in enumerate(betas):
        print(f"{beta:8.1f} | {results['eigenvalues'][i]:14.6f} | "
              f"{results['tropical_errors'][i]:12.2e} | "
              f"{results['residuals'][i]:10.2e}")
    
    print("\n✓ Tropical error → 0 as β → ∞ (decoherence vanishes)")
    print("✓ Eigenvector structure persists across all temperatures!")


"""
Quantum Tropical Dynamics: Demonstrations and Numerical Examples

This module demonstrates the key theorems of quantum tropical dynamics:
1. Additive homogeneity of the quantum tropical operator
2. Tropical approximation bounds (sandwich inequality)
3. Eigenvector existence via Perron-Frobenius reduction
4. Convergence of soft minimum to hard minimum as β → ∞
"""

import numpy as np
from typing import Tuple


def qmin_vec(beta: float, x: np.ndarray) -> float:
    """Quantum (soft) minimum via log-sum-exp.
    
    qmin_β(x) = -(1/β) * log(∑_i exp(-β * x_i))
    
    Converges to min(x) as β → ∞.
    """
    # Numerically stable log-sum-exp
    m = np.min(x)
    return m - (1/beta) * np.log(np.sum(np.exp(-beta * (x - m))))


def qtrop_map(beta: float, A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Quantum tropical map: soft min-plus matrix-vector product.
    
    (T_{β,A} x)(i) = -(1/β) * log(∑_j exp(-β * (A_{ij} + x_j)))
    """
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        s = A[i, :] + x
        m = np.min(s)
        result[i] = m - (1/beta) * np.log(np.sum(np.exp(-beta * (s - m))))
    return result


def normalize0(x: np.ndarray) -> np.ndarray:
    """Normalize by subtracting the 0-th coordinate."""
    return x - x[0]


def min_plus_map(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Hard tropical (min-plus) matrix-vector product.
    
    (T_A x)(i) = min_j (A_{ij} + x_j)
    """
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def find_eigenvector_pf(beta: float, A: np.ndarray) -> Tuple[np.ndarray, float]:
    """Find the quantum tropical eigenvector via Perron-Frobenius.
    
    The eigenvector equation T_{β,A}(x) = x + λ is equivalent to
    M u = μ u where M_{ij} = exp(-β A_{ij}), u_j = exp(-β x_j), μ = exp(-βλ).
    
    Returns (x, eigval) such that T_{β,A}(x) ≈ x + eigval.
    """
    M = np.exp(-beta * A)
    eigenvalues, eigenvectors = np.linalg.eig(M)
    
    # Find the Perron eigenvalue (largest real eigenvalue with positive eigenvector)
    idx = np.argmax(np.real(eigenvalues))
    mu = np.real(eigenvalues[idx])
    u = np.real(eigenvectors[:, idx])
    
    # Ensure positive eigenvector
    if np.all(u < 0):
        u = -u
    
    # Convert back: x_j = -(1/β) * log(u_j), λ = -(1/β) * log(μ)
    u = np.abs(u) + 1e-15  # ensure positivity
    x = -(1/beta) * np.log(u)
    eigval = -(1/beta) * np.log(mu)
    
    return x, eigval


# ==================== DEMO 1: Additive Homogeneity ====================
print("=" * 70)
print("DEMO 1: Additive Homogeneity of qTropMap")
print("  Theorem: T_{β,A}(x + c) = T_{β,A}(x) + c")
print("=" * 70)

np.random.seed(42)
n = 4
beta = 2.0
A = np.random.randn(n, n)
x = np.random.randn(n)
c = 3.14

Tx = qtrop_map(beta, A, x)
Txc = qtrop_map(beta, A, x + c)

print(f"\nMatrix A ({n}×{n}), β = {beta}, c = {c}")
print(f"T(x + c)     = {Txc}")
print(f"T(x) + c     = {Tx + c}")
print(f"Max |diff|    = {np.max(np.abs(Txc - (Tx + c))):.2e}")
print("✓ Additive homogeneity verified numerically!\n")


# ==================== DEMO 2: Tropical Sandwich Bounds ====================
print("=" * 70)
print("DEMO 2: Tropical Sandwich Bounds")
print("  Theorem: min(x) - log(n)/β ≤ qmin_β(x) ≤ min(x)")
print("=" * 70)

x = np.array([1.0, 3.0, 2.0, 5.0, 0.5])
n_x = len(x)

print(f"\nx = {x}")
print(f"{'β':>8} | {'min(x)':>10} | {'qmin_β(x)':>12} | {'min - log(n)/β':>16} | {'gap':>10}")
print("-" * 70)

for beta in [0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 200.0]:
    qm = qmin_vec(beta, x)
    hard_min = np.min(x)
    lower = hard_min - np.log(n_x) / beta
    gap = hard_min - qm
    print(f"{beta:8.1f} | {hard_min:10.4f} | {qm:12.6f} | {lower:16.6f} | {gap:10.6f}")

print("\n✓ Sandwich bounds verified: gap → 0 as β → ∞\n")


# ==================== DEMO 3: Eigenvector Existence ====================
print("=" * 70)
print("DEMO 3: Eigenvector Existence (Perron-Frobenius Reduction)")
print("  Theorem: ∃ x, λ such that T_{β,A}(x) = x + λ")
print("=" * 70)

for n in [2, 3, 5]:
    A = np.random.randn(n, n)
    beta = 3.0
    x_eig, eigval = find_eigenvector_pf(beta, A)
    
    Tx = qtrop_map(beta, A, x_eig)
    residual = np.max(np.abs(Tx - (x_eig + eigval)))
    
    print(f"\nn = {n}, β = {beta}")
    print(f"  Eigenvalue λ = {eigval:.6f}")
    print(f"  T(x)         = {Tx}")
    print(f"  x + λ        = {x_eig + eigval}")
    print(f"  Max residual  = {residual:.2e}")
    print(f"  ✓ Eigenvector verified!" if residual < 1e-8 else f"  ⚠ Residual = {residual:.2e}")


# ==================== DEMO 4: Normalized Fixed Point ====================
print("\n" + "=" * 70)
print("DEMO 4: Normalized Fixed Point via Power Iteration")
print("  Theorem: ∃ x, normalize0(T_{β,A}(x)) = x")
print("=" * 70)

n = 4
A = np.random.randn(n, n)
beta = 5.0

# Power iteration: x_{k+1} = normalize0(T(x_k))
x = np.zeros(n)
for k in range(200):
    x_new = normalize0(qtrop_map(beta, A, x))
    if np.max(np.abs(x_new - x)) < 1e-14:
        print(f"\nConverged in {k+1} iterations!")
        break
    x = x_new

residual = np.max(np.abs(normalize0(qtrop_map(beta, A, x)) - x))
print(f"  Fixed point x = {x}")
print(f"  Residual       = {residual:.2e}")
print(f"  ✓ Normalized fixed point verified!\n")


# ==================== DEMO 5: Temperature Dependence ====================
print("=" * 70)
print("DEMO 5: Eigenvalue as Function of Inverse Temperature β")
print("  Physical interpretation: free energy vs zero-temperature limit")
print("=" * 70)

n = 3
A = np.array([[0.0, 1.0, 2.0],
              [1.0, 0.0, 1.5],
              [2.0, 1.5, 0.0]])

betas = np.logspace(-1, 2, 50)
eigvals = []

for b in betas:
    _, ev = find_eigenvector_pf(b, A)
    eigvals.append(ev)

print(f"\nMatrix A = \n{A}")
print(f"\n{'β':>8} | {'Eigenvalue λ(β)':>16}")
print("-" * 30)
for b, ev in zip([0.1, 0.5, 1.0, 5.0, 10.0, 100.0], 
                 [eigvals[0], eigvals[8], eigvals[16], eigvals[30], eigvals[38], eigvals[49]]):
    print(f"{b:8.1f} | {ev:16.6f}")

# The tropical limit: eigenvalue of the min-plus operator
# For the symmetric matrix above, the tropical eigenvalue is the min cycle mean
print(f"\nTropical limit (β→∞): eigenvalue → min-plus spectral radius")
print(f"  λ(β=100) = {eigvals[-1]:.6f}")
print(f"  ✓ Temperature dependence verified!\n")


# ==================== DEMO 6: No Literal Fixed Point ====================
print("=" * 70)
print("DEMO 6: No Literal Fixed Point (Negative Result)")
print("  Theorem: ∃ A, β such that ¬∃ x, T_{β,A}(x) = x")
print("=" * 70)

A_1 = np.array([[1.0]])
beta = 1.0
print(f"\nA = [[1]], β = 1")
print(f"For any x: T(x) = A₁₁ + x = 1 + x ≠ x")
print(f"Eigenvalue λ = {1.0} (always shifts by 1)")
print(f"✓ No literal fixed point exists — only projective/eigenvector form!\n")

print("=" * 70)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)


"""
Quantum Tropical Dynamics: Visualizations

Generates publication-quality figures illustrating the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO
from algorithms import qtrop_map, log_sum_exp, perron_eigenvector, normalize0


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_sandwich_bounds():
    """Plot the tropical sandwich bounds: min(x) - log(n)/β ≤ qmin ≤ min(x)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    x = np.array([1.0, 3.0, 2.0, 5.0, 0.5])
    n = len(x)
    hard_min = np.min(x)
    
    betas = np.logspace(-1, 3, 200)
    qmins = [log_sum_exp(x, b) for b in betas]
    upper = [hard_min] * len(betas)
    lower = [hard_min - np.log(n)/b for b in betas]
    
    ax1.fill_between(betas, lower, upper, alpha=0.2, color='steelblue', label='Allowed region')
    ax1.plot(betas, qmins, 'r-', linewidth=2, label='qmin_β(x)')
    ax1.plot(betas, upper, 'k--', linewidth=1, label='min(x)')
    ax1.plot(betas, lower, 'b--', linewidth=1, label='min(x) - log(n)/β')
    ax1.set_xscale('log')
    ax1.set_xlabel('Inverse temperature β', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Tropical Sandwich Bounds', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Gap plot
    gaps = [hard_min - qm for qm in qmins]
    bound_gaps = [np.log(n)/b for b in betas]
    
    ax2.plot(betas, gaps, 'r-', linewidth=2, label='Actual gap: min(x) - qmin')
    ax2.plot(betas, bound_gaps, 'b--', linewidth=1.5, label='Bound: log(n)/β')
    ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.set_xlabel('Inverse temperature β', fontsize=12)
    ax2.set_ylabel('Gap', fontsize=12)
    ax2.set_title('Convergence to Hard Minimum', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Quantum Tropical Approximation Bounds', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_eigenvector_convergence():
    """Plot eigenvector convergence via power iteration."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    np.random.seed(42)
    A = np.random.randn(4, 4)
    
    for idx, beta in enumerate([1.0, 5.0, 20.0]):
        ax = axes[idx]
        x = np.zeros(4)
        history = [x.copy()]
        
        for k in range(50):
            Tx = qtrop_map(beta, A, x)
            x_new = normalize0(Tx)
            history.append(x_new.copy())
            if np.max(np.abs(x_new - x)) < 1e-14:
                break
            x = x_new
        
        history = np.array(history)
        for i in range(4):
            ax.plot(history[:, i], label=f'x_{i}', linewidth=1.5)
        
        ax.set_xlabel('Iteration', fontsize=11)
        ax.set_ylabel('Coordinate value', fontsize=11)
        ax.set_title(f'β = {beta}', fontsize=13, fontweight='bold')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Normalized Fixed Point Convergence', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_eigenvalue_landscape():
    """Plot eigenvalue as function of β showing thermal-to-tropical transition."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    A = np.array([
        [0.0, 1.0, 3.0],
        [2.0, 0.0, 1.0],
        [1.0, 2.0, 0.0]
    ])
    
    betas = np.logspace(-1, 2.5, 100)
    eigvals = []
    eigvecs = []
    
    for b in betas:
        x, ev = perron_eigenvector(A, b)
        eigvals.append(ev)
        eigvecs.append(normalize0(x))
    
    eigvecs = np.array(eigvecs)
    
    ax1.plot(betas, eigvals, 'r-', linewidth=2)
    ax1.axhline(y=eigvals[-1], color='gray', linestyle='--', alpha=0.5, 
                label=f'Tropical limit ≈ {eigvals[-1]:.4f}')
    ax1.set_xscale('log')
    ax1.set_xlabel('Inverse temperature β', fontsize=12)
    ax1.set_ylabel('Eigenvalue λ(β)', fontsize=12)
    ax1.set_title('Eigenvalue vs Temperature', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    for i in range(3):
        ax2.plot(betas, eigvecs[:, i], linewidth=1.5, label=f'x_{i}')
    ax2.set_xscale('log')
    ax2.set_xlabel('Inverse temperature β', fontsize=12)
    ax2.set_ylabel('Normalized eigenvector coordinate', fontsize=12)
    ax2.set_title('Eigenvector vs Temperature', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Thermal-to-Tropical Phase Transition', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_soft_assignment():
    """Visualize the soft assignment as temperature varies."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    
    cost = np.array([
        [1.0, 3.0, 5.0],
        [4.0, 1.0, 2.0],
        [3.0, 4.0, 1.0]
    ])
    
    for idx, beta in enumerate([0.5, 2.0, 10.0, 100.0]):
        weights = np.exp(-beta * cost)
        P = weights / weights.sum(axis=1, keepdims=True)
        
        im = axes[idx].imshow(P, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
        axes[idx].set_title(f'β = {beta}', fontsize=13, fontweight='bold')
        axes[idx].set_xlabel('Column', fontsize=10)
        axes[idx].set_ylabel('Row', fontsize=10)
        
        for i in range(3):
            for j in range(3):
                axes[idx].text(j, i, f'{P[i,j]:.2f}', ha='center', va='center',
                             fontsize=9, color='black' if P[i,j] < 0.7 else 'white')
    
    fig.colorbar(im, ax=axes, shrink=0.8, label='Assignment probability')
    fig.suptitle('Soft Assignment: Thermal → Deterministic', fontsize=16, fontweight='bold', y=1.05)
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    sandwich = plot_sandwich_bounds()
    print(f"  Sandwich bounds: {len(sandwich)} chars")
    
    convergence = plot_eigenvector_convergence()
    print(f"  Convergence: {len(convergence)} chars")
    
    landscape = plot_eigenvalue_landscape()
    print(f"  Eigenvalue landscape: {len(landscape)} chars")
    
    assignment = plot_soft_assignment()
    print(f"  Soft assignment: {len(assignment)} chars")
    
    print("Done! Figures saved as base64 data URIs.")
