#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Spectral-Tropical Entropy Bridge

Demonstrates how the certified entropy bounds can be applied to:
1. Network analysis — detecting graph irregularity
2. Community structure — entropy as a regularity probe
3. Random graph models — comparing entropy profiles
4. Architecture analysis — graph-based circuit/network design
"""

import numpy as np
import random

random.seed(42)
np.random.seed(42)


# ============================================================
# Core functions (self-contained)
# ============================================================

def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)

def graph_volume(degrees):
    return float(degrees.sum())

def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol

def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h

def max_degree(degrees):
    return int(degrees.max())

def average_degree(degrees):
    return float(degrees.mean())

def regularity_deficit(degrees):
    n = len(degrees)
    return np.log(n) - shannon_entropy(degrees)

def entropy_lower_bound(degrees):
    n = len(degrees)
    d_bar = average_degree(degrees)
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return np.log(n * d_bar / delta)

def spectral_radius(adj):
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())

def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


# ============================================================
# Application 1: Network Irregularity Detection
# ============================================================

def network_irregularity_score(adj):
    """Compute an irregularity score for a network using the regularity deficit.

    The regularity deficit D(G) = log|V| - H(G) is a certified measure of
    how far a network is from being regular. By our verified theorem:
        D(G) ≤ log(Δ/d̄)

    This provides a normalized irregularity score in [0, 1]:
        score = D(G) / log(Δ/d̄)

    A score near 0 means nearly regular; near 1 means maximally irregular
    relative to the degree spread.

    Returns:
        (score, deficit, upper_bound)
    """
    degrees = degree_sequence(adj)
    D = regularity_deficit(degrees)
    d_bar = average_degree(degrees)
    delta = max_degree(degrees)
    if d_bar <= 0 or delta <= 0 or delta == d_bar:
        return 0.0, D, 0.0
    ub = np.log(delta / d_bar)
    score = D / ub if ub > 0 else 0.0
    return min(score, 1.0), D, ub


def demo_network_irregularity():
    """Demonstrate network irregularity detection on various topologies."""
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Network Irregularity Detection")
    print("=" * 60)

    # Scale-free-like network (preferential attachment)
    n = 50
    adj_pref = np.zeros((n, n), dtype=int)
    for i in range(1, n):
        # Connect to existing vertices with probability proportional to degree + 1
        degrees = adj_pref[:i].sum(axis=1) + 1
        probs = degrees / degrees.sum()
        targets = np.random.choice(i, size=min(2, i), replace=False, p=probs)
        for t in targets:
            adj_pref[i][t] = adj_pref[t][i] = 1

    # Regular-ish network (Erdős–Rényi dense)
    adj_er = generate_erdos_renyi(n, 0.5)

    # Hub-and-spoke
    adj_hub = np.zeros((n, n), dtype=int)
    # 5 hubs connected to all others
    for hub in range(5):
        for i in range(5, n):
            adj_hub[hub][i] = adj_hub[i][hub] = 1

    networks = [
        ("Preferential Attachment", adj_pref),
        ("Erdős–Rényi G(50,0.5)", adj_er),
        ("Hub-and-Spoke (5 hubs)", adj_hub),
    ]

    for name, adj in networks:
        score, D, ub = network_irregularity_score(adj)
        degrees = degree_sequence(adj)
        print(f"\n  {name}:")
        print(f"    Degrees: min={degrees.min()}, max={degrees.max()}, avg={degrees.mean():.1f}")
        print(f"    Regularity deficit D(G) = {D:.4f}")
        print(f"    Upper bound log(Δ/d̄)   = {ub:.4f}")
        print(f"    Irregularity score      = {score:.4f}")


# ============================================================
# Application 2: Entropy-Based Community Detection Probe
# ============================================================

def entropy_community_probe(adj, partition):
    """Use entropy to assess how well a partition captures community structure.

    For each community in the partition, compute:
    - Internal entropy (within-community degree entropy)
    - The regularity deficit (how far from regular)

    Regular communities have D ≈ 0; irregular ones signal structural heterogeneity.
    """
    results = []
    for comm_idx, community in enumerate(partition):
        if len(community) < 2:
            continue
        # Extract subgraph
        sub_adj = adj[np.ix_(community, community)]
        degrees = degree_sequence(sub_adj)
        if graph_volume(degrees) == 0:
            continue
        H = shannon_entropy(degrees)
        D = regularity_deficit(degrees)
        lb = entropy_lower_bound(degrees)
        results.append({
            'community': comm_idx,
            'size': len(community),
            'entropy': H,
            'log_n': np.log(len(community)),
            'deficit': D,
            'lower_bound': lb,
        })
    return results


def demo_community_probe():
    """Demonstrate entropy-based community structure analysis."""
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Entropy-Based Community Probe")
    print("=" * 60)

    # Create a planted partition graph
    n_per = 20
    n = 3 * n_per
    adj = np.zeros((n, n), dtype=int)

    # Dense within communities, sparse between
    p_in, p_out = 0.7, 0.05
    for i in range(n):
        for j in range(i + 1, n):
            comm_i, comm_j = i // n_per, j // n_per
            p = p_in if comm_i == comm_j else p_out
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1

    # True partition
    partition = [list(range(k * n_per, (k + 1) * n_per)) for k in range(3)]

    results = entropy_community_probe(adj, partition)
    for r in results:
        print(f"\n  Community {r['community']} (size {r['size']}):")
        print(f"    H(sub)     = {r['entropy']:.4f}")
        print(f"    log|V_sub| = {r['log_n']:.4f}")
        print(f"    D(sub)     = {r['deficit']:.4f}")
        print(f"    LB         = {r['lower_bound']:.4f}")
        print(f"    H ≥ LB?    = {'✓' if r['entropy'] >= r['lower_bound'] - 1e-10 else '✗'}")


# ============================================================
# Application 3: Random Graph Model Comparison
# ============================================================

def demo_random_model_comparison():
    """Compare entropy profiles across random graph models."""
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Random Graph Model Comparison")
    print("=" * 60)

    n = 40
    n_trials = 100

    models = {
        'ER(0.1)': lambda: generate_erdos_renyi(n, 0.1),
        'ER(0.3)': lambda: generate_erdos_renyi(n, 0.3),
        'ER(0.5)': lambda: generate_erdos_renyi(n, 0.5),
    }

    for model_name, gen_fn in models.items():
        entropies = []
        deficits = []
        margins = []
        for _ in range(n_trials):
            adj = gen_fn()
            degrees = degree_sequence(adj)
            if graph_volume(degrees) == 0:
                continue
            H = shannon_entropy(degrees)
            D = regularity_deficit(degrees)
            lb = entropy_lower_bound(degrees)
            entropies.append(H)
            deficits.append(D)
            margins.append(H - lb)

        entropies = np.array(entropies)
        deficits = np.array(deficits)
        margins = np.array(margins)

        print(f"\n  Model: {model_name}")
        print(f"    Entropy:  mean={entropies.mean():.4f} ± {entropies.std():.4f}")
        print(f"    log(40) = {np.log(40):.4f}")
        print(f"    Deficit:  mean={deficits.mean():.4f} ± {deficits.std():.4f}")
        print(f"    Margin:   mean={margins.mean():.4f}, min={margins.min():.4f}")
        print(f"    All bounds hold: {'✓' if margins.min() >= -1e-10 else '✗'}")


# ============================================================
# Application 4: Design Quality Metric for Network Architectures
# ============================================================

def network_quality_metrics(adj):
    """Compute quality metrics for network architecture design.

    Uses the spectral-tropical entropy framework to assess:
    - Information capacity (entropy)
    - Structural balance (regularity deficit)
    - Spectral certificate quality (bound tightness)
    """
    degrees = degree_sequence(adj)
    n = len(degrees)
    if graph_volume(degrees) == 0:
        return None

    H = shannon_entropy(degrees)
    D = regularity_deficit(degrees)
    lb = entropy_lower_bound(degrees)
    lam1 = spectral_radius(adj)
    d_bar = average_degree(degrees)
    delta = max_degree(degrees)

    return {
        'entropy': H,
        'max_entropy': np.log(n),
        'efficiency': H / np.log(n) if n > 1 else 1.0,  # How close to max entropy
        'deficit': D,
        'spectral_radius': lam1,
        'spectral_gap': lam1 - d_bar,  # λ₁ - d̄
        'bound_margin': H - lb,
        'degree_ratio': delta / d_bar if d_bar > 0 else float('inf'),
    }


def demo_architecture_quality():
    """Compare network architectures using entropy quality metrics."""
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Network Architecture Quality")
    print("=" * 60)

    n = 30

    # Mesh (regular)
    adj_mesh = np.zeros((n, n), dtype=int)
    for i in range(n):
        for d in [1, 2, 3]:
            adj_mesh[i][(i + d) % n] = adj_mesh[(i + d) % n][i] = 1

    # Ring (sparse regular)
    adj_ring = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj_ring[i][(i + 1) % n] = adj_ring[(i + 1) % n][i] = 1

    # Random (dense ER)
    adj_rand = generate_erdos_renyi(n, 0.4)

    architectures = [
        ("6-regular mesh", adj_mesh),
        ("Ring (2-regular)", adj_ring),
        ("Random ER(30, 0.4)", adj_rand),
    ]

    for name, adj in architectures:
        metrics = network_quality_metrics(adj)
        if metrics is None:
            print(f"\n  {name}: No edges")
            continue
        print(f"\n  {name}:")
        print(f"    Entropy efficiency: {metrics['efficiency']:.4f} (1.0 = perfectly regular)")
        print(f"    Regularity deficit: {metrics['deficit']:.4f}")
        print(f"    Spectral gap λ₁-d̄: {metrics['spectral_gap']:.4f}")
        print(f"    Degree ratio Δ/d̄:  {metrics['degree_ratio']:.4f}")
        print(f"    Bound margin:       {metrics['bound_margin']:.4f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  SPECTRAL-TROPICAL ENTROPY: APPLICATIONS")
    print("=" * 60)

    demo_network_irregularity()
    demo_community_probe()
    demo_random_model_comparison()
    demo_architecture_quality()

    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral-Tropical Entropy Bridge: Interactive Demonstration

This script demonstrates the main theorems relating graph spectra,
Shannon entropy of degree distributions, and information-theoretic
measures of graph irregularity.

Key results tested:
  1. H(G) >= log(|V| * d_bar / Delta)   [Entropy lower bound]
  2. D(G) <= log(Delta / d_bar)          [Regularity deficit bound]
  3. H(G) = log|V| iff G is regular      [Entropy rigidity]
  4. D(G) = D_KL(p || uniform)           [KL divergence identity]
  5. Strong conjecture: H(G) >= log(|V| * lambda_1 / Delta)
"""

import numpy as np
from collections import Counter
import random

random.seed(42)
np.random.seed(42)


def generate_erdos_renyi(n, p):
    """Generate an Erdős–Rényi random graph G(n, p)."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = 1
                adj[j][i] = 1
    return adj


def generate_regular_graph(n, d):
    """Generate a d-regular graph on n vertices (approximately).
    Uses the pairing model with retry."""
    if n * d % 2 != 0:
        d = d - 1
    for _ in range(100):
        stubs = []
        for v in range(n):
            stubs.extend([v] * d)
        random.shuffle(stubs)
        adj = np.zeros((n, n), dtype=int)
        valid = True
        for i in range(0, len(stubs), 2):
            u, v = stubs[i], stubs[i + 1]
            if u == v or adj[u][v] == 1:
                valid = False
                break
            adj[u][v] = 1
            adj[v][u] = 1
        if valid:
            return adj
    # Fallback: cycle graph
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i][(i + 1) % n] = 1
        adj[(i + 1) % n][i] = 1
    return adj


def generate_star_graph(n):
    """Generate a star graph on n vertices (maximally irregular)."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(1, n):
        adj[0][i] = 1
        adj[i][0] = 1
    return adj


def degree_sequence(adj):
    """Compute degree sequence from adjacency matrix."""
    return adj.sum(axis=1)


def graph_vol(degrees):
    """Total volume: sum of degrees."""
    return float(degrees.sum())


def degree_prob(degrees):
    """Degree probability distribution."""
    v = graph_vol(degrees)
    if v == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / v


def degree_entropy(degrees):
    """Shannon entropy H(G) = -sum p_v log(p_v)."""
    p = degree_prob(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def max_degree(degrees):
    """Maximum degree Delta."""
    return int(degrees.max())


def avg_degree(degrees):
    """Average degree d_bar."""
    return float(degrees.mean())


def regularity_deficit(degrees):
    """Regularity deficit D(G) = log|V| - H(G)."""
    n = len(degrees)
    return np.log(n) - degree_entropy(degrees)


def kl_divergence_from_uniform(degrees):
    """KL divergence D_KL(p || uniform)."""
    n = len(degrees)
    p = degree_prob(degrees)
    u = 1.0 / n
    kl = 0.0
    for pv in p:
        if pv > 0:
            kl += pv * np.log(pv / u)
    return kl


def entropy_lower_bound_avg_max(degrees):
    """Lower bound: log(|V| * d_bar / Delta)."""
    n = len(degrees)
    d_bar = avg_degree(degrees)
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return np.log(n * d_bar / delta)


def spectral_radius(adj):
    """Largest eigenvalue of adjacency matrix."""
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


def entropy_lower_bound_spectral(degrees, lambda1):
    """Strong conjecture bound: log(|V| * lambda_1 / Delta)."""
    n = len(degrees)
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return np.log(n * lambda1 / delta)


def analyze_graph(name, adj):
    """Full analysis of a graph."""
    degrees = degree_sequence(adj)
    n = len(degrees)
    vol = graph_vol(degrees)
    d_bar = avg_degree(degrees)
    delta = max_degree(degrees)
    H = degree_entropy(degrees)
    D = regularity_deficit(degrees)
    KL = kl_divergence_from_uniform(degrees)
    lb_avg = entropy_lower_bound_avg_max(degrees)
    lam1 = spectral_radius(adj)
    lb_spec = entropy_lower_bound_spectral(degrees, lam1)

    print(f"\n{'=' * 60}")
    print(f"  Graph: {name}")
    print(f"{'=' * 60}")
    print(f"  |V| = {n},  |E| = {int(vol / 2)}")
    print(f"  Degree sequence: {sorted(degrees, reverse=True)[:10]}{'...' if n > 10 else ''}")
    print(f"  Delta (max deg)  = {delta}")
    print(f"  d_bar (avg deg)  = {d_bar:.4f}")
    print(f"  lambda_1 (spec)  = {lam1:.4f}")
    print(f"  vol(G)           = {vol:.0f}")
    print()
    print(f"  --- Information-Theoretic Measures ---")
    print(f"  H(G)             = {H:.6f}")
    print(f"  log|V|           = {np.log(n):.6f}")
    print(f"  D(G)             = {D:.6f}")
    print(f"  D_KL(p||u)       = {KL:.6f}")
    print(f"  |D(G) - D_KL|    = {abs(D - KL):.2e}  (should be ≈ 0)")
    print()
    print(f"  --- Bounds Verification ---")
    print(f"  Bound: log(|V|*d_bar/Delta) = {lb_avg:.6f}")
    print(f"  H(G) - bound               = {H - lb_avg:.6f}  (should be ≥ 0)")
    print(f"  Bound: log(Delta/d_bar)     = {np.log(delta / d_bar) if d_bar > 0 else float('inf'):.6f}")
    print(f"  D(G) - bound               = {D - np.log(delta / d_bar) if d_bar > 0 else 0:.6f}  (should be ≤ 0)")
    print()
    print(f"  --- Strong Spectral Conjecture ---")
    print(f"  Bound: log(|V|*lambda_1/Delta) = {lb_spec:.6f}")
    print(f"  H(G) - spectral bound          = {H - lb_spec:.6f}  {'✓' if H >= lb_spec - 1e-10 else '✗ COUNTEREXAMPLE!'}")

    return {
        'name': name, 'n': n, 'H': H, 'D': D, 'KL': KL,
        'delta': delta, 'd_bar': d_bar, 'lambda1': lam1,
        'lb_avg': lb_avg, 'lb_spec': lb_spec,
        'margin_avg': H - lb_avg, 'margin_spec': H - lb_spec
    }


def main():
    print("=" * 60)
    print("  SPECTRAL-TROPICAL ENTROPY BRIDGE")
    print("  Demonstration of Formally Verified Theorems")
    print("=" * 60)

    # --- Demo 1: Specific graph families ---
    print("\n\n" + "#" * 60)
    print("  PART 1: Canonical Graph Families")
    print("#" * 60)

    # Complete graph K_10 (regular)
    n = 10
    adj_complete = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    analyze_graph("K_10 (complete, 9-regular)", adj_complete)

    # Cycle graph C_10 (regular)
    adj_cycle = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj_cycle[i][(i + 1) % n] = 1
        adj_cycle[(i + 1) % n][i] = 1
    analyze_graph("C_10 (cycle, 2-regular)", adj_cycle)

    # Star graph S_10 (maximally irregular)
    adj_star = generate_star_graph(n)
    analyze_graph("S_10 (star, highly irregular)", adj_star)

    # Path graph P_10
    adj_path = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj_path[i][i + 1] = 1
        adj_path[i + 1][i] = 1
    analyze_graph("P_10 (path)", adj_path)

    # --- Demo 2: Random graph testing ---
    print("\n\n" + "#" * 60)
    print("  PART 2: Random Graph Testing (Strong Conjecture)")
    print("#" * 60)

    for p_val in [0.1, 0.3, 0.5]:
        print(f"\n--- G(50, {p_val}) ---")
        n_tests = 200
        margins_avg = []
        margins_spec = []
        counterexamples = 0

        for trial in range(n_tests):
            adj = generate_erdos_renyi(50, p_val)
            degrees = degree_sequence(adj)
            if graph_vol(degrees) == 0:
                continue
            H = degree_entropy(degrees)
            lb_avg = entropy_lower_bound_avg_max(degrees)
            lam1 = spectral_radius(adj)
            lb_spec = entropy_lower_bound_spectral(degrees, lam1)

            margins_avg.append(H - lb_avg)
            margins_spec.append(H - lb_spec)
            if H < lb_spec - 1e-10:
                counterexamples += 1

        margins_avg = np.array(margins_avg)
        margins_spec = np.array(margins_spec)

        print(f"  Tested {n_tests} graphs")
        print(f"  Avg-max bound margins:  mean={margins_avg.mean():.6f}, min={margins_avg.min():.6f}")
        print(f"  Spectral bound margins: mean={margins_spec.mean():.6f}, min={margins_spec.min():.6f}")
        print(f"  Strong conjecture counterexamples: {counterexamples}")
        print(f"  Strong conjecture holds: {'✓ YES' if counterexamples == 0 else '✗ NO'}")

    # --- Demo 3: Regularity and entropy ---
    print("\n\n" + "#" * 60)
    print("  PART 3: Entropy Rigidity (Regular ↔ Max Entropy)")
    print("#" * 60)

    for d in [3, 5, 8]:
        adj = generate_regular_graph(20, d)
        degrees = degree_sequence(adj)
        H = degree_entropy(degrees)
        log_n = np.log(20)
        is_regular = len(set(degrees)) == 1
        print(f"\n  {d}-regular graph on 20 vertices:")
        print(f"    Actually regular: {is_regular}")
        print(f"    H(G)    = {H:.6f}")
        print(f"    log|V|  = {log_n:.6f}")
        print(f"    |H - log|V|| = {abs(H - log_n):.2e}")

    # --- Demo 4: KL divergence identity ---
    print("\n\n" + "#" * 60)
    print("  PART 4: D(G) = D_KL(p || uniform)")
    print("#" * 60)

    for _ in range(5):
        adj = generate_erdos_renyi(30, 0.3)
        degrees = degree_sequence(adj)
        if graph_vol(degrees) == 0:
            continue
        D = regularity_deficit(degrees)
        KL = kl_divergence_from_uniform(degrees)
        print(f"  D(G) = {D:.10f},  D_KL = {KL:.10f},  |diff| = {abs(D - KL):.2e}")

    print("\n" + "=" * 60)
    print("  All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Entropy Landscape

Visualizes the degree entropy H(G) vs the certified lower bound log(|V|d̄/Δ)
across random graphs of varying density. Shows that the bound always holds
and is tight for near-regular graphs.

Key insight: The entropy floor rises as graphs become denser (more regular),
demonstrating that spectral regularity forces information-theoretic regularity.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees):
    return float(degrees.sum())


def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def entropy_lower_bound(degrees):
    n = len(degrees)
    d_bar = float(degrees.mean())
    delta = int(degrees.max())
    if delta == 0:
        return float('-inf')
    return np.log(n * d_bar / delta)


def spectral_radius(adj):
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


# Generate data
n = 40
p_values = np.linspace(0.05, 0.95, 50)
n_samples = 30

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Entropy vs Lower Bound scatter
all_H = []
all_LB = []
all_p = []

for p_val in p_values:
    for _ in range(n_samples):
        adj = generate_erdos_renyi(n, p_val)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue
        H = shannon_entropy(degrees)
        lb = entropy_lower_bound(degrees)
        all_H.append(H)
        all_LB.append(lb)
        all_p.append(p_val)

all_H = np.array(all_H)
all_LB = np.array(all_LB)
all_p = np.array(all_p)

sc = axes[0].scatter(all_LB, all_H, c=all_p, cmap='viridis', alpha=0.4, s=8)
axes[0].plot([0, np.log(n)], [0, np.log(n)], 'r--', linewidth=2, label='H = bound (equality)')
axes[0].set_xlabel('Lower Bound: log(|V|·d̄/Δ)', fontsize=12)
axes[0].set_ylabel('Degree Entropy H(G)', fontsize=12)
axes[0].set_title('Entropy vs Certified Lower Bound', fontsize=13)
axes[0].legend(fontsize=10)
plt.colorbar(sc, ax=axes[0], label='Edge probability p')

# Plot 2: Entropy margin by density
p_bins = np.linspace(0.05, 0.95, 20)
mean_margins = []
min_margins = []
for i in range(len(p_bins) - 1):
    mask = (all_p >= p_bins[i]) & (all_p < p_bins[i + 1])
    if mask.any():
        margins = all_H[mask] - all_LB[mask]
        mean_margins.append(margins.mean())
        min_margins.append(margins.min())
    else:
        mean_margins.append(0)
        min_margins.append(0)

bin_centers = (p_bins[:-1] + p_bins[1:]) / 2
axes[1].fill_between(bin_centers, 0, mean_margins, alpha=0.3, color='blue', label='Mean margin')
axes[1].plot(bin_centers, mean_margins, 'b-', linewidth=2)
axes[1].plot(bin_centers, min_margins, 'r-', linewidth=2, label='Min margin')
axes[1].axhline(y=0, color='k', linewidth=0.5, linestyle='--')
axes[1].set_xlabel('Edge Probability p', fontsize=12)
axes[1].set_ylabel('H(G) − log(|V|·d̄/Δ)', fontsize=12)
axes[1].set_title('Bound Margin vs Graph Density', fontsize=13)
axes[1].legend(fontsize=10)

# Plot 3: Regularity deficit
all_D = np.log(n) - all_H
all_UB = []
for H_val, p_val in zip(all_H, all_p):
    adj = generate_erdos_renyi(n, p_val)
    degrees = degree_sequence(adj)
    d_bar = float(degrees.mean())
    delta = int(degrees.max())
    if d_bar > 0 and delta > 0:
        all_UB.append(np.log(delta / d_bar))
    else:
        all_UB.append(0)
all_UB = np.array(all_UB)

axes[2].scatter(all_p, all_D, c='steelblue', alpha=0.3, s=8, label='D(G)')
axes[2].set_xlabel('Edge Probability p', fontsize=12)
axes[2].set_ylabel('Regularity Deficit D(G)', fontsize=12)
axes[2].set_title('Deficit Decreases with Density', fontsize=13)
axes[2].legend(fontsize=10)

plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")


#!/usr/bin/env python3
"""
Visualization 3: KL Divergence Identity and Entropy Rigidity

Visualizes two key results:
1. D(G) = D_KL(p || uniform) — the regularity deficit IS a KL divergence
2. Regular graphs uniquely maximize entropy (rigidity theorem)

Shows how the degree distribution of regular vs irregular graphs
relates to the uniform distribution, and how entropy changes as
graphs are perturbed away from regularity.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees):
    return float(degrees.sum())


def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def regularity_deficit(degrees):
    n = len(degrees)
    return np.log(n) - shannon_entropy(degrees)


def kl_divergence_from_uniform(degrees):
    n = len(degrees)
    p = degree_distribution(degrees)
    u = 1.0 / n
    kl = 0.0
    for pv in p:
        if pv > 0:
            kl += pv * np.log(pv / u)
    return kl


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Plot 1: D(G) vs D_KL(p || u) ---
n_graphs = 300
deficits = []
kl_divs = []

for _ in range(n_graphs):
    n = random.choice([20, 30, 40, 50])
    p = random.uniform(0.05, 0.9)
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    degrees = degree_sequence(adj)
    if graph_volume(degrees) == 0:
        continue
    D = regularity_deficit(degrees)
    KL = kl_divergence_from_uniform(degrees)
    deficits.append(D)
    kl_divs.append(KL)

deficits = np.array(deficits)
kl_divs = np.array(kl_divs)

axes[0].scatter(kl_divs, deficits, c='steelblue', alpha=0.5, s=15)
axes[0].plot([0, deficits.max()], [0, deficits.max()], 'r-', linewidth=2, label='D = D_KL (identity)')
axes[0].set_xlabel('D_KL(p || uniform)', fontsize=12)
axes[0].set_ylabel('Regularity Deficit D(G)', fontsize=12)
axes[0].set_title('Verified: D(G) ≡ D_KL(p || u)', fontsize=13)
axes[0].legend(fontsize=11)
max_err = np.max(np.abs(deficits - kl_divs))
axes[0].text(0.05, 0.9, f'Max |D - D_KL| = {max_err:.2e}',
             transform=axes[0].transAxes, fontsize=10,
             bbox=dict(boxstyle='round', facecolor='lightyellow'))

# --- Plot 2: Entropy rigidity - perturbing from regular ---
n = 30
# Start with a 6-regular graph (cycle with 3 neighbors each side)
adj_base = np.zeros((n, n), dtype=int)
for i in range(n):
    for d in [1, 2, 3]:
        adj_base[i][(i + d) % n] = adj_base[(i + d) % n][i] = 1

perturbation_levels = np.linspace(0, 0.5, 30)
mean_entropies = []
mean_deficits = []

for pert in perturbation_levels:
    trial_H = []
    trial_D = []
    for _ in range(50):
        adj = adj_base.copy()
        # Randomly add/remove edges
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < pert:
                    adj[i][j] = 1 - adj[i][j]
                    adj[j][i] = adj[i][j]
        # Ensure simple graph
        np.fill_diagonal(adj, 0)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue
        trial_H.append(shannon_entropy(degrees))
        trial_D.append(regularity_deficit(degrees))
    if trial_H:
        mean_entropies.append(np.mean(trial_H))
        mean_deficits.append(np.mean(trial_D))
    else:
        mean_entropies.append(0)
        mean_deficits.append(0)

axes[1].plot(perturbation_levels, mean_entropies, 'b-', linewidth=2, label='H(G)')
axes[1].axhline(y=np.log(n), color='r', linewidth=1, linestyle='--', label='log|V| (max entropy)')
axes[1].set_xlabel('Perturbation Level', fontsize=12)
axes[1].set_ylabel('Degree Entropy H(G)', fontsize=12)
axes[1].set_title('Entropy Rigidity: Perturbing from Regular', fontsize=13)
axes[1].legend(fontsize=10)

# --- Plot 3: Degree distribution comparison ---
# Regular graph
degrees_reg = degree_sequence(adj_base)
p_reg = degree_distribution(degrees_reg)

# Highly irregular graph (star + some random)
adj_irreg = np.zeros((n, n), dtype=int)
for i in range(1, n):
    adj_irreg[0][i] = adj_irreg[i][0] = 1
for i in range(1, n):
    for j in range(i + 1, n):
        if random.random() < 0.1:
            adj_irreg[i][j] = adj_irreg[j][i] = 1
degrees_irreg = degree_sequence(adj_irreg)
p_irreg = degree_distribution(degrees_irreg)

uniform = np.ones(n) / n

x = np.arange(n)
width = 0.25
axes[2].bar(x - width, sorted(p_reg, reverse=True), width, color='steelblue', alpha=0.7, label='Regular graph')
axes[2].bar(x, sorted(p_irreg, reverse=True), width, color='coral', alpha=0.7, label='Irregular graph')
axes[2].bar(x + width, uniform, width, color='gray', alpha=0.4, label='Uniform 1/|V|')
axes[2].set_xlabel('Vertex (sorted by degree)', fontsize=12)
axes[2].set_ylabel('Probability p_v', fontsize=12)
axes[2].set_title('Degree Distribution vs Uniform', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].set_xlim(-1, n)

plt.tight_layout()
plt.savefig('kl_divergence_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved kl_divergence_rigidity.png")


#!/usr/bin/env python3
"""
Visualization 2: Testing the Strong Spectral Conjecture

Tests the conjecture H(G) ≥ log(|V|·λ₁/Δ) across random graphs.
The certified bound uses d̄ instead of λ₁; the conjecture replaces d̄
with the spectral radius λ₁ ≥ d̄ (a STRONGER claim).

Displays empirical evidence for/against the conjecture across
different graph families and densities.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees):
    return float(degrees.sum())


def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def spectral_radius(adj):
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


n = 50
p_values = [0.1, 0.3, 0.5, 0.7]
n_samples = 250

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

for idx, p_val in enumerate(p_values):
    ax = axes[idx // 2][idx % 2]

    entropies = []
    certified_bounds = []
    spectral_bounds = []
    counterexamples_x = []
    counterexamples_y = []

    for _ in range(n_samples):
        adj = generate_erdos_renyi(n, p_val)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue

        H = shannon_entropy(degrees)
        d_bar = float(degrees.mean())
        delta = int(degrees.max())
        lam1 = spectral_radius(adj)

        if delta == 0:
            continue

        lb_cert = np.log(n * d_bar / delta)
        lb_spec = np.log(n * lam1 / delta)

        entropies.append(H)
        certified_bounds.append(lb_cert)
        spectral_bounds.append(lb_spec)

        if H < lb_spec - 1e-10:
            counterexamples_x.append(lb_spec)
            counterexamples_y.append(H)

    entropies = np.array(entropies)
    certified_bounds = np.array(certified_bounds)
    spectral_bounds = np.array(spectral_bounds)

    # Plot certified bound
    ax.scatter(certified_bounds, entropies, c='steelblue', alpha=0.3, s=12, label='Certified bound (d̄)')
    # Plot spectral bound
    ax.scatter(spectral_bounds, entropies, c='orange', alpha=0.3, s=12, label='Spectral bound (λ₁)')

    if len(counterexamples_x) > 0:
        ax.scatter(counterexamples_x, counterexamples_y, c='red', s=50, marker='x',
                   label=f'Counterexamples: {len(counterexamples_x)}', zorder=5)

    # Equality line
    lims = [min(certified_bounds.min(), spectral_bounds.min()) - 0.1,
            max(entropies.max(), spectral_bounds.max()) + 0.1]
    ax.plot(lims, lims, 'k--', linewidth=1, alpha=0.5)

    margin_cert = (entropies - certified_bounds).min()
    margin_spec = (entropies - spectral_bounds).min()

    ax.set_xlabel('Lower Bound', fontsize=11)
    ax.set_ylabel('Entropy H(G)', fontsize=11)
    ax.set_title(f'G({n}, {p_val}): min margin (cert)={margin_cert:.4f}, (spec)={margin_spec:.4f}', fontsize=12)
    ax.legend(fontsize=9, loc='upper left')

plt.suptitle('Strong Spectral Conjecture: H(G) ≥ log(|V|·λ₁/Δ)', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('spectral_conjecture.png', dpi=150, bbox_inches='tight')
print("Saved spectral_conjecture.png")
