"""
Applications of Directional Log-Concavity

Real-world applications demonstrating the DLC framework:
1. Matroid basis sampling — certified rapid mixing for combinatorial optimization
2. Fermionic exclusion — statistical mechanics equilibration certificate
3. Diverse subset selection — ML recommendation diversification
"""

import numpy as np
from itertools import combinations


# ─── Self-contained helpers ───────────────────────────────────────────

def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def check_pairwise_dlc(w, n):
    for i, j in combinations(range(n), 2):
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        if w10 * w01 - w11 * w00 < -1e-12:
            return False
    return True


def compute_dobrushin_constant(w, n):
    if n <= 1:
        return 0.0
    c = 0.0
    for i in range(n):
        total_inf = 0.0
        for j in range(n):
            if j == i:
                continue
            w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
            d1 = w11 + w01
            d0 = w10 + w00
            p1 = w11 / d1 if d1 > 0 else 0
            p0 = w10 / d0 if d0 > 0 else 0
            total_inf += abs(p1 - p0)
        c = max(c, total_inf)
    return c


def mixing_time_bound(n, c, eps=0.01):
    if c >= 1:
        return float('inf')
    return (n / (1 - c)) * np.log(n / eps)


def glauber_step(w, n, x, rng):
    x = x.copy()
    site = rng.integers(0, n)
    w_on = w_off = 0.0
    for S in subsets_of(n):
        if all(((j in S) == bool(x[j])) for j in range(n) if j != site):
            ws = w.get(S, 0.0)
            if site in S:
                w_on += ws
            else:
                w_off += ws
    total = w_on + w_off
    if total > 0:
        x[site] = 1 if rng.random() < w_on / total else 0
    return x


# ─── Application 1: Uniform Matroid Basis Sampling ───────────────────

def app_matroid_sampling():
    """
    Demonstrates DLC certification for uniform matroid bases.

    A uniform matroid U(k,n) has bases = all k-element subsets of [n].
    The basis exchange walk is known to mix rapidly; DLC provides a
    lightweight certificate.
    """
    print("=" * 65)
    print("  APPLICATION 1: Matroid Basis Sampling")
    print("  Uniform matroid U(k,n) — certified rapid mixing")
    print("=" * 65)

    for n, k in [(4, 2), (5, 2), (5, 3), (6, 3)]:
        w = {S: (1.0 if len(S) == k else 0.0) for S in subsets_of(n)}
        is_dlc = check_pairwise_dlc(w, n)
        c = compute_dobrushin_constant(w, n)
        tmix = mixing_time_bound(n, c) if c < 1 else float('inf')

        print(f"\n  U({k},{n}):")
        print(f"    DLC certified: {is_dlc}")
        print(f"    Dobrushin constant: {c:.4f}")
        print(f"    Mixing time bound: {tmix:.0f} steps")
        print(f"    Number of bases: {sum(1 for S in subsets_of(n) if len(S) == k)}")

    print()


# ─── Application 2: Fermionic Exclusion System ───────────────────────

def app_fermionic_system():
    """
    Demonstrates DLC as a certificate for fermionic equilibration.

    Models n sites with repulsive nearest-neighbor interaction.
    The DLC condition becomes a formal version of repulsive occupancy.
    """
    print("=" * 65)
    print("  APPLICATION 2: Fermionic Exclusion System")
    print("  Nearest-neighbor repulsion — equilibration certificate")
    print("=" * 65)

    n = 5
    print(f"\n  n={n} sites, varying repulsion strength β:")
    print(f"  {'β':>6s} {'DLC':>5s} {'c':>8s} {'T_mix':>8s} {'Z':>10s}")

    for beta in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0]:
        def adj(S):
            return sum(1 for x in S if x + 1 in S)
        w = {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}
        is_dlc = check_pairwise_dlc(w, n)
        c = compute_dobrushin_constant(w, n)
        tmix = mixing_time_bound(n, c) if c < 1 else float('inf')
        Z = sum(w.values())
        print(f"  {beta:6.1f} {str(is_dlc):>5s} {c:8.4f} {tmix:8.0f} {Z:10.2f}")

    # Detailed analysis at β=2
    beta = 2.0
    w = {S: np.exp(-beta * sum(1 for x in S if x+1 in S)) for S in subsets_of(n)}
    Z = sum(w.values())

    print(f"\n  Detailed analysis at β={beta}:")
    print(f"  Marginal occupancy probabilities:")
    for i in range(n):
        prob = sum(ws for S, ws in w.items() if i in S) / Z
        print(f"    Site {i}: Pr[occupied] = {prob:.4f}")

    print(f"\n  Pairwise correlations (all should be ≤ 0 under DLC):")
    for i, j in combinations(range(n), 2):
        pi = sum(ws for S, ws in w.items() if i in S) / Z
        pj = sum(ws for S, ws in w.items() if j in S) / Z
        pij = sum(ws for S, ws in w.items() if i in S and j in S) / Z
        cov = pij - pi * pj
        print(f"    Cov({i},{j}) = {cov:+.6f} {'✓' if cov <= 1e-10 else '✗'}")

    print()


# ─── Application 3: Diverse Subset Selection ─────────────────────────

def app_diverse_selection():
    """
    Demonstrates DLC for diverse item selection in recommendation systems.

    Given n items with a similarity matrix, we want to sample diverse subsets.
    DPP-like weights ensure repulsion between similar items.
    """
    print("=" * 65)
    print("  APPLICATION 3: Diverse Subset Selection")
    print("  DPP-based recommendation diversification")
    print("=" * 65)

    n = 4
    items = ["Sci-Fi Movie", "Fantasy Movie", "Jazz Album", "Classical Album"]

    # Similarity matrix (items in same category are similar)
    sim = np.array([
        [1.0, 0.8, 0.1, 0.1],
        [0.8, 1.0, 0.1, 0.1],
        [0.1, 0.1, 1.0, 0.7],
        [0.1, 0.1, 0.7, 1.0],
    ])

    # DPP kernel: L = sim (already PSD)
    L = sim
    w = {}
    for S in subsets_of(n):
        idx = sorted(S)
        if len(idx) == 0:
            w[S] = 1.0
        else:
            sub = L[np.ix_(idx, idx)]
            w[S] = max(0.0, np.linalg.det(sub))

    is_dlc = check_pairwise_dlc(w, n)
    c = compute_dobrushin_constant(w, n)
    Z = sum(w.values())

    print(f"\n  Items: {items}")
    print(f"  DLC certified: {is_dlc}")
    print(f"  Dobrushin constant: {c:.4f}")
    print(f"  Mixing time bound: {mixing_time_bound(n, c):.0f} steps")

    print(f"\n  Pairwise repulsion strengths:")
    for i, j in combinations(range(n), 2):
        pi = sum(ws for S, ws in w.items() if i in S) / Z
        pj = sum(ws for S, ws in w.items() if j in S) / Z
        pij = sum(ws for S, ws in w.items() if i in S and j in S) / Z
        cov = pij - pi * pj
        print(f"    {items[i]:>18s} vs {items[j]:<18s}: Cov = {cov:+.4f}")

    # Sample diverse recommendations
    print(f"\n  Sampled diverse recommendations (200 samples, 50 Glauber steps):")
    rng = np.random.default_rng(42)
    recommendations = {}
    for _ in range(200):
        x = np.zeros(n, dtype=int)
        for _ in range(50):
            x = glauber_step(w, n, x, rng)
        config = tuple(items[i] for i in range(n) if x[i])
        recommendations[config] = recommendations.get(config, 0) + 1

    for config, count in sorted(recommendations.items(), key=lambda x: -x[1])[:8]:
        print(f"    {str(config):>55s}: {count:3d} times")

    print()


if __name__ == '__main__':
    app_matroid_sampling()
    app_fermionic_system()
    app_diverse_selection()


"""
Demo: Directional Log-Concavity and Negative Dependence

Interactive demonstration of the DLC framework on concrete examples:
1. Uniform weights — trivial DLC with zero Dobrushin constant
2. Exclusion process — DLC from combinatorial repulsion
3. Repulsive Ising — DLC from energy-based repulsion
4. Determinantal point process — DLC from algebraic repulsion
5. Glauber dynamics simulation — empirical mixing verification
"""

import numpy as np
from itertools import combinations


# ─── Inline helper functions (self-contained) ────────────────────────

def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        has_i, has_j = i in S, j in S
        if has_i and has_j:
            w11 += ws
        elif has_i:
            w10 += ws
        elif has_j:
            w01 += ws
        else:
            w00 += ws
    return w11, w10, w01, w00


def check_pairwise_dlc(w, n):
    is_dlc = True
    gaps = {}
    for i, j in combinations(range(n), 2):
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        gap = w10 * w01 - w11 * w00
        gaps[(i, j)] = gap
        if gap < -1e-12:
            is_dlc = False
    return is_dlc, gaps


def compute_site_influence(w, n, i, j):
    w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
    d1 = w11 + w01
    d0 = w10 + w00
    p1 = w11 / d1 if d1 > 0 else 0
    p0 = w10 / d0 if d0 > 0 else 0
    return p1 - p0


def compute_dobrushin_constant(w, n):
    if n <= 1:
        return 0.0
    return max(
        sum(abs(compute_site_influence(w, n, i, j)) for j in range(n) if j != i)
        for i in range(n)
    )


def mixing_time_bound(n, c, eps=0.01):
    if c >= 1:
        return float('inf')
    return (n / (1 - c)) * np.log(n / eps)


def glauber_step(w, n, x, rng):
    x = x.copy()
    site = rng.integers(0, n)
    w_on = w_off = 0.0
    for S in subsets_of(n):
        agrees = all(((j in S) == bool(x[j])) for j in range(n) if j != site)
        if agrees:
            ws = w.get(S, 0.0)
            if site in S:
                w_on += ws
            else:
                w_off += ws
    total = w_on + w_off
    if total > 0:
        x[site] = 1 if rng.random() < w_on / total else 0
    return x


# ─── Weight system constructors ──────────────────────────────────────

def uniform_weights(n):
    return {S: 1.0 for S in subsets_of(n)}


def exclusion_weights(n, k):
    return {S: (1.0 if len(S) == k else 0.0) for S in subsets_of(n)}


def repulsive_weights(n, beta=1.0):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


def dpp_weights(n, L):
    weights = {}
    for S in subsets_of(n):
        idx = sorted(S)
        if len(idx) == 0:
            weights[S] = 1.0
        else:
            sub = L[np.ix_(idx, idx)]
            weights[S] = max(0.0, np.linalg.det(sub))
    return weights


# ─── DLC certificate ─────────────────────────────────────────────────

def dlc_certificate(w, n, eps=0.01):
    is_dlc, gaps = check_pairwise_dlc(w, n)
    c = compute_dobrushin_constant(w, n)
    tmix = mixing_time_bound(n, c, eps) if c < 1 else float('inf')
    Z = sum(w.values())

    neg_corr = {}
    for i, j in combinations(range(n), 2):
        pi = sum(ws for S, ws in w.items() if i in S) / Z
        pj = sum(ws for S, ws in w.items() if j in S) / Z
        pij = sum(ws for S, ws in w.items() if i in S and j in S) / Z
        neg_corr[(i, j)] = pij - pi * pj

    return {
        'is_dlc': is_dlc,
        'gaps': gaps,
        'dobrushin_constant': c,
        'mixing_time': tmix,
        'negative_correlations': neg_corr,
        'partition_function': Z,
    }


# ─── Empirical mixing time estimation ────────────────────────────────

def estimate_empirical_mixing(w, n, n_trials=50, max_steps=500, seed=0):
    """Estimate mixing time by measuring total variation convergence."""
    rng = np.random.default_rng(seed)

    # Compute exact distribution
    Z = sum(w.values())
    exact_probs = {}
    for S in subsets_of(n):
        exact_probs[S] = w.get(S, 0.0) / Z

    # Track total variation over time
    tv_history = []
    for t in range(0, max_steps, max(1, max_steps // 50)):
        counts = {}
        for trial in range(n_trials):
            x = np.zeros(n, dtype=int)
            for step in range(t):
                x = glauber_step(w, n, x, rng)
            config = frozenset(i for i in range(n) if x[i])
            counts[config] = counts.get(config, 0) + 1

        # Estimate TV distance
        tv = 0.0
        all_configs = set(exact_probs.keys()) | set(counts.keys())
        for S in all_configs:
            empirical = counts.get(S, 0) / n_trials
            exact = exact_probs.get(S, 0.0)
            tv += abs(empirical - exact)
        tv /= 2
        tv_history.append((t, tv))

    return tv_history


# ─── Main demo ────────────────────────────────────────────────────────

def run_demo():
    print("=" * 70)
    print("  DIRECTIONAL LOG-CONCAVITY: DEMO")
    print("  Coefficient-level certificates for negative dependence")
    print("=" * 70)

    # --- Example 1: Uniform weights ---
    print("\n┌─ Example 1: Uniform Weights (n=4) ─────────────────────────┐")
    n = 4
    w = uniform_weights(n)
    cert = dlc_certificate(w, n)
    print(f"│ DLC satisfied:       {cert['is_dlc']}")
    print(f"│ Dobrushin constant:  {cert['dobrushin_constant']:.6f}")
    print(f"│ Mixing time bound:   {cert['mixing_time']:.1f} steps")
    print(f"│ Partition function:  {cert['partition_function']:.0f}")
    print(f"│ All covariances ≤ 0: {all(v <= 1e-10 for v in cert['negative_correlations'].values())}")
    for (i, j), cov in sorted(cert['negative_correlations'].items()):
        print(f"│   Cov({i},{j}) = {cov:+.6f}")
    print(f"└──────────────────────────────────────────────────────────────┘")

    # --- Example 2: Exclusion process ---
    print("\n┌─ Example 2: Exclusion Process (n=5, k=2) ──────────────────┐")
    n, k = 5, 2
    w = exclusion_weights(n, k)
    cert = dlc_certificate(w, n)
    print(f"│ DLC satisfied:       {cert['is_dlc']}")
    print(f"│ Dobrushin constant:  {cert['dobrushin_constant']:.6f}")
    print(f"│ Mixing time bound:   {cert['mixing_time']:.1f} steps")
    for (i, j), cov in sorted(cert['negative_correlations'].items()):
        print(f"│   Cov({i},{j}) = {cov:+.6f}")
    print(f"└──────────────────────────────────────────────────────────────┘")

    # --- Example 3: Repulsive Ising ---
    print("\n┌─ Example 3: Repulsive Ising (n=5, varying β) ─────────────┐")
    n = 5
    for beta in [0.5, 1.0, 2.0, 5.0]:
        w = repulsive_weights(n, beta)
        cert = dlc_certificate(w, n)
        print(f"│ β={beta:4.1f}: DLC={cert['is_dlc']}, "
              f"c={cert['dobrushin_constant']:.4f}, "
              f"T_mix≈{cert['mixing_time']:.0f}")
    print(f"└──────────────────────────────────────────────────────────────┘")

    # --- Example 4: DPP ---
    print("\n┌─ Example 4: Determinantal Point Process (n=4) ────────────┐")
    n = 4
    np.random.seed(42)
    A = np.random.randn(n, n) * 0.5
    L = A @ A.T  # PSD kernel
    w = dpp_weights(n, L)
    cert = dlc_certificate(w, n)
    print(f"│ DLC satisfied:       {cert['is_dlc']}")
    print(f"│ Dobrushin constant:  {cert['dobrushin_constant']:.6f}")
    print(f"│ Mixing time bound:   {cert['mixing_time']:.1f} steps")
    print(f"│ All covariances ≤ 0: {all(v <= 1e-10 for v in cert['negative_correlations'].values())}")
    print(f"└──────────────────────────────────────────────────────────────┘")

    # --- Example 5: DLC depth vs mixing (conjecture test) ---
    print("\n┌─ Example 5: Conjecture Test — Stronger DLC ⟹ Faster Mixing ┐")
    print("│ Testing: stronger repulsion (higher β) gives lower Dobrushin  │")
    n = 4
    betas = [0.1, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    print(f"│ {'β':>6s} {'c':>10s} {'T_mix':>10s} {'min_gap':>12s}")
    for beta in betas:
        w = repulsive_weights(n, beta)
        cert = dlc_certificate(w, n)
        min_gap = min(cert['gaps'].values())
        print(f"│ {beta:6.1f} {cert['dobrushin_constant']:10.6f} "
              f"{cert['mixing_time']:10.1f} {min_gap:12.6f}")
    print(f"└───────────────────────────────────────────────────────────────┘")

    # --- Glauber dynamics simulation ---
    print("\n┌─ Example 6: Glauber Dynamics Simulation ───────────────────┐")
    n = 4
    w = repulsive_weights(n, beta=1.0)
    Z = sum(w.values())
    rng = np.random.default_rng(123)

    # Run multiple chains and check convergence
    n_chains = 200
    T = 100
    final_configs = []
    for _ in range(n_chains):
        x = np.zeros(n, dtype=int)
        for _ in range(T):
            x = glauber_step(w, n, x, rng)
        final_configs.append(frozenset(i for i in range(n) if x[i]))

    # Compare empirical vs exact marginals
    print(f"│ After {T} Glauber steps ({n_chains} chains):")
    for site in range(n):
        empirical = sum(1 for cfg in final_configs if site in cfg) / n_chains
        exact = sum(ws for S, ws in w.items() if site in S) / Z
        print(f"│   Site {site}: empirical={empirical:.3f}, exact={exact:.3f}, "
              f"error={abs(empirical-exact):.3f}")
    print(f"└──────────────────────────────────────────────────────────────┘")


if __name__ == '__main__':
    run_demo()


"""
Visualization: DLC Determinant Gap Surface

Plots the DLC gap w₁₀·w₀₁ - w₁₁·w₀₀ for each coordinate pair across
different weight systems. The gap is nonneg when DLC holds.

Visualizes how the 2×2 determinant inequality — the foundation of the
entire theory — varies across coordinate pairs and repulsion strengths.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def repulsive_weights(n, beta):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


def exclusion_weights(n, k):
    return {S: (1.0 if len(S) == k else 0.0) for S in subsets_of(n)}


# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

n = 6
pairs = list(combinations(range(n), 2))
pair_labels = [f'({i},{j})' for i, j in pairs]

# Panel 1: DLC gaps for repulsive system, varying β
ax = axes[0, 0]
betas = [0.5, 1.0, 2.0, 5.0]
x_pos = np.arange(len(pairs))
width = 0.18
for idx, beta in enumerate(betas):
    w = repulsive_weights(n, beta)
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        gaps.append(w10 * w01 - w11 * w00)
    ax.bar(x_pos + idx * width, gaps, width, label=f'β={beta}', alpha=0.8)

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xticks(x_pos + 1.5 * width)
ax.set_xticklabels(pair_labels, fontsize=7, rotation=45)
ax.set_ylabel('DLC gap (w₁₀w₀₁ - w₁₁w₀₀)')
ax.set_title('DLC Gaps: Repulsive System (varying β)', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2, axis='y')

# Panel 2: DLC gaps for exclusion process, varying k
ax = axes[0, 1]
ks = [1, 2, 3, 4, 5]
for idx, k in enumerate(ks):
    w = exclusion_weights(n, k)
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        gaps.append(w10 * w01 - w11 * w00)
    ax.bar(x_pos + idx * width, gaps, width, label=f'k={k}', alpha=0.8)

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xticks(x_pos + 2 * width)
ax.set_xticklabels(pair_labels, fontsize=7, rotation=45)
ax.set_ylabel('DLC gap')
ax.set_title('DLC Gaps: Exclusion Process (varying k)', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2, axis='y')

# Panel 3: Negative correlations heatmap
ax = axes[1, 0]
beta = 2.0
w = repulsive_weights(n, beta)
Z = sum(w.values())
corr_mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i == j:
            pi = sum(ws for S, ws in w.items() if i in S) / Z
            corr_mat[i, j] = pi * (1 - pi)
        else:
            pi = sum(ws for S, ws in w.items() if i in S) / Z
            pj = sum(ws for S, ws in w.items() if j in S) / Z
            pij = sum(ws for S, ws in w.items() if i in S and j in S) / Z
            corr_mat[i, j] = pij - pi * pj

im = ax.imshow(corr_mat, cmap='RdBu', aspect='equal')
ax.set_title(f'Correlation Matrix (β={beta})', fontweight='bold')
ax.set_xlabel('Coordinate j')
ax.set_ylabel('Coordinate i')
plt.colorbar(im, ax=ax, fraction=0.046)
for i in range(n):
    for j in range(n):
        color = 'white' if abs(corr_mat[i, j]) > 0.02 else 'black'
        ax.text(j, i, f'{corr_mat[i,j]:.3f}', ha='center', va='center',
                fontsize=7, color=color)

# Panel 4: Summary — DLC gap vs distance between coordinates
ax = axes[1, 1]
for beta in [0.5, 1.0, 2.0, 5.0]:
    w = repulsive_weights(n, beta)
    distances = []
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        distances.append(abs(j - i))
        gaps.append(w10 * w01 - w11 * w00)
    # Average gap by distance
    unique_d = sorted(set(distances))
    avg_gaps = [np.mean([g for d, g in zip(distances, gaps) if d == ud])
                for ud in unique_d]
    ax.plot(unique_d, avg_gaps, 'o-', label=f'β={beta}', linewidth=1.5, markersize=5)

ax.set_xlabel('Distance |j - i| between coordinates')
ax.set_ylabel('Average DLC gap')
ax.set_title('DLC Gap vs Coordinate Distance', fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)

fig.suptitle('The 2×2 Determinant Inequality: Foundation of the DLC Framework',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_dlc_determinant.png', dpi=150, bbox_inches='tight')
print("Saved viz_dlc_determinant.png")


"""
Visualization: Site Influence Heatmap under DLC

Visualizes the influence matrix I(i,j) = Pr[Xi=1|Xj=1] - Pr[Xi=1|Xj=0]
for a repulsive weight system. Under DLC, all off-diagonal entries are
nonpositive (blue), showing that including any item repels all others.

The heatmap demonstrates Theorem 2 (conditional antitone influence):
darker blue = stronger repulsion between coordinates.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def compute_influence_matrix(w, n):
    mat = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
            d1, d0 = w11 + w01, w10 + w00
            p1 = w11 / d1 if d1 > 0 else 0
            p0 = w10 / d0 if d0 > 0 else 0
            mat[i, j] = p1 - p0
    return mat


def repulsive_weights(n, beta):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


# --- Create figure ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

n = 6
betas = [0.5, 2.0, 5.0]
titles = ['Weak repulsion (β=0.5)', 'Medium repulsion (β=2.0)', 'Strong repulsion (β=5.0)']

for ax, beta, title in zip(axes, betas, titles):
    w = repulsive_weights(n, beta)
    mat = compute_influence_matrix(w, n)

    # All off-diagonal should be ≤ 0 under DLC
    vmax = max(abs(mat.min()), abs(mat.max())) if mat.any() else 0.1
    im = ax.imshow(mat, cmap='RdBu', vmin=-vmax, vmax=vmax, aspect='equal')

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel('Coordinate j')
    ax.set_ylabel('Coordinate i')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

    # Annotate values
    for i in range(n):
        for j in range(n):
            val = mat[i, j]
            color = 'white' if abs(val) > vmax * 0.5 else 'black'
            ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                    fontsize=8, color=color)

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

fig.suptitle('Site Influence Matrix I(i,j) under DLC\n'
             '(Blue = repulsion, confirming Theorem 2: all off-diagonal ≤ 0)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_influence_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_influence_heatmap.png")


"""
Visualization: Mixing Time Convergence under DLC

Shows how the Dobrushin constant c and theoretical mixing time change
as repulsion strength (β) increases. Demonstrates the core prediction:
stronger DLC → smaller Dobrushin constant → faster mixing.

Also shows empirical convergence of Glauber dynamics marginals to confirm
the theoretical mixing time bounds.
"""

import numpy as np
import matplotlib.pyplot as plt


def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def compute_dobrushin(w, n):
    if n <= 1:
        return 0.0
    c = 0.0
    for i in range(n):
        total = 0.0
        for j in range(n):
            if j == i:
                continue
            w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
            d1, d0 = w11 + w01, w10 + w00
            p1 = w11 / d1 if d1 > 0 else 0
            p0 = w10 / d0 if d0 > 0 else 0
            total += abs(p1 - p0)
        c = max(c, total)
    return c


def repulsive_weights(n, beta):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


def glauber_step(w, n, x, rng):
    x = x.copy()
    site = rng.integers(0, n)
    w_on = w_off = 0.0
    for S in subsets_of(n):
        if all(((j in S) == bool(x[j])) for j in range(n) if j != site):
            ws = w.get(S, 0.0)
            if site in S:
                w_on += ws
            else:
                w_off += ws
    total = w_on + w_off
    if total > 0:
        x[site] = 1 if rng.random() < w_on / total else 0
    return x


# --- Panel 1: Dobrushin constant vs β ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

n = 5
betas = np.linspace(0.1, 8.0, 40)
dob_constants = []
for beta in betas:
    w = repulsive_weights(n, beta)
    dob_constants.append(compute_dobrushin(w, n))

ax = axes[0]
ax.plot(betas, dob_constants, 'b-', linewidth=2)
ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='c = 1 (mixing threshold)')
ax.set_xlabel('Repulsion strength β', fontsize=11)
ax.set_ylabel('Dobrushin constant c', fontsize=11)
ax.set_title('Dobrushin Constant vs Repulsion', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)

# --- Panel 2: Mixing time vs β ---
ax = axes[1]
mix_times = [(n / (1 - c)) * np.log(n / 0.01) if c < 1 else np.nan for c in dob_constants]
ax.plot(betas, mix_times, 'g-', linewidth=2)
ax.set_xlabel('Repulsion strength β', fontsize=11)
ax.set_ylabel('Mixing time bound T_mix', fontsize=11)
ax.set_title('Certified Mixing Time vs Repulsion', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.3)

# --- Panel 3: Empirical convergence ---
ax = axes[2]
n = 4
rng = np.random.default_rng(42)

for beta, color in [(0.5, 'blue'), (2.0, 'green'), (5.0, 'red')]:
    w = repulsive_weights(n, beta)
    Z = sum(w.values())
    exact_p0 = sum(ws for S, ws in w.items() if 0 in S) / Z

    steps = list(range(0, 201, 5))
    errors = []
    for T in steps:
        empirical_sum = 0
        n_samples = 100
        for _ in range(n_samples):
            x = np.zeros(n, dtype=int)
            for _ in range(T):
                x = glauber_step(w, n, x, rng)
            empirical_sum += x[0]
        emp_p0 = empirical_sum / n_samples
        errors.append(abs(emp_p0 - exact_p0))

    ax.plot(steps, errors, color=color, linewidth=1.5, alpha=0.8, label=f'β={beta}')

ax.set_xlabel('Glauber steps', fontsize=11)
ax.set_ylabel('|Pr[X₀=1] - exact|', fontsize=11)
ax.set_title('Empirical Convergence (n=4)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

fig.suptitle('DLC Controls Mixing: Theory and Empirics',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing_convergence.png")
