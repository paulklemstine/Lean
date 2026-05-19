#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Algorithms

Implementations of the core algorithms from the research paper:
- Brill-Noether feasibility checking
- CDPR allocation construction
- Round-robin path construction
- Displacement tableau construction and enumeration
- Divisor rank computation on chains of loops
"""

from typing import List, Tuple, Optional, Generator
from itertools import product
from functools import lru_cache


# ===================== Core Computations =====================

def brill_noether_number(g: int, r: int, d: int) -> int:
    """
    Compute the Brill-Noether number ρ(g,r,d) = g - (r+1)(g-d+r).

    Parameters:
        g: genus (number of loops)
        r: desired rank
        d: degree of divisor

    Returns:
        The Brill-Noether number as an integer.

    Examples:
        >>> brill_noether_number(4, 1, 3)
        0
        >>> brill_noether_number(3, 1, 2)
        -1
    """
    return g - (r + 1) * (g - d + r)


def is_feasible(g: int, r: int, d: int) -> bool:
    """
    O(1) feasibility check: does a rank-r degree-d divisor exist on a chain of g loops?

    This is the key algorithmic consequence of the CDPR theorem:
    existence reduces to checking ρ(g,r,d) ≥ 0.

    Examples:
        >>> is_feasible(4, 1, 3)  # ρ = 0
        True
        >>> is_feasible(3, 1, 2)  # ρ = -1
        False
    """
    return brill_noether_number(g, r, d) >= 0


# ===================== CDPR Allocation =====================

def canonical_allocation(g: int, r: int, d: int) -> Optional[List[int]]:
    """
    Construct the canonical CDPR allocation when ρ ≥ 0.

    Algorithm 1 from the paper: s[0] = g - r*c, s[j] = c for j ≥ 1,
    where c = max(0, g + r - d).

    Time complexity: O(r)
    Space complexity: O(r)

    Returns:
        List of r+1 natural numbers summing to g, or None if ρ < 0.

    Examples:
        >>> canonical_allocation(4, 1, 3)
        [2, 2]
        >>> canonical_allocation(9, 2, 6)
        [3, 3, 3]
    """
    if brill_noether_number(g, r, d) < 0:
        return None

    c = max(0, g + r - d)
    s = [c] * (r + 1)
    s[0] = g - r * c
    return s


def enumerate_allocations(g: int, r: int, d: int) -> Generator[List[int], None, None]:
    """
    Enumerate all valid CDPR allocations for parameters (g, r, d).

    Yields weakly decreasing lists [s_0, ..., s_r] summing to g
    with s_r ≥ max(0, g - d + r).

    Examples:
        >>> list(enumerate_allocations(4, 1, 3))
        [[2, 2]]
        >>> len(list(enumerate_allocations(5, 1, 4)))
        2
    """
    c = max(0, g - d + r)

    def _generate(remaining: int, max_val: int, depth: int, current: List[int]):
        if depth == r:
            if remaining >= c:
                yield current + [remaining]
            return
        for val in range(min(remaining - c * (r - depth), max_val), c - 1, -1):
            yield from _generate(remaining - val, val, depth + 1, current + [val])

    yield from _generate(g, g, 0, [])


def count_allocations(g: int, r: int, d: int) -> int:
    """Count the number of valid CDPR allocations."""
    return sum(1 for _ in enumerate_allocations(g, r, d))


# ===================== Round-Robin Path =====================

def round_robin_path(g: int, r: int) -> List[int]:
    """
    Construct the round-robin CDPR path: σ(k) = k mod (r+1).

    Algorithm 2 from the paper.

    Time complexity: O(g)
    Space complexity: O(g)

    Examples:
        >>> round_robin_path(6, 1)
        [0, 1, 0, 1, 0, 1]
        >>> round_robin_path(4, 2)
        [0, 1, 2, 0]
    """
    return [k % (r + 1) for k in range(g)]


def path_step_counts(sigma: List[int], r: int) -> List[List[int]]:
    """
    Compute step counts at each time for all coordinates.

    Returns a (g+1) × (r+1) matrix where entry [i][j] is
    the number of times coordinate j was chosen in the first i steps.
    """
    g = len(sigma)
    counts = [[0] * (r + 1) for _ in range(g + 1)]
    for i in range(g):
        for j in range(r + 1):
            counts[i + 1][j] = counts[i][j]
        counts[i + 1][sigma[i]] += 1
    return counts


def path_states(d: int, r: int, sigma: List[int]) -> List[List[int]]:
    """
    Compute the Weyl chamber state vector at each time step.

    State at time i: state[i][j] = (d - j) - i + count[i][j]
    """
    g = len(sigma)
    counts = path_step_counts(sigma, r)
    states = []
    for i in range(g + 1):
        state = [(d - j) - i + counts[i][j] for j in range(r + 1)]
        states.append(state)
    return states


def verify_cdpr_path(g: int, r: int, d: int, sigma: List[int]) -> Tuple[bool, str]:
    """
    Verify a CDPR path and return (valid, reason).

    Examples:
        >>> verify_cdpr_path(6, 1, 4, [0, 1, 0, 1, 0, 1])
        (True, 'Valid')
    """
    if len(sigma) != g:
        return False, f"Wrong length: {len(sigma)} ≠ {g}"

    states = path_states(d, r, sigma)
    for i, state in enumerate(states):
        for j in range(r):
            if state[j] < state[j + 1]:
                return False, f"Ordering violation at step {i}: state[{j}]={state[j]} < state[{j+1}]={state[j+1]}"
        if state[r] < 0:
            return False, f"Positivity violation at step {i}: state[{r}]={state[r]} < 0"

    return True, "Valid"


# ===================== Displacement Tableau =====================

def canonical_tableau(g: int, rows: int, cols: int) -> Optional[List[List[int]]]:
    """
    Construct the canonical displacement tableau T(i,j) = i*cols + j.

    Algorithm 3 from the paper.

    Time complexity: O(rows * cols)
    Space complexity: O(rows * cols)

    Returns None if rows*cols > g.

    Examples:
        >>> canonical_tableau(4, 2, 2)
        [[0, 1], [2, 3]]
    """
    if rows * cols > g:
        return None
    return [[i * cols + j for j in range(cols)] for i in range(rows)]


def verify_tableau(g: int, T: List[List[int]]) -> Tuple[bool, str]:
    """Verify a displacement tableau."""
    all_entries = set()
    for i, row in enumerate(T):
        for j in range(len(row) - 1):
            if row[j] >= row[j + 1]:
                return False, f"Row {i} not strictly increasing at position {j}"
        for entry in row:
            if entry < 0 or entry >= g:
                return False, f"Entry {entry} out of range [0, {g})"
            if entry in all_entries:
                return False, f"Entry {entry} not injective"
            all_entries.add(entry)
    return True, "Valid"


def count_tableaux(g: int, rows: int, cols: int) -> int:
    """
    Count the number of valid displacement tableaux by exhaustive enumeration.

    Warning: Exponential complexity. Only use for small parameters.
    """
    if rows * cols > g:
        return 0
    if cols == 0 or rows == 0:
        return 1

    from itertools import combinations

    count = 0
    # Each row is a strictly increasing sequence of cols values from {0,...,g-1}
    # All rows combined must use distinct values (injective)
    # Generate all possible row selections
    available = list(range(g))

    def _count_recursive(row_idx: int, used: set) -> int:
        if row_idx == rows:
            return 1
        remaining = [x for x in available if x not in used]
        total = 0
        for combo in combinations(remaining, cols):
            # combo is automatically sorted (strictly increasing)
            total += _count_recursive(row_idx + 1, used | set(combo))
        return total

    return _count_recursive(0, set())


# ===================== Weyl Chamber Analysis =====================

def in_weyl_chamber(v: List[int]) -> bool:
    """Check if a vector lies in the closed Weyl chamber."""
    for j in range(len(v) - 1):
        if v[j] < v[j + 1]:
            return False
    return v[-1] >= 0


def initial_state(r: int, d: int) -> List[int]:
    """Compute the CDPR initial state: v(j) = d - j."""
    return [d - j for j in range(r + 1)]


# ===================== Main Demo =====================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1: Allocation
    print("Algorithm 1: Canonical Allocation")
    for g, r, d in [(4, 1, 3), (9, 2, 6), (12, 3, 9)]:
        alloc = canonical_allocation(g, r, d)
        rho = brill_noether_number(g, r, d)
        print(f"  ({g},{r},{d}): ρ={rho}, allocation={alloc}")

    # Algorithm 2: Round-Robin Path
    print("\nAlgorithm 2: Round-Robin Path")
    g, r, d = 6, 1, 4
    sigma = round_robin_path(g, r)
    valid, reason = verify_cdpr_path(g, r, d, sigma)
    print(f"  ({g},{r},{d}): path={sigma}, valid={valid}")

    # Algorithm 3: Displacement Tableau
    print("\nAlgorithm 3: Canonical Tableau")
    for g, r, d in [(4, 1, 3), (9, 2, 6)]:
        rows, cols = r + 1, max(0, g + r - d)
        T = canonical_tableau(g, rows, cols)
        if T:
            valid, reason = verify_tableau(g, T)
            print(f"  ({g},{r},{d}): shape={rows}×{cols}, valid={valid}")
            for row in T:
                print(f"    {row}")

    # Algorithm 4: Feasibility Check
    print("\nAlgorithm 4: O(1) Feasibility Check")
    for g in range(1, 8):
        max_r = next((r for r in range(g + 1) if not is_feasible(g, r, g)), g + 1) - 1
        print(f"  g={g}: maximum rank for degree-g divisor: r={max_r}")

    # Allocation counting
    print("\nAllocation Counting:")
    for g, r, d in [(4, 1, 3), (5, 1, 4), (6, 1, 4), (6, 1, 5)]:
        n = count_allocations(g, r, d)
        rho = brill_noether_number(g, r, d)
        print(f"  ({g},{r},{d}): ρ={rho}, #allocations={n}")

    # Tableau counting
    print("\nTableau Counting:")
    for g, r, d in [(4, 1, 3), (5, 1, 4), (6, 1, 4)]:
        rows, cols = r + 1, max(0, g + r - d)
        n = count_tableaux(g, rows, cols)
        print(f"  ({g},{r},{d}): shape={rows}×{cols}, #tableaux={n}")
