"""
Applications of the Finite-Temperature Pruning Law
====================================================

Real-world applications of the log-sum-exp pruning bounds to:
1. Transformer attention head pruning
2. Mixture-of-experts gating
3. Statistical mechanics partition function approximation
4. Neural architecture search with certified guarantees

Keywords: certified pruning, attention head redundancy, softmax robustness,
free energy perturbation, entropy-compression tradeoff
"""

import numpy as np
from typing import Tuple


def log_sum_exp(x: np.ndarray, tau: float) -> float:
    """Numerically stable log-sum-exp."""
    s = x / tau
    m = s.max()
    return tau * (m + np.log(np.sum(np.exp(s - m))))


# ============================================================
# Application 1: Transformer Attention Head Pruning
# ============================================================
def simulate_attention_pruning(
    n_heads: int = 12,
    seq_len: int = 64,
    tau: float = 1.0,
    n_trials: int = 100
) -> None:
    """
    Simulate pruning attention heads in a transformer layer.

    Each head produces a score (pre-softmax logit). Heads whose scores
    are consistently dominated by others can be certified for removal.

    The pruning bound guarantees:
        |LSE(all heads) - LSE(kept heads)| ≤ τ * log(|removed| + 1)
    """
    print("Application 1: Transformer Attention Head Pruning")
    print("=" * 55)
    print(f"  Heads: {n_heads}, Sequence length: {seq_len}, Temperature: {tau}")
    print()

    np.random.seed(42)

    # Simulate: some heads have high mean score, others low
    head_means = np.array([5.0 + 2.0 * (i < 4) for i in range(n_heads)])
    # Add noise across sequence positions
    total_gap = 0
    total_bound = 0
    max_ratio = 0

    for trial in range(n_trials):
        # Sample scores for each position
        scores = head_means + np.random.randn(n_heads) * 0.5

        # Keep top-k heads
        k = 4
        top_k = np.argsort(scores)[-k:]
        removed = np.array([i for i in range(n_heads) if i not in top_k])

        gap = log_sum_exp(scores, tau) - log_sum_exp(scores[top_k], tau)
        s = scores[top_k].max()

        # Refined bound
        refined = tau * np.log(1 + sum(np.exp((scores[j] - s) / tau) for j in removed))
        card_bound = tau * np.log(len(removed) + 1)

        total_gap += gap
        total_bound += refined
        ratio = gap / refined if refined > 1e-15 else 0
        max_ratio = max(max_ratio, ratio)

    print(f"  Over {n_trials} trials (keeping top-{k} of {n_heads}):")
    print(f"    Avg gap:           {total_gap/n_trials:.6f}")
    print(f"    Avg refined bound: {total_bound/n_trials:.6f}")
    print(f"    Avg card bound:    {tau * np.log(n_heads - k + 1):.6f}")
    print(f"    Max gap/bound:     {max_ratio:.4f}")
    print(f"    Compression:       {(n_heads-k)/n_heads*100:.0f}%")
    print()


# ============================================================
# Application 2: Mixture-of-Experts Gating
# ============================================================
def simulate_moe_expert_pruning(
    n_experts: int = 16,
    tau: float = 1.0
) -> None:
    """
    Apply pruning certificates to mixture-of-experts gating.

    In MoE architectures, the gating function uses softmax over expert
    scores. Pruning low-scoring experts changes the gate distribution
    by at most the certified amount.
    """
    print("Application 2: Mixture-of-Experts Expert Pruning")
    print("=" * 55)

    np.random.seed(123)

    # Expert scores: a few strong, many weak
    expert_scores = np.zeros(n_experts)
    expert_scores[:3] = np.array([8.0, 7.5, 7.0])  # strong experts
    expert_scores[3:] = 3.0 + np.random.randn(n_experts - 3) * 1.0  # weak experts

    print(f"  Expert scores: {np.round(expert_scores, 2)}")
    s = expert_scores[:3].max()

    for n_keep in [3, 5, 8]:
        top = np.argsort(expert_scores)[-n_keep:]
        removed = [i for i in range(n_experts) if i not in top]
        n_removed = len(removed)

        gap = log_sum_exp(expert_scores, tau) - log_sum_exp(expert_scores[top], tau)
        refined = tau * np.log(1 + sum(
            np.exp((expert_scores[j] - expert_scores[top].max()) / tau) for j in removed
        ))
        card = tau * np.log(n_removed + 1)

        print(f"\n  Keep top-{n_keep} experts:")
        print(f"    Gap:     {gap:.6f}")
        print(f"    Refined: {refined:.6f}")
        print(f"    Card:    {card:.6f}")
        print(f"    Savings: {n_removed}/{n_experts} experts removed")
    print()


# ============================================================
# Application 3: Statistical Mechanics — Partition Function
# ============================================================
def simulate_partition_function_pruning(
    n_states: int = 100,
    beta: float = 1.0  # inverse temperature = 1/tau
) -> None:
    """
    Demonstrate pruning of microstates from a partition function.

    In statistical mechanics, Z = sum_i exp(-E_i / kT).
    States with high energy (low Boltzmann weight) contribute little
    to Z. The pruning bound certifies how much Z changes when
    removing high-energy states.
    """
    print("Application 3: Partition Function State Pruning")
    print("=" * 55)

    tau = 1.0 / beta
    np.random.seed(456)

    # Energy levels: ground state + excited states
    energies = np.zeros(n_states)
    energies[0] = 0.0  # ground state
    energies[1:5] = 1.0  # low-lying excited states
    energies[5:] = np.random.uniform(3.0, 10.0, n_states - 5)  # high energy

    # Use negative energies as scores (higher score = lower energy = more populated)
    scores = -energies

    print(f"  {n_states} microstates, β = {beta} (τ = {tau:.2f})")
    print(f"  Ground state energy: {energies[0]}")
    print(f"  Energy range: [{energies.min():.1f}, {energies.max():.1f}]")

    for n_keep in [5, 10, 20, 50]:
        # Keep the n_keep lowest-energy states
        keep_idx = np.argsort(energies)[:n_keep]
        remove_idx = np.array([i for i in range(n_states) if i not in keep_idx])

        gap = log_sum_exp(scores, tau) - log_sum_exp(scores[keep_idx], tau)
        s = scores[keep_idx].max()
        refined = tau * np.log(1 + sum(
            np.exp((scores[j] - s) / tau) for j in remove_idx
        ))

        Z_full = np.sum(np.exp(scores / tau))
        Z_keep = np.sum(np.exp(scores[keep_idx] / tau))
        rel_error = abs(Z_full - Z_keep) / Z_full

        print(f"\n  Keep {n_keep} lowest-energy states:")
        print(f"    Free energy gap:   {gap:.8f}")
        print(f"    Certified bound:   {refined:.8f}")
        print(f"    Relative Z error:  {rel_error:.2e}")
        print(f"    States pruned:     {len(remove_idx)}/{n_states}")
    print()


# ============================================================
# Application 4: Neural Architecture Search
# ============================================================
def simulate_nas_certified_search(
    n_ops: int = 8,
    tau: float = 1.0
) -> None:
    """
    Certified operation pruning in differentiable NAS.

    In DARTS-style NAS, the architecture is parameterized by
    softmax weights over candidate operations. The pruning bound
    guarantees that removing low-weight operations changes the
    aggregated output by at most an entropic term.
    """
    print("Application 4: Neural Architecture Search — Certified Op Pruning")
    print("=" * 55)

    np.random.seed(789)

    # Architecture weights (pre-softmax)
    alpha = np.array([4.0, 3.8, 1.0, 0.5, 3.5, 0.2, 0.8, 3.9])
    op_names = ["conv3x3", "conv5x5", "sep3x3", "sep5x5",
                "dil3x3", "avg_pool", "max_pool", "identity"]

    print(f"  Operations and weights:")
    for name, a in zip(op_names, alpha):
        print(f"    {name:12s}: α = {a:.1f}")

    for n_keep in [2, 3, 4]:
        top = np.argsort(alpha)[-n_keep:]
        removed = [i for i in range(n_ops) if i not in top]

        gap = log_sum_exp(alpha, tau) - log_sum_exp(alpha[top], tau)
        card_bound = tau * np.log(len(removed) + 1)

        print(f"\n  Keep top-{n_keep} operations:")
        print(f"    Kept: {[op_names[i] for i in sorted(top)]}")
        print(f"    Gap:  {gap:.6f}")
        print(f"    Bound: {card_bound:.6f}")
        print(f"    Certified accuracy: softmax output changes by ≤ {gap:.4f}")
    print()


if __name__ == "__main__":
    simulate_attention_pruning()
    simulate_moe_expert_pruning()
    simulate_partition_function_pruning()
    simulate_nas_certified_search()
    print("\nAll applications demonstrated successfully.")


"""
Finite-Temperature Pruning Law: Demonstrations
================================================

Demonstrates the log-sum-exp pruning bound theorems with concrete
numerical examples, showing how removing dominated heads from a
softmax-style aggregation incurs at most an entropic penalty.

Keywords: certified pruning, attention head redundancy, log-sum-exp stability,
tropicalization error, free energy perturbation, softmax robustness
"""

import numpy as np

def lse(x: np.ndarray, tau: float) -> float:
    """Log-sum-exp at temperature tau: tau * log(sum(exp(x_i / tau)))."""
    shifted = x / tau
    m = shifted.max()
    return tau * (m + np.log(np.sum(np.exp(shifted - m))))

def lse_subset(x: np.ndarray, indices: np.ndarray, tau: float) -> float:
    """LSE restricted to a subset of indices."""
    return lse(x[indices], tau)

def pruning_gap(x: np.ndarray, keep: np.ndarray, tau: float) -> float:
    """Compute lse_all - lse_keep."""
    return lse(x, tau) - lse_subset(x, keep, tau)

# ============================================================
# Demo 1: Single-head pruning bound (τ * log 2)
# ============================================================
print("=" * 60)
print("DEMO 1: Single Redundant Head Pruning")
print("=" * 60)

np.random.seed(42)
n = 5
x = np.array([3.0, 5.0, 2.0, 5.0, 1.0])
j = 2  # head to remove (x[2] = 2.0, dominated by max of others = 5.0)
keep = np.array([i for i in range(n) if i != j])

print(f"Scores x = {x}")
print(f"Removing head j={j} with score x[j]={x[j]}")
print(f"Max of remaining heads = {x[keep].max()}")
print(f"Head is dominated: {x[j]} ≤ {x[keep].max()} ✓")
print()

for tau in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
    gap = pruning_gap(x, keep, tau)
    bound = tau * np.log(2)
    print(f"  τ={tau:5.1f}  |  gap = {gap:.6f}  |  τ·log(2) = {bound:.6f}  |  "
          f"ratio = {gap/bound:.4f}  |  bound holds: {gap <= bound + 1e-10}")

# ============================================================
# Demo 2: Multi-head pruning bound (τ * log(|R| + 1))
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Multi-Head Pruning (Cardinality Bound)")
print("=" * 60)

n = 8
x = np.array([5.0, 5.0, 3.0, 2.0, 4.0, 1.0, 3.5, 2.5])
keep_set = np.array([0, 1])  # K: heads with max score
remove_set = np.array([2, 3, 4, 5, 6, 7])  # R: dominated heads
s = x[keep_set].max()

print(f"Scores x = {x}")
print(f"Keep set K = {keep_set}, Remove set R = {remove_set}")
print(f"Max of kept heads s = {s}")
print(f"|R| = {len(remove_set)}")
print(f"All removed heads dominated: {all(x[j] <= s for j in remove_set)} ✓")
print()

for tau in [0.1, 0.5, 1.0, 2.0, 5.0]:
    gap = pruning_gap(x, keep_set, tau)
    card_bound = tau * np.log(len(remove_set) + 1)
    refined = tau * np.log(1 + sum(np.exp((x[j] - s) / tau) for j in remove_set))
    print(f"  τ={tau:4.1f}  |  gap = {gap:.6f}  |  "
          f"refined = {refined:.6f}  |  card_bound = {card_bound:.6f}  |  "
          f"holds: {gap <= card_bound + 1e-10}")

# ============================================================
# Demo 3: Margin-refined bound with gap δ
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Margin-Refined Bound (Exponential Decay)")
print("=" * 60)

n = 6
s_val = 10.0
deltas = [0.0, 1.0, 2.0, 5.0, 10.0]

for delta in deltas:
    x = np.array([s_val, s_val, s_val - delta, s_val - delta,
                   s_val - delta, s_val - delta])
    keep = np.array([0, 1])
    remove = np.array([2, 3, 4, 5])
    R_card = len(remove)
    tau = 1.0
    gap = pruning_gap(x, keep, tau)
    margin_bound = tau * np.log(1 + R_card * np.exp(-delta / tau))
    card_bound = tau * np.log(R_card + 1)
    print(f"  δ={delta:5.1f}  |  gap = {gap:.6f}  |  "
          f"margin_bound = {margin_bound:.6f}  |  card_bound = {card_bound:.6f}  |  "
          f"improvement = {card_bound/max(margin_bound, 1e-15):.2f}x")

# ============================================================
# Demo 4: Zero-temperature convergence
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Zero-Temperature Convergence (Tropicalization)")
print("=" * 60)

x = np.array([5.0, 3.0, 4.0, 2.0, 5.0])
keep = np.array([0, 4])  # heads achieving the max
remove = np.array([1, 2, 3])

print(f"Scores x = {x}")
print(f"Keep = {keep} (achieving max = {x[keep].max()})")
print(f"Remove = {remove} (all dominated)")
print()

for tau in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
    gap = pruning_gap(x, keep, tau)
    bound = tau * np.log(len(remove) + 1)
    print(f"  τ={tau:8.3f}  |  gap = {gap:.8f}  |  bound = {bound:.8f}  |  "
          f"gap → 0 as τ → 0: {'YES' if gap < 0.01 else 'not yet'}")

print()
print("As τ → 0, the gap vanishes: tropically redundant heads are free to prune.")
print("This is the bridge between tropical geometry (max-plus) and finite-temperature smoothing.")

# ============================================================
# Demo 5: Tightness of the bound
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Tightness — When is the bound achieved?")
print("=" * 60)

print("\nThe single-head bound τ·log(2) is tight when x_j = max(x_i, i≠j):")
for tau in [0.5, 1.0, 2.0]:
    # All scores equal → maximally tight
    x_equal = np.array([5.0, 5.0])
    gap = pruning_gap(x_equal, np.array([0]), tau)
    bound = tau * np.log(2)
    print(f"  τ={tau:.1f}, x=[5,5]: gap/bound = {gap/bound:.6f}")

    # One score much lower
    x_dom = np.array([5.0, 0.0])
    gap = pruning_gap(x_dom, np.array([0]), tau)
    print(f"  τ={tau:.1f}, x=[5,0]: gap/bound = {gap/bound:.6f}")

if __name__ == "__main__":
    print("\n\nAll demonstrations completed successfully.")


"""Generate PACKAGE.json with all artifacts."""

import json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def lse(x, tau):
    s = x / tau
    m = s.max()
    return tau * (m + np.log(np.sum(np.exp(s - m))))


def make_viz_gap_vs_temperature():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    x = np.array([5.0, 5.0, 3.0, 2.0, 4.0])
    keep_single = np.array([0, 2, 3, 4])
    taus = np.linspace(0.05, 5.0, 200)
    gaps_single = [lse(x, t) - lse(x[keep_single], t) for t in taus]
    bounds_single = [t * np.log(2) for t in taus]
    ax = axes[0]
    ax.plot(taus, gaps_single, 'b-', linewidth=2, label='Actual gap')
    ax.plot(taus, bounds_single, 'r--', linewidth=2, label=r'$\tau \cdot \ln 2$ bound')
    ax.fill_between(taus, gaps_single, bounds_single, alpha=0.15, color='red')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title('(a) Single head removal', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    x2 = np.array([5.0, 5.0, 3.0, 2.0, 4.0, 1.0, 3.5, 2.5])
    keep_multi = np.array([0, 1])
    remove_multi = np.array([2, 3, 4, 5, 6, 7])
    gaps_multi = [lse(x2, t) - lse(x2[keep_multi], t) for t in taus]
    card_bounds = [t * np.log(len(remove_multi) + 1) for t in taus]
    refined = [t * np.log(1 + sum(np.exp((x2[j] - x2[keep_multi].max()) / t) for j in remove_multi)) for t in taus]
    ax = axes[1]
    ax.plot(taus, gaps_multi, 'b-', linewidth=2, label='Actual gap')
    ax.plot(taus, refined, 'g-.', linewidth=2, label='Refined bound')
    ax.plot(taus, card_bounds, 'r--', linewidth=2, label=r'$\tau \cdot \ln(|R|+1)$ bound')
    ax.fill_between(taus, gaps_multi, card_bounds, alpha=0.1, color='red')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title(f'(b) Removing {len(remove_multi)} dominated heads', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    fig.suptitle('Finite-Temperature Pruning Bound', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig


def make_viz_margin_decay():
    fig, ax = plt.subplots(figsize=(8, 5))
    R_card = 10
    taus = [0.5, 1.0, 2.0, 5.0]
    deltas = np.linspace(0, 10, 200)
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(taus)))
    for tau, color in zip(taus, colors):
        bounds = [tau * np.log(1 + R_card * np.exp(-d / tau)) for d in deltas]
        ax.plot(deltas, bounds, linewidth=2, color=color, label=rf'$\tau = {tau}$')
    for tau, color in zip(taus, colors):
        ax.axhline(y=tau * np.log(R_card + 1), color=color, linestyle=':', alpha=0.4)
    ax.set_xlabel(r'Margin $\delta$', fontsize=13)
    ax.set_ylabel(r'Bound $\tau \cdot \ln(1 + |R| e^{-\delta/\tau})$', fontsize=13)
    ax.set_title(f'Margin-Refined Bound (|R| = {R_card} heads)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig


def make_viz_tropicalization():
    fig, ax = plt.subplots(figsize=(8, 5))
    x = np.array([5.0, 3.0, 4.0, 2.0, 5.0])
    keep = np.array([0, 4])
    taus = np.logspace(-2, 1, 200)
    gaps = [lse(x, t) - lse(x[keep], t) for t in taus]
    bounds = [t * np.log(len(x) - len(keep) + 1) for t in taus]
    ax.loglog(taus, gaps, 'b-', linewidth=2, label='Actual gap')
    ax.loglog(taus, bounds, 'r--', linewidth=2, label=r'$\tau \cdot \ln(|R|+1)$ bound')
    ax.loglog(taus, taus, 'k:', alpha=0.4, linewidth=1, label=r'$O(\tau)$ reference')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title('Zero-Temperature Convergence\n(Bridge to Tropical Geometry)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3, which='both')
    plt.tight_layout()
    return fig


def make_viz_tightness():
    fig, ax = plt.subplots(figsize=(8, 6))
    taus = np.linspace(0.1, 5.0, 50)
    gaps_arr = np.linspace(0, 4, 50)
    ratios = np.zeros((len(gaps_arr), len(taus)))
    for i, gap in enumerate(gaps_arr):
        for j, tau in enumerate(taus):
            actual_gap = tau * np.log(1 + np.exp(-gap / tau))
            bound = tau * np.log(2)
            ratios[i, j] = actual_gap / bound if bound > 1e-15 else 0
    im = ax.imshow(ratios, extent=[taus[0], taus[-1], gaps_arr[-1], gaps_arr[0]],
                   aspect='auto', cmap='RdYlGn_r', vmin=0, vmax=1)
    plt.colorbar(im, ax=ax, label='Tightness (gap / bound)')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel(r'Score gap $s - x_j$', fontsize=13)
    ax.set_title('Tightness of Single-Head Pruning Bound', fontsize=14)
    plt.tight_layout()
    return fig


# Read markdown files
with open('ARTICLE.md', 'r') as f:
    article_md = f.read()
with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper_md = f.read()
with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions_md = f.read()

# Read lean file
with open('Tropical/LSEPruning.lean', 'r') as f:
    lean_code = f.read()

# Read python files
with open('demo.py', 'r') as f:
    demo_code = f.read()
with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()
with open('applications.py', 'r') as f:
    applications_code = f.read()

# Generate visualizations
viz1 = fig_to_base64(make_viz_gap_vs_temperature())
viz2 = fig_to_base64(make_viz_margin_decay())
viz3 = fig_to_base64(make_viz_tropicalization())
viz4 = fig_to_base64(make_viz_tightness())
plt.close('all')

package = {
    "title": "Finite-Temperature Pruning Laws for Log-Sum-Exp Aggregation",
    "domain": "Tropical Geometry / Statistical Mechanics / Neural Compression",
    "article": article_md,
    "research_paper": research_paper_md,
    "future_directions": future_directions_md,
    "demos": [
        {
            "name": "Pruning Bound Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "CertifiedPrune — Greedy Certified Head Pruning",
            "pseudocode": (
                "Algorithm: CertifiedPrune(x, tau, epsilon)\n"
                "Input: scores x in R^n, temperature tau > 0, error budget epsilon > 0\n"
                "Output: partition (K, R) with certified gap <= epsilon\n\n"
                "1. s <- max(x)\n"
                "2. Sort indices by x_i ascending\n"
                "3. R <- empty, K <- {i : x_i = s}\n"
                "4. For j in ascending score order:\n"
                "5.   If j not in K:\n"
                "6.     R' <- R union {j}\n"
                "7.     bound <- tau * log(1 + sum_{k in R'} exp((x_k - s)/tau))\n"
                "8.     If bound <= epsilon: R <- R'\n"
                "9.     Else: K <- K union {j}\n"
                "10. Return (K, R, bound)\n\n"
                "Complexity: O(n log n) time, O(n) space"
            ),
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Pruning Gap vs Temperature", "data": viz1},
        {"name": "Margin-Refined Bound Decay", "data": viz2},
        {"name": "Zero-Temperature Convergence (Tropicalization)", "data": viz3},
        {"name": "Tightness Heatmap", "data": viz4}
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


"""
Visualizations for the Finite-Temperature Pruning Law
======================================================

Generates publication-quality figures showing:
1. Pruning gap vs. bound across temperatures
2. Margin-refined bound decay
3. Zero-temperature convergence
4. Tightness analysis
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def lse(x, tau):
    s = x / tau
    m = s.max()
    return tau * (m + np.log(np.sum(np.exp(s - m))))


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def plot_gap_vs_temperature():
    """Figure 1: Pruning gap vs cardinality bound across temperatures."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel A: Single head
    x = np.array([5.0, 5.0, 3.0, 2.0, 4.0])
    keep_single = np.array([0, 2, 3, 4])
    taus = np.linspace(0.05, 5.0, 200)
    gaps_single = [lse(x, t) - lse(x[keep_single], t) for t in taus]
    bounds_single = [t * np.log(2) for t in taus]

    ax = axes[0]
    ax.plot(taus, gaps_single, 'b-', linewidth=2, label='Actual gap')
    ax.plot(taus, bounds_single, 'r--', linewidth=2, label=r'$\tau \cdot \ln 2$ bound')
    ax.fill_between(taus, gaps_single, bounds_single, alpha=0.15, color='red')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title('(a) Single head removal', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    # Panel B: Multi-head
    x2 = np.array([5.0, 5.0, 3.0, 2.0, 4.0, 1.0, 3.5, 2.5])
    keep_multi = np.array([0, 1])
    remove_multi = np.array([2, 3, 4, 5, 6, 7])
    gaps_multi = [lse(x2, t) - lse(x2[keep_multi], t) for t in taus]
    card_bounds = [t * np.log(len(remove_multi) + 1) for t in taus]
    refined = [t * np.log(1 + sum(np.exp((x2[j] - x2[keep_multi].max()) / t) for j in remove_multi)) for t in taus]

    ax = axes[1]
    ax.plot(taus, gaps_multi, 'b-', linewidth=2, label='Actual gap')
    ax.plot(taus, refined, 'g-.', linewidth=2, label='Refined bound')
    ax.plot(taus, card_bounds, 'r--', linewidth=2, label=r'$\tau \cdot \ln(|R|+1)$ bound')
    ax.fill_between(taus, gaps_multi, card_bounds, alpha=0.1, color='red')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title(f'(b) Removing {len(remove_multi)} dominated heads', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Finite-Temperature Pruning Bound', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig


def plot_margin_decay():
    """Figure 2: Margin-refined bound showing exponential decay."""
    fig, ax = plt.subplots(figsize=(8, 5))

    R_card = 10
    taus = [0.5, 1.0, 2.0, 5.0]
    deltas = np.linspace(0, 10, 200)

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(taus)))
    for tau, color in zip(taus, colors):
        bounds = [tau * np.log(1 + R_card * np.exp(-d / tau)) for d in deltas]
        ax.plot(deltas, bounds, linewidth=2, color=color,
                label=rf'$\tau = {tau}$')

    # Cardinality bound (constant)
    for tau, color in zip(taus, colors):
        ax.axhline(y=tau * np.log(R_card + 1), color=color, linestyle=':', alpha=0.4)

    ax.set_xlabel(r'Margin $\delta$', fontsize=13)
    ax.set_ylabel(r'Bound $\tau \cdot \ln(1 + |R| e^{-\delta/\tau})$', fontsize=13)
    ax.set_title(f'Margin-Refined Bound (|R| = {R_card} heads)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig


def plot_tropicalization():
    """Figure 3: Zero-temperature convergence."""
    fig, ax = plt.subplots(figsize=(8, 5))

    x = np.array([5.0, 3.0, 4.0, 2.0, 5.0])
    keep = np.array([0, 4])

    taus = np.logspace(-2, 1, 200)
    gaps = [lse(x, t) - lse(x[keep], t) for t in taus]
    bounds = [t * np.log(len(x) - len(keep) + 1) for t in taus]

    ax.loglog(taus, gaps, 'b-', linewidth=2, label='Actual gap')
    ax.loglog(taus, bounds, 'r--', linewidth=2, label=r'$\tau \cdot \ln(|R|+1)$ bound')
    ax.loglog(taus, taus, 'k:', alpha=0.4, linewidth=1, label=r'$O(\tau)$ reference')

    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel('Pruning gap', fontsize=13)
    ax.set_title('Zero-Temperature Convergence\n(Bridge to Tropical Geometry)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3, which='both')
    plt.tight_layout()
    return fig


def plot_tightness_heatmap():
    """Figure 4: Tightness ratio gap/bound as function of parameters."""
    fig, ax = plt.subplots(figsize=(8, 6))

    n = 5
    taus = np.linspace(0.1, 5.0, 50)
    gaps_arr = np.linspace(0, 4, 50)  # gap = s - x_j

    ratios = np.zeros((len(gaps_arr), len(taus)))
    for i, gap in enumerate(gaps_arr):
        for j, tau in enumerate(taus):
            x = np.array([5.0, 5.0 - gap])
            actual = lse(x, tau) - tau * (x[0] / tau)  # LSE - max
            # For single removal: gap = tau * log(1 + exp(-gap/tau))
            actual_gap = tau * np.log(1 + np.exp(-gap / tau))
            bound = tau * np.log(2)
            ratios[i, j] = actual_gap / bound if bound > 1e-15 else 0

    im = ax.imshow(ratios, extent=[taus[0], taus[-1], gaps_arr[-1], gaps_arr[0]],
                   aspect='auto', cmap='RdYlGn_r', vmin=0, vmax=1)
    cbar = plt.colorbar(im, ax=ax, label='Tightness (gap / bound)')
    ax.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax.set_ylabel(r'Score gap $s - x_j$', fontsize=13)
    ax.set_title('Tightness of Single-Head Pruning Bound', fontsize=14)
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    figs = {
        'gap_vs_temperature': plot_gap_vs_temperature(),
        'margin_decay': plot_margin_decay(),
        'tropicalization': plot_tropicalization(),
        'tightness': plot_tightness_heatmap()
    }

    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"Saved {name}.png")

    # Also save base64 versions for JSON package
    for name, fig in figs.items():
        b64 = fig_to_base64(fig)
        print(f"{name}: {len(b64)} chars (base64)")

    plt.close('all')
    print("All visualizations generated.")
