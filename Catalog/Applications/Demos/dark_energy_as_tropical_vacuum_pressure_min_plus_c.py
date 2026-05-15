#!/usr/bin/env python3
"""
Applications of Tropical Vacuum Energy

Demonstrates real-world connections of the tropical vacuum energy framework:
1. Shortest-path / network routing (structural identity with Bellman-Ford)
2. Softmax-to-hardmax collapse in neural attention
3. Portfolio optimization under tropical semantics
"""

import numpy as np


# ── Application 1: Shortest Path as Tropical Vacuum Energy ──

def tropical_shortest_path(adj_matrix: np.ndarray, source: int) -> np.ndarray:
    """Compute single-source shortest paths using tropical (min-plus) algebra.

    This is structurally identical to computing tropical vacuum energy:
    the shortest distance to each vertex is the min over all "diagrams"
    (paths) reaching that vertex.

    Implements Bellman-Ford via min-plus matrix power.

    Args:
        adj_matrix: n×n adjacency matrix with edge weights (np.inf for no edge).
        source: Source vertex index.

    Returns:
        Array of shortest distances from source to each vertex.
    """
    n = adj_matrix.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0

    for _ in range(n - 1):
        for u in range(n):
            for v in range(n):
                if dist[u] + adj_matrix[u, v] < dist[v]:
                    dist[v] = dist[u] + adj_matrix[u, v]

    return dist


def demo_shortest_path():
    """Demonstrate the structural identity between shortest paths
    and tropical vacuum energy."""
    print("=" * 60)
    print("APPLICATION 1: Shortest Path = Tropical Vacuum Energy")
    print("=" * 60)

    # Small graph: 5 vertices
    INF = np.inf
    adj = np.array([
        [0,   4,   1, INF, INF],
        [INF,   0, INF,   1, INF],
        [INF,   2,   0,   5, INF],
        [INF, INF, INF,   0,   3],
        [INF, INF, INF, INF,   0],
    ], dtype=float)

    source = 0
    dists = tropical_shortest_path(adj, source)

    print(f"Graph has {adj.shape[0]} vertices.")
    print(f"Shortest distances from vertex {source}:")
    for v, d in enumerate(dists):
        print(f"  vertex {v}: distance = {d}")

    # The distance to vertex 4 is the "tropical vacuum energy" over all
    # paths from 0 to 4, where each path is a "diagram" with action = length
    target = 4
    print(f"\nTropical vacuum energy (0 → {target}) = {dists[target]}")
    print("This is min over all path-diagrams from 0 to 4.")
    print("  Path 0→2→1→3→4: cost = 1+2+1+3 = 7")
    print("  Path 0→1→3→4:   cost = 4+1+3 = 8")
    print("  Minimum (tropical): 7 ✓")
    print()


# ── Application 2: Softmax → Hardmax as Tropicalization ──

def softmax(logits: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """Compute softmax with inverse temperature β."""
    scaled = beta * logits
    shifted = scaled - np.max(scaled)
    exp_vals = np.exp(shifted)
    return exp_vals / np.sum(exp_vals)


def demo_softmax_tropicalization():
    """Demonstrate that softmax → hardmax as β → ∞ (tropicalization).

    In attention mechanisms, softmax aggregates all key-value pairs.
    The tropical limit selects only the highest-scoring pair — this is
    the same selector principle as tropical vacuum energy."""
    print("=" * 60)
    print("APPLICATION 2: Softmax → Hardmax (Tropicalization)")
    print("=" * 60)

    # Attention scores for 5 tokens
    scores = np.array([1.0, 3.5, 2.0, 3.5, 0.5])
    print(f"Attention scores: {list(scores)}")
    print()

    print(f"{'β':>8s} | Attention weights (softmax)")
    print("-" * 60)
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        weights = softmax(scores, beta)
        w_str = "  ".join(f"{w:.4f}" for w in weights)
        print(f"{beta:8.1f} | {w_str}")

    print()
    print("As β → ∞, softmax concentrates on the maximum score(s).")
    print("This is the tropical selector principle: the partition function")
    print("becomes a max-selector (equivalently, -scores gives a min-selector).")
    print()


# ── Application 3: Portfolio Optimization ──

def tropical_portfolio_selection(
    scenarios: dict[str, list[float]],
    risk_aversion: str = "worst_case"
) -> tuple[str, float]:
    """Select a portfolio using tropical (min-plus) optimization.

    Under worst-case (minimax) risk, the optimal portfolio minimizes
    the maximum loss across scenarios — this is tropical optimization.

    Args:
        scenarios: Dict mapping portfolio name to list of returns across scenarios.
        risk_aversion: 'worst_case' uses min of returns (tropical).

    Returns:
        (best_portfolio_name, its_worst_case_return)
    """
    # For each portfolio, compute worst-case return (min across scenarios)
    worst_cases = {name: min(returns) for name, returns in scenarios.items()}

    # Select portfolio with best worst-case (maximin = tropical optimum)
    best = max(worst_cases, key=worst_cases.get)
    return best, worst_cases[best]


def demo_portfolio():
    """Demonstrate tropical portfolio selection."""
    print("=" * 60)
    print("APPLICATION 3: Tropical Portfolio Selection (Minimax)")
    print("=" * 60)

    scenarios = {
        "Aggressive":   [0.30, -0.25, 0.15, -0.40, 0.20],
        "Balanced":     [0.12, -0.05, 0.08, -0.10, 0.10],
        "Conservative": [0.04,  0.02, 0.03, -0.01, 0.03],
        "Speculative":  [0.50, -0.45, 0.35, -0.60, 0.40],
    }

    print("Scenario returns:")
    print(f"{'Portfolio':>15s} | {'S1':>6s} {'S2':>6s} {'S3':>6s} {'S4':>6s} {'S5':>6s} | {'Worst':>6s}")
    print("-" * 65)
    for name, returns in scenarios.items():
        r_str = " ".join(f"{r:6.2f}" for r in returns)
        worst = min(returns)
        print(f"{name:>15s} | {r_str} | {worst:6.2f}")

    best_name, best_worst = tropical_portfolio_selection(scenarios)
    print(f"\nTropical optimal portfolio: {best_name}")
    print(f"Worst-case return: {best_worst:.2f}")
    print()
    print("The tropical selector picks the portfolio with the best")
    print("worst-case outcome — identical to the vacuum energy selecting")
    print("the least-action diagram.")
    print()


if __name__ == "__main__":
    demo_shortest_path()
    demo_softmax_tropicalization()
    demo_portfolio()


#!/usr/bin/env python3
"""
Tropical Vacuum Energy — Demonstrations

Concrete numerical examples illustrating the theorems proved in the
formal framework. Each demo corresponds to a specific theorem.
"""

import numpy as np


def tropical_vacuum_energy(actions: list[float]) -> tuple[float, int]:
    """Compute the tropical vacuum energy (min-plus sum) of a list of actions.

    Returns (vacuum_energy, minimizer_index).
    """
    if not actions:
        raise ValueError("Need at least one diagram")
    min_idx = int(np.argmin(actions))
    return actions[min_idx], min_idx


def demo_selector_principle():
    """Theorem 2 & 3: The tropical vacuum energy is attained by an actual diagram
    and dominates all others."""
    print("=" * 60)
    print("DEMO 1: Selector Principle (Theorems 2 & 3)")
    print("=" * 60)

    actions = [5.0, 2.0, 8.0, 3.0, 7.0]
    e_vac, idx = tropical_vacuum_energy(actions)

    print(f"Diagram actions: {actions}")
    print(f"Tropical vacuum energy: {e_vac}")
    print(f"Minimizing diagram index: {idx} (action = {actions[idx]})")
    print(f"Dominates all others: {all(e_vac <= a for a in actions)}")
    print()


def demo_catastrophe_collapse():
    """Theorem 5: Adding high-action diagrams doesn't change vacuum energy."""
    print("=" * 60)
    print("DEMO 2: Catastrophe Collapse (Theorem 5)")
    print("=" * 60)

    # Start with ground state
    base_actions = [2.0]
    e_vac_base, _ = tropical_vacuum_energy(base_actions)
    print(f"Base diagram: action = {base_actions[0]}")
    print(f"Initial vacuum energy: {e_vac_base}")
    print()

    # Add diagrams spanning 120 orders of magnitude
    print("Adding high-energy diagrams:")
    current_actions = list(base_actions)
    for k in [6, 30, 60, 90, 120]:
        new_action = 10.0 ** k
        current_actions.append(new_action)
        e_vac, _ = tropical_vacuum_energy(current_actions)
        print(f"  Added 10^{k:3d} → vacuum energy = {e_vac}"
              f"  (changed: {e_vac != e_vac_base})")

    print(f"\nAfter adding 5 diagrams up to 10^120:")
    print(f"  Standard sum: {sum(current_actions):.2e}")
    print(f"  Tropical min: {tropical_vacuum_energy(current_actions)[0]}")
    print(f"  Ratio: {sum(current_actions) / tropical_vacuum_energy(current_actions)[0]:.2e}")
    print()


def demo_gap_rigidity():
    """Theorem 6: Positive spectral gap certifies robustness."""
    print("=" * 60)
    print("DEMO 3: Gap Rigidity (Theorem 6)")
    print("=" * 60)

    actions = [1.0, 3.5, 5.0, 7.2, 9.1]
    e_vac, idx = tropical_vacuum_energy(actions)
    gap = min(a - actions[idx] for a in actions if a != actions[idx])

    print(f"Actions: {actions}")
    print(f"Vacuum energy: {e_vac} (diagram {idx})")
    print(f"Spectral gap δ = {gap}")
    print(f"Robustness: perturbations < {gap/2:.2f} cannot change the vacuum sector")
    print()

    # Show robustness under perturbation
    print("Perturbation test:")
    rng = np.random.default_rng(42)
    for eps in [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        perturbed = [a + rng.uniform(-eps, eps) for a in actions]
        e_pert, idx_pert = tropical_vacuum_energy(perturbed)
        same_sector = idx_pert == idx
        print(f"  ε = {eps:.1f}: minimizer = diagram {idx_pert}"
              f"  (same sector: {same_sector})")
    print()


def demo_shift_covariance():
    """Theorem 7: Uniform shifts translate vacuum energy covariantly."""
    print("=" * 60)
    print("DEMO 4: Shift Covariance (Theorem 7)")
    print("=" * 60)

    actions = [3.0, 1.0, 4.0, 1.5, 9.0]
    e_vac, _ = tropical_vacuum_energy(actions)

    print(f"Original actions: {actions}")
    print(f"Original vacuum energy: {e_vac}")
    print()

    for c in [-5.0, 0.0, 2.7, 100.0]:
        shifted = [a + c for a in actions]
        e_shifted, _ = tropical_vacuum_energy(shifted)
        print(f"  Shift c = {c:6.1f}: E_vac(S+c) = {e_shifted:8.1f}"
              f"  =  c + E_vac(S) = {c + e_vac:8.1f}"
              f"  (match: {np.isclose(e_shifted, c + e_vac)})")
    print()


def demo_log_sum_exp_convergence():
    """Numerical verification of the zero-temperature limit:
    -1/β · log(Σ exp(-β·S_i)) → min(S_i) as β → ∞."""
    print("=" * 60)
    print("DEMO 5: Log-Sum-Exp Convergence (Future Direction 1)")
    print("=" * 60)

    actions = np.array([1.0, 3.0, 5.0, 7.0, 9.0])
    min_action = np.min(actions)

    print(f"Actions: {list(actions)}")
    print(f"Tropical vacuum energy (min): {min_action}")
    print()

    print(f"{'β':>10s} | {'F(β)':>15s} | {'min S':>10s} | {'|Error|':>12s}")
    print("-" * 55)

    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        # Use log-sum-exp trick for numerical stability
        shifted = -beta * actions
        max_shifted = np.max(shifted)
        log_sum = max_shifted + np.log(np.sum(np.exp(shifted - max_shifted)))
        free_energy = -log_sum / beta
        error = abs(free_energy - min_action)
        print(f"{beta:10.1f} | {free_energy:15.10f} | {min_action:10.1f} | {error:12.2e}")

    print()


def demo_monotonicity():
    """Theorem 9: Enlarging the diagram set can only decrease vacuum energy."""
    print("=" * 60)
    print("DEMO 6: Monotonicity (Theorem 9)")
    print("=" * 60)

    all_actions = [8.0, 3.0, 6.0, 1.0, 5.0, 9.0, 2.0, 7.0]

    print("Progressive enlargement of diagram set:")
    for k in range(1, len(all_actions) + 1):
        subset = all_actions[:k]
        e_vac, _ = tropical_vacuum_energy(subset)
        print(f"  |s| = {k}: actions = {subset!s:40s} → E_vac = {e_vac}")

    print("\nVacuum energy is non-increasing as the set grows.")
    print()


if __name__ == "__main__":
    demo_selector_principle()
    demo_catastrophe_collapse()
    demo_gap_rigidity()
    demo_shift_covariance()
    demo_log_sum_exp_convergence()
    demo_monotonicity()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""
import json
import base64
from pathlib import Path

# Read text files
def read_file(path):
    return Path(path).read_text()

# Read and encode image
def encode_image(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Physics/Quantum/TropicalVacuumEnergy.lean')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Encode images
img_collapse = encode_image('fig_catastrophe_collapse.png')
img_convergence = encode_image('fig_convergence.png')
img_gap = encode_image('fig_gap_rigidity.png')
img_phase = encode_image('fig_phase_diagram.png')

package = {
    "title": "Tropical Vacuum Energy: Min-Plus Cosmological Constant and the Selector Principle",
    "domain": "Mathematical Physics / Tropical Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Vacuum Energy Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Vacuum Energy Computation",
            "pseudocode": "Input: Finite set of actions {S(i) : i in s}\nOutput: E_vac^trop\n\nE_vac <- +infinity\nminimizer <- None\nfor each i in s:\n    if S(i) < E_vac:\n        E_vac <- S(i)\n        minimizer <- i\nreturn (E_vac, minimizer)\n\nComplexity: O(|s|) time, O(1) space",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "Vacuum Catastrophe Collapse: Additive vs Tropical",
            "data": img_collapse
        },
        {
            "name": "Zero-Temperature Convergence: Log-Sum-Exp to Min",
            "data": img_convergence
        },
        {
            "name": "Gap Rigidity: Robustness Under Perturbation",
            "data": img_gap
        },
        {
            "name": "Tropical Phase Diagram: Piecewise-Linear Vacuum Energy",
            "data": img_phase
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({Path('PACKAGE.json').stat().st_size} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Tropical Vacuum Energy

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_catastrophe_collapse():
    """Visualize the vacuum catastrophe collapse:
    standard (additive) vs tropical (min-plus) vacuum energy."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Diagram actions spanning many orders of magnitude
    orders = [0, 6, 30, 60, 90, 120]
    actions = [10.0**k for k in orders]
    labels = [f"$10^{{{k}}}$" for k in orders]

    # Standard (additive)
    cumulative = np.cumsum(actions)
    ax1.bar(range(len(actions)), actions, color='#e74c3c', alpha=0.7, label='Individual')
    ax1.plot(range(len(actions)), cumulative, 'ko-', markersize=8, label='Cumulative sum')
    ax1.set_yscale('log')
    ax1.set_xticks(range(len(actions)))
    ax1.set_xticklabels(labels, fontsize=10)
    ax1.set_xlabel('Diagram action', fontsize=12)
    ax1.set_ylabel('Energy (log scale)', fontsize=12)
    ax1.set_title('Standard QFT: Additive\n(Vacuum Catastrophe)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)

    # Tropical (min-plus)
    tropical_cumulative = [min(actions[:k+1]) for k in range(len(actions))]
    ax2.bar(range(len(actions)), actions, color='#3498db', alpha=0.3, label='Individual')
    ax2.plot(range(len(actions)), tropical_cumulative, 'go-', markersize=10,
             linewidth=2, label='Tropical min', zorder=5)
    ax2.axhline(y=1.0, color='green', linestyle='--', alpha=0.5, label=f'Vacuum = {actions[0]}')
    ax2.set_yscale('log')
    ax2.set_xticks(range(len(actions)))
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_xlabel('Diagram action', fontsize=12)
    ax2.set_ylabel('Energy (log scale)', fontsize=12)
    ax2.set_title('Tropical QFT: Min-Plus\n(Catastrophe Collapse)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)

    fig.suptitle('Vacuum Energy: Additive vs Tropical', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('/workspace/request-project/fig_catastrophe_collapse.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_log_sum_exp_convergence():
    """Visualize convergence of log-sum-exp to min (zero-temperature limit)."""
    fig, ax = plt.subplots(figsize=(8, 5))

    actions = np.array([1.0, 3.0, 5.0, 7.0, 9.0])
    min_action = np.min(actions)

    betas = np.logspace(-1, 3, 200)
    free_energies = []
    for beta in betas:
        shifted = -beta * actions
        max_s = np.max(shifted)
        log_sum = max_s + np.log(np.sum(np.exp(shifted - max_s)))
        free_energies.append(-log_sum / beta)

    ax.semilogx(betas, free_energies, 'b-', linewidth=2, label=r'$F(\beta) = -\frac{1}{\beta}\log\sum e^{-\beta S_i}$')
    ax.axhline(y=min_action, color='r', linestyle='--', linewidth=2, label=r'$\min S_i$ (tropical limit)')

    # Theoretical bound
    bound = min_action + np.log(len(actions)) / betas
    ax.semilogx(betas, bound, 'g:', linewidth=1.5, alpha=0.7, label=r'Upper bound: $\min S + \frac{\log|s|}{\beta}$')

    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel('Energy', fontsize=13)
    ax.set_title('Zero-Temperature Limit: Free Energy → Tropical Vacuum Energy', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0.5, 5.5)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_gap_rigidity():
    """Visualize gap rigidity: robustness under perturbation."""
    fig, ax = plt.subplots(figsize=(8, 5))

    np.random.seed(42)
    base_actions = [1.0, 3.5, 5.0, 7.0, 9.0]
    gap = base_actions[1] - base_actions[0]  # δ = 2.5

    epsilons = np.linspace(0, 3.0, 100)
    n_trials = 200

    # For each epsilon, run many perturbation trials and check if minimizer changes
    stability_fraction = []
    for eps in epsilons:
        same_count = 0
        for _ in range(n_trials):
            perturbed = [a + np.random.uniform(-eps, eps) for a in base_actions]
            if np.argmin(perturbed) == 0:
                same_count += 1
        stability_fraction.append(same_count / n_trials)

    ax.plot(epsilons, stability_fraction, 'b-', linewidth=2, label='Empirical stability')
    ax.axvline(x=gap/2, color='r', linestyle='--', linewidth=2,
               label=f'Guaranteed stable (δ/2 = {gap/2:.2f})')
    ax.axvspan(0, gap/2, alpha=0.1, color='green', label='Certified robust region')

    ax.set_xlabel('Perturbation magnitude ε', fontsize=13)
    ax.set_ylabel('Probability minimizer unchanged', fontsize=13)
    ax.set_title('Gap Rigidity: Robustness Under Perturbation', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11, loc='lower left')
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_gap_rigidity.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_phase_diagram():
    """Visualize tropical phase transitions: vacuum energy as a function
    of coupling constant λ."""
    fig, ax = plt.subplots(figsize=(8, 5))

    lambdas = np.linspace(-2, 5, 1000)

    # Three diagrams with actions depending on λ
    S1 = lambda l: 2.0 + 0.5 * l
    S2 = lambda l: 4.0 - 0.3 * l
    S3 = lambda l: 1.0 + 1.2 * l

    s1_vals = [S1(l) for l in lambdas]
    s2_vals = [S2(l) for l in lambdas]
    s3_vals = [S3(l) for l in lambdas]
    vac_energy = [min(S1(l), S2(l), S3(l)) for l in lambdas]

    ax.plot(lambdas, s1_vals, 'r--', alpha=0.5, label=r'$S_1(\lambda) = 2 + 0.5\lambda$')
    ax.plot(lambdas, s2_vals, 'b--', alpha=0.5, label=r'$S_2(\lambda) = 4 - 0.3\lambda$')
    ax.plot(lambdas, s3_vals, 'g--', alpha=0.5, label=r'$S_3(\lambda) = 1 + 1.2\lambda$')
    ax.plot(lambdas, vac_energy, 'k-', linewidth=3, label=r'$E_{\mathrm{vac}}^{\mathrm{trop}}(\lambda)$')

    ax.set_xlabel(r'Coupling constant $\lambda$', fontsize=13)
    ax.set_ylabel('Action / Energy', fontsize=13)
    ax.set_title('Tropical Phase Diagram: Piecewise-Linear Vacuum Energy', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_phase_diagram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_catastrophe_collapse()
    print(f"  fig_catastrophe_collapse.png ({len(b64_1)} chars base64)")
    b64_2 = plot_log_sum_exp_convergence()
    print(f"  fig_convergence.png ({len(b64_2)} chars base64)")
    b64_3 = plot_gap_rigidity()
    print(f"  fig_gap_rigidity.png ({len(b64_3)} chars base64)")
    b64_4 = plot_phase_diagram()
    print(f"  fig_phase_diagram.png ({len(b64_4)} chars base64)")
    print("Done.")
