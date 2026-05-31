"""
Algorithms for computing Condorcet curvature and related measures.

This module implements the key algorithms from the Arrow-Curvature theory:
- Majority tournament construction
- Condorcet curvature computation
- Kendall distance
- Polarization index
- Single-peaked detection
"""

from typing import List, Tuple, Optional
from itertools import permutations
import random


def majority_margin(profile: List[List[int]], a: int, b: int) -> int:
    """Compute the majority margin of alternative a over b.
    
    Args:
        profile: List of rankings (each ranking is a permutation of alternatives).
                 Lower position = more preferred.
        a: First alternative index
        b: Second alternative index
        
    Returns:
        Number of voters preferring a to b minus those preferring b to a.
    """
    count_ab = sum(1 for ranking in profile if ranking.index(a) < ranking.index(b))
    count_ba = sum(1 for ranking in profile if ranking.index(b) < ranking.index(a))
    return count_ab - count_ba


def majority_tournament(profile: List[List[int]], n_alternatives: int) -> List[Tuple[int, int]]:
    """Construct the majority tournament from a preference profile.
    
    Args:
        profile: List of rankings (permutations of range(n_alternatives))
        n_alternatives: Number of alternatives
        
    Returns:
        List of edges (a, b) where a beats b by majority.
    """
    edges = []
    for a in range(n_alternatives):
        for b in range(a + 1, n_alternatives):
            margin = majority_margin(profile, a, b)
            if margin > 0:
                edges.append((a, b))
            elif margin < 0:
                edges.append((b, a))
    return edges


def condorcet_curvature(profile: List[List[int]], n_alternatives: int) -> int:
    """Compute the Condorcet curvature of a preference profile.
    
    The curvature counts directed 3-cycles in the majority tournament.
    Zero curvature means majority rule is transitive (flat space).
    Positive curvature indicates Condorcet cycles (curved space).
    
    Args:
        profile: List of rankings
        n_alternatives: Number of alternatives
        
    Returns:
        Number of directed 3-cycles in the majority tournament.
    """
    count = 0
    for a in range(n_alternatives):
        for b in range(n_alternatives):
            if b == a:
                continue
            for c in range(n_alternatives):
                if c == a or c == b:
                    continue
                m_ab = majority_margin(profile, a, b)
                m_bc = majority_margin(profile, b, c)
                m_ca = majority_margin(profile, c, a)
                if m_ab > 0 and m_bc > 0 and m_ca > 0:
                    count += 1
    return count


def kendall_distance(ranking1: List[int], ranking2: List[int]) -> int:
    """Compute the Kendall tau distance between two rankings.
    
    Counts the number of pairwise disagreements between the rankings.
    This is the discrete geodesic distance on the preference manifold.
    
    Args:
        ranking1: First ranking (permutation)
        ranking2: Second ranking (permutation)
        
    Returns:
        Number of pairwise inversions between the rankings.
    """
    n = len(ranking1)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            a, b = ranking1[i], ranking1[j]
            # In ranking1, a is preferred to b (appears earlier)
            # Check if ranking2 disagrees
            if ranking2.index(a) > ranking2.index(b):
                count += 1
    return count


def polarization_index(profile: List[List[int]]) -> int:
    """Compute the polarization index of a profile.
    
    Maximum Kendall distance between any two voters.
    High polarization = far apart in preference space = positive curvature.
    
    Args:
        profile: List of rankings
        
    Returns:
        Maximum pairwise Kendall distance.
    """
    max_dist = 0
    for i in range(len(profile)):
        for j in range(i + 1, len(profile)):
            d = kendall_distance(profile[i], profile[j])
            max_dist = max(max_dist, d)
    return max_dist


def is_single_peaked(ranking: List[int], axis: Optional[List[int]] = None) -> bool:
    """Check if a ranking is single-peaked on the given axis.
    
    Single-peaked means there's a unique peak, and utility decreases
    monotonically on both sides of the peak along the axis.
    
    Args:
        ranking: A ranking (preference order, most preferred first)
        axis: The underlying linear order of alternatives (default: natural order)
        
    Returns:
        True if the ranking is single-peaked on the axis.
    """
    n = len(ranking)
    if axis is None:
        axis = list(range(n))
    
    # Find the peak (most preferred alternative)
    peak = ranking[0]
    peak_pos = axis.index(peak)
    
    # Check: moving left from peak, preferences decrease
    for i in range(peak_pos):
        for j in range(i + 1, peak_pos + 1):
            a_pos = axis[i]
            b_pos = axis[j]
            # b is closer to peak, so should be preferred to a
            if ranking.index(a_pos) < ranking.index(b_pos):
                return False
    
    # Check: moving right from peak, preferences decrease
    for i in range(peak_pos, n):
        for j in range(i + 1, n):
            a_pos = axis[i]
            b_pos = axis[j]
            # a is closer to peak, so should be preferred to b
            if ranking.index(a_pos) > ranking.index(b_pos):
                return False
    
    return True


def profile_is_single_peaked(profile: List[List[int]],
                              axis: Optional[List[int]] = None) -> bool:
    """Check if all rankings in a profile are single-peaked."""
    return all(is_single_peaked(r, axis) for r in profile)


def generate_random_profile(n_alternatives: int, n_voters: int) -> List[List[int]]:
    """Generate a random preference profile.
    
    Args:
        n_alternatives: Number of alternatives
        n_voters: Number of voters
        
    Returns:
        List of random rankings (permutations).
    """
    alts = list(range(n_alternatives))
    return [random.sample(alts, n_alternatives) for _ in range(n_voters)]


def curvature_spectrum(n_alternatives: int, n_voters: int,
                        n_samples: int = 1000) -> dict:
    """Sample the distribution of Condorcet curvature.
    
    Args:
        n_alternatives: Number of alternatives
        n_voters: Number of voters
        n_samples: Number of random profiles to sample
        
    Returns:
        Dictionary with curvature statistics.
    """
    curvatures = []
    single_peaked_count = 0
    
    for _ in range(n_samples):
        profile = generate_random_profile(n_alternatives, n_voters)
        curv = condorcet_curvature(profile, n_alternatives)
        curvatures.append(curv)
        if profile_is_single_peaked(profile):
            single_peaked_count += 1
    
    return {
        'mean_curvature': sum(curvatures) / len(curvatures),
        'max_curvature': max(curvatures),
        'zero_curvature_fraction': curvatures.count(0) / len(curvatures),
        'single_peaked_fraction': single_peaked_count / n_samples,
        'curvature_distribution': curvatures
    }


if __name__ == '__main__':
    # Demonstrate key algorithms
    print("=" * 60)
    print("CONDORCET CURVATURE ALGORITHMS")
    print("=" * 60)
    
    # Classic Condorcet cycle
    condorcet = [[0, 1, 2], [1, 2, 0], [2, 0, 1]]
    print("\nClassic Condorcet profile:")
    for i, r in enumerate(condorcet):
        print(f"  Voter {i}: {' > '.join(str(x) for x in r)}")
    
    curv = condorcet_curvature(condorcet, 3)
    print(f"  Curvature: {curv}")
    print(f"  Polarization: {polarization_index(condorcet)}")
    
    # Single-peaked profile (no cycle)
    peaked = [[0, 1, 2], [1, 0, 2], [2, 1, 0]]
    print("\nSingle-peaked profile:")
    for i, r in enumerate(peaked):
        print(f"  Voter {i}: {' > '.join(str(x) for x in r)}")
    
    curv = condorcet_curvature(peaked, 3)
    print(f"  Curvature: {curv}")
    print(f"  Single-peaked: {profile_is_single_peaked(peaked)}")
    print(f"  Polarization: {polarization_index(peaked)}")
