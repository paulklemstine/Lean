#!/usr/bin/env python3
"""
Applications of Integrated Information via Tensor Networks

Demonstrates real-world applications of the integrated information rank
framework in physics, neuroscience modeling, and network analysis.

Applications:
1. Quantum state classification by integration level
2. Entanglement structure detection in many-body systems
3. Network decomposability analysis
4. Area law verification for MPS states
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Dict, Tuple


# ============================================================
# Core computational routines (self-contained)
# ============================================================

def flatten_state(psi, partition_left):
    n = psi.ndim
    partition_right = sorted(set(range(n)) - set(partition_left))
    perm = list(partition_left) + partition_right
    psi_perm = np.transpose(psi, perm)
    left_dim = int(np.prod([psi.shape[i] for i in partition_left]))
    right_dim = int(np.prod([psi.shape[i] for i in partition_right]))
    return psi_perm.reshape(left_dim, right_dim)


def matrix_rank(M, tol=1e-10):
    if M.size == 0:
        return 0
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


def all_nontrivial_bipartitions(n):
    from itertools import combinations
    parts = []
    for k in range(1, n):
        for combo in combinations(range(n), k):
            parts.append(list(combo))
    return parts


def integrated_info_rank(psi, tol=1e-10):
    n = psi.ndim
    if n < 2:
        return 0
    min_rank = float('inf')
    for part in all_nontrivial_bipartitions(n):
        M = flatten_state(psi, part)
        r = matrix_rank(M, tol)
        min_rank = min(min_rank, r)
    return int(min_rank)


def cut_rank_profile(psi, tol=1e-10):
    n = psi.ndim
    return [matrix_rank(flatten_state(psi, list(range(k+1))), tol) for k in range(n-1)]


def random_mps(n, d, D, normalize=True):
    tensors = []
    for k in range(n):
        D_l = 1 if k == 0 else D
        D_r = 1 if k == n - 1 else D
        A = np.random.randn(d, D_l, D_r) + 1j * np.random.randn(d, D_l, D_r)
        tensors.append(A)
    shape = tuple(d for _ in range(n))
    psi = np.zeros(shape, dtype=complex)
    for idx in cartesian_product(*[range(d) for _ in range(n)]):
        mat = tensors[0][idx[0]]
        for site in range(1, n):
            mat = mat @ tensors[site][idx[site]]
        psi[idx] = mat[0, 0]
    if normalize:
        norm = np.sqrt(np.sum(np.abs(psi)**2))
        if norm > 0:
            psi /= norm
    return psi


# ============================================================
# Application 1: Quantum State Classification
# ============================================================

def classify_quantum_states():
    """
    Classify quantum states by their integrated information rank.
    
    Categories:
    - Φ# = 0: trivial (zero state or single site)
    - Φ# = 1: separable / product state (no integration)
    - Φ# = 2: weakly integrated (e.g., bond-dim-2 MPS, Bell pairs)
    - Φ# > 2: strongly integrated (high entanglement complexity)
    """
    print("=" * 70)
    print("APPLICATION 1: Quantum State Classification by Integration Level")
    print("=" * 70)
    print()
    
    n = 4
    d = 2
    
    states = {}
    
    # Product state
    psi_prod = np.zeros((2,)*n, dtype=complex)
    for idx in cartesian_product(*[range(2)]*n):
        psi_prod[idx] = np.prod([np.array([1, 1j])[i] for i in idx])
    psi_prod /= np.sqrt(np.sum(np.abs(psi_prod)**2))
    states["Product |+i⟩^⊗4"] = psi_prod
    
    # GHZ state
    psi_ghz = np.zeros((2,)*n, dtype=complex)
    psi_ghz[(0,)*n] = 1/np.sqrt(2)
    psi_ghz[(1,)*n] = 1/np.sqrt(2)
    states["GHZ"] = psi_ghz
    
    # W state
    psi_w = np.zeros((2,)*n, dtype=complex)
    for k in range(n):
        idx = [0]*n
        idx[k] = 1
        psi_w[tuple(idx)] = 1/np.sqrt(n)
    states["W state"] = psi_w
    
    # Random MPS D=2
    np.random.seed(123)
    states["MPS D=2"] = random_mps(n, d, 2)
    
    # Random MPS D=3
    states["MPS D=3"] = random_mps(n, d, 3)
    
    # Maximally entangled (random)
    psi_rand = np.random.randn(*([d]*n)) + 1j*np.random.randn(*([d]*n))
    psi_rand /= np.sqrt(np.sum(np.abs(psi_rand)**2))
    states["Random"] = psi_rand
    
    print(f"  {'State':<20} {'Φ#':>4} {'Cut Profile':<20} {'Class':<25}")
    print(f"  {'-'*20} {'----':>4} {'-'*20} {'-'*25}")
    
    for name, psi in states.items():
        phi = integrated_info_rank(psi)
        cuts = cut_rank_profile(psi)
        
        if phi == 0:
            cls = "Trivial"
        elif phi == 1:
            cls = "Separable (no integration)"
        elif phi == 2:
            cls = "Weakly integrated"
        else:
            cls = f"Strongly integrated"
        
        print(f"  {name:<20} {phi:>4} {str(cuts):<20} {cls:<25}")
    
    print()


# ============================================================
# Application 2: Entanglement Structure Detection
# ============================================================

def entanglement_structure_analysis():
    """
    Analyze entanglement structure of many-body quantum states by
    computing the full bipartition rank spectrum.
    
    This reveals which subsystems are entangled and how strongly.
    """
    print("=" * 70)
    print("APPLICATION 2: Entanglement Structure Detection")
    print("=" * 70)
    print()
    
    # Create a state with known structure:
    # Sites 0,1 entangled; sites 2,3 entangled; no cross-entanglement
    bell = np.zeros((2, 2), dtype=complex)
    bell[0, 0] = 1/np.sqrt(2)
    bell[1, 1] = 1/np.sqrt(2)
    
    # |Bell⟩_{01} ⊗ |Bell⟩_{23}
    psi = np.tensordot(bell, bell, axes=0)  # shape (2,2,2,2)
    
    print("  State: |Bell⟩₀₁ ⊗ |Bell⟩₂₃")
    print()
    print(f"  {'Partition A':<15} {'Rank':>6} {'Interpretation':<35}")
    print(f"  {'-'*15} {'------':>6} {'-'*35}")
    
    for part in all_nontrivial_bipartitions(4):
        M = flatten_state(psi, part)
        r = matrix_rank(M)
        
        part_set = set(part)
        comp_set = set(range(4)) - part_set
        
        if part_set in [{0,1}, {2,3}]:
            interp = "Bell pair boundary → rank 2"
        elif part_set in [{0}, {1}]:
            interp = "Single site of Bell pair → rank 2"
        elif part_set in [{2}, {3}]:
            interp = "Single site of Bell pair → rank 2"
        elif len(part_set & {0,1}) > 0 and len(part_set & {2,3}) > 0:
            interp = "Mixed subsystems"
        else:
            interp = ""
        
        print(f"  {str(part):<15} {r:>6} {interp:<35}")
    
    phi = integrated_info_rank(psi)
    print(f"\n  Integrated information rank Φ# = {phi}")
    print(f"  → State has weak integration (product of Bell pairs)")
    print()


# ============================================================
# Application 3: Network Decomposability
# ============================================================

def network_decomposability():
    """
    Model a classical correlation network as a tensor state and
    analyze its decomposability using integrated information rank.
    
    This applies to neural network analysis, social network structure,
    and communication network design.
    """
    print("=" * 70)
    print("APPLICATION 3: Network Decomposability Analysis")
    print("=" * 70)
    print()
    
    n = 4
    
    # Model 1: Independent nodes (no connections)
    psi_indep = np.zeros((2,)*n, dtype=complex)
    for idx in cartesian_product(*[range(2)]*n):
        psi_indep[idx] = np.prod([np.array([0.7, 0.3])[i] for i in idx])
    psi_indep /= np.sqrt(np.sum(np.abs(psi_indep)**2))
    
    # Model 2: Pairwise correlated (01 and 23)
    psi_pair = np.zeros((2,)*n, dtype=complex)
    corr_01 = np.array([[0.8, 0.1], [0.1, 0.8]])
    corr_23 = np.array([[0.7, 0.2], [0.2, 0.7]])
    for idx in cartesian_product(*[range(2)]*n):
        psi_pair[idx] = corr_01[idx[0], idx[1]] * corr_23[idx[2], idx[3]]
    psi_pair /= np.sqrt(np.sum(np.abs(psi_pair)**2))
    
    # Model 3: Fully connected (all-to-all correlations)
    psi_full = np.zeros((2,)*n, dtype=complex)
    for idx in cartesian_product(*[range(2)]*n):
        s = sum(idx)
        psi_full[idx] = np.exp(-0.5 * (s - n/2)**2)
    psi_full /= np.sqrt(np.sum(np.abs(psi_full)**2))
    
    models = {
        "Independent nodes": psi_indep,
        "Pairwise clusters": psi_pair,
        "Fully connected": psi_full,
    }
    
    print(f"  {'Network Model':<25} {'Φ#':>4} {'Phi-faithful?':<15} {'Min cut rank':>12}")
    print(f"  {'-'*25} {'----':>4} {'-'*15} {'-'*12}")
    
    for name, psi in models.items():
        phi = integrated_info_rank(psi)
        faithful = phi > 1
        min_cut = min(cut_rank_profile(psi))
        
        print(f"  {name:<25} {phi:>4} {str(faithful):<15} {min_cut:>12}")
    
    print()
    print("  Interpretation:")
    print("  - Independent nodes: Φ# = 1 (fully decomposable)")
    print("  - Pairwise clusters: Φ# depends on cluster structure")
    print("  - Fully connected: Φ# > 1 (genuinely integrated)")
    print()


# ============================================================
# Application 4: Area Law Verification
# ============================================================

def area_law_verification():
    """
    Verify the 'area law' for MPS states: contiguous-cut entanglement
    is bounded by bond dimension, independent of system size.
    
    This is a key prediction connecting IIT to condensed matter physics.
    """
    print("=" * 70)
    print("APPLICATION 4: Area Law for MPS Integrated Information")
    print("=" * 70)
    print()
    
    D = 3
    d = 2
    
    print(f"  Bond dimension D = {D}, local dimension d = {d}")
    print()
    print(f"  {'n (sites)':<12} {'Φ#':>4} {'Max cut rank':>14} {'Φ# ≤ D?':>10}")
    print(f"  {'-'*12} {'----':>4} {'-'*14} {'-'*10}")
    
    np.random.seed(42)
    for n in range(3, 9):
        psi = random_mps(n, d, D)
        phi = integrated_info_rank(psi)
        max_cut = max(cut_rank_profile(psi))
        bounded = "✓" if phi <= D else "✗"
        
        print(f"  {n:<12} {phi:>4} {max_cut:>14} {bounded:>10}")
    
    print()
    print(f"  Observation: Φ# remains ≤ D = {D} regardless of system size n.")
    print("  This confirms the area-law behavior predicted by Theorem 2.")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Integrated Information: Real-World Applications                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    classify_quantum_states()
    entanglement_structure_analysis()
    network_decomposability()
    area_law_verification()
    
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Integrated Information via Tensor Networks — Demonstration Script

Generates small MPS (Matrix Product State) examples, computes cut-rank profiles,
and tests the main conjecture: that integrated information rank equals
the minimum contiguous-cut flattening rank for MPS states.

Usage:
    python demo.py
"""

import numpy as np
from itertools import product as cartesian_product


def tensor_product_state(psi_locals):
    """
    Construct a product state from local state vectors.
    
    Args:
        psi_locals: list of 1D arrays, one per site
    
    Returns:
        Full tensor state as a multi-dimensional array
    """
    result = psi_locals[0]
    for psi in psi_locals[1:]:
        result = np.tensordot(result, psi, axes=0)
    return result


def flatten_tensor(psi, partition_left):
    """
    Flatten a tensor state along a bipartition.
    
    Args:
        psi: n-dimensional array (tensor state)
        partition_left: list of indices for the 'left' subsystem
    
    Returns:
        2D matrix (flattening)
    """
    n = psi.ndim
    partition_right = [i for i in range(n) if i not in partition_left]
    
    # Transpose so left indices come first, then right
    perm = list(partition_left) + list(partition_right)
    psi_perm = np.transpose(psi, perm)
    
    # Reshape: left dims -> rows, right dims -> cols
    left_dim = int(np.prod([psi.shape[i] for i in partition_left]))
    right_dim = int(np.prod([psi.shape[i] for i in partition_right]))
    
    return psi_perm.reshape(left_dim, right_dim)


def flattening_rank(psi, partition_left, tol=1e-10):
    """
    Compute the flattening rank (number of nonzero singular values).
    
    Args:
        psi: tensor state
        partition_left: left partition indices
        tol: tolerance for singular value cutoff
    
    Returns:
        Integer rank
    """
    M = flatten_tensor(psi, partition_left)
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


def all_nontrivial_bipartitions(n):
    """
    Generate all nontrivial bipartitions of {0, ..., n-1}.
    A bipartition is nontrivial if both parts are nonempty.
    
    Yields:
        Lists of left-partition indices
    """
    for size in range(1, n):
        for combo in _combinations(list(range(n)), size):
            yield list(combo)


def _combinations(lst, k):
    """Simple combinations generator."""
    if k == 0:
        yield []
        return
    for i in range(len(lst)):
        for rest in _combinations(lst[i+1:], k-1):
            yield [lst[i]] + rest


def integrated_info_rank(psi):
    """
    Compute the integrated information rank:
    minimum flattening rank over all nontrivial bipartitions.
    
    Args:
        psi: tensor state (n-dimensional array)
    
    Returns:
        Integer (the integrated information rank)
    """
    n = psi.ndim
    if n < 2:
        return 0
    
    min_rank = float('inf')
    for partition in all_nontrivial_bipartitions(n):
        r = flattening_rank(psi, partition)
        min_rank = min(min_rank, r)
    
    return int(min_rank)


def contiguous_cut_ranks(psi):
    """
    Compute the flattening rank for each contiguous cut of a chain.
    Cut k separates sites {0,...,k} from {k+1,...,n-1}.
    
    Args:
        psi: tensor state
    
    Returns:
        List of ranks for cuts k=0,...,n-2
    """
    n = psi.ndim
    ranks = []
    for k in range(n - 1):
        left = list(range(k + 1))
        r = flattening_rank(psi, left)
        ranks.append(r)
    return ranks


def random_mps(n, d, D, normalize=True):
    """
    Generate a random MPS of bond dimension D.
    
    ψ(i₁,...,iₙ) = Tr(A₁[i₁] · A₂[i₂] · ... · Aₙ[iₙ])
    
    For open boundary conditions:
    ψ(i₁,...,iₙ) = A₁[i₁] · A₂[i₂] · ... · Aₙ[iₙ]
    where A₁ is 1×D, Aₖ is D×D, Aₙ is D×1
    
    Args:
        n: number of sites
        d: local dimension
        D: bond dimension
        normalize: whether to normalize the state
    
    Returns:
        Tensor state as n-dimensional array of shape (d,)*n
    """
    # Generate random MPS tensors
    tensors = []
    for site in range(n):
        if site == 0:
            # First tensor: 1 × D matrix for each physical index
            A = np.random.randn(d, 1, D) + 1j * np.random.randn(d, 1, D)
        elif site == n - 1:
            # Last tensor: D × 1 matrix for each physical index
            A = np.random.randn(d, D, 1) + 1j * np.random.randn(d, D, 1)
        else:
            # Middle tensors: D × D matrix for each physical index
            A = np.random.randn(d, D, D) + 1j * np.random.randn(d, D, D)
        tensors.append(A)
    
    # Contract the MPS to get the full tensor
    shape = tuple(d for _ in range(n))
    psi = np.zeros(shape, dtype=complex)
    
    for idx in cartesian_product(*[range(d) for _ in range(n)]):
        # Multiply matrices for each site
        result = tensors[0][idx[0]]  # 1×D
        for site in range(1, n):
            result = result @ tensors[site][idx[site]]
        psi[idx] = result[0, 0]  # scalar
    
    if normalize:
        norm = np.sqrt(np.sum(np.abs(psi)**2))
        if norm > 0:
            psi = psi / norm
    
    return psi


def demo_product_states():
    """Demonstrate Theorem 1: Product states have integrated info rank = 1."""
    print("=" * 70)
    print("THEOREM 1: Product States Have Integrated Information Rank = 1")
    print("=" * 70)
    print()
    
    for n in [2, 3, 4]:
        for d in [2, 3]:
            # Random nonzero local states
            psi_locals = [np.random.randn(d) + 1j * np.random.randn(d) for _ in range(n)]
            psi = tensor_product_state(psi_locals)
            phi = integrated_info_rank(psi)
            
            print(f"  n={n} sites, d={d} local dim: Φ# = {phi}")
            assert phi == 1, f"Expected 1, got {phi}!"
    
    print()
    print("  ✓ All product states have Φ# = 1 (verified)")
    print()


def demo_mps_bond_dimension_bound():
    """Demonstrate Theorem 2: MPS bond dimension bounds integrated info."""
    print("=" * 70)
    print("THEOREM 2: MPS Bond Dimension Bounds Integrated Information")
    print("=" * 70)
    print()
    
    for n in [3, 4, 5]:
        for D in [2, 3, 4]:
            d = 2
            psi = random_mps(n, d, D)
            phi = integrated_info_rank(psi)
            cut_ranks = contiguous_cut_ranks(psi)
            
            print(f"  n={n}, d={d}, D={D}: Φ# = {phi}, "
                  f"cut ranks = {cut_ranks}")
            assert phi <= D, f"Expected Φ# ≤ {D}, got {phi}!"
    
    print()
    print("  ✓ All MPS states satisfy Φ# ≤ D (verified)")
    print()


def demo_exact_bond_dim_2():
    """Demonstrate Theorem 3: Bond-dim-2 MPS with full-rank cuts → Φ# = 2."""
    print("=" * 70)
    print("THEOREM 3: Bond-Dimension-2 MPS Exact Computation")
    print("=" * 70)
    print()
    
    n, d, D = 4, 2, 2
    num_trials = 100
    num_full_rank = 0
    
    for trial in range(num_trials):
        psi = random_mps(n, d, D)
        phi = integrated_info_rank(psi)
        cut_ranks = contiguous_cut_ranks(psi)
        
        if all(r >= 2 for r in cut_ranks):
            num_full_rank += 1
            assert phi == 2, f"Expected Φ# = 2, got {phi}!"
    
    print(f"  Generated {num_trials} random D=2 MPS on {n} sites (d={d})")
    print(f"  {num_full_rank} had all contiguous cut ranks ≥ 2")
    print(f"  All of those had Φ# = 2 exactly (verified)")
    print()


def demo_conjecture_test():
    """
    Test the MPS min-cut Phi conjecture:
    For MPS, Φ# = min contiguous-cut rank.
    
    Search for counterexamples.
    """
    print("=" * 70)
    print("CONJECTURE TEST: Φ# = min contiguous-cut rank for MPS")
    print("=" * 70)
    print()
    
    counterexamples = 0
    total_tests = 0
    
    for n in [3, 4, 5]:
        for D in [2, 3]:
            d = 2
            for _ in range(200):
                total_tests += 1
                psi = random_mps(n, d, D)
                
                phi = integrated_info_rank(psi)
                min_contiguous = min(contiguous_cut_ranks(psi))
                
                if phi != min_contiguous:
                    counterexamples += 1
                    print(f"  COUNTEREXAMPLE: n={n}, D={D}: "
                          f"Φ#={phi} ≠ min_contiguous={min_contiguous}")
                    # Show all bipartition ranks
                    print(f"    Cut ranks: {contiguous_cut_ranks(psi)}")
                    for part in all_nontrivial_bipartitions(n):
                        r = flattening_rank(psi, part)
                        print(f"    Partition {part}: rank={r}")
    
    print()
    if counterexamples == 0:
        print(f"  No counterexamples found in {total_tests} tests!")
        print("  The conjecture holds in all tested cases.")
    else:
        print(f"  Found {counterexamples} counterexamples in {total_tests} tests.")
        print("  The conjecture is FALSIFIED for general bipartitions.")
        print("  (Non-contiguous bipartitions can have lower rank than "
              "any contiguous cut.)")
    print()


def demo_dimension_bound():
    """Demonstrate cross-domain theorem: rank ≤ min(left_dim, right_dim)."""
    print("=" * 70)
    print("CROSS-DOMAIN: Flattening Rank ≤ min(left_dim, right_dim)")
    print("=" * 70)
    print()
    
    n, d = 4, 3
    psi = np.random.randn(*([d]*n)) + 1j * np.random.randn(*([d]*n))
    
    for part in [[0], [0,1], [0,1,2], [1,3]]:
        r = flattening_rank(psi, part)
        left_dim = d ** len(part)
        right_dim = d ** (n - len(part))
        bound = min(left_dim, right_dim)
        print(f"  Partition {part}: rank={r}, "
              f"left_dim={left_dim}, right_dim={right_dim}, "
              f"bound={bound}, satisfied: {r <= bound}")
        assert r <= bound
    
    print()
    print("  ✓ Dimension bound satisfied for all bipartitions")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Integrated Information via Tensor Networks — Numerical Demos      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_product_states()
    demo_mps_bond_dimension_bound()
    demo_exact_bond_dim_2()
    demo_dimension_bound()
    demo_conjecture_test()
    
    print("All demonstrations completed successfully.")
