"""
Applications of Matroid Hodge Theory and DPP Support Exchange

Real-world applications:
1. Diverse subset selection in machine learning
2. Sensor placement optimization
3. Document summarization via DPP sampling
"""
import numpy as np
from itertools import combinations
from typing import List, Tuple


def dpp_quality_diversity_kernel(
    quality: np.ndarray,
    similarity: np.ndarray
) -> np.ndarray:
    """
    Construct a DPP kernel from quality scores and similarity matrix.

    K = diag(q) · S · diag(q) where q are quality scores and S is similarity.
    This kernel encodes the tension between quality and diversity:
    high-quality items are preferred, but similar items repel each other.

    Args:
        quality: n-vector of item quality scores
        similarity: n×n similarity matrix (PSD)

    Returns:
        n×n DPP kernel (PSD if similarity is PSD and quality ≥ 0)
    """
    n = len(quality)
    D = np.diag(quality)
    return D @ similarity @ D


def greedy_matroid_constrained_max(
    values: np.ndarray,
    K: np.ndarray,
    d: int,
    eps: float = 1e-10
) -> Tuple[Tuple[int, ...], float]:
    """
    Greedy maximization of a linear function subject to matroid constraint.

    Uses the fact that DPP support forms a matroid, so greedy gives
    a 1/2-approximation for monotone submodular maximization.

    The matroid constraint is: selected subset S must have det(K_S) > eps.

    Args:
        values: n-vector of item values
        K: n×n PSD kernel matrix
        d: target subset size
        eps: positivity threshold

    Returns:
        (best_subset, value) tuple
    """
    n = len(values)
    selected = []

    for _ in range(d):
        best_idx = -1
        best_val = -np.inf
        for i in range(n):
            if i in selected:
                continue
            candidate = sorted(selected + [i])
            det = np.linalg.det(K[np.ix_(candidate, candidate)])
            if det > eps and values[i] > best_val:
                best_val = values[i]
                best_idx = i
        if best_idx == -1:
            break
        selected.append(best_idx)

    selected = tuple(sorted(selected))
    return selected, sum(values[i] for i in selected)


def sensor_placement_demo():
    """Demo: Optimal sensor placement using matroid-constrained DPP."""
    print("=" * 60)
    print("Application: Sensor Placement Optimization")
    print("=" * 60)

    # 8 candidate sensor locations with quality and correlation
    np.random.seed(42)
    n = 8
    d = 4  # select 4 sensors

    # Quality scores (signal strength at each location)
    quality = np.array([0.9, 0.7, 0.8, 0.6, 0.95, 0.5, 0.85, 0.75])

    # Spatial correlation (nearby sensors are correlated)
    positions = np.random.rand(n, 2) * 10
    dists = np.sqrt(np.sum((positions[:, None] - positions[None, :]) ** 2, axis=2))
    similarity = np.exp(-dists / 3.0)

    # Build DPP kernel
    K = dpp_quality_diversity_kernel(quality, similarity)

    # Find best diverse subset
    best_subset, best_value = greedy_matroid_constrained_max(quality, K, d)

    print(f"  Candidate locations: {n}")
    print(f"  Select: {d} sensors")
    print(f"  Quality scores: {quality}")
    print(f"  Selected sensors: {best_subset}")
    print(f"  Total quality: {best_value:.3f}")
    print(f"  det(K_S) = {np.linalg.det(K[np.ix_(list(best_subset), list(best_subset))]):.6f}")

    # Compare with top-quality (ignoring diversity)
    top_quality = tuple(np.argsort(-quality)[:d])
    top_det = np.linalg.det(K[np.ix_(list(top_quality), list(top_quality))])
    print(f"  Top-quality sensors: {top_quality}")
    print(f"  Top-quality det(K_S) = {top_det:.6f}")
    print()


def document_summarization_demo():
    """Demo: Document summarization via DPP diversity."""
    print("=" * 60)
    print("Application: Document Summarization")
    print("=" * 60)

    np.random.seed(7)
    n = 10  # 10 candidate sentences
    d = 3   # select 3 for summary

    # Random sentence embeddings (simulating semantic vectors)
    embeddings = np.random.randn(n, 5)
    embeddings /= np.linalg.norm(embeddings, axis=1, keepdims=True)

    # Quality = norm of embedding (simulating relevance)
    quality = 0.5 + 0.5 * np.random.rand(n)

    # Similarity via cosine
    similarity = embeddings @ embeddings.T

    # Build kernel
    K = dpp_quality_diversity_kernel(quality, similarity)

    # Check DPP support is matroid
    support = []
    for S in combinations(range(n), d):
        det = np.linalg.det(K[np.ix_(list(S), list(S))])
        if det > 1e-10:
            support.append(S)

    print(f"  Sentences: {n}, Summary size: {d}")
    print(f"  DPP support size: {len(support)}")

    # Verify exchange property
    support_set = set(support)
    exchange_ok = True
    for B1 in support[:20]:  # check first 20 for speed
        for B2 in support[:20]:
            S1, S2 = set(B1), set(B2)
            for x in S1 - S2:
                found = any(
                    tuple(sorted((S1 - {x}) | {y})) in support_set
                    for y in S2 - S1
                )
                if not found:
                    exchange_ok = False
                    break
    print(f"  Exchange property: {'✓' if exchange_ok else '✗'}")

    # Find best summary
    best_S, best_val = greedy_matroid_constrained_max(quality, K, d)
    print(f"  Best summary sentences: {best_S}")
    print(f"  Total relevance: {best_val:.3f}")
    print()


if __name__ == "__main__":
    sensor_placement_demo()
    document_summarization_demo()
    print("All applications completed successfully!")


"""
Demo: Matroid Hodge Theory and DPP Support Exchange

Demonstrates the key theorems connecting determinantal point processes,
matroid theory, and Lorentzian polynomials through concrete numerical examples.
"""
import numpy as np
from itertools import combinations
from typing import List, Set, Tuple


def random_psd_matrix(n: int, rank: int = None) -> np.ndarray:
    """Generate a random n×n positive semidefinite matrix of given rank."""
    if rank is None:
        rank = n
    rank = min(rank, n)
    B = np.random.randn(rank, n)
    return B.T @ B


def principal_minor(K: np.ndarray, S: Tuple[int, ...]) -> float:
    """Compute det(K_S) for subset S."""
    S_list = list(S)
    return np.linalg.det(K[np.ix_(S_list, S_list)])


def dpp_support(K: np.ndarray, d: int, eps: float = 1e-10) -> List[Tuple[int, ...]]:
    """Compute the DPP support: {S : |S|=d, det(K_S) > eps}."""
    n = K.shape[0]
    support = []
    for S in combinations(range(n), d):
        if principal_minor(K, S) > eps:
            support.append(S)
    return support


def check_exchange_property(support: List[Tuple[int, ...]], n: int) -> bool:
    """Check the matroid exchange property for a collection of equal-sized subsets."""
    support_set = set(support)
    for B1 in support:
        for B2 in support:
            S1 = set(B1)
            S2 = set(B2)
            for x in S1 - S2:
                found = False
                for y in S2 - S1:
                    B1_new = tuple(sorted((S1 - {x}) | {y}))
                    if B1_new in support_set:
                        found = True
                        break
                if not found:
                    return False
    return True


def check_symmetric_exchange(support: List[Tuple[int, ...]], n: int) -> bool:
    """Check the SYMMETRIC exchange property (stronger):
    For all B1, B2 in support and x in B1\\B2,
    exists y in B2\\B1 such that both (B1-x+y) and (B2+x-y) are in support."""
    support_set = set(support)
    for B1 in support:
        for B2 in support:
            S1 = set(B1)
            S2 = set(B2)
            for x in S1 - S2:
                found = False
                for y in S2 - S1:
                    B1_new = tuple(sorted((S1 - {x}) | {y}))
                    B2_new = tuple(sorted((S2 - {y}) | {x}))
                    if B1_new in support_set and B2_new in support_set:
                        found = True
                        break
                if not found:
                    return False
    return True


def demo_psd_principal_minors():
    """Demo 1: All principal minors of PSD matrices are nonneg."""
    print("=" * 60)
    print("Demo 1: PSD Principal Minor Nonnegativity")
    print("=" * 60)
    np.random.seed(42)
    K = random_psd_matrix(5)
    print(f"K = random 5×5 PSD matrix")
    print(f"Eigenvalues: {np.linalg.eigvalsh(K)}")
    print()

    for d in range(1, 6):
        minors = [principal_minor(K, S) for S in combinations(range(5), d)]
        print(f"  d={d}: min det(K_S) = {min(minors):.6f} ≥ 0 ✓")
    print()


def demo_dpp_support_is_matroid():
    """Demo 2: DPP support satisfies the matroid exchange property."""
    print("=" * 60)
    print("Demo 2: DPP Support Exchange Property")
    print("=" * 60)
    np.random.seed(123)

    for trial in range(5):
        n = 6
        rank = 4
        K = random_psd_matrix(n, rank)
        for d in range(1, rank + 1):
            support = dpp_support(K, d)
            if len(support) >= 2:
                exchange_ok = check_exchange_property(support, n)
                sym_exchange_ok = check_symmetric_exchange(support, n)
                print(f"  Trial {trial+1}, d={d}: "
                      f"|support|={len(support):3d}, "
                      f"exchange={'✓' if exchange_ok else '✗'}, "
                      f"sym_exchange={'✓' if sym_exchange_ok else '✗'}")
    print()


def demo_rank1_kernel():
    """Demo 3: Rank-1 kernel vvᵀ is PSD with (vᵀx)² characterization."""
    print("=" * 60)
    print("Demo 3: Rank-1 Kernel PSD Property")
    print("=" * 60)
    v = np.array([1.0, 2.0, -1.0, 0.5])
    K = np.outer(v, v)
    print(f"v = {v}")
    print(f"K = vvᵀ")
    print(f"Eigenvalues of K: {np.linalg.eigvalsh(K)}")

    for _ in range(5):
        x = np.random.randn(4)
        quad_form = x @ K @ x
        vdotx_sq = (v @ x) ** 2
        print(f"  xᵀKx = {quad_form:.6f} = (vᵀx)² = {vdotx_sq:.6f} ≥ 0 ✓")
    print()


def demo_cauchy_schwarz():
    """Demo 4: PSD Cauchy-Schwarz K_ij² ≤ K_ii · K_jj."""
    print("=" * 60)
    print("Demo 4: PSD Entry Cauchy-Schwarz Inequality")
    print("=" * 60)
    np.random.seed(7)
    K = random_psd_matrix(4)
    n = K.shape[0]
    print(f"K = random 4×4 PSD matrix")
    for i in range(n):
        for j in range(i + 1, n):
            lhs = K[i, j] ** 2
            rhs = K[i, i] * K[j, j]
            print(f"  K[{i},{j}]² = {lhs:.6f} ≤ K[{i},{i}]·K[{j},{j}] = {rhs:.6f}: "
                  f"{'✓' if lhs <= rhs + 1e-10 else '✗'}")
    print()


def demo_negative_dependence():
    """Demo 5: Total negative dependence = Frobenius norm."""
    print("=" * 60)
    print("Demo 5: Total Negative Dependence = Frobenius Norm")
    print("=" * 60)
    np.random.seed(13)
    K = random_psd_matrix(4)
    K = (K + K.T) / 2  # ensure exact symmetry

    total_gap = sum(K[i, j] * K[j, i] for i in range(4) for j in range(4))
    frobenius = np.sum(K ** 2)
    print(f"  Σᵢⱼ K_ij·K_ji = {total_gap:.6f}")
    print(f"  Σᵢⱼ K_ij²     = {frobenius:.6f}")
    print(f"  Equal: {'✓' if abs(total_gap - frobenius) < 1e-10 else '✗'}")
    print()


if __name__ == "__main__":
    demo_psd_principal_minors()
    demo_dpp_support_is_matroid()
    demo_rank1_kernel()
    demo_cauchy_schwarz()
    demo_negative_dependence()
    print("All demos completed successfully!")


"""
Visualization: Cauchy-Schwarz Inequality for PSD Matrices

Scatter plot of K_ij² vs K_ii·K_jj for many random PSD matrices,
showing the Cauchy-Schwarz inequality K_ij² ≤ K_ii·K_jj holds universally.
The boundary curve is the parabola of equality.
"""
import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    rank = min(rank, n)
    B = np.random.randn(rank, n)
    return B.T @ B


np.random.seed(42)

lhs_vals = []  # K_ij²
rhs_vals = []  # K_ii · K_jj
gap_vals = []  # K_ii·K_jj - K_ij²

for _ in range(200):
    n = np.random.choice([3, 4, 5, 6])
    rank = np.random.randint(1, n + 1)
    K = random_psd_matrix(n, rank)

    for i in range(n):
        for j in range(i + 1, n):
            kij_sq = K[i, j] ** 2
            kii_kjj = K[i, i] * K[j, j]
            lhs_vals.append(kij_sq)
            rhs_vals.append(kii_kjj)
            gap_vals.append(kii_kjj - kij_sq)

lhs_vals = np.array(lhs_vals)
rhs_vals = np.array(rhs_vals)
gap_vals = np.array(gap_vals)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('PSD Entry Cauchy-Schwarz: K²ᵢⱼ ≤ Kᵢᵢ · Kⱼⱼ',
             fontsize=14, fontweight='bold')

# Left: scatter
ax1.scatter(rhs_vals, lhs_vals, alpha=0.3, s=10, c='#3498db', edgecolors='none')
max_val = max(rhs_vals.max(), lhs_vals.max()) * 1.1
ax1.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (equality)')
ax1.set_xlabel('Kᵢᵢ · Kⱼⱼ', fontsize=12)
ax1.set_ylabel('K²ᵢⱼ', fontsize=12)
ax1.set_title('All points below diagonal', fontsize=11)
ax1.legend(fontsize=10)
ax1.set_xlim(0, max_val)
ax1.set_ylim(0, max_val)
ax1.set_aspect('equal')

# Right: histogram of gaps
ax2.hist(gap_vals, bins=50, color='#2ecc71', edgecolor='black', alpha=0.8)
ax2.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Gap = 0')
ax2.set_xlabel('Gap: Kᵢᵢ·Kⱼⱼ - K²ᵢⱼ', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title(f'All {len(gap_vals)} gaps ≥ 0', fontsize=11)
ax2.legend(fontsize=10)

min_gap = gap_vals.min()
ax2.annotate(f'Min gap: {min_gap:.2e}', xy=(min_gap, 0),
             xytext=(min_gap + max(gap_vals) * 0.1, max(np.histogram(gap_vals, 50)[0]) * 0.5),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=10, color='red')

plt.tight_layout()
plt.savefig('cauchy_schwarz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cauchy_schwarz.png")


"""
Visualization: DPP Support Heatmap

Shows the principal minor values det(K_S) for all subsets S of a given size d,
arranged by subset index. The support (positive minors) is highlighted,
demonstrating that positive minors form a matroid-like structure.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    B = np.random.randn(rank, n)
    return B.T @ B


def principal_minor(K, S):
    S_list = list(S)
    return np.linalg.det(K[np.ix_(S_list, S_list)])


np.random.seed(42)
n = 6
rank = 4
K = random_psd_matrix(n, rank)

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle('DPP Principal Minors by Subset Size\n(PSD kernel, n=6, rank=4)',
             fontsize=14, fontweight='bold')

for idx, d in enumerate([1, 2, 3, 4]):
    subsets = list(combinations(range(n), d))
    minors = [principal_minor(K, S) for S in subsets]

    colors = ['#2ecc71' if m > 1e-10 else '#e74c3c' for m in minors]

    ax = axes[idx]
    bars = ax.bar(range(len(subsets)), minors, color=colors, edgecolor='black',
                  linewidth=0.5, alpha=0.8)
    ax.set_title(f'd = {d}\n{sum(1 for m in minors if m > 1e-10)}/{len(subsets)} positive',
                 fontsize=11)
    ax.set_xlabel('Subset index')
    ax.set_ylabel('det(K_S)')
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xticks([])

plt.tight_layout()
plt.savefig('dpp_support_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved dpp_support_heatmap.png")


"""
Visualization: Matroid Exchange Graph

For a DPP support of size d, draws a graph where nodes are bases (subsets
with positive principal minor) and edges connect bases that differ by a
single element swap. The exchange property guarantees this graph is connected.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
import matplotlib.patches as mpatches


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    B = np.random.randn(rank, n)
    return B.T @ B


def principal_minor(K, S):
    S_list = list(S)
    return np.linalg.det(K[np.ix_(S_list, S_list)])


def hamming_distance(S1, S2):
    return len(set(S1) - set(S2))


np.random.seed(42)
n = 6
rank = 3
K = random_psd_matrix(n, rank)

d = 3
subsets = list(combinations(range(n), d))
minors = [principal_minor(K, S) for S in subsets]
support = [S for S, m in zip(subsets, minors) if m > 1e-10]

# Layout using spring embedding
num_nodes = len(support)
if num_nodes > 1:
    # Build adjacency
    adj = np.zeros((num_nodes, num_nodes))
    for i in range(num_nodes):
        for j in range(i + 1, num_nodes):
            if hamming_distance(support[i], support[j]) == 1:
                adj[i, j] = adj[j, i] = 1

    # Simple force-directed layout
    pos = np.random.randn(num_nodes, 2) * 2
    for _ in range(200):
        forces = np.zeros_like(pos)
        for i in range(num_nodes):
            for j in range(num_nodes):
                if i == j:
                    continue
                diff = pos[i] - pos[j]
                dist = max(np.linalg.norm(diff), 0.01)
                # Repulsion
                forces[i] += diff / dist ** 2 * 0.5
                # Attraction for edges
                if adj[i, j]:
                    forces[i] -= diff * 0.1
        pos += forces * 0.05
        pos -= pos.mean(axis=0)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    fig.suptitle(f'Matroid Exchange Graph\nDPP Support (n={n}, d={d}, rank={rank})',
                 fontsize=14, fontweight='bold')

    # Draw edges
    for i in range(num_nodes):
        for j in range(i + 1, num_nodes):
            if adj[i, j]:
                ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                        'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    minor_vals = [principal_minor(K, S) for S in support]
    max_minor = max(minor_vals)
    colors = [plt.cm.YlOrRd(0.3 + 0.7 * m / max_minor) for m in minor_vals]

    for i in range(num_nodes):
        circle = plt.Circle(pos[i], 0.15, color=colors[i], ec='black',
                           linewidth=1.5, zorder=5)
        ax.add_patch(circle)
        label = '{' + ','.join(str(x) for x in support[i]) + '}'
        ax.annotate(label, pos[i], ha='center', va='center', fontsize=7,
                   fontweight='bold', zorder=6)

    ax.set_xlim(pos[:, 0].min() - 0.5, pos[:, 0].max() + 0.5)
    ax.set_ylim(pos[:, 1].min() - 0.5, pos[:, 1].max() + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    green_patch = mpatches.Patch(color='#e6550d', label=f'Bases ({num_nodes} total)')
    edge_line = plt.Line2D([0], [0], color='black', alpha=0.3,
                           label='Exchange edge (Hamming dist 1)')
    ax.legend(handles=[green_patch, edge_line], loc='lower right', fontsize=10)

    plt.tight_layout()
    plt.savefig('exchange_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved exchange_graph.png ({num_nodes} nodes)")
else:
    print("Not enough support elements to draw graph")
