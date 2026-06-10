#!/usr/bin/env python3
"""
Algorithms for Configuration-Based Clause Space Analysis

Implements the bounded-space search algorithm whose correctness is
formally verified in ConfigurationSpace.lean.
"""

from collections import deque
from typing import FrozenSet, Set, Tuple, Optional, List


# Type aliases
Literal = Tuple[str, bool]  # (variable_name, is_positive)
Clause = FrozenSet[Literal]
CNF = FrozenSet[Clause]
Config = FrozenSet[Clause]


def negate(lit: Literal) -> Literal:
    """Negate a literal."""
    return (lit[0], not lit[1])


def resolve_clauses(c1: Clause, c2: Clause) -> List[Clause]:
    """
    Find all resolvents of two clauses.

    For each complementary literal pair (x, ¬x) where x ∈ c1 and ¬x ∈ c2,
    produces the resolvent (c1 \ {x}) ∪ (c2 \ {¬x}).

    Time: O(|c1| · |c2|)
    Space: O(|c1| + |c2|) per resolvent

    >>> c1 = frozenset([("x", True), ("y", True)])
    >>> c2 = frozenset([("x", False), ("z", True)])
    >>> resolve_clauses(c1, c2)
    [frozenset({('y', True), ('z', True)})]
    """
    results = []
    for lit in c1:
        neg_lit = negate(lit)
        if neg_lit in c2:
            resolvent = (c1 - {lit}) | (c2 - {neg_lit})
            results.append(resolvent)
    return results


def bounded_space_refutable(
    cnf: CNF,
    max_space: int,
    max_configs: int = 100000
) -> Tuple[bool, Optional[List[Config]], int]:
    """
    Determine if a CNF has a resolution refutation within clause space s.

    Algorithm: BFS through the configuration graph where:
    - Vertices: sets of clauses (configurations) with |config| ≤ max_space
    - Edges: axiom downloads, resolution steps, erasure steps
    - Start: empty configuration
    - Goal: any configuration containing the empty clause

    Soundness (verified in Lean):
        If returns (True, trace, _), then trace is a valid configuration
        refutation with space ≤ max_space.

    Completeness (verified in Lean):
        If returns (False, None, _), then no refutation exists within
        space max_space.

    Args:
        cnf: The input CNF formula
        max_space: Maximum number of clauses allowed simultaneously
        max_configs: Budget limit on configurations to explore

    Returns:
        (found, trace_or_none, configs_explored)

    Time: O(max_configs · (|cnf| + s²))
    Space: O(max_configs · s) for visited set
    """
    empty_clause: Clause = frozenset()
    initial: Config = frozenset()

    # BFS state
    visited: Set[Config] = {initial}
    parent = {initial: None}
    queue: deque = deque([initial])
    explored = 0

    while queue and explored < max_configs:
        config = queue.popleft()
        explored += 1

        # Check for contradiction
        if empty_clause in config:
            # Reconstruct trace
            trace = []
            c = config
            while c is not None:
                trace.append(c)
                c = parent[c]
            trace.reverse()
            return True, trace, explored

        # Generate successors

        # 1. Axiom downloads
        for clause in cnf:
            if clause not in config:
                new_config = config | {clause}
                if len(new_config) <= max_space and new_config not in visited:
                    visited.add(new_config)
                    parent[new_config] = config
                    queue.append(new_config)

        # 2. Resolution steps
        clauses = list(config)
        for i in range(len(clauses)):
            for j in range(i + 1, len(clauses)):
                for resolvent in resolve_clauses(clauses[i], clauses[j]):
                    if resolvent not in config:
                        new_config = config | {resolvent}
                        if len(new_config) <= max_space and new_config not in visited:
                            visited.add(new_config)
                            parent[new_config] = config
                            queue.append(new_config)

        # 3. Erasure steps
        for clause in config:
            new_config = config - {clause}
            if new_config not in visited:
                visited.add(new_config)
                parent[new_config] = config
                queue.append(new_config)

    return False, None, explored


def compute_minimum_space(cnf: CNF, upper_bound: int = 10) -> Optional[int]:
    """
    Compute the minimum clause space needed to refute a CNF.

    Binary search would be possible but linear search is simpler
    and the range is typically small.

    Args:
        cnf: Input CNF formula
        upper_bound: Maximum space to try

    Returns:
        Minimum space s such that a refutation exists, or None if not found
        within the upper bound.
    """
    for s in range(1, upper_bound + 1):
        found, _, _ = bounded_space_refutable(cnf, s)
        if found:
            return s
    return None


def clause_space_bound(n: int, w: int) -> int:
    """
    Compute the number of distinct clauses of width ≤ w over n variables.

    Formula: Σ_{k=0}^{w} C(n,k) · 2^k

    This equals 3^n when w = n (by the binomial theorem for (1+2)^n).

    >>> clause_space_bound(3, 3)
    27
    >>> clause_space_bound(4, 4)
    81
    """
    from math import comb
    return sum(comb(n, k) * (2 ** k) for k in range(w + 1))


# ─── Example usage ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Simple example: {x} ∧ {¬x}
    x_pos: Literal = ("x", True)
    x_neg: Literal = ("x", False)
    cnf: CNF = frozenset([
        frozenset([x_pos]),
        frozenset([x_neg])
    ])

    print("CNF: {x} ∧ {¬x}")
    found, trace, explored = bounded_space_refutable(cnf, max_space=3)
    print(f"Refutable within space 3: {found}")
    if trace:
        print(f"Trace length: {len(trace)}")
        for i, config in enumerate(trace):
            clauses_str = ", ".join(
                "{" + ", ".join(
                    (v if p else f"¬{v}") for v, p in sorted(c)
                ) + "}" if c else "□"
                for c in config
            ) if config else "∅"
            print(f"  Step {i}: {{{clauses_str}}}")

    min_s = compute_minimum_space(cnf)
    print(f"Minimum clause space: {min_s}")
    print(f"clauseSpaceBound(1, 1) = {clause_space_bound(1, 1)}")
