#!/usr/bin/env python3
"""
Algorithms for Social Choice Topology

Type-hinted implementations of the key algorithms used in the
PreferenceSphere framework.
"""

from itertools import permutations
from typing import Callable


# Type aliases
Ranking = tuple[int, ...]  # ranking[i] = rank of alternative i
Profile = tuple[Ranking, ...]  # profile[voter] = ranking
SWF = Callable[[Profile], Ranking]


def kendall_tau_distance(sigma: Ranking, tau: Ranking) -> int:
    """Compute the Kendall tau distance between two rankings.
    
    Time complexity: O(n²) where n = number of alternatives.
    Can be improved to O(n log n) using merge sort.
    
    Args:
        sigma: First ranking (sigma[i] = rank of alternative i)
        tau: Second ranking
    
    Returns:
        Number of pairs (i,j) with i<j where sigma and tau disagree on ordering.
    """
    n = len(sigma)
    assert len(tau) == n
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            # Disagree if one ranks i before j and the other ranks j before i
            if (sigma[i] - sigma[j]) * (tau[i] - tau[j]) < 0:
                count += 1
    return count


def kendall_tau_fast(sigma: Ranking, tau: Ranking) -> int:
    """Compute Kendall tau distance in O(n log n) using merge sort.
    
    Args:
        sigma: First ranking
        tau: Second ranking
    
    Returns:
        Kendall tau distance
    """
    n = len(sigma)
    # Compute the composition tau ∘ sigma^{-1}
    sigma_inv = [0] * n
    for i in range(n):
        sigma_inv[sigma[i]] = i
    
    # Count inversions of tau[sigma_inv[·]]
    composed = [tau[sigma_inv[i]] for i in range(n)]
    
    def merge_count(arr: list[int]) -> tuple[list[int], int]:
        if len(arr) <= 1:
            return arr, 0
        mid = len(arr) // 2
        left, l_inv = merge_count(arr[:mid])
        right, r_inv = merge_count(arr[mid:])
        merged = []
        inversions = l_inv + r_inv
        i = j = 0
        while i < len(left) and j < len(right):
            if left[i] <= right[j]:
                merged.append(left[i])
                i += 1
            else:
                merged.append(right[j])
                inversions += len(left) - i
                j += 1
        merged.extend(left[i:])
        merged.extend(right[j:])
        return merged, inversions
    
    _, inversions = merge_count(composed)
    return inversions


def antipodal_ranking(sigma: Ranking) -> Ranking:
    """Compute the antipodal (reversed) ranking.
    
    The antipodal reverses the preference order:
    if sigma ranks alternative i at position p,
    antipodal ranks it at position (n-1-p).
    
    Args:
        sigma: A ranking
    
    Returns:
        The antipodal ranking
    """
    n = len(sigma)
    return tuple(n - 1 - s for s in sigma)


def is_pareto_efficient(swf: SWF, n_voters: int, n_alts: int) -> bool:
    """Check if a SWF satisfies Pareto efficiency.
    
    A SWF is Pareto efficient if: whenever all voters prefer alternative
    i to alternative j, the social ranking also prefers i to j.
    
    Args:
        swf: Social welfare function
        n_voters: Number of voters
        n_alts: Number of alternatives
    
    Returns:
        True if Pareto efficient
    """
    all_rankings = list(permutations(range(n_alts)))
    
    for ranking in all_rankings:
        # Unanimous profile
        profile = tuple(ranking for _ in range(n_voters))
        result = swf(profile)
        # Check all pairwise comparisons
        for i in range(n_alts):
            for j in range(n_alts):
                if ranking[i] < ranking[j]:  # voters prefer i to j
                    if result[i] >= result[j]:  # but society doesn't
                        return False
    return True


def is_iia(swf: SWF, n_voters: int, n_alts: int,
           n_samples: int = 500) -> bool:
    """Check if a SWF satisfies Independence of Irrelevant Alternatives.
    
    A SWF satisfies IIA if: the social ranking of i vs j depends only
    on individual rankings of i vs j.
    
    Args:
        swf: Social welfare function
        n_voters: Number of voters
        n_alts: Number of alternatives
        n_samples: Number of random profile pairs to test
    
    Returns:
        True if IIA is satisfied (probabilistic check)
    """
    import random
    all_rankings = list(permutations(range(n_alts)))
    
    for _ in range(n_samples):
        # Generate two random profiles
        P = tuple(random.choice(all_rankings) for _ in range(n_voters))
        Q = tuple(random.choice(all_rankings) for _ in range(n_voters))
        
        # Check each pair of alternatives
        for a in range(n_alts):
            for b in range(a + 1, n_alts):
                # Check if P and Q agree on a vs b for all voters
                agree = all(
                    (P[v][a] < P[v][b]) == (Q[v][a] < Q[v][b])
                    for v in range(n_voters)
                )
                if agree:
                    # Then social rankings of a vs b must also agree
                    fp = swf(P)
                    fq = swf(Q)
                    if (fp[a] < fp[b]) != (fq[a] < fq[b]):
                        return False
    return True


def find_dictator(swf: SWF, n_voters: int, n_alts: int,
                  n_samples: int = 300) -> int | None:
    """Find the dictator of a SWF, if it exists.
    
    Args:
        swf: Social welfare function
        n_voters: Number of voters
        n_alts: Number of alternatives
        n_samples: Number of random profiles to test
    
    Returns:
        Index of the dictator, or None if not dictatorial
    """
    import random
    all_rankings = list(permutations(range(n_alts)))
    candidates = set(range(n_voters))
    
    for _ in range(n_samples):
        if not candidates:
            return None
        
        profile = tuple(random.choice(all_rankings) for _ in range(n_voters))
        result = swf(profile)
        
        # Eliminate non-dictators
        to_remove = set()
        for d in candidates:
            for a in range(n_alts):
                for b in range(n_alts):
                    if profile[d][a] < profile[d][b] and result[a] >= result[b]:
                        to_remove.add(d)
                        break
                if d in to_remove:
                    break
        candidates -= to_remove
    
    if len(candidates) == 1:
        return candidates.pop()
    return None


def compute_decisive_coalitions(swf: SWF, n_voters: int, n_alts: int) -> list[frozenset[int]]:
    """Find all decisive coalitions for a SWF.
    
    A coalition S is decisive if: for every pair (a,b) of alternatives,
    when all voters in S prefer a to b and all others prefer b to a,
    society prefers a to b.
    
    Args:
        swf: Social welfare function
        n_voters: Number of voters  
        n_alts: Number of alternatives
    
    Returns:
        List of decisive coalitions
    """
    all_rankings = list(permutations(range(n_alts)))
    decisive = []
    
    for S_mask in range(2**n_voters):
        S = frozenset(i for i in range(n_voters) if S_mask & (1 << i))
        is_decisive = True
        
        for a in range(n_alts):
            for b in range(n_alts):
                if a == b:
                    continue
                # Find ranking where a > b
                ranking_ab = None
                ranking_ba = None
                for r in all_rankings:
                    if r[a] < r[b]:
                        ranking_ab = r
                    if r[b] < r[a]:
                        ranking_ba = r
                    if ranking_ab and ranking_ba:
                        break
                
                # Profile: voters in S have ranking_ab, others have ranking_ba
                profile = tuple(
                    ranking_ab if i in S else ranking_ba
                    for i in range(n_voters)
                )
                result = swf(profile)
                if result[a] >= result[b]:
                    is_decisive = False
                    break
            if not is_decisive:
                break
        
        if is_decisive:
            decisive.append(S)
    
    return decisive


def preference_sphere_graph(n: int) -> dict[Ranking, list[Ranking]]:
    """Construct the PreferenceSphere graph (permutohedron).
    
    Vertices are rankings, edges connect rankings that differ by
    a single adjacent transposition.
    
    Args:
        n: Number of alternatives
    
    Returns:
        Adjacency list representation
    """
    all_rankings = list(permutations(range(n)))
    graph: dict[Ranking, list[Ranking]] = {r: [] for r in all_rankings}
    
    for ranking in all_rankings:
        for k in range(n - 1):
            # Swap positions k and k+1
            adj = list(ranking)
            adj[k], adj[k + 1] = adj[k + 1], adj[k]
            adj_tuple = tuple(adj)
            graph[ranking].append(adj_tuple)
    
    return graph


if __name__ == "__main__":
    # Quick validation
    n = 4
    sigma = tuple(range(n))
    tau = antipodal_ranking(sigma)
    
    d1 = kendall_tau_distance(sigma, tau)
    d2 = kendall_tau_fast(sigma, tau)
    expected = n * (n - 1) // 2
    
    print(f"Kendall distance (naive):  d({sigma}, {tau}) = {d1}")
    print(f"Kendall distance (fast):   d({sigma}, {tau}) = {d2}")
    print(f"Expected (n*(n-1)/2):      {expected}")
    assert d1 == d2 == expected, "Mismatch!"
    print("✓ All checks passed")
    
    # Test dictator detection
    for d in range(3):
        swf = lambda profile, d=d: profile[d]
        found = find_dictator(swf, 3, 3)
        print(f"Dictator SWF (voter {d}): detected dictator = {found}")
        assert found == d
    
    # Test decisive coalitions
    swf0 = lambda profile: profile[0]
    coalitions = compute_decisive_coalitions(swf0, 3, 3)
    print(f"\nDecisive coalitions for dictator-0 SWF with 3 voters:")
    for c in sorted(coalitions, key=len):
        print(f"  {set(c)}")
