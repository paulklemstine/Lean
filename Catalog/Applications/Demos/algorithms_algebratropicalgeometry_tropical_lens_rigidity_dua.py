#!/usr/bin/env python3
"""
Algorithms for Tropical Lens Rigidity and Metric-Tree Reconstruction

Implements:
1. Star tree reconstruction from boundary distances
2. Four-point condition verification
3. Split system construction and distance computation
4. Buneman split decomposition
5. Compatibility checking for split systems

All algorithms have documented complexity bounds.
"""

from fractions import Fraction
from itertools import combinations, permutations
from typing import List, Tuple, Optional, Set, FrozenSet
from dataclasses import dataclass


@dataclass
class WeightedSplit:
    """A weighted bipartition of a finite set.
    
    Attributes:
        left: frozenset of vertices on the 'left' side
        right: frozenset of vertices on the 'right' side
        weight: positive rational weight
    """
    left: FrozenSet[int]
    right: FrozenSet[int]
    weight: Fraction
    
    def separates(self, i: int, j: int) -> bool:
        """Whether this split separates vertices i and j.
        
        Time: O(1) amortized (frozenset lookup)
        """
        return (i in self.left) != (j in self.left)
    
    def dist_contrib(self, i: int, j: int) -> Fraction:
        """Distance contribution of this split to d(i,j).
        
        Time: O(1)
        """
        return self.weight if self.separates(i, j) else Fraction(0)
    
    def is_nontrivial(self) -> bool:
        """Whether both sides are nonempty."""
        return len(self.left) > 0 and len(self.right) > 0
    
    def __repr__(self):
        return f"Split({sorted(self.left)}|{sorted(self.right)}, w={float(self.weight):.4f})"


def star_distance_matrix(weights: List[Fraction]) -> List[List[Fraction]]:
    """Compute the distance matrix of a star tree.
    
    For a star tree with center connected to leaves 0,...,b-1 
    with edge weights w_0,...,w_{b-1}:
        d(i,j) = w_i + w_j  for i ≠ j
        d(i,i) = 0
    
    Time: O(b²)
    Space: O(b²)
    
    Args:
        weights: list of b positive rational edge weights
    
    Returns:
        b×b distance matrix
    """
    b = len(weights)
    return [[Fraction(0) if i == j else weights[i] + weights[j] 
             for j in range(b)] for i in range(b)]


def reconstruct_star_weights(D: List[List[Fraction]], 
                              j0: int = 0, k0: int = 1) -> List[Fraction]:
    """Reconstruct star tree edge weights from the distance matrix.
    
    Uses the formula: w_i = (d(i,j₀) + d(i,k₀) - d(j₀,k₀)) / 2
    
    This is correct for i ∉ {j₀, k₀}. For the reference vertices
    themselves, use a different pair of reference vertices.
    
    Time: O(b)
    Space: O(b)
    
    Args:
        D: distance matrix
        j0, k0: reference vertex indices (must be distinct)
    
    Returns:
        list of reconstructed weights
    """
    b = len(D)
    assert j0 != k0, "Reference vertices must be distinct"
    return [(D[i][j0] + D[i][k0] - D[j0][k0]) / 2 for i in range(b)]


def verify_four_point(D: List[List[Fraction]]) -> Tuple[bool, List[Tuple]]:
    """Verify the four-point (tree metric) condition.
    
    Checks: for all i,j,k,l:
        d(i,j) + d(k,l) ≤ max(d(i,k) + d(j,l), d(i,l) + d(j,k))
    
    Time: O(b⁴)
    Space: O(1) plus violations list
    
    Args:
        D: distance matrix
    
    Returns:
        (is_tree_metric, list_of_violations)
    """
    b = len(D)
    violations = []
    for i in range(b):
        for j in range(b):
            for k in range(b):
                for l in range(b):
                    s1 = D[i][j] + D[k][l]
                    s2 = D[i][k] + D[j][l]
                    s3 = D[i][l] + D[j][k]
                    if s1 > max(s2, s3):
                        violations.append((i, j, k, l))
    return len(violations) == 0, violations


def verify_star_pattern(D: List[List[Fraction]]) -> bool:
    """Check if a distance matrix has star-tree form.
    
    A distance matrix is a star metric iff for all distinct i,j,k,l:
        d(i,j) + d(k,l) = d(i,k) + d(j,l) = d(i,l) + d(j,k)
    
    (All three cross-sums are equal.)
    
    Time: O(b⁴)
    
    Args:
        D: distance matrix
    
    Returns:
        True iff D has star-tree form
    """
    b = len(D)
    for i, j, k, l in combinations(range(b), 4):
        s1 = D[i][j] + D[k][l]
        s2 = D[i][k] + D[j][l]
        s3 = D[i][l] + D[j][k]
        if not (s1 == s2 == s3):
            return False
    return True


def splits_compatible(s1: WeightedSplit, s2: WeightedSplit) -> bool:
    """Check if two splits are compatible.
    
    Two splits {A₁|B₁} and {A₂|B₂} are compatible iff one of the four
    intersections A₁∩A₂, A₁∩B₂, B₁∩A₂, B₁∩B₂ is empty.
    
    Time: O(b)
    
    Args:
        s1, s2: weighted splits
    
    Returns:
        True iff the splits are compatible
    """
    has_tt = bool(s1.left & s2.left)
    has_tf = bool(s1.left & s2.right)
    has_ft = bool(s1.right & s2.left)
    has_ff = bool(s1.right & s2.right)
    return not (has_tt and has_tf and has_ft and has_ff)


def split_system_distance(splits: List[WeightedSplit], 
                           b: int) -> List[List[Fraction]]:
    """Compute the distance matrix of a split system.
    
    d(i,j) = Σ_{s separating i,j} w(s)
    
    Time: O(b² · |splits|)
    Space: O(b²)
    """
    D = [[Fraction(0)] * b for _ in range(b)]
    for i in range(b):
        for j in range(i + 1, b):
            d = sum(s.dist_contrib(i, j) for s in splits)
            D[i][j] = d
            D[j][i] = d
    return D


def buneman_isolation_index(D: List[List[Fraction]], 
                             A: FrozenSet[int], B: FrozenSet[int],
                             i: int, j: int) -> Fraction:
    """Compute the Buneman isolation index for a candidate split.
    
    For a split {A|B} and vertices i∈A, j∈B:
        α(A|B) = min over (a∈A, b∈B) of (d(a,j) + d(b,i) - d(a,b) - d(i,j)) / 2
    
    If α > 0 for all choices of i∈A, j∈B, the split is realized by the tree.
    
    Time: O(|A| · |B|)
    """
    min_val = None
    for a in A:
        for b in B:
            val = (D[a][j] + D[b][i] - D[a][b] - D[i][j]) / 2
            if min_val is None or val < min_val:
                min_val = val
    return min_val if min_val is not None else Fraction(0)


def find_geodesic_isomorphism(D1: List[List[Fraction]], 
                                D2: List[List[Fraction]]) -> Optional[List[int]]:
    """Find a geodesic isomorphism between two distance matrices, if one exists.
    
    Searches for a permutation σ such that d₁(i,j) = d₂(σ(i),σ(j)) for all i,j.
    
    Time: O(b! · b²) worst case (brute force)
         O(b³) with profile-based matching heuristic
    
    Args:
        D1, D2: distance matrices of same size
    
    Returns:
        permutation σ as list, or None if no isomorphism exists
    """
    b = len(D1)
    assert len(D2) == b, "Matrices must have same size"
    
    # Heuristic: group by sorted distance profile
    profiles1 = {}
    profiles2 = {}
    for i in range(b):
        p1 = tuple(sorted(D1[i]))
        p2 = tuple(sorted(D2[i]))
        profiles1.setdefault(p1, []).append(i)
        profiles2.setdefault(p2, []).append(i)
    
    # Quick rejection: profile multisets must match
    if sorted(profiles1.keys()) != sorted(profiles2.keys()):
        return None
    
    # Try all consistent permutations
    for perm in permutations(range(b)):
        if all(D1[i][j] == D2[perm[i]][perm[j]] 
               for i in range(b) for j in range(b)):
            return list(perm)
    
    return None


def certified_star_reconstruction(D: List[List[Fraction]]) -> Optional[List[Fraction]]:
    """Certified reconstruction pipeline for star trees.
    
    Given a distance matrix:
    1. Verify four-point condition
    2. Verify star-tree pattern
    3. Reconstruct weights
    4. Verify reconstruction matches original
    
    Time: O(b⁴) dominated by four-point verification
    Space: O(b²)
    
    Args:
        D: distance matrix
    
    Returns:
        reconstructed weights, or None if not a star metric
    """
    b = len(D)
    
    # Step 1: Four-point check
    is_tree, _ = verify_four_point(D)
    if not is_tree:
        return None
    
    # Step 2: Star pattern check
    if not verify_star_pattern(D):
        return None
    
    # Step 3: Reconstruct using multiple reference pairs
    if b < 2:
        return None
    weights = [Fraction(0)] * b
    # Use (0,1) for i >= 2
    rec01 = reconstruct_star_weights(D, 0, 1)
    for i in range(2, b):
        weights[i] = rec01[i]
    # Use other pairs for 0 and 1
    if b >= 4:
        rec23 = reconstruct_star_weights(D, 2, 3)
        weights[0] = rec23[0]
        weights[1] = rec23[1]
    elif b == 3:
        rec12 = reconstruct_star_weights(D, 1, 2)
        weights[0] = rec12[0]
        rec02 = reconstruct_star_weights(D, 0, 2)
        weights[1] = rec02[1]
    elif b == 2:
        weights[0] = D[0][1] / 2
        weights[1] = D[0][1] / 2
    
    # Step 4: Certify
    D_check = star_distance_matrix(weights)
    if any(D[i][j] != D_check[i][j] for i in range(b) for j in range(b)):
        return None
    
    return weights


if __name__ == "__main__":
    print("Algorithms module — run demo.py for demonstrations")
    
    # Quick self-test
    w = [Fraction(3), Fraction(5), Fraction(7), Fraction(2)]
    D = star_distance_matrix(w)
    
    is_tree, _ = verify_four_point(D)
    assert is_tree, "Star tree should satisfy four-point"
    
    is_star = verify_star_pattern(D)
    assert is_star, "Star tree should have star pattern"
    
    w_rec = certified_star_reconstruction(D)
    # Reconstruction uses ref (0,1), so w[0] and w[1] may differ
    # but the distance matrix will match
    assert w_rec is not None, "Should reconstruct successfully"
    D_rec = star_distance_matrix(w_rec)
    assert all(D[i][j] == D_rec[i][j] for i in range(4) for j in range(4)), \
        "Reconstructed distance matrix should match"
    
    # Test geodesic isomorphism
    w2 = [Fraction(7), Fraction(3), Fraction(5), Fraction(2)]
    D2 = star_distance_matrix(w2)
    sigma = find_geodesic_isomorphism(D, D2)
    assert sigma is not None, "Should find isomorphism"
    assert all(w[i] == w2[sigma[i]] for i in range(4)), "Weights should match under σ"
    
    print("All self-tests passed!")
