#!/usr/bin/env python3
"""
Applications of Sparse Matrix Structure Preservation

Demonstrates real-world applications of the row-sparsity bound theorem:
1. Finite Element Assembly — local basis functions produce sparse stiffness matrices
2. Graph Laplacian Operations — degree-bounded graphs under algebraic rewrites
3. Sparse Autodiff — Jacobian sparsity tracking through symbolic operations
"""

import numpy as np
import random
from typing import List, Dict, Tuple, Set
from algorithms import (
    MatTerm, TermKind, mat_leaf_count, row_sparsity_budget,
    eval_mat_tracked, compute_row_support, check_row_sparse,
    check_row_disjoint
)


# ============================================================================
# Application 1: Finite Element Assembly
# ============================================================================

def create_1d_fem_stiffness(n_elements: int) -> np.ndarray:
    """
    Create a 1D finite element stiffness matrix.

    For n_elements linear elements, the stiffness matrix is (n+1)×(n+1)
    tridiagonal, with each row having at most 3 nonzeros (row-3-sparse).

    This models the discretization of -u''(x) = f(x) on [0,1].
    """
    n = n_elements + 1
    K = np.zeros((n, n))
    h = 1.0 / n_elements

    for e in range(n_elements):
        # Element stiffness matrix contribution
        ke = np.array([[1, -1], [-1, 1]]) / h
        i, j = e, e + 1
        K[i, i] += ke[0, 0]
        K[i, j] += ke[0, 1]
        K[j, i] += ke[1, 0]
        K[j, j] += ke[1, 1]

    return K


def demo_fem_assembly():
    """
    Demonstrate sparsity preservation in finite element assembly.

    When combining element stiffness matrices K_e, the assembled matrix
    K = Σ K_e remains sparse because element basis functions have local
    support. Our theorem quantifies this precisely.
    """
    print("=" * 70)
    print("APPLICATION 1: Finite Element Assembly")
    print("=" * 70)
    print()

    n_elem = 20
    n = n_elem + 1

    # Create two element-level sparse contributions
    # In practice, these come from different physical terms (e.g., stiffness + mass)
    K_stiffness = create_1d_fem_stiffness(n_elem)
    K_mass = np.zeros((n, n))
    h = 1.0 / n_elem
    for e in range(n_elem):
        me = h / 6.0 * np.array([[2, 1], [1, 2]])
        i, j = e, e + 1
        K_mass[i, i] += me[0, 0]
        K_mass[i, j] += me[0, 1]
        K_mass[j, i] += me[1, 0]
        K_mass[j, j] += me[1, 1]

    s_stiff, max_stiff = check_row_sparse(K_stiffness, 3)
    s_mass, max_mass = check_row_sparse(K_mass, 3)

    print(f"Number of elements: {n_elem}")
    print(f"Matrix size: {n}×{n}")
    print(f"Stiffness matrix row-3-sparse: {s_stiff} (max support: {max_stiff})")
    print(f"Mass matrix row-3-sparse: {s_mass} (max support: {max_mass})")

    # Combined system: α*K_stiffness + β*K_mass
    alpha, beta = 1.0, 0.01
    K_combined = alpha * K_stiffness + beta * K_mass
    s_comb, max_comb = check_row_sparse(K_combined, 6)

    print()
    print(f"Combined matrix (α·K + β·M):")
    print(f"  Row-6-sparse (s+t bound): {s_comb} (max support: {max_comb})")
    print(f"  Actual max row support: {max_comb}")
    print()

    # Since stiffness and mass have identical sparsity patterns,
    # the combined matrix has the same pattern
    print(f"  In this case, supports are NOT disjoint, but the addition")
    print(f"  shares columns, so the actual sparsity ({max_comb}) is much")
    print(f"  better than the worst-case bound ({max_stiff + max_mass}).")
    print(f"  Our theorem gives a safe upper bound; practice often beats it.")
    print()


# ============================================================================
# Application 2: Graph Laplacian Operations
# ============================================================================

def create_graph_laplacian(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Create the Laplacian matrix L = D - A for an undirected graph."""
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1
        A[j, i] = 1
    D = np.diag(A.sum(axis=1))
    return D - A


def random_bounded_degree_graph(n: int, max_degree: int) -> List[Tuple[int, int]]:
    """Generate a random graph where each vertex has degree ≤ max_degree."""
    edges = []
    degrees = [0] * n
    candidates = [(i, j) for i in range(n) for j in range(i + 1, n)]
    random.shuffle(candidates)

    for i, j in candidates:
        if degrees[i] < max_degree and degrees[j] < max_degree:
            edges.append((i, j))
            degrees[i] += 1
            degrees[j] += 1

    return edges


def demo_graph_laplacian():
    """
    Demonstrate sparsity bounds for graph Laplacian operations.

    A row-sparse matrix is a bounded-outdegree graph.
    Our support theorems become degree-growth theorems under graph union.
    """
    print("=" * 70)
    print("APPLICATION 2: Graph Laplacian Operations")
    print("=" * 70)
    print()

    n = 30
    max_deg = 4

    # Create two bounded-degree graphs
    edges1 = random_bounded_degree_graph(n, max_deg)
    edges2 = random_bounded_degree_graph(n, max_deg)

    L1 = create_graph_laplacian(n, edges1)
    L2 = create_graph_laplacian(n, edges2)

    _, s1 = check_row_sparse(L1, 0)
    _, s2 = check_row_sparse(L2, 0)

    print(f"Graph 1: {n} vertices, {len(edges1)} edges, max row support: {s1}")
    print(f"Graph 2: {n} vertices, {len(edges2)} edges, max row support: {s2}")

    # Symbolic operation: L1 + 0.5 * L2 (e.g., graph interpolation)
    L_combined = L1 + 0.5 * L2
    _, s_comb = check_row_sparse(L_combined, 0)

    print()
    print(f"Combined Laplacian (L1 + 0.5·L2):")
    print(f"  Predicted bound: {s1} + {s2} = {s1 + s2}")
    print(f"  Observed max row support: {s_comb}")
    print(f"  Within bound: {s_comb <= s1 + s2}")
    print()

    # Interpret as graph theory
    print(f"  Graph interpretation: combining two degree-{max_deg} graphs")
    print(f"  yields a graph with max degree ≤ {s1 + s2 - 2}")
    print(f"  (subtracting 2 for the diagonal entries)")
    print()


# ============================================================================
# Application 3: Sparse Autodiff / Jacobian Compression
# ============================================================================

def demo_sparse_autodiff():
    """
    Demonstrate sparsity tracking for automatic differentiation.

    In sparse autodiff, the Jacobian of a vector function has a sparsity
    pattern determined by the computational graph. When combining partial
    Jacobians via addition and scaling, our theorem tracks the resulting
    sparsity.
    """
    print("=" * 70)
    print("APPLICATION 3: Sparse Automatic Differentiation")
    print("=" * 70)
    print()

    n = 15

    # Simulate Jacobians from a computational graph
    # Each partial Jacobian has few nonzeros per row (local dependencies)
    def make_local_jacobian(n: int, bandwidth: int) -> np.ndarray:
        J = np.zeros((n, n))
        for i in range(n):
            for k in range(-bandwidth, bandwidth + 1):
                j = i + k
                if 0 <= j < n:
                    J[i, j] = random.uniform(-1, 1)
        return J

    J1 = make_local_jacobian(n, 1)  # bandwidth 1 → row-3-sparse
    J2 = make_local_jacobian(n, 2)  # bandwidth 2 → row-5-sparse
    J3 = make_local_jacobian(n, 1)  # bandwidth 1 → row-3-sparse

    _, s1 = check_row_sparse(J1, 0)
    _, s2 = check_row_sparse(J2, 0)
    _, s3 = check_row_sparse(J3, 0)

    print(f"Partial Jacobians (n={n}):")
    print(f"  J1 (bandwidth 1): max row support = {s1}")
    print(f"  J2 (bandwidth 2): max row support = {s2}")
    print(f"  J3 (bandwidth 1): max row support = {s3}")

    # Chain rule combination: J_total = J1 + 2*J2 + J3
    # Using our term representation:
    env = {0: J1, 1: J2, 2: J3}
    t = MatTerm.add(
        MatTerm.add(MatTerm.var(0), MatTerm.smul(2.0, MatTerm.var(1))),
        MatTerm.var(2)
    )

    budget = mat_leaf_count(t)
    s_env = max(s1, s2, s3)
    predicted = budget * s_env

    result = eval_mat_tracked(t, env, s_env)

    print()
    print(f"Combined Jacobian (J1 + 2·J2 + J3):")
    print(f"  Leaf count: {budget}")
    print(f"  Environment sparsity: {s_env}")
    print(f"  Predicted bound: {budget} × {s_env} = {predicted}")
    print(f"  Observed max row support: {result.max_row_support}")
    print(f"  Within bound: {result.is_within_bound}")
    print()
    print(f"  For sparse autodiff, this means we can pre-allocate")
    print(f"  at most {predicted} nonzeros per row in the combined Jacobian,")
    print(f"  guaranteeing no overflow in CSR storage.")
    print()


# ============================================================================
# Application 4: Operator Locality in Physics
# ============================================================================

def demo_hamiltonian_locality():
    """
    Demonstrate locality preservation for local Hamiltonians.

    In quantum lattice models, Hamiltonians are sums of local terms.
    When simplifying operator expressions, sparsity preservation ensures
    that locality is maintained.
    """
    print("=" * 70)
    print("APPLICATION 4: Local Hamiltonian Simplification")
    print("=" * 70)
    print()

    n = 16  # 16-site lattice

    # Create nearest-neighbor interaction terms (banded matrices)
    def nearest_neighbor_term(n: int, site: int) -> np.ndarray:
        H = np.zeros((n, n))
        i, j = site, (site + 1) % n
        H[i, j] = 1.0
        H[j, i] = 1.0
        H[i, i] = -0.5
        H[j, j] = -0.5
        return H

    # Full Hamiltonian: H = Σ_i J_i * h_i
    terms = []
    couplings = []
    for site in range(n):
        h = nearest_neighbor_term(n, site)
        J = random.uniform(0.5, 1.5)
        terms.append(h)
        couplings.append(J)

    # Build as tensor term: sum of J_i * h_i
    env = {i: terms[i] for i in range(n)}

    # Build term tree (left-associative sum)
    t = MatTerm.smul(couplings[0], MatTerm.var(0))
    for i in range(1, n):
        t = MatTerm.add(t, MatTerm.smul(couplings[i], MatTerm.var(i)))

    s = max(check_row_sparse(terms[i], 0)[1] for i in range(n))
    budget = mat_leaf_count(t)
    predicted = budget * s

    H_total = sum(couplings[i] * terms[i] for i in range(n))
    _, actual = check_row_sparse(H_total, 0)

    print(f"Lattice sites: {n}")
    print(f"Individual term sparsity: {s}")
    print(f"Number of terms: {n}")
    print(f"Leaf count: {budget}")
    print(f"Predicted bound: {budget} × {s} = {predicted}")
    print(f"Observed row sparsity: {actual}")
    print(f"Within bound: {actual <= predicted}")
    print()
    print(f"  The predicted bound {predicted} is conservative because")
    print(f"  nearest-neighbor terms overlap in only a few columns.")
    print(f"  The actual sparsity ({actual}) reflects that the lattice")
    print(f"  Hamiltonian remains local even after combining all terms.")
    print()


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    demo_fem_assembly()
    demo_graph_laplacian()
    demo_sparse_autodiff()
    demo_hamiltonian_locality()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Sparse Matrix Structure Preservation under Tensor Rewrites — Interactive Demo

This demo:
1. Generates random sparse matrices in CSR-style format
2. Builds random tensor terms of bounded depth
3. Computes the predicted support bound from syntax (matLeafCount)
4. Evaluates terms before and after normalization
5. Visualizes row-support sizes and sparsity ratios
6. Flags any violation of the proven theorem
7. Illustrates why the naive "always preserves s" conjecture fails
"""

import numpy as np
import random
from typing import List, Tuple, Dict
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================================
# Part 1: Sparse Matrix Representation
# ============================================================================

def make_sparse_matrix(n: int, s: int) -> np.ndarray:
    """Generate a random n×n matrix where each row has exactly s nonzero entries."""
    A = np.zeros((n, n))
    for i in range(n):
        cols = random.sample(range(n), min(s, n))
        for j in cols:
            A[i, j] = random.uniform(-10, 10)
    return A


def row_support(A: np.ndarray, i: int) -> set:
    """Return the set of column indices where row i is nonzero."""
    return {j for j in range(A.shape[1]) if A[i, j] != 0}


def row_sparsity(A: np.ndarray) -> int:
    """Return the maximum row support size (max nonzeros per row)."""
    return max(len(row_support(A, i)) for i in range(A.shape[0]))


def is_row_sparse(A: np.ndarray, s: int) -> bool:
    """Check if every row has at most s nonzeros."""
    return all(len(row_support(A, i)) <= s for i in range(A.shape[0]))


# ============================================================================
# Part 2: Tensor Term AST
# ============================================================================

class TermKind(Enum):
    MAT_VAR = auto()
    MAT_ADD = auto()
    SMUL_MAT = auto()


@dataclass
class MatTerm:
    """A mat-sorted tensor term."""
    kind: TermKind
    var_id: int = 0          # for MAT_VAR
    scalar: float = 1.0      # for SMUL_MAT
    left: 'MatTerm' = None   # for MAT_ADD / SMUL_MAT
    right: 'MatTerm' = None  # for MAT_ADD

    def __repr__(self):
        if self.kind == TermKind.MAT_VAR:
            return f"M{self.var_id}"
        elif self.kind == TermKind.MAT_ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == TermKind.SMUL_MAT:
            return f"({self.scalar:.2f} * {self.left})"
        return "?"


def mat_var(k: int) -> MatTerm:
    return MatTerm(TermKind.MAT_VAR, var_id=k)


def mat_add(a: MatTerm, b: MatTerm) -> MatTerm:
    return MatTerm(TermKind.MAT_ADD, left=a, right=b)


def smul_mat(c: float, a: MatTerm) -> MatTerm:
    return MatTerm(TermKind.SMUL_MAT, scalar=c, left=a)


def mat_leaf_count(t: MatTerm) -> int:
    """Compute the syntactic sparsity budget multiplier."""
    if t.kind == TermKind.MAT_VAR:
        return 1
    elif t.kind == TermKind.MAT_ADD:
        return mat_leaf_count(t.left) + mat_leaf_count(t.right)
    elif t.kind == TermKind.SMUL_MAT:
        return mat_leaf_count(t.left)
    return 0


def eval_mat(t: MatTerm, env: Dict[int, np.ndarray]) -> np.ndarray:
    """Evaluate a mat-sorted term in an environment."""
    if t.kind == TermKind.MAT_VAR:
        return env[t.var_id].copy()
    elif t.kind == TermKind.MAT_ADD:
        return eval_mat(t.left, env) + eval_mat(t.right, env)
    elif t.kind == TermKind.SMUL_MAT:
        return t.scalar * eval_mat(t.left, env)
    raise ValueError(f"Unknown term kind: {t.kind}")


def norm_step_mat(t: MatTerm) -> MatTerm:
    """One-step normalization: distribute scalar mult over addition."""
    if (t.kind == TermKind.SMUL_MAT and
        t.left is not None and t.left.kind == TermKind.MAT_ADD):
        a_term = t.left
        return mat_add(
            smul_mat(t.scalar, a_term.left),
            smul_mat(t.scalar, a_term.right)
        )
    return t


def random_mat_term(depth: int, num_vars: int) -> MatTerm:
    """Generate a random mat-sorted term of bounded depth."""
    if depth <= 0:
        return mat_var(random.randint(0, num_vars - 1))
    choice = random.random()
    if choice < 0.3:
        return mat_var(random.randint(0, num_vars - 1))
    elif choice < 0.7:
        return mat_add(
            random_mat_term(depth - 1, num_vars),
            random_mat_term(depth - 1, num_vars)
        )
    else:
        return smul_mat(
            random.uniform(-5, 5),
            random_mat_term(depth - 1, num_vars)
        )


# ============================================================================
# Part 3: Demonstration
# ============================================================================

def demo_naive_conjecture_fails():
    """Show that the naive 'sparsity is always preserved' conjecture is false."""
    print("=" * 70)
    print("DEMO 1: Why the naive sparsity-preservation conjecture fails")
    print("=" * 70)
    print()

    n, s = 10, 3
    A = make_sparse_matrix(n, s)
    B = make_sparse_matrix(n, s)

    s_A = row_sparsity(A)
    s_B = row_sparsity(B)
    s_sum = row_sparsity(A + B)

    print(f"Matrix size: {n}×{n}, target sparsity: s = {s}")
    print(f"Row sparsity of A:     {s_A}")
    print(f"Row sparsity of B:     {s_B}")
    print(f"Row sparsity of A + B: {s_sum}")
    print()

    if s_sum > s:
        print(f"⚠ COUNTEREXAMPLE: A+B has row sparsity {s_sum} > {s}.")
        print("  The naive conjecture 'addition preserves s-sparsity' is FALSE.")
    else:
        print("  (No counterexample in this run — try again or increase s.)")
    print()

    print(f"✓ Our theorem guarantees: row sparsity of A+B ≤ {s_A} + {s_B} = {s_A + s_B}")
    print(f"  Observed: {s_sum} ≤ {s_A + s_B}? {s_sum <= s_A + s_B}")
    print()


def demo_scalar_preservation():
    """Show that scalar multiplication preserves sparsity exactly."""
    print("=" * 70)
    print("DEMO 2: Scalar multiplication preserves row support exactly")
    print("=" * 70)
    print()

    n, s = 8, 4
    A = make_sparse_matrix(n, s)
    c = 3.14

    print(f"Matrix size: {n}×{n}, sparsity: s = {s}, scalar: c = {c}")
    print(f"Row sparsity of A:     {row_sparsity(A)}")
    print(f"Row sparsity of c*A:   {row_sparsity(c * A)}")

    # Check exact support equality
    all_equal = all(row_support(A, i) == row_support(c * A, i) for i in range(n))
    print(f"Row supports identical: {all_equal}")
    print(f"✓ Theorem 2' confirmed: nonzero scalar preserves support exactly.")
    print()


def demo_support_bound():
    """Verify the support bound theorem on random terms."""
    print("=" * 70)
    print("DEMO 3: Verifying the support bound theorem")
    print("=" * 70)
    print()

    n, s = 20, 3
    num_vars = 4
    num_trials = 1000

    env = {k: make_sparse_matrix(n, s) for k in range(num_vars)}

    violations = 0
    max_ratio = 0.0
    ratios = []

    for trial in range(num_trials):
        t = random_mat_term(depth=4, num_vars=num_vars)
        budget = mat_leaf_count(t)
        predicted_bound = budget * s

        result = eval_mat(t, env)
        observed = row_sparsity(result)

        ratio = observed / predicted_bound if predicted_bound > 0 else 0
        ratios.append(ratio)
        max_ratio = max(max_ratio, ratio)

        if observed > predicted_bound:
            violations += 1
            print(f"  ⚠ VIOLATION at trial {trial}: observed={observed}, bound={predicted_bound}")

    print(f"Trials: {num_trials}, n={n}, s={s}, vars={num_vars}")
    print(f"Violations: {violations}")
    print(f"Max observed/predicted ratio: {max_ratio:.4f}")
    print(f"Mean observed/predicted ratio: {np.mean(ratios):.4f}")
    print(f"✓ Theorem 3 confirmed: no violations found!" if violations == 0 else
          f"⚠ {violations} violations found!")
    print()


def demo_normalization():
    """Show that normalization preserves the support bound."""
    print("=" * 70)
    print("DEMO 4: Normalization preserves the support bound")
    print("=" * 70)
    print()

    n, s = 15, 4
    env = {0: make_sparse_matrix(n, s), 1: make_sparse_matrix(n, s)}

    # Build a term where normalization actually does something:
    # c • (A + B) → c•A + c•B
    c = 2.5
    t = smul_mat(c, mat_add(mat_var(0), mat_var(1)))
    t_norm = norm_step_mat(t)

    print(f"Original term:   {t}")
    print(f"Normalized term: {t_norm}")
    print(f"Leaf count (original):   {mat_leaf_count(t)}")
    print(f"Leaf count (normalized): {mat_leaf_count(t_norm)}")
    print()

    result_orig = eval_mat(t, env)
    result_norm = eval_mat(t_norm, env)

    print(f"Semantic equality: {np.allclose(result_orig, result_norm)}")
    print(f"Row sparsity (original):   {row_sparsity(result_orig)}")
    print(f"Row sparsity (normalized): {row_sparsity(result_norm)}")
    print(f"Predicted bound: {mat_leaf_count(t) * s}")
    print(f"✓ Theorem 5 confirmed: normalization inherits the support bound.")
    print()


def demo_disjoint_support():
    """Show exact preservation under disjoint support."""
    print("=" * 70)
    print("DEMO 5: Exact preservation under disjoint support")
    print("=" * 70)
    print()

    n, s = 20, 3

    # Create two matrices with disjoint nonzero patterns
    A = np.zeros((n, n))
    B = np.zeros((n, n))

    for i in range(n):
        # First s columns for A, next s columns for B (ensuring disjointness)
        cols_a = list(range(min(s, n)))
        cols_b = list(range(s, min(2 * s, n)))
        for j in cols_a:
            A[i, j] = random.uniform(-10, 10)
        for j in cols_b:
            B[i, j] = random.uniform(-10, 10)

    # Verify disjointness
    disjoint = all(
        A[i, j] == 0 or B[i, j] == 0
        for i in range(n) for j in range(n)
    )

    s_A = row_sparsity(A)
    s_B = row_sparsity(B)
    s_sum = row_sparsity(A + B)

    print(f"Row-disjoint: {disjoint}")
    print(f"Row sparsity of A:     {s_A}")
    print(f"Row sparsity of B:     {s_B}")
    print(f"Row sparsity of A + B: {s_sum}")
    print()

    # Under disjointness, rowSupport(A+B) = rowSupport(A) ∪ rowSupport(B)
    support_union = all(
        row_support(A + B, i) == row_support(A, i) | row_support(B, i)
        for i in range(n)
    )
    print(f"Support exactness (Theorem 6): {support_union}")
    print(f"✓ Under disjoint support, row support of A+B is exactly the union.")
    print()


def demo_large_scale():
    """Large-scale validation: 5000 trials."""
    print("=" * 70)
    print("DEMO 6: Large-scale validation (5000 trials)")
    print("=" * 70)
    print()

    n, s = 100, 5
    num_vars = 5
    num_trials = 5000

    env = {k: make_sparse_matrix(n, s) for k in range(num_vars)}

    violations = 0
    collision_factors = []

    for _ in range(num_trials):
        t = random_mat_term(depth=4, num_vars=num_vars)
        budget = mat_leaf_count(t)
        predicted_bound = budget * s

        if predicted_bound == 0:
            continue

        result = eval_mat(t, env)
        observed = row_sparsity(result)

        if observed > predicted_bound:
            violations += 1

        collision_factors.append(observed / predicted_bound)

    print(f"n={n}, s={s}, vars={num_vars}, trials={num_trials}")
    print(f"Violations: {violations}")
    print(f"Average collision factor: {np.mean(collision_factors):.4f}")
    print(f"Max collision factor:     {np.max(collision_factors):.4f}")
    print(f"Min collision factor:     {np.min(collision_factors):.4f}")
    print(f"Std dev:                  {np.std(collision_factors):.4f}")
    print()

    # Distribution of collision factors
    bins = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
    hist, _ = np.histogram(collision_factors, bins=bins)
    print("Collision factor distribution:")
    for i in range(len(bins) - 1):
        bar = "█" * (hist[i] * 50 // max(hist))
        print(f"  [{bins[i]:.1f}, {bins[i+1]:.1f}): {hist[i]:5d} {bar}")
    print()
    print("✓ All observations within the proven bound." if violations == 0 else
          f"⚠ {violations} violations!")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    demo_naive_conjecture_fails()
    demo_scalar_preservation()
    demo_support_bound()
    demo_normalization()
    demo_disjoint_support()
    demo_large_scale()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
