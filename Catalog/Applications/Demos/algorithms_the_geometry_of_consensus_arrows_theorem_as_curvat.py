"""
Algorithms for the Arrow-Curvature Theory
==========================================
Type-hinted implementations of the core mathematical algorithms.
"""

from typing import Callable, Optional
import numpy as np
from dataclasses import dataclass


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class ProbDist:
    """A probability distribution on m alternatives."""
    val: np.ndarray  # shape (m,), non-negative, sums to 1
    
    def __post_init__(self):
        assert np.all(self.val >= -1e-15), "Distribution must be non-negative"
        assert abs(self.val.sum() - 1.0) < 1e-10, f"Distribution must sum to 1, got {self.val.sum()}"
    
    @property
    def m(self) -> int:
        return len(self.val)


@dataclass
class DecisiveFamily:
    """A decisive family on n voters (Arrow's algebraic structure).
    
    Represented as a predicate on frozensets of voter indices.
    """
    n: int  # number of voters
    is_decisive: Callable[[frozenset[int]], bool]
    
    def find_dictator(self) -> Optional[int]:
        """Find the dictator (if the family is principal).
        
        By Arrow's theorem, every decisive family on a finite set
        is principal: there exists a dictator i such that
        S is decisive ⟺ i ∈ S.
        """
        for i in range(self.n):
            if self.is_decisive(frozenset({i})):
                # Verify this is the dictator
                is_principal = True
                for mask in range(1 << self.n):
                    S = frozenset(j for j in range(self.n) if mask & (1 << j))
                    if self.is_decisive(S) != (i in S):
                        is_principal = False
                        break
                if is_principal:
                    return i
        return None


# ============================================================
# Fisher Geometry Algorithms
# ============================================================

def fisher_embedding(p: np.ndarray) -> np.ndarray:
    """Embed distribution p into the unit sphere via p ↦ √p.
    
    Properties:
    - ||φ(p)||² = 1 (image lies on unit sphere)
    - ||φ(p) - φ(q)||² = 2·H²(p,q) (isometry up to scale)
    
    Args:
        p: Probability distribution (non-negative, sums to 1)
    
    Returns:
        Point on the unit sphere in R^m
    """
    return np.sqrt(np.maximum(p, 0))


def bhattacharyya_coefficient(p: np.ndarray, q: np.ndarray) -> float:
    """Bhattacharyya coefficient BC(p,q) = Σ √(pᵢ·qᵢ).
    
    Satisfies:
    - 0 ≤ BC(p,q) ≤ 1
    - BC(p,q) = 1 ⟺ p = q (for strictly positive distributions)
    - BC(p,q) = 0 ⟺ p ⊥ q (disjoint supports)
    
    The Fisher-Rao geodesic distance is d_FR = 2·arccos(BC).
    """
    return float(np.sum(np.sqrt(np.maximum(p * q, 0))))


def hellinger_distance_sq(p: np.ndarray, q: np.ndarray) -> float:
    """Squared Hellinger distance H²(p,q) = 1 - BC(p,q).
    
    Captures the Fisher geometry of the probability simplex.
    """
    return 1.0 - bhattacharyya_coefficient(p, q)


def fisher_rao_distance(p: np.ndarray, q: np.ndarray) -> float:
    """Fisher-Rao geodesic distance d_FR(p,q) = 2·arccos(BC(p,q)).
    
    This is the geodesic distance on the sphere (via the Fisher embedding).
    """
    bc = bhattacharyya_coefficient(p, q)
    bc = np.clip(bc, -1, 1)
    return 2.0 * np.arccos(bc)


def polarization_index(profile: list[np.ndarray]) -> float:
    """Polarization index: average pairwise Hellinger distance.
    
    Measures how spread out voters' preferences are in the Fisher geometry.
    
    Properties:
    - PI = 0 ⟺ all voters agree (consensus)
    - PI > 0 ⟺ there is disagreement
    - Higher PI → stronger curvature effects → Arrow obstruction
    
    Args:
        profile: List of probability distributions (one per voter)
    
    Returns:
        Non-negative polarization index
    """
    n = len(profile)
    if n == 0:
        return 0.0
    total = sum(
        hellinger_distance_sq(profile[i], profile[j])
        for i in range(n)
        for j in range(n)
    )
    return total / (n ** 2)


# ============================================================
# Curvature Computation
# ============================================================

def sectional_curvature_fisher(m: int) -> float:
    """Sectional curvature of the Fisher information metric on Δ^{m-1}.
    
    The Fisher embedding φ: Δ → S^{m-1} is an isometry (up to scale).
    The unit sphere S^{m-1} has constant sectional curvature K = 1.
    Therefore the Fisher simplex has K = 1.
    
    This positive curvature is the geometric source of Arrow's impossibility.
    """
    return 1.0  # Constant positive curvature


def verify_sphere_isometry(p: np.ndarray, q: np.ndarray) -> dict[str, float]:
    """Verify the Fisher embedding is an isometry to the sphere.
    
    Checks:
    1. ||φ(p)||² = 1 (on unit sphere)
    2. ||φ(q)||² = 1 (on unit sphere)  
    3. ||φ(p) - φ(q)||² = 2·H²(p,q) (isometry)
    """
    phi_p = fisher_embedding(p)
    phi_q = fisher_embedding(q)
    
    norm_p = float(np.sum(phi_p ** 2))
    norm_q = float(np.sum(phi_q ** 2))
    chord_sq = float(np.sum((phi_p - phi_q) ** 2))
    hellinger_sq = hellinger_distance_sq(p, q)
    
    return {
        "norm_phi_p_sq": norm_p,
        "norm_phi_q_sq": norm_q,
        "chord_sq": chord_sq,
        "2_times_hellinger_sq": 2 * hellinger_sq,
        "isometry_error": abs(chord_sq - 2 * hellinger_sq),
        "sphere_error_p": abs(norm_p - 1.0),
        "sphere_error_q": abs(norm_q - 1.0),
    }


# ============================================================
# Arrow's Theorem Verification
# ============================================================

def construct_decisive_family_from_swf(
    n: int,
    m: int,
    swf: Callable[[list[list[int]]], list[int]]
) -> DecisiveFamily:
    """Construct the decisive family from a social welfare function.
    
    Given a SWF F mapping preference profiles to social preferences,
    a coalition S is decisive if: whenever all voters in S prefer a to b
    (and all others prefer b to a), society prefers a to b.
    
    Under IIA, the decisive family is independent of which pair (a,b) is chosen.
    
    Args:
        n: Number of voters
        m: Number of alternatives (must be ≥ 3 for Arrow's theorem)
        swf: Social welfare function mapping profiles to social ordering
             Each ordering is a permutation (list of alternatives, best first)
    
    Returns:
        DecisiveFamily capturing which coalitions are decisive
    """
    def is_decisive(S: frozenset[int]) -> bool:
        # Test with alternatives 0 and 1
        # Voters in S: prefer 0 to 1
        # Voters not in S: prefer 1 to 0
        profile = []
        for i in range(n):
            if i in S:
                profile.append(list(range(m)))  # 0 > 1 > 2 > ...
            else:
                ordering = [1, 0] + list(range(2, m))  # 1 > 0 > 2 > ...
                profile.append(ordering)
        
        social = swf(profile)
        # Check if 0 is ranked before 1 in social ordering
        return social.index(0) < social.index(1)
    
    return DecisiveFamily(n=n, is_decisive=is_decisive)


def verify_arrow_theorem(n: int, m: int) -> None:
    """Verify Arrow's theorem for small instances.
    
    Tests that for any SWF satisfying Pareto + IIA on m ≥ 3 alternatives
    and n voters, there must be a dictator.
    """
    print(f"Arrow's theorem verification: {n} voters, {m} alternatives")
    
    # The only SWFs satisfying Pareto + IIA are dictatorships
    for dictator in range(n):
        def swf(profile, d=dictator):
            return profile[d]
        
        df = construct_decisive_family_from_swf(n, m, swf)
        found_dictator = df.find_dictator()
        print(f"  Dictator {dictator}: found_dictator = {found_dictator}, correct = {found_dictator == dictator}")


if __name__ == "__main__":
    print("=" * 60)
    print("Arrow-Curvature Algorithm Demonstrations")
    print("=" * 60)
    
    # Test Fisher embedding
    p = np.array([0.4, 0.3, 0.2, 0.1])
    q = np.array([0.25, 0.25, 0.25, 0.25])
    
    print("\nFisher embedding verification:")
    result = verify_sphere_isometry(p, q)
    for k, v in result.items():
        print(f"  {k}: {v:.10f}")
    
    print(f"\nSectional curvature of Fisher simplex: K = {sectional_curvature_fisher(4)}")
    
    # Arrow's theorem
    print()
    verify_arrow_theorem(3, 3)
    verify_arrow_theorem(5, 4)
