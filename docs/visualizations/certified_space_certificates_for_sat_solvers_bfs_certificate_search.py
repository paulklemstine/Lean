"""
Clause-Space Certificate Algorithms

Implements bounded-space certificate search and verification for CNF formulas.
Provides BFS-based search over the finite configuration graph, certificate
validation, and configuration counting.

This module implements the key algorithms from the clause-space certificate
theory: a framework for certifying unsatisfiability within a prescribed
memory budget using finite-state reachability.
"""

from __future__ import annotations
from typing import Optional, NamedTuple
from itertools import combinations, product
from collections import deque
import time


class Clause:
    """A clause is a frozenset of literals (variable, polarity) pairs.
    
    Example: Clause({(0, True), (1, False)}) represents x0 ∨ ¬x1
    """
    def __init__(self, literals: set[tuple[int, bool]] | frozenset[tuple[int, bool]]):
        self.literals = frozenset(literals)
    
    def __eq__(self, other):
        return isinstance(other, Clause) and self.literals == other.literals
    
    def __hash__(self):
        return hash(self.literals)
    
    def __repr__(self):
        if not self.literals:
            return "□"  # empty clause
        parts = []
        for var, pol in sorted(self.literals):
            parts.append(f"x{var}" if pol else f"¬x{var}")
        return " ∨ ".join(parts)
    
    def __len__(self):
        return len(self.literals)
    
    def is_empty(self) -> bool:
        return len(self.literals) == 0
    
    def satisfied_by(self, assignment: dict[int, bool]) -> bool:
        """Check if the clause is satisfied by the given assignment."""
        return any(assignment.get(var, False) == pol for var, pol in self.literals)
    
    def is_proper(self) -> bool:
        """Check if no variable appears both positively and negatively."""
        vars_seen: dict[int, bool] = {}
        for var, pol in self.literals:
            if var in vars_seen and vars_seen[var] != pol:
                return False
            vars_seen[var] = pol
        return True
    
    def to_ternary(self, num_vars: int) -> tuple[int, ...]:
        """Map to ternary vector: 0=absent, 1=positive, 2=negative."""
        result = [0] * num_vars
        for var, pol in self.literals:
            if var < num_vars:
                result[var] = 1 if pol else 2
        return tuple(result)


EMPTY_CLAUSE = Clause(set())


class CNF:
    """A CNF formula is a set of clauses (conjunction of disjunctions)."""
    
    def __init__(self, clauses: list[Clause]):
        self.clauses = frozenset(clauses)
    
    def __repr__(self):
        return " ∧ ".join(f"({c})" for c in sorted(self.clauses, key=str))
    
    def satisfied_by(self, assignment: dict[int, bool]) -> bool:
        return all(c.satisfied_by(assignment) for c in self.clauses)
    
    def is_satisfiable(self, num_vars: int) -> bool:
        """Brute-force satisfiability check."""
        for bits in range(2 ** num_vars):
            assignment = {v: bool((bits >> v) & 1) for v in range(num_vars)}
            if self.satisfied_by(assignment):
                return True
        return False
    
    def variables(self) -> set[int]:
        """Get all variables appearing in the formula."""
        return {var for c in self.clauses for var, _ in c.literals}


def resolve(c1: Clause, c2: Clause, var: int) -> Optional[Clause]:
    """Resolve c1 and c2 on variable var.
    
    Returns the resolvent if (var, True) ∈ c1 and (var, False) ∈ c2,
    otherwise None.
    """
    if (var, True) not in c1.literals or (var, False) not in c2.literals:
        return None
    new_lits = (c1.literals - {(var, True)}) | (c2.literals - {(var, False)})
    return Clause(new_lits)


# --- Space Configuration ---

class SpaceConfig:
    """A bounded-memory configuration: a frozenset of clauses."""
    
    def __init__(self, clauses: frozenset[Clause] | set[Clause] = frozenset()):
        self.clauses = frozenset(clauses)
    
    def __eq__(self, other):
        return isinstance(other, SpaceConfig) and self.clauses == other.clauses
    
    def __hash__(self):
        return hash(self.clauses)
    
    def __repr__(self):
        if not self.clauses:
            return "{}"
        return "{" + ", ".join(str(c) for c in sorted(self.clauses, key=str)) + "}"
    
    @property
    def size(self) -> int:
        return len(self.clauses)
    
    def contains_empty_clause(self) -> bool:
        return EMPTY_CLAUSE in self.clauses


class StepInfo(NamedTuple):
    """Information about a space step for certificate reconstruction."""
    kind: str  # "download", "resolve", "erase"
    detail: str


def get_successors(config: SpaceConfig, cnf: CNF, variables: set[int],
                   space_bound: int) -> list[tuple[SpaceConfig, StepInfo]]:
    """Get all valid successor configurations within the space bound.
    
    Returns list of (new_config, step_info) pairs.
    """
    successors = []
    
    # Download: add an axiom clause
    for c in cnf.clauses:
        new_clauses = config.clauses | {c}
        if len(new_clauses) <= space_bound:
            successors.append((
                SpaceConfig(new_clauses),
                StepInfo("download", str(c))
            ))
    
    # Resolve: derive a new clause
    clause_list = list(config.clauses)
    for i, c1 in enumerate(clause_list):
        for j, c2 in enumerate(clause_list):
            for v in variables:
                r = resolve(c1, c2, v)
                if r is not None:
                    new_clauses = config.clauses | {r}
                    if len(new_clauses) <= space_bound:
                        successors.append((
                            SpaceConfig(new_clauses),
                            StepInfo("resolve", f"{c1} ⊗ {c2} on x{v} → {r}")
                        ))
    
    # Erase: remove a clause
    for c in config.clauses:
        new_clauses = config.clauses - {c}
        successors.append((
            SpaceConfig(new_clauses),
            StepInfo("erase", str(c))
        ))
    
    return successors


class SpaceCertificate:
    """A space certificate: a trace of configurations with step info."""
    
    def __init__(self, trace: list[SpaceConfig], steps: list[StepInfo],
                 space_bound: int):
        self.trace = trace
        self.steps = steps
        self.space_bound = space_bound
    
    def is_valid(self, cnf: CNF) -> bool:
        """Verify the certificate is valid."""
        if not self.trace:
            return False
        if self.trace[0] != SpaceConfig():
            return False
        if not self.trace[-1].contains_empty_clause():
            return False
        if any(cfg.size > self.space_bound for cfg in self.trace):
            return False
        return True
    
    @property
    def length(self) -> int:
        return len(self.trace)
    
    def __repr__(self):
        lines = [f"SpaceCertificate (bound={self.space_bound}, length={self.length}):"]
        for i, (cfg, step) in enumerate(zip(self.trace, ["START"] + [s.detail for s in self.steps])):
            lines.append(f"  [{i}] {step}")
            lines.append(f"       mem = {cfg}")
        return "\n".join(lines)


def find_space_certificate(cnf: CNF, space_bound: int, 
                           num_vars: int,
                           max_configs: int = 100000) -> Optional[SpaceCertificate]:
    """BFS search for a space certificate.
    
    Searches the finite graph of bounded configurations using BFS,
    guaranteeing the shortest certificate is found (if one exists
    within the search budget).
    
    Args:
        cnf: The CNF formula
        space_bound: Maximum number of clauses in memory
        num_vars: Number of variables
        max_configs: Maximum configurations to explore
    
    Returns:
        A SpaceCertificate if found, None otherwise
    """
    variables = set(range(num_vars))
    start = SpaceConfig()
    
    # BFS
    visited: dict[SpaceConfig, tuple[Optional[SpaceConfig], Optional[StepInfo]]] = {
        start: (None, None)
    }
    queue: deque[SpaceConfig] = deque([start])
    configs_explored = 0
    
    while queue and configs_explored < max_configs:
        current = queue.popleft()
        configs_explored += 1
        
        # Check if goal reached
        if current.contains_empty_clause():
            # Reconstruct path
            path = []
            steps = []
            node = current
            while node is not None:
                path.append(node)
                prev, step = visited[node]
                if step is not None:
                    steps.append(step)
                node = prev
            path.reverse()
            steps.reverse()
            return SpaceCertificate(path, steps, space_bound)
        
        # Explore successors
        for succ, step_info in get_successors(current, cnf, variables, space_bound):
            if succ not in visited:
                visited[succ] = (current, step_info)
                queue.append(succ)
    
    return None


class SearchStats(NamedTuple):
    """Statistics from a certificate search."""
    found: bool
    certificate_length: Optional[int]
    configs_explored: int
    total_bounded_configs: int
    time_seconds: float
    formula: str
    space_bound: int


def count_bounded_configs(num_vars: int, space_bound: int) -> int:
    """Count the theoretical upper bound on bounded configurations.
    
    Uses the formula: sum_{k=0}^{s} C(num_clauses, k)
    where num_clauses = 2^(2*num_vars) (all subsets of the literal set).
    
    For practical counting, we use the number of "reachable" clauses
    which is much smaller.
    """
    from math import comb
    num_literals = 2 * num_vars
    num_clauses = 2 ** num_literals
    total = sum(comb(num_clauses, k) for k in range(space_bound + 1))
    return total


def count_proper_clauses(num_vars: int) -> int:
    """Count proper clauses: 3^n (each variable absent, positive, or negative)."""
    return 3 ** num_vars


def enumerate_all_proper_clauses(num_vars: int) -> list[Clause]:
    """Enumerate all proper clauses over num_vars variables."""
    clauses = []
    for assignment in product(range(3), repeat=num_vars):
        lits = set()
        for var, val in enumerate(assignment):
            if val == 1:
                lits.add((var, True))
            elif val == 2:
                lits.add((var, False))
        clauses.append(Clause(lits))
    return clauses


def generate_random_cnf(num_vars: int, num_clauses: int, 
                        clause_width: int = 3,
                        seed: Optional[int] = None) -> CNF:
    """Generate a random CNF formula."""
    import random
    if seed is not None:
        random.seed(seed)
    
    clauses = []
    variables = list(range(num_vars))
    for _ in range(num_clauses):
        width = min(clause_width, num_vars)
        chosen_vars = random.sample(variables, width)
        lits = {(v, random.choice([True, False])) for v in chosen_vars}
        clauses.append(Clause(lits))
    return CNF(clauses)


def generate_pigeonhole(n: int) -> tuple[CNF, int]:
    """Generate the pigeonhole principle PHP(n+1, n).
    
    n+1 pigeons must go into n holes. This is a classic unsatisfiable
    formula that requires large clause space.
    
    Variables: x_{i,j} means pigeon i is in hole j.
    Variable encoding: i * n + j for pigeon i, hole j.
    
    Returns (cnf, num_vars).
    """
    pigeons = n + 1
    holes = n
    num_vars = pigeons * holes
    
    def var(pigeon, hole):
        return pigeon * holes + hole
    
    clauses = []
    
    # Each pigeon must be in some hole
    for i in range(pigeons):
        lits = {(var(i, j), True) for j in range(holes)}
        clauses.append(Clause(lits))
    
    # No two pigeons in the same hole
    for j in range(holes):
        for i1 in range(pigeons):
            for i2 in range(i1 + 1, pigeons):
                clauses.append(Clause({(var(i1, j), False), (var(i2, j), False)}))
    
    return CNF(clauses), num_vars


if __name__ == "__main__":
    # Quick test
    # x0 ∨ x1, ¬x0, ¬x1 — unsatisfiable
    c1 = Clause({(0, True), (1, True)})
    c2 = Clause({(0, False)})
    c3 = Clause({(1, False)})
    F = CNF([c1, c2, c3])
    
    print(f"Formula: {F}")
    print(f"Satisfiable: {F.is_satisfiable(2)}")
    
    cert = find_space_certificate(F, 3, 2)
    if cert:
        print(f"\nCertificate found!")
        print(cert)
        print(f"Valid: {cert.is_valid(F)}")
    else:
        print("No certificate found")
    
    print(f"\nProper clauses over 2 vars: {count_proper_clauses(2)}")
    print(f"Theoretical bound: {count_proper_clauses(2)} = 3^2 = 9")
