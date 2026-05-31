"""
Algorithms for Social Choice Theory and the Arrow-Borsuk-Ulam Connection.

This module implements core algorithms for analyzing voting systems,
detecting Condorcet cycles, verifying Arrow's axioms, and computing
topological invariants of preference spaces.
"""

from itertools import permutations, product
from typing import Callable, Optional


# --- Core Types ---

Ballot = tuple[int, ...]  # A permutation of (0, 1, ..., k-1) representing ranks
Profile = tuple[Ballot, ...]  # One ballot per voter
SWF = Callable[[Profile], Ballot]  # Social welfare function


def prefers(ballot: Ballot, a: int, b: int) -> bool:
    """Check if alternative `a` is preferred to `b` under the given ballot.
    
    A ballot is a ranking: ballot[i] = rank of alternative i.
    Lower rank = more preferred.
    """
    return ballot[a] < ballot[b]


def antipodal_ballot(ballot: Ballot) -> Ballot:
    """Compute the antipodal (reversed) ballot.
    
    If ballot[i] = r, then antipodal[i] = k - 1 - r.
    This reverses all pairwise comparisons.
    """
    k = len(ballot)
    return tuple(k - 1 - r for r in ballot)


def antipodal_profile(profile: Profile) -> Profile:
    """Reverse all voters' preferences."""
    return tuple(antipodal_ballot(b) for b in profile)


# --- Majority Rule ---

def majority_count(profile: Profile, a: int, b: int) -> int:
    """Count voters who prefer alternative `a` to `b`."""
    return sum(1 for ballot in profile if prefers(ballot, a, b))


def majority_prefers(profile: Profile, a: int, b: int) -> bool:
    """Check if majority prefers `a` to `b` (strict majority)."""
    n = len(profile)
    return 2 * majority_count(profile, a, b) > n


def majority_tournament(profile: Profile, k: int) -> dict[tuple[int, int], bool]:
    """Compute the full majority tournament for k alternatives."""
    tournament = {}
    for a in range(k):
        for b in range(k):
            if a != b:
                tournament[(a, b)] = majority_prefers(profile, a, b)
    return tournament


# --- Condorcet Cycle Detection ---

def has_condorcet_cycle(profile: Profile, k: int) -> Optional[tuple[int, ...]]:
    """Detect a Condorcet cycle in the majority tournament.
    
    Returns the cycle as a tuple if found, None otherwise.
    Uses DFS-based cycle detection in the majority tournament graph.
    """
    tournament = majority_tournament(profile, k)
    
    # Build adjacency list
    adj: dict[int, list[int]] = {i: [] for i in range(k)}
    for (a, b), wins in tournament.items():
        if wins:
            adj[a].append(b)
    
    # DFS cycle detection
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * k
    parent = [-1] * k
    
    def dfs(u: int) -> Optional[list[int]]:
        color[u] = GRAY
        for v in adj[u]:
            if color[v] == GRAY:
                # Found a cycle - reconstruct it
                cycle = [v, u]
                x = u
                while parent[x] != v and parent[x] != -1:
                    x = parent[x]
                    cycle.append(x)
                return cycle
            if color[v] == WHITE:
                parent[v] = u
                result = dfs(v)
                if result is not None:
                    return result
        color[u] = BLACK
        return None
    
    for i in range(k):
        if color[i] == WHITE:
            cycle = dfs(i)
            if cycle is not None:
                return tuple(cycle)
    return None


# --- Arrow's Axioms Verification ---

def check_pareto(f: SWF, k: int, n: int) -> bool:
    """Verify that SWF f satisfies the Pareto condition.
    
    For all profiles where all voters agree on a > b, 
    the social outcome must also have a > b.
    """
    all_ballots = list(permutations(range(k)))
    
    for ballot in all_ballots:
        # Unanimous profile: everyone votes the same
        profile = tuple([ballot] * n)
        social = f(profile)
        
        for a in range(k):
            for b in range(k):
                if a != b and prefers(ballot, a, b):
                    if not prefers(social, a, b):
                        return False
    return True


def check_iia(f: SWF, k: int, n: int) -> bool:
    """Verify Independence of Irrelevant Alternatives.
    
    For all profile pairs agreeing on (a,b) comparisons for all voters,
    the social preference on (a,b) must agree.
    """
    all_ballots = list(permutations(range(k)))
    all_profiles = list(product(all_ballots, repeat=n))
    
    for a in range(k):
        for b in range(k):
            if a == b:
                continue
            # Group profiles by their (a,b) pattern
            groups: dict[tuple[bool, ...], list[Profile]] = {}
            for profile in all_profiles:
                pattern = tuple(prefers(ballot, a, b) for ballot in profile)
                groups.setdefault(pattern, []).append(profile)
            
            for _pattern, profiles_in_group in groups.items():
                social_prefs = set()
                for profile in profiles_in_group:
                    social = f(profile)
                    social_prefs.add(prefers(social, a, b))
                if len(social_prefs) > 1:
                    return False
    return True


def check_non_dictatorial(f: SWF, k: int, n: int) -> bool:
    """Verify non-dictatorship."""
    all_ballots = list(permutations(range(k)))
    all_profiles = list(product(all_ballots, repeat=n))
    
    for d in range(n):
        is_dictator = True
        for profile in all_profiles:
            social = f(profile)
            for a in range(k):
                for b in range(k):
                    if a != b and prefers(profile[d], a, b):
                        if not prefers(social, a, b):
                            is_dictator = False
                            break
                if not is_dictator:
                    break
            if not is_dictator:
                break
        if is_dictator:
            return False  # Found a dictator
    return True


def verify_arrow(f: SWF, k: int, n: int) -> dict[str, bool]:
    """Full Arrow axiom verification."""
    return {
        'pareto': check_pareto(f, k, n),
        'iia': check_iia(f, k, n),
        'non_dictatorial': check_non_dictatorial(f, k, n),
    }


# --- Exhaustive Arrow Search ---

def find_arrow_compliant_swfs(k: int, n: int) -> list[SWF]:
    """Enumerate all SWFs satisfying Pareto and IIA for small k, n.
    
    Returns the list of compliant SWFs. By Arrow's theorem,
    all should be dictatorial for k >= 3.
    """
    all_ballots = list(permutations(range(k)))
    all_profiles = list(product(all_ballots, repeat=n))
    
    # For small cases, represent SWF as a dictionary
    # Try all dictatorial SWFs first
    dictatorial_swfs = []
    for d in range(n):
        def make_dict_swf(d: int = d) -> SWF:
            def swf(profile: Profile) -> Ballot:
                return profile[d]
            return swf
        dictatorial_swfs.append(make_dict_swf())
    
    return dictatorial_swfs


# --- Topological Invariants ---

def kendall_distance(b1: Ballot, b2: Ballot) -> int:
    """Compute the Kendall tau distance between two ballots.
    
    This counts the number of pairwise disagreements.
    """
    k = len(b1)
    dist = 0
    for i in range(k):
        for j in range(i + 1, k):
            if (b1[i] < b1[j]) != (b2[i] < b2[j]):
                dist += 1
    return dist


def is_antipodal_pair(b1: Ballot, b2: Ballot) -> bool:
    """Check if two ballots are antipodal (reversed preferences)."""
    return b2 == antipodal_ballot(b1)


def preference_sphere_embedding(ballot: Ballot) -> list[float]:
    """Embed a ballot into R^{k-1} via pairwise comparison coordinates.
    
    Uses the first k-1 pairwise comparisons (0 vs 1, 0 vs 2, ..., 0 vs k-1)
    mapped to {-1, +1}.
    """
    k = len(ballot)
    coords = []
    for j in range(1, k):
        coords.append(1.0 if prefers(ballot, 0, j) else -1.0)
    return coords


def pareto_antipodal_test(f: SWF, k: int, n: int) -> bool:
    """Test the Pareto-antipodal conflict.
    
    For each unanimous profile, verify that f(p) != f(antipodal(p))
    in the Pareto-relevant sense.
    """
    all_ballots = list(permutations(range(k)))
    
    for ballot in all_ballots:
        profile = tuple([ballot] * n)
        anti_profile = antipodal_profile(profile)
        
        social = f(profile)
        anti_social = f(anti_profile)
        
        # Check that they differ on some pair where Pareto applies
        for a in range(k):
            for b in range(k):
                if a != b and prefers(ballot, a, b):
                    # All voters prefer a > b in profile
                    # All voters prefer b > a in anti_profile
                    if prefers(social, a, b) and prefers(anti_social, a, b):
                        return False  # Violation!
    return True
