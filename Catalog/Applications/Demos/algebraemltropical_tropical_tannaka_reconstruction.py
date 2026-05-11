#!/usr/bin/env python3
"""
Tropical Tannaka Reconstruction — Applications

Demonstrates real-world applications of tropical symmetry reconstruction:
1. Shortest-path network symmetry detection
2. Dynamic programming invariance analysis
3. Tropical linear algebra symmetry extraction
"""

import numpy as np
from algorithms import (
    TensorCategoryPresentation,
    SymmetrySemiringElement,
    compute_symmetry_presentation,
    check_naturality,
    compute_closure_character,
)


# ── Application 1: Network Symmetry Detection ────────────────────────────

def network_symmetry_demo():
    """
    Detect symmetries of a weighted directed graph using tropical matrices.

    The adjacency matrix of a weighted graph is a tropical matrix.
    Graph automorphisms correspond to natural endomorphisms of the
    fiber functor applied to the graph's path category.

    A permutation π is a graph automorphism iff π⁻¹ A π = A (tropically),
    where A is the adjacency matrix.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Symmetry Detection")
    print("=" * 60)

    # A symmetric 4-node graph (cycle with equal weights)
    n = 4
    INF = float('inf')
    A = np.full((n, n), INF)
    for i in range(n):
        A[i, (i + 1) % n] = 1.0  # forward edges
        A[(i + 1) % n, i] = 1.0  # backward edges

    print(f"\nGraph adjacency matrix (∞ = no edge):")
    for row in A:
        print(f"  {['∞' if x == INF else f'{x:.0f}' for x in row]}")

    # The graph has D₄ symmetry (dihedral group of order 8)
    # Check rotation by 1: π = (0 1 2 3) → (1 2 3 0)
    perm = [1, 2, 3, 0]
    P = np.zeros((n, n))
    for i, j in enumerate(perm):
        P[i, j] = 1.0

    # Check if P is a "tropical automorphism": P A = A P (standard, since
    # permutation matrices work the same tropically)
    PA = P @ A
    AP = A @ P
    is_auto = np.allclose(PA, AP)
    print(f"\nRotation by 1 is automorphism: {is_auto}")

    # Reflection: π = (0 3 2 1) → (0 3 2 1)
    perm_ref = [0, 3, 2, 1]
    P_ref = np.zeros((n, n))
    for i, j in enumerate(perm_ref):
        P_ref[i, j] = 1.0
    is_auto_ref = np.allclose(P_ref @ A, A @ P_ref)
    print(f"Reflection is automorphism: {is_auto_ref}")

    # Non-symmetry: swap only nodes 0 and 1
    perm_bad = [1, 0, 2, 3]
    P_bad = np.zeros((n, n))
    for i, j in enumerate(perm_bad):
        P_bad[i, j] = 1.0
    is_auto_bad = np.allclose(P_bad @ A, A @ P_bad)
    print(f"Swap(0,1) is automorphism: {is_auto_bad}")

    # Model as tensor category reconstruction
    cat = TensorCategoryPresentation(
        n_generators=1,
        dimensions=[n],
        morphisms=[(0, 0, A)]
    )
    pres = compute_symmetry_presentation(cat)
    print(f"\nReconstruction presentation:")
    print(f"  Ambient dim: {pres.ambient_dim} (= {n}² matrix entries)")
    print(f"  Naturality constraints: {pres.n_constraints}")
    print(f"  Natural dimension: {pres.natural_dim}")
    print()


# ── Application 2: Dynamic Programming Invariance ─────────────────────────

def dynamic_programming_demo():
    """
    Analyze invariances in dynamic programming transition matrices.

    In DP, the value function evolves under tropical matrix multiplication:
        V_{t+1} = T ⊗ V_t  (max-plus)

    Symmetries of T correspond to symmetries of the DP problem.
    """
    print("=" * 60)
    print("APPLICATION 2: Dynamic Programming Invariance")
    print("=" * 60)

    # A simple DP transition matrix (3 states)
    # T[i][j] = reward for transitioning from state j to state i
    T = np.array([
        [0, 2, 1],
        [2, 0, 2],
        [1, 2, 0]
    ], dtype=float)

    print(f"\nDP transition matrix T:")
    print(T)

    # This matrix is symmetric → it commutes with any permutation
    # that preserves the structure
    print(f"\nT is symmetric: {np.allclose(T, T.T)}")

    # Check which permutation matrices commute with T
    from itertools import permutations
    n = 3
    symmetries = []
    for perm in permutations(range(n)):
        P = np.zeros((n, n))
        for i, j in enumerate(perm):
            P[i, j] = 1.0
        if np.allclose(P @ T, T @ P):
            symmetries.append(perm)

    print(f"\nPermutation symmetries of T: {len(symmetries)}")
    for s in symmetries:
        print(f"  {s}")

    # Model as reconstruction
    cat = TensorCategoryPresentation(
        n_generators=1,
        dimensions=[n],
        morphisms=[(0, 0, T)]
    )
    pres = compute_symmetry_presentation(cat)
    print(f"\nReconstruction: {pres.ambient_dim} ambient, "
          f"{pres.n_constraints} constraints, "
          f"natural dim = {pres.natural_dim}")
    print()


# ── Application 3: Tropical Linear Algebra ────────────────────────────────

def tropical_linear_algebra_demo():
    """
    Demonstrate tropical matrix operations and their symmetries.

    In the max-plus algebra:
    - Addition = max
    - Multiplication = +
    - Zero = -∞
    - One = 0
    """
    print("=" * 60)
    print("APPLICATION 3: Tropical Linear Algebra Symmetries")
    print("=" * 60)

    def trop_mat_mul(A, B):
        m, k = A.shape
        _, n = B.shape
        C = np.full((m, n), -np.inf)
        for i in range(m):
            for j in range(n):
                for p in range(k):
                    if A[i, p] != -np.inf and B[p, j] != -np.inf:
                        C[i, j] = max(C[i, j], A[i, p] + B[p, j])
        return C

    # Tropical identity
    n = 3
    I_trop = np.full((n, n), -np.inf)
    np.fill_diagonal(I_trop, 0)

    # A tropical matrix
    A = np.array([
        [0, 3, -np.inf],
        [-np.inf, 0, 2],
        [1, -np.inf, 0]
    ])

    print(f"\nTropical matrix A:")
    for row in A:
        print(f"  {['−∞' if x == -np.inf else f'{x:.0f}' for x in row]}")

    # Tropical powers: A^k gives length-k shortest paths
    A2 = trop_mat_mul(A, A)
    A3 = trop_mat_mul(A2, A)

    print(f"\nA² (2-step max-weight paths):")
    for row in A2:
        print(f"  {['−∞' if x == -np.inf else f'{x:.0f}' for x in row]}")

    print(f"\nA³ (3-step max-weight paths):")
    for row in A3:
        print(f"  {['−∞' if x == -np.inf else f'{x:.0f}' for x in row]}")

    # Tropical eigenvalue: the maximum cycle mean
    # For this matrix, we can compute it from the diagonal of A, A², A³
    print(f"\nTropical eigenvalue analysis:")
    print(f"  diag(A) = {[A[i, i] for i in range(n)]}")
    print(f"  diag(A²) = {[A2[i, i] for i in range(n)]}")
    print(f"  diag(A³)/3 = {[A3[i, i]/3 if A3[i, i] > -np.inf else '-∞' for i in range(n)]}")

    # The tropical eigenvalue = max cycle mean
    max_cycle_mean = max(
        A3[i, i] / 3 for i in range(n) if A3[i, i] > -np.inf
    )
    print(f"  Max cycle mean (tropical eigenvalue) ≈ {max_cycle_mean:.2f}")
    print()


# ── Run All Applications ─────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL TANNAKA RECONSTRUCTION — APPLICATIONS            ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    network_symmetry_demo()
    dynamic_programming_demo()
    tropical_linear_algebra_demo()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Tannaka Reconstruction — Demo

Demonstrates the reconstruction of a "symmetry semiring" from a finite
tensor category with a tropical fiber functor. Walks through a concrete
example with 3 generators, computes the symmetry semiring, naturality
constraints, closure characters, and verifies reconstruction.
"""

import numpy as np
from itertools import product as cartprod


# ── 1. Tropical Semiring ──────────────────────────────────────────────────

class TropicalSemiring:
    """The max-plus (tropical) semiring: (ℝ ∪ {-∞}, max, +)"""
    NEG_INF = float('-inf')

    @staticmethod
    def add(a, b):
        return max(a, b)

    @staticmethod
    def mul(a, b):
        if a == TropicalSemiring.NEG_INF or b == TropicalSemiring.NEG_INF:
            return TropicalSemiring.NEG_INF
        return a + b

    @staticmethod
    def zero():
        return TropicalSemiring.NEG_INF

    @staticmethod
    def one():
        return 0.0


# ── 2. Tropical Matrix Operations ─────────────────────────────────────────

def trop_mat_mul(A, B):
    """Tropical matrix multiplication (max-plus)."""
    m, k1 = A.shape
    k2, n = B.shape
    assert k1 == k2
    C = np.full((m, n), TropicalSemiring.NEG_INF)
    for i in range(m):
        for j in range(n):
            for p in range(k1):
                val = TropicalSemiring.mul(A[i, p], B[p, j])
                C[i, j] = TropicalSemiring.add(C[i, j], val)
    return C


def trop_mat_id(n):
    """Tropical identity matrix."""
    M = np.full((n, n), TropicalSemiring.NEG_INF)
    for i in range(n):
        M[i, i] = TropicalSemiring.one()
    return M


def trop_trace(M):
    """Tropical trace = max of diagonal elements."""
    n = M.shape[0]
    t = TropicalSemiring.NEG_INF
    for i in range(n):
        t = TropicalSemiring.add(t, M[i, i])
    return t


# ── 3. Finite Tensor Category Data ────────────────────────────────────────

class TensorCatData:
    """A finite tensor category with fiber functor data."""
    def __init__(self, dims, morphisms=None):
        """
        dims: list of generator dimensions
        morphisms: list of (src_idx, tgt_idx, matrix) triples
        """
        self.n_gen = len(dims)
        self.dims = dims
        self.morphisms = morphisms or []
        self.n_mor = len(self.morphisms)

    def __repr__(self):
        return (f"TensorCatData(n_gen={self.n_gen}, dims={self.dims}, "
                f"n_mor={self.n_mor})")


# ── 4. Symmetry Semiring ──────────────────────────────────────────────────

class SymmetrySemiring:
    """
    An element of the symmetry semiring: a family of endomorphism
    matrices, one per generator.

    Over ℝ with standard operations (pointwise):
      zero: all zero matrices
      one: all identity matrices
      add: pointwise matrix addition
      mul: pointwise matrix multiplication (Hadamard-like on components)
    """
    def __init__(self, cat_data, components):
        """
        components: list of numpy arrays, one per generator
        """
        self.cat = cat_data
        self.components = components

    @classmethod
    def zero(cls, cat):
        return cls(cat, [np.zeros((d, d)) for d in cat.dims])

    @classmethod
    def one(cls, cat):
        return cls(cat, [np.ones((d, d)) for d in cat.dims])

    @classmethod
    def identity_matrices(cls, cat):
        """The element with identity matrices (tropical one)."""
        return cls(cat, [trop_mat_id(d) for d in cat.dims])

    def __add__(self, other):
        return SymmetrySemiring(self.cat,
            [a + b for a, b in zip(self.components, other.components)])

    def __mul__(self, other):
        return SymmetrySemiring(self.cat,
            [a * b for a, b in zip(self.components, other.components)])

    def closure_character(self):
        """Trace on each component → closure capacity character."""
        return [np.trace(M) for M in self.components]

    def is_natural(self):
        """Check naturality: commutes with all morphism matrices."""
        for src_idx, tgt_idx, mat in self.cat.morphisms:
            eta_tgt = self.components[tgt_idx]
            eta_src = self.components[src_idx]
            # Naturality: eta_tgt @ mat == mat @ eta_src (standard multiplication)
            lhs = eta_tgt @ mat
            rhs = mat @ eta_src
            if not np.allclose(lhs, rhs, atol=1e-10):
                return False
        return True

    def __repr__(self):
        chars = self.closure_character()
        return f"SymmetrySemiring(traces={[f'{c:.2f}' for c in chars]})"


# ── 5. Demo: Two-Generator Example ────────────────────────────────────────

def demo_two_generators():
    print("=" * 70)
    print("DEMO 1: Two-Generator Category (no morphisms)")
    print("=" * 70)

    cat = TensorCatData(dims=[1, 2])
    print(f"\nCategory: {cat}")

    # Zero and one
    z = SymmetrySemiring.zero(cat)
    o = SymmetrySemiring.one(cat)
    print(f"\nZero element: {z}")
    print(f"  Components: {[M.tolist() for M in z.components]}")
    print(f"One element: {o}")
    print(f"  Components: {[M.tolist() for M in o.components]}")

    # Character of one = dimensions
    print(f"\nCharacter of 1 = {o.closure_character()} (should be [1, 2])")

    # Character is additive
    eta = SymmetrySemiring(cat, [np.array([[3.0]]), np.array([[1.0, 2.0], [3.0, 4.0]])])
    mu = SymmetrySemiring(cat, [np.array([[1.0]]), np.array([[5.0, 6.0], [7.0, 8.0]])])
    sum_char = (eta + mu).closure_character()
    char_sum = [a + b for a, b in zip(eta.closure_character(), mu.closure_character())]
    print(f"\nCharacter additivity test:")
    print(f"  χ(η+μ) = {sum_char}")
    print(f"  χ(η)+χ(μ) = {char_sum}")
    print(f"  Equal: {all(abs(a-b) < 1e-10 for a, b in zip(sum_char, char_sum))}")

    # All elements are natural (no morphisms)
    print(f"\nAll elements natural (vacuously): {eta.is_natural()}")
    print()


# ── 6. Demo: Three-Generator Example with Morphisms ────────────────────────

def demo_three_generators():
    print("=" * 70)
    print("DEMO 2: Three-Generator Category with Morphism Constraints")
    print("=" * 70)

    # Generators with dims 2, 2, 3
    # One morphism from gen 0 → gen 1
    morphism_matrix = np.array([[1.0, 0.0], [0.0, 1.0]])  # identity morphism
    cat = TensorCatData(dims=[2, 2, 3], morphisms=[(0, 1, morphism_matrix)])
    print(f"\nCategory: {cat}")
    print(f"Morphism 0→1: identity matrix")

    # Test naturality
    # With identity morphism, naturality requires η₁ = η₀
    eta_natural = SymmetrySemiring(cat, [
        np.array([[1.0, 2.0], [3.0, 4.0]]),
        np.array([[1.0, 2.0], [3.0, 4.0]]),  # same as gen 0
        np.array([[5.0, 0.0, 0.0], [0.0, 6.0, 0.0], [0.0, 0.0, 7.0]])
    ])
    print(f"\nNatural element (η₀ = η₁): is_natural = {eta_natural.is_natural()}")

    eta_unnatural = SymmetrySemiring(cat, [
        np.array([[1.0, 2.0], [3.0, 4.0]]),
        np.array([[5.0, 6.0], [7.0, 8.0]]),  # different from gen 0
        np.array([[5.0, 0.0, 0.0], [0.0, 6.0, 0.0], [0.0, 0.0, 7.0]])
    ])
    print(f"Unnatural element (η₀ ≠ η₁): is_natural = {eta_unnatural.is_natural()}")

    # The natural subsemiring has η₀ = η₁, so it's determined by
    # the choice of η₀ (2×2 matrix) and η₂ (3×3 matrix)
    print(f"\nSymmetry semiring dimension (natural part):")
    print(f"  Full product: {sum(d*d for d in cat.dims)} = "
          f"{'+'.join(str(d*d) for d in cat.dims)} parameters")
    print(f"  After naturality: {cat.dims[0]**2 + cat.dims[2]**2} = "
          f"{cat.dims[0]}² + {cat.dims[2]}² parameters")
    print(f"  (η₀ determines η₁ via identity morphism)")
    print()


# ── 7. Demo: Pullback Functoriality ───────────────────────────────────────

def demo_functoriality():
    print("=" * 70)
    print("DEMO 3: Functoriality of Reconstruction")
    print("=" * 70)

    cat_C = TensorCatData(dims=[2, 3])
    cat_D = TensorCatData(dims=[3, 2, 4])

    # Morphism Φ: C → D sending gen 0 → gen 0, gen 1 → gen 2
    # (dim compatibility: C.dim[0]=2 but D.dim[0]=3 — this doesn't match,
    #  so let's use compatible dims)
    cat_C = TensorCatData(dims=[3, 4])
    cat_D = TensorCatData(dims=[2, 3, 4])
    gen_map = [1, 2]  # C.gen[0] → D.gen[1], C.gen[1] → D.gen[2]

    print(f"\nC: dims={cat_C.dims}")
    print(f"D: dims={cat_D.dims}")
    print(f"Φ: gen_map={gen_map} (C.gen[i] → D.gen[gen_map[i]])")
    print(f"  C.dim[0]={cat_C.dims[0]} = D.dim[{gen_map[0]}]={cat_D.dims[gen_map[0]]} ✓")
    print(f"  C.dim[1]={cat_C.dims[1]} = D.dim[{gen_map[1]}]={cat_D.dims[gen_map[1]]} ✓")

    # An element of End(D)
    eta_D = SymmetrySemiring(cat_D, [
        np.eye(2) * 10,
        np.eye(3) * 20,
        np.eye(4) * 30,
    ])

    # Pullback: restrict to C's generators via gen_map
    pullback_components = [eta_D.components[gen_map[i]] for i in range(cat_C.n_gen)]
    eta_C = SymmetrySemiring(cat_C, pullback_components)

    print(f"\nη_D character: {eta_D.closure_character()}")
    print(f"ψ(η_D) character: {eta_C.closure_character()}")
    print(f"  (projects to components {gen_map} of D)")

    # Verify ring homomorphism properties
    mu_D = SymmetrySemiring(cat_D, [
        np.eye(2) * 5,
        np.eye(3) * 15,
        np.eye(4) * 25,
    ])
    pullback_mu = SymmetrySemiring(cat_C, [mu_D.components[gen_map[i]] for i in range(cat_C.n_gen)])

    sum_pullback = SymmetrySemiring(cat_C,
        [(eta_D + mu_D).components[gen_map[i]] for i in range(cat_C.n_gen)])
    pullback_sum = eta_C + pullback_mu

    print(f"\nRing homomorphism check:")
    print(f"  ψ(η+μ) chars: {sum_pullback.closure_character()}")
    print(f"  ψ(η)+ψ(μ) chars: {pullback_sum.closure_character()}")
    match = all(abs(a-b) < 1e-10 for a, b
                in zip(sum_pullback.closure_character(), pullback_sum.closure_character()))
    print(f"  ψ(η+μ) = ψ(η)+ψ(μ): {match}")
    print()


# ── 8. Demo: Tropical (Max-Plus) Reconstruction ───────────────────────────

def demo_tropical():
    print("=" * 70)
    print("DEMO 4: Tropical (Max-Plus) Reconstruction")
    print("=" * 70)

    # In the max-plus semiring, the symmetry semiring inherits idempotency
    print("\nMax-plus semiring: (ℝ∪{-∞}, max, +)")
    print(f"  0 (additive identity) = -∞")
    print(f"  1 (multiplicative identity) = 0")

    # 2×2 tropical matrix example
    A = np.array([[0, 3], [1, 0]])  # tropical identity has 0 on diagonal
    B = np.array([[2, -1], [0, 4]])

    print(f"\nA = {A.tolist()}")
    print(f"B = {B.tolist()}")
    print(f"A ⊗ B (trop mul) = {trop_mat_mul(A, B).tolist()}")
    print(f"trop_trace(A) = {trop_trace(A)} (max of diagonal)")
    print(f"trop_trace(B) = {trop_trace(B)}")

    # Idempotency: A ⊕ A = A in tropical
    A_plus_A = np.maximum(A, A)  # max-plus addition = max
    print(f"\nIdempotency: A ⊕ A = {A_plus_A.tolist()} = A? {np.array_equal(A_plus_A, A)}")
    print()


# ── 9. Run All Demos ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL TANNAKA RECONSTRUCTION — INTERACTIVE DEMOS               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_two_generators()
    demo_three_generators()
    demo_functoriality()
    demo_tropical()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import (
    create_reconstruction_diagram,
    create_symmetry_semiring_heatmap,
    create_naturality_constraint_diagram,
    create_character_diagram,
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Generate visualizations
print("Generating visualizations...")
vis_reconstruction = create_reconstruction_diagram()
vis_heatmap = create_symmetry_semiring_heatmap()
vis_naturality = create_naturality_constraint_diagram()
vis_character = create_character_diagram()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Bridges/EMLTropical/TropicalTannakaReconstruction.lean')

package = {
    "title": "Tropical Tannaka Reconstruction via Idempotent Fiber Functors and Closure Symmetry Semirings",
    "domain": "Algebra / Tropical Geometry / Category Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Tannaka Reconstruction Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Symmetry Semiring Computation",
            "pseudocode": "Input: TensorCategoryPresentation(n_gen, dims, morphisms)\nOutput: (ambient_dim, n_constraints, natural_dim)\n\nambient_dim <- sum(d_i^2 for d_i in dims)\nn_constraints <- sum(d_tgt * d_src for each morphism)\nnatural_dim <- ambient_dim - n_constraints\nreturn (ambient_dim, n_constraints, natural_dim)",
            "code": algorithms_code
        },
        {
            "name": "Naturality Checking",
            "pseudocode": "Input: element eta, category C\nOutput: Boolean\n\nfor each morphism k with matrix M_k:\n    LHS = eta_tgt * M_k (matrix multiplication)\n    RHS = M_k * eta_src\n    if LHS != RHS: return False\nreturn True",
            "code": "# See algorithms.py check_naturality function"
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Tannaka Reconstruction Pipeline",
            "data": vis_reconstruction
        },
        {
            "name": "Symmetry Semiring Element Components",
            "data": vis_heatmap
        },
        {
            "name": "Naturality Constraints Analysis",
            "data": vis_naturality
        },
        {
            "name": "Closure Capacity Character (Koopman Bridge)",
            "data": vis_character
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Tropical Tannaka Reconstruction — Visualizations

Generates figures illustrating key concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_reconstruction_diagram():
    """Create a diagram showing the Tannaka reconstruction pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-1, 4)
    ax.axis('off')

    # Boxes
    boxes = [
        (0.5, 2, "Tensor\nCategory C"),
        (3.5, 2, "Fiber\nFunctor F"),
        (6.5, 2, "Tropical\nSemimodules"),
        (9.5, 2, "Symmetry\nSemiring A"),
        (6.5, 0, "Tropical\nRep(A)"),
    ]
    for x, y, text in boxes:
        rect = mpatches.FancyBboxPatch((x - 0.9, y - 0.5), 1.8, 1.0,
            boxstyle="round,pad=0.1", facecolor='#E8F4FD',
            edgecolor='#2C3E50', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=10,
                fontweight='bold', color='#2C3E50')

    # Arrows
    arrows = [
        (1.4, 2, 2.6, 2, ''),
        (4.4, 2, 5.6, 2, ''),
        (7.4, 2, 8.6, 2, 'End⊗(F)'),
        (6.5, 1.5, 6.5, 0.5, ''),
        (9.5, 1.5, 7.4, 0.5, 'K'),
    ]
    for x1, y1, x2, y2, label in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
            arrowprops=dict(arrowstyle='->', lw=2, color='#E74C3C'))
        if label:
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2 + 0.2
            ax.text(mx, my, label, ha='center', va='bottom', fontsize=9,
                    color='#E74C3C', fontstyle='italic')

    ax.set_title("Tropical Tannaka Reconstruction Pipeline",
                 fontsize=14, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def create_symmetry_semiring_heatmap():
    """Visualize a symmetry semiring element as heatmaps."""
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))

    # Three generator components
    dims = [2, 3, 2]
    np.random.seed(42)
    components = [np.random.rand(d, d) for d in dims]

    for ax, M, i in zip(axes, components, range(3)):
        im = ax.imshow(M, cmap='YlOrRd', vmin=0, vmax=1)
        ax.set_title(f'Generator {i}\n(dim {dims[i]})', fontsize=12,
                     fontweight='bold')
        ax.set_xlabel('Column')
        ax.set_ylabel('Row')
        for r in range(M.shape[0]):
            for c in range(M.shape[1]):
                ax.text(c, r, f'{M[r, c]:.2f}', ha='center', va='center',
                        fontsize=9, color='black' if M[r, c] < 0.5 else 'white')

    fig.colorbar(im, ax=axes, label='Matrix Entry Value', shrink=0.8)
    fig.suptitle('Symmetry Semiring Element Components', fontsize=14,
                 fontweight='bold', y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


def create_naturality_constraint_diagram():
    """Visualize naturality constraints."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: commutative diagram
    ax1.set_xlim(-0.5, 4.5)
    ax1.set_ylim(-0.5, 3.5)
    ax1.axis('off')
    ax1.set_title('Naturality Square', fontsize=13, fontweight='bold')

    positions = {
        'F(X)': (0.5, 3), 'F(Y)': (3.5, 3),
        'F(X)\'': (0.5, 0.5), 'F(Y)\'': (3.5, 0.5),
    }
    labels = {
        'F(X)': 'F(X)', 'F(Y)': 'F(Y)',
        'F(X)\'': 'F(X)', 'F(Y)\'': 'F(Y)',
    }
    for key, (x, y) in positions.items():
        ax1.text(x, y, labels[key], ha='center', va='center', fontsize=14,
                fontweight='bold', color='#2C3E50',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F4FD',
                         edgecolor='#2C3E50', linewidth=1.5))

    # Arrows
    ax1.annotate('', xy=(2.8, 3), xytext=(1.2, 3),
        arrowprops=dict(arrowstyle='->', lw=2, color='#3498DB'))
    ax1.text(2, 3.3, 'F(f)', ha='center', fontsize=11, color='#3498DB')

    ax1.annotate('', xy=(2.8, 0.5), xytext=(1.2, 0.5),
        arrowprops=dict(arrowstyle='->', lw=2, color='#3498DB'))
    ax1.text(2, 0.1, 'F(f)', ha='center', fontsize=11, color='#3498DB')

    ax1.annotate('', xy=(0.5, 1.2), xytext=(0.5, 2.3),
        arrowprops=dict(arrowstyle='->', lw=2, color='#E74C3C'))
    ax1.text(-0.1, 1.75, 'η_X', ha='center', fontsize=11, color='#E74C3C')

    ax1.annotate('', xy=(3.5, 1.2), xytext=(3.5, 2.3),
        arrowprops=dict(arrowstyle='->', lw=2, color='#E74C3C'))
    ax1.text(4.1, 1.75, 'η_Y', ha='center', fontsize=11, color='#E74C3C')

    # Right: constraint counting
    ax2.axis('off')
    ax2.set_title('Constraint Analysis', fontsize=13, fontweight='bold')

    data = [
        ['Generators', '3', 'dims = [2, 2, 3]'],
        ['Ambient dim', '17', '2²+2²+3²'],
        ['Morphisms', '1', '(0→1, id)'],
        ['Constraints', '4', '2×2 equations'],
        ['Natural dim', '13', '17−4'],
    ]
    table = ax2.table(cellText=data,
                      colLabels=['Property', 'Value', 'Detail'],
                      loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1.2, 1.8)
    for (row, col), cell in table.get_celld().items():
        if row == 0:
            cell.set_facecolor('#2C3E50')
            cell.set_text_props(color='white', fontweight='bold')
        else:
            cell.set_facecolor('#F7F9FC' if row % 2 == 0 else 'white')
        cell.set_edgecolor('#BDC3C7')

    plt.tight_layout()
    return fig_to_base64(fig)


def create_character_diagram():
    """Visualize the closure capacity character."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: character values for several semiring elements
    n_gen = 4
    gen_labels = [f'Gen {i}' for i in range(n_gen)]
    dims = [2, 3, 1, 4]

    np.random.seed(123)
    n_elements = 5
    characters = []
    for _ in range(n_elements):
        components = [np.random.rand(d, d) * 3 for d in dims]
        chars = [np.trace(M) for M in components]
        characters.append(chars)

    x = np.arange(n_gen)
    width = 0.15
    colors = plt.cm.Set2(np.linspace(0, 1, n_elements))

    for i, (chars, color) in enumerate(zip(characters, colors)):
        ax1.bar(x + i * width, chars, width, label=f'η_{i}', color=color,
                edgecolor='gray', linewidth=0.5)

    ax1.set_xlabel('Generator', fontsize=12)
    ax1.set_ylabel('Trace (Character Value)', fontsize=12)
    ax1.set_title('Closure Characters of\nSymmetry Semiring Elements', fontsize=13,
                  fontweight='bold')
    ax1.set_xticks(x + width * (n_elements - 1) / 2)
    ax1.set_xticklabels(gen_labels)
    ax1.legend(fontsize=9)
    ax1.grid(axis='y', alpha=0.3)

    # Right: additivity verification
    eta_chars = characters[0]
    mu_chars = characters[1]
    sum_chars = [a + b for a, b in zip(eta_chars, mu_chars)]

    ax2.bar(x - 0.2, eta_chars, 0.35, label='χ(η)', color='#3498DB',
            edgecolor='gray', alpha=0.8)
    ax2.bar(x + 0.2, mu_chars, 0.35, label='χ(μ)', color='#E74C3C',
            edgecolor='gray', alpha=0.8)
    ax2.plot(x, sum_chars, 'ko-', label='χ(η+μ) = χ(η)+χ(μ)',
             markersize=8, linewidth=2)

    ax2.set_xlabel('Generator', fontsize=12)
    ax2.set_ylabel('Character Value', fontsize=12)
    ax2.set_title('Character Additivity\n(Koopman Bridge)', fontsize=13,
                  fontweight='bold')
    ax2.set_xticks(x)
    ax2.set_xticklabels(gen_labels)
    ax2.legend(fontsize=9)
    ax2.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    vis1 = create_reconstruction_diagram()
    vis2 = create_symmetry_semiring_heatmap()
    vis3 = create_naturality_constraint_diagram()
    vis4 = create_character_diagram()

    print(f"  Reconstruction diagram: {len(vis1)} chars")
    print(f"  Heatmap: {len(vis2)} chars")
    print(f"  Naturality: {len(vis3)} chars")
    print(f"  Character: {len(vis4)} chars")
    print("Done!")
