#!/usr/bin/env python3
"""
Algorithms for the Geometry of Consensus.

Type-hinted implementations of the core algorithms:
1. Condorcet curvature computation
2. Fisher embedding and Bhattacharyya coefficient
3. Polarization index
4. Holonomy defect algebra operations
5. Decisive family (ultrafilter) detection
"""

from __future__ import annotations
import numpy as np
from typing import Optional


# ============================================================================
# Core Data Structures
# ============================================================================

class TournamentSign:
    """Tournament sign function on n alternatives.
    
    Encodes a complete tournament via an antisymmetric sign matrix
    σ: {0,...,n-1}² → {-1, 0, 1}.
    """
    
    def __init__(self, sign_matrix: np.ndarray) -> None:
        n = sign_matrix.shape[0]
        assert sign_matrix.shape == (n, n), "Sign matrix must be square"
        assert np.all(np.diag(sign_matrix) == 0), "Diagonal must be zero"
        assert np.allclose(sign_matrix + sign_matrix.T, 0), "Must be antisymmetric"
        self.n = n
        self.sign = sign_matrix
    
    @classmethod
    def from_preferences(cls, profiles: list[list[int]], n_alts: int) -> TournamentSign:
        """Construct tournament from voter preference profiles."""
        k = len(profiles)
        sign = np.zeros((n_alts, n_alts), dtype=int)
        for a in range(n_alts):
            for b in range(n_alts):
                if a == b:
                    continue
                count = sum(1 for p in profiles if p.index(a) < p.index(b))
                sign[a, b] = 1 if 2 * count > k else -1
        return cls(sign)
    
    def triple_defect(self, a: int, b: int, c: int) -> int:
        """Holonomy defect δ(a,b,c) = σ(a,b)·σ(b,c)·σ(c,a)."""
        return int(self.sign[a, b] * self.sign[b, c] * self.sign[c, a])
    
    def condorcet_curvature(self) -> int:
        """Count directed 3-cycles (Condorcet curvature)."""
        count = 0
        for a in range(self.n):
            for b in range(a + 1, self.n):
                for c in range(b + 1, self.n):
                    if self.triple_defect(a, b, c) == 1:
                        count += 1
        return count
    
    def total_holonomy(self) -> int:
        """Sum of triple defects over ordered triples."""
        total = 0
        for a in range(self.n):
            for b in range(a + 1, self.n):
                for c in range(b + 1, self.n):
                    total += self.triple_defect(a, b, c)
        return total
    
    def score_sequence(self) -> np.ndarray:
        """Score sequence s(a) = Σ_b σ(a,b)."""
        return self.sign.sum(axis=1)
    
    def is_transitive(self) -> bool:
        """Check transitivity (zero curvature)."""
        return self.condorcet_curvature() == 0


class HolonomyDefectAlgebra(TournamentSign):
    """The Holonomy Defect Algebra — extends TournamentSign with score operations."""
    
    def __init__(self, sign_matrix: np.ndarray) -> None:
        super().__init__(sign_matrix)
        self._scores = self.score_sequence()
    
    @property
    def scores(self) -> np.ndarray:
        return self._scores
    
    def score_variance(self) -> int:
        """Sum of squared scores Σ s(a)²."""
        return int(np.sum(self._scores ** 2))
    
    def moon_cycle_count(self) -> int:
        """Compute 3-cycle count via Moon's formula.
        
        c₃ = C(n,3) - Σᵢ C(wᵢ, 2) where wᵢ = (n-1+sᵢ)/2.
        """
        n = self.n
        c_n_3 = n * (n - 1) * (n - 2) // 6
        w = (n - 1 + self._scores) // 2  # win counts
        return c_n_3 - sum(int(wi * (wi - 1)) // 2 for wi in w)
    
    def verify_gauss_bonnet(self) -> bool:
        """Verify the discrete Gauss-Bonnet identity:
        totalHolonomy = transitiveTriples - cycleCount."""
        c3 = self.condorcet_curvature()
        c_n_3 = self.n * (self.n - 1) * (self.n - 2) // 6
        return self.total_holonomy() == (c_n_3 - c3) - c3


# ============================================================================
# Fisher Geometry
# ============================================================================

def fisher_embedding(p: np.ndarray) -> np.ndarray:
    """Fisher embedding: p ↦ √p. Maps simplex Δ^{m-1} to sphere S^{m-1}.
    
    Args:
        p: Probability distribution (non-negative, sums to 1)
    
    Returns:
        Point on the unit sphere
    """
    return np.sqrt(np.maximum(p, 0))


def bhattacharyya_coefficient(p: np.ndarray, q: np.ndarray) -> float:
    """Bhattacharyya coefficient: BC(p,q) = Σᵢ √(pᵢqᵢ).
    
    Equals the inner product of Fisher embeddings: BC = ⟨φ(p), φ(q)⟩.
    Satisfies 0 ≤ BC ≤ 1, with BC = 1 iff p = q.
    """
    return float(np.sum(np.sqrt(np.maximum(p * q, 0))))


def hellinger_distance_sq(p: np.ndarray, q: np.ndarray) -> float:
    """Squared Hellinger distance: H²(p,q) = Σ(√pᵢ - √qᵢ)².
    
    Equals 2(1 - BC(p,q)) by the Hellinger-Bhattacharyya identity.
    """
    fp, fq = fisher_embedding(p), fisher_embedding(q)
    return float(np.sum((fp - fq) ** 2))


def polarization_index(distributions: list[np.ndarray]) -> float:
    """Polarization index of a voter profile.
    
    Pol = (1/k²) Σᵢⱼ (1 - BC(pᵢ, pⱼ))
    
    Measures average pairwise disagreement on the Fisher manifold.
    Zero when all voters agree; maximized when voters are antipodal.
    """
    k = len(distributions)
    if k == 0:
        return 0.0
    total = sum(
        1 - bhattacharyya_coefficient(distributions[i], distributions[j])
        for i in range(k) for j in range(k)
    )
    return total / k ** 2


def fisher_rao_distance(p: np.ndarray, q: np.ndarray) -> float:
    """Fisher-Rao geodesic distance on the probability simplex.
    
    d_FR(p,q) = 2·arccos(BC(p,q)).
    This is the arc length on the sphere S^{m-1} between φ(p) and φ(q).
    """
    bc = bhattacharyya_coefficient(p, q)
    bc = np.clip(bc, -1, 1)  # numerical safety
    return 2 * np.arccos(bc)


# ============================================================================
# Decisive Family Detection
# ============================================================================

def find_dictator(
    f: "callable",  # f: tuple[bool,...] -> bool
    k: int
) -> Optional[int]:
    """Find a dictator for a Boolean function f: {0,1}^k → {0,1}.
    
    A dictator is a coordinate d such that f(v) = v[d] for all v.
    Returns the dictator index, or None if no dictator exists.
    """
    for d in range(k):
        is_dictator = True
        for bits in range(2 ** k):
            v = tuple((bits >> i) & 1 for i in range(k))
            if f(v) != v[d]:
                is_dictator = False
                break
        if is_dictator:
            return d
    return None


def find_pivotal_voter(
    f: "callable",  # f: tuple[bool,...] -> bool
    k: int
) -> Optional[tuple[int, tuple]]:
    """Find a pivotal voter for a Boolean function.
    
    Returns (d, v) where flipping coordinate d in v changes f's output,
    or None if no pivotal voter exists (impossible for unanimity-preserving f).
    """
    for bits in range(2 ** k):
        v = list((bits >> i) & 1 for i in range(k))
        fv = f(tuple(v))
        for d in range(k):
            w = v.copy()
            w[d] = 1 - w[d]
            if f(tuple(w)) != fv:
                return (d, tuple(v))
    return None


# ============================================================================
# Condorcet Domain Detection
# ============================================================================

def is_condorcet_domain(orderings: list[list[int]], n_alts: int) -> bool:
    """Check if a set of linear orderings forms a Condorcet domain.
    
    A Condorcet domain is a set of orderings such that majority rule over
    any odd number of voters with preferences in this set always produces
    a transitive majority relation.
    """
    from itertools import combinations_with_replacement
    
    # Test with all possible odd-sized profiles from the domain
    # (sufficient to test size 3 by a theorem of Fishburn)
    for combo in combinations_with_replacement(range(len(orderings)), 3):
        profiles = [orderings[i] for i in combo]
        T = TournamentSign.from_preferences(profiles, n_alts)
        if not T.is_transitive():
            return False
    return True


def max_condorcet_domain_size(n_alts: int) -> int:
    """Compute the maximum Condorcet domain size for n alternatives.
    
    For n ≤ 4, this is computed exactly. Conjecture: 2^{n-1} for all n.
    """
    from itertools import permutations
    
    all_orderings = [list(p) for p in permutations(range(n_alts))]
    
    # Greedy search for large Condorcet domains
    best_size = 0
    
    # Try starting from each ordering
    for start in range(len(all_orderings)):
        domain = [all_orderings[start]]
        for i in range(len(all_orderings)):
            if i == start:
                continue
            candidate = domain + [all_orderings[i]]
            if is_condorcet_domain(candidate, n_alts):
                domain = candidate
        best_size = max(best_size, len(domain))
    
    return best_size


if __name__ == "__main__":
    # Quick test
    print("Testing HolonomyDefectAlgebra...")
    
    # Condorcet cycle
    sign = np.array([[0, 1, -1], [-1, 0, 1], [1, -1, 0]])
    H = HolonomyDefectAlgebra(sign)
    print(f"Condorcet cycle: curvature={H.condorcet_curvature()}, "
          f"holonomy={H.total_holonomy()}, transitive={H.is_transitive()}")
    print(f"Gauss-Bonnet verified: {H.verify_gauss_bonnet()}")
    
    # Transitive tournament
    sign_t = np.array([[0, 1, 1], [-1, 0, 1], [-1, -1, 0]])
    H_t = HolonomyDefectAlgebra(sign_t)
    print(f"Transitive: curvature={H_t.condorcet_curvature()}, "
          f"holonomy={H_t.total_holonomy()}, transitive={H_t.is_transitive()}")
    
    # Fisher geometry
    p = np.array([0.5, 0.3, 0.2])
    q = np.array([0.2, 0.5, 0.3])
    print(f"\nFisher-Rao distance: {fisher_rao_distance(p, q):.4f}")
    print(f"Hellinger² = {hellinger_distance_sq(p, q):.4f}")
    print(f"2(1-BC) = {2*(1 - bhattacharyya_coefficient(p, q)):.4f}")
    
    # Pivotal voter
    majority = lambda v: int(sum(v) > len(v) / 2)
    result = find_pivotal_voter(majority, 3)
    print(f"\nMajority rule pivotal: voter {result[0]} at profile {result[1]}")
    
    # Condorcet domain
    print(f"\nMax Condorcet domain size for 3 alternatives: {max_condorcet_domain_size(3)}")
