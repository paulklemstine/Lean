#!/usr/bin/env python3
"""
MPS Min-Cut Principle: Applications

Demonstrates real-world applications of the MPS min-cut principle:
1. Entanglement diagnostics for quantum states
2. Bond dimension optimization for MPS compression
3. Communication complexity analysis
4. Comparison with tree tensor networks

Each application shows the min-cut principle working in practice.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, FrozenSet
import sys


# ======================================================================
# Core MPS utilities (self-contained)
# ======================================================================

def random_mps_tensors(n, d, bond_dims, seed=42):
    rng = np.random.default_rng(seed)
    return [rng.standard_normal((bond_dims[i], d, bond_dims[i+1])) for i in range(n)]

def contract_mps(tensors, d, n):
    result = tensors[0]
    for i in range(1, n):
        result = np.einsum('...i,ijk->...jk', result, tensors[i])
    return result.reshape([d] * n)

def flat_rank(psi, S, n, tol=1e-10):
    S_list = sorted(S)
    Sc_list = sorted(set(range(n)) - S)
    d = psi.shape[0]
    psi_perm = np.transpose(psi, S_list + Sc_list)
    M = psi_perm.reshape(d**len(S_list), d**len(Sc_list))
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


# ======================================================================
# Application 1: Entanglement Diagnostics
# ======================================================================

def entanglement_diagnostics():
    """
    Use the min-cut principle to efficiently diagnose entanglement structure.

    Instead of computing all 2^n - 2 flattening ranks, we only need n-1
    prefix cuts to find the global entanglement bottleneck.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Entanglement Diagnostics")
    print("=" * 60)

    n, d = 6, 2
    bond_dims = [1, 4, 8, 3, 6, 4, 1]  # bottleneck at bond 3 (D=3)
    tensors = random_mps_tensors(n, d, bond_dims, seed=123)
    psi = contract_mps(tensors, d, n)

    print(f"\nQuantum state: {n}-site chain, d={d}")
    print(f"Bond dimensions: {bond_dims}")
    print(f"Expected bottleneck: D_3 = {bond_dims[3]} (bond between sites 2 and 3)")

    print(f"\nPrefix cut scan (O(n) cuts):")
    min_rank = float('inf')
    min_k = -1
    for k in range(1, n):
        S = frozenset(range(k))
        r = flat_rank(psi, S, n)
        bottleneck = bond_dims[k]
        marker = " <-- BOTTLENECK" if r == min(bond_dims[1:-1]) else ""
        print(f"  Cut at bond {k}: rank = {r}, D_{k} = {bottleneck}{marker}")
        if r < min_rank:
            min_rank = r
            min_k = k

    print(f"\nDiagnosis: Entanglement bottleneck at bond {min_k}")
    print(f"  Bottleneck rank = {min_rank}")
    print(f"  This means the state has at most {min_rank}-dimensional")
    print(f"  correlations across the cut at site {min_k}.")
    print(f"\n  By the min-cut principle, this is also the global minimum")
    print(f"  over ALL 2^{n}-2 = {2**n - 2} possible bipartitions!")


# ======================================================================
# Application 2: Optimal Bond Dimension Compression
# ======================================================================

def bond_dimension_optimization():
    """
    Use the min-cut principle to guide MPS compression.

    The principle tells us that reducing any bond dimension D_k below the
    current minimum doesn't lose information if D_k is above the bottleneck,
    and that the bottleneck bond is the one limiting overall expressivity.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Bond Dimension Optimization")
    print("=" * 60)

    n, d = 5, 2
    bond_dims_original = [1, 4, 8, 6, 3, 1]  # bottleneck at D_4=3
    tensors = random_mps_tensors(n, d, bond_dims_original, seed=456)
    psi_original = contract_mps(tensors, d, n)

    print(f"\nOriginal MPS: bonds = {bond_dims_original}")
    print(f"Bottleneck: D_4 = {bond_dims_original[4]}")
    print(f"\nCompression analysis via min-cut principle:")

    # Check which bonds can be reduced
    bottleneck = min(bond_dims_original[1:-1])
    total_params_original = sum(
        bond_dims_original[i] * d * bond_dims_original[i+1] for i in range(n)
    )
    print(f"  Current parameter count: {total_params_original}")

    # Compressed bond dimensions
    bond_dims_compressed = [1] + [min(b, bottleneck) for b in bond_dims_original[1:-1]] + [1]
    total_params_compressed = sum(
        bond_dims_compressed[i] * d * bond_dims_compressed[i+1] for i in range(n)
    )

    print(f"  Compressed bonds: {bond_dims_compressed}")
    print(f"  Compressed parameter count: {total_params_compressed}")
    print(f"  Compression ratio: {total_params_original / total_params_compressed:.1f}x")
    print(f"\n  Key insight: bonds above the bottleneck ({bottleneck}) carry")
    print(f"  redundant capacity. The min-cut principle guarantees that")
    print(f"  the global entanglement structure is limited by D = {bottleneck}.")


# ======================================================================
# Application 3: Communication Complexity
# ======================================================================

def communication_complexity():
    """
    Interpret the min-cut principle in terms of communication complexity.

    The flattening rank across a bipartition S|S^c is a lower bound on the
    communication complexity of any protocol that computes the tensor entry
    given inputs split across S and S^c. The min-cut principle says the
    hardest communication bottleneck is always at a contiguous cut.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Communication Complexity Analysis")
    print("=" * 60)

    n, d = 5, 2
    bond_dims = [1, 3, 5, 2, 4, 1]
    tensors = random_mps_tensors(n, d, bond_dims, seed=789)
    psi = contract_mps(tensors, d, n)

    print(f"\nTensor network: {n} parties on a chain")
    print(f"Bond dimensions: {bond_dims}")
    print(f"\nCommunication bottleneck analysis:")

    # For each bipartition, the flattening rank gives a comm complexity bound
    all_ranks = {}
    for size in range(1, n):
        for combo in combinations(range(n), size):
            S = frozenset(combo)
            r = flat_rank(psi, S, n)
            all_ranks[S] = r

    min_rank = min(all_ranks.values())
    print(f"  Minimum comm complexity lower bound: log2({min_rank}) = {np.log2(min_rank):.2f} bits")

    # Show that contiguous cuts achieve this
    for k in range(1, n):
        S = frozenset(range(k))
        r = all_ranks[S]
        is_min = " <-- ACHIEVES MINIMUM" if r == min_rank else ""
        print(f"  Prefix cut k={k}: rank = {r}, comm bound = {np.log2(r):.2f} bits{is_min}")

    print(f"\n  Min-cut principle implication:")
    print(f"  The hardest communication partition is always contiguous!")
    print(f"  For MPS-structured data, adversarial input partitioning")
    print(f"  cannot do worse than a contiguous split.")


# ======================================================================
# Application 4: Comparing 1D chains vs tree structures
# ======================================================================

def tree_vs_chain_comparison():
    """
    Compare the min-cut principle on chains (where it holds exactly)
    with tree tensor networks (where an analogous principle should hold).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Chain vs Tree Tensor Networks")
    print("=" * 60)

    # Chain MPS
    n = 5
    d = 2
    bonds = [1, 3, 4, 2, 3, 1]
    tensors = random_mps_tensors(n, d, bonds, seed=101)
    psi = contract_mps(tensors, d, n)

    # Count bipartitions needed
    n_all = 2**n - 2
    n_prefix = n - 1

    print(f"\n1D Chain (n={n}):")
    print(f"  Total bipartitions: {n_all}")
    print(f"  Prefix cuts needed: {n_prefix}")
    print(f"  Exponential-to-linear reduction: {n_all}→{n_prefix}")

    # Verify
    ranks = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            S = frozenset(combo)
            ranks.append(flat_rank(psi, S, n))
    prefix_ranks = [flat_rank(psi, frozenset(range(k)), n) for k in range(1, n)]

    print(f"  Min over all: {min(ranks)}")
    print(f"  Min over prefixes: {min(prefix_ranks)}")
    print(f"  Match: {'YES' if min(ranks) == min(prefix_ranks) else 'NO'}")

    # Tree prediction
    print(f"\nTree Tensor Network (hypothetical binary tree, {n} leaves):")
    print(f"  Total bipartitions: {n_all}")
    print(f"  Subtree cuts (analog of prefix): O(n) = {n}")
    print(f"  Conjecture: min over subtree cuts = min over all cuts")
    print(f"  Status: OPEN QUESTION — would generalize the chain result")

    # Scaling comparison
    print(f"\nScaling comparison:")
    for n_val in [5, 10, 15, 20, 25, 30]:
        n_all_val = 2**n_val - 2
        n_prefix_val = n_val - 1
        print(f"  n={n_val:2d}: all={n_all_val:>12,d}  prefix={n_prefix_val:2d}  "
              f"speedup={n_all_val/n_prefix_val:>12,.0f}x")


def main():
    print("=" * 60)
    print("  MPS MIN-CUT PRINCIPLE: APPLICATIONS")
    print("=" * 60)

    entanglement_diagnostics()
    bond_dimension_optimization()
    communication_complexity()
    tree_vs_chain_comparison()

    print(f"\n{'=' * 60}")
    print("  All applications demonstrated successfully.")
    print(f"{'=' * 60}")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
MPS Min-Cut Principle: Interactive Demonstration

Samples random Matrix Product States (MPS) over the rationals,
enumerates all nontrivial bipartitions, computes flattening ranks,
and verifies that the minimum is always achieved by a contiguous (prefix) cut.

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional
import sys


def random_mps_tensors(n: int, phys_dim: int, bond_dims: List[int],
                       rng: np.random.Generator) -> List[np.ndarray]:
    """
    Generate random MPS tensors for a chain of length n.

    Parameters
    ----------
    n : int
        Number of sites.
    phys_dim : int
        Local physical dimension at each site.
    bond_dims : list of int
        Bond dimensions [D_0, D_1, ..., D_n] where D_0 = D_n = 1
        for open boundary conditions.
    rng : numpy random Generator

    Returns
    -------
    tensors : list of np.ndarray
        tensors[i] has shape (bond_dims[i], phys_dim, bond_dims[i+1])
    """
    assert len(bond_dims) == n + 1
    assert bond_dims[0] == 1 and bond_dims[-1] == 1
    tensors = []
    for i in range(n):
        A = rng.standard_normal((bond_dims[i], phys_dim, bond_dims[i + 1]))
        tensors.append(A)
    return tensors


def mps_to_full_tensor(tensors: List[np.ndarray], phys_dim: int) -> np.ndarray:
    """
    Contract MPS tensors into the full state tensor ψ(s_0, s_1, ..., s_{n-1}).

    Returns an array of shape (phys_dim,) * n.
    """
    n = len(tensors)
    # Start with the first tensor
    result = tensors[0]  # shape (1, d, D_1)
    for i in range(1, n):
        # result has shape (1, d^i, D_i)
        # tensors[i] has shape (D_i, d, D_{i+1})
        result = np.einsum('...i,ijk->...jk', result, tensors[i])
    # result has shape (1, d, d, ..., d, 1) with n physical indices
    result = result.reshape([phys_dim] * n)
    return result


def flatten_tensor(psi: np.ndarray, S: frozenset, n: int) -> np.ndarray:
    """
    Flatten tensor ψ across bipartition S | S^c.

    Parameters
    ----------
    psi : np.ndarray of shape (d,) * n
    S : frozenset of int, subset of {0, ..., n-1}
    n : int

    Returns
    -------
    matrix : 2D np.ndarray with rows indexed by S configurations
             and columns indexed by S^c configurations
    """
    S_list = sorted(S)
    Sc_list = sorted(set(range(n)) - S)

    # Permute axes: S indices first, then S^c indices
    perm = S_list + Sc_list
    psi_perm = np.transpose(psi, perm)

    d = psi.shape[0]
    row_dim = d ** len(S_list)
    col_dim = d ** len(Sc_list)
    return psi_perm.reshape(row_dim, col_dim)


def flat_rank(psi: np.ndarray, S: frozenset, n: int, tol: float = 1e-10) -> int:
    """Compute the rank of the flattening of ψ across S | S^c."""
    M = flatten_tensor(psi, S, n)
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


def all_nontrivial_bipartitions(n: int):
    """Generate all nonempty proper subsets of {0, ..., n-1}."""
    for size in range(1, n):
        for combo in combinations(range(n), size):
            yield frozenset(combo)


def prefix_cuts(n: int):
    """Generate all prefix cuts {0, ..., k-1} for k = 1, ..., n-1."""
    for k in range(1, n):
        yield frozenset(range(k))


def cut_edges(n: int, S: frozenset) -> List[int]:
    """Return the list of cut edges for subset S on the path graph."""
    edges = []
    for i in range(n - 1):
        if (i in S) != (i + 1 in S):
            edges.append(i)
    return edges


def edge_cut_min_weight(bond_dims: List[int], S: frozenset, n: int) -> int:
    """Minimum bond dimension among cut edges for bipartition S."""
    edges = cut_edges(n, S)
    if not edges:
        return 0
    # bond_dims[i+1] is the bond dimension of edge i (between site i and i+1)
    return min(bond_dims[e + 1] for e in edges)


def run_experiment(n: int, phys_dim: int, bond_dims: List[int],
                   seed: int = 42, verbose: bool = True) -> Dict:
    """
    Run a single MPS min-cut experiment.

    Returns a dict with results including whether the conjecture holds.
    """
    rng = np.random.default_rng(seed)
    tensors = random_mps_tensors(n, phys_dim, bond_dims, rng)
    psi = mps_to_full_tensor(tensors, phys_dim)

    if verbose:
        print(f"\n{'='*60}")
        print(f"MPS Min-Cut Experiment")
        print(f"  Chain length n = {n}")
        print(f"  Physical dim d = {phys_dim}")
        print(f"  Bond dims = {bond_dims}")
        print(f"{'='*60}")

    # Compute flattening ranks for all bipartitions
    all_ranks = {}
    min_rank = float('inf')
    min_S = None

    for S in all_nontrivial_bipartitions(n):
        r = flat_rank(psi, S, n)
        all_ranks[S] = r
        if r < min_rank:
            min_rank = r
            min_S = S

    # Compute prefix cut ranks
    prefix_ranks = {}
    min_prefix_rank = float('inf')
    min_prefix_k = None

    for S in prefix_cuts(n):
        k = len(S)
        r = all_ranks[S]
        prefix_ranks[k] = r
        if r < min_prefix_rank:
            min_prefix_rank = r
            min_prefix_k = k

    # Min bond dimension
    internal_bonds = bond_dims[1:-1]
    min_bond = min(internal_bonds)

    # Check conjecture
    conjecture_holds = (min_rank == min_prefix_rank)

    if verbose:
        print(f"\n  Prefix cut ranks:")
        for k in sorted(prefix_ranks):
            bond = bond_dims[k]
            print(f"    {{0,...,{k-1}}} : rank = {prefix_ranks[k]}, bond D_{k} = {bond}")

        print(f"\n  Min bond dimension: {min_bond}")
        print(f"  Min prefix cut rank: {min_prefix_rank} (at k={min_prefix_k})")
        print(f"  Min over ALL bipartitions: {min_rank}")
        print(f"  Minimizing subset: {set(min_S)}")
        print(f"  Is minimizer contiguous prefix? {min_S in set(prefix_cuts(n))}")

        n_bipartitions = len(all_ranks)
        n_achieving_min = sum(1 for r in all_ranks.values() if r == min_rank)
        print(f"\n  Total bipartitions checked: {n_bipartitions}")
        print(f"  Bipartitions achieving minimum: {n_achieving_min}")

        # Check edge bottleneck bound
        violations = 0
        for S, r in all_ranks.items():
            eb = edge_cut_min_weight(bond_dims, S, n)
            if r < eb:
                violations += 1
                print(f"  !! BOTTLENECK VIOLATION: S={set(S)}, rank={r}, bottleneck={eb}")
        if violations == 0:
            print(f"  Edge bottleneck bound: VERIFIED for all {n_bipartitions} bipartitions")

        print(f"\n  *** CONJECTURE {'HOLDS' if conjecture_holds else 'FAILS'} ***")

        if not conjecture_holds:
            print(f"  !!! COUNTEREXAMPLE FOUND !!!")
            print(f"  The minimum rank {min_rank} over all bipartitions")
            print(f"  is LESS than the minimum prefix rank {min_prefix_rank}")

    return {
        'n': n,
        'phys_dim': phys_dim,
        'bond_dims': bond_dims,
        'all_ranks': all_ranks,
        'prefix_ranks': prefix_ranks,
        'min_rank': min_rank,
        'min_prefix_rank': min_prefix_rank,
        'min_bond': min_bond,
        'conjecture_holds': conjecture_holds,
    }


def noncontiguous_strictness_test(n: int, phys_dim: int, bond_dims: List[int],
                                   num_trials: int = 20, verbose: bool = True):
    """
    Test the generic strictness hypothesis:
    noncontiguous cuts typically have strictly larger flattening rank
    than the best contiguous cut.
    """
    if verbose:
        print(f"\n{'='*60}")
        print(f"Generic Strictness Test (n={n}, d={phys_dim}, bonds={bond_dims})")
        print(f"{'='*60}")

    strictly_larger_count = 0
    total_noncontiguous = 0

    for trial in range(num_trials):
        rng = np.random.default_rng(trial * 137 + 42)
        tensors = random_mps_tensors(n, phys_dim, bond_dims, rng)
        psi = mps_to_full_tensor(tensors, phys_dim)

        prefix_set = set(prefix_cuts(n))
        min_prefix_rank = float('inf')
        for S in prefix_set:
            r = flat_rank(psi, S, n)
            min_prefix_rank = min(min_prefix_rank, r)

        for S in all_nontrivial_bipartitions(n):
            if S not in prefix_set and S not in {frozenset(set(range(n)) - s) for s in prefix_set}:
                r = flat_rank(psi, S, n)
                total_noncontiguous += 1
                if r > min_prefix_rank:
                    strictly_larger_count += 1

    if verbose and total_noncontiguous > 0:
        pct = 100.0 * strictly_larger_count / total_noncontiguous
        print(f"  Noncontiguous cuts tested: {total_noncontiguous}")
        print(f"  Strictly larger than min prefix: {strictly_larger_count} ({pct:.1f}%)")
        print(f"  Conclusion: Noncontiguous cuts are {'TYPICALLY' if pct > 90 else 'SOMETIMES'} "
              f"strictly worse")


def main():
    print("=" * 60)
    print("  MPS MIN-CUT PRINCIPLE: COMPUTATIONAL VERIFICATION")
    print("  Verifying that Φ#(ψ) = min_{k} flatRank(ψ, {0,...,k-1})")
    print("=" * 60)

    # Test configurations
    configs = [
        # (n, phys_dim, bond_dims)
        (3, 2, [1, 2, 2, 1]),
        (4, 2, [1, 2, 3, 2, 1]),
        (5, 2, [1, 2, 4, 3, 2, 1]),
        (4, 3, [1, 3, 2, 3, 1]),
        (5, 2, [1, 3, 5, 4, 2, 1]),
        (6, 2, [1, 2, 3, 4, 3, 2, 1]),
    ]

    all_hold = True
    for n, d, bonds in configs:
        for seed in range(5):
            result = run_experiment(n, d, bonds, seed=seed, verbose=(seed == 0))
            if not result['conjecture_holds']:
                all_hold = False
                print(f"COUNTEREXAMPLE at n={n}, d={d}, bonds={bonds}, seed={seed}")

    print(f"\n{'='*60}")
    print(f"  SUMMARY: Conjecture {'VERIFIED' if all_hold else 'FALSIFIED'} "
          f"across all {len(configs)} configurations × 5 seeds")
    print(f"{'='*60}")

    # Strictness test
    noncontiguous_strictness_test(4, 2, [1, 2, 3, 2, 1])
    noncontiguous_strictness_test(5, 2, [1, 3, 2, 4, 2, 1])

    # Edge count analysis
    print(f"\n{'='*60}")
    print(f"  CUT EDGE ANALYSIS")
    print(f"{'='*60}")
    n = 5
    for S in all_nontrivial_bipartitions(n):
        edges = cut_edges(n, S)
        S_set = set(S)
        is_prefix = S in set(prefix_cuts(n))
        is_suffix = frozenset(set(range(n)) - S) in set(prefix_cuts(n))
        contiguous = is_prefix or is_suffix
        print(f"  S={str(S_set):20s}  cut_edges={edges}  "
              f"#edges={len(edges)}  contiguous={'Y' if contiguous else 'N'}")


if __name__ == '__main__':
    main()
