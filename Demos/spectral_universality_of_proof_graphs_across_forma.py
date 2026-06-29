"""
Spectral Proof Universality — Applications

Demonstrates real-world applications of spectral proof graph theory:
1. Proof complexity classification via spectral invariants
2. Cross-system proof comparison
3. Automated transfer learning signatures
"""

import numpy as np
from numpy.linalg import eigvalsh
from typing import List, Tuple, Dict
import json


def build_dependency_graph(
    dependencies: Dict[str, List[str]]
) -> Tuple[np.ndarray, List[str]]:
    """
    Build a proof dependency graph from a dependency dictionary.

    Each key is a theorem/lemma name, and the value is a list of
    theorems/lemmas it depends on.

    Args:
        dependencies: {theorem_name: [dependency_names]}

    Returns:
        (adjacency_matrix, vertex_labels)
    """
    all_names = set(dependencies.keys())
    for deps in dependencies.values():
        all_names.update(deps)
    names = sorted(all_names)
    idx = {name: i for i, name in enumerate(names)}
    n = len(names)

    A = np.zeros((n, n))
    for thm, deps in dependencies.items():
        for dep in deps:
            if dep in idx:
                i, j = idx[thm], idx[dep]
                A[i, j] = 1
                A[j, i] = 1  # Moralized/undirected version
    return A, names


def proof_spectral_signature(
    dependencies: Dict[str, List[str]], max_k: int = 8
) -> Dict[str, float]:
    """
    Compute the spectral signature of a proof corpus.

    The signature is the vector of normalized spectral moments
    (μ₀, μ₁, ..., μ_max_k).

    By the universality theorem, two proof corpora with the same
    local dependency structure will have converging signatures
    as they grow.

    Args:
        dependencies: Proof dependency graph.
        max_k: Maximum moment order.

    Returns:
        Dictionary of spectral invariants.
    """
    A, names = build_dependency_graph(dependencies)
    n = A.shape[0]
    eigenvalues = eigvalsh(A)

    signature = {}
    signature["n_vertices"] = n
    signature["n_edges"] = int(np.sum(A) / 2)
    signature["max_degree"] = int(np.max(np.sum(A, axis=1)))
    signature["spectral_radius"] = float(np.max(np.abs(eigenvalues)))

    for k in range(max_k + 1):
        signature[f"moment_{k}"] = float(np.sum(eigenvalues**k) / n)

    return signature


def compare_proof_systems(
    system_A: Dict[str, List[str]],
    system_B: Dict[str, List[str]],
    max_k: int = 8
) -> Dict[str, float]:
    """
    Compare two proof systems via their spectral signatures.

    Returns moment differences that indicate how similar the
    proof structures are. By the universality theorem, these
    differences converge to 0 if and only if the systems have
    the same local proof geometry.

    Args:
        system_A, system_B: Proof dependency graphs.
        max_k: Maximum moment order.

    Returns:
        Dictionary of comparison metrics.
    """
    sig_A = proof_spectral_signature(system_A, max_k)
    sig_B = proof_spectral_signature(system_B, max_k)

    comparison = {}
    comparison["size_A"] = sig_A["n_vertices"]
    comparison["size_B"] = sig_B["n_vertices"]

    for k in range(max_k + 1):
        diff = abs(sig_A[f"moment_{k}"] - sig_B[f"moment_{k}"])
        comparison[f"moment_diff_{k}"] = diff

    # Overall distance: L∞ norm of moment differences
    max_diff = max(
        comparison[f"moment_diff_{k}"] for k in range(max_k + 1)
    )
    comparison["max_moment_difference"] = max_diff

    return comparison


def classify_proof_complexity(
    dependencies: Dict[str, List[str]]
) -> str:
    """
    Classify proof complexity using spectral invariants.

    Uses the spectral radius and moment ratios as features.
    The classification is based on empirical thresholds
    inspired by the complexity-phase hypothesis.

    Args:
        dependencies: Proof dependency graph.

    Returns:
        Complexity class: "elementary", "algebraic", or "abstract"
    """
    sig = proof_spectral_signature(dependencies, 6)
    spectral_radius = sig["spectral_radius"]
    max_degree = sig["max_degree"]

    # Ratio of 4th moment to square of 2nd moment
    # (measures "heaviness" of spectral tails)
    if sig["moment_2"] > 0:
        kurtosis_ratio = sig["moment_4"] / (sig["moment_2"] ** 2)
    else:
        kurtosis_ratio = 0

    if max_degree <= 3 and kurtosis_ratio < 2.5:
        return "elementary"
    elif max_degree <= 8 and kurtosis_ratio < 5.0:
        return "algebraic"
    else:
        return "abstract"


# ============================================================
# Application 1: Simulated Proof Corpora
# ============================================================
print("=" * 60)
print("APPLICATION 1: Spectral Signatures of Proof Systems")
print("=" * 60)

# Simulate a simple arithmetic proof corpus
arithmetic_proofs = {
    "add_comm": [],
    "add_assoc": [],
    "add_zero": [],
    "mul_comm": ["add_comm"],
    "mul_assoc": ["add_assoc", "mul_comm"],
    "mul_zero": ["add_zero", "mul_comm"],
    "distrib": ["mul_comm", "add_assoc"],
    "mul_one": ["mul_zero", "add_zero"],
    "pow_succ": ["mul_assoc", "mul_one"],
    "pow_zero": ["mul_one"],
    "sum_formula": ["add_comm", "add_assoc", "mul_comm", "distrib"],
    "binomial": ["pow_succ", "distrib", "mul_comm"],
}

# Simulate an algebra proof corpus with similar structure
algebra_proofs = {
    "group_assoc": [],
    "group_id": [],
    "group_inv": [],
    "comm_group": ["group_assoc"],
    "ring_assoc": ["group_assoc", "comm_group"],
    "ring_zero": ["group_id", "comm_group"],
    "ring_distrib": ["comm_group", "group_assoc"],
    "ring_one": ["ring_zero", "group_id"],
    "ideal_def": ["ring_assoc", "ring_one"],
    "ideal_zero": ["ring_one"],
    "quotient_ring": ["group_assoc", "group_assoc", "comm_group", "ring_distrib"],
    "isomorphism_thm": ["ideal_def", "ring_distrib", "comm_group"],
}

sig_arith = proof_spectral_signature(arithmetic_proofs)
sig_alg = proof_spectral_signature(algebra_proofs)

print("\nArithmetic proof corpus:")
for key, val in sig_arith.items():
    if isinstance(val, float):
        print(f"  {key}: {val:.6f}")
    else:
        print(f"  {key}: {val}")

print("\nAlgebra proof corpus:")
for key, val in sig_alg.items():
    if isinstance(val, float):
        print(f"  {key}: {val:.6f}")
    else:
        print(f"  {key}: {val}")


# ============================================================
# Application 2: Cross-System Comparison
# ============================================================
print("\n" + "=" * 60)
print("APPLICATION 2: Cross-System Proof Comparison")
print("=" * 60)

comparison = compare_proof_systems(arithmetic_proofs, algebra_proofs)
print("\nArithmetic vs. Algebra:")
for key, val in comparison.items():
    if isinstance(val, float):
        print(f"  {key}: {val:.6f}")
    else:
        print(f"  {key}: {val}")

# Compare arithmetic with itself (should be zero difference)
self_comparison = compare_proof_systems(arithmetic_proofs, arithmetic_proofs)
print("\nArithmetic vs. Arithmetic (self-comparison):")
print(f"  max_moment_difference: {self_comparison['max_moment_difference']:.6f}")


# ============================================================
# Application 3: Complexity Classification
# ============================================================
print("\n" + "=" * 60)
print("APPLICATION 3: Proof Complexity Classification")
print("=" * 60)

# Simple linear proof chain (elementary)
simple_proofs = {f"lemma_{i}": [f"lemma_{i-1}"] if i > 0 else []
                 for i in range(10)}

# Dense interconnected proofs (abstract)
dense_proofs = {}
for i in range(15):
    deps = [f"thm_{j}" for j in range(max(0, i-5), i)]
    dense_proofs[f"thm_{i}"] = deps

for name, corpus in [("Arithmetic", arithmetic_proofs),
                      ("Algebra", algebra_proofs),
                      ("Simple chain", simple_proofs),
                      ("Dense network", dense_proofs)]:
    complexity = classify_proof_complexity(corpus)
    sig = proof_spectral_signature(corpus, 4)
    print(f"\n{name}:")
    print(f"  Classification: {complexity}")
    print(f"  Vertices: {sig['n_vertices']}, Edges: {sig['n_edges']}")
    print(f"  Max degree: {sig['max_degree']}")
    print(f"  Spectral radius: {sig['spectral_radius']:.4f}")


# ============================================================
# Application 4: Perturbation Analysis
# ============================================================
print("\n" + "=" * 60)
print("APPLICATION 4: Normalization Invariance Check")
print("=" * 60)

# Original proof corpus
original = arithmetic_proofs.copy()

# "Normalized" version: unfold one definition (add mul_one dependency)
normalized = arithmetic_proofs.copy()
normalized["pow_succ"] = ["mul_assoc", "mul_one", "add_zero"]  # extra dep
normalized["binomial_alt"] = normalized.pop("binomial")  # rename

A_orig, _ = build_dependency_graph(original)
A_norm, _ = build_dependency_graph(normalized)

# Pad to same size
n = max(A_orig.shape[0], A_norm.shape[0])
A_orig_pad = np.zeros((n, n))
A_norm_pad = np.zeros((n, n))
A_orig_pad[:A_orig.shape[0], :A_orig.shape[1]] = A_orig
A_norm_pad[:A_norm.shape[0], :A_norm.shape[1]] = A_norm

diff_rows = np.sum(np.any(A_orig_pad - A_norm_pad != 0, axis=1))
print(f"\nRows changed by normalization: {diff_rows}")
print(f"Total vertices: {n}")
print(f"Perturbation ratio: {diff_rows/n:.4f}")

print("\nMoment differences (should be small for large corpora):")
ev_orig = eigvalsh(A_orig_pad)
ev_norm = eigvalsh(A_norm_pad)
for k in range(7):
    mom_orig = np.sum(ev_orig**k) / n
    mom_norm = np.sum(ev_norm**k) / n
    print(f"  k={k}: |Δμ_k| = {abs(mom_orig - mom_norm):.6f}")


print("\n" + "=" * 60)
print("All applications complete.")
print("=" * 60)


"""
Spectral Proof Universality — Demonstrations

This script demonstrates the key mathematical results formalized in the
Lean development, using concrete numerical examples:

1. The trace-eigenvalue identity: tr(A^k) = Σ λ_i^k
2. Spectral moments of graph adjacency matrices
3. Perturbation stability of spectral measures
4. Walk counting via matrix powers
"""

import numpy as np
from numpy.linalg import eigh
from collections import Counter

def adjacency_matrix(edges, n):
    """Build adjacency matrix from edge list."""
    A = np.zeros((n, n))
    for (i, j) in edges:
        A[i, j] = 1
        A[j, i] = 1
    return A


def empirical_spectral_moments(A, max_k=10):
    """Compute empirical spectral moments: (1/n) Σ λ_i^k."""
    eigenvalues = eigh(A)[0]
    n = len(eigenvalues)
    return {k: np.sum(eigenvalues**k) / n for k in range(max_k + 1)}


def normalized_trace_powers(A, max_k=10):
    """Compute normalized traces: tr(A^k) / n."""
    n = A.shape[0]
    result = {}
    Ak = np.eye(n)
    for k in range(max_k + 1):
        result[k] = np.trace(Ak) / n
        Ak = Ak @ A
    return result


def count_closed_walks(A, k):
    """Count closed walks of length k via tr(A^k)."""
    n = A.shape[0]
    Ak = np.linalg.matrix_power(A, k)
    return int(round(np.trace(Ak)))


def spectral_distance(A, B):
    """Kolmogorov distance between empirical spectral measures."""
    ev_A = np.sort(eigh(A)[0])
    ev_B = np.sort(eigh(B)[0])
    # Create combined sorted list of all eigenvalues
    all_vals = np.sort(np.concatenate([ev_A, ev_B]))
    max_diff = 0
    for x in all_vals:
        cdf_A = np.mean(ev_A <= x)
        cdf_B = np.mean(ev_B <= x)
        max_diff = max(max_diff, abs(cdf_A - cdf_B))
    return max_diff


# ============================================================
# Demo 1: Trace-Eigenvalue Identity
# ============================================================
print("=" * 60)
print("DEMO 1: Trace-Eigenvalue Identity")
print("tr(A^k) = Σ λ_i^k  for symmetric matrices")
print("=" * 60)

# Random symmetric matrix
np.random.seed(42)
n = 5
M = np.random.randn(n, n)
A = (M + M.T) / 2  # Symmetrize

eigenvalues = eigh(A)[0]
print(f"\nMatrix size: {n}×{n}")
print(f"Eigenvalues: {eigenvalues.round(4)}")

print(f"\n{'k':>3} | {'tr(A^k)':>15} | {'Σ λ_i^k':>15} | {'Match':>8}")
print("-" * 50)
for k in range(7):
    Ak = np.linalg.matrix_power(A, k)
    trace_val = np.trace(Ak)
    eigen_sum = np.sum(eigenvalues**k)
    match = abs(trace_val - eigen_sum) < 1e-8
    print(f"{k:3d} | {trace_val:15.6f} | {eigen_sum:15.6f} | {'✓' if match else '✗':>8}")


# ============================================================
# Demo 2: Walk Counting in Graphs
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Closed Walk Counting")
print("tr(A^k) = number of closed walks of length k")
print("=" * 60)

# Cycle graph C5
edges_C5 = [(0,1), (1,2), (2,3), (3,4), (4,0)]
A_C5 = adjacency_matrix(edges_C5, 5)

# Complete graph K4
edges_K4 = [(i,j) for i in range(4) for j in range(i+1, 4)]
A_K4 = adjacency_matrix(edges_K4, 4)

# Path graph P4
edges_P4 = [(0,1), (1,2), (2,3)]
A_P4 = adjacency_matrix(edges_P4, 4)

for name, A_g in [("Cycle C₅", A_C5), ("Complete K₄", A_K4), ("Path P₄", A_P4)]:
    print(f"\n{name}:")
    for k in range(1, 7):
        walks = count_closed_walks(A_g, k)
        print(f"  Closed walks of length {k}: {walks}")


# ============================================================
# Demo 3: Spectral Moment Equality
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Spectral Moments = Normalized Traces")
print("empiricalSpectralMoment(A, k) = normalizedTrace(A^k)")
print("=" * 60)

A_g = A_K4
moments = empirical_spectral_moments(A_g, 8)
traces = normalized_trace_powers(A_g, 8)

print(f"\nComplete graph K₄:")
print(f"{'k':>3} | {'Spectral moment':>15} | {'Norm. trace':>15} | {'Match':>8}")
print("-" * 50)
for k in range(9):
    match = abs(moments[k] - traces[k]) < 1e-10
    print(f"{k:3d} | {moments[k]:15.6f} | {traces[k]:15.6f} | {'✓' if match else '✗':>8}")


# ============================================================
# Demo 4: Perturbation Stability
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Spectral Stability Under Perturbation")
print("|tr(A^k) - tr(B^k)| ≤ 2n·R^k")
print("=" * 60)

# Start with a random graph, perturb by changing a few edges
np.random.seed(123)
n = 20
p = 0.3
adj = np.random.random((n, n)) < p
adj = np.triu(adj, 1)
A_base = (adj + adj.T).astype(float)

# Perturb: change edges involving vertex 0 only
A_perturbed = A_base.copy()
for j in range(1, 5):
    A_perturbed[0, j] = 1 - A_perturbed[0, j]
    A_perturbed[j, 0] = A_perturbed[0, j]

nonzero_rows = np.sum(np.any(A_base - A_perturbed != 0, axis=1))
R = max(max(abs(eigh(A_base)[0])), max(abs(eigh(A_perturbed)[0])))

print(f"\nGraph size: {n}")
print(f"Nonzero rows in perturbation: {nonzero_rows}")
print(f"Spectral radius bound R: {R:.4f}")

print(f"\n{'k':>3} | {'|tr(A^k)-tr(B^k)|':>18} | {'2n·R^k bound':>15} | {'Satisfied':>9}")
print("-" * 55)
for k in range(1, 8):
    diff = abs(np.trace(np.linalg.matrix_power(A_base, k)) -
               np.trace(np.linalg.matrix_power(A_perturbed, k)))
    bound = 2 * n * R**k
    sat = diff <= bound + 1e-8
    print(f"{k:3d} | {diff:18.4f} | {bound:15.4f} | {'✓' if sat else '✗':>9}")


# ============================================================
# Demo 5: Spectral Universality — Same Local Structure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Spectral Universality")
print("Graphs with same local structure → same spectral moments")
print("=" * 60)

# Two different d-regular graphs should have similar spectral behavior
# Build two 3-regular graphs on 8 vertices

# Cube graph (3-regular, 8 vertices)
cube_edges = [(0,1),(1,2),(2,3),(3,0),(4,5),(5,6),(6,7),(7,4),
              (0,4),(1,5),(2,6),(3,7)]
A_cube = adjacency_matrix(cube_edges, 8)

# Möbius-Kantor-like 3-regular graph on 8 vertices
mk_edges = [(0,1),(1,2),(2,3),(3,4),(4,5),(5,6),(6,7),(7,0),
            (0,3),(1,4),(2,5),(3,6)]
A_mk = adjacency_matrix(mk_edges, 8)

print(f"\nCube graph vs another 3-regular graph (8 vertices each):")
mom_cube = empirical_spectral_moments(A_cube, 8)
mom_mk = empirical_spectral_moments(A_mk, 8)

print(f"{'k':>3} | {'Cube moment':>15} | {'Alt. moment':>15} | {'Difference':>12}")
print("-" * 55)
for k in range(9):
    diff = abs(mom_cube[k] - mom_mk[k])
    print(f"{k:3d} | {mom_cube[k]:15.6f} | {mom_mk[k]:15.6f} | {diff:12.6f}")

print("\nNote: k=0,1,2 moments match exactly (both 3-regular).")
print("Higher moments differ when local neighborhoods differ —")
print("this is the content of the universality theorem!")


# ============================================================
# Demo 6: Eigenvalue Distribution Comparison
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Eigenvalue Distributions")
print("=" * 60)

for name, A_g in [("Cycle C₅", A_C5), ("Complete K₄", A_K4),
                   ("Cube", A_cube)]:
    evs = np.sort(eigh(A_g)[0])
    print(f"\n{name} eigenvalues: {evs.round(4)}")
    print(f"  Spectral radius: {max(abs(evs)):.4f}")
    print(f"  Mean eigenvalue: {np.mean(evs):.4f}")
    print(f"  Variance of eigenvalues: {np.var(evs):.4f}")


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)
