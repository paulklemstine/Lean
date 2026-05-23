"""
Clause-Space Certificate Search Algorithms

Implements bounded-memory clause-space proof search for CNF formulas,
including certificate generation, validation, and state-space analysis.

All algorithms mirror the formally verified Lean definitions in
Pythagorean/ClauseSpace/Defs.lean.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
from collections import deque
import itertools


@dataclass(frozen=True)
class Clause:
    """A propositional clause: disjunction of positive and negative literals."""
    pos: frozenset[int]
    neg: frozenset[int]

    @staticmethod
    def empty() -> Clause:
        return Clause(frozenset(), frozenset())

    def is_satisfied_by(self, sigma: dict[int, bool]) -> bool:
        """Check if assignment sigma satisfies this clause."""
        return (any(sigma.get(v, False) for v in self.pos) or
                any(not sigma.get(v, True) for v in self.neg))

    def is_disjoint(self) -> bool:
        return self.pos.isdisjoint(self.neg)

    def to_ternary(self, variables: list[int]) -> tuple[int, ...]:
        """Encode as ternary vector: 0=absent, 1=positive, 2=negative."""
        return tuple(
            1 if v in self.pos else (2 if v in self.neg else 0)
            for v in variables
        )

    def __repr__(self) -> str:
        pos_strs = [f"+{v}" for v in sorted(self.pos)]
        neg_strs = [f"-{v}" for v in sorted(self.neg)]
        lits = pos_strs + neg_strs
        return f"({' ∨ '.join(lits)})" if lits else "□"


def resolve(c1: Clause, c2: Clause, v: int) -> Optional[Clause]:
    """
    Resolve c1 and c2 on variable v.
    Returns the resolvent if v appears positively in c1 and negatively in c2,
    with proper polarity constraints.
    """
    if v in c1.pos and v not in c1.neg and v in c2.neg and v not in c2.pos:
        new_pos = (c1.pos | c2.pos) - {v}
        new_neg = (c1.neg | c2.neg) - {v}
        return Clause(new_pos, new_neg)
    return None


@dataclass
class CNF:
    """A CNF formula: conjunction of clauses."""
    clauses: list[Clause]
    variables: set[int] = field(default_factory=set)

    def __post_init__(self):
        if not self.variables:
            for c in self.clauses:
                self.variables |= c.pos | c.neg

    def is_satisfiable(self) -> bool:
        """Brute-force satisfiability check."""
        vars_list = sorted(self.variables)
        for bits in itertools.product([False, True], repeat=len(vars_list)):
            sigma = dict(zip(vars_list, bits))
            if all(c.is_satisfied_by(sigma) for c in self.clauses):
                return True
        return False


@dataclass
class SpaceCertificate:
    """A bounded-space refutation certificate."""
    trace: list[frozenset[Clause]]
    space_bound: int

    @property
    def length(self) -> int:
        return len(self.trace)

    def is_valid(self, cnf: CNF) -> bool:
        """Check certificate validity (mirrors certificateChecks)."""
        if not self.trace:
            return False
        # Starts empty
        if self.trace[0] != frozenset():
            return False
        # Ends with empty clause
        if Clause.empty() not in self.trace[-1]:
            return False
        # All configs bounded
        if any(len(mem) > self.space_bound for mem in self.trace):
            return False
        # Valid steps
        cnf_clauses = frozenset(cnf.clauses)
        for i in range(len(self.trace) - 1):
            if not is_valid_step(cnf, self.trace[i], self.trace[i + 1]):
                return False
        return True


def is_valid_step(cnf: CNF, mem1: frozenset[Clause],
                  mem2: frozenset[Clause]) -> bool:
    """Check if mem2 is reachable from mem1 by a single valid step."""
    # Download
    for c in cnf.clauses:
        if mem2 == mem1 | {c}:
            return True
    # Resolve
    for c1 in mem1:
        for c2 in mem1:
            for v in cnf.variables:
                r = resolve(c1, c2, v)
                if r is not None and mem2 == mem1 | {r}:
                    return True
    # Erase
    for c in mem1:
        if mem2 == mem1 - {c}:
            return True
    return False


def get_successors(cnf: CNF, mem: frozenset[Clause],
                   space_bound: int) -> list[frozenset[Clause]]:
    """Get all valid successor configurations within space bound."""
    successors = []
    # Download
    for c in cnf.clauses:
        new_mem = mem | {c}
        if len(new_mem) <= space_bound:
            successors.append(new_mem)
    # Resolve
    mem_list = list(mem)
    for c1 in mem_list:
        for c2 in mem_list:
            for v in cnf.variables:
                r = resolve(c1, c2, v)
                if r is not None:
                    new_mem = mem | {r}
                    if len(new_mem) <= space_bound:
                        successors.append(new_mem)
    # Erase
    for c in mem_list:
        new_mem = mem - {c}
        successors.append(new_mem)
    return successors


def find_space_certificate(cnf: CNF, space_bound: int,
                           max_steps: int = 100000
                           ) -> Optional[SpaceCertificate]:
    """
    BFS search for a space certificate.

    Searches the finite graph of bounded configurations for a path
    from the empty configuration to one containing the empty clause.

    Returns a SpaceCertificate if found, None otherwise.
    """
    start = frozenset()
    goal_clause = Clause.empty()

    # BFS
    visited: dict[frozenset[Clause], Optional[frozenset[Clause]]] = {start: None}
    queue: deque[frozenset[Clause]] = deque([start])
    steps = 0

    while queue and steps < max_steps:
        current = queue.popleft()
        steps += 1

        # Check if goal
        if goal_clause in current:
            # Reconstruct path
            path = []
            node = current
            while node is not None:
                path.append(node)
                node = visited[node]
            path.reverse()
            return SpaceCertificate(trace=path, space_bound=space_bound)

        # Expand
        for succ in get_successors(cnf, current, space_bound):
            if succ not in visited:
                visited[succ] = current
                queue.append(succ)

    return None


def count_reachable_configs(cnf: CNF, space_bound: int,
                            max_steps: int = 100000) -> dict:
    """
    Count reachable configurations in the bounded space graph.

    Returns statistics about the search space.
    """
    start = frozenset()
    visited: set[frozenset[Clause]] = {start}
    queue: deque[frozenset[Clause]] = deque([start])
    steps = 0
    goal_found = False

    while queue and steps < max_steps:
        current = queue.popleft()
        steps += 1
        if Clause.empty() in current:
            goal_found = True
        for succ in get_successors(cnf, current, space_bound):
            if succ not in visited:
                visited.add(succ)
                queue.append(succ)

    return {
        "reachable_configs": len(visited),
        "steps_explored": steps,
        "goal_found": goal_found,
        "exhausted": len(queue) == 0,
    }


def enumerate_all_clauses(variables: list[int],
                          disjoint_only: bool = True) -> list[Clause]:
    """Enumerate all clauses over given variables."""
    clauses = []
    for assignment in itertools.product(range(3 if disjoint_only else 4),
                                        repeat=len(variables)):
        pos = frozenset(v for v, a in zip(variables, assignment) if a == 1)
        neg = frozenset(v for v, a in zip(variables, assignment) if a == 2)
        clauses.append(Clause(pos, neg))
    return clauses


def total_config_bound(n_vars: int, space_bound: int,
                       disjoint: bool = True) -> int:
    """
    Compute the theoretical upper bound on configurations.
    Sum of C(num_clauses, k) for k = 0..s.
    """
    from math import comb
    num_clauses = 3**n_vars if disjoint else 4**n_vars
    return sum(comb(num_clauses, k) for k in range(space_bound + 1))


def generate_random_cnf(n_vars: int, n_clauses: int,
                        max_clause_size: int = 3,
                        seed: Optional[int] = None) -> CNF:
    """Generate a random CNF formula."""
    import random
    if seed is not None:
        random.seed(seed)
    variables = list(range(1, n_vars + 1))
    clauses = []
    for _ in range(n_clauses):
        k = random.randint(1, min(max_clause_size, n_vars))
        chosen = random.sample(variables, k)
        pos = frozenset(v for v in chosen if random.random() < 0.5)
        neg = frozenset(v for v in chosen if v not in pos)
        clauses.append(Clause(pos, neg))
    return CNF(clauses, set(variables))


# Predefined small unsatisfiable CNFs for testing
def pigeonhole_2_1() -> CNF:
    """Pigeonhole: 2 pigeons, 1 hole. Variables: p_{i,j} = pigeon i in hole j."""
    # p11 = 1, p21 = 2
    # At least one hole per pigeon: (p11), (p21)
    # At most one pigeon per hole: (¬p11 ∨ ¬p21)
    c1 = Clause(frozenset({1}), frozenset())       # pigeon 1 in hole 1
    c2 = Clause(frozenset({2}), frozenset())       # pigeon 2 in hole 1
    c3 = Clause(frozenset(), frozenset({1, 2}))    # not both in hole 1
    return CNF([c1, c2, c3], {1, 2})


def simple_unsat() -> CNF:
    """Simple unsatisfiable: (x) ∧ (¬x)."""
    c1 = Clause(frozenset({1}), frozenset())
    c2 = Clause(frozenset(), frozenset({1}))
    return CNF([c1, c2], {1})


def two_var_unsat() -> CNF:
    """Unsatisfiable on 2 variables: (x∨y) ∧ (x∨¬y) ∧ (¬x∨y) ∧ (¬x∨¬y)."""
    c1 = Clause(frozenset({1, 2}), frozenset())
    c2 = Clause(frozenset({1}), frozenset({2}))
    c3 = Clause(frozenset({2}), frozenset({1}))
    c4 = Clause(frozenset(), frozenset({1, 2}))
    return CNF([c1, c2, c3, c4], {1, 2})
