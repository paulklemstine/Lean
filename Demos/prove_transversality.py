"""
Applications of Tropical Transversality
=========================================
Demonstrates real-world applications of max-affine corner locus theory
to neural networks, optimization, and tropical geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import Set, Tuple


# --------------------------------------------------------------------------
# Application 1: ReLU Network Decision Boundaries
# --------------------------------------------------------------------------

def relu_network_boundaries():
    """
    Demonstrate that ReLU network decision boundaries are corner loci
    of max-affine functions.

    A single-hidden-layer ReLU network with k neurons computes:
        f(x) = sum_j v_j * max(0, w_j · x + b_j)
    
    The activation pattern changes at hyperplanes w_j · x + b_j = 0,
    which are exactly the corner loci of the functions
    {0, w_j · x + b_j} for each neuron j.
    """
    print("="*60)
    print("APPLICATION 1: ReLU Network Activation Boundaries")
    print("="*60)

    # Simple 2D network with 4 neurons
    W = np.array([[1.0, 0.5],
                  [-0.5, 1.0],
                  [0.8, -0.3],
                  [-0.2, -0.8]])
    biases = np.array([0.5, -0.3, 0.2, 0.1])
    v = np.array([1.0, -0.5, 0.8, -0.3])  # output weights

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    xs = np.linspace(-3, 3, 300)
    ys = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(xs, ys)

    # Compute network output and activation patterns
    Z = np.zeros_like(X)
    Pattern = np.zeros_like(X, dtype=int)
    for i in range(len(xs)):
        for j in range(len(ys)):
            pt = np.array([X[j, i], Y[j, i]])
            pre_activations = W @ pt + biases
            activations = np.maximum(0, pre_activations)
            Z[j, i] = v @ activations
            # Encode activation pattern as binary number
            Pattern[j, i] = sum(2**k for k in range(4) if pre_activations[k] > 0)

    # Left: activation regions
    ax = axes[0]
    ax.contourf(X, Y, Pattern, levels=np.arange(-0.5, 17, 1),
                cmap='Set3', alpha=0.5)

    # Draw activation boundaries (corner loci)
    for k in range(4):
        dw = W[k]
        db = -biases[k]
        if abs(dw[0]) > abs(dw[1]):
            ys_line = np.linspace(-3, 3, 200)
            xs_line = (db - dw[1] * ys_line) / dw[0]
        else:
            xs_line = np.linspace(-3, 3, 200)
            ys_line = (db - dw[0] * xs_line) / dw[1]
        mask = (np.abs(xs_line) <= 3.5) & (np.abs(ys_line) <= 3.5)
        ax.plot(xs_line[mask], ys_line[mask], 'k-', linewidth=1.5,
                label=f'Neuron {k+1}' if k < 4 else '')

    ax.set_title('ReLU Activation Regions\n(= tropical arrangement)', fontsize=11)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(fontsize=8)

    # Right: network output with level curves
    ax = axes[1]
    cf = ax.contourf(X, Y, Z, levels=20, cmap='RdYlBu_r', alpha=0.7)
    plt.colorbar(cf, ax=ax, label='Network output')

    # Overlay activation boundaries
    for k in range(4):
        dw = W[k]
        db = -biases[k]
        if abs(dw[0]) > abs(dw[1]):
            ys_line = np.linspace(-3, 3, 200)
            xs_line = (db - dw[1] * ys_line) / dw[0]
        else:
            xs_line = np.linspace(-3, 3, 200)
            ys_line = (db - dw[0] * xs_line) / dw[1]
        mask = (np.abs(xs_line) <= 3.5) & (np.abs(ys_line) <= 3.5)
        ax.plot(xs_line[mask], ys_line[mask], 'k--', linewidth=1, alpha=0.5)

    ax.set_title('Network Output\n(piecewise linear)', fontsize=11)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('relu_boundaries.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: relu_boundaries.png")

    # Count activation regions
    unique_patterns = len(set(Pattern.flatten()))
    print(f"Number of distinct activation patterns: {unique_patterns}")
    print(f"Number of neurons: 4")
    print(f"By transversality, generic biases produce the maximum number")
    print(f"of distinct regions consistent with the arrangement.")


# --------------------------------------------------------------------------
# Application 2: Certified Optimization
# --------------------------------------------------------------------------

def certified_optimization():
    """
    Demonstrate certified optimization on max-affine objectives.

    For f(x) = max_i ℓ_i(x), minimization over a polytope can be
    decomposed into optimization over each active stratum.
    Transversality ensures isolated optima on each stratum.
    """
    print("\n" + "="*60)
    print("APPLICATION 2: Certified Optimization")
    print("="*60)

    # Minimize f(x) = max(x₁, x₂, -x₁-x₂+3) over [-1,4]²
    w = np.array([[1.0, 0.0],
                  [0.0, 1.0],
                  [-1.0, -1.0]])
    b = np.array([0.0, 0.0, 3.0])

    # The minimum of f occurs where the active strata interact with
    # the feasible region boundary or at interior tie points.

    # Find all pairwise tie lines
    print("\nPairwise tie lines:")
    for i, j in combinations(range(3), 2):
        dw = w[i] - w[j]
        db = b[j] - b[i]
        print(f"  ℓ_{i} = ℓ_{j}: {dw[0]:.1f}x₁ + {dw[1]:.1f}x₂ = {db:.1f}")

    # Triple tie point
    A = np.array([w[0] - w[1], w[0] - w[2]])
    rhs = np.array([b[1] - b[0], b[2] - b[0]])
    triple_pt = np.linalg.solve(A, rhs)
    print(f"\nTriple tie point: ({triple_pt[0]:.2f}, {triple_pt[1]:.2f})")
    print(f"  f value at triple point: {max(w[i] @ triple_pt + b[i] for i in range(3)):.2f}")

    # The minimum of max(x₁, x₂, -x₁-x₂+3) is at x₁=x₂=1 where all three are equal to 1
    print(f"\nOptimal point: (1.00, 1.00)")
    print(f"Optimal value: 1.00")
    print(f"This is the triple tie point — the corner locus vertex!")
    print(f"\nThe transversality theorem guarantees:")
    print(f"  - This is an isolated critical point of codimension 2")
    print(f"  - Generic linear perturbations have unique minimizers")

    # Verify with a grid search
    best_val = float('inf')
    best_pt = None
    for x1 in np.linspace(-1, 4, 1000):
        for x2 in np.linspace(-1, 4, 1000):
            val = max(x1, x2, -x1 - x2 + 3)
            if val < best_val:
                best_val = val
                best_pt = (x1, x2)
    print(f"\nGrid search verification: optimal ≈ ({best_pt[0]:.3f}, {best_pt[1]:.3f}), value ≈ {best_val:.3f}")


# --------------------------------------------------------------------------
# Application 3: Tropical Polynomial Roots
# --------------------------------------------------------------------------

def tropical_geometry():
    """
    Connect max-affine corner loci to tropical algebraic geometry.

    A tropical polynomial p(x) = max_i (a_i + i·x) has "roots"
    (corner points) where adjacent linear pieces meet.
    The transversality theorem tells us when these roots are simple.
    """
    print("\n" + "="*60)
    print("APPLICATION 3: Tropical Polynomial Roots")
    print("="*60)

    # Tropical polynomial: p(x) = max(a_0, a_1 + x, a_2 + 2x, a_3 + 3x)
    # This is a 1D max-affine function with slopes 0, 1, 2, 3
    coeffs = np.array([0.0, 1.5, 0.5, -2.0])

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: the tropical polynomial
    ax = axes[0]
    xs = np.linspace(-3, 4, 1000)
    pieces = np.array([coeffs[i] + i * xs for i in range(4)])
    envelope = np.max(pieces, axis=0)

    for i in range(4):
        ax.plot(xs, pieces[i], '--', alpha=0.4, label=f'$a_{i} + {i}x$')
    ax.plot(xs, envelope, 'k-', linewidth=2.5, label='$p(x) = \\max$')

    # Find tropical roots (corner points)
    roots = []
    for i in range(3):
        # Intersection of line i and line i+1: a_i + i*x = a_{i+1} + (i+1)*x
        # x = a_i - a_{i+1}
        root = coeffs[i] - coeffs[i+1]
        val = coeffs[i] + i * root
        # Check if this is actually on the envelope
        if all(coeffs[j] + j * root <= val + 1e-10 for j in range(4)):
            roots.append((root, val))
            ax.plot(root, val, 'ro', markersize=10, zorder=10)

    ax.set_title('Tropical Polynomial (1D)', fontsize=12)
    ax.set_xlabel('$x$')
    ax.set_ylabel('$p(x)$')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    print(f"\nTropical polynomial: p(x) = max(0, 1.5+x, 0.5+2x, -2+3x)")
    print(f"Tropical roots (corner points):")
    for root, val in roots:
        print(f"  x = {root:.2f}, p(x) = {val:.2f}")

    # Right: 2D tropical curve
    ax = axes[1]

    # Tropical curve: max(0, x, y, x+y-2)
    w2d = np.array([[0, 0], [1, 0], [0, 1], [1, 1]])
    b2d = np.array([0, 0, 0, -2])

    xs2 = np.linspace(-3, 3, 400)
    ys2 = np.linspace(-3, 3, 400)
    X, Y = np.meshgrid(xs2, ys2)
    Active = np.zeros_like(X, dtype=int)

    for i in range(len(xs2)):
        for j in range(len(ys2)):
            pt = np.array([X[j, i], Y[j, i]])
            vals = [w2d[k] @ pt + b2d[k] for k in range(4)]
            Active[j, i] = np.argmax(vals)

    colors = ['#FFB3BA', '#BAFFC9', '#BAE1FF', '#FFFFBA']
    for k in range(4):
        mask = (Active == k).astype(float)
        ax.contourf(X, Y, mask, levels=[0.5, 1.5], colors=[colors[k]], alpha=0.4)

    # Draw the tropical curve (corner locus)
    for i, j in combinations(range(4), 2):
        dw = w2d[i] - w2d[j]
        db = b2d[j] - b2d[i]
        norm = np.linalg.norm(dw)
        if norm < 1e-10:
            continue
        if abs(dw[0]) > abs(dw[1]):
            ys_line = np.linspace(-3, 3, 500)
            xs_line = (db - dw[1] * ys_line) / dw[0]
        else:
            xs_line = np.linspace(-3, 3, 500)
            ys_line = (db - dw[0] * xs_line) / dw[1]
        mask = (np.abs(xs_line) <= 3.5) & (np.abs(ys_line) <= 3.5)

        # Only draw segments on the actual corner locus
        corner_mask = []
        for idx in range(len(xs_line)):
            if mask[idx]:
                pt = np.array([xs_line[idx], ys_line[idx]])
                vals = [w2d[k] @ pt + b2d[k] for k in range(4)]
                mx = max(vals)
                active = {k for k, v in enumerate(vals) if abs(v - mx) < 0.05}
                corner_mask.append(i in active and j in active)
            else:
                corner_mask.append(False)
        corner_mask = np.array(corner_mask)

        if np.any(corner_mask):
            ax.plot(xs_line[corner_mask], ys_line[corner_mask],
                    'r-', linewidth=2)

    ax.set_title('Tropical Curve in $\\mathbb{R}^2$\n$\\max(0, x, y, x+y-2)$', fontsize=11)
    ax.set_xlabel('$x$')
    ax.set_ylabel('$y$')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_applications.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: tropical_applications.png")


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

if __name__ == '__main__':
    relu_network_boundaries()
    certified_optimization()
    tropical_geometry()

    print("\n" + "="*60)
    print("All applications completed.")
    print("="*60)


"""
Tropical Transversality Demo
=============================
Demonstrates the geometry of max-affine corner loci and tie strata
using concrete numerical examples in 2D and 3D.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations

# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

def affine_fun(w, b, i, x):
    """ℓ_i(x) = ⟨w_i, x⟩ + b_i"""
    return np.dot(w[i], x) + b[i]

def max_affine(w, b, x):
    """f(x) = max_i ℓ_i(x)"""
    return max(affine_fun(w, b, i, x) for i in range(len(w)))

def active_set(w, b, x, tol=1e-10):
    """Indices achieving the maximum at x."""
    vals = [affine_fun(w, b, i, x) for i in range(len(w))]
    mx = max(vals)
    return {i for i, v in enumerate(vals) if abs(v - mx) < tol}

def is_corner(w, b, x, tol=1e-10):
    """True if x is in the corner locus (≥2 active indices)."""
    return len(active_set(w, b, x, tol)) >= 2

def tie_set_direction(w, s, i0):
    """
    Compute the direction (kernel) of the tie set for index set s
    with pivot i0. Returns basis vectors spanning ker(diffMap).
    """
    s_list = sorted(s - {i0})
    if not s_list:
        return np.eye(w.shape[1])  # trivial: direction is all of E
    # Build the matrix of difference vectors
    A = np.array([w[i] - w[i0] for i in s_list])
    # Compute the null space
    _, S, Vt = np.linalg.svd(A)
    rank = np.sum(S > 1e-10)
    null_space = Vt[rank:]
    return null_space

# --------------------------------------------------------------------------
# Example 1: Three affine functions in 2D
# --------------------------------------------------------------------------

def demo_2d():
    """Visualize corner locus of 3 affine functions in R^2."""
    # Three weight vectors and biases
    w = np.array([[1.0, 0.0],
                  [0.0, 1.0],
                  [-0.5, -0.5]])
    b = np.array([0.0, 0.0, 1.5])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: the max-affine function as a contour plot ---
    ax = axes[0]
    xs = np.linspace(-3, 3, 400)
    ys = np.linspace(-3, 3, 400)
    X, Y = np.meshgrid(xs, ys)
    Z = np.zeros_like(X)
    Active = np.zeros_like(X, dtype=int)
    for i in range(len(xs)):
        for j in range(len(ys)):
            pt = np.array([X[j, i], Y[j, i]])
            vals = [affine_fun(w, b, k, pt) for k in range(3)]
            Z[j, i] = max(vals)
            Active[j, i] = np.argmax(vals)

    # Color by active region
    colors = ['#FFB3BA', '#BAFFC9', '#BAE1FF']
    for k in range(3):
        mask = (Active == k).astype(float)
        ax.contourf(X, Y, mask, levels=[0.5, 1.5], colors=[colors[k]], alpha=0.4)

    # Draw contour lines of f
    ax.contour(X, Y, Z, levels=15, colors='gray', linewidths=0.5, alpha=0.5)

    # Draw corner locus (tie lines)
    corner_pts_x, corner_pts_y = [], []
    for i in range(len(xs)):
        for j in range(len(ys)):
            pt = np.array([X[j, i], Y[j, i]])
            if is_corner(w, b, pt, tol=0.05):
                corner_pts_x.append(pt[0])
                corner_pts_y.append(pt[1])

    ax.scatter(corner_pts_x, corner_pts_y, c='red', s=0.3, alpha=0.8, zorder=5)

    ax.set_title('Max-Affine Function: Regions & Corner Locus', fontsize=12)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')

    # Legend
    for k, label in enumerate(['$\\ell_1$ active', '$\\ell_2$ active', '$\\ell_3$ active']):
        ax.plot([], [], 's', color=colors[k], markersize=10, label=label)
    ax.plot([], [], 'r-', linewidth=2, label='Corner locus')
    ax.legend(loc='upper right', fontsize=9)

    # --- Right panel: Tie strata and codimension ---
    ax = axes[1]

    # Compute pairwise tie lines analytically
    # ℓ_i(x) = ℓ_j(x) means ⟨w_i - w_j, x⟩ = b_j - b_i
    for i, j in combinations(range(3), 2):
        dw = w[i] - w[j]
        db = b[j] - b[i]

        if abs(dw[0]) > abs(dw[1]):
            ys_line = np.linspace(-3, 3, 100)
            xs_line = (db - dw[1] * ys_line) / dw[0]
        else:
            xs_line = np.linspace(-3, 3, 100)
            ys_line = (db - dw[0] * xs_line) / dw[1]

        mask = (np.abs(xs_line) <= 3.5) & (np.abs(ys_line) <= 3.5)
        label = f'$T_{{{{{i+1},{j+1}}}}}$: codim 1'
        ax.plot(xs_line[mask], ys_line[mask], linewidth=2, label=label)

    # Triple tie point (codimension 2 = point)
    # Solve: w_1 - w_2 and w_1 - w_3 applied to x = bias differences
    A = np.array([w[0] - w[1], w[0] - w[2]])
    rhs = np.array([b[1] - b[0], b[2] - b[0]])
    if np.linalg.matrix_rank(A) == 2:
        triple_pt = np.linalg.solve(A, rhs)
        ax.plot(triple_pt[0], triple_pt[1], 'ko', markersize=10, zorder=10,
                label=f'$T_{{1,2,3}}$: codim 2 (point)')

    # Show direction info
    for s_set in [{0, 1}, {0, 2}, {1, 2}]:
        i0 = min(s_set)
        direction = tie_set_direction(w, s_set, i0)
        dim = direction.shape[0]
        codim = 2 - dim

    ax.set_title('Tie Strata: Codimension = |s| - 1', fontsize=12)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_transversality_2d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_transversality_2d.png")

# --------------------------------------------------------------------------
# Example 2: Verify codimension theorem numerically
# --------------------------------------------------------------------------

def demo_codimension():
    """Verify the codimension theorem for various configurations."""
    print("\n" + "="*60)
    print("CODIMENSION VERIFICATION")
    print("="*60)

    np.random.seed(42)
    n = 5  # ambient dimension
    num_indices = 8

    w = np.random.randn(num_indices, n)
    b = np.random.randn(num_indices)

    print(f"\nAmbient dimension n = {n}")
    print(f"Number of affine functions = {num_indices}")

    for k in range(2, min(n + 2, num_indices + 1)):
        # Pick first k indices
        s = set(range(k))
        i0 = 0

        # Build difference matrix
        s_list = sorted(s - {i0})
        A = np.array([w[i] - w[i0] for i in s_list])
        rank = np.linalg.matrix_rank(A, tol=1e-10)

        # Theoretical prediction
        expected_codim = k - 1
        expected_dim = n - expected_codim

        # Actual kernel dimension
        _, S, Vt = np.linalg.svd(A)
        actual_rank = np.sum(S > 1e-10)
        actual_ker_dim = n - actual_rank

        independent = "✓" if rank == k - 1 else "✗"
        match = "✓" if actual_ker_dim == expected_dim else "✗"

        print(f"\n  |s| = {k}: "
              f"rank(A) = {actual_rank}, "
              f"dim(ker) = {actual_ker_dim}, "
              f"expected = {expected_dim} "
              f"[{match}]  "
              f"lin.indep [{independent}]")

    # Demonstrate rank drop for linearly dependent configuration
    print(f"\n--- Degenerate case (rank drop) ---")
    w_degen = np.array([[1.0, 0, 0, 0, 0],
                        [0.0, 1, 0, 0, 0],
                        [1.0, 1, 0, 0, 0],  # w_3 = w_1 + w_2, so w_3 - w_1 = w_2 - w_1 + (w_1 - w_1)?
                        [0.0, 0, 1, 0, 0]])
    # w_3 - w_1 = (0,1,0,0,0), w_2 - w_1 = (-1,1,0,0,0), w_4 - w_1 = (-1,0,1,0,0)
    # These are independent! Let me make a true degenerate case:
    w_degen = np.array([[1.0, 0, 0, 0, 0],
                        [0.0, 1, 0, 0, 0],
                        [2.0, -1, 0, 0, 0],  # w_3 - w_1 = (1,-1,0,0,0)
                        [1.0, 1, 0, 0, 0]])   # w_4 - w_1 = (0,1,0,0,0) = w_2 - w_1
    s = {0, 1, 2, 3}
    i0 = 0
    s_list = sorted(s - {i0})
    A = np.array([w_degen[i] - w_degen[i0] for i in s_list])
    rank = np.linalg.matrix_rank(A, tol=1e-10)
    print(f"  |s| = {len(s)}: rank(A) = {rank} < {len(s)-1} = |s|-1  → rank drop!")
    print(f"  Difference vectors are NOT linearly independent.")
    print(f"  dim(ker) = {n - rank} > {n - (len(s)-1)} = expected dim")
    print(f"  Tie set has LARGER dimension than expected (non-generic).")

# --------------------------------------------------------------------------
# Example 3: Linear functional non-constancy
# --------------------------------------------------------------------------

def demo_linear_probing():
    """Demonstrate that generic linear functionals vary on tie strata."""
    print("\n" + "="*60)
    print("LINEAR PROBING ON TIE STRATA")
    print("="*60)

    n = 3
    w = np.array([[1.0, 0.0, 0.0],
                  [0.0, 1.0, 0.0],
                  [0.0, 0.0, 1.0]])
    b = np.array([0.0, 0.0, 0.0])

    # Pairwise tie set {0,1}: ⟨w_1 - w_0, x⟩ = b_0 - b_1 → x_2 - x_1 = 0
    # Direction: ker of (w_1 - w_0) = ker of (-1,1,0) = span{(1,1,0), (0,0,1)}
    s = {0, 1}
    i0 = 0
    direction = tie_set_direction(w, s, i0)
    print(f"\nTie set s={s}, pivot={i0}")
    print(f"  Direction dimension: {direction.shape[0]} (expected: {n - (len(s)-1)})")
    print(f"  Direction basis:\n{direction}")

    # Test various linear functionals
    test_vectors = [
        ("c = (1,0,0)", np.array([1.0, 0.0, 0.0])),
        ("c = (1,1,0)", np.array([1.0, 1.0, 0.0])),
        ("c = (0,0,1)", np.array([0.0, 0.0, 1.0])),
        ("c = (1,-1,0)", np.array([1.0, -1.0, 0.0])),  # orthogonal to direction!
    ]

    for name, c in test_vectors:
        # Check if c is orthogonal to direction
        projs = [np.dot(c, d) for d in direction]
        is_orth = all(abs(p) < 1e-10 for p in projs)
        status = "CONSTANT (c ⊥ direction)" if is_orth else "VARIES (c not ⊥ direction)"
        print(f"  {name}: {status}  (projections: {[f'{p:.3f}' for p in projs]})")

# --------------------------------------------------------------------------
# Example 4: Corner locus visualization in 2D with 5 functions
# --------------------------------------------------------------------------

def demo_complex_2d():
    """More complex 2D example with 5 affine functions."""
    np.random.seed(123)
    num = 5
    n = 2

    w = np.array([[2.0, 0.5],
                  [-1.0, 1.5],
                  [0.5, -1.0],
                  [-0.5, -0.5],
                  [1.0, 1.0]])
    b = np.array([0.0, 0.5, 1.0, 2.0, -1.0])

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    xs = np.linspace(-4, 4, 500)
    ys = np.linspace(-4, 4, 500)
    X, Y = np.meshgrid(xs, ys)

    # Compute active index at each point
    Active = np.zeros_like(X, dtype=int)
    for i in range(len(xs)):
        for j in range(len(ys)):
            pt = np.array([X[j, i], Y[j, i]])
            vals = [affine_fun(w, b, k, pt) for k in range(num)]
            Active[j, i] = np.argmax(vals)

    # Color regions
    cmap = plt.cm.Set3
    ax.contourf(X, Y, Active, levels=np.arange(-0.5, num, 1),
                cmap=cmap, alpha=0.4)

    # Draw all pairwise tie lines
    for i, j in combinations(range(num), 2):
        dw = w[i] - w[j]
        db = b[j] - b[i]
        norm = np.linalg.norm(dw)
        if norm < 1e-10:
            continue

        if abs(dw[0]) > abs(dw[1]):
            ys_line = np.linspace(-4, 4, 200)
            xs_line = (db - dw[1] * ys_line) / dw[0]
        else:
            xs_line = np.linspace(-4, 4, 200)
            ys_line = (db - dw[0] * xs_line) / dw[1]

        mask = (np.abs(xs_line) <= 4.5) & (np.abs(ys_line) <= 4.5)

        # Check which segments are actually on the corner locus
        corner_mask = []
        for idx in range(len(xs_line)):
            if mask[idx]:
                pt = np.array([xs_line[idx], ys_line[idx]])
                aset = active_set(w, b, pt, tol=0.1)
                corner_mask.append(i in aset and j in aset)
            else:
                corner_mask.append(False)
        corner_mask = np.array(corner_mask)

        ax.plot(xs_line[mask], ys_line[mask], '--', linewidth=0.5,
                color='gray', alpha=0.3)
        if np.any(corner_mask):
            ax.plot(xs_line[corner_mask], ys_line[corner_mask],
                    linewidth=2, alpha=0.8)

    # Find triple points
    for i, j, k in combinations(range(num), 3):
        A = np.array([w[i] - w[j], w[i] - w[k]])
        if np.linalg.matrix_rank(A) == 2:
            rhs = np.array([b[j] - b[i], b[k] - b[i]])
            pt = np.linalg.solve(A, rhs)
            if abs(pt[0]) <= 4 and abs(pt[1]) <= 4:
                if is_corner(w, b, pt, tol=0.01):
                    aset = active_set(w, b, pt, tol=0.01)
                    if len(aset) >= 3:
                        ax.plot(pt[0], pt[1], 'ko', markersize=8, zorder=10)

    ax.set_title('Corner Locus of 5 Affine Functions in $\\mathbb{R}^2$', fontsize=13)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('tropical_transversality_complex.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: tropical_transversality_complex.png")

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

if __name__ == '__main__':
    print("="*60)
    print("TROPICAL TRANSVERSALITY DEMO")
    print("="*60)

    demo_2d()
    demo_codimension()
    demo_linear_probing()
    demo_complex_2d()

    print("\n" + "="*60)
    print("All demos completed successfully.")
    print("="*60)
