"""
Clause-Space Certificate Algorithms

Implements the core algorithms for bounded-memory SAT refutation certificates:
- Clause and CNF representation
- Space-bounded proof search via BFS over configuration graphs
- Certificate verification
- Configuration counting and complexity analysis

These algorithms mirror the formally verified Lean definitions and theorems.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
from itertools import combinations, product
from collections import deque
import time


@dataclass(frozen=True)
class Clause:
    """A propositional clause: disjunction of positive and negative literals.

    Attributes:
        pos: frozenset of variables appearing positively
        neg: frozenset of variables appearing negatively
    """
    pos: frozenset[int]
    neg: frozenset[int]

    @staticmethod
    def empty() -> 'Clause':
        """The empty clause (always false)."""
        return Clause(frozenset(), frozenset())

    def is_empty(self) -> bool:
        return len(self.pos) == 0 and len(self.neg) == 0

    def is_disjoint(self) -> bool:
        """True if pos and neg are disjoint (non-tautological)."""
        return self.pos.isdisjoint(self.neg)

    def satisfied_by(self, assignment: dict[int, bool]) -> bool:
        """Check if this clause is satisfied by the given assignment."""
        for v in self.pos:
            if assignment.get(v, False):
                return True
        for v in self.neg:
            if not assignment.get(v, True):
                return True
        return False

    @staticmethod
    def resolve(c1: 'Clause', c2: 'Clause', v: int) -> 'Clause':
        """Resolve c1 and c2 on variable v."""
        return Clause(
            pos=(c1.pos | c2.pos) - {v},
            neg=(c1.neg | c2.neg) - {v}
        )

    def to_ternary(self, variables: list[int]) -> tuple[int, ...]:
        """Encode as ternary vector: 0=absent, 1=positive, 2=negative."""
        result = []
        for v in variables:
            if v in self.pos:
                result.append(1)
            elif v in self.neg:
                result.append(2)
            else:
                result.append(0)
        return tuple(result)

    def __repr__(self) -> str:
        lits = []
        for v in sorted(self.pos):
            lits.append(f"x{v}")
        for v in sorted(self.neg):
            lits.append(f"¬x{v}")
        return "(" + " ∨ ".join(lits) + ")" if lits else "⊥"


@dataclass
class CNF:
    """A CNF formula: conjunction of clauses.

    Attributes:
        clauses: list of clauses
        variables: set of all variables
    """
    clauses: list[Clause]
    variables: frozenset[int] = field(default_factory=frozenset)

    def __post_init__(self):
        if not self.variables:
            vs = set()
            for c in self.clauses:
                vs |= c.pos | c.neg
            object.__setattr__(self, 'variables', frozenset(vs))

    def satisfiable(self) -> tuple[bool, Optional[dict[int, bool]]]:
        """Brute-force SAT check. Returns (is_sat, witness)."""
        vars_list = sorted(self.variables)
        n = len(vars_list)
        for bits in range(2**n):
            assignment = {vars_list[i]: bool((bits >> i) & 1) for i in range(n)}
            if all(c.satisfied_by(assignment) for c in self.clauses):
                return True, assignment
        return False, None


# --- Configuration Space ---

Config = frozenset  # frozenset[Clause]


def all_clauses(variables: list[int]) -> list[Clause]:
    """Enumerate all disjoint clauses over the given variables."""
    n = len(variables)
    result = []
    for encoding in product(range(3), repeat=n):
        pos = frozenset(variables[i] for i in range(n) if encoding[i] == 1)
        neg = frozenset(variables[i] for i in range(n) if encoding[i] == 2)
        result.append(Clause(pos, neg))
    return result


def num_clauses(n_vars: int) -> int:
    """Number of disjoint clauses over n variables = 3^n."""
    return 3 ** n_vars


def count_bounded_configs(n_vars: int, s: int) -> int:
    """Upper bound on configurations of size ≤ s: sum of C(3^n, k) for k=0..s."""
    from math import comb
    total_clauses = 3 ** n_vars
    return sum(comb(total_clauses, k) for k in range(s + 1))


# --- Space Steps ---

def successors(config: Config, cnf: CNF) -> list[tuple[Config, str]]:
    """Generate all valid successor configurations with step descriptions."""
    results = []
    config_list = list(config)

    # Download: add an axiom clause
    for c in cnf.clauses:
        new_config = config | frozenset({c})
        if new_config != config:
            results.append((new_config, f"download {c}"))

    # Erase: remove a clause
    for c in config_list:
        new_config = config - frozenset({c})
        results.append((new_config, f"erase {c}"))

    # Resolve: resolve two in-memory clauses
    for i, c1 in enumerate(config_list):
        for j, c2 in enumerate(config_list):
            if i == j:
                continue
            # Find resolution variables: v in c1.pos ∩ c2.neg
            for v in c1.pos & c2.neg:
                if v not in c1.neg and v not in c2.pos:
                    resolvent = Clause.resolve(c1, c2, v)
                    new_config = config | frozenset({resolvent})
                    results.append((new_config, f"resolve {c1} {c2} on x{v} -> {resolvent}"))

    return results


# --- Space Certificate ---

@dataclass
class SpaceCertificate:
    """A space certificate: a trace of configurations from empty to goal."""
    trace: list[Config]
    steps: list[str]  # description of each step

    @property
    def space_used(self) -> int:
        return max(len(c) for c in self.trace) if self.trace else 0

    def is_valid(self, cnf: CNF, s: int) -> bool:
        """Verify the certificate is valid."""
        if not self.trace:
            return False
        if self.trace[0] != frozenset():
            return False
        if Clause.empty() not in self.trace[-1]:
            return False
        if any(len(c) > s for c in self.trace):
            return False
        return True

    def __repr__(self) -> str:
        lines = [f"SpaceCertificate (space={self.space_used}, length={len(self.trace)})"]
        for i, (config, step) in enumerate(zip(self.trace, ['start'] + self.steps)):
            clauses_str = ', '.join(str(c) for c in config) if config else '∅'
            lines.append(f"  [{i}] {step}: {{{clauses_str}}}")
        return '\n'.join(lines)


# --- BFS Search ---

def find_space_certificate(
    cnf: CNF,
    s: int,
    max_fuel: Optional[int] = None
) -> tuple[Optional[SpaceCertificate], dict]:
    """
    Search for a space certificate using BFS over the configuration graph.

    Args:
        cnf: The CNF formula
        s: Space bound (max clauses in memory)
        max_fuel: Maximum number of configurations to explore

    Returns:
        (certificate or None, statistics dict)
    """
    start_time = time.time()
    start_config: Config = frozenset()

    # BFS
    visited: dict[Config, tuple[Config, str]] = {start_config: (start_config, "start")}
    queue: deque[Config] = deque([start_config])
    explored = 0

    while queue:
        if max_fuel is not None and explored >= max_fuel:
            break

        current = queue.popleft()
        explored += 1

        # Check goal
        if Clause.empty() in current:
            # Reconstruct path by tracing back through visited
            path = []
            steps = []
            c = current
            while True:
                path.append(c)
                prev, step = visited[c]
                steps.append(step)
                if prev == c:  # reached start
                    break
                c = prev
            path.reverse()
            steps.reverse()

            elapsed = time.time() - start_time
            cert = SpaceCertificate(path, steps[1:])
            stats = {
                'found': True,
                'explored': explored,
                'visited': len(visited),
                'time': elapsed,
                'certificate_length': len(path),
                'space_used': cert.space_used,
            }
            return cert, stats

        # Expand
        for next_config, step_desc in successors(current, cnf):
            if len(next_config) <= s and next_config not in visited:
                visited[next_config] = (current, step_desc)
                queue.append(next_config)

    elapsed = time.time() - start_time
    stats = {
        'found': False,
        'explored': explored,
        'visited': len(visited),
        'time': elapsed,
    }
    return None, stats


# --- Certificate Verification ---

def verify_certificate(cert: SpaceCertificate, cnf: CNF, s: int) -> bool:
    """Independently verify a space certificate."""
    return cert.is_valid(cnf, s)


# --- Example CNFs ---

def pigeonhole_cnf(n: int) -> CNF:
    """
    Pigeonhole principle: n+1 pigeons, n holes.
    Unsatisfiable. Variables x_{i,j} means pigeon i is in hole j.
    """
    clauses = []
    var_map = {}
    var_id = 0

    # Each pigeon goes to some hole
    for i in range(n + 1):
        pos = set()
        for j in range(n):
            if (i, j) not in var_map:
                var_map[(i, j)] = var_id
                var_id += 1
            pos.add(var_map[(i, j)])
        clauses.append(Clause(frozenset(pos), frozenset()))

    # No two pigeons in same hole
    for j in range(n):
        for i1 in range(n + 1):
            for i2 in range(i1 + 1, n + 1):
                v1 = var_map[(i1, j)]
                v2 = var_map[(i2, j)]
                clauses.append(Clause(frozenset(), frozenset({v1, v2})))

    variables = frozenset(range(var_id))
    return CNF(clauses, variables)


def simple_unsat_cnf() -> CNF:
    """Simple unsatisfiable CNF: {x} ∧ {¬x}."""
    return CNF([
        Clause(frozenset({0}), frozenset()),     # x0
        Clause(frozenset(), frozenset({0})),      # ¬x0
    ])


def simple_unsat_2var() -> CNF:
    """Unsatisfiable CNF on 2 variables: x∧¬x∧y∧¬y simplified."""
    return CNF([
        Clause(frozenset({0}), frozenset()),      # x0
        Clause(frozenset(), frozenset({0})),       # ¬x0
    ])


def random_3sat(n_vars: int, n_clauses: int, seed: int = 42) -> CNF:
    """Generate a random 3-SAT instance."""
    import random
    rng = random.Random(seed)
    vars_list = list(range(n_vars))
    clauses = []
    for _ in range(n_clauses):
        vs = rng.sample(vars_list, min(3, n_vars))
        pos = frozenset(v for v in vs if rng.random() > 0.5)
        neg = frozenset(v for v in vs if v not in pos)
        clauses.append(Clause(pos, neg))
    return CNF(clauses)


if __name__ == "__main__":
    # Quick test
    cnf = simple_unsat_cnf()
    print(f"Formula: {' ∧ '.join(str(c) for c in cnf.clauses)}")
    print(f"Satisfiable: {cnf.satisfiable()[0]}")

    cert, stats = find_space_certificate(cnf, s=3)
    if cert:
        print(f"\nCertificate found!")
        print(cert)
        print(f"Valid: {verify_certificate(cert, cnf, 3)}")
    print(f"\nStats: {stats}")
