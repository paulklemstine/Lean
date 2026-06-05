"""
Algorithms for Social Choice and Arrow's Impossibility

Type-hinted implementations of key algorithms from the formalization.
"""

from typing import List, Set, Tuple, Optional, Callable
from itertools import permutations, combinations


# Type aliases
Ranking = List[int]  # ranking[i] = position of alternative i (lower = more preferred)
Profile = List[Ranking]  # one ranking per voter
SWF = Callable[[Profile], Ranking]  # social welfare function


def is_pareto(f: SWF, n_voters: int, n_alts: int) -> bool:
    """Check if a SWF satisfies the Pareto condition by sampling profiles."""
    for a in range(n_alts):
        for b in range(n_alts):
            if a == b:
                continue
            # Test: all voters prefer a to b
            profile: Profile = []
            # Build a ranking where a is in position 0, b in position 1
            for _ in range(n_voters):
                ranking = list(range(n_alts))
                ranking.remove(a)
                ranking.remove(b)
                ranking = [a, b] + ranking
                profile.append(ranking)
            result = f(profile)
            if result.index(a) > result.index(b):
                return False
    return True


def find_dictator(f: SWF, n_voters: int, n_alts: int) -> Optional[int]:
    """Find a dictator for a SWF, if one exists.

    Algorithm: For each voter d, check if d is a dictator by testing
    profiles where d's preference differs from all others.
    """
    if n_alts < 2:
        return None

    for d in range(n_voters):
        is_dict = True
        # Test all pairs (a, b) with d preferring a>b and others preferring b>a
        for a in range(n_alts):
            for b in range(n_alts):
                if a == b:
                    continue
                profile: Profile = []
                for v in range(n_voters):
                    if v == d:
                        ranking = list(range(n_alts))
                        ranking.remove(a)
                        ranking.remove(b)
                        ranking = [a, b] + ranking
                    else:
                        ranking = list(range(n_alts))
                        ranking.remove(a)
                        ranking.remove(b)
                        ranking = [b, a] + ranking
                    profile.append(ranking)
                result = f(profile)
                if result.index(a) > result.index(b):
                    is_dict = False
                    break
            if not is_dict:
                break
        if is_dict:
            return d
    return None


def decisive_coalitions(
    f: SWF, n_voters: int, n_alts: int
) -> List[Set[int]]:
    """Find all decisive coalitions for a SWF.

    A coalition S is decisive if: whenever S all prefer a>b
    and all others prefer b>a, society prefers a>b.
    Tests with a fixed pair (0, 1).
    """
    if n_alts < 2:
        return []

    result: List[Set[int]] = []
    a, b = 0, 1

    for size in range(n_voters + 1):
        for coalition in combinations(range(n_voters), size):
            coalition_set = set(coalition)
            is_dec = True

            # Build test profile
            profile: Profile = []
            for v in range(n_voters):
                if v in coalition_set:
                    ranking = list(range(n_alts))
                    ranking.remove(a)
                    ranking.remove(b)
                    ranking = [a, b] + ranking
                else:
                    ranking = list(range(n_alts))
                    ranking.remove(a)
                    ranking.remove(b)
                    ranking = [b, a] + ranking
                profile.append(ranking)

            social = f(profile)
            if social.index(a) > social.index(b):
                is_dec = False

            if is_dec:
                result.append(coalition_set)

    return result


def verify_ultrafilter_property(
    coalitions: List[Set[int]], n_voters: int
) -> bool:
    """Verify that a collection of coalitions satisfies the ultrafilter property:
    for every subset S, either S or its complement is in the collection."""
    all_voters = set(range(n_voters))
    for size in range(n_voters + 1):
        for S in combinations(range(n_voters), size):
            S_set = set(S)
            complement = all_voters - S_set
            if S_set not in coalitions and complement not in coalitions:
                return False
    return True


def social_sign(f: SWF, profile: Profile, a: int, b: int) -> int:
    """Compute the social sign for pair (a, b) at a profile."""
    result = f(profile)
    if result.index(a) < result.index(b):
        return 1
    elif result.index(a) > result.index(b):
        return -1
    return 0


def antipodal_profile(profile: Profile) -> Profile:
    """Compute the antipodal (reversed) profile."""
    return [list(reversed(p)) for p in profile]


def verify_sign_change(
    f: SWF, n_voters: int, n_alts: int
) -> bool:
    """Verify the sign change theorem: for any unanimous profile,
    the social sign must flip between the profile and its antipodal."""
    if n_alts < 2:
        return True

    for perm in permutations(range(n_alts)):
        ranking = list(perm)
        profile = [ranking] * n_voters
        anti = antipodal_profile(profile)

        for a in range(n_alts):
            for b in range(a + 1, n_alts):
                s1 = social_sign(f, profile, a, b)
                s2 = social_sign(f, anti, a, b)
                if s1 == s2 and s1 != 0:
                    return False
    return True


# Example SWFs
def dictator_swf(d: int) -> SWF:
    """Create a dictator SWF where voter d determines the outcome."""
    def f(profile: Profile) -> Ranking:
        return profile[d]
    return f


def majority_rule_2(profile: Profile) -> Ranking:
    """Majority rule for 2 alternatives."""
    n = len(profile)
    count_01 = sum(1 for p in profile if p.index(0) < p.index(1))
    if count_01 > n / 2:
        return [0, 1]
    return [1, 0]


if __name__ == "__main__":
    # Test dictator SWF
    f = dictator_swf(0)
    print(f"Dictator (voter 0): dictator found = {find_dictator(f, 3, 3)}")
    print(f"Pareto: {is_pareto(f, 3, 3)}")

    coalitions = decisive_coalitions(f, 3, 3)
    print(f"Decisive coalitions: {coalitions}")
    print(f"Ultrafilter property: {verify_ultrafilter_property(coalitions, 3)}")
    print(f"Sign change verified: {verify_sign_change(f, 3, 3)}")
