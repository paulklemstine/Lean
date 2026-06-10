#!/usr/bin/env python3
"""
Demo: Tropical Hodge Theory on Weighted Polyhedral Complexes

Demonstrates the core computations:
1. Weighted coboundary and codifferential
2. Combinatorial Laplacian
3. Kernel characterization (harmonic forms = closed forms)
4. Graph Laplacian as special case
5. Betti number computation
"""

import numpy as np
from typing import Tuple, List

def weighted_codifferential(d: np.ndarray, w_src: np.ndarray, w_tgt: np.ndarray) -> np.ndarray:
    """
    Compute the codifferential δ = W_src^{-1} d^T W_tgt.
    
    Args:
        d: Coboundary matrix (n x m)
        w_src: Source weights (m,) - all positive
        w_tgt: Target weights (n,) - all positive
    
    Returns:
        δ: Codifferential matrix (m x n)
    """
    W_src_inv = np.diag(1.0 / w_src)
    W_tgt = np.diag(w_tgt)
    return W_src_inv @ d.T @ W_tgt

def combinatorial_laplacian(d: np.ndarray, w_src: np.ndarray, w_tgt: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the combinatorial Laplacian.
    
    Returns:
        (Δ_up, Δ_down): Laplacian-up (m x m) and Laplacian-down (n x n)
    """
    delta = weighted_codifferential(d, w_src, w_tgt)
    lap_up = delta @ d
    lap_down = d @ delta
    return lap_up, lap_down

def weighted_inner_product(w: np.ndarray, u: np.ndarray, v: np.ndarray) -> float:
    """Compute the weighted inner product <u, v>_w = Σ w_i u_i v_i."""
    return np.sum(w * u * v)

def verify_adjunction(d: np.ndarray, w_src: np.ndarray, w_tgt: np.ndarray,
                       u: np.ndarray, v: np.ndarray) -> Tuple[float, float]:
    """
    Verify the adjunction: <du, v>_tgt = <u, δv>_src.
    
    Returns:
        (lhs, rhs): Both sides should be equal.
    """
    delta = weighted_codifferential(d, w_src, w_tgt)
    du = d @ u
    delta_v = delta @ v
    lhs = weighted_inner_product(w_tgt, du, v)
    rhs = weighted_inner_product(w_src, u, delta_v)
    return lhs, rhs

def compute_betti_numbers(laplacians: List[np.ndarray]) -> List[int]:
    """
    Compute Betti numbers from Laplacian kernels.
    
    The k-th Betti number = nullity of Δ_k.
    """
    betti = []
    for lap in laplacians:
        rank = np.linalg.matrix_rank(lap, tol=1e-10)
        betti.append(lap.shape[0] - rank)
    return betti

def graph_laplacian(incidence: np.ndarray, edge_weights: np.ndarray) -> np.ndarray:
    """Compute the graph Laplacian L = B^T W B."""
    W = np.diag(edge_weights)
    return incidence.T @ W @ incidence


# ============================================================
# Demo 1: Triangle Graph
# ============================================================
print("=" * 60)
print("Demo 1: Triangle Graph (K_3)")
print("=" * 60)

# Triangle: 3 vertices, 3 edges
# Edges: 0→1, 1→2, 0→2
B = np.array([
    [ 1, -1,  0],  # edge 0→1
    [ 0,  1, -1],  # edge 1→2
    [ 1,  0, -1],  # edge 0→2
], dtype=float)

w_edges = np.array([1.0, 1.0, 1.0])  # unit weights
L = graph_laplacian(B, w_edges)

print(f"Incidence matrix B:\n{B}")
print(f"Graph Laplacian L = B^T W B:\n{L}")
print(f"L is symmetric: {np.allclose(L, L.T)}")
print(f"Eigenvalues of L: {np.sort(np.linalg.eigvalsh(L))}")
print(f"Betti number b_0 (connected components): {3 - np.linalg.matrix_rank(L, tol=1e-10)}")

# Verify adjunction
u = np.array([1.0, 2.0, 3.0])
v = np.array([0.5, -1.0, 0.5])
lhs, rhs = verify_adjunction(B, np.ones(3), w_edges, u, v)
print(f"\nAdjunction verification:")
print(f"  <du, v>_tgt = {lhs:.6f}")
print(f"  <u, δv>_src = {rhs:.6f}")
print(f"  Equal: {np.isclose(lhs, rhs)}")

# ============================================================
# Demo 2: Tetrahedron Boundary (2D simplicial complex)
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Tetrahedron Boundary")
print("=" * 60)

# 4 vertices, 6 edges, 4 faces
# Vertices: 0, 1, 2, 3
# Edges: 01, 02, 03, 12, 13, 23
# Faces: 012, 013, 023, 123

# d_0: vertices → edges (incidence matrix)
d0 = np.array([
    [-1,  1,  0,  0],  # edge 01
    [-1,  0,  1,  0],  # edge 02
    [-1,  0,  0,  1],  # edge 03
    [ 0, -1,  1,  0],  # edge 12
    [ 0, -1,  0,  1],  # edge 13
    [ 0,  0, -1,  1],  # edge 23
], dtype=float)

# d_1: edges → faces (boundary matrix)
d1 = np.array([
    [ 1, -1,  0,  1,  0,  0],  # face 012: e01 - e02 + e12
    [ 1,  0, -1,  0,  1,  0],  # face 013: e01 - e03 + e13
    [ 0,  1, -1,  0,  0,  1],  # face 023: e02 - e03 + e23
    [ 0,  0,  0,  1, -1,  1],  # face 123: e12 - e13 + e23
], dtype=float)

# Verify d1 * d0 = 0 (d² = 0)
print(f"d1 * d0 = 0: {np.allclose(d1 @ d0, 0)}")

# Compute Laplacians
w_v = np.ones(4)  # vertex weights
w_e = np.ones(6)  # edge weights
w_f = np.ones(4)  # face weights

lap0_up, _ = combinatorial_laplacian(d0, w_v, w_e)
lap1_up, lap1_down = combinatorial_laplacian(d1, w_e, w_f)

print(f"\nΔ_0 (vertex Laplacian):\n{lap0_up}")
print(f"Eigenvalues of Δ_0: {np.sort(np.linalg.eigvalsh(lap0_up))}")

# Betti numbers
b0 = 4 - np.linalg.matrix_rank(lap0_up, tol=1e-10)
b1_closed = 6 - np.linalg.matrix_rank(d0, tol=1e-10)
b1_exact = np.linalg.matrix_rank(d0, tol=1e-10)
b1 = b1_closed - np.linalg.matrix_rank(d1, tol=1e-10)  # dim ker d1 - dim im d0

# Proper computation via rank-nullity
rank_d0 = np.linalg.matrix_rank(d0, tol=1e-10)
rank_d1 = np.linalg.matrix_rank(d1, tol=1e-10)
nullity_d0 = 4 - rank_d0
nullity_d1 = 6 - rank_d1

b0_proper = nullity_d0  # ker d0
b1_proper = nullity_d1 - rank_d0  # ker d1 / im d0
b2_proper = 4 - rank_d1  # coker d1

print(f"\nBetti numbers of tetrahedron boundary (≅ S²):")
print(f"  b_0 = {b0_proper} (should be 1)")
print(f"  b_1 = {b1_proper} (should be 0)")
print(f"  b_2 = {b2_proper} (should be 1)")
print(f"  Euler characteristic χ = {b0_proper - b1_proper + b2_proper} (should be 2)")

# ============================================================
# Demo 3: Weighted Graph - Non-uniform Weights
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Weighted Path Graph P_4")
print("=" * 60)

# Path: 0 -- 1 -- 2 -- 3
B_path = np.array([
    [-1,  1,  0,  0],  # edge 0→1
    [ 0, -1,  1,  0],  # edge 1→2
    [ 0,  0, -1,  1],  # edge 2→3
], dtype=float)

# Non-uniform weights
w_edges_path = np.array([2.0, 1.0, 3.0])

L_path = graph_laplacian(B_path, w_edges_path)
eigvals = np.sort(np.linalg.eigvalsh(L_path))

print(f"Edge weights: {w_edges_path}")
print(f"Weighted Laplacian:\n{L_path}")
print(f"Eigenvalues: {eigvals}")
print(f"Spectral gap λ_1 = {eigvals[1]:.6f}")
print(f"Trace = {np.trace(L_path):.6f} (= sum of weighted degrees)")
print(f"Sum of w_e * B_ev² = {np.sum(w_edges_path[:, None] * B_path**2):.6f}")

# Verify trace formula
delta_path = weighted_codifferential(B_path, np.ones(4), w_edges_path)
lap_path, _ = combinatorial_laplacian(B_path, np.ones(4), w_edges_path)
trace_formula = sum(
    (1.0 / 1.0) * w_edges_path[i] * B_path[i, j]**2
    for i in range(3) for j in range(4)
)
print(f"\nTrace formula verification:")
print(f"  tr(Δ) = {np.trace(lap_path):.6f}")
print(f"  Σ w_src⁻¹ w_tgt d² = {trace_formula:.6f}")
print(f"  Equal: {np.isclose(np.trace(lap_path), trace_formula)}")

# ============================================================
# Demo 4: Kernel Characterization
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Kernel Characterization (ker Δ = ker d)")
print("=" * 60)

# Use the path graph
print(f"rank(d) = {np.linalg.matrix_rank(B_path, tol=1e-10)}")
print(f"rank(Δ) = {np.linalg.matrix_rank(lap_path, tol=1e-10)}")
print(f"nullity(d) = {4 - np.linalg.matrix_rank(B_path, tol=1e-10)}")
print(f"nullity(Δ) = {4 - np.linalg.matrix_rank(lap_path, tol=1e-10)}")
print(f"ker(Δ) = ker(d): {np.linalg.matrix_rank(B_path) == np.linalg.matrix_rank(lap_path)}")

# Find a harmonic vector (in ker Δ)
_, S, Vt = np.linalg.svd(lap_path)
harmonic = Vt[-1]  # last row = smallest singular value
print(f"\nHarmonic vector (ker Δ): {np.array2string(harmonic / harmonic[0], precision=4)}")
print(f"  d * harmonic ≈ 0: {np.allclose(B_path @ harmonic, 0, atol=1e-10)}")

# ============================================================
# Demo 5: Hard Lefschetz Property Check
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Hard Lefschetz Property")
print("=" * 60)

# Check HLP for known examples
examples = [
    ("S² (tetrahedron)", [1, 0, 1]),
    ("Torus T²", [1, 2, 1]),
    ("CP² tropical", [1, 1, 1]),
    ("Permutohedron Σ₃", [1, 3, 3, 1]),
]

for name, betti in examples:
    n = len(betti) - 1
    hlp = all(betti[k] <= betti[n - k] for k in range(n // 2 + 1))
    symmetric = all(betti[k] == betti[n - k] for k in range(n + 1))
    print(f"  {name}: betti = {betti}, HLP = {hlp}, symmetric = {symmetric}")

print("\nDone!")


#!/usr/bin/env python3
"""
Visualization: Betti Numbers and Hard Lefschetz Property
for Various Simplicial Complexes

Shows the Betti number profiles and highlights whether they satisfy
the Hard Lefschetz Property (HLP).
"""

import numpy as np
import matplotlib.pyplot as plt


def satisfies_hlp(betti: list) -> bool:
    """Check Hard Lefschetz Property: b_k ≤ b_{n-k} for k ≤ n/2."""
    n = len(betti) - 1
    return all(betti[k] <= betti[n - k] for k in range(n // 2 + 1))


def is_symmetric(betti: list) -> bool:
    """Check Poincaré duality: b_k = b_{n-k}."""
    n = len(betti) - 1
    return all(betti[k] == betti[n - k] for k in range(n + 1))


def euler_char(betti: list) -> int:
    """Compute Euler characteristic."""
    return sum((-1)**k * b for k, b in enumerate(betti))


# ============================================================
# Data: Various topological spaces and their Betti numbers
# ============================================================

spaces = [
    ("S²", [1, 0, 1], "Sphere"),
    ("T²", [1, 2, 1], "Torus"),
    ("RP²", [1, 0, 1], "Real projective plane"),
    ("Klein bottle", [1, 1, 1], "Klein bottle (ℝ coefficients)"),
    ("CP²", [1, 0, 1, 0, 1], "Complex projective plane"),
    ("CP³", [1, 0, 1, 0, 1, 0, 1], "Complex projective 3-space"),
    ("Σ₃ fan", [1, 3, 3, 1], "Permutohedron fan"),
    ("U_{2,4}", [1, 3, 1], "Matroid U(2,4)"),
    ("U_{3,6}", [1, 5, 5, 1], "Matroid U(3,6)"),
    ("W³×T²", [1, 2, 1, 2, 1], "Product variety"),
]

fig, axes = plt.subplots(2, 5, figsize=(20, 8))

for ax, (name, betti, desc) in zip(axes.flat, spaces):
    n = len(betti) - 1
    colors = ['#2ecc71' if satisfies_hlp(betti) else '#e74c3c'] * len(betti)

    bars = ax.bar(range(len(betti)), betti, color=colors, alpha=0.8,
                  edgecolor='black', linewidth=1.5)

    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlabel('degree k', fontsize=9)
    ax.set_ylabel('bₖ', fontsize=9)
    ax.set_xticks(range(len(betti)))

    # Annotate each bar
    for i, b in enumerate(betti):
        ax.text(i, b + 0.1, str(b), ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Status annotations
    hlp_status = "✓ HLP" if satisfies_hlp(betti) else "✗ HLP"
    sym_status = "✓ Sym" if is_symmetric(betti) else "✗ Sym"
    chi = euler_char(betti)
    ax.text(0.02, 0.95, f'{hlp_status}\n{sym_status}\nχ={chi}',
            transform=ax.transAxes, fontsize=8, va='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_ylim(0, max(betti) * 1.4)

plt.suptitle('Betti Numbers and Hard Lefschetz Property\nfor Tropical Varieties and Simplicial Complexes',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('betti_numbers.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved betti_numbers.png")


#!/usr/bin/env python3
"""
Visualization: Hodge Decomposition of a 1-Form on a Graph

Shows how a 1-cochain on a graph decomposes into exact + harmonic + coexact parts.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def graph_laplacian(B: np.ndarray, w: np.ndarray) -> np.ndarray:
    """Compute L = B^T W B."""
    return B.T @ np.diag(w) @ B


def project_to_kernel(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Project v onto ker(A) using SVD."""
    U, S, Vt = np.linalg.svd(A)
    tol = 1e-10 * max(S) if len(S) > 0 and max(S) > 0 else 1e-10
    null_space = Vt[S < tol].T  # columns = null space basis
    if null_space.shape[1] == 0:
        return np.zeros_like(v)
    return null_space @ (null_space.T @ v)


def hodge_decompose_0form(B: np.ndarray, w_e: np.ndarray, f: np.ndarray):
    """
    Decompose a 0-form f on vertices into:
    - harmonic part (in ker d ∩ ker δ)
    - coexact part (in im δ)

    For degree 0, there is no exact part (im d_{-1} = 0).
    """
    n_v = B.shape[1]
    L = graph_laplacian(B, w_e)

    # Harmonic = projection onto ker(L)
    harmonic = project_to_kernel(L, f)

    # Coexact = f - harmonic (which is in im(δ) = im(B^T W))
    coexact = f - harmonic

    return harmonic, coexact


# ============================================================
# Setup: Hexagonal graph (6 vertices, 6 edges forming a cycle)
# ============================================================

n = 6
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
pos = np.column_stack([np.cos(angles), np.sin(angles)])

# Cycle graph incidence matrix
edges = []
for i in range(n):
    row = np.zeros(n)
    row[i] = -1
    row[(i + 1) % n] = 1
    edges.append(row)
B = np.array(edges)
w_e = np.ones(n)

# Define a 0-form (function on vertices)
f = np.array([3.0, 1.0, 4.0, 1.0, 5.0, 2.0])

# Decompose
harmonic, coexact = hodge_decompose_0form(B, w_e, f)

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

components = [
    ("Original f", f, 'viridis'),
    ("Harmonic part", harmonic, 'coolwarm'),
    ("Coexact part (im δ)", coexact, 'plasma'),
]

for ax, (title, values, cmap) in zip(axes, components):
    # Draw edges
    for i in range(n):
        j = (i + 1) % n
        ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                'k-', linewidth=1.5, alpha=0.3)

    # Draw vertices with values
    scatter = ax.scatter(pos[:, 0], pos[:, 1], c=values, cmap=cmap,
                         s=400, zorder=5, edgecolors='black', linewidth=2)

    for i in range(n):
        ax.annotate(f'{values[i]:.2f}', xy=pos[i],
                    ha='center', va='center', fontsize=9, fontweight='bold',
                    color='white' if abs(values[i]) > np.max(abs(values)) * 0.5 else 'black')

    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    plt.colorbar(scatter, ax=ax, shrink=0.6)

# Verify decomposition
residual = np.linalg.norm(f - harmonic - coexact)
fig.text(0.5, 0.02,
         f'Decomposition: f = harmonic + coexact | '
         f'‖residual‖ = {residual:.2e} | '
         f'harmonic value = {harmonic[0]:.4f} (constant on connected component)',
         ha='center', fontsize=11, style='italic')

plt.suptitle('Tropical Hodge Decomposition on Hexagonal Graph',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig('hodge_decomposition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved hodge_decomposition.png")


#!/usr/bin/env python3
"""
Visualization: Spectrum of the Tropical Laplacian on Various Graphs

Shows eigenvalue distributions for different graph topologies,
illustrating how graph structure determines the harmonic forms.
"""

import numpy as np
import matplotlib.pyplot as plt


def graph_laplacian(incidence: np.ndarray, edge_weights: np.ndarray) -> np.ndarray:
    """Compute L = B^T W B."""
    W = np.diag(edge_weights)
    return incidence.T @ W @ incidence


def complete_graph_incidence(n: int) -> np.ndarray:
    """Signed incidence matrix of K_n."""
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            row = np.zeros(n)
            row[i] = -1
            row[j] = 1
            edges.append(row)
    return np.array(edges)


def path_graph_incidence(n: int) -> np.ndarray:
    """Signed incidence matrix of P_n (path on n vertices)."""
    edges = []
    for i in range(n - 1):
        row = np.zeros(n)
        row[i] = -1
        row[i + 1] = 1
        edges.append(row)
    return np.array(edges)


def cycle_graph_incidence(n: int) -> np.ndarray:
    """Signed incidence matrix of C_n."""
    edges = []
    for i in range(n):
        row = np.zeros(n)
        row[i] = -1
        row[(i + 1) % n] = 1
        edges.append(row)
    return np.array(edges)


def petersen_graph_incidence() -> np.ndarray:
    """Signed incidence matrix of the Petersen graph (10 vertices, 15 edges)."""
    # Petersen graph edges
    outer = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    inner = [(5, 7), (6, 8), (7, 9), (8, 5), (9, 6)]
    spokes = [(0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]
    all_edges = outer + inner + spokes

    n_verts = 10
    edges = []
    for i, j in all_edges:
        row = np.zeros(n_verts)
        row[i] = -1
        row[j] = 1
        edges.append(row)
    return np.array(edges)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

graphs = [
    ("Complete Graph K₆", complete_graph_incidence(6), np.ones(15)),
    ("Path Graph P₈", path_graph_incidence(8), np.ones(7)),
    ("Cycle Graph C₈", cycle_graph_incidence(8), np.ones(8)),
    ("Petersen Graph", petersen_graph_incidence(), np.ones(15)),
]

for ax, (name, B, w) in zip(axes.flat, graphs):
    L = graph_laplacian(B, w)
    eigvals = np.sort(np.linalg.eigvalsh(L))

    ax.bar(range(len(eigvals)), eigvals, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.set_title(name, fontsize=14, fontweight='bold')
    ax.set_xlabel('Eigenvalue index')
    ax.set_ylabel('λ')
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)

    # Annotate spectral gap
    nonzero = eigvals[eigvals > 1e-10]
    if len(nonzero) > 0:
        gap = nonzero[0]
        ax.annotate(f'λ₁ = {gap:.3f}', xy=(1, gap),
                    xytext=(2, gap + 0.5), fontsize=10,
                    arrowprops=dict(arrowstyle='->', color='red'),
                    color='red')

    # Annotate multiplicity of zero
    n_zero = len(eigvals) - len(nonzero)
    ax.annotate(f'b₀ = {n_zero}', xy=(0, 0),
                xytext=(0.5, max(eigvals) * 0.8), fontsize=11, color='green')

plt.suptitle('Tropical Laplacian Spectrum on Various Graphs', fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('laplacian_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved laplacian_spectrum.png")
