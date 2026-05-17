"""
Applications of Tropical Polyphonic Optimization

Real-world applications demonstrating the theorems:
1. Certified chorale generation with optimality proof
2. Factor graph energy minimization (WCSP)
3. Shortest path as tropical tensor contraction
4. Sequence alignment via tropical DP
"""

import numpy as np
from itertools import product as cartesian_product

# ================================================================
# Application 1: Certified Chorale Generation
# ================================================================

def certified_chorale_generation():
    """
    Generate an optimal 4-voice chorale and produce a certificate
    proving its optimality via the rigidity theorem.
    """
    print("=" * 60)
    print("Application 1: Certified Chorale Generation")
    print("=" * 60)

    CONSONANCES = {0, 3, 4, 5, 7, 8, 9, 12}
    NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F',
                  'F#', 'G', 'G#', 'A', 'A#', 'B']

    def note_name(midi):
        return f"{NOTE_NAMES[midi % 12]}{midi // 12 - 1}"

    def pair_cost(pi, pj):
        interval = abs(pi - pj) % 12
        return 0.0 if interval in CONSONANCES else 2.0

    def spacing_cost(voice, pitch):
        ranges = [(60, 77), (55, 72), (48, 67), (41, 60)]
        lo, hi = ranges[voice]
        return max(0.0, max(lo - pitch, pitch - hi))

    # Search for zero-cost chorales
    pitches = list(range(48, 72))
    voice_pairs = [(i, j) for i in range(4) for j in range(i + 1, 4)]

    zero_cost_chorales = []
    for s, a, t, b in cartesian_product(
        range(60, 72), range(55, 67), range(48, 60), range(41, 55)
    ):
        chorale = [s, a, t, b]
        pair_total = sum(pair_cost(chorale[i], chorale[j])
                         for i, j in voice_pairs)
        space_total = sum(spacing_cost(v, chorale[v]) for v in range(4))
        if pair_total + space_total == 0:
            zero_cost_chorales.append(chorale)

    print(f"\n  Found {len(zero_cost_chorales)} zero-cost chorales")
    for c in zero_cost_chorales[:5]:
        names = [note_name(p) for p in c]
        print(f"    S={names[0]:4s} A={names[1]:4s} "
              f"T={names[2]:4s} B={names[3]:4s}  ({c})")

    if zero_cost_chorales:
        print(f"\n  Certificate for first chorale:")
        c = zero_cost_chorales[0]
        for i, j in voice_pairs:
            pc = pair_cost(c[i], c[j])
            vnames = ['S', 'A', 'T', 'B']
            print(f"    pairCost({vnames[i]},{vnames[j]}) = {pc} ✓")
        for v in range(4):
            sc = spacing_cost(v, c[v])
            print(f"    spacingPenalty({['S','A','T','B'][v]}) = {sc} ✓")
        print("    → By rigidity theorem: total cost = 0 ✓")
    print()


# ================================================================
# Application 2: Weighted CSP / Factor Graph
# ================================================================

def factor_graph_optimization():
    """
    Solve a weighted constraint satisfaction problem (WCSP)
    using the tropical tensor framework.

    Example: graph coloring with soft constraints.
    """
    print("=" * 60)
    print("Application 2: Factor Graph Optimization (Graph Coloring)")
    print("=" * 60)

    n_nodes = 4
    n_colors = 3
    edges = [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)]

    # Pairwise penalty: 1 for same color, 0 for different
    def edge_penalty(ci, cj):
        return 1.0 if ci == cj else 0.0

    # Unary preference: slight preference for certain colors per node
    preferences = np.random.RandomState(123).rand(n_nodes, n_colors) * 0.3

    def node_penalty(node, color):
        return preferences[node, color]

    # Brute force
    best_cost = float('inf')
    best_coloring = None

    for coloring in cartesian_product(range(n_colors), repeat=n_nodes):
        cost = sum(edge_penalty(coloring[i], coloring[j]) for i, j in edges)
        cost += sum(node_penalty(v, coloring[v]) for v in range(n_nodes))
        if cost < best_cost:
            best_cost = cost
            best_coloring = coloring

    print(f"\n  Graph: {n_nodes} nodes, {len(edges)} edges, {n_colors} colors")
    print(f"  Optimal coloring: {best_coloring}")
    print(f"  Optimal cost: {best_cost:.4f}")

    # Verify rigidity if cost is near zero
    edge_costs = [edge_penalty(best_coloring[i], best_coloring[j])
                  for i, j in edges]
    node_costs = [node_penalty(v, best_coloring[v]) for v in range(n_nodes)]
    print(f"  Edge penalties: {edge_costs}")
    print(f"  Node penalties: {[f'{c:.3f}' for c in node_costs]}")
    print(f"  All edge constraints satisfied: "
          f"{'✓' if all(c == 0 for c in edge_costs) else '✗'}")
    print()


# ================================================================
# Application 3: Shortest Path as Tropical Contraction
# ================================================================

def shortest_path_tropical():
    """
    Shortest path in a graph via tropical matrix multiplication.

    The adjacency matrix of a weighted graph is a tropical matrix.
    Tropical matrix powers give shortest paths of bounded length.
    """
    print("=" * 60)
    print("Application 3: Shortest Path via Tropical Matrix Power")
    print("=" * 60)

    # 5-node weighted graph
    INF = float('inf')
    W = np.array([
        [0, 3, INF, 7, INF],
        [3, 0, 1, INF, 2],
        [INF, 1, 0, 2, INF],
        [7, INF, 2, 0, 4],
        [INF, 2, INF, 4, 0]
    ])

    def tropical_matmul(A, B):
        """Tropical matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj})"""
        n = A.shape[0]
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C

    # Compute shortest paths by tropical power (Floyd-Warshall equivalent)
    D = W.copy()
    for _ in range(4):  # n-1 iterations
        D = tropical_matmul(D, W)

    print(f"\n  Weight matrix W:")
    for row in W:
        print(f"    {['∞' if x == INF else f'{x:.0f}' for x in row]}")

    print(f"\n  Shortest path matrix D = W^(⊗n):")
    for row in D:
        print(f"    {[f'{x:.0f}' for x in row]}")

    # Verify: shortest path from 0 to 4
    print(f"\n  Shortest path 0→4: {D[0, 4]:.0f} "
          f"(via 0→1→4: {W[0,1]+W[1,4]:.0f})")
    print()


# ================================================================
# Application 4: Sequence Alignment via Tropical DP
# ================================================================

def sequence_alignment_tropical():
    """
    Sequence alignment (edit distance) as tropical dynamic programming.

    This is a direct application of the product-space minimization theorem.
    """
    print("=" * 60)
    print("Application 4: Sequence Alignment (Edit Distance)")
    print("=" * 60)

    seq1 = "BACH"
    seq2 = "BEACH"

    n, m = len(seq1), len(seq2)

    # DP table (tropical minimum over alignment paths)
    dp = np.zeros((n + 1, m + 1))
    for i in range(n + 1):
        dp[i, 0] = i
    for j in range(m + 1):
        dp[0, j] = j

    for i in range(1, n + 1):
        for j in range(1, m + 1):
            match_cost = 0 if seq1[i-1] == seq2[j-1] else 1
            dp[i, j] = min(
                dp[i-1, j] + 1,      # deletion
                dp[i, j-1] + 1,      # insertion
                dp[i-1, j-1] + match_cost  # substitution/match
            )

    print(f"\n  Sequences: '{seq1}' → '{seq2}'")
    print(f"  Edit distance (tropical DP minimum): {int(dp[n, m])}")
    print(f"\n  DP table (tropical min-plus computation):")
    header = "    " + "   ".join([" "] + list(seq2))
    print(header)
    for i in range(n + 1):
        label = " " if i == 0 else seq1[i - 1]
        row = [f"{int(dp[i,j]):2d}" for j in range(m + 1)]
        print(f"  {label} " + "  ".join(row))
    print()


# ================================================================
# Run all applications
# ================================================================

if __name__ == "__main__":
    certified_chorale_generation()
    factor_graph_optimization()
    shortest_path_tropical()
    sequence_alignment_tropical()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Tropical Polyphonic Optimization — Concrete Demonstrations

Demonstrates the key theorems with numerical examples:
1. Tropical tensor additivity: min(f⊗g) = min(f) + min(g)
2. Product-space minimization: min_{a,b} f(a,b) = min_a min_b f(a,b)
3. Chorale zero-cost rigidity: total=0 ⟺ all factors=0
4. Variable elimination speedup for four-voice optimization
"""

import numpy as np
from itertools import product as cartesian_product

np.random.seed(42)

# ============================================================
# Demo 1: Tropical Tensor Additivity
# ============================================================

def trop_min(f_values):
    """Tropical minimum (inf over a finite set)."""
    return np.min(f_values)

def trop_tensor(f, g):
    """Tropical tensor product: (f⊗g)(a,b) = f(a) + g(b)."""
    return np.add.outer(f, g)

print("=" * 60)
print("Demo 1: Tropical Tensor Additivity")
print("  Theorem: min_{a,b} (f(a) + g(b)) = min(f) + min(g)")
print("=" * 60)

for trial in range(5):
    n_alpha, n_beta = np.random.randint(3, 20, size=2)
    f = np.random.randn(n_alpha) * 5
    g = np.random.randn(n_beta) * 5

    tensor = trop_tensor(f, g)
    lhs = trop_min(tensor)
    rhs = trop_min(f) + trop_min(g)

    print(f"  Trial {trial+1}: |α|={n_alpha}, |β|={n_beta}, "
          f"min(f⊗g) = {lhs:.6f}, min(f)+min(g) = {rhs:.6f}, "
          f"error = {abs(lhs - rhs):.2e}")

# ============================================================
# Demo 2: Product-Space Minimization
# ============================================================

print("\n" + "=" * 60)
print("Demo 2: Product-Space Minimization")
print("  Theorem: min_{a,b} f(a,b) = min_a min_b f(a,b)")
print("=" * 60)

for trial in range(5):
    n_alpha, n_beta = np.random.randint(3, 15, size=2)
    F = np.random.randn(n_alpha, n_beta) * 10

    global_min = np.min(F)
    iterated_min = np.min(np.min(F, axis=1))

    print(f"  Trial {trial+1}: |α|={n_alpha}, |β|={n_beta}, "
          f"global min = {global_min:.6f}, iterated min = {iterated_min:.6f}, "
          f"equal = {np.isclose(global_min, iterated_min)}")

# ============================================================
# Demo 3: Four-Voice Chorale Zero-Cost Rigidity
# ============================================================

print("\n" + "=" * 60)
print("Demo 3: Four-Voice Chorale Zero-Cost Rigidity")
print("  Theorem: total_cost=0 ∧ all_nonneg ⟹ each_factor=0")
print("=" * 60)

VOICES = 4
VOICE_PAIRS = [(i, j) for i in range(VOICES) for j in range(i+1, VOICES)]

def chorale_cost(chorale, pair_cost_fn, spacing_penalty_fn):
    """Compute total chorale cost = Σ pair_costs + Σ spacing_penalties."""
    pair_total = sum(pair_cost_fn(i, j, chorale[i], chorale[j])
                     for i, j in VOICE_PAIRS)
    spacing_total = sum(spacing_penalty_fn(i, chorale[i])
                        for i in range(VOICES))
    return pair_total, spacing_total, pair_total + spacing_total

# Example: consonance-based pair cost
CONSONANCES = {0, 3, 4, 5, 7, 8, 9, 12}

def pair_cost(i, j, pitch_i, pitch_j):
    """Penalty for dissonant interval (nonneg)."""
    interval = abs(pitch_i - pitch_j) % 12
    return 0.0 if interval in CONSONANCES else 1.0

def spacing_penalty(i, pitch):
    """Penalty for being out of comfortable range (nonneg)."""
    ranges = [(60, 79), (53, 72), (47, 67), (40, 60)]  # S, A, T, B (MIDI)
    lo, hi = ranges[i]
    if lo <= pitch <= hi:
        return 0.0
    return abs(pitch - lo) + abs(pitch - hi) - (hi - lo)

# A perfect chorale (all costs zero)
perfect_chorale = [67, 60, 55, 48]  # G4, C4, G3, C3
pair_costs = [pair_cost(i, j, perfect_chorale[i], perfect_chorale[j])
              for i, j in VOICE_PAIRS]
space_costs = [spacing_penalty(i, perfect_chorale[i]) for i in range(VOICES)]
pc, sc, tc = chorale_cost(perfect_chorale, pair_cost, spacing_penalty)

print(f"\n  Perfect chorale: {perfect_chorale}")
print(f"  Pair costs:    {pair_costs}")
print(f"  Spacing costs: {space_costs}")
print(f"  Total cost:    {tc}")
print(f"  Rigidity check: total=0 ⟹ all factors=0? "
      f"{'✓ YES' if tc == 0 and all(p == 0 for p in pair_costs + space_costs) else '✗ NO'}")

# An imperfect chorale
bad_chorale = [67, 61, 55, 48]
pc2, sc2, tc2 = chorale_cost(bad_chorale, pair_cost, spacing_penalty)
print(f"\n  Imperfect chorale: {bad_chorale}")
print(f"  Total cost: {tc2} (> 0, so rigidity does not apply)")

# ============================================================
# Demo 4: Variable Elimination Speedup
# ============================================================

print("\n" + "=" * 60)
print("Demo 4: Variable Elimination Speedup")
print("  Theorem: min over product = iterated mins")
print("=" * 60)

PITCHES = list(range(48, 60))  # 12 pitches (one octave)
N_PITCHES = len(PITCHES)

def local_energy(s, a, t, b):
    """Four-voice energy at one time step."""
    voices = [s, a, t, b]
    cost = 0.0
    for i, j in VOICE_PAIRS:
        interval = abs(voices[i] - voices[j]) % 12
        if interval not in CONSONANCES:
            cost += 1.0
    for i in range(VOICES):
        cost += spacing_penalty(i, voices[i])
    return cost

# Brute force: enumerate all 12^4 = 20736 configurations
print(f"\n  State space: {N_PITCHES} pitches per voice")
print(f"  Brute force: {N_PITCHES}^4 = {N_PITCHES**4} configurations")

all_configs = list(cartesian_product(PITCHES, repeat=4))
all_costs = [local_energy(*c) for c in all_configs]
bf_min = min(all_costs)
bf_argmin = all_configs[np.argmin(all_costs)]

# Variable elimination: fix (S,A), minimize over (T,B)
print(f"  Variable elimination: {N_PITCHES}^2 × {N_PITCHES}^2 = "
      f"{N_PITCHES**2} outer × {N_PITCHES**2} inner")

best_overall = float('inf')
best_config = None

sa_pairs = list(cartesian_product(PITCHES, repeat=2))
tb_pairs = list(cartesian_product(PITCHES, repeat=2))

for s, a in sa_pairs:
    inner_min = float('inf')
    inner_best = None
    for t, b in tb_pairs:
        cost = local_energy(s, a, t, b)
        if cost < inner_min:
            inner_min = cost
            inner_best = (t, b)
    if inner_min < best_overall:
        best_overall = inner_min
        best_config = (s, a) + inner_best

print(f"\n  Brute force minimum:    {bf_min} at {bf_argmin}")
print(f"  Var. elimination min:   {best_overall} at {best_config}")
print(f"  Results match: {'✓ YES' if np.isclose(bf_min, best_overall) else '✗ NO'}")

# ============================================================
# Demo 5: Mass verification of tensor theorem
# ============================================================

print("\n" + "=" * 60)
print("Demo 5: Mass Verification of Tropical Tensor Theorem")
print("=" * 60)

max_error = 0.0
n_trials = 10000
for _ in range(n_trials):
    na = np.random.randint(2, 50)
    nb = np.random.randint(2, 50)
    f = np.random.randn(na) * 100
    g = np.random.randn(nb) * 100
    tensor = trop_tensor(f, g)
    err = abs(trop_min(tensor) - (trop_min(f) + trop_min(g)))
    max_error = max(max_error, err)

print(f"  {n_trials} random trials, max error: {max_error:.2e}")
print(f"  Theorem verified to machine precision: "
      f"{'✓ YES' if max_error < 1e-10 else '✗ NO'}")

print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)


"""
Visualizations for Tropical Polyphonic Optimization

Generates charts illustrating key mathematical structures:
1. Tropical tensor product heatmap
2. Chorale cost landscape
3. Rigidity decomposition
4. Variable elimination diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"

# ================================================================
# Visualization 1: Tropical Tensor Product
# ================================================================

def plot_tropical_tensor():
    np.random.seed(42)
    f = np.array([3.0, 1.0, 4.0, 1.5, 2.7])
    g = np.array([2.0, 0.5, 3.0, 1.0])

    tensor = np.add.outer(f, g)
    min_f = np.min(f)
    min_g = np.min(g)
    min_tensor = np.min(tensor)

    fig, axes = plt.subplots(1, 3, figsize=(14, 4),
                             gridspec_kw={'width_ratios': [1, 1, 3]})

    # f values
    axes[0].barh(range(len(f)), f, color='steelblue', alpha=0.8)
    axes[0].axvline(min_f, color='red', linestyle='--', linewidth=2,
                    label=f'min(f) = {min_f}')
    axes[0].set_yticks(range(len(f)))
    axes[0].set_yticklabels([f'α={i}' for i in range(len(f))])
    axes[0].set_xlabel('f(α)')
    axes[0].set_title('Cost f')
    axes[0].legend(fontsize=8)
    axes[0].invert_yaxis()

    # g values
    axes[1].barh(range(len(g)), g, color='coral', alpha=0.8)
    axes[1].axvline(min_g, color='red', linestyle='--', linewidth=2,
                    label=f'min(g) = {min_g}')
    axes[1].set_yticks(range(len(g)))
    axes[1].set_yticklabels([f'β={i}' for i in range(len(g))])
    axes[1].set_xlabel('g(β)')
    axes[1].set_title('Cost g')
    axes[1].legend(fontsize=8)
    axes[1].invert_yaxis()

    # Tensor product
    im = axes[2].imshow(tensor, cmap='YlOrRd', aspect='auto')
    min_pos = np.unravel_index(np.argmin(tensor), tensor.shape)
    axes[2].plot(min_pos[1], min_pos[0], 'k*', markersize=20,
                 label=f'min(f⊗g) = {min_tensor}')
    axes[2].set_xticks(range(len(g)))
    axes[2].set_xticklabels([f'β={i}' for i in range(len(g))])
    axes[2].set_yticks(range(len(f)))
    axes[2].set_yticklabels([f'α={i}' for i in range(len(f))])
    axes[2].set_title(f'Tropical Tensor f⊗g\n'
                      f'min(f⊗g) = {min_tensor} = {min_f} + {min_g}')
    axes[2].legend(fontsize=9, loc='lower right')
    plt.colorbar(im, ax=axes[2], shrink=0.8)

    # Add cell values
    for i in range(len(f)):
        for j in range(len(g)):
            axes[2].text(j, i, f'{tensor[i,j]:.1f}',
                        ha='center', va='center', fontsize=9,
                        color='white' if tensor[i,j] > 3.5 else 'black')

    fig.suptitle('Tropical Tensor Theorem: min(f⊗g) = min(f) + min(g)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


# ================================================================
# Visualization 2: Chorale Cost Landscape
# ================================================================

def plot_chorale_landscape():
    CONSONANCES = {0, 3, 4, 5, 7, 8, 9, 12}
    voice_pairs = [(i, j) for i in range(4) for j in range(i + 1, 4)]

    def chorale_cost(s, a, t, b):
        voices = [s, a, t, b]
        cost = 0
        for i, j in voice_pairs:
            interval = abs(voices[i] - voices[j]) % 12
            if interval not in CONSONANCES:
                cost += 1
        return cost

    # Fix T=55, B=48, vary S and A
    s_range = range(60, 73)
    a_range = range(53, 66)
    costs = np.zeros((len(list(s_range)), len(list(a_range))))
    s_vals = list(s_range)
    a_vals = list(a_range)

    for i, s in enumerate(s_vals):
        for j, a in enumerate(a_vals):
            costs[i, j] = chorale_cost(s, a, 55, 48)

    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(costs, cmap='RdYlGn_r', aspect='auto',
                   origin='lower', interpolation='nearest')

    # Mark zero-cost points
    zeros = np.argwhere(costs == 0)
    if len(zeros) > 0:
        ax.scatter(zeros[:, 1], zeros[:, 0], c='lime', s=100,
                   edgecolors='black', linewidths=2, zorder=5,
                   label=f'Zero-cost ({len(zeros)} points)')

    note_names = ['C', 'C#', 'D', 'D#', 'E', 'F',
                  'F#', 'G', 'G#', 'A', 'A#', 'B']

    ax.set_xticks(range(0, len(a_vals), 2))
    ax.set_xticklabels([f'{note_names[a%12]}{a//12-1}'
                        for a in a_vals[::2]], rotation=45)
    ax.set_yticks(range(0, len(s_vals), 2))
    ax.set_yticklabels([f'{note_names[s%12]}{s//12-1}'
                        for s in s_vals[::2]])
    ax.set_xlabel('Alto Pitch')
    ax.set_ylabel('Soprano Pitch')
    ax.set_title('Chorale Cost Landscape (T=G3, B=C3)\n'
                 'Green points satisfy all pairwise consonance constraints',
                 fontsize=12)
    ax.legend(loc='upper right', fontsize=11)
    plt.colorbar(im, ax=ax, label='Number of dissonant pairs')
    plt.tight_layout()
    return fig_to_base64(fig)


# ================================================================
# Visualization 3: Rigidity Decomposition
# ================================================================

def plot_rigidity():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Zero-cost example (rigidity holds)
    labels = ['S-A', 'S-T', 'S-B', 'A-T', 'A-B', 'T-B',
              'ψ(S)', 'ψ(A)', 'ψ(T)', 'ψ(B)']
    zero_values = [0] * 10
    colors_zero = ['#2ecc71'] * 10

    axes[0].barh(range(10), zero_values, color=colors_zero, alpha=0.8,
                 edgecolor='darkgreen', linewidth=2)
    axes[0].set_yticks(range(10))
    axes[0].set_yticklabels(labels)
    axes[0].set_xlabel('Cost Value')
    axes[0].set_title('Zero-Cost Chorale: All Factors = 0\n'
                      '(Rigidity Theorem: global 0 ⟹ local 0)',
                      fontsize=11)
    axes[0].set_xlim(-0.5, 5)
    axes[0].axvline(0, color='black', linewidth=1)

    for i in range(10):
        axes[0].text(0.1, i, '0 ✓', va='center', fontsize=10,
                     color='darkgreen', fontweight='bold')

    # Right: Nonzero-cost example (some violations)
    nonzero_values = [0, 2, 0, 1, 0, 0, 0.5, 0, 0, 0.3]
    colors_nz = ['#2ecc71' if v == 0 else '#e74c3c' for v in nonzero_values]

    axes[1].barh(range(10), nonzero_values, color=colors_nz, alpha=0.8,
                 edgecolor=['darkgreen' if v == 0 else 'darkred'
                            for v in nonzero_values],
                 linewidth=2)
    axes[1].set_yticks(range(10))
    axes[1].set_yticklabels(labels)
    axes[1].set_xlabel('Cost Value')
    axes[1].set_title(f'Imperfect Chorale: Total = {sum(nonzero_values)}\n'
                      f'(Rigidity: total > 0 ⟹ ≥1 factor > 0)',
                      fontsize=11)
    axes[1].axvline(0, color='black', linewidth=1)

    for i in range(10):
        v = nonzero_values[i]
        if v > 0:
            axes[1].text(v + 0.1, i, f'{v} ✗', va='center', fontsize=10,
                         color='darkred', fontweight='bold')
        else:
            axes[1].text(0.1, i, '0 ✓', va='center', fontsize=10,
                         color='darkgreen', fontweight='bold')

    fig.suptitle('Zero-Cost Rigidity Theorem: Decomposition of Optimality Certificates',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


# ================================================================
# Visualization 4: Variable Elimination
# ================================================================

def plot_variable_elimination():
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Full 2D cost surface
    np.random.seed(42)
    n_a, n_b = 8, 10
    F = np.random.rand(n_a, n_b) * 5 + 1

    im = axes[0].imshow(F, cmap='viridis', aspect='auto')
    min_pos = np.unravel_index(np.argmin(F), F.shape)
    axes[0].plot(min_pos[1], min_pos[0], 'r*', markersize=20)
    axes[0].set_xlabel('β')
    axes[0].set_ylabel('α')
    axes[0].set_title(f'Full cost f(α,β)\nGlobal min = {F.min():.2f}')
    plt.colorbar(im, ax=axes[0], shrink=0.8)

    # Inner minimization: min_β f(α,β) for each α
    inner_mins = np.min(F, axis=1)
    inner_argmins = np.argmin(F, axis=1)

    axes[1].barh(range(n_a), inner_mins, color='teal', alpha=0.8)
    axes[1].set_yticks(range(n_a))
    axes[1].set_yticklabels([f'α={i}' for i in range(n_a)])
    axes[1].set_xlabel('min_β f(α,β)')
    axes[1].set_title('Step 1: Inner Minimization\nmin_β f(α,β) for each α')
    axes[1].invert_yaxis()

    # Highlight the optimal α
    opt_a = np.argmin(inner_mins)
    axes[1].barh(opt_a, inner_mins[opt_a], color='red', alpha=0.9)

    # Outer minimization
    outer_min = np.min(inner_mins)
    axes[2].bar(['min_α min_β f(α,β)'], [outer_min], color='red', alpha=0.8,
                width=0.5)
    axes[2].set_ylabel('Cost')
    axes[2].set_title(f'Step 2: Outer Minimization\n'
                      f'min_α (min_β f(α,β)) = {outer_min:.2f}')
    axes[2].set_ylim(0, max(inner_mins) * 1.2)

    # Add annotation
    axes[2].text(0, outer_min + 0.2,
                f'= global min = {F.min():.2f}\nat α={min_pos[0]}, β={min_pos[1]}',
                ha='center', fontsize=10)

    fig.suptitle('Product-Space Minimization: min_{α,β} f = min_α min_β f',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


# ================================================================
# Generate all visualizations
# ================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_tropical_tensor()
    print(f"  Tropical tensor: {len(img1)} chars")

    img2 = plot_chorale_landscape()
    print(f"  Chorale landscape: {len(img2)} chars")

    img3 = plot_rigidity()
    print(f"  Rigidity: {len(img3)} chars")

    img4 = plot_variable_elimination()
    print(f"  Variable elimination: {len(img4)} chars")

    print("All visualizations generated successfully.")

    # Save individual PNGs
    for name, data in [('tropical_tensor', img1), ('chorale_landscape', img2),
                       ('rigidity', img3), ('variable_elimination', img4)]:
        img_data = base64.b64decode(data.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(img_data)
        print(f"  Saved {name}.png")
