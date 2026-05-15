#!/usr/bin/env python3
"""
Applications of Finite-Temperature Tropical Approximation

Demonstrates real-world applications:
1. Shortest path smoothing (network routing)
2. Neural network tropical approximation
3. Statistical mechanics / free energy computation
4. Entropy-regularized reinforcement learning
"""

import numpy as np
from typing import Tuple, List


def logsumexp_stable(beta: float, values: np.ndarray) -> float:
    """Numerically stable log-sum-exp."""
    m = np.max(values)
    return m + np.log(np.sum(np.exp(beta * (values - m)))) / beta


# =============================================================================
# Application 1: Shortest Path Smoothing
# =============================================================================

def shortest_path_tropical(W: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via tropical matrix power (Floyd-Warshall style).
    
    In max-plus algebra with negated weights, this computes longest paths,
    which with negated distance matrices gives shortest paths.
    
    Args:
        W: Weight matrix (n×n), W[i][j] = negative distance from i to j
           (use -inf for no direct edge)
    
    Returns:
        Distance matrix D where D[i][j] = max over paths of sum of weights
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = max(D[i, j], D[i, k] + D[k, j])
    return D


def shortest_path_soft(W: np.ndarray, beta: float) -> np.ndarray:
    """
    Soft shortest paths via log-sum-exp relaxation.
    
    Replaces max with softmax in the Floyd-Warshall iteration.
    At high β, converges to the tropical (exact) shortest path.
    
    Args:
        W: Weight matrix (n×n)
        beta: Inverse temperature
        
    Returns:
        Soft distance matrix
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                vals = np.array([D[i, j], D[i, k] + D[k, j]])
                D[i, j] = logsumexp_stable(beta, vals)
    return D


def demo_shortest_path():
    """Demo: Smooth shortest paths with certified approximation."""
    print("=" * 70)
    print("APPLICATION 1: Smooth Shortest Path Computation")
    print("=" * 70)
    
    # Small graph (4 cities)
    INF = -1000  # represents -infinity (no direct edge)
    W = np.array([
        [0,   -2,  INF, -10],
        [INF,  0,   -3, INF],
        [INF, INF,   0,  -1],
        [INF, INF, INF,   0]
    ], dtype=float)
    # Negate: we want longest path in negated weights = shortest path
    W_neg = -W
    np.fill_diagonal(W_neg, 0)
    
    # Use max-plus: longest path = shortest path in original
    # Actually let's just work with the original distances directly
    # and use the negative convention
    
    print("\nDistance matrix (direct edges):")
    dist = np.array([
        [0,   2,  np.inf, 10],
        [np.inf, 0, 3,    np.inf],
        [np.inf, np.inf, 0, 1],
        [np.inf, np.inf, np.inf, 0]
    ])
    print(dist)
    
    # Negate distances for max-plus formulation
    W = -dist
    W[W == -np.inf] = -1000
    
    D_trop = shortest_path_tropical(W)
    print(f"\nTropical (exact) shortest path distances:")
    print(-D_trop)
    
    n = W.shape[0]
    print(f"\nSoft approximation errors (bound = log({n})/β per step):")
    for beta in [1.0, 5.0, 10.0, 50.0, 100.0]:
        D_soft = shortest_path_soft(W, beta)
        err = np.max(np.abs(D_soft - D_trop))
        # Note: error accumulates over n iterations of Floyd-Warshall
        bound = n * np.log(n) / beta
        print(f"  β={beta:6.1f}: max error = {err:.6f}, accumulated bound ≈ {bound:.6f}")


# =============================================================================
# Application 2: ReLU Network Tropical Approximation  
# =============================================================================

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(x, 0)."""
    return np.maximum(x, 0)

def softplus(x: np.ndarray, beta: float) -> np.ndarray:
    """Softplus: (1/β) log(1 + exp(βx)) ≈ ReLU(x)."""
    # Numerically stable version
    return np.where(
        beta * x > 20,
        x,
        np.log1p(np.exp(beta * x)) / beta
    )

def demo_neural_network():
    """Demo: Tropical approximation of a ReLU network."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: ReLU Network ↔ Tropical Polynomial")
    print("=" * 70)
    
    # Simple 2-layer ReLU network
    np.random.seed(42)
    W1 = np.array([[1.0, -0.5], [0.3, 0.8], [-0.2, 1.2]])
    b1 = np.array([0.1, -0.3, 0.5])
    W2 = np.array([[0.5, -0.7, 0.3], [0.2, 0.9, -0.4]])
    b2 = np.array([0.1, -0.2])
    
    def relu_network(x):
        h = relu(W1 @ x + b1)
        return W2 @ h + b2
    
    def softplus_network(x, beta):
        h = softplus(W1 @ x + b1, beta)
        return W2 @ h + b2
    
    # Test on a grid
    x_test = np.array([1.0, 0.5])
    
    print(f"\nInput: x = {x_test}")
    y_relu = relu_network(x_test)
    print(f"ReLU network output: {y_relu}")
    
    print(f"\n{'β':>8s} {'Softplus output':>30s} {'‖diff‖∞':>12s}")
    print("-" * 52)
    for beta in [0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        y_soft = softplus_network(x_test, beta)
        err = np.max(np.abs(y_soft - y_relu))
        print(f"{beta:8.1f} {str(np.round(y_soft, 6)):>30s} {err:12.6f}")
    
    print("\nThe softplus network converges to the ReLU (tropical) network as β → ∞")
    print("Error bound per layer: log(width)/β")


# =============================================================================
# Application 3: Statistical Mechanics / Free Energy
# =============================================================================

def partition_function(energies: np.ndarray, beta: float) -> float:
    """Compute partition function Z = Σ exp(-β E_i)."""
    return np.sum(np.exp(-beta * energies))

def free_energy(energies: np.ndarray, beta: float) -> float:
    """Compute free energy F = -(1/β) log Z."""
    return -logsumexp_stable(beta, -energies)

def gibbs_distribution(energies: np.ndarray, beta: float) -> np.ndarray:
    """Compute Gibbs probability distribution p_i = exp(-β E_i) / Z."""
    shifted = -beta * (energies - np.min(energies))
    probs = np.exp(shifted)
    return probs / np.sum(probs)

def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy H(p) = -Σ p_i log p_i."""
    p_pos = p[p > 0]
    return -np.sum(p_pos * np.log(p_pos))

def demo_stat_mech():
    """Demo: Free energy, Gibbs distributions, and the tropical limit."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Statistical Mechanics & Free Energy")
    print("=" * 70)
    
    energies = np.array([0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0])
    n = len(energies)
    E_min = np.min(energies)
    
    print(f"\nEnergy levels: {energies}")
    print(f"Ground state energy E₀ = {E_min}")
    print(f"Number of states n = {n}")
    print(f"Maximum entropic correction: log({n})/β = {np.log(n):.4f}/β")
    
    print(f"\n{'β':>6s} {'Free energy':>12s} {'E₀':>6s} {'F-E₀':>10s} {'log(n)/β':>10s} {'H(Gibbs)':>10s}")
    print("-" * 56)
    
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]:
        F = free_energy(energies, beta)
        p = gibbs_distribution(energies, beta)
        H = shannon_entropy(p)
        bound = np.log(n) / beta
        print(f"{beta:6.1f} {F:12.6f} {E_min:6.1f} {F-E_min:10.6f} {bound:10.6f} {H:10.6f}")
    
    print("\nAs β → ∞: Free energy → E₀, entropy → 0, Gibbs → δ(ground state)")
    print("As β → 0: Free energy → -∞, entropy → log(n), Gibbs → uniform")


# =============================================================================
# Application 4: Entropy-Regularized RL (Soft Value Iteration)
# =============================================================================

def demo_soft_rl():
    """Demo: Soft value iteration for a simple MDP."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Entropy-Regularized Reinforcement Learning")
    print("=" * 70)
    
    # Simple 3-state MDP
    # Reward matrix R[s, a] for taking action a in state s
    R = np.array([
        [1.0, 0.5, 0.0],   # State 0: action 0 is best
        [0.0, 2.0, 0.5],   # State 1: action 1 is best
        [0.5, 0.0, 1.5],   # State 2: action 2 is best
    ])
    
    gamma = 0.9  # discount factor
    n_states, n_actions = R.shape
    
    # Transition: deterministic for simplicity
    # Action i takes you to state i
    T = np.eye(n_states)  # T[a, s'] = 1 if action a leads to state s'
    
    def soft_value_iteration(beta: float, max_iter: int = 200) -> np.ndarray:
        V = np.zeros(n_states)
        for _ in range(max_iter):
            Q = np.zeros((n_states, n_actions))
            for s in range(n_states):
                for a in range(n_actions):
                    Q[s, a] = R[s, a] + gamma * np.sum(T[a, :] * V)
            V_new = np.array([logsumexp_stable(beta, Q[s, :]) for s in range(n_states)])
            if np.max(np.abs(V_new - V)) < 1e-10:
                V = V_new
                break
            V = V_new
        return V
    
    def hard_value_iteration(max_iter: int = 200) -> np.ndarray:
        V = np.zeros(n_states)
        for _ in range(max_iter):
            Q = np.zeros((n_states, n_actions))
            for s in range(n_states):
                for a in range(n_actions):
                    Q[s, a] = R[s, a] + gamma * np.sum(T[a, :] * V)
            V_new = np.max(Q, axis=1)
            if np.max(np.abs(V_new - V)) < 1e-10:
                V = V_new
                break
            V = V_new
        return V
    
    V_hard = hard_value_iteration()
    print(f"\nReward matrix R:\n{R}")
    print(f"\nHard (tropical) value function: {np.round(V_hard, 4)}")
    
    print(f"\n{'β':>8s} {'Soft V':>30s} {'‖V_β - V*‖∞':>14s} {'bound':>10s}")
    print("-" * 64)
    for beta in [0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        V_soft = soft_value_iteration(beta)
        err = np.max(np.abs(V_soft - V_hard))
        # Rough bound: log(n_actions)/β per iteration, accumulated over ~1/(1-γ) steps
        bound = np.log(n_actions) / (beta * (1 - gamma))
        print(f"{beta:8.1f} {str(np.round(V_soft, 4)):>30s} {err:14.6f} {bound:10.6f}")
    
    print(f"\nAs β → ∞, soft value iteration → hard (tropical) value iteration")
    print(f"Per-step error bound: log({n_actions})/β = {np.log(n_actions):.4f}/β")


if __name__ == "__main__":
    demo_shortest_path()
    demo_neural_network()
    demo_stat_mech()
    demo_soft_rl()


#!/usr/bin/env python3
"""
Finite-Temperature Tropical Approximation: Demonstrations

This script demonstrates the key theorems with concrete numerical examples,
showing how log-sum-exp (softmax) converges to the tropical maximum with
explicit error bounds.
"""

import numpy as np
from typing import List, Tuple

def softmax2(beta: float, x: float, y: float) -> float:
    """Binary soft-max: (1/β) log(exp(βx) + exp(βy))."""
    # Use logsumexp trick for numerical stability
    m = max(x, y)
    return m + np.log(np.exp(beta * (x - m)) + np.exp(beta * (y - m))) / beta

def finset_lse(beta: float, values: np.ndarray) -> float:
    """Finset log-sum-exp: (1/β) log(Σ exp(β·z_i))."""
    m = np.max(values)
    return m + np.log(np.sum(np.exp(beta * (values - m)))) / beta

def tropical_mat_action(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (T_A x)(i) = max_j (A_ij + x_j)."""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x)
    return result

def soft_mat_action(A: np.ndarray, x: np.ndarray, beta: float) -> np.ndarray:
    """Soft tropical matrix-vector product."""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        vals = A[i, :] + x
        result[i] = finset_lse(beta, vals)
    return result

def demo_theorem_a():
    """Demonstrate Theorem A: Binary finite-temperature tropical approximation."""
    print("=" * 70)
    print("THEOREM A: Binary Soft-Max Bounds")
    print("max(x,y) ≤ (1/β)log(exp(βx)+exp(βy)) ≤ max(x,y) + log(2)/β")
    print("=" * 70)
    
    x, y = 1.0, 2.0
    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]
    
    print(f"\nTest case: x = {x}, y = {y}, max(x,y) = {max(x,y)}")
    print(f"\n{'β':>8s} {'softmax₂':>12s} {'max(x,y)':>10s} {'upper':>10s} {'gap':>10s} {'bound ok?':>10s}")
    print("-" * 62)
    
    for beta in betas:
        sm = softmax2(beta, x, y)
        mx = max(x, y)
        ub = mx + np.log(2) / beta
        gap = sm - mx
        ok = (mx <= sm + 1e-12) and (sm <= ub + 1e-12)
        print(f"{beta:8.1f} {sm:12.6f} {mx:10.3f} {ub:10.6f} {gap:10.6f} {'✓' if ok else '✗':>10s}")
    
    print("\n--- Sharpness test: x = y = 3.0 ---")
    a = 3.0
    print(f"{'β':>8s} {'softmax₂':>12s} {'a+log2/β':>12s} {'|diff|':>12s}")
    print("-" * 46)
    for beta in [1.0, 10.0, 100.0, 1000.0]:
        sm = softmax2(beta, a, a)
        exact = a + np.log(2) / beta
        print(f"{beta:8.1f} {sm:12.9f} {exact:12.9f} {abs(sm-exact):12.2e}")

def demo_theorem_b():
    """Demonstrate Theorem B: Finset log-sum-exp bounds."""
    print("\n" + "=" * 70)
    print("THEOREM B: Finset LSE Bounds")
    print("max_i f(i) ≤ LSE_β(f) ≤ max_i f(i) + log(|s|)/β")
    print("=" * 70)
    
    values = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    n = len(values)
    mx = np.max(values)
    
    print(f"\nValues: {values}")
    print(f"n = {n}, max = {mx}")
    
    betas = [0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]
    print(f"\n{'β':>8s} {'LSE_β':>10s} {'max':>8s} {'upper':>10s} {'gap':>10s} {'bound':>8s}")
    print("-" * 56)
    
    for beta in betas:
        lse = finset_lse(beta, values)
        ub = mx + np.log(n) / beta
        gap = lse - mx
        ok = (mx <= lse + 1e-12) and (lse <= ub + 1e-12)
        print(f"{beta:8.1f} {lse:10.6f} {mx:8.3f} {ub:10.6f} {gap:10.6f} {'✓' if ok else '✗':>8s}")
    
    print("\n--- Sharpness test: all values equal ---")
    eq_values = np.array([3.0, 3.0, 3.0, 3.0, 3.0])
    n_eq = len(eq_values)
    for beta in [1.0, 10.0, 100.0]:
        lse = finset_lse(beta, eq_values)
        exact = 3.0 + np.log(n_eq) / beta
        print(f"  β={beta:6.1f}: LSE = {lse:.9f}, 3 + log(5)/β = {exact:.9f}, diff = {abs(lse-exact):.2e}")

def demo_theorem_c():
    """Demonstrate Theorem C: Matrix operator approximation."""
    print("\n" + "=" * 70)
    print("THEOREM C: Tropical Matrix Soft Approximation")
    print("‖T_{A,β}x - T_A x‖_∞ ≤ log(n)/β")
    print("=" * 70)
    
    np.random.seed(42)
    n = 5
    A = np.random.randn(n, n)
    x = np.random.randn(n)
    
    print(f"\nMatrix A ({n}×{n}):")
    print(np.round(A, 3))
    print(f"\nVector x: {np.round(x, 3)}")
    
    trop = tropical_mat_action(A, x)
    print(f"\nTropical T_A x: {np.round(trop, 3)}")
    
    betas = [0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]
    bound_val = np.log(n)
    
    print(f"\nTheoretical bound: log({n})/β = {bound_val:.4f}/β")
    print(f"\n{'β':>8s} {'‖T_β x - T x‖∞':>16s} {'log(n)/β':>10s} {'ratio':>8s} {'bound ok?':>10s}")
    print("-" * 54)
    
    for beta in betas:
        soft = soft_mat_action(A, x, beta)
        err = np.max(np.abs(soft - trop))
        bound = bound_val / beta
        ratio = err / bound if bound > 0 else 0
        ok = err <= bound + 1e-10
        print(f"{beta:8.1f} {err:16.6f} {bound:10.6f} {ratio:8.4f} {'✓' if ok else '✗':>10s}")

def demo_convergence():
    """Demonstrate convergence behavior as β → ∞."""
    print("\n" + "=" * 70)
    print("CONVERGENCE: Error decay as β → ∞")
    print("=" * 70)
    
    values = np.array([1.0, 4.0, 2.0, 7.0, 3.0, 6.0, 5.0, 8.0, 1.5, 3.5])
    n = len(values)
    mx = np.max(values)
    
    print(f"\nn = {n} values, max = {mx}")
    print(f"Theoretical bound: log({n})/β = {np.log(n):.4f}/β")
    print(f"\n{'β':>10s} {'LSE_β':>12s} {'error':>12s} {'bound':>12s} {'error·β':>12s}")
    print("-" * 60)
    
    for k in range(1, 15):
        beta = 2.0 ** k
        lse = finset_lse(beta, values)
        err = lse - mx
        bound = np.log(n) / beta
        print(f"{beta:10.0f} {lse:12.8f} {err:12.2e} {bound:12.2e} {err*beta:12.6f}")

def demo_free_energy():
    """Demonstrate the statistical mechanics interpretation."""
    print("\n" + "=" * 70)
    print("APPLICATION: Free Energy in Statistical Mechanics")
    print("F = -(1/β)log Z = -(1/β)log Σ exp(-βE_i)")
    print("=" * 70)
    
    energies = np.array([0.5, 1.0, 1.5, 2.0, 3.0])
    n = len(energies)
    
    print(f"\nEnergy levels: {energies}")
    print(f"Ground state energy E_min = {np.min(energies)}")
    print(f"\n{'β (1/T)':>10s} {'Free energy':>14s} {'E_min':>8s} {'F-E_min':>10s} {'log(n)/β':>10s}")
    print("-" * 54)
    
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        # Free energy = -(1/β) log Σ exp(-β E_i) = -LSE_β(-E)
        neg_energies = -energies
        F = -finset_lse(beta, neg_energies)
        E_min = np.min(energies)
        gap = F - E_min
        bound = np.log(n) / beta
        print(f"{beta:10.1f} {F:14.6f} {E_min:8.3f} {gap:10.6f} {bound:10.6f}")
    
    print("\nAs β → ∞ (T → 0), free energy → ground state energy E_min")
    print("The gap is bounded by log(n)/β (entropic correction)")

if __name__ == "__main__":
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_convergence()
    demo_free_energy()


#!/usr/bin/env python3
"""
Visualizations for Finite-Temperature Tropical Approximation

Generates publication-quality figures showing:
1. Binary softmax bounds
2. Convergence as β → ∞
3. Matrix operator error
4. Temperature phase diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import rcParams
import base64
from io import BytesIO

# Style settings
rcParams['font.family'] = 'serif'
rcParams['font.size'] = 12
rcParams['axes.linewidth'] = 1.2
rcParams['figure.dpi'] = 150


def logsumexp_stable(beta, values):
    m = np.max(values)
    return m + np.log(np.sum(np.exp(beta * (values - m)))) / beta


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_binary_bounds():
    """Plot 1: Binary softmax between max and max + log(2)/β."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: softmax as a function of y for fixed x=0
    ax = axes[0]
    y_range = np.linspace(-3, 3, 300)
    x_val = 0.0
    
    ax.plot(y_range, np.maximum(x_val, y_range), 'k-', linewidth=2.5, label='max(0, y)', zorder=5)
    
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']
    for idx, beta in enumerate([0.5, 1.0, 2.0, 5.0, 20.0]):
        sm = np.array([logsumexp_stable(beta, np.array([x_val, y])) for y in y_range])
        ax.plot(y_range, sm, color=colors[idx], linewidth=1.5, 
                label=f'β = {beta}', alpha=0.8)
    
    ax.set_xlabel('y', fontsize=14)
    ax.set_ylabel('softmax₂(β, 0, y)', fontsize=14)
    ax.set_title('Softmax Converges to Max', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 3)
    
    # Right: Error as function of β for various (x,y) pairs
    ax = axes[1]
    betas = np.logspace(-1, 3, 200)
    
    pairs = [(0, 0), (0, 1), (0, 2), (1, 1), (-1, 3)]
    colors2 = ['#e74c3c', '#3498db', '#2ecc71', '#e67e22', '#9b59b6']
    
    for idx, (x, y) in enumerate(pairs):
        errors = np.array([logsumexp_stable(b, np.array([float(x), float(y)])) - max(x, y) 
                          for b in betas])
        ax.loglog(betas, errors, color=colors2[idx], linewidth=1.5, 
                 label=f'x={x}, y={y}')
    
    # Theoretical bound
    ax.loglog(betas, np.log(2) / betas, 'k--', linewidth=2, label='log(2)/β bound', zorder=5)
    
    ax.set_xlabel('β (inverse temperature)', fontsize=14)
    ax.set_ylabel('softmax₂ − max', fontsize=14)
    ax.set_title('Error Decay: O(1/β)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3, which='both')
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_binary_bounds.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_finset_convergence():
    """Plot 2: Finset LSE convergence for various set sizes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    np.random.seed(42)
    
    # Left: LSE vs max for different n
    ax = axes[0]
    betas = np.logspace(-0.5, 2.5, 200)
    
    for n, color in [(2, '#e74c3c'), (5, '#3498db'), (10, '#2ecc71'), 
                      (50, '#e67e22'), (100, '#9b59b6')]:
        values = np.random.randn(n)
        mx = np.max(values)
        errors = np.array([logsumexp_stable(b, values) - mx for b in betas])
        ax.loglog(betas, errors, color=color, linewidth=1.5, label=f'n = {n}')
        ax.loglog(betas, np.log(n) / betas, color=color, linewidth=1.5, 
                 linestyle='--', alpha=0.5)
    
    ax.set_xlabel('β', fontsize=14)
    ax.set_ylabel('LSE_β − max', fontsize=14)
    ax.set_title('Entropic Correction: log(n)/β', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')
    
    # Right: Error times β (should plateau at log(n))
    ax = axes[1]
    for n, color in [(2, '#e74c3c'), (5, '#3498db'), (10, '#2ecc71'), 
                      (50, '#e67e22'), (100, '#9b59b6')]:
        values = np.random.randn(n)
        mx = np.max(values)
        products = np.array([(logsumexp_stable(b, values) - mx) * b for b in betas])
        ax.semilogx(betas, products, color=color, linewidth=1.5, label=f'n={n}')
        ax.axhline(y=np.log(n), color=color, linestyle=':', alpha=0.4)
    
    ax.set_xlabel('β', fontsize=14)
    ax.set_ylabel('(LSE_β − max) × β', fontsize=14)
    ax.set_title('Scaled Error → log(n) as β → ∞', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_finset_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_matrix_operator():
    """Plot 3: Matrix operator approximation."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    np.random.seed(123)
    
    # Left: Pointwise comparison for a 5x5 system
    ax = axes[0]
    n = 5
    A = np.random.randn(n, n)
    x = np.random.randn(n)
    
    trop = np.array([np.max(A[i, :] + x) for i in range(n)])
    
    betas = [1, 2, 5, 10, 50]
    width = 0.15
    positions = np.arange(n)
    
    ax.bar(positions - 2*width, trop, width, color='#2c3e50', label='Tropical T_A x', zorder=3)
    
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']
    for idx, beta in enumerate(betas):
        soft = np.array([logsumexp_stable(beta, A[i, :] + x) for i in range(n)])
        offset = (idx - 1) * width
        ax.bar(positions + offset + width, soft, width * 0.9, color=colors[idx], 
               alpha=0.7, label=f'β={beta}', zorder=2)
    
    ax.set_xlabel('Coordinate i', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Tropical vs Soft Matrix Action', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, ncol=2)
    ax.set_xticks(positions)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Right: Sup-norm error vs β for different matrix sizes
    ax = axes[1]
    betas_range = np.logspace(0, 2.5, 100)
    
    for n, color in [(3, '#e74c3c'), (5, '#3498db'), (10, '#2ecc71'), 
                      (20, '#e67e22'), (50, '#9b59b6')]:
        A = np.random.randn(n, n)
        x = np.random.randn(n)
        trop = np.array([np.max(A[i, :] + x) for i in range(n)])
        
        errors = []
        for beta in betas_range:
            soft = np.array([logsumexp_stable(beta, A[i, :] + x) for i in range(n)])
            errors.append(np.max(np.abs(soft - trop)))
        
        ax.loglog(betas_range, errors, color=color, linewidth=1.5, label=f'n={n}')
        ax.loglog(betas_range, np.log(n) / betas_range, color=color, 
                 linestyle='--', alpha=0.4)
    
    ax.set_xlabel('β', fontsize=14)
    ax.set_ylabel('‖T_{A,β}x − T_A x‖_∞', fontsize=14)
    ax.set_title('Operator Error Bound', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_matrix_operator.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_phase_diagram():
    """Plot 4: Temperature phase diagram and free energy landscape."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: "Phase diagram" - Gibbs distribution at various temperatures
    ax = axes[0]
    energies = np.array([0.0, 0.3, 0.8, 1.5, 2.5])
    n = len(energies)
    
    betas = np.logspace(-1, 2, 200)
    
    for i in range(n):
        probs = []
        for beta in betas:
            p = np.exp(-beta * (energies - energies[0]))
            p = p / np.sum(p)
            probs.append(p[i])
        ax.semilogx(betas, probs, linewidth=2, label=f'E={energies[i]:.1f}')
    
    ax.axhline(y=1/n, color='gray', linestyle=':', alpha=0.5)
    ax.text(0.12, 1/n + 0.02, f'uniform = 1/{n}', fontsize=9, color='gray')
    
    ax.set_xlabel('β (inverse temperature)', fontsize=14)
    ax.set_ylabel('Gibbs probability p_i', fontsize=14)
    ax.set_title('Temperature Phase Diagram', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, title='Energy level')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.02, 1.02)
    
    # Right: Free energy landscape
    ax = axes[1]
    betas_plot = [0.5, 1.0, 2.0, 5.0, 20.0, 100.0]
    z_range = np.linspace(-2, 4, 300)
    
    n_vals = 5
    values = np.array([0.0, 1.0, 2.0, 3.0, 3.5])
    
    colors = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(betas_plot)))
    
    for idx, beta in enumerate(betas_plot):
        # For each z, compute "soft envelope" contribution
        envelope = np.array([logsumexp_stable(beta, np.array([v, z])) for z, v in 
                            zip(z_range, np.full_like(z_range, values[0]))])
        # Actually show LSE as function of a parameter
        lse_vals = np.array([logsumexp_stable(beta, values + t * np.linspace(-1, 1, n_vals)) 
                            for t in np.linspace(-2, 2, 300)])
        
    # Instead: show free energy vs number of states
    ax.clear()
    n_range = np.arange(1, 101)
    for beta in [0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        corrections = np.log(n_range) / beta
        ax.plot(n_range, corrections, linewidth=1.5, label=f'β={beta}')
    
    ax.set_xlabel('Number of states n', fontsize=14)
    ax.set_ylabel('Entropic correction log(n)/β', fontsize=14)
    ax.set_title('Free Energy Correction', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_phase_diagram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_binary_bounds()
    print(f"  Binary bounds: saved to fig_binary_bounds.png ({len(b64_1)} chars base64)")
    
    b64_2 = plot_finset_convergence()
    print(f"  Finset convergence: saved to fig_finset_convergence.png ({len(b64_2)} chars base64)")
    
    b64_3 = plot_matrix_operator()
    print(f"  Matrix operator: saved to fig_matrix_operator.png ({len(b64_3)} chars base64)")
    
    b64_4 = plot_phase_diagram()
    print(f"  Phase diagram: saved to fig_phase_diagram.png ({len(b64_4)} chars base64)")
    
    print("\nAll visualizations generated successfully.")
    
    # Store base64 data for PACKAGE.json
    import json
    viz_data = {
        "binary_bounds": b64_1,
        "finset_convergence": b64_2,
        "matrix_operator": b64_3,
        "phase_diagram": b64_4
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
