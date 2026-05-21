#!/usr/bin/env python3
"""
Applications of Configuration-Based Clause Space Theory

Shows how the formalized theorems apply to practical problems:
1. SAT solver memory prediction
2. Proof complexity classification
3. Bottleneck detection in resolution proofs
"""

from algorithms import (
    bounded_space_refutable, compute_minimum_space,
    clause_space_bound, resolve_clauses
)
from typing import FrozenSet, Tuple

Literal = Tuple[str, bool]
Clause = FrozenSet[Literal]
CNF = FrozenSet[Clause]


def make_php(m: int, n: int) -> CNF:
    """Pigeonhole principle: m pigeons into n holes."""
    clauses = set()
    for i in range(m):
        clauses.add(frozenset((f"p{i}h{j}", True) for j in range(n)))
    for j in range(n):
        for i1 in range(m):
            for i2 in range(i1+1, m):
                clauses.add(frozenset([
                    (f"p{i1}h{j}", False),
                    (f"p{i2}h{j}", False)
                ]))
    return frozenset(clauses)


def application_memory_prediction():
    """
    APPLICATION 1: Predicting SAT Solver Memory Requirements

    The bottleneck theorem gives a rigorous lower bound on how much
    memory any resolution-based SAT solver must use.
    """
    print("=" * 60)
    print("APPLICATION 1: Memory Prediction for SAT Solvers")
    print("=" * 60)
    print()
    print("For any CDCL SAT solver based on resolution:")
    print("  learned_clauses_in_memory ≥ min_clause_space(F)")
    print()

    # Simple unsatisfiable formula
    cnf = frozenset([
        frozenset([("a", True), ("b", True)]),
        frozenset([("a", True), ("b", False)]),
        frozenset([("a", False), ("b", True)]),
        frozenset([("a", False), ("b", False)]),
    ])

    min_s = compute_minimum_space(cnf, upper_bound=6)
    print(f"  Formula: 4 clauses over {{a, b}}")
    print(f"  Minimum clause space: {min_s}")
    print(f"  → Any solver needs ≥ {min_s} clauses in memory simultaneously")
    print()

    # Clause space bound
    n_vars = 2
    for w in range(1, n_vars + 1):
        b = clause_space_bound(n_vars, w)
        print(f"  clauseSpaceBound({n_vars}, {w}) = {b}")
    print()


def application_proof_classification():
    """
    APPLICATION 2: Proof Complexity Classification

    Different CNF families require different amounts of space.
    This classifies formulas by their space complexity.
    """
    print("=" * 60)
    print("APPLICATION 2: Proof Complexity Classification")
    print("=" * 60)
    print()

    formulas = {
        "trivial": frozenset([
            frozenset([("x", True)]),
            frozenset([("x", False)])
        ]),
        "width-2": frozenset([
            frozenset([("x", True), ("y", True)]),
            frozenset([("x", True), ("y", False)]),
            frozenset([("x", False), ("y", True)]),
            frozenset([("x", False), ("y", False)]),
        ]),
        "PHP(3,2)": make_php(3, 2),
    }

    print(f"{'Name':>12} {'|F|':>5} {'maxW':>5} {'space':>6}")
    print("-" * 35)

    for name, cnf in formulas.items():
        max_w = max(len(c) for c in cnf)
        s = compute_minimum_space(cnf, upper_bound=6)
        s_str = str(s) if s else ">6"
        print(f"{name:>12} {len(cnf):>5} {max_w:>5} {s_str:>6}")

    print()
    print("Higher space → harder for memory-bounded solvers")
    print()


def application_bottleneck_detection():
    """
    APPLICATION 3: Bottleneck Detection

    Uses the graph separation theorem to identify memory bottlenecks.
    """
    print("=" * 60)
    print("APPLICATION 3: Bottleneck Detection")
    print("=" * 60)
    print()

    cnf = frozenset([
        frozenset([("x", True)]),
        frozenset([("x", False)])
    ])

    print("Formula: {x} ∧ {¬x}")
    print()
    print("Configuration graph reachability by space bound:")

    for s in range(1, 5):
        found, trace, explored = bounded_space_refutable(cnf, s, max_configs=1000)
        if found:
            print(f"  s={s}: REACHABLE — refutation found in {len(trace)-1} steps")
        else:
            print(f"  s={s}: BLOCKED — {explored} configs explored, no refutation")
            print(f"         → Bottleneck theorem: ALL refutations need space ≥ {s+1}")

    print()
    print("The smallest s where 'REACHABLE' first appears is the")
    print("minimum clause space of the formula.")
    print()


if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Applications of Configuration Space Theory           ║")
    print("╚════════════════════════════════════════════════════════╝")
    print()

    application_memory_prediction()
    application_proof_classification()
    application_bottleneck_detection()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Configuration-Based Clause Space for Resolution: Demonstration

Demonstrates the configuration-space model by constructing small CNFs,
computing clause space via configuration search, and showing bottleneck frontiers.
"""

from itertools import combinations
from collections import deque


# ─── CNF Representation ───────────────────────────────────────────────────────

class Literal:
    __slots__ = ('var', 'positive')
    def __init__(self, var, positive=True):
        self.var = var
        self.positive = positive
    def neg(self):
        return Literal(self.var, not self.positive)
    def __eq__(self, other):
        return self.var == other.var and self.positive == other.positive
    def __hash__(self):
        return hash((self.var, self.positive))
    def __repr__(self):
        return f"{self.var}" if self.positive else f"¬{self.var}"


def php_cnf(m, n):
    """PHP(m,n): m pigeons, n holes. Unsatisfiable when m > n."""
    clauses = set()
    for i in range(m):
        clauses.add(frozenset(Literal(f"p{i}h{j}") for j in range(n)))
    for j in range(n):
        for i1 in range(m):
            for i2 in range(i1+1, m):
                clauses.add(frozenset([Literal(f"p{i1}h{j}", False),
                                        Literal(f"p{i2}h{j}", False)]))
    return clauses


def simple_unsat_cnf():
    """A trivially unsatisfiable CNF: {x} ∧ {¬x}."""
    x = Literal("x")
    return {frozenset([x]), frozenset([x.neg()])}


def small_unsat_cnf():
    """Small unsatisfiable CNF: {x,y} ∧ {x,¬y} ∧ {¬x,y} ∧ {¬x,¬y}."""
    x, y = Literal("x"), Literal("y")
    return {
        frozenset([x, y]),
        frozenset([x, y.neg()]),
        frozenset([x.neg(), y]),
        frozenset([x.neg(), y.neg()])
    }


# ─── Configuration Space Search ───────────────────────────────────────────────

def resolve(c1, c2):
    """Try all possible resolutions between two clauses."""
    results = []
    for lit in c1:
        neg_lit = lit.neg()
        if neg_lit in c2:
            resolvent = (c1 - {lit}) | (c2 - {neg_lit})
            results.append(resolvent)
    return results


def bounded_space_search(cnf, max_space, max_configs=50000):
    """BFS through configuration space within space bound."""
    initial = frozenset()
    empty_clause = frozenset()

    visited = {initial}
    queue = deque([(initial, 0)])
    configs_explored = 0

    while queue and configs_explored < max_configs:
        config, depth = queue.popleft()
        configs_explored += 1

        if empty_clause in config:
            return True, depth, configs_explored

        # Axiom downloads
        for clause in cnf:
            if clause not in config:
                new_config = config | {clause}
                if len(new_config) <= max_space and new_config not in visited:
                    visited.add(new_config)
                    queue.append((new_config, depth + 1))

        # Resolution steps
        clauses = list(config)
        for i in range(len(clauses)):
            for j in range(i+1, len(clauses)):
                for resolvent in resolve(clauses[i], clauses[j]):
                    if resolvent not in config:
                        new_config = config | {resolvent}
                        if len(new_config) <= max_space and new_config not in visited:
                            visited.add(new_config)
                            queue.append((new_config, depth + 1))

        # Erasure steps
        for clause in config:
            new_config = config - {clause}
            if new_config not in visited:
                visited.add(new_config)
                queue.append((new_config, depth + 1))

    return False, -1, configs_explored


def compute_min_space(cnf, max_s=6):
    """Find minimum clause space for refutation."""
    for s in range(1, max_s + 1):
        found, depth, explored = bounded_space_search(cnf, s)
        if found:
            return s, depth, explored
    return None, -1, -1


# ─── Experiments ──────────────────────────────────────────────────────────────

def experiment_trivial():
    """Experiment with trivially unsatisfiable CNFs."""
    print("=" * 60)
    print("EXPERIMENT 1: Trivial Unsatisfiable CNFs")
    print("=" * 60)
    print()

    # {x} ∧ {¬x}
    cnf = simple_unsat_cnf()
    s, d, e = compute_min_space(cnf)
    print(f"  {{x}} ∧ {{¬x}}: space={s}, trace_length={d}, explored={e}")

    # Width-2 tautological contradiction
    cnf = small_unsat_cnf()
    s, d, e = compute_min_space(cnf)
    print(f"  4-clause width-2: space={s}, trace_length={d}, explored={e}")
    print()


def experiment_php():
    """Standard PHP space analysis."""
    print("=" * 60)
    print("EXPERIMENT 2: Pigeonhole Principle Space")
    print("=" * 60)
    print()
    print(f"{'PHP':>10} {'|F|':>5} {'maxW':>5} {'space':>6} {'steps':>7} {'explored':>9}")
    print("-" * 50)

    for n in range(2, 5):
        cnf = php_cnf(n+1, n)
        w = max(len(c) for c in cnf)
        s, d, e = compute_min_space(cnf, max_s=n+2)
        s_str = str(s) if s is not None else ">"+str(n+2)
        print(f"  PHP({n+1},{n}) {len(cnf):>5} {w:>5} {s_str:>6} {d:>7} {e:>9}")

    print()
    print("Width-space theorem: space ≥ refWidth - maxInitWidth + 1")
    print("For PHP(n+1,n): refWidth ≥ n, maxInitWidth = n, so bound = 1 (trivial)")
    print()


def experiment_bottleneck():
    """Bottleneck frontier analysis."""
    print("=" * 60)
    print("EXPERIMENT 3: Bottleneck Frontier")
    print("=" * 60)
    print()

    cnf = simple_unsat_cnf()
    print("Formula: {x} ∧ {¬x}")
    for s in range(1, 4):
        found, d, e = bounded_space_search(cnf, s)
        label = f"REFUTABLE (depth {d})" if found else "BLOCKED"
        print(f"  Space ≤ {s}: {label}  ({e} configs)")

    print()
    cnf = small_unsat_cnf()
    print("Formula: {x,y} ∧ {x,¬y} ∧ {¬x,y} ∧ {¬x,¬y}")
    for s in range(1, 5):
        found, d, e = bounded_space_search(cnf, s)
        label = f"REFUTABLE (depth {d})" if found else "BLOCKED"
        print(f"  Space ≤ {s}: {label}  ({e} configs)")

    print()
    print("Bottleneck theorem: if s-bounded search is BLOCKED,")
    print("every refutation needs space ≥ s+1.")
    print()


def experiment_clause_count():
    """Distinct clause count bound demonstration."""
    print("=" * 60)
    print("EXPERIMENT 4: Clause Count Bound (Theorem 3)")
    print("=" * 60)
    print()
    print("Theorem: |distinct clauses in trace| ≤ length × space")
    print()

    cnf = simple_unsat_cnf()
    print("Formula: {x} ∧ {¬x}")
    s, d, _ = compute_min_space(cnf)
    print(f"  Min space: {s}, trace length: {d}")
    print(f"  Bound: {d} × {s} = {d*s}")
    print(f"  Actual distinct clauses: ≤ {len(cnf) + 1} (axioms + empty clause)")

    print()
    cnf = small_unsat_cnf()
    print("Formula: {x,y} ∧ {x,¬y} ∧ {¬x,y} ∧ {¬x,¬y}")
    s, d, _ = compute_min_space(cnf)
    if s:
        print(f"  Min space: {s}, trace length: {d}")
        print(f"  Bound: {d} × {s} = {d*s}")
    print()


def experiment_space_bound_table():
    """Space bound comparison table."""
    print("=" * 60)
    print("EXPERIMENT 5: clauseSpaceBound(n, w) = Σ C(n,k)·2^k")
    print("=" * 60)
    print()

    from math import comb
    def clause_space_bound(n, w):
        return sum(comb(n, k) * 2**k for k in range(w+1))

    print(f"{'n':>4} {'w':>4} {'bound':>10} {'3^n':>10}")
    print("-" * 35)
    for n in range(1, 7):
        for w in [1, n//2, n]:
            b = clause_space_bound(n, w)
            print(f"{n:>4} {w:>4} {b:>10} {3**n:>10}")
    print()
    print("When w = n: clauseSpaceBound(n,n) = 3^n (binomial theorem)")
    print()


if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Configuration-Based Clause Space — Demonstrations    ║")
    print("╚════════════════════════════════════════════════════════╝")
    print()

    experiment_trivial()
    experiment_php()
    experiment_bottleneck()
    experiment_clause_count()
    experiment_space_bound_table()

    print("All experiments completed successfully.")
