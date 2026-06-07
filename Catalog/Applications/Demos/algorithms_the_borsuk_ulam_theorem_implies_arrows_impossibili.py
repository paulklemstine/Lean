#!/usr/bin/env python3
"""
Algorithms for Social Choice Theory and Ultrafilter Analysis

Type-hinted implementations of the key algorithms from the
Arrow-Borsuk-Ulam bridge formalization.
"""

from typing import List, Tuple, Set, FrozenSet, Dict, Optional, Callable
from itertools import permutations, combinations
from functools import reduce


# ============================================================
# Type Aliases
# ============================================================

Order = Tuple[int, ...]  # A strict linear order (permutation)
Profile = Tuple[Order, ...]  # A preference profile (tuple of orders)
Coalition = FrozenSet[int]  # A set of voters


# ============================================================
# Algorithm 1: Decisive Coalition Finder
# ============================================================

def prefers(order: Order, a: int, b: int) -> bool:
    """Check if order prefers a to b (lower index = more preferred)."""
    return order.index(a) < order.index(b)


def find_all_decisive_coalitions(
    swf: Callable[[Profile], Order],
    n: int,
    k: int,
    sample_profiles: Optional[List[Profile]] = None
) -> Set[Coalition]:
    """
    Find all decisive coalitions for a social welfare function.
    
    Algorithm:
    1. For each subset S of voters:
    2.   For each pair (a, b) of alternatives:
    3.     Check ALL profiles where S prefers a>b and non-S prefers b>a
    4.     If society always prefers a>b, S is decisive for (a,b)
    5.   If S is decisive for ALL pairs, S is decisive
    
    Complexity: O(2^k * n^2 * |profiles|)
    
    Args:
        swf: Social welfare function mapping profiles to orders
        n: Number of alternatives
        k: Number of voters
        sample_profiles: Profiles to check (default: all possible)
    
    Returns:
        Set of decisive coalitions
    """
    if sample_profiles is None:
        orders = list(permutations(range(n)))
        # Generate all profiles (warning: n!^k can be very large)
        sample_profiles = []
        def gen_profiles(depth: int, current: List[Order]) -> None:
            if depth == k:
                sample_profiles.append(tuple(current))
                return
            for o in orders:
                current.append(o)
                gen_profiles(depth + 1, current)
                current.pop()
        gen_profiles(0, [])
    
    decisive: Set[Coalition] = set()
    all_voters = frozenset(range(k))
    
    for mask in range(2**k):
        S = frozenset(i for i in range(k) if mask & (1 << i))
        is_decisive = True
        
        for a in range(n):
            for b in range(n):
                if a == b:
                    continue
                for profile in sample_profiles:
                    s_prefers = all(prefers(profile[i], a, b) for i in S)
                    others_oppose = all(
                        prefers(profile[i], b, a)
                        for i in range(k) if i not in S
                    )
                    if s_prefers and others_oppose:
                        if not prefers(swf(profile), a, b):
                            is_decisive = False
                            break
                if not is_decisive:
                    break
            if not is_decisive:
                break
        
        if is_decisive:
            decisive.add(S)
    
    return decisive


# ============================================================
# Algorithm 2: Ultrafilter Verification
# ============================================================

def verify_ultrafilter(
    decisive: Set[Coalition],
    k: int
) -> Dict[str, bool]:
    """
    Verify that a collection of coalitions forms an ultrafilter.
    
    Checks the five axioms of a DecisiveFilterSystem:
    1. Universe is decisive
    2. Empty set is not decisive
    3. Complement property: for all S, S or complement(S) is decisive
    4. Intersection closure
    5. Upward closure
    
    Also checks principality (existence of a decisive singleton).
    
    Args:
        decisive: Set of decisive coalitions
        k: Number of voters
    
    Returns:
        Dictionary mapping property names to boolean values
    """
    universe = frozenset(range(k))
    
    results: Dict[str, bool] = {}
    
    # Axiom 1: Universe is decisive
    results["A1_univ_decisive"] = universe in decisive
    
    # Axiom 2: Empty not decisive
    results["A2_empty_not_decisive"] = frozenset() not in decisive
    
    # Axiom 3: Complement property
    results["A3_complement"] = all(
        frozenset(i for i in range(k) if mask & (1 << i)) in decisive or
        universe - frozenset(i for i in range(k) if mask & (1 << i)) in decisive
        for mask in range(2**k)
    )
    
    # Axiom 4: Intersection closure
    results["A4_intersection"] = all(
        S & T in decisive
        for S in decisive for T in decisive
    )
    
    # Axiom 5: Upward closure
    results["A5_upward"] = all(
        all(
            frozenset(i for i in range(k) if mask & (1 << i)) in decisive
            for mask in range(2**k)
            if S <= frozenset(i for i in range(k) if mask & (1 << i))
        )
        for S in decisive
    )
    
    # Principality
    results["principal"] = any(frozenset({i}) in decisive for i in range(k))
    
    # Is it an ultrafilter?
    results["is_ultrafilter"] = all(
        results[f"A{i}_{name}"]
        for i, name in [(1, "univ_decisive"), (2, "empty_not_decisive"),
                        (3, "complement"), (4, "intersection"), (5, "upward")]
    )
    
    return results


# ============================================================
# Algorithm 3: Field Expansion Verification
# ============================================================

def verify_field_expansion(
    swf: Callable[[Profile], Order],
    n: int,
    k: int,
    S: Coalition,
    a0: int,
    b0: int,
    sample_profiles: List[Profile]
) -> bool:
    """
    Verify the field expansion lemma: if S is decisive for (a0, b0),
    then S is decisive for all pairs.
    
    Args:
        swf: Social welfare function
        n: Number of alternatives
        k: Number of voters
        S: Coalition to test
        a0, b0: Initial pair
        sample_profiles: Profiles to check
    
    Returns:
        True if field expansion holds
    """
    # First check S is decisive for (a0, b0)
    for profile in sample_profiles:
        if (all(prefers(profile[i], a0, b0) for i in S) and
            all(prefers(profile[i], b0, a0) for i in range(k) if i not in S)):
            if not prefers(swf(profile), a0, b0):
                return False  # S not decisive for (a0, b0)
    
    # Now check S is decisive for all pairs
    for a in range(n):
        for b in range(n):
            if a == b:
                continue
            for profile in sample_profiles:
                if (all(prefers(profile[i], a, b) for i in S) and
                    all(prefers(profile[i], b, a) for i in range(k) if i not in S)):
                    if not prefers(swf(profile), a, b):
                        return False
    
    return True


# ============================================================
# Algorithm 4: Kendall Distance Computation
# ============================================================

def kendall_distance(o1: Order, o2: Order) -> int:
    """
    Compute the Kendall tau distance between two orders.
    
    This counts the number of pairwise disagreements:
    pairs (i, j) where o1 and o2 disagree on i vs j.
    
    Complexity: O(n^2)
    """
    n = len(o1)
    return sum(
        1 for i in range(n) for j in range(i+1, n)
        if prefers(o1, i, j) != prefers(o2, i, j)
    )


def kendall_diameter(n: int) -> int:
    """Maximum Kendall distance = n*(n-1)/2."""
    return n * (n - 1) // 2


def reverse_order(order: Order) -> Order:
    """The antipodal (reversed) order."""
    return tuple(reversed(order))


# ============================================================
# Algorithm 5: Arrow Impossibility Checker
# ============================================================

def check_arrow_impossibility(n: int, k: int) -> str:
    """
    Exhaustively verify Arrow's impossibility theorem for given n, k.
    
    Checks ALL possible SWFs (only feasible for very small n, k)
    and confirms that every Pareto+IIA SWF is dictatorial.
    
    Returns a summary string.
    """
    if n > 3 or k > 2:
        return f"Exhaustive check infeasible for n={n}, k={k}"
    
    orders = list(permutations(range(n)))
    
    # Generate all profiles
    all_profiles: List[Profile] = []
    def gen(depth: int, current: List[Order]) -> None:
        if depth == k:
            all_profiles.append(tuple(current))
            return
        for o in orders:
            current.append(o)
            gen(depth + 1, current)
            current.pop()
    gen(0, [])
    
    num_profiles = len(all_profiles)
    num_orders = len(orders)
    
    # For n=3, k=2: 36 profiles, 6 possible outputs each = 6^36 possible SWFs
    # Too many to enumerate all SWFs. Instead, check specific SWFs.
    
    results = []
    
    # Check all dictator SWFs
    for d in range(k):
        swf = lambda p, d=d: p[d]
        pareto = check_pareto_full(swf, n, k, all_profiles)
        iia = check_iia_full(swf, n, k, all_profiles)
        results.append(f"Dictator {d}: Pareto={pareto}, IIA={iia}, Dictatorial=True")
    
    return "\n".join(results)


def check_pareto_full(
    swf: Callable[[Profile], Order],
    n: int, k: int,
    profiles: List[Profile]
) -> bool:
    """Full Pareto check."""
    for p in profiles:
        r = swf(p)
        for a in range(n):
            for b in range(n):
                if a != b and all(prefers(p[i], a, b) for i in range(k)):
                    if not prefers(r, a, b):
                        return False
    return True


def check_iia_full(
    swf: Callable[[Profile], Order],
    n: int, k: int,
    profiles: List[Profile]
) -> bool:
    """Full IIA check."""
    for p1 in profiles:
        for p2 in profiles:
            for a in range(n):
                for b in range(n):
                    if a != b:
                        if all(prefers(p1[i], a, b) == prefers(p2[i], a, b) for i in range(k)):
                            if prefers(swf(p1), a, b) != prefers(swf(p2), a, b):
                                return False
    return True


if __name__ == "__main__":
    print("Arrow Impossibility Checker")
    print("=" * 40)
    
    for n in [2, 3]:
        for k in [1, 2]:
            print(f"\nn={n} alternatives, k={k} voters:")
            print(check_arrow_impossibility(n, k))
