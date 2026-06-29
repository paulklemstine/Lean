#!/usr/bin/env python3
"""
Algorithms for Argumentation Complex Analysis
==============================================
Type-hinted implementations of the core algorithms.
"""

from typing import Set, Dict, List, Tuple, FrozenSet, Optional
from itertools import combinations
from collections import defaultdict


def compute_conflict_free_sets(
    arguments: List[str],
    attacks: Set[Tuple[str, str]]
) -> List[FrozenSet[str]]:
    """
    Compute all conflict-free sets of an argumentation framework.
    
    Algorithm: Enumerate all subsets and check pairwise non-attack.
    Complexity: O(2^n * n^2) where n = |arguments|.
    
    Pseudocode:
        CF = {∅}
        for k = 1 to |A|:
            for each k-subset S of A:
                if no (a,b) ∈ R with a,b ∈ S:
                    CF = CF ∪ {S}
        return CF
    """
    result: List[FrozenSet[str]] = [frozenset()]
    for k in range(1, len(arguments) + 1):
        for combo in combinations(arguments, k):
            S = set(combo)
            conflict = False
            for a in S:
                for b in S:
                    if (a, b) in attacks:
                        conflict = True
                        break
                if conflict:
                    break
            if not conflict:
                result.append(frozenset(combo))
    return result


def compute_defense_filtration(
    arguments: List[str],
    attacks: Set[Tuple[str, str]]
) -> List[Set[str]]:
    """
    Compute the defense filtration F_0 ⊆ F_1 ⊆ ... converging to the
    grounded extension.
    
    Algorithm: Iteratively compute defended arguments until stabilization.
    Complexity: O(n^3) where n = |arguments| (at most n iterations,
                each checking n arguments against n attackers).
    
    Pseudocode:
        F_0 = ∅
        repeat:
            F_{k+1} = {a ∈ A : ∀b. R(b,a) → ∃c ∈ F_k. R(c,b)}
        until F_{k+1} = F_k
        return [F_0, F_1, ..., F_k]
    """
    attack_dict: Dict[str, Set[str]] = defaultdict(set)
    for a, b in attacks:
        attack_dict[b].add(a)
    
    levels: List[Set[str]] = [set()]
    for _ in range(len(arguments) + 1):
        prev = levels[-1]
        next_level: Set[str] = set()
        for a in arguments:
            defended = True
            for b in attack_dict[a]:
                if not any((c, b) in attacks for c in prev):
                    defended = False
                    break
            if defended:
                next_level.add(a)
        levels.append(next_level)
        if next_level == prev:
            break
    return levels


def compute_f_vector(
    conflict_free_sets: List[FrozenSet[str]]
) -> Dict[int, int]:
    """
    Compute the f-vector of the argumentation complex.
    
    f[k] = number of faces of dimension k.
    Dimension of a face S is |S| - 1 (so ∅ has dimension -1).
    
    Pseudocode:
        for each face S in K(AF):
            f[|S| - 1] += 1
        return f
    """
    fvec: Dict[int, int] = defaultdict(int)
    for S in conflict_free_sets:
        fvec[len(S) - 1] += 1
    return dict(sorted(fvec.items()))


def compute_euler_characteristic(f_vector: Dict[int, int]) -> float:
    """
    Compute the Euler characteristic χ = Σ (-1)^k f_k.
    
    Pseudocode:
        χ = 0
        for each (k, f_k) in f-vector:
            χ += (-1)^k * f_k
        return χ
    """
    return sum((-1)**k * v for k, v in f_vector.items())


def compute_preferred_extensions(
    arguments: List[str],
    attacks: Set[Tuple[str, str]]
) -> List[FrozenSet[str]]:
    """
    Compute all preferred extensions (maximal admissible sets).
    
    Algorithm:
        1. Compute all conflict-free sets
        2. Filter for admissible (self-defending)
        3. Filter for maximal (no proper admissible superset)
    
    Pseudocode:
        ADM = {S ∈ CF : ∀a ∈ S. S defends a}
        PREF = {S ∈ ADM : ¬∃T ∈ ADM. S ⊊ T}
        return PREF
    """
    attack_dict: Dict[str, Set[str]] = defaultdict(set)
    for a, b in attacks:
        attack_dict[b].add(a)
    
    def defends(S: Set[str], a: str) -> bool:
        for b in attack_dict[a]:
            if not any((c, b) in attacks for c in S):
                return False
        return True
    
    def is_conflict_free(S: Set[str]) -> bool:
        for a in S:
            for b in S:
                if (a, b) in attacks:
                    return False
        return True
    
    def is_admissible(S: Set[str]) -> bool:
        if not is_conflict_free(S):
            return False
        return all(defends(S, a) for a in S)
    
    cf = compute_conflict_free_sets(arguments, attacks)
    admissible = [S for S in cf if is_admissible(set(S))]
    
    preferred: List[FrozenSet[str]] = []
    for S in admissible:
        is_max = True
        for T in admissible:
            if S < T:  # proper subset
                is_max = False
                break
        if is_max:
            preferred.append(S)
    
    return preferred


def compute_defense_depth(
    arguments: List[str],
    attacks: Set[Tuple[str, str]]
) -> Dict[str, Optional[int]]:
    """
    Compute the defense depth of each argument.
    
    The defense depth of argument a is the first level k ≥ 1
    such that a ∈ F_k in the defense filtration.
    Returns None for arguments not in the grounded extension.
    
    Pseudocode:
        levels = defense_filtration(AF)
        for each a ∈ A:
            depth[a] = min{k : a ∈ F_k} or None
        return depth
    """
    levels = compute_defense_filtration(arguments, attacks)
    depth: Dict[str, Optional[int]] = {}
    for a in arguments:
        d = None
        for k, level in enumerate(levels):
            if a in level:
                d = k
                break
        depth[a] = d
    return depth


if __name__ == "__main__":
    # Example: run algorithms on a sample framework
    args = ['A', 'B', 'C', 'D']
    atks = {('A', 'B'), ('B', 'C'), ('C', 'D'), ('D', 'A')}
    
    print("4-Cycle Framework Analysis")
    print("=" * 40)
    
    cf = compute_conflict_free_sets(args, atks)
    print(f"Conflict-free sets: {len(cf)}")
    
    fvec = compute_f_vector(cf)
    print(f"f-vector: {fvec}")
    
    chi = compute_euler_characteristic(fvec)
    print(f"Euler characteristic: {chi}")
    
    pref = compute_preferred_extensions(args, atks)
    print(f"Preferred extensions: {[set(S) for S in pref]}")
    
    levels = compute_defense_filtration(args, atks)
    print(f"Defense filtration depth: {len(levels) - 1}")
    
    depths = compute_defense_depth(args, atks)
    print(f"Defense depths: {depths}")
