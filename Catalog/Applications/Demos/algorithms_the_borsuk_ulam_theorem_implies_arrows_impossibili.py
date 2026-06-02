"""
Algorithms for Social Choice Theory and Preference Topology

Type-hinted implementations of the key algorithms from the
Borsuk-Ulam–Arrow bridge formalization.
"""

from typing import Callable, Optional
from itertools import permutations


# ============================================================
# Core Types
# ============================================================

Ranking = tuple[int, ...]  # A strict linear order (permutation)
Profile = list[Ranking]     # A preference profile (list of rankings)
SWF = Callable[[Profile], Ranking]  # Social welfare function


# ============================================================
# Preference Operations
# ============================================================

def prefers(ranking: Ranking, a: int, b: int) -> bool:
    """Check if ranking prefers a to b (lower index = more preferred)."""
    return ranking.index(a) < ranking.index(b)


def reverse_ranking(ranking: Ranking) -> Ranking:
    """The antipodal ranking: reverse the preference order."""
    return tuple(reversed(ranking))


def reverse_profile(profile: Profile) -> Profile:
    """Reverse all voters' preferences (the antipodal map on L(n)^k)."""
    return [reverse_ranking(r) for r in profile]


# ============================================================
# Kendall Distance
# ============================================================

def kendall_distance(r1: Ranking, r2: Ranking) -> int:
    """
    Kendall tau distance: number of pairwise disagreements.
    
    This is the discrete metric on the preference manifold L(n).
    Properties:
    - kendall_distance(r, r) = 0
    - kendall_distance(r1, r2) = kendall_distance(r2, r1)
    - kendall_distance(r, reverse(r)) = n*(n-1)/2 (maximum)
    - kendall_distance(r1, r2) <= kendall_distance(r1, reverse(r1)) for all r2
    """
    n = len(r1)
    return sum(
        1 for i in range(n) for j in range(i + 1, n)
        if prefers(r1, i, j) != prefers(r2, i, j)
    )


# ============================================================
# Condorcet Curvature
# ============================================================

def support_count(profile: Profile, a: int, b: int) -> int:
    """Count voters preferring a to b."""
    return sum(1 for r in profile if prefers(r, a, b))


def majority_beats(profile: Profile, a: int, b: int) -> bool:
    """Does a majority-beat b?"""
    return support_count(profile, a, b) > support_count(profile, b, a)


def condorcet_curvature(profile: Profile, n: int) -> int:
    """
    Condorcet curvature: number of directed 3-cycles in majority relation.
    
    - Curvature = 0: majority rule is transitive (flat preference space)
    - Curvature > 0: Condorcet paradox exists (curved preference space)
    
    Arrow's theorem is driven by the existence of curvature in general:
    for n >= 3, there always exist profiles with positive curvature.
    """
    count = 0
    for a in range(n):
        for b in range(n):
            if b == a:
                continue
            for c in range(n):
                if c == a or c == b:
                    continue
                if (majority_beats(profile, a, b) and
                    majority_beats(profile, b, c) and
                    majority_beats(profile, c, a)):
                    count += 1
    return count


def condorcet_winner(profile: Profile, n: int) -> Optional[int]:
    """
    Find the Condorcet winner if one exists.
    
    A Condorcet winner majority-beats every other alternative.
    By our theorem condorcet_winner_unique, at most one can exist.
    """
    for w in range(n):
        if all(majority_beats(profile, w, b) for b in range(n) if b != w):
            return w
    return None


# ============================================================
# Arrow's Axiom Checking
# ============================================================

def check_pareto(swf: SWF, n: int, k: int) -> bool:
    """Check if SWF satisfies Pareto efficiency (for small n, k)."""
    orders = list(permutations(range(n)))
    for indices in range(len(orders) ** k):
        profile = []
        idx = indices
        for _ in range(k):
            profile.append(orders[idx % len(orders)])
            idx //= len(orders)

        social = swf(profile)
        for a in range(n):
            for b in range(n):
                if a != b and all(prefers(r, a, b) for r in profile):
                    if not prefers(social, a, b):
                        return False
    return True


def check_iia(swf: SWF, n: int, k: int) -> bool:
    """Check if SWF satisfies Independence of Irrelevant Alternatives."""
    orders = list(permutations(range(n)))
    all_profiles = []
    for indices in range(len(orders) ** k):
        profile = []
        idx = indices
        for _ in range(k):
            profile.append(orders[idx % len(orders)])
            idx //= len(orders)
        all_profiles.append(profile)

    for P in all_profiles:
        for Q in all_profiles:
            social_P = swf(P)
            social_Q = swf(Q)
            for a in range(n):
                for b in range(n):
                    if a == b:
                        continue
                    # Check if all voters agree on a vs b
                    agree = all(
                        prefers(P[i], a, b) == prefers(Q[i], a, b)
                        for i in range(k)
                    )
                    if agree:
                        if prefers(social_P, a, b) != prefers(social_Q, a, b):
                            return False
    return True


def find_dictator(swf: SWF, n: int, k: int) -> Optional[int]:
    """Find a dictator for the SWF, or None if non-dictatorial."""
    orders = list(permutations(range(n)))
    for d in range(k):
        is_dictator = True
        for indices in range(len(orders) ** k):
            profile = []
            idx = indices
            for _ in range(k):
                profile.append(orders[idx % len(orders)])
                idx //= len(orders)
            social = swf(profile)
            for a in range(n):
                for b in range(n):
                    if a != b and prefers(profile[d], a, b):
                        if not prefers(social, a, b):
                            is_dictator = False
                            break
                if not is_dictator:
                    break
            if not is_dictator:
                break
        if is_dictator:
            return d
    return None


# ============================================================
# Dictator SWF
# ============================================================

def make_dictator_swf(d: int) -> SWF:
    """Create a dictator SWF for voter d."""
    return lambda profile: profile[d]


# ============================================================
# Majority Rule SWF (not always well-defined for n >= 3)
# ============================================================

def majority_rule_swf(profile: Profile) -> Ranking:
    """
    Majority rule: rank alternatives by Borda count.
    WARNING: This is NOT majority rule in the strict sense (which may not
    produce a transitive ranking). This is Borda count, which always produces
    a ranking but does NOT satisfy IIA.
    """
    n = len(profile[0])
    scores = [0] * n
    for r in profile:
        for pos, alt in enumerate(r):
            scores[alt] += (n - 1 - pos)
    return tuple(sorted(range(n), key=lambda x: -scores[x]))


if __name__ == "__main__":
    # Quick test
    n, k = 3, 2
    print(f"Testing dictator SWF (n={n}, k={k}):")
    swf = make_dictator_swf(0)
    print(f"  Pareto: {check_pareto(swf, n, k)}")
    print(f"  IIA: {check_iia(swf, n, k)}")
    print(f"  Dictator: voter {find_dictator(swf, n, k)}")

    print(f"\nTesting Borda count (n={n}, k={k}):")
    print(f"  Pareto: {check_pareto(majority_rule_swf, n, k)}")
    print(f"  IIA: {check_iia(majority_rule_swf, n, k)}")
    print(f"  Dictator: {find_dictator(majority_rule_swf, n, k)}")
    print("  (Borda violates IIA — confirming Arrow's theorem!)")
