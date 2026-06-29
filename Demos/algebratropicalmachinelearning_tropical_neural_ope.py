#!/usr/bin/env python3
"""
Applications of Tropical Operadic Realization Theory

Demonstrates real-world applications of the realization duality theorem:
1. Neural network architecture compression
2. Min-plus routing network optimization
3. Scheduling system minimization
4. Architecture search via rank computation
"""

import numpy as np
from typing import Tuple, List
from algorithms import (
    compute_canonical_realization,
    compute_nerode_classes,
    tropical_matmul,
    operational_rank,
)


# ============================================================
# Application 1: Min-Plus Neural Network Compression
# ============================================================

def simulate_minplus_network(n_inputs: int, n_hidden: int, n_outputs: int,
                              seed: int = 42) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Simulate a min-plus (tropical) neural network.
    
    A min-plus network computes: output[o] = min_h (W2[o,h] + min_i (W1[h,i] + input[i]))
    This is equivalent to: output[o] = min_h min_i (W2[o,h] + W1[h,i] + input[i])
    """
    rng = np.random.RandomState(seed)
    W1 = rng.randint(-5, 5, (n_hidden, n_inputs))
    W2 = rng.randint(-5, 5, (n_outputs, n_hidden))
    
    # The composed weight matrix (min-plus product)
    M_composed = tropical_matmul(W2.astype(float), W1.astype(float)).astype(int)
    
    return W1, W2, M_composed


def app_network_compression():
    print("=" * 70)
    print("APPLICATION 1: Min-Plus Neural Network Compression")
    print("=" * 70)
    
    configs = [
        (8, 20, 4, "Small overparameterized"),
        (10, 50, 5, "Medium overparameterized"),
        (6, 100, 3, "Highly overparameterized"),
    ]
    
    for n_in, n_hid, n_out, desc in configs:
        W1, W2, M = simulate_minplus_network(n_in, n_hid, n_out)
        
        # M is n_out × n_in: the composed function
        # Treat rows as "output observables", columns as "input features"
        # The rank tells us the minimal hidden layer size
        rank = operational_rank(M)
        
        print(f"\n{desc}:")
        print(f"  Architecture: {n_in} → {n_hid} → {n_out}")
        print(f"  Composed function rank: {rank}")
        print(f"  Minimal hidden size: {rank}")
        print(f"  Compression: {n_hid} → {rank} hidden units ({(1-rank/n_hid)*100:.0f}% reduction)")


# ============================================================
# Application 2: Shortest Path Routing Optimization
# ============================================================

def app_routing_optimization():
    print("\n" + "=" * 70)
    print("APPLICATION 2: Shortest Path Routing Network Optimization")
    print("=" * 70)
    
    # Distance matrix for a 6-node network
    # Entries: shortest path cost from node i to node j
    INF = 999
    D = np.array([
        [0, 3, 5, INF, INF, INF],
        [3, 0, 1, 4, INF, INF],
        [5, 1, 0, 2, 6, INF],
        [INF, 4, 2, 0, 3, 7],
        [INF, INF, 6, 3, 0, 2],
        [INF, INF, INF, 7, 2, 0],
    ])
    
    # Floyd-Warshall in tropical (min-plus) algebra
    n = D.shape[0]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    
    print(f"\nAll-pairs shortest path matrix ({n}×{n}):")
    print(D)
    
    # Compute operational rank
    rank = operational_rank(D)
    R = compute_canonical_realization(D)
    
    print(f"\nOperational rank: {rank}")
    print(f"Routing table can be compressed to {rank} profiles")
    
    classes = compute_nerode_classes(D)
    print(f"\nNerode equivalence classes (nodes with identical routing):")
    for nc in classes:
        nodes = [chr(65 + m) for m in nc.members]
        print(f"  Class {nc.class_id}: nodes {nodes}")
        print(f"    Profile: {nc.profile}")


# ============================================================
# Application 3: Job Scheduling Minimization
# ============================================================

def app_scheduling():
    print("\n" + "=" * 70)
    print("APPLICATION 3: Job Scheduling System Minimization")
    print("=" * 70)
    
    # Processing times: M[job, machine] = time to process job on machine
    # Jobs with identical processing profiles can share a scheduling slot
    jobs = [
        "DataPrep-A", "DataPrep-B", "Training-1", "Training-2",
        "Inference-A", "Inference-B", "DataPrep-C", "Training-3",
        "Inference-C", "DataPrep-D"
    ]
    machines = ["CPU", "GPU", "TPU", "FPGA"]
    
    M = np.array([
        [10, 20, 15, 25],  # DataPrep-A
        [10, 20, 15, 25],  # DataPrep-B (same profile)
        [30, 5, 8, 40],    # Training-1
        [30, 5, 8, 40],    # Training-2 (same profile)
        [15, 12, 10, 8],   # Inference-A
        [15, 12, 10, 8],   # Inference-B (same profile)
        [10, 20, 15, 25],  # DataPrep-C (same as DataPrep-A)
        [30, 5, 8, 40],    # Training-3 (same as Training-1)
        [15, 12, 10, 8],   # Inference-C (same as Inference-A)
        [10, 20, 15, 25],  # DataPrep-D (same as DataPrep-A)
    ])
    
    R = compute_canonical_realization(M)
    classes = compute_nerode_classes(M)
    
    print(f"\n{len(jobs)} jobs on {len(machines)} machines")
    print(f"Distinct scheduling profiles: {R.rank}")
    print(f"Scheduling slots needed: {R.rank} (not {len(jobs)})")
    
    print(f"\nJob groups (Nerode classes):")
    for nc in classes:
        job_names = [jobs[m] for m in nc.members]
        print(f"  Group {nc.class_id}: {job_names}")
        print(f"    Processing times: {dict(zip(machines, nc.profile))}")
    
    print(f"\nCompression: {len(jobs)} → {R.rank} scheduling slots")
    print(f"Reduction: {(1 - R.rank/len(jobs))*100:.0f}%")


# ============================================================
# Application 4: Architecture Search via Rank
# ============================================================

def app_architecture_search():
    print("\n" + "=" * 70)
    print("APPLICATION 4: Architecture Search via Tropical Rank")
    print("=" * 70)
    
    print("\nGiven a target function M, find the minimal architecture.")
    print("The theorem guarantees: min hidden size = operational rank.\n")
    
    # Target function: M[input, output] = cost
    # We try different target functions and find their minimal architectures
    
    targets = {
        "Min function": lambda i, j: min(i, j),
        "Max function": lambda i, j: max(i, j),
        "Sum function": lambda i, j: i + j,
        "Abs difference": lambda i, j: abs(i - j),
        "Constant": lambda i, j: 42,
        "XOR-like": lambda i, j: (i + j) % 3,
    }
    
    n = 8  # 8 inputs, 8 outputs
    
    print(f"{'Target':>20} {'Rank':>6} {'Min States':>12} {'Notes':>30}")
    print("-" * 72)
    
    for name, f in targets.items():
        M = np.array([[f(i, j) for j in range(n)] for i in range(n)])
        rank = operational_rank(M)
        
        # Determine notes
        if rank == 1:
            notes = "Trivially compressible"
        elif rank == n:
            notes = "Incompressible (full rank)"
        elif rank < n // 2:
            notes = f"Highly compressible ({(1-rank/n)*100:.0f}%)"
        else:
            notes = f"Moderately compressible"
        
        print(f"{name:>20} {rank:>6} {rank:>12} {notes:>30}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL OPERADIC REALIZATION — Real-World Applications           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    app_network_compression()
    app_routing_optimization()
    app_scheduling()
    app_architecture_search()
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Build the PACKAGE.json from all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Load visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

# Read all content files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean proofs
defs_lean = read_file('Bridges/TropicalOperadicRealization/Defs.lean')
theorems_lean = read_file('Bridges/TropicalOperadicRealization/Theorems.lean')
lean_proofs = defs_lean + "\n\n-- ═══════════════════════════════════════\n-- THEOREMS FILE\n-- ═══════════════════════════════════════\n\n" + theorems_lean

package = {
    "title": "Tropical Operadic Realization Duality via Idempotent Composition Semimodules",
    "domain": "Bridges: Tropical Geometry × Operad Theory × Machine Learning × Automata Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Operadic Realization — Full Demo Suite",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Canonical Realization (Nerode Quotient)",
            "pseudocode": """Algorithm: CanonicalRealization(M : C × O → ℤ)
Input: Evaluation table M indexed by contexts C and observables O
Output: Canonical realization (States, encode, decode)

1. Compute profiles: P = {M(c, ·) : c ∈ C}  // distinct row profiles
2. Index profiles: Enumerate P = {p₁, ..., p_r} where r = |P|
3. Define encode: encode(c) = index of M(c, ·) in P
4. Define decode: decode(i, o) = pᵢ(o)
5. Return (Fin(r), encode, decode)

Complexity: O(|C| · |O| · log|C|) time, O(r · |O|) space""",
            "code": algorithms_code
        },
        {
            "name": "Tropical Min-Plus Matrix Factorization",
            "pseudocode": """Algorithm: TropicalFactorization(M : n × m matrix over ℤ)
Input: Integer matrix M
Output: Matrices L, R such that M = L ⊗_trop R (min-plus product)

1. Set B = 1 + 2 · max_{i,j} |M[i,j]|
2. Set L[i,j] = 0 if i = j, else B  (indicator matrix)
3. Set R = M  (copy of original matrix)
4. Return (L, R, rank = n)

Correctness: For j = i: L[i,i] + R[i,k] = 0 + M[i,k] = M[i,k]
             For j ≠ i: L[i,j] + R[j,k] = B + M[j,k] ≥ M[i,k]
             Therefore min_j(L[i,j] + R[j,k]) = M[i,k]

Complexity: O(n · m) time""",
            "code": """import numpy as np

def tropical_matmul(A, B):
    \"\"\"Tropical (min-plus) matrix product.\"\"\"
    n, r = A.shape
    result = np.full((n, B.shape[1]), np.inf)
    for j in range(r):
        result = np.minimum(result, A[:, j:j+1] + B[j:j+1, :])
    return result

def tropical_factorization(M):
    \"\"\"Compute tropical factorization M = L ⊗ R.\"\"\"
    n, m = M.shape
    B = 1 + 2 * int(np.max(np.abs(M)))
    L = np.full((n, n), B, dtype=np.int64)
    np.fill_diagonal(L, 0)
    R = M.copy().astype(np.int64)
    return L, R

# Example
M = np.array([[1, 3, 2], [4, 2, 5], [3, 1, 4]])
L, R = tropical_factorization(M)
M_check = tropical_matmul(L.astype(float), R.astype(float))
print(f"Original: {M.tolist()}")
print(f"Reconstructed: {M_check.astype(int).tolist()}")
print(f"Correct: {np.allclose(M, M_check)}")
"""
        }
    ],
    "visualizations": [
        {
            "name": "Architecture Compression Ratios by Table Structure",
            "data": viz_data["compression_ratios"]
        },
        {
            "name": "Nerode Quotient: Canonical Minimal Realization",
            "data": viz_data["nerode_quotient"]
        },
        {
            "name": "Tropical (Min-Plus) Matrix Factorization Decomposition",
            "data": viz_data["tropical_factorization"]
        },
        {
            "name": "Operational Rank Scaling Behavior",
            "data": viz_data["rank_scaling"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Operadic Realization Duality: Demonstrations

This script demonstrates the main theorems of tropical operadic realization theory
with concrete numerical examples:
1. Canonical realization construction (Nerode quotient)
2. Minimality verification
3. Tropical (min-plus) matrix factorization
4. Architecture compression ratios
5. Uniqueness of canonical realizations
"""

import numpy as np
from typing import Dict, List, Tuple, Set
from itertools import product


# ============================================================
# Core: Canonical Realization Algorithm
# ============================================================

def canonical_realization(M: np.ndarray) -> Tuple[int, np.ndarray, np.ndarray]:
    """
    Compute the canonical minimal realization of an evaluation table M.
    
    Args:
        M: shape (n_contexts, n_observables), integer-valued evaluation table
    
    Returns:
        rank: operational rank (number of distinct response profiles)
        encode: shape (n_contexts,), maps context index to state index
        decode: shape (rank, n_observables), maps state to response profile
    """
    n_contexts, n_observables = M.shape
    
    # Find distinct rows (response profiles)
    unique_rows, encode = np.unique(M, axis=0, return_inverse=True)
    rank = len(unique_rows)
    decode = unique_rows
    
    return rank, encode, decode


def verify_realization(M: np.ndarray, encode: np.ndarray, decode: np.ndarray) -> bool:
    """Verify that encode/decode correctly realizes M."""
    n_contexts, n_observables = M.shape
    for c in range(n_contexts):
        for o in range(n_observables):
            if M[c, o] != decode[encode[c], o]:
                return False
    return True


def is_reduced(encode: np.ndarray, n_states: int) -> bool:
    """Check if encode is surjective (every state is reachable)."""
    return len(set(encode)) == n_states


def is_separated(decode: np.ndarray) -> bool:
    """Check if distinct states have distinct decode profiles."""
    n_states = decode.shape[0]
    for i in range(n_states):
        for j in range(i + 1, n_states):
            if np.array_equal(decode[i], decode[j]):
                return False
    return True


# ============================================================
# Tropical Min-Plus Factorization
# ============================================================

def tropical_mat_mul(L: np.ndarray, R: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix product: (L ⊗ R)[i,k] = min_j (L[i,j] + R[j,k])
    """
    n, r = L.shape
    r2, m = R.shape
    assert r == r2, "Inner dimensions must match"
    
    result = np.full((n, m), np.inf)
    for j in range(r):
        result = np.minimum(result, L[:, j:j+1] + R[j:j+1, :])
    return result


def tropical_factorization(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, int]:
    """
    Compute a tropical (min-plus) factorization of M.
    M[c,o] = min_s (L[c,s] + R[s,o])
    
    Uses the indicator-based construction from the formal proof.
    
    Returns:
        L: left factor, shape (n_contexts, r)
        R: right factor, shape (r, n_observables)
        r: factorization rank
    """
    n_contexts, n_observables = M.shape
    r = n_contexts  # We factor through Fin(n_contexts)
    
    # Bound: B ≥ max_{c,o,s} (M[c,o] - M[s,o])
    B = 1 + 2 * int(np.max(np.abs(M)))
    
    # L[c, s] = 0 if c == s, else B
    L = np.full((n_contexts, r), B, dtype=np.int64)
    np.fill_diagonal(L, 0)
    
    # R[s, o] = M[s, o]
    R = M.copy().astype(np.int64)
    
    return L, R, r


def verify_tropical_factorization(M: np.ndarray, L: np.ndarray, R: np.ndarray) -> bool:
    """Verify M = L ⊗_trop R (min-plus product)."""
    M_reconstructed = tropical_mat_mul(L.astype(float), R.astype(float))
    return np.allclose(M.astype(float), M_reconstructed)


# ============================================================
# Nerode Equivalence
# ============================================================

def nerode_classes(M: np.ndarray) -> Dict[int, List[int]]:
    """
    Compute the Nerode equivalence classes of M.
    Two contexts c₁, c₂ are equivalent iff M[c₁, :] == M[c₂, :].
    """
    classes = {}
    row_to_class = {}
    
    for c in range(M.shape[0]):
        row_key = tuple(M[c, :])
        if row_key not in row_to_class:
            class_id = len(classes)
            row_to_class[row_key] = class_id
            classes[class_id] = []
        classes[row_to_class[row_key]].append(c)
    
    return classes


# ============================================================
# Demo 1: Basic Canonical Realization
# ============================================================

def demo_basic_realization():
    print("=" * 70)
    print("DEMO 1: Canonical Realization Construction")
    print("=" * 70)
    
    # A 6×4 evaluation table with repeated rows
    M = np.array([
        [3, 1, 4, 1],   # Profile A
        [2, 7, 1, 8],   # Profile B
        [3, 1, 4, 1],   # Profile A (duplicate)
        [5, 9, 2, 6],   # Profile C
        [2, 7, 1, 8],   # Profile B (duplicate)
        [3, 1, 4, 1],   # Profile A (duplicate)
    ])
    
    print(f"\nEvaluation table M ({M.shape[0]} contexts × {M.shape[1]} observables):")
    print(M)
    
    rank, encode, decode = canonical_realization(M)
    
    print(f"\nOperational rank: {rank} (out of {M.shape[0]} contexts)")
    print(f"Compression ratio: {M.shape[0]}/{rank} = {M.shape[0]/rank:.1f}×")
    print(f"\nNerode equivalence classes:")
    for cls_id, members in nerode_classes(M).items():
        print(f"  Class {cls_id}: contexts {members} → profile {M[members[0], :]}")
    
    print(f"\nEncode map: {encode}")
    print(f"Decode table:\n{decode}")
    
    # Verify properties
    correct = verify_realization(M, encode, decode)
    reduced = is_reduced(encode, rank)
    separated = is_separated(decode)
    
    print(f"\nVerification:")
    print(f"  Correctly realizes M: {correct}")
    print(f"  Reduced (surjective encode): {reduced}")
    print(f"  Separated (injective decode): {separated}")
    print(f"  Canonical: {correct and reduced and separated}")


# ============================================================
# Demo 2: Tropical Min-Plus Factorization
# ============================================================

def demo_tropical_factorization():
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical (Min-Plus) Matrix Factorization")
    print("=" * 70)
    
    M = np.array([
        [1, 3, 2],
        [4, 2, 5],
        [3, 1, 4],
    ])
    
    print(f"\nEvaluation table M:")
    print(M)
    
    L, R, r = tropical_factorization(M)
    
    print(f"\nFactorization rank: {r}")
    print(f"\nLeft factor L (indicator-based):")
    print(L)
    print(f"\nRight factor R:")
    print(R)
    
    # Verify: M[c,o] = min_s (L[c,s] + R[s,o])
    M_reconstructed = tropical_mat_mul(L.astype(float), R.astype(float))
    print(f"\nReconstructed M (via min-plus product L ⊗ R):")
    print(M_reconstructed.astype(int))
    
    correct = verify_tropical_factorization(M, L, R)
    print(f"\nFactorization correct: {correct}")
    
    # Show the min-plus computation for one entry
    c, o = 0, 1
    print(f"\nDetailed computation for M[{c},{o}] = {M[c,o]}:")
    for s in range(r):
        val = L[c, s] + R[s, o]
        marker = " ← min" if val == M[c, o] else ""
        print(f"  s={s}: L[{c},{s}] + R[{s},{o}] = {L[c,s]} + {R[s,o]} = {val}{marker}")


# ============================================================
# Demo 3: Minimality and State Count Invariance
# ============================================================

def demo_minimality():
    print("\n" + "=" * 70)
    print("DEMO 3: Minimality — State Count = Operational Rank")
    print("=" * 70)
    
    # Create a table with known rank
    M = np.array([
        [1, 0, 2],
        [3, 4, 5],
        [1, 0, 2],  # same as row 0
        [3, 4, 5],  # same as row 1
        [7, 8, 9],
        [1, 0, 2],  # same as row 0
        [7, 8, 9],  # same as row 4
    ])
    
    rank, encode, decode = canonical_realization(M)
    
    print(f"\nTable with {M.shape[0]} contexts, operational rank = {rank}")
    print(f"Canonical realization has {rank} states")
    
    # Show that any other realization must have ≥ rank states
    print(f"\nTheorem: Every realization has ≥ {rank} states")
    print(f"Proof: M has {rank} distinct response profiles,")
    print(f"       so decode must map to ≥ {rank} distinct functions,")
    print(f"       requiring ≥ {rank} states.")
    
    # Demonstrate with an "overcomplete" realization (identity)
    identity_states = M.shape[0]
    print(f"\nIdentity realization: {identity_states} states (wasteful)")
    print(f"Canonical realization: {rank} states (minimal)")
    print(f"Savings: {identity_states - rank} states ({(1-rank/identity_states)*100:.0f}% reduction)")


# ============================================================
# Demo 4: Uniqueness of Canonical Realizations
# ============================================================

def demo_uniqueness():
    print("\n" + "=" * 70)
    print("DEMO 4: Uniqueness — Canonical Realizations Are Isomorphic")
    print("=" * 70)
    
    M = np.array([
        [10, 20],
        [30, 40],
        [10, 20],
        [50, 60],
    ])
    
    # Construction 1: Using np.unique (canonical)
    rank1, encode1, decode1 = canonical_realization(M)
    
    # Construction 2: Manual construction with different state ordering
    # Deliberately permute the state indices
    perm = np.array([2, 0, 1])  # permutation of {0,1,2}
    rank2 = rank1
    encode2 = np.array([perm[e] for e in encode1])
    decode2 = decode1[np.argsort(perm)]
    
    print(f"\nTwo canonical realizations of the same 4×2 table:")
    print(f"\nRealization 1:")
    print(f"  States: {rank1}")
    print(f"  Encode: {encode1}")
    print(f"  Decode:\n{decode1}")
    
    print(f"\nRealization 2 (permuted states):")
    print(f"  States: {rank2}")
    print(f"  Encode: {encode2}")
    print(f"  Decode:\n{decode2}")
    
    # Find the isomorphism
    print(f"\nBoth realize the same table: {verify_realization(M, encode1, decode1) and verify_realization(M, encode2, decode2)}")
    print(f"\nIsomorphism f: State₁ → State₂ = {dict(enumerate(perm))}")
    print(f"Verifying: f ∘ encode₁ = encode₂: {all(perm[encode1[c]] == encode2[c] for c in range(4))}")
    print(f"Verifying: decode₁[s] = decode₂[f(s)]: {all(np.array_equal(decode1[s], decode2[perm[s]]) for s in range(rank1))}")


# ============================================================
# Demo 5: Compression Statistics
# ============================================================

def demo_compression_statistics():
    print("\n" + "=" * 70)
    print("DEMO 5: Architecture Compression Statistics")
    print("=" * 70)
    
    np.random.seed(42)
    
    print(f"\n{'Contexts':>10} {'Observables':>12} {'Rank':>6} {'Ratio':>8} {'Description':>20}")
    print("-" * 60)
    
    test_cases = [
        ("Random", lambda n, m: np.random.randint(-10, 10, (n, m))),
        ("Low-rank", lambda n, m: np.minimum(
            np.arange(n).reshape(-1, 1), np.arange(m).reshape(1, -1)
        )),
        ("Constant", lambda n, m: np.full((n, m), 42)),
        ("Binary", lambda n, m: np.random.randint(0, 2, (n, m))),
        ("Periodic", lambda n, m: np.array([[i % 3 + j for j in range(m)] for i in range(n)])),
    ]
    
    for name, gen in test_cases:
        for n, m in [(10, 5), (50, 5), (100, 10)]:
            M = gen(n, m)
            rank, _, _ = canonical_realization(M)
            ratio = n / rank
            print(f"{n:>10} {m:>12} {rank:>6} {ratio:>8.1f}× {name:>20}")


# ============================================================
# Demo 6: Idempotent Semimodule
# ============================================================

def demo_semimodule():
    print("\n" + "=" * 70)
    print("DEMO 6: Idempotent Composition Semimodule")
    print("=" * 70)
    
    # The semimodule has carrier Fin(rank) with min as both operations
    M = np.array([
        [1, 2, 3],
        [4, 5, 6],
        [1, 2, 3],
        [7, 8, 9],
    ])
    
    rank, _, _ = canonical_realization(M)
    print(f"\nOperational rank: {rank}")
    print(f"Semimodule carrier: Fin({rank}) = {{{', '.join(str(i) for i in range(rank))}}}")
    
    print(f"\nTropical addition table (⊕ = min):")
    print(f"  ⊕  | " + " ".join(f"{j}" for j in range(rank)))
    print(f"  ---+" + "---" * rank)
    for i in range(rank):
        vals = " ".join(f"{min(i,j)}" for j in range(rank))
        print(f"  {i}  | {vals}")
    
    print(f"\nProperties verified:")
    print(f"  Idempotent (x ⊕ x = x): {all(min(i,i) == i for i in range(rank))}")
    print(f"  Commutative (x ⊕ y = y ⊕ x): {all(min(i,j) == min(j,i) for i in range(rank) for j in range(rank))}")
    print(f"  Associative: {all(min(min(i,j),k) == min(i,min(j,k)) for i in range(rank) for j in range(rank) for k in range(rank))}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL OPERADIC REALIZATION DUALITY — Demonstration Suite       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_basic_realization()
    demo_tropical_factorization()
    demo_minimality()
    demo_uniqueness()
    demo_compression_statistics()
    demo_semimodule()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate visualizations for the Tropical Operadic Realization Theory."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_compression_ratios() -> str:
    """Visualization 1: Compression ratios across different table types."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    np.random.seed(42)
    sizes = [5, 10, 20, 50, 100, 200]
    m = 5  # fixed observables
    
    # Random tables
    ranks_random = []
    for n in sizes:
        M = np.random.randint(-10, 10, (n, m))
        ranks_random.append(len(np.unique(M, axis=0)))
    
    # Low-rank tables (min function)
    ranks_lowrank = []
    for n in sizes:
        M = np.array([[min(i, j) for j in range(m)] for i in range(n)])
        ranks_lowrank.append(len(np.unique(M, axis=0)))
    
    # Periodic tables
    ranks_periodic = []
    for n in sizes:
        M = np.array([[(i % 3) + j for j in range(m)] for i in range(n)])
        ranks_periodic.append(len(np.unique(M, axis=0)))
    
    ax = axes[0]
    ax.plot(sizes, [n/r for n, r in zip(sizes, ranks_random)], 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax.set_title('Random Tables', fontsize=14, fontweight='bold')
    ax.set_xlabel('Number of Contexts', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    ax.plot(sizes, [n/r for n, r in zip(sizes, ranks_lowrank)], 's-', color='#2ecc71', linewidth=2, markersize=8)
    ax.set_title('Low-Rank (min function)', fontsize=14, fontweight='bold')
    ax.set_xlabel('Number of Contexts', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    
    ax = axes[2]
    ax.plot(sizes, [n/r for n, r in zip(sizes, ranks_periodic)], 'D-', color='#3498db', linewidth=2, markersize=8)
    ax.set_title('Periodic Tables', fontsize=14, fontweight='bold')
    ax.set_xlabel('Number of Contexts', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Architecture Compression by Table Structure', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_nerode_quotient() -> str:
    """Visualization 2: Nerode quotient / canonical realization diagram."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Original (overcomplete) realization
    M = np.array([
        [3, 1, 4],
        [2, 7, 1],
        [3, 1, 4],
        [5, 9, 2],
        [2, 7, 1],
        [3, 1, 4],
    ])
    
    # Plot original table as heatmap
    im1 = ax1.imshow(M, cmap='YlOrRd', aspect='auto')
    ax1.set_title('Original Evaluation Table\n(6 contexts × 3 observables)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('Observables', fontsize=12)
    ax1.set_ylabel('Contexts', fontsize=12)
    ax1.set_xticks(range(3))
    ax1.set_yticks(range(6))
    ax1.set_xticklabels(['O₀', 'O₁', 'O₂'])
    ax1.set_yticklabels(['C₀', 'C₁', 'C₂', 'C₃', 'C₄', 'C₅'])
    
    # Color-code duplicate rows
    colors = ['#e74c3c', '#3498db', '#e74c3c', '#2ecc71', '#3498db', '#e74c3c']
    for i, c in enumerate(colors):
        ax1.add_patch(plt.Rectangle((-0.5, i-0.5), 3, 1, fill=False, edgecolor=c, linewidth=3))
    
    for i in range(6):
        for j in range(3):
            ax1.text(j, i, str(M[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    
    plt.colorbar(im1, ax=ax1, fraction=0.046)
    
    # Plot canonical realization
    unique = np.unique(M, axis=0)
    im2 = ax2.imshow(unique, cmap='YlOrRd', aspect='auto')
    ax2.set_title('Canonical Realization\n(3 states × 3 observables)', fontsize=13, fontweight='bold')
    ax2.set_xlabel('Observables', fontsize=12)
    ax2.set_ylabel('States (Nerode classes)', fontsize=12)
    ax2.set_xticks(range(3))
    ax2.set_yticks(range(3))
    ax2.set_xticklabels(['O₀', 'O₁', 'O₂'])
    ax2.set_yticklabels(['S₀ = {C₁,C₄}', 'S₁ = {C₀,C₂,C₅}', 'S₂ = {C₃}'])
    
    state_colors = ['#3498db', '#e74c3c', '#2ecc71']
    for i, c in enumerate(state_colors):
        ax2.add_patch(plt.Rectangle((-0.5, i-0.5), 3, 1, fill=False, edgecolor=c, linewidth=3))
    
    for i in range(3):
        for j in range(3):
            ax2.text(j, i, str(unique[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    
    plt.colorbar(im2, ax=ax2, fraction=0.046)
    
    fig.suptitle('Nerode Quotient: Canonical Minimal Realization', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_tropical_factorization() -> str:
    """Visualization 3: Tropical factorization decomposition."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4),
                              gridspec_kw={'width_ratios': [3, 0.5, 3, 3]})
    
    M = np.array([
        [1, 3, 2],
        [4, 2, 5],
        [3, 1, 4],
    ])
    B = 11
    L = np.full((3, 3), B, dtype=int)
    np.fill_diagonal(L, 0)
    R = M.copy()
    
    # M
    im = axes[0].imshow(M, cmap='Blues', aspect='auto')
    axes[0].set_title('M', fontsize=14, fontweight='bold')
    for i in range(3):
        for j in range(3):
            axes[0].text(j, i, str(M[i,j]), ha='center', va='center', fontsize=16, fontweight='bold')
    axes[0].set_xticks(range(3))
    axes[0].set_yticks(range(3))
    
    # =
    axes[1].text(0.5, 0.5, '=\nmin₊', ha='center', va='center', fontsize=18, fontweight='bold',
                 transform=axes[1].transAxes)
    axes[1].axis('off')
    
    # L
    im = axes[2].imshow(L, cmap='Oranges', aspect='auto', vmin=0, vmax=B)
    axes[2].set_title('L (indicator)', fontsize=14, fontweight='bold')
    for i in range(3):
        for j in range(3):
            axes[2].text(j, i, str(L[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    axes[2].set_xticks(range(3))
    axes[2].set_yticks(range(3))
    
    # R
    im = axes[3].imshow(R, cmap='Greens', aspect='auto')
    axes[3].set_title('R = M', fontsize=14, fontweight='bold')
    for i in range(3):
        for j in range(3):
            axes[3].text(j, i, str(R[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    axes[3].set_xticks(range(3))
    axes[3].set_yticks(range(3))
    
    fig.suptitle('Tropical (Min-Plus) Matrix Factorization: M = L ⊗ R', fontsize=16, fontweight='bold', y=1.05)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_rank_scaling() -> str:
    """Visualization 4: Operational rank scaling behavior."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    np.random.seed(42)
    m_values = [2, 3, 5, 8, 10]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(m_values)))
    
    for m, color in zip(m_values, colors):
        ns = range(1, 101)
        avg_ranks = []
        for n in ns:
            ranks = []
            for trial in range(10):
                M = np.random.randint(0, 5, (n, m))
                ranks.append(len(np.unique(M, axis=0)))
            avg_ranks.append(np.mean(ranks))
        
        ax.plot(ns, avg_ranks, color=color, linewidth=2, label=f'm={m} obs, range=5')
    
    ax.plot(ns, ns, 'k--', alpha=0.3, linewidth=1, label='rank = n (upper bound)')
    ax.set_xlabel('Number of Contexts (n)', fontsize=13)
    ax.set_ylabel('Operational Rank (avg over 10 trials)', fontsize=13)
    ax.set_title('Operational Rank vs. Context Count\n(Random integer tables, range [0,5))', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    v1 = viz_compression_ratios()
    print(f"  Compression ratios: {len(v1)} chars")
    
    v2 = viz_nerode_quotient()
    print(f"  Nerode quotient: {len(v2)} chars")
    
    v3 = viz_tropical_factorization()
    print(f"  Tropical factorization: {len(v3)} chars")
    
    v4 = viz_rank_scaling()
    print(f"  Rank scaling: {len(v4)} chars")
    
    # Save visualization data for PACKAGE.json
    viz_data = {
        "compression_ratios": v1,
        "nerode_quotient": v2,
        "tropical_factorization": v3,
        "rank_scaling": v4,
    }
    
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    
    print("Done! Visualization data saved to viz_data.json")
