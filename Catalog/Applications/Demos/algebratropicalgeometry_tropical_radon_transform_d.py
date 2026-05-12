"""
Tropical Radon Transform Duality: Demonstrations and Visualizations

This module demonstrates the tropical Radon transform for star trees,
including distance computation, four-point condition verification,
certified reconstruction, and visualization of the duality.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations, product
from typing import List, Tuple, Optional
import json
import base64
from io import BytesIO


# ============================================================
# §1. Tropical Semiring Operations
# ============================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b"""
    return a + b

def tropical_matrix_add(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Pointwise tropical addition (min) of matrices."""
    return np.minimum(A, B)

def tropical_scalar_mul(c: float, A: np.ndarray) -> np.ndarray:
    """Tropical scalar multiplication: add constant to all entries."""
    return c + A


# ============================================================
# §2. Star Tree Distance Function
# ============================================================

class StarTree:
    """A weighted star tree with n leaves and a root.
    
    Vertices: root (index 0), leaves (indices 1..n)
    """
    
    def __init__(self, weights: List[int]):
        """Create a star tree with given edge weights.
        
        Args:
            weights: List of positive edge weights [w_1, ..., w_n]
        """
        assert all(w > 0 for w in weights), "All weights must be positive"
        self.weights = list(weights)
        self.n = len(weights)
    
    def distance(self, u: int, v: int) -> int:
        """Compute distance between vertices u and v.
        
        Vertex 0 is the root; vertices 1..n are leaves.
        """
        if u == v:
            return 0
        if u == 0:
            return self.weights[v - 1]
        if v == 0:
            return self.weights[u - 1]
        return self.weights[u - 1] + self.weights[v - 1]
    
    def distance_matrix(self) -> np.ndarray:
        """Compute the full (n+1) × (n+1) distance matrix."""
        m = self.n + 1
        D = np.zeros((m, m), dtype=int)
        for i in range(m):
            for j in range(m):
                D[i, j] = self.distance(i, j)
        return D
    
    def __repr__(self):
        return f"StarTree(weights={self.weights})"


# ============================================================
# §3. Four-Point Condition Verification
# ============================================================

def check_four_point(D: np.ndarray) -> Tuple[bool, Optional[Tuple]]:
    """Check the four-point condition for a distance matrix.
    
    Returns (True, None) if condition holds, or
    (False, (x, y, z, w, violation_amount)) for first failure.
    """
    m = D.shape[0]
    for x, y, z, w in product(range(m), repeat=4):
        s1 = D[x, y] + D[z, w]
        s2 = D[x, z] + D[y, w]
        s3 = D[x, w] + D[y, z]
        if s1 > max(s2, s3):
            return False, (x, y, z, w, s1 - max(s2, s3))
    return True, None


def check_star_metric(D: np.ndarray, center: int = 0) -> bool:
    """Check if D is a star metric with given center."""
    m = D.shape[0]
    for u in range(m):
        for v in range(m):
            if u != v and u != center and v != center:
                if D[u, v] != D[u, center] + D[center, v]:
                    return False
    return True


def check_separation(D: np.ndarray) -> bool:
    """Check that distinct vertices have distinct distance rows."""
    m = D.shape[0]
    for u in range(m):
        for v in range(u + 1, m):
            if np.array_equal(D[u], D[v]):
                return False
    return True


# ============================================================
# §4. Reconstruction
# ============================================================

def reconstruct_star_weights(D: np.ndarray) -> List[int]:
    """Reconstruct star tree weights from a distance matrix.
    
    The weight of edge i is D[0, i+1] (distance from root to leaf i).
    """
    n = D.shape[0] - 1
    return [int(D[0, i + 1]) for i in range(n)]


def verify_reconstruction(tree: StarTree) -> bool:
    """Verify that reconstruction recovers the original weights."""
    D = tree.distance_matrix()
    recovered = reconstruct_star_weights(D)
    return recovered == tree.weights


# ============================================================
# §5. Tropical Semimodule Operations
# ============================================================

def demonstrate_tropical_semimodule():
    """Demonstrate tropical semimodule properties."""
    print("=" * 60)
    print("Tropical Semimodule Operations")
    print("=" * 60)
    
    T1 = StarTree([2, 5, 3])
    T2 = StarTree([4, 1, 6])
    
    D1 = T1.distance_matrix()
    D2 = T2.distance_matrix()
    
    print(f"\nTree 1: {T1}")
    print(f"Distance matrix:\n{D1}\n")
    
    print(f"Tree 2: {T2}")
    print(f"Distance matrix:\n{D2}\n")
    
    # Tropical addition (pointwise min)
    D_add = tropical_matrix_add(D1, D2)
    print(f"Tropical addition (pointwise min):\n{D_add}\n")
    
    # Commutativity
    D_add_rev = tropical_matrix_add(D2, D1)
    print(f"Commutativity: D1⊕D2 == D2⊕D1? {np.array_equal(D_add, D_add_rev)}")
    
    # Idempotency
    D_idem = tropical_matrix_add(D1, D1)
    print(f"Idempotency: D1⊕D1 == D1? {np.array_equal(D_idem, D1)}")
    
    # Scalar multiplication
    c = 3
    D_smul = tropical_scalar_mul(c, D1)
    print(f"\nTropical scalar multiplication (c={c}):\n{D_smul}")
    
    # Distributivity
    lhs = tropical_scalar_mul(c, tropical_matrix_add(D1, D2))
    rhs = tropical_matrix_add(tropical_scalar_mul(c, D1), tropical_scalar_mul(c, D2))
    print(f"\nDistributivity: c⊗(D1⊕D2) == (c⊗D1)⊕(c⊗D2)? {np.array_equal(lhs, rhs)}")


# ============================================================
# §6. Complete Duality Demonstration
# ============================================================

def demonstrate_duality():
    """Demonstrate the complete tropical Radon duality for star trees."""
    print("=" * 60)
    print("Tropical Radon Duality for Star Trees")
    print("=" * 60)
    
    # Create star trees
    trees = [
        StarTree([2, 5, 3]),
        StarTree([1, 1, 1]),
        StarTree([10, 20, 30, 40]),
        StarTree([7]),
    ]
    
    for tree in trees:
        D = tree.distance_matrix()
        n = tree.n
        
        print(f"\n--- {tree} ---")
        print(f"Distance matrix ({n+1}×{n+1}):")
        print(D)
        
        # Verify metric properties
        print(f"  Self-distance = 0: {all(D[i,i] == 0 for i in range(n+1))}")
        print(f"  Symmetric: {np.array_equal(D, D.T)}")
        
        # Triangle inequality
        tri_ok = True
        for u, v, w in product(range(n+1), repeat=3):
            if D[u, w] > D[u, v] + D[v, w]:
                tri_ok = False
                break
        print(f"  Triangle inequality: {tri_ok}")
        
        # Positive distances
        pos_ok = all(D[u, v] > 0 for u in range(n+1) for v in range(n+1) if u != v)
        print(f"  Positive distances: {pos_ok}")
        
        # Four-point condition
        fp_ok, _ = check_four_point(D)
        print(f"  Four-point condition: {fp_ok}")
        
        # Star metric
        star_ok = check_star_metric(D, center=0)
        print(f"  Star metric (center=0): {star_ok}")
        
        # Separation
        sep_ok = check_separation(D)
        print(f"  Separated: {sep_ok}")
        
        # Reconstruction
        recovered = reconstruct_star_weights(D)
        print(f"  Reconstruction: {recovered}")
        print(f"  Correct: {recovered == tree.weights}")
    
    # Demonstrate faithfulness
    print("\n--- Faithfulness ---")
    T1 = StarTree([2, 5, 3])
    T2 = StarTree([2, 5, 4])  # different last weight
    D1, D2 = T1.distance_matrix(), T2.distance_matrix()
    print(f"T1: {T1.weights}, T2: {T2.weights}")
    print(f"Same distance matrix? {np.array_equal(D1, D2)}")
    print(f"(Different trees always give different matrices)")


# ============================================================
# §7. Visualization
# ============================================================

def create_star_tree_visualization():
    """Create a visualization of a star tree and its distance matrix."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Tree visualization
    ax = axes[0]
    tree = StarTree([2, 5, 3])
    n = tree.n
    
    # Draw root at center
    ax.plot(0, 0, 'ko', markersize=15, zorder=5)
    ax.annotate('Root', (0, 0), textcoords="offset points", 
                xytext=(0, -20), ha='center', fontsize=10, fontweight='bold')
    
    # Draw leaves at equal angles
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    for i in range(n):
        r = tree.weights[i] * 0.3  # scale for visualization
        x = r * np.cos(angles[i])
        y = r * np.sin(angles[i])
        
        # Draw edge
        ax.plot([0, x], [0, y], '-', color=colors[i], linewidth=2)
        
        # Draw leaf
        ax.plot(x, y, 'o', color=colors[i], markersize=12, zorder=5)
        ax.annotate(f'Leaf {i}\n(w={tree.weights[i]})', (x, y), 
                   textcoords="offset points", xytext=(15, 5), fontsize=9)
        
        # Edge weight label
        mx, my = x/2, y/2
        ax.annotate(f'{tree.weights[i]}', (mx, my), 
                   textcoords="offset points", xytext=(10, 5), 
                   fontsize=11, fontweight='bold', color=colors[i])
    
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2, 2.5)
    ax.set_aspect('equal')
    ax.set_title('Star Tree\n(Geometric Object)', fontsize=12, fontweight='bold')
    ax.axis('off')
    
    # Arrow
    axes[1].annotate('', xy=(0.8, 0.5), xytext=(0.2, 0.5),
                    arrowprops=dict(arrowstyle='->', lw=3, color='#8e44ad'))
    axes[1].text(0.5, 0.65, 'Tropical Radon\nTransform', ha='center', 
                fontsize=11, fontweight='bold', color='#8e44ad')
    axes[1].text(0.5, 0.35, 'S ↦ d_S', ha='center', 
                fontsize=13, style='italic', color='#8e44ad')
    axes[1].axis('off')
    axes[1].set_xlim(0, 1)
    axes[1].set_ylim(0, 1)
    
    # Distance matrix
    ax = axes[2]
    D = tree.distance_matrix()
    labels = ['Root', 'L0', 'L1', 'L2']
    
    im = ax.imshow(D, cmap='YlOrRd', aspect='equal')
    ax.set_xticks(range(4))
    ax.set_yticks(range(4))
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_yticklabels(labels, fontsize=10)
    
    for i in range(4):
        for j in range(4):
            ax.text(j, i, str(D[i, j]), ha='center', va='center', 
                   fontsize=14, fontweight='bold',
                   color='white' if D[i, j] > 4 else 'black')
    
    ax.set_title('Distance Matrix\n(Algebraic Data)', fontsize=12, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    plt.suptitle('Tropical Radon Duality: Star Tree ↔ Distance Matrix', 
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    buf = BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    plt.savefig('star_tree_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    return base64.b64encode(buf.read()).decode()


def create_four_point_visualization():
    """Visualize the four-point condition."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    tree = StarTree([2, 5, 3, 4])
    D = tree.distance_matrix()
    
    # Show all three pairwise sums for vertices 1,2,3,4 (leaves)
    leaves = [1, 2, 3, 4]
    sums = []
    labels_list = []
    for perm in [(0,1,2,3), (0,2,1,3), (0,3,1,2)]:
        i, j, k, l = [leaves[p] for p in perm]
        s = D[i, j] + D[k, l]
        sums.append(s)
        labels_list.append(f'd({i},{j})+d({k},{l})')
    
    ax = axes[0]
    colors_bar = ['#e74c3c', '#3498db', '#2ecc71']
    bars = ax.bar(range(3), sums, color=colors_bar, edgecolor='black', linewidth=1.5)
    ax.set_xticks(range(3))
    ax.set_xticklabels(labels_list, fontsize=9)
    ax.set_ylabel('Sum Value', fontsize=11)
    ax.set_title('Four-Point Condition\n(All three sums are equal for star trees)', 
                fontsize=12, fontweight='bold')
    
    for bar, val in zip(bars, sums):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
               str(val), ha='center', fontsize=13, fontweight='bold')
    
    ax.axhline(y=max(sums), color='gray', linestyle='--', alpha=0.5)
    
    # Reconstruction roundtrip
    ax = axes[1]
    n_trials = 20
    max_weight = 50
    errors = []
    
    for _ in range(n_trials):
        weights = [np.random.randint(1, max_weight + 1) for _ in range(5)]
        T = StarTree(weights)
        D_test = T.distance_matrix()
        recovered = reconstruct_star_weights(D_test)
        error = sum(abs(w - r) for w, r in zip(weights, recovered))
        errors.append(error)
    
    ax.bar(range(n_trials), errors, color='#2ecc71', edgecolor='black')
    ax.set_xlabel('Trial', fontsize=11)
    ax.set_ylabel('Reconstruction Error', fontsize=11)
    ax.set_title(f'Reconstruction Accuracy\n({n_trials} random star trees, all errors = 0)', 
                fontsize=12, fontweight='bold')
    ax.set_ylim(-0.5, 2)
    
    plt.tight_layout()
    buf = BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    plt.savefig('four_point_reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    return base64.b64encode(buf.read()).decode()


# ============================================================
# §8. Main Demo
# ============================================================

if __name__ == "__main__":
    print("Tropical Radon Transform Duality — Demo\n")
    
    # Run demonstrations
    demonstrate_duality()
    print()
    demonstrate_tropical_semimodule()
    
    # Create visualizations
    print("\n\nGenerating visualizations...")
    img1 = create_star_tree_visualization()
    img2 = create_four_point_visualization()
    print(f"Saved: star_tree_duality.png")
    print(f"Saved: four_point_reconstruction.png")
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)
