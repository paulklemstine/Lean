"""
Algorithms for Proof Complexity: Resolution, Cutting Planes, and PHP

Implements:
1. PHP CNF generation
2. Bounded-width resolution search
3. Cutting planes certificate construction
4. Width-entropy profile computation
5. Proof information estimation

All algorithms correspond to formally verified Lean definitions.
"""

from typing import Optional
from itertools import combinations
from collections import defaultdict


# =============================================================================
# Core Data Structures
# =============================================================================

class Literal:
    """A propositional literal: a variable with a sign."""

    def __init__(self, var: tuple, positive: bool = True):
        self.var = var
        self.positive = positive

    def __neg__(self):
        return Literal(self.var, not self.positive)

    def __eq__(self, other):
        return isinstance(other, Literal) and self.var == other.var and self.positive == other.positive

    def __hash__(self):
        return hash((self.var, self.positive))

    def __repr__(self):
        sign = "" if self.positive else "¬"
        return f"{sign}x{self.var}"

    def eval(self, assignment: dict) -> bool:
        """Evaluate literal under assignment."""
        val = assignment.get(self.var, False)
        return val if self.positive else not val

    def complement(self):
        """Return the complement literal."""
        return -self


Clause = frozenset  # A clause is a frozenset of Literals
CNF = frozenset     # A CNF is a frozenset of Clauses


def clause_width(clause: Clause) -> int:
    """Width of a clause = number of literals."""
    return len(clause)


def clause_satisfied(clause: Clause, assignment: dict) -> bool:
    """Check if a clause is satisfied by an assignment."""
    return any(lit.eval(assignment) for lit in clause)


def cnf_satisfied(cnf, assignment: dict) -> bool:
    """Check if a CNF is satisfied by an assignment."""
    return all(clause_satisfied(c, assignment) for c in cnf)


# =============================================================================
# PHP CNF Generation
# =============================================================================

def generate_php(m: int, n: int) -> tuple:
    """
    Generate the Pigeonhole Principle CNF: PHP(m, n).

    Variables: x_{i,j} means "pigeon i goes to hole j"
    Clauses:
      - At-least-one: for each pigeon i, at least one hole
      - At-most-one: for each hole j, at most one pigeon

    Args:
        m: number of pigeons
        n: number of holes

    Returns:
        Tuple of (all_clauses, at_least_one_clauses, at_most_one_clauses)

    Complexity: O(m*n) at-least-one literals, O(m²*n) at-most-one clauses

    Example:
        >>> clauses, al, amo = generate_php(3, 2)
        >>> len(al)  # 3 pigeon clauses
        3
        >>> len(amo)  # 2 holes * C(3,2) pairs = 6 collision clauses
        6
    """
    at_least_one = []
    for i in range(m):
        clause = frozenset(Literal((i, j), positive=True) for j in range(n))
        at_least_one.append(clause)

    at_most_one = []
    for j in range(n):
        for i1, i2 in combinations(range(m), 2):
            clause = frozenset([
                Literal((i1, j), positive=False),
                Literal((i2, j), positive=False)
            ])
            at_most_one.append(clause)

    all_clauses = at_least_one + at_most_one
    return all_clauses, at_least_one, at_most_one


def php_statistics(n: int) -> dict:
    """
    Compute statistics for PHP(n+1, n).

    Returns dict with:
        - pigeons, holes, variables
        - at_least_one_count, at_most_one_count, total_clauses
        - max_initial_width, min_initial_width
        - width_lower_bound (proven: n)

    Example:
        >>> stats = php_statistics(3)
        >>> stats['pigeons'], stats['holes']
        (4, 3)
        >>> stats['width_lower_bound']
        3
    """
    m, nn = n + 1, n
    clauses, al, amo = generate_php(m, nn)

    widths = [clause_width(c) for c in clauses]

    return {
        'pigeons': m,
        'holes': nn,
        'variables': m * nn,
        'at_least_one_count': len(al),
        'at_most_one_count': len(amo),
        'total_clauses': len(clauses),
        'max_initial_width': max(widths) if widths else 0,
        'min_initial_width': min(widths) if widths else 0,
        'al_width': nn,
        'amo_width': 2,
        'width_lower_bound': nn,  # Proven: any refutation needs width >= n
    }


# =============================================================================
# Resolution Engine
# =============================================================================

def resolve(c1: Clause, c2: Clause, var) -> Optional[Clause]:
    """
    Attempt to resolve two clauses on a variable.

    Returns the resolvent if the resolution is valid, None otherwise.

    Example:
        >>> l = Literal(('x',), True)
        >>> c1 = frozenset([l, Literal(('y',), True)])
        >>> c2 = frozenset([-l, Literal(('z',), True)])
        >>> r = resolve(c1, c2, ('x',))
        >>> len(r)
        2
    """
    pos_lit = Literal(var, True)
    neg_lit = Literal(var, False)

    if pos_lit in c1 and neg_lit in c2:
        resolvent = (c1 - {pos_lit}) | (c2 - {neg_lit})
        return resolvent
    elif neg_lit in c1 and pos_lit in c2:
        resolvent = (c1 - {neg_lit}) | (c2 - {pos_lit})
        return resolvent
    return None


def get_variables(clauses) -> set:
    """Extract all variables from a list of clauses."""
    variables = set()
    for clause in clauses:
        for lit in clause:
            variables.add(lit.var)
    return variables


def bounded_width_resolution(clauses: list, max_width: int,
                              max_steps: int = 10000) -> dict:
    """
    Attempt to find a resolution refutation using only clauses of width ≤ max_width.

    This implements a saturation-based resolution search that only keeps
    clauses within the width bound.

    Args:
        clauses: initial CNF clauses
        max_width: maximum allowed clause width
        max_steps: maximum number of resolution steps

    Returns:
        dict with:
            - found: whether empty clause was derived
            - steps: number of resolution steps performed
            - derived_count: number of derived clauses
            - max_derived_width: maximum width of derived clauses

    Example:
        >>> clauses, _, _ = generate_php(3, 2)
        >>> result = bounded_width_resolution(clauses, max_width=1, max_steps=100)
        >>> result['found']  # Width 1 is too narrow for PHP(3,2)
        False
    """
    derived = set()
    for c in clauses:
        if clause_width(c) <= max_width:
            derived.add(c)

    variables = get_variables(clauses)
    steps = 0
    found = False
    max_derived_width = max((clause_width(c) for c in derived), default=0)

    derived_list = list(derived)

    while steps < max_steps and not found:
        new_clauses = set()
        for i, c1 in enumerate(derived_list):
            for j, c2 in enumerate(derived_list):
                if i >= j:
                    continue
                for var in variables:
                    resolvent = resolve(c1, c2, var)
                    if resolvent is not None and clause_width(resolvent) <= max_width:
                        if resolvent not in derived:
                            new_clauses.add(resolvent)
                            if clause_width(resolvent) > max_derived_width:
                                max_derived_width = clause_width(resolvent)
                            if len(resolvent) == 0:
                                found = True
                                break
                    steps += 1
                    if steps >= max_steps or found:
                        break
                if found or steps >= max_steps:
                    break
            if found or steps >= max_steps:
                break

        if not new_clauses:
            break

        derived.update(new_clauses)
        derived_list = list(derived)

    return {
        'found': found,
        'steps': steps,
        'derived_count': len(derived),
        'max_derived_width': max_derived_width,
    }


# =============================================================================
# Cutting Planes
# =============================================================================

class LinearInequality:
    """
    A linear inequality: Σ coeffs[v] * v ≥ rhs
    over 0/1 variables.
    """

    def __init__(self, coeffs: dict, rhs: int):
        self.coeffs = defaultdict(int, coeffs)
        self.rhs = rhs

    def is_valid(self, assignment: dict) -> bool:
        """Check if the inequality is valid under a 0/1 assignment."""
        total = sum(c * (1 if assignment.get(v, False) else 0)
                    for v, c in self.coeffs.items())
        return self.rhs <= total

    def __add__(self, other):
        """Add two inequalities."""
        new_coeffs = defaultdict(int)
        for v, c in self.coeffs.items():
            new_coeffs[v] += c
        for v, c in other.coeffs.items():
            new_coeffs[v] += c
        return LinearInequality(dict(new_coeffs), self.rhs + other.rhs)

    def __repr__(self):
        terms = []
        for v, c in sorted(self.coeffs.items(), key=str):
            if c != 0:
                terms.append(f"{c}·x{v}")
        lhs = " + ".join(terms) if terms else "0"
        return f"{lhs} ≥ {self.rhs}"


def php_pigeon_inequality(m: int, n: int, i: int) -> LinearInequality:
    """
    Pigeon constraint: pigeon i goes to at least one hole.
    x_{i,0} + x_{i,1} + ... + x_{i,n-1} ≥ 1

    Example:
        >>> ineq = php_pigeon_inequality(3, 2, 0)
        >>> ineq.rhs
        1
    """
    coeffs = {(i, j): 1 for j in range(n)}
    return LinearInequality(coeffs, 1)


def php_hole_inequality(m: int, n: int, j: int) -> LinearInequality:
    """
    Hole constraint: hole j receives at most one pigeon.
    -x_{0,j} - x_{1,j} - ... - x_{m-1,j} ≥ -(1)

    Example:
        >>> ineq = php_hole_inequality(3, 2, 0)
        >>> ineq.rhs
        -1
    """
    coeffs = {(i, j): -1 for i in range(m)}
    return LinearInequality(coeffs, -1)


def construct_cp_refutation(n: int) -> list:
    """
    Construct an explicit cutting-planes refutation of PHP(n+1, n).

    The refutation works by:
    1. Summing all pigeon constraints: total ≥ n+1
    2. Summing all hole constraints: -total ≥ -n
    3. Adding: 0 ≥ 1 (contradiction)

    Returns list of (step_description, inequality) pairs.

    Complexity: O(n) constraints, O(1) derivation steps.

    Example:
        >>> steps = construct_cp_refutation(2)
        >>> steps[-1][0]
        'CONTRADICTION: 0 ≥ 1'
    """
    m = n + 1
    steps = []

    # Step 1: List pigeon constraints
    pigeon_ineqs = []
    for i in range(m):
        ineq = php_pigeon_inequality(m, n, i)
        pigeon_ineqs.append(ineq)
        steps.append((f"Pigeon {i} constraint", ineq))

    # Step 2: Sum pigeon constraints
    pigeon_sum = pigeon_ineqs[0]
    for ineq in pigeon_ineqs[1:]:
        pigeon_sum = pigeon_sum + ineq
    steps.append(("Sum of pigeon constraints", pigeon_sum))

    # Step 3: List hole constraints
    hole_ineqs = []
    for j in range(n):
        ineq = php_hole_inequality(m, n, j)
        hole_ineqs.append(ineq)
        steps.append((f"Hole {j} constraint", ineq))

    # Step 4: Sum hole constraints
    hole_sum = hole_ineqs[0]
    for ineq in hole_ineqs[1:]:
        hole_sum = hole_sum + ineq
    steps.append(("Sum of hole constraints", hole_sum))

    # Step 5: Add pigeon and hole sums
    contradiction = pigeon_sum + hole_sum
    steps.append(("CONTRADICTION: 0 ≥ 1", contradiction))

    return steps


# =============================================================================
# Width-Entropy Profile
# =============================================================================

def compute_width_entropy_profile(clauses: list, max_width: int,
                                   max_steps: int = 5000) -> dict:
    """
    Compute the width-entropy profile: for each width w, count
    the number of distinct clauses of width ≤ w derivable by resolution.

    This is a computational approximation of the formal WidthEntropyProfile.

    Args:
        clauses: initial CNF clauses
        max_width: maximum width to compute profile for
        max_steps: maximum resolution steps per width level

    Returns:
        dict mapping width → count of derivable clauses at that width

    Example:
        >>> clauses, _, _ = generate_php(3, 2)
        >>> profile = compute_width_entropy_profile(clauses, 3, 500)
        >>> profile[0] <= profile[1] <= profile[2]  # Monotone
        True
    """
    variables = get_variables(clauses)
    profile = {}

    for w in range(max_width + 1):
        derived = set()
        for c in clauses:
            if clause_width(c) <= w:
                derived.add(c)

        # Saturate at this width
        changed = True
        steps = 0
        derived_list = list(derived)
        while changed and steps < max_steps:
            changed = False
            new_clauses = set()
            for i, c1 in enumerate(derived_list):
                for j, c2 in enumerate(derived_list):
                    if i >= j:
                        continue
                    for var in variables:
                        resolvent = resolve(c1, c2, var)
                        if resolvent is not None and clause_width(resolvent) <= w:
                            if resolvent not in derived:
                                new_clauses.add(resolvent)
                                changed = True
                        steps += 1
                        if steps >= max_steps:
                            break
                    if steps >= max_steps:
                        break
                if steps >= max_steps:
                    break
            derived.update(new_clauses)
            derived_list = list(derived)

        profile[w] = len(derived)

    return profile


# =============================================================================
# Proof Information Estimation
# =============================================================================

def estimate_proof_information(clauses: list, max_steps: int = 10000) -> dict:
    """
    Estimate the proof information content by tracking resolution steps.

    Returns statistics about the resolution proof search.

    Example:
        >>> clauses, _, _ = generate_php(3, 2)
        >>> info = estimate_proof_information(clauses, 1000)
        >>> info['total_resolutions'] > 0
        True
    """
    derived = set(clauses)
    variables = get_variables(clauses)
    steps = 0
    resolutions = 0
    width_histogram = defaultdict(int)

    for c in clauses:
        width_histogram[clause_width(c)] += 1

    derived_list = list(derived)
    found = False

    while steps < max_steps and not found:
        new_clauses = set()
        for i, c1 in enumerate(derived_list):
            for j, c2 in enumerate(derived_list):
                if i >= j:
                    continue
                for var in variables:
                    resolvent = resolve(c1, c2, var)
                    if resolvent is not None and resolvent not in derived:
                        new_clauses.add(resolvent)
                        resolutions += 1
                        width_histogram[clause_width(resolvent)] += 1
                        if len(resolvent) == 0:
                            found = True
                            break
                    steps += 1
                    if steps >= max_steps or found:
                        break
                if found or steps >= max_steps:
                    break
            if found or steps >= max_steps:
                break

        if not new_clauses:
            break
        derived.update(new_clauses)
        derived_list = list(derived)

    return {
        'found_refutation': found,
        'total_resolutions': resolutions,
        'total_derived': len(derived),
        'steps': steps,
        'width_histogram': dict(width_histogram),
    }


if __name__ == "__main__":
    # Quick demonstration
    print("=== PHP(3,2) Statistics ===")
    stats = php_statistics(2)
    for k, v in stats.items():
        print(f"  {k}: {v}")

    print("\n=== Bounded Width Resolution on PHP(3,2) ===")
    clauses, _, _ = generate_php(3, 2)
    for w in range(1, 4):
        result = bounded_width_resolution(clauses, max_width=w, max_steps=5000)
        status = "FOUND" if result['found'] else "NOT FOUND"
        print(f"  Width ≤ {w}: {status} (derived {result['derived_count']} clauses)")

    print("\n=== CP Refutation of PHP(3,2) ===")
    steps = construct_cp_refutation(2)
    for desc, ineq in steps:
        print(f"  {desc}: {ineq}")
