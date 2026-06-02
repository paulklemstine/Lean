#!/usr/bin/env python3
"""
Algorithms for Argumentation Framework Analysis

Type-hinted implementations of the core algorithms for computing
argumentation semantics and the independence complex.
"""

from typing import Set, FrozenSet, List, Tuple, Dict, Optional
from itertools import combinations
from dataclasses import dataclass


@dataclass
class ArgFramework:
    """An abstract argumentation framework (Dung, 1995)."""
    args: Set[int]
    attacks: Set[Tuple[int, int]]

    def attackers(self, a: int) -> Set[int]:
        """Return the set of arguments attacking a."""
        return {b for (b, c) in self.attacks if c == a}

    def attacked_by(self, a: int) -> Set[int]:
        """Return the set of arguments attacked by a."""
        return {c for (b, c) in self.attacks if b == a}


def all_subsets(S: Set[int]) -> List[FrozenSet[int]]:
    """Generate all subsets of S."""
    items = sorted(S)
    result: List[FrozenSet[int]] = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def is_conflict_free(af: ArgFramework, S: FrozenSet[int]) -> bool:
    """Check if S is conflict-free in af.

    A set is conflict-free if no two of its members attack each other.
    Time complexity: O(|S|²) with set lookup.
    """
    for a in S:
        for b in S:
            if (a, b) in af.attacks:
                return False
    return True


def defends(af: ArgFramework, S: FrozenSet[int], a: int) -> bool:
    """Check if S defends argument a.

    S defends a if for every attacker b of a, some c ∈ S attacks b.
    Time complexity: O(|attackers(a)| · |S|).
    """
    for b in af.attackers(a):
        if not any((c, b) in af.attacks for c in S):
            return False
    return True


def is_admissible(af: ArgFramework, S: FrozenSet[int]) -> bool:
    """Check if S is admissible.

    S is admissible if it is conflict-free and defends all its members.
    Time complexity: O(|S|² + |S| · |A| · |S|).
    """
    if not is_conflict_free(af, S):
        return False
    return all(defends(af, S, a) for a in S)


def characteristic_function(af: ArgFramework, S: FrozenSet[int]) -> FrozenSet[int]:
    """Compute F(S) = {a ∈ A | S defends a}.

    The characteristic function maps a set to all arguments it defends.
    """
    return frozenset(a for a in af.args if defends(af, S, a))


def compute_grounded(af: ArgFramework) -> FrozenSet[int]:
    """Compute the grounded extension via least fixed point iteration.

    Algorithm: Start with ∅, repeatedly apply F until convergence.
    Guaranteed to terminate in ≤ |A| steps by monotonicity.
    Time complexity: O(|A|² · |R|).
    """
    S: FrozenSet[int] = frozenset()
    while True:
        new_S = characteristic_function(af, S)
        if new_S == S:
            return S
        S = new_S


def compute_preferred(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all preferred extensions.

    Algorithm: Enumerate all admissible sets, select maximal ones.
    Time complexity: O(2^|A| · |A|² · |R|) — exponential, but exact.

    For large frameworks, use labelling-based algorithms (Caminada, 2006).
    """
    admissible_sets = [S for S in all_subsets(af.args) if is_admissible(af, S)]
    preferred: List[FrozenSet[int]] = []
    for S in admissible_sets:
        if not any(S < T for T in admissible_sets):
            preferred.append(S)
    return preferred


def compute_stable(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all stable extensions.

    A stable extension is conflict-free and attacks every non-member.
    """
    result: List[FrozenSet[int]] = []
    for S in all_subsets(af.args):
        if not is_conflict_free(af, S):
            continue
        attacks_all = all(
            any((b, a) in af.attacks for b in S)
            for a in af.args if a not in S
        )
        if attacks_all:
            result.append(S)
    return result


def compute_complete(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all complete extensions.

    A complete extension is admissible and contains every argument it defends.
    Equivalently, S is a fixed point of F: F(S) = S.
    """
    return [
        S for S in all_subsets(af.args)
        if is_admissible(af, S) and characteristic_function(af, S) == S
    ]


def independence_complex(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute the independence complex (all conflict-free sets).

    Returns the list of all faces of the simplicial complex.
    """
    return [S for S in all_subsets(af.args) if is_conflict_free(af, S)]


def f_vector(af: ArgFramework) -> List[int]:
    """Compute the f-vector of the independence complex.

    f_k = number of faces with exactly k+1 vertices (dimension k).
    """
    cf = independence_complex(af)
    if not cf:
        return []
    max_size = max(len(S) for S in cf)
    return [sum(1 for S in cf if len(S) == k + 1) for k in range(max_size)]


def euler_characteristic(af: ArgFramework) -> int:
    """Compute the Euler characteristic χ = Σ (-1)^k f_k."""
    fv = f_vector(af)
    return sum((-1)**k * fv[k] for k in range(len(fv)))


def dung_fundamental_lemma_check(
    af: ArgFramework,
    S: FrozenSet[int],
    a: int
) -> Dict[str, bool]:
    """Verify Dung's Fundamental Lemma conditions and conclusion.

    Returns a dictionary with:
    - admissible_S: S is admissible
    - defends_a: S defends a
    - cf_insert: insert(a, S) is conflict-free
    - admissible_insert: insert(a, S) is admissible (the conclusion)
    """
    S_ext = S | frozenset({a})
    return {
        "admissible_S": is_admissible(af, S),
        "defends_a": defends(af, S, a),
        "cf_insert": is_conflict_free(af, S_ext),
        "admissible_insert": is_admissible(af, S_ext),
    }


if __name__ == "__main__":
    # Example: Linear chain 0 → 1 → 2 → 3
    af = ArgFramework(
        args={0, 1, 2, 3},
        attacks={(0, 1), (1, 2), (2, 3)}
    )

    print("Framework: 0 → 1 → 2 → 3")
    print(f"Grounded extension: {set(compute_grounded(af))}")
    print(f"Preferred extensions: {[set(S) for S in compute_preferred(af)]}")
    print(f"Stable extensions: {[set(S) for S in compute_stable(af)]}")
    print(f"Complete extensions: {[set(S) for S in compute_complete(af)]}")
    print(f"f-vector: {f_vector(af)}")
    print(f"Euler characteristic: {euler_characteristic(af)}")
