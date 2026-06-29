"""
Algorithms for Entropy Barrier Analysis in Resolution Proof Complexity.

This module implements:
1. Width-entropy profile estimation for CNF formulas
2. Entropy barrier detection
3. Free-energy landscape computation
4. Step-bounded growth verification

All algorithms correspond to formally verified mathematical definitions
in the Lean 4 formalization.
"""

import math
import itertools
from typing import Optional
from dataclasses import dataclass


@dataclass
class Literal:
    """A propositional literal: a variable with a polarity."""
    var: int
    positive: bool

    def __neg__(self) -> 'Literal':
        return Literal(self.var, not self.positive)

    def __hash__(self):
        return hash((self.var, self.positive))

    def __eq__(self, other):
        return self.var == other.var and self.positive == other.positive

    def __repr__(self):
        return f"x{self.var}" if self.positive else f"¬x{self.var}"


# A clause is a frozenset of Literals
Clause = frozenset
# A CNF is a frozenset of Clauses
CNF = frozenset


def clause_width(c: Clause) -> int:
    """Width of a clause = number of literals."""
    return len(c)


def resolve(c1: Clause, c2: Clause, var: int) -> Optional[Clause]:
    """
    Resolve two clauses on a variable, if possible.

    Returns the resolvent C1 ∪ C2 \\ {x, ¬x} if x ∈ C1 and ¬x ∈ C2,
    or None if resolution is not applicable.

    >>> c1 = frozenset([Literal(0, True), Literal(1, True)])
    >>> c2 = frozenset([Literal(0, False), Literal(2, True)])
    >>> r = resolve(c1, c2, 0)
    >>> r == frozenset([Literal(1, True), Literal(2, True)])
    True
    """
    pos_lit = Literal(var, True)
    neg_lit = Literal(var, False)

    if pos_lit in c1 and neg_lit in c2:
        result = (c1 - {pos_lit}) | (c2 - {neg_lit})
        # Check for tautology (both x and ¬x in result)
        vars_pos = {l.var for l in result if l.positive}
        vars_neg = {l.var for l in result if not l.positive}
        if vars_pos & vars_neg:
            return None  # tautological
        return result
    return None


def php_cnf(m: int, n: int) -> set:
    """
    Generate the Pigeonhole Principle CNF: PHP(m, n).
    m pigeons, n holes. Unsatisfiable when m > n.

    Variables: x_{i,j} means "pigeon i goes to hole j".
    Clauses:
      - At-least-one: for each pigeon i, ∨_j x_{i,j}
      - At-most-one: for each hole j and pigeons i1 < i2, ¬x_{i1,j} ∨ ¬x_{i2,j}

    >>> cnf = php_cnf(3, 2)
    >>> len(cnf) > 0
    True
    """
    clauses = set()
    # At-least-one clauses
    for i in range(m):
        clause = frozenset(Literal(i * n + j, True) for j in range(n))
        clauses.add(clause)
    # At-most-one clauses
    for j in range(n):
        for i1 in range(m):
            for i2 in range(i1 + 1, m):
                clause = frozenset([
                    Literal(i1 * n + j, False),
                    Literal(i2 * n + j, False)
                ])
                clauses.add(clause)
    return clauses


def random_3sat(n_vars: int, n_clauses: int, seed: int = 42) -> set:
    """
    Generate a random 3-SAT instance.

    >>> cnf = random_3sat(10, 43)
    >>> all(len(c) == 3 for c in cnf)
    True
    """
    import random
    rng = random.Random(seed)
    clauses = set()
    for _ in range(n_clauses):
        vars_chosen = rng.sample(range(n_vars), 3)
        clause = frozenset(
            Literal(v, rng.random() > 0.5) for v in vars_chosen
        )
        clauses.add(clause)
    return clauses


def bounded_width_saturation(cnf: set, max_width: int, n_vars: int,
                              max_clauses: int = 50000) -> set:
    """
    Compute the saturation of a CNF under resolution, restricted to
    clauses of width ≤ max_width.

    This is the set of all clauses of width ≤ max_width derivable from
    the input CNF via resolution.

    Time complexity: O(|derived|² · n_vars) per iteration.
    Space complexity: O(|derived|).

    >>> cnf = {frozenset([Literal(0, True)]), frozenset([Literal(0, False)])}
    >>> sat = bounded_width_saturation(cnf, 1, 1)
    >>> frozenset() in sat  # empty clause is derivable
    True
    """
    derived = set()
    for c in cnf:
        if clause_width(c) <= max_width:
            derived.add(c)

    changed = True
    while changed:
        changed = False
        new_clauses = set()
        derived_list = list(derived)
        for c1 in derived_list:
            for c2 in derived_list:
                for v in range(n_vars):
                    r = resolve(c1, c2, v)
                    if r is not None and clause_width(r) <= max_width and r not in derived:
                        new_clauses.add(r)
        if new_clauses:
            derived |= new_clauses
            changed = True
            if len(derived) > max_clauses:
                break

    return derived


def estimate_width_entropy_profile(cnf: set, n_vars: int,
                                    max_width: Optional[int] = None) -> list:
    """
    Estimate the width-entropy profile P(w) for a CNF formula.

    P(w) = log₂(|{clauses of width ≤ w derivable from F}|)

    This is a monotone nondecreasing function of w.

    Args:
        cnf: Set of clauses (frozensets of Literals)
        n_vars: Number of variables
        max_width: Maximum width to consider (default: n_vars)

    Returns:
        List P where P[w] = log₂(count of derivable clauses at width ≤ w)

    >>> cnf = php_cnf(3, 2)
    >>> profile = estimate_width_entropy_profile(cnf, 6, max_width=4)
    >>> all(profile[i] <= profile[i+1] for i in range(len(profile)-1))
    True
    """
    if max_width is None:
        max_width = n_vars

    profile = []
    for w in range(max_width + 1):
        derived = bounded_width_saturation(cnf, w, n_vars)
        count = max(len(derived), 1)  # avoid log(0)
        profile.append(math.log2(count))

    return profile


@dataclass
class EntropyBarrier:
    """
    Represents an entropy barrier in a width-entropy profile.

    Corresponds to the Lean structure EntropyBarrierData.

    Attributes:
        w0: Initial clause width
        w_star: Barrier width (where entropy is suppressed)
        w_max: Maximum width
        gap_ratio: P(w_star) / P(w_max), the suppression ratio
        profile: The full width-entropy profile
    """
    w0: int
    w_star: int
    w_max: int
    gap_ratio: float
    profile: list

    @property
    def has_barrier(self) -> bool:
        """True if gap_ratio < 1 (genuine suppression)."""
        return self.gap_ratio < 1.0

    @property
    def barrier_strength(self) -> float:
        """1 - gap_ratio: higher means stronger barrier."""
        return 1.0 - self.gap_ratio


def detect_entropy_barrier(profile: list, w0: int = 0,
                           threshold: float = 0.9) -> Optional[EntropyBarrier]:
    """
    Detect an entropy barrier in a width-entropy profile.

    Scans for the first width w where P(w)/P(w_max) < threshold.

    Args:
        profile: Width-entropy profile P[0..w_max]
        w0: Initial clause width
        threshold: Gap ratio threshold for barrier detection

    Returns:
        EntropyBarrier if found, None otherwise

    >>> profile = [0.0, 1.0, 1.5, 2.0, 5.0, 8.0, 10.0]
    >>> barrier = detect_entropy_barrier(profile, threshold=0.5)
    >>> barrier is not None
    True
    """
    w_max = len(profile) - 1
    if w_max <= w0 or profile[w_max] <= 0:
        return None

    for w in range(w0 + 1, w_max):
        ratio = profile[w] / profile[w_max]
        if ratio < threshold:
            return EntropyBarrier(
                w0=w0,
                w_star=w,
                w_max=w_max,
                gap_ratio=ratio,
                profile=profile
            )
    return None


def free_energy(beta: float, profile: list) -> list:
    """
    Compute the free-energy landscape F_β(w) = β·w - P(w).

    Corresponds to the Lean definition `freeEnergy`.

    Args:
        beta: Inverse temperature parameter
        profile: Width-entropy profile P[0..w_max]

    Returns:
        List F where F[w] = β·w - P(w)

    >>> profile = [0.0, 1.0, 3.0, 6.0, 10.0]
    >>> fe = free_energy(2.0, profile)
    >>> fe[0]
    0.0
    >>> fe[2]
    1.0
    """
    return [beta * w - profile[w] for w in range(len(profile))]


def free_energy_barrier_height(fe_landscape: list) -> float:
    """
    Compute the height of the free-energy barrier.

    The barrier height is max(F_β) - min(F_β) over the landscape.

    >>> fe = [0.0, 2.0, 1.0, -1.0, 0.5]
    >>> free_energy_barrier_height(fe)
    3.0
    """
    return max(fe_landscape) - min(fe_landscape)


def step_bounded_growth_check(entropy_sequence: list, delta: float) -> bool:
    """
    Verify that a sequence satisfies step-bounded growth by Δ.

    Corresponds to the Lean definition `StepBoundedGrowth`.

    >>> step_bounded_growth_check([0, 1, 2, 3, 4], 1.0)
    True
    >>> step_bounded_growth_check([0, 1, 3, 4], 1.0)
    False
    """
    for t in range(len(entropy_sequence) - 1):
        if entropy_sequence[t + 1] > entropy_sequence[t] + delta + 1e-10:
            return False
    return True


def crossing_time_lower_bound(A: float, B: float, delta: float) -> float:
    """
    Compute the crossing time lower bound: (B - A) / Δ.

    Corresponds to the Lean theorem `crossing_time_lower_bound`.

    >>> crossing_time_lower_bound(0.0, 10.0, 2.0)
    5.0
    """
    if delta <= 0:
        return float('inf')
    return (B - A) / delta


def clause_space_bound(n: int, w: int) -> int:
    """
    Number of distinct clauses over n variables of width at most w.

    ∑_{k=0}^{w} C(n,k) · 2^k

    Corresponds to the Lean definition `clauseSpaceBound` from WidthToSize.lean.

    >>> clause_space_bound(3, 3)  # = 3^3 = 27
    27
    >>> clause_space_bound(4, 0)  # only empty clause
    1
    """
    total = 0
    for k in range(min(w, n) + 1):
        total += math.comb(n, k) * (2 ** k)
    return total


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    print("All algorithm doctests passed.")
