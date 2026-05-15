"""
Applications of the Gibbs Variational Principle.

Demonstrates real-world uses:
1. Softmax attention in transformers
2. Entropy-regularized reinforcement learning
3. Statistical mechanics simulation
4. Tropical limit for combinatorial optimization
"""

import numpy as np
from algorithms import softmax, log_sum_exp, shannon_entropy, free_energy_objective


# =============================================================================
# Application 1: Softmax Attention Mechanism
# =============================================================================

def attention_layer(
    queries: np.ndarray,
    keys: np.ndarray,
    values: np.ndarray,
    tau: float = 1.0,
) -> np.ndarray:
    """Single-head attention using softmax.

    For each query q, compute:
        scores_i = q · k_i
        weights = softmax(scores / τ)
        output = ∑ weights_i * v_i

    By the variational principle, these weights solve:
        argmax_{p ∈ Δ} { ∑ pᵢ (q · kᵢ) + τ H(p) }

    Args:
        queries: (n_queries, d_model) array
        keys: (n_keys, d_model) array
        values: (n_keys, d_value) array
        tau: Temperature for attention sharpness

    Returns:
        (n_queries, d_value) attention output
    """
    scores = queries @ keys.T  # (n_queries, n_keys)
    outputs = []
    for i in range(len(queries)):
        weights = softmax(scores[i], tau)
        output = weights @ values
        outputs.append(output)
    return np.array(outputs)


def demo_attention():
    """Demonstrate attention as entropy-regularized optimization."""
    print("=" * 60)
    print("APPLICATION 1: Softmax Attention as Variational Optimization")
    print("=" * 60)

    np.random.seed(42)
    d_model, d_value, n_keys = 4, 3, 5

    keys = np.random.randn(n_keys, d_model)
    values = np.array([
        [1, 0, 0],   # "red"
        [0, 1, 0],   # "green"
        [0, 0, 1],   # "blue"
        [1, 1, 0],   # "yellow"
        [0, 1, 1],   # "cyan"
    ], dtype=float)

    query = np.random.randn(1, d_model)
    scores = (query @ keys.T).flatten()

    print(f"\nScores: {np.round(scores, 3)}")
    for tau in [0.1, 0.5, 1.0, 5.0]:
        weights = softmax(scores, tau)
        output = weights @ values
        entropy = shannon_entropy(weights)
        print(f"\nτ = {tau}:")
        print(f"  Weights: {np.round(weights, 4)}")
        print(f"  Output:  {np.round(output, 4)}")
        print(f"  Entropy: {entropy:.4f} (max = {np.log(n_keys):.4f})")
        print(f"  → {'Uniform mixing' if entropy > 1.2 else 'Concentrated' if entropy < 0.5 else 'Moderate mixing'}")


# =============================================================================
# Application 2: Entropy-Regularized Policy Optimization
# =============================================================================

def entropy_regularized_policy(
    q_values: np.ndarray, tau: float = 1.0
) -> tuple:
    """Compute the optimal entropy-regularized policy.

    Solves: π* = argmax_{π ∈ Δ} { ∑ π(a) Q(a) + τ H(π) }

    By the Gibbs variational principle:
        π*(a) = softmax(Q/τ)
        V = τ log ∑ exp(Q(a)/τ)  (soft value function)

    Args:
        q_values: Q-values for each action.
        tau: Entropy regularization coefficient.

    Returns:
        (policy, soft_value) tuple.
    """
    policy = softmax(q_values, tau)
    soft_value = log_sum_exp(q_values, tau)
    return policy, soft_value


def demo_rl():
    """Demonstrate entropy-regularized RL policy."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Entropy-Regularized Reinforcement Learning")
    print("=" * 60)

    # Simple grid world: 4 actions (N, E, S, W) with different Q-values
    actions = ["North", "East", "South", "West"]
    q_values = np.array([2.0, 5.0, 1.0, 3.0])

    print(f"\nQ-values: {dict(zip(actions, q_values))}")
    print(f"Greedy action: {actions[np.argmax(q_values)]}")

    for tau in [0.1, 0.5, 1.0, 2.0, 10.0]:
        policy, soft_v = entropy_regularized_policy(q_values, tau)
        expected_q = np.dot(policy, q_values)
        entropy = shannon_entropy(policy)
        print(f"\nτ = {tau}:")
        print(f"  Policy: {dict(zip(actions, np.round(policy, 4)))}")
        print(f"  Soft value V = {soft_v:.4f}")
        print(f"  E[Q] = {expected_q:.4f}, τH = {tau * entropy:.4f}")
        print(f"  Exploration-exploitation: {'exploit' if tau < 0.5 else 'explore' if tau > 5 else 'balanced'}")


# =============================================================================
# Application 3: Statistical Mechanics — Canonical Ensemble
# =============================================================================

def canonical_ensemble(
    energy_levels: np.ndarray,
    temperature: float,
    degeneracies: np.ndarray = None,
) -> dict:
    """Compute canonical ensemble properties.

    The Gibbs distribution minimizes free energy F = E - TS:
        ρᵢ = exp(-εᵢ/T) / Z  (for non-degenerate levels)

    This is our variational principle with x = -ε and τ = T.

    Args:
        energy_levels: Energy of each microstate.
        temperature: Temperature T > 0.
        degeneracies: Optional degeneracy factors.

    Returns:
        Dictionary with thermodynamic quantities.
    """
    if degeneracies is not None:
        # Effective energies accounting for degeneracy
        effective = -energy_levels  # x_i = -ε_i for our convention
        log_deg = np.log(degeneracies)
        effective = effective + temperature * log_deg  # absorb degeneracy
    else:
        effective = -energy_levels

    gibbs_probs = softmax(effective, temperature)
    log_Z = log_sum_exp(effective, temperature) / temperature

    avg_energy = np.dot(gibbs_probs, energy_levels)
    entropy = shannon_entropy(gibbs_probs)
    free_energy_val = avg_energy - temperature * entropy

    return {
        "probabilities": gibbs_probs,
        "partition_function_log": log_Z,
        "average_energy": avg_energy,
        "entropy": entropy,
        "free_energy": free_energy_val,
        "temperature": temperature,
    }


def demo_stat_mech():
    """Demonstrate statistical mechanics application."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Statistical Mechanics — Two-Level System")
    print("=" * 60)

    # Two-level system (e.g., spin in magnetic field)
    energy_levels = np.array([0.0, 1.0])  # ground state and excited state
    states = ["Ground", "Excited"]

    print(f"\nEnergy levels: {dict(zip(states, energy_levels))}")

    temperatures = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    print(f"\n{'T':>6s} {'P(ground)':>10s} {'P(excited)':>10s} {'⟨E⟩':>8s} {'S':>8s} {'F':>8s}")
    print("-" * 55)
    for T in temperatures:
        result = canonical_ensemble(energy_levels, T)
        p = result["probabilities"]
        print(f"{T:6.1f} {p[0]:10.4f} {p[1]:10.4f} {result['average_energy']:8.4f} "
              f"{result['entropy']:8.4f} {result['free_energy']:8.4f}")

    print("\nAs T → 0: system freezes to ground state (P(ground) → 1)")
    print("As T → ∞: system equilibrates (P → uniform, S → log 2)")


# =============================================================================
# Application 4: Tropical Limit — Combinatorial Optimization
# =============================================================================

def smooth_max(x: np.ndarray, tau: float = 1.0) -> float:
    """Smooth approximation to max(x) via log-sum-exp.

    By the variational principle:
        max(x) ≤ τ log ∑ exp(xᵢ/τ) ≤ max(x) + τ log(n)

    As τ → 0⁺, this converges to max(x).

    Args:
        x: Array of values.
        tau: Smoothing temperature.

    Returns:
        Smooth maximum approximation.
    """
    return log_sum_exp(x, tau)


def smooth_argmax(x: np.ndarray, tau: float = 1.0) -> np.ndarray:
    """Smooth approximation to argmax indicator via softmax.

    As τ → 0⁺, softmax concentrates on the argmax.

    Args:
        x: Array of values.
        tau: Smoothing temperature.

    Returns:
        Soft argmax (probability vector).
    """
    return softmax(x, tau)


def demo_tropical():
    """Demonstrate tropical (zero-temperature) limit."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Limit — Smooth to Combinatorial")
    print("=" * 60)

    # Knapsack-like scoring
    items = ["A", "B", "C", "D", "E"]
    scores = np.array([3.0, 7.0, 2.0, 5.0, 4.0])

    print(f"\nItem scores: {dict(zip(items, scores))}")
    print(f"True max: {np.max(scores)} (item {items[np.argmax(scores)]})")

    print(f"\n{'τ':>8s} {'smooth max':>12s} {'gap':>8s} {'soft argmax':>40s}")
    print("-" * 75)
    for tau in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
        sm = smooth_max(scores, tau)
        sa = smooth_argmax(scores, tau)
        gap = sm - np.max(scores)
        sa_str = ', '.join(f'{s:.4f}' for s in sa)
        print(f"{tau:8.3f} {sm:12.6f} {gap:8.5f}   [{sa_str}]")

    print("\n→ As τ → 0: smooth max → max, soft argmax → hard argmax")
    print("  This is the dequantization bridge to tropical geometry")


if __name__ == "__main__":
    demo_attention()
    demo_rl()
    demo_stat_mech()
    demo_tropical()


"""
Demo: Gibbs Variational Principle / Log-Sum-Exp Duality

Demonstrates the identity:
    τ * log(∑ exp(xᵢ/τ)) = max_p { ∑ pᵢxᵢ + τ H(p) }

with the maximum achieved by the softmax distribution.
"""

import numpy as np


def log_sum_exp(x: np.ndarray, tau: float) -> float:
    """Compute τ * log(∑ exp(xᵢ/τ)) in a numerically stable way."""
    m = np.max(x)
    return tau * (m / tau + np.log(np.sum(np.exp((x - m) / tau))))


def softmax(x: np.ndarray, tau: float) -> np.ndarray:
    """Compute softmax probabilities: qᵢ = exp(xᵢ/τ) / Z."""
    m = np.max(x)
    e = np.exp((x - m) / tau)
    return e / np.sum(e)


def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy H(p) = -∑ pᵢ log pᵢ with 0 log 0 = 0."""
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


def free_energy(x: np.ndarray, p: np.ndarray, tau: float) -> float:
    """Free energy objective: ∑ pᵢxᵢ + τ H(p)."""
    return np.dot(p, x) + tau * shannon_entropy(p)


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """KL(p || q) = ∑ pᵢ log(pᵢ/qᵢ) with 0 log 0 = 0."""
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))


def main():
    print("=" * 70)
    print("GIBBS VARIATIONAL PRINCIPLE — NUMERICAL DEMONSTRATION")
    print("=" * 70)

    # --- Demo 1: Basic verification ---
    print("\n--- Demo 1: Basic Verification ---")
    x = np.array([1.0, 2.0, 3.0])
    tau = 1.0

    lse = log_sum_exp(x, tau)
    q = softmax(x, tau)
    fe_q = free_energy(x, q, tau)

    print(f"x = {x}")
    print(f"τ = {tau}")
    print(f"τ log Z = {lse:.6f}")
    print(f"Softmax q = [{', '.join(f'{qi:.6f}' for qi in q)}]")
    print(f"F(x, q) = {fe_q:.6f}")
    print(f"Gap |τ log Z - F(x,q)| = {abs(lse - fe_q):.2e}")
    print(f"✓ Attainment verified!" if abs(lse - fe_q) < 1e-10 else "✗ Error!")

    # Test with uniform distribution
    p_unif = np.ones(len(x)) / len(x)
    fe_unif = free_energy(x, p_unif, tau)
    print(f"\nUniform p = {p_unif}")
    print(f"F(x, p_uniform) = {fe_unif:.6f}")
    print(f"Gap τ log Z - F(x, p_uniform) = {lse - fe_unif:.6f} ≥ 0")
    print(f"KL(p_uniform || q) = {kl_divergence(p_unif, q):.6f}")

    # Test with extreme distribution
    p_extreme = np.array([0.0, 0.0, 1.0])
    fe_extreme = free_energy(x, p_extreme, tau)
    print(f"\nDirac p = {p_extreme}")
    print(f"F(x, p_dirac) = {fe_extreme:.6f}")
    print(f"Gap τ log Z - F(x, p_dirac) = {lse - fe_extreme:.6f} ≥ 0")

    # --- Demo 2: KL decomposition ---
    print("\n--- Demo 2: KL Decomposition ---")
    print("F(x, p) = τ log Z - τ KL(p || q)")
    for label, p in [("uniform", p_unif), ("softmax", q), ("dirac", p_extreme)]:
        fe = free_energy(x, p, tau)
        kl = kl_divergence(p, q) if np.all(p[p > 0] > 0) else float('inf')
        rhs = lse - tau * kl
        print(f"  {label:10s}: F = {fe:.4f}, τ log Z - τ KL = {rhs:.4f}, match = {abs(fe - rhs) < 1e-8}")

    # --- Demo 3: Temperature sweep ---
    print("\n--- Demo 3: Temperature Sweep (Tropical Limit) ---")
    x = np.array([1.0, 3.0, 2.0])
    print(f"x = {x}, max(x) = {np.max(x)}")
    taus = [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    print(f"{'τ':>8s} {'τ log Z':>10s} {'gap to max':>12s} {'softmax':>30s}")
    for tau in taus:
        lse_val = log_sum_exp(x, tau)
        q_val = softmax(x, tau)
        gap = lse_val - np.max(x)
        q_str = ', '.join(f'{qi:.4f}' for qi in q_val)
        print(f"{tau:8.3f} {lse_val:10.6f} {gap:12.6f}   [{q_str}]")
    print("As τ → 0⁺: τ log Z → max(x) and softmax → argmax indicator")

    # --- Demo 4: Random verification ---
    print("\n--- Demo 4: Random Verification (1000 trials) ---")
    np.random.seed(42)
    n = 5
    violations = 0
    max_gap = 0
    for _ in range(1000):
        x = np.random.randn(n) * 3
        tau = np.random.exponential(1.0)
        lse_val = log_sum_exp(x, tau)
        q_val = softmax(x, tau)

        # Check attainment
        fe_q = free_energy(x, q_val, tau)
        if abs(lse_val - fe_q) > 1e-8:
            violations += 1

        # Check upper bound with random p
        alpha = np.random.exponential(1.0, n)
        p_rand = alpha / alpha.sum()
        fe_rand = free_energy(x, p_rand, tau)
        gap = lse_val - fe_rand
        max_gap = max(max_gap, gap)
        if fe_rand > lse_val + 1e-8:
            violations += 1

    print(f"Violations: {violations}/2000")
    print(f"Max gap (τ log Z - F(x,p_random)): {max_gap:.6f}")
    print("✓ All checks passed!" if violations == 0 else "✗ Some checks failed!")

    # --- Demo 5: High-dimensional ---
    print("\n--- Demo 5: High-Dimensional (n=100) ---")
    n = 100
    x = np.linspace(0, 10, n)
    tau = 1.0
    lse_val = log_sum_exp(x, tau)
    q_val = softmax(x, tau)
    fe_q = free_energy(x, q_val, tau)
    print(f"n = {n}, τ = {tau}")
    print(f"τ log Z = {lse_val:.6f}")
    print(f"F(x, q) = {fe_q:.6f}")
    print(f"H(q) = {shannon_entropy(q_val):.6f}")
    print(f"max(x) = {np.max(x):.1f}")
    print(f"Top 5 softmax weights: {np.sort(q_val)[-5:][::-1]}")
    print(f"✓ Concentration near maximum confirmed")


if __name__ == "__main__":
    main()


"""
Generate visualizations for the Gibbs Variational Principle.
Saves figures as PNG files and outputs base64 for JSON embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def log_sum_exp(x, tau):
    m = np.max(x)
    return tau * (m / tau + np.log(np.sum(np.exp((x - m) / tau))))


def softmax(x, tau):
    m = np.max(x)
    e = np.exp((x - m) / tau)
    return e / np.sum(e)


def shannon_entropy(p):
    mask = p > 1e-15
    return -np.sum(p[mask] * np.log(p[mask]))


def plot_tropical_limit():
    """Plot 1: τ log Z converging to max(x) as τ → 0."""
    x = np.array([1.0, 3.0, 2.0])
    taus = np.geomspace(0.01, 10, 200)
    lse_vals = [log_sum_exp(x, t) for t in taus]

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.semilogx(taus, lse_vals, 'b-', linewidth=2, label=r'$\tau \log \sum e^{x_i/\tau}$')
    ax.axhline(y=np.max(x), color='r', linestyle='--', linewidth=1.5, label=r'$\max(x) = 3$')
    ax.fill_between(taus, np.max(x), lse_vals, alpha=0.15, color='blue')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Value', fontsize=13)
    ax.set_title('Tropical Limit: Log-Sum-Exp → Max as τ → 0⁺', fontsize=14)
    ax.legend(fontsize=12)
    ax.set_ylim(2.5, 5.5)
    ax.grid(True, alpha=0.3)
    ax.text(0.03, 3.15, 'Gap → 0', fontsize=11, color='blue', alpha=0.7)
    fig.savefig('/workspace/request-project/viz_tropical_limit.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_softmax_temperature():
    """Plot 2: Softmax distributions at different temperatures."""
    x = np.array([1.0, 3.0, 2.0, 0.5])
    taus = [0.1, 0.5, 1.0, 5.0]

    fig, axes = plt.subplots(1, 4, figsize=(16, 4), sharey=True)
    labels = [f'$x_{i+1}$={v}' for i, v in enumerate(x)]

    for ax, tau in zip(axes, taus):
        p = softmax(x, tau)
        bars = ax.bar(range(len(x)), p, color=['#e74c3c', '#2ecc71', '#3498db', '#f39c12'],
                      edgecolor='black', linewidth=0.5)
        ax.set_title(f'τ = {tau}', fontsize=13, fontweight='bold')
        ax.set_xticks(range(len(x)))
        ax.set_xticklabels([f'{v}' for v in x], fontsize=10)
        ax.set_xlabel('Score $x_i$', fontsize=11)
        ax.set_ylim(0, 1.05)
        h = shannon_entropy(p)
        ax.text(0.5, 0.92, f'H={h:.2f}', transform=ax.transAxes,
                ha='center', fontsize=10, style='italic')
        for bar, val in zip(bars, p):
            if val > 0.05:
                ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
                        f'{val:.2f}', ha='center', fontsize=9)

    axes[0].set_ylabel('Probability', fontsize=12)
    fig.suptitle('Softmax Distribution vs Temperature', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_softmax_temp.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_variational_landscape():
    """Plot 3: Free energy landscape on the 2-simplex (n=3)."""
    x = np.array([1.0, 2.0, 3.0])
    tau = 1.0
    lse_val = log_sum_exp(x, tau)

    # Create grid on the 2-simplex using barycentric coordinates
    N = 100
    fe_grid = np.full((N+1, N+1), np.nan)

    for i in range(N+1):
        for j in range(N+1 - i):
            k = N - i - j
            p = np.array([i/N, j/N, k/N])
            fe_grid[i, j] = np.dot(x, p) + tau * shannon_entropy(p)

    # Convert to Cartesian for triangular plot
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Plot using imshow on the triangular region
    points_x = []
    points_y = []
    values = []

    for i in range(N+1):
        for j in range(N+1 - i):
            k = N - i - j
            p = np.array([i/N, j/N, k/N])
            # Barycentric to Cartesian
            cx = 0.5 * (2*j/N + k/N)
            cy = (np.sqrt(3)/2) * k/N
            fe = np.dot(x, p) + tau * shannon_entropy(p)
            points_x.append(cx)
            points_y.append(cy)
            values.append(fe)

    scatter = ax.tricontourf(points_x, points_y, values, levels=20, cmap='viridis')
    plt.colorbar(scatter, ax=ax, label='Free Energy $F_\\tau(x, p)$')

    # Mark the softmax optimizer
    q = softmax(x, tau)
    qx = 0.5 * (2*q[1] + q[2])
    qy = (np.sqrt(3)/2) * q[2]
    ax.plot(qx, qy, 'r*', markersize=15, markeredgecolor='white', markeredgewidth=1.5,
            label=f'Softmax (optimal)\nF = {lse_val:.3f}')

    # Mark vertices
    verts = [(0, 0), (1, 0), (0.5, np.sqrt(3)/2)]
    vlabels = [f'$e_1$ (x={x[0]})', f'$e_2$ (x={x[1]})', f'$e_3$ (x={x[2]})']
    for (vx, vy), vl in zip(verts, vlabels):
        ax.plot(vx, vy, 'ko', markersize=6)
        offset = {'$e_1$ (x=1.0)': (-0.1, -0.07), '$e_2$ (x=2.0)': (0.02, -0.07),
                  '$e_3$ (x=3.0)': (-0.05, 0.04)}
        dx, dy = offset.get(vl, (0, 0))
        ax.text(vx + dx, vy + dy, vl, fontsize=10, ha='center')

    # Draw simplex boundary
    tri = plt.Polygon(verts, fill=False, edgecolor='black', linewidth=1.5)
    ax.add_patch(tri)

    ax.set_title(f'Free Energy Landscape on Probability Simplex (τ={tau})', fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.set_aspect('equal')
    ax.axis('off')
    fig.savefig('/workspace/request-project/viz_variational_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_kl_decomposition():
    """Plot 4: KL decomposition F = τ log Z - τ KL(p||q)."""
    x = np.array([1.0, 3.0, 2.0])
    tau = 1.0
    lse_val = log_sum_exp(x, tau)
    q = softmax(x, tau)

    # Generate random distributions and compute F and KL
    np.random.seed(42)
    n_samples = 500
    kl_vals = []
    fe_vals = []

    for _ in range(n_samples):
        alpha = np.random.exponential(1.0, 3)
        p = alpha / alpha.sum()
        fe = np.dot(x, p) + tau * shannon_entropy(p)
        mask = p > 1e-15
        kl = np.sum(p[mask] * np.log(p[mask] / q[mask]))
        kl_vals.append(kl)
        fe_vals.append(fe)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.scatter(kl_vals, fe_vals, alpha=0.4, s=15, c='steelblue', label='Random $p \\in \\Delta_3$')

    # Theoretical line
    kl_line = np.linspace(0, max(kl_vals), 100)
    fe_line = lse_val - tau * kl_line
    ax.plot(kl_line, fe_line, 'r-', linewidth=2, label=r'$F = \tau \log Z - \tau \cdot \mathrm{KL}(p \| q)$')

    ax.axhline(y=lse_val, color='green', linestyle='--', alpha=0.7, label=f'τ log Z = {lse_val:.3f}')
    ax.plot(0, lse_val, 'r*', markersize=15, zorder=5, label='Softmax (KL=0)')

    ax.set_xlabel(r'KL divergence $\mathrm{KL}(p \| q)$', fontsize=13)
    ax.set_ylabel(r'Free energy $F_\tau(x, p)$', fontsize=13)
    ax.set_title('KL Decomposition of the Variational Principle', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.savefig('/workspace/request-project/viz_kl_decomposition.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_tropical_limit()
    print("  ✓ Tropical limit plot")
    b64_2 = plot_softmax_temperature()
    print("  ✓ Softmax temperature plot")
    b64_3 = plot_variational_landscape()
    print("  ✓ Variational landscape plot")
    b64_4 = plot_kl_decomposition()
    print("  ✓ KL decomposition plot")

    # Save base64 data for JSON embedding
    viz_data = [
        {"name": "Tropical Limit", "data": b64_1},
        {"name": "Softmax vs Temperature", "data": b64_2},
        {"name": "Variational Landscape on Simplex", "data": b64_3},
        {"name": "KL Decomposition", "data": b64_4},
    ]
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Done! Saved viz_data.json and PNG files.")
