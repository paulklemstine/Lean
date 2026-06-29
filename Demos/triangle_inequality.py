"""
Applications of the Orbit Cost Triangle Inequality

Demonstrates real-world applications in:
1. Point cloud matching (3D shape comparison)
2. Molecular similarity under rotation
3. Nearest-neighbor retrieval with symmetry
4. Clustering of symmetric objects
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple


# ============================================================================
# Application 1: Point Cloud Matching
# ============================================================================

def point_cloud_orbit_cost(
    cloud1: np.ndarray,
    cloud2: np.ndarray,
    metric: str = 'l2'
) -> Tuple[float, np.ndarray]:
    """
    Compare two point clouds up to permutation of point labels.

    This is the "assignment problem" formulation: find the optimal
    correspondence between points in the two clouds.

    Parameters
    ----------
    cloud1, cloud2 : ndarray of shape (n, d)
        Two point clouds with n points in d dimensions
    metric : str
        'l1' or 'l2' for the per-point cost

    Returns
    -------
    cost : float
        Orbit cost (optimal matching cost)
    perm : ndarray
        Optimal permutation
    """
    from scipy.optimize import linear_sum_assignment

    n = len(cloud1)
    assert len(cloud2) == n, "Point clouds must have same size"

    if metric == 'l1':
        C = np.sum(np.abs(cloud1[:, None, :] - cloud2[None, :, :]), axis=-1)
    elif metric == 'l2':
        C = np.sqrt(np.sum((cloud1[:, None, :] - cloud2[None, :, :]) ** 2, axis=-1))
    else:
        raise ValueError(f"Unknown metric: {metric}")

    row_ind, col_ind = linear_sum_assignment(C)
    cost = C[row_ind, col_ind].sum()

    perm = np.zeros(n, dtype=int)
    perm[row_ind] = col_ind

    return cost, perm


def demo_point_cloud():
    """Demonstrate point cloud matching."""
    print("=" * 70)
    print("APPLICATION 1: Point Cloud Matching")
    print("=" * 70)

    np.random.seed(42)

    # Generate three point clouds: two similar, one different
    n_points = 10
    d = 3

    # Cloud A: random
    A = np.random.randn(n_points, d)

    # Cloud B: shuffled and noisy version of A
    perm = np.random.permutation(n_points)
    B = A[perm] + 0.1 * np.random.randn(n_points, d)

    # Cloud C: completely different
    C = 3.0 * np.random.randn(n_points, d)

    d_AB, _ = point_cloud_orbit_cost(A, B)
    d_BC, _ = point_cloud_orbit_cost(B, C)
    d_AC, _ = point_cloud_orbit_cost(A, C)

    print(f"\nCloud A: {n_points} random points in ℝ³")
    print(f"Cloud B: shuffled + noisy version of A")
    print(f"Cloud C: independent random points")
    print(f"\norbitCost(A, B) = {d_AB:.4f}  (small — similar clouds)")
    print(f"orbitCost(A, C) = {d_AC:.4f}  (large — different clouds)")
    print(f"orbitCost(B, C) = {d_BC:.4f}")
    print(f"\nTriangle inequality: {d_AC:.4f} ≤ {d_AB:.4f} + {d_BC:.4f} = {d_AB + d_BC:.4f}")
    print(f"Verified: {d_AC <= d_AB + d_BC + 1e-10}")


# ============================================================================
# Application 2: Nearest-Neighbor Retrieval with Triangle Inequality Pruning
# ============================================================================

class OrbitCostIndex:
    """
    A simple ball-tree-like index for orbit-cost nearest neighbor search.

    The triangle inequality enables pruning: if we know d(q, p) and d(p, x),
    we can lower-bound d(q, x) >= |d(q, p) - d(p, x)|, allowing us to
    skip candidates that cannot possibly be closer than the current best.
    """

    def __init__(self, database: List[np.ndarray], cost_fn):
        """
        Parameters
        ----------
        database : list of ndarray
            Objects to index
        cost_fn : callable
            Orbit cost function (x, y) -> float
        """
        self.database = database
        self.cost_fn = cost_fn
        self.n = len(database)

        # Precompute pivot distances
        self.pivot = database[0]
        self.pivot_dists = np.array([cost_fn(self.pivot, x) for x in database])

    def query(self, q: np.ndarray, k: int = 1) -> List[Tuple[int, float]]:
        """
        Find k-nearest neighbors using triangle inequality pruning.

        Returns list of (index, distance) pairs.
        """
        d_q_pivot = self.cost_fn(q, self.pivot)

        # Sort candidates by |d(q, pivot) - d(x, pivot)| (lower bound)
        lower_bounds = np.abs(d_q_pivot - self.pivot_dists)
        candidates = np.argsort(lower_bounds)

        results = []
        best_k_dist = float('inf')
        n_evaluated = 0

        for idx in candidates:
            if lower_bounds[idx] > best_k_dist:
                break  # Triangle inequality pruning!

            d = self.cost_fn(q, self.database[idx])
            n_evaluated += 1
            results.append((idx, d))
            results.sort(key=lambda x: x[1])
            results = results[:k]
            if len(results) == k:
                best_k_dist = results[-1][1]

        return results, n_evaluated


def demo_nearest_neighbor():
    """Demonstrate triangle-inequality-based pruning for NN search."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Nearest Neighbor with Triangle Inequality Pruning")
    print("=" * 70)

    np.random.seed(42)
    n_db = 200
    n_dim = 4

    # Database of vectors, compared up to sorting (permutation orbit)
    database = [np.random.randn(n_dim) for _ in range(n_db)]

    def orbit_cost_sorted(x, y):
        """Orbit cost under permutation = L1 distance of sorted vectors."""
        return np.sum(np.abs(np.sort(x) - np.sort(y)))

    index = OrbitCostIndex(database, orbit_cost_sorted)

    # Query
    query = np.random.randn(n_dim)
    results, n_eval = index.query(query, k=5)

    # Brute force for comparison
    all_dists = [(i, orbit_cost_sorted(query, x)) for i, x in enumerate(database)]
    all_dists.sort(key=lambda x: x[1])
    brute_results = all_dists[:5]

    print(f"\nDatabase: {n_db} vectors in ℝ⁴")
    print(f"Orbit cost: permutation-invariant L1")
    print(f"\nPruned search: evaluated {n_eval}/{n_db} candidates "
          f"({100 * n_eval / n_db:.1f}%)")
    print(f"\nTop-5 results (pruned):")
    for idx, d in results:
        print(f"  index={idx:3d}, distance={d:.4f}")
    print(f"\nTop-5 results (brute force):")
    for idx, d in brute_results:
        print(f"  index={idx:3d}, distance={d:.4f}")

    # Verify match
    pruned_indices = set(r[0] for r in results)
    brute_indices = set(r[0] for r in brute_results)
    print(f"\nResults match: {pruned_indices == brute_indices}")


# ============================================================================
# Application 3: Clustering with Orbit Distance
# ============================================================================

def demo_clustering():
    """Demonstrate k-medoids clustering with orbit cost."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Clustering with Orbit Distance")
    print("=" * 70)

    np.random.seed(42)
    n_points = 30
    n_dim = 3

    # Generate 3 clusters with internal permutation variety
    cluster_centers = [
        np.array([1.0, 2.0, 3.0]),
        np.array([10.0, 11.0, 12.0]),
        np.array([5.0, -5.0, 0.0]),
    ]

    data = []
    true_labels = []
    for c_idx, center in enumerate(cluster_centers):
        for _ in range(n_points // 3):
            # Random permutation of center + noise
            perm = np.random.permutation(n_dim)
            point = center[perm] + 0.3 * np.random.randn(n_dim)
            data.append(point)
            true_labels.append(c_idx)

    def orbit_dist(x, y):
        return np.sum(np.abs(np.sort(x) - np.sort(y)))

    # Compute pairwise distance matrix
    n = len(data)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = orbit_dist(data[i], data[j])
            D[i, j] = d
            D[j, i] = d

    # Simple k-medoids (PAM-like)
    k = 3
    medoids = [0, n_points // 3, 2 * n_points // 3]  # Initial

    for iteration in range(20):
        # Assign each point to nearest medoid
        labels = np.argmin(D[:, medoids], axis=1)

        # Update medoids
        new_medoids = []
        for c in range(k):
            cluster = np.where(labels == c)[0]
            if len(cluster) == 0:
                new_medoids.append(medoids[c])
                continue
            intra_dists = D[np.ix_(cluster, cluster)].sum(axis=1)
            best = cluster[np.argmin(intra_dists)]
            new_medoids.append(best)

        if new_medoids == medoids:
            break
        medoids = new_medoids

    # Evaluate
    labels = np.argmin(D[:, medoids], axis=1)
    print(f"\n{n} points in ℝ³, 3 clusters (permuted + noisy)")
    print(f"k-medoids with orbit distance converged in {iteration + 1} iterations")
    print(f"\nCluster sizes: {[np.sum(labels == c) for c in range(k)]}")
    print(f"True labels:      {true_labels}")
    print(f"Predicted labels: {labels.tolist()}")

    # Check if clustering is correct (up to label permutation)
    from itertools import permutations as label_perms
    best_acc = 0
    for perm in label_perms(range(k)):
        remapped = [perm[l] for l in labels]
        acc = sum(r == t for r, t in zip(remapped, true_labels)) / n
        best_acc = max(best_acc, acc)
    print(f"Clustering accuracy (best label matching): {best_acc:.1%}")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_point_cloud()
    demo_nearest_neighbor()
    demo_clustering()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


"""
Orbit Cost Triangle Inequality: Numerical Demonstrations

This module demonstrates the orbit-cost construction and triangle inequality
with concrete numerical examples across several domains:
1. Permutation group on vectors (sorting-invariant distance)
2. Cyclic rotation group on sequences
3. Graph matching via adjacency matrix permutation
"""

import numpy as np
from itertools import permutations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================================
# Core orbit cost computation
# ============================================================================

def orbit_cost(Wc, mu, nu, group_elements, action):
    """
    Compute orbitCost = inf_{g in G} Wc(mu, g . nu)

    Parameters
    ----------
    Wc : callable, cost function (mu, nu) -> float
    mu, nu : objects in alpha
    group_elements : iterable of group elements
    action : callable, (g, x) -> g . x

    Returns
    -------
    float : the orbit cost
    """
    costs = [Wc(mu, action(g, nu)) for g in group_elements]
    return min(costs)


def orbit_cost_with_witness(Wc, mu, nu, group_elements, action):
    """Compute orbit cost and return the optimal group element."""
    best_cost = float('inf')
    best_g = None
    for g in group_elements:
        c = Wc(mu, action(g, nu))
        if c < best_cost:
            best_cost = c
            best_g = g
    return best_cost, best_g


# ============================================================================
# Demo 1: Permutation-invariant vector distance
# ============================================================================

def demo_permutation_vectors():
    """
    G = S_n (symmetric group) acting on R^n by coordinate permutation.
    Wc = L1 distance.
    orbitCost compares vectors up to reordering (i.e., as multisets).
    """
    print("=" * 70)
    print("DEMO 1: Permutation-Invariant Vector Distance")
    print("=" * 70)

    n = 4
    # Three vectors
    mu = np.array([1.0, 3.0, 5.0, 7.0])
    nu = np.array([7.0, 5.0, 1.0, 3.0])  # permutation of mu
    rho = np.array([2.0, 4.0, 6.0, 8.0])

    # L1 cost
    def Wc(x, y):
        return np.sum(np.abs(x - y))

    # Permutation action
    perms = list(permutations(range(n)))
    def action(sigma, x):
        return x[list(sigma)]

    # Compute orbit costs
    d_mu_nu = orbit_cost(Wc, mu, nu, perms, action)
    d_nu_rho = orbit_cost(Wc, nu, rho, perms, action)
    d_mu_rho = orbit_cost(Wc, mu, rho, perms, action)

    print(f"\nmu  = {mu}")
    print(f"nu  = {nu}")
    print(f"rho = {rho}")
    print(f"\norbitCost(mu, nu)  = {d_mu_nu:.4f}")
    print(f"orbitCost(nu, rho) = {d_nu_rho:.4f}")
    print(f"orbitCost(mu, rho) = {d_mu_rho:.4f}")
    print(f"\nTriangle inequality check:")
    print(f"  d(mu,rho) = {d_mu_rho:.4f}")
    print(f"  d(mu,nu) + d(nu,rho) = {d_mu_nu + d_nu_rho:.4f}")
    print(f"  Satisfied: {d_mu_rho <= d_mu_nu + d_nu_rho + 1e-10}")

    # Note: mu and nu are permutations of each other, so d(mu,nu) = 0
    print(f"\n  mu and nu are permutations of each other => d(mu,nu) = {d_mu_nu}")

    return d_mu_rho, d_mu_nu + d_nu_rho


# ============================================================================
# Demo 2: Cyclic rotation group on sequences
# ============================================================================

def demo_cyclic_rotation():
    """
    G = Z/nZ acting on R^n by cyclic rotation.
    This is relevant for comparing periodic signals.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Cyclic Rotation-Invariant Distance")
    print("=" * 70)

    n = 8
    # Three periodic signals
    t = np.linspace(0, 2 * np.pi, n, endpoint=False)
    mu = np.sin(t)
    nu = np.sin(t + 1.0)  # phase-shifted
    rho = np.sin(t) + 0.5 * np.cos(2 * t)

    # L2 cost
    def Wc(x, y):
        return np.sqrt(np.sum((x - y) ** 2))

    # Cyclic rotation action
    rotations = list(range(n))
    def action(k, x):
        return np.roll(x, k)

    d_mu_nu = orbit_cost(Wc, mu, nu, rotations, action)
    d_nu_rho = orbit_cost(Wc, nu, rho, rotations, action)
    d_mu_rho = orbit_cost(Wc, mu, rho, rotations, action)

    print(f"\nmu  = sin(t)")
    print(f"nu  = sin(t + 1)")
    print(f"rho = sin(t) + 0.5*cos(2t)")
    print(f"\norbitCost(mu, nu)  = {d_mu_nu:.4f}")
    print(f"orbitCost(nu, rho) = {d_nu_rho:.4f}")
    print(f"orbitCost(mu, rho) = {d_mu_rho:.4f}")
    print(f"\nTriangle inequality check:")
    print(f"  d(mu,rho) = {d_mu_rho:.4f}")
    print(f"  d(mu,nu) + d(nu,rho) = {d_mu_nu + d_nu_rho:.4f}")
    print(f"  Satisfied: {d_mu_rho <= d_mu_nu + d_nu_rho + 1e-10}")

    return d_mu_rho, d_mu_nu + d_nu_rho


# ============================================================================
# Demo 3: Graph matching
# ============================================================================

def demo_graph_matching():
    """
    G = S_n acting on n×n adjacency matrices by conjugation:
      (sigma . A)_{ij} = A_{sigma^{-1}(i), sigma^{-1}(j)}
    Wc = Frobenius norm of difference.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Graph Matching Distance")
    print("=" * 70)

    n = 4
    # Three graphs (adjacency matrices)
    # Graph 1: path 0-1-2-3
    A = np.zeros((n, n))
    A[0, 1] = A[1, 0] = 1
    A[1, 2] = A[2, 1] = 1
    A[2, 3] = A[3, 2] = 1

    # Graph 2: path 2-0-3-1 (isomorphic to A under permutation)
    B = np.zeros((n, n))
    B[2, 0] = B[0, 2] = 1
    B[0, 3] = B[3, 0] = 1
    B[3, 1] = B[1, 3] = 1

    # Graph 3: star with center 0
    C = np.zeros((n, n))
    C[0, 1] = C[1, 0] = 1
    C[0, 2] = C[2, 0] = 1
    C[0, 3] = C[3, 0] = 1

    # Frobenius cost
    def Wc(X, Y):
        return np.linalg.norm(X - Y, 'fro')

    # Conjugation action
    perms = list(permutations(range(n)))
    def action(sigma, X):
        P = np.zeros((n, n))
        for i, si in enumerate(sigma):
            P[i, si] = 1
        return P @ X @ P.T

    d_AB = orbit_cost(Wc, A, B, perms, action)
    d_BC = orbit_cost(Wc, B, C, perms, action)
    d_AC = orbit_cost(Wc, A, C, perms, action)

    print(f"\nGraph A: path 0-1-2-3")
    print(f"Graph B: path 2-0-3-1 (isomorphic to A)")
    print(f"Graph C: star with center 0")
    print(f"\norbitCost(A, B) = {d_AB:.4f}  (should be ≈0, isomorphic)")
    print(f"orbitCost(B, C) = {d_BC:.4f}")
    print(f"orbitCost(A, C) = {d_AC:.4f}")
    print(f"\nTriangle inequality check:")
    print(f"  d(A,C) = {d_AC:.4f}")
    print(f"  d(A,B) + d(B,C) = {d_AB + d_BC:.4f}")
    print(f"  Satisfied: {d_AC <= d_AB + d_BC + 1e-10}")

    return d_AC, d_AB + d_BC


# ============================================================================
# Demo 4: Triangle inequality stress test
# ============================================================================

def demo_stress_test():
    """
    Randomly sample many triples and verify triangle inequality holds.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Monte Carlo Triangle Inequality Verification")
    print("=" * 70)

    n = 3
    perms = list(permutations(range(n)))
    def Wc(x, y):
        return np.sum(np.abs(x - y))
    def action(sigma, x):
        return x[list(sigma)]

    np.random.seed(42)
    n_tests = 10000
    violations = 0
    max_slack = 0.0

    for _ in range(n_tests):
        mu = np.random.randn(n)
        nu = np.random.randn(n)
        rho = np.random.randn(n)

        d_mr = orbit_cost(Wc, mu, rho, perms, action)
        d_mn = orbit_cost(Wc, mu, nu, perms, action)
        d_nr = orbit_cost(Wc, nu, rho, perms, action)

        slack = d_mn + d_nr - d_mr
        max_slack = max(max_slack, slack)
        if d_mr > d_mn + d_nr + 1e-10:
            violations += 1

    print(f"\n{n_tests} random triples tested (n={n}, L1 cost, S_{n} action)")
    print(f"Violations: {violations}")
    print(f"Maximum slack (d(μ,ν) + d(ν,ρ) - d(μ,ρ)): {max_slack:.6f}")
    print(f"Triangle inequality holds in all cases: {violations == 0}")


# ============================================================================
# Visualization
# ============================================================================

def create_visualizations():
    """Generate visualizations of the orbit cost construction."""

    # Figure 1: Composition of witnesses
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: The orbit of a point
    n_pts = 8
    theta = np.linspace(0, 2 * np.pi, n_pts, endpoint=False)
    orbit_x = np.cos(theta)
    orbit_y = np.sin(theta)

    axes[0].scatter(orbit_x, orbit_y, c='steelblue', s=100, zorder=5)
    axes[0].scatter([0], [0], c='red', s=150, marker='*', zorder=5, label='μ')
    for i in range(n_pts):
        axes[0].annotate(f'g_{i}·ν', (orbit_x[i], orbit_y[i]),
                        textcoords="offset points", xytext=(10, 5), fontsize=8)
    axes[0].set_title('Orbit of ν under G', fontsize=13)
    axes[0].set_xlabel('Dimension 1')
    axes[0].set_ylabel('Dimension 2')
    axes[0].legend()
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Triangle inequality mechanism
    pts = {'μ': (0, 0), 'g₁·ν': (2, 1.5), '(g₁g₂)·ρ': (4, 0.5)}
    for name, (x, y) in pts.items():
        axes[1].scatter([x], [y], s=150, zorder=5)
        axes[1].annotate(name, (x, y), textcoords="offset points",
                        xytext=(10, 10), fontsize=12, fontweight='bold')

    # Draw triangle
    xs = [0, 2, 4, 0]
    ys = [0, 1.5, 0.5, 0]
    axes[1].plot(xs[:2], ys[:2], 'b-', linewidth=2, label='Wc(μ, g₁·ν)')
    axes[1].plot(xs[1:3], ys[1:3], 'g-', linewidth=2, label='Wc(g₁·ν, (g₁g₂)·ρ) = Wc(ν, g₂·ρ)')
    axes[1].plot([xs[0], xs[2]], [ys[0], ys[2]], 'r--', linewidth=2, label='Wc(μ, (g₁g₂)·ρ)')
    axes[1].set_title('Composition of Witnesses', fontsize=13)
    axes[1].legend(fontsize=9)
    axes[1].set_aspect('equal')
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Triangle inequality slack distribution
    n_dim = 3
    perms = list(permutations(range(n_dim)))
    def Wc(x, y):
        return np.sum(np.abs(x - y))
    def action(sigma, x):
        return x[list(sigma)]

    np.random.seed(42)
    slacks = []
    for _ in range(2000):
        mu = np.random.randn(n_dim)
        nu = np.random.randn(n_dim)
        rho = np.random.randn(n_dim)
        d_mr = orbit_cost(Wc, mu, rho, perms, action)
        d_mn = orbit_cost(Wc, mu, nu, perms, action)
        d_nr = orbit_cost(Wc, nu, rho, perms, action)
        slacks.append(d_mn + d_nr - d_mr)

    axes[2].hist(slacks, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    axes[2].axvline(x=0, color='red', linestyle='--', linewidth=2, label='Tightness bound')
    axes[2].set_xlabel('d(μ,ν) + d(ν,ρ) − d(μ,ρ)', fontsize=11)
    axes[2].set_ylabel('Frequency', fontsize=11)
    axes[2].set_title('Triangle Inequality Slack', fontsize=13)
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('orbit_cost_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: orbit_cost_visualization.png")

    # Figure 2: Cost landscape over group elements
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    n_dim = 4
    mu = np.array([1.0, 2.0, 3.0, 4.0])
    nu = np.array([4.5, 1.5, 3.5, 2.5])
    perms_4 = list(permutations(range(n_dim)))

    costs = [np.sum(np.abs(mu - nu[list(p)])) for p in perms_4]
    costs_sorted = sorted(costs)

    ax.bar(range(len(costs_sorted)), costs_sorted, color='steelblue', alpha=0.7)
    ax.axhline(y=min(costs), color='red', linestyle='--', linewidth=2,
               label=f'orbitCost = {min(costs):.2f}')
    ax.set_xlabel('Permutation index (sorted by cost)', fontsize=11)
    ax.set_ylabel('Wc(μ, σ·ν)', fontsize=11)
    ax.set_title('Cost Landscape over S₄', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('cost_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cost_landscape.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_permutation_vectors()
    demo_cyclic_rotation()
    demo_graph_matching()
    demo_stress_test()
    create_visualizations()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("The triangle inequality was verified in every case.")
    print("=" * 70)
