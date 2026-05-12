#!/usr/bin/env python3
"""
Algorithms for Closure-Matroid-Secret Sharing

Implements the key algorithms from the research paper:
1. Greedy rank computation
2. Minimal qualified set extraction  
3. Access structure enumeration
4. Flat lattice computation
"""

from typing import Set, FrozenSet, Callable, List, Tuple, Optional
import itertools


def greedy_rank(ground: frozenset, cl: Callable, A: frozenset) -> Tuple[int, frozenset]:
    """Compute rank of A by greedily building a maximal independent subset.
    
    Algorithm:
        Start with I = ∅
        For each x ∈ A:
            If x ∉ cl(I), add x to I
        Return |I|
    
    Returns: (rank, basis) where basis is a maximal independent subset
    
    Time: O(|A| · T_cl) where T_cl is the cost of one closure computation
    Space: O(|A|)
    """
    basis = frozenset()
    for x in sorted(A, key=str):  # deterministic ordering
        if x not in cl(basis):
            basis = basis | {x}
    return len(basis), basis


def greedy_prune_minimal_qualified(
    ground: frozenset, cl: Callable, dealer: object, A: frozenset
) -> frozenset:
    """Find a minimal qualified subset of A by greedy deletion.
    
    Algorithm:
        B = A
        For each x ∈ A:
            If dealer ∈ cl(B \ {x}):
                B = B \ {x}
        Return B
    
    Precondition: dealer ∈ cl(A)
    Postcondition: B ⊆ A, dealer ∈ cl(B), and B is minimal qualified
    
    Time: O(|A| · T_cl)
    Space: O(|A|)
    """
    assert dealer in cl(A), "A must be qualified"
    B = set(A)
    for x in sorted(A, key=str):
        candidate = frozenset(B - {x})
        if dealer in cl(candidate):
            B = set(candidate)
    return frozenset(B)


def enumerate_access_structure(
    ground: frozenset, cl: Callable, dealer: object
) -> Tuple[List[frozenset], List[frozenset], List[frozenset]]:
    """Enumerate the complete access structure for a dealer.
    
    Returns:
        (qualified, private, minimal_qualified)
    
    Time: O(2^|ground| · T_cl)
    """
    participants = ground - {dealer}
    qualified = []
    private = []
    minimal_qualified = []
    
    for r in range(len(participants) + 1):
        for combo in itertools.combinations(sorted(participants, key=str), r):
            A = frozenset(combo)
            if dealer in cl(A):
                qualified.append(A)
                # Check minimality
                is_minimal = all(
                    dealer not in cl(A - {x}) for x in A
                )
                if is_minimal:
                    minimal_qualified.append(A)
            else:
                private.append(A)
    
    return qualified, private, minimal_qualified


def compute_flat_lattice(
    ground: frozenset, cl: Callable
) -> List[Tuple[frozenset, int]]:
    """Compute all flats (closed sets) with their ranks.
    
    Returns: List of (flat, rank) pairs, sorted by rank
    
    Time: O(2^|ground| · T_cl)
    """
    flats = []
    for r in range(len(ground) + 1):
        for combo in itertools.combinations(sorted(ground, key=str), r):
            A = frozenset(combo)
            closure = cl(A)
            if closure == A:
                rank, _ = greedy_rank(ground, cl, A)
                flats.append((A, rank))
    
    return sorted(flats, key=lambda x: (x[1], len(x[0])))


def rank_stratification(
    ground: frozenset, cl: Callable, dealer: object
) -> dict:
    """Compute the rank stratification of the access structure.
    
    Groups qualified and private sets by the rank of their closure.
    Shows how rank controls the threshold profile.
    
    Returns: dict mapping rank -> {qualified_count, private_count, 
                                    qualified_examples, private_examples}
    """
    participants = ground - {dealer}
    strata = {}
    
    for r in range(len(participants) + 1):
        for combo in itertools.combinations(sorted(participants, key=str), r):
            A = frozenset(combo)
            rk, _ = greedy_rank(ground, cl, A)
            
            if rk not in strata:
                strata[rk] = {
                    'qualified_count': 0, 'private_count': 0,
                    'qualified_examples': [], 'private_examples': []
                }
            
            if dealer in cl(A):
                strata[rk]['qualified_count'] += 1
                if len(strata[rk]['qualified_examples']) < 3:
                    strata[rk]['qualified_examples'].append(A)
            else:
                strata[rk]['private_count'] += 1
                if len(strata[rk]['private_examples']) < 3:
                    strata[rk]['private_examples'].append(A)
    
    return strata


if __name__ == "__main__":
    import numpy as np
    
    # Example: rank-3 vector matroid
    ground = frozenset({'d', 1, 2, 3, 4})
    vectors = {'d': (1, 0, 0), 1: (0, 1, 0), 2: (0, 0, 1), 3: (1, 1, 0), 4: (1, 0, 1)}
    
    def cl(A):
        if not A:
            return frozenset()
        result = set(A)
        base = [list(vectors[a]) for a in A]
        br = np.linalg.matrix_rank(np.array(base, dtype=float))
        for x in ground - A:
            test = base + [list(vectors[x])]
            if np.linalg.matrix_rank(np.array(test, dtype=float)) == br:
                result.add(x)
        return frozenset(result)
    
    print("=== Greedy Rank ===")
    for subset in [frozenset(), frozenset({1}), frozenset({1, 2}), frozenset({1, 2, 3}), ground]:
        r, basis = greedy_rank(ground, cl, subset)
        print(f"  rank({sorted(subset, key=str)}) = {r}, basis = {sorted(basis, key=str)}")
    
    print("\n=== Minimal Qualified Set (Greedy Prune) ===")
    full = frozenset({1, 2, 3, 4})
    mq = greedy_prune_minimal_qualified(ground, cl, 'd', full)
    print(f"  Pruned {sorted(full, key=str)} → {sorted(mq, key=str)}")
    
    print("\n=== Access Structure ===")
    qual, priv, minqual = enumerate_access_structure(ground, cl, 'd')
    print(f"  Qualified: {len(qual)}, Private: {len(priv)}")
    print(f"  Minimal qualified: {[sorted(m, key=str) for m in minqual]}")
    
    print("\n=== Flat Lattice ===")
    for flat, rank in compute_flat_lattice(ground, cl):
        print(f"  rank {rank}: {sorted(flat, key=str)}")
    
    print("\n=== Rank Stratification ===")
    strata = rank_stratification(ground, cl, 'd')
    for rk in sorted(strata):
        s = strata[rk]
        print(f"  rank {rk}: {s['qualified_count']} qualified, {s['private_count']} private")
