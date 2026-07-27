#!/usr/bin/env python3
"""Numerical demonstrations for resolution and cutting planes on pigeonhole formulas."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple

Variable = Tuple[int, int]
Literal = Tuple[Variable, bool]  # True means positive.
Clause = Tuple[Literal, ...]
Assignment = Dict[Variable, bool]


@dataclass(frozen=True)
class Inequality:
    """The inequality bound <= sum(coeff[var] * x_var)."""

    coeff: Dict[Variable, int]
    bound: int

    def value(self, assignment: Mapping[Variable, bool]) -> int:
        return sum(c * int(assignment.get(v, False)) for v, c in self.coeff.items())

    def satisfied_by(self, assignment: Mapping[Variable, bool]) -> bool:
        return self.bound <= self.value(assignment)


def variables(m: int, n: int) -> List[Variable]:
    """Return all pigeon-hole incidence variables."""
    return [(i, j) for i in range(m) for j in range(n)]


def pigeonhole_cnf(m: int, n: int) -> List[Clause]:
    """Construct demand clauses and pairwise collision clauses."""
    if m < 0 or n < 0:
        raise ValueError("m and n must be nonnegative")
    clauses: List[Clause] = []
    for i in range(m):
        clauses.append(tuple((((i, j), True) for j in range(n))))
    for j in range(n):
        for i in range(m):
            for k in range(i + 1, m):
                clauses.append((((i, j), False), ((k, j), False)))
    return clauses


def clause_satisfied(clause: Clause, assignment: Mapping[Variable, bool]) -> bool:
    """Evaluate one disjunctive clause."""
    return any(assignment.get(var, False) == positive for var, positive in clause)


def cnf_satisfied(cnf: Sequence[Clause], assignment: Mapping[Variable, bool]) -> bool:
    """Evaluate a conjunction of clauses."""
    return all(clause_satisfied(clause, assignment) for clause in cnf)


def satisfying_assignments(m: int, n: int) -> Iterable[Assignment]:
    """Enumerate all models of the pigeonhole CNF; intended for small inputs."""
    vs = variables(m, n)
    cnf = pigeonhole_cnf(m, n)
    for bits in product((False, True), repeat=len(vs)):
        assignment = dict(zip(vs, bits))
        if cnf_satisfied(cnf, assignment):
            yield assignment


def add_inequalities(p: Inequality, q: Inequality) -> Inequality:
    """Add coefficients and bounds pointwise."""
    keys = set(p.coeff) | set(q.coeff)
    coeff = {v: p.coeff.get(v, 0) + q.coeff.get(v, 0) for v in keys}
    return Inequality(coeff, p.bound + q.bound)


def scale_inequality(k: int, q: Inequality) -> Inequality:
    """Multiply an inequality by a nonnegative integer."""
    if k < 0:
        raise ValueError("cutting-planes scaling must be nonnegative")
    return Inequality({v: k * c for v, c in q.coeff.items()}, k * q.bound)


def pigeon_inequality(m: int, n: int, i: int) -> Inequality:
    """Return 1 <= sum_j x_ij."""
    return Inequality({(r, j): int(r == i) for r in range(m) for j in range(n)}, 1)


def hole_inequality(m: int, n: int, j: int) -> Inequality:
    """Return -1 <= -sum_i x_ij, equivalent to capacity at most one."""
    return Inequality({(i, s): -int(s == j) for i in range(m) for s in range(n)}, -1)


def aggregate_certificate(m: int, n: int) -> Inequality:
    """Add all demand and capacity inequalities."""
    zero = Inequality({v: 0 for v in variables(m, n)}, 0)
    result = zero
    for i in range(m):
        result = add_inequalities(result, pigeon_inequality(m, n, i))
    for j in range(n):
        result = add_inequalities(result, hole_inequality(m, n, j))
    return result


def derivation_size_bound(m: int, n: int) -> int:
    """Return the proved cutting-planes node upper bound 2(m+n)+3."""
    return 2 * (m + n) + 3


def demonstrate(m: int, n: int, enumerate_limit: int = 20) -> None:
    """Print the CNF counts, aggregate certificate, and small exhaustive check."""
    if m < 0 or n < 0:
        raise ValueError("m and n must be nonnegative")
    cnf = pigeonhole_cnf(m, n)
    aggregate = aggregate_certificate(m, n)
    nonzero = {v: c for v, c in aggregate.coeff.items() if c != 0}
    print(f"Instance: {m} pigeons, {n} holes")
    print(f"Variables: {m * n}")
    print(f"CNF clauses: {len(cnf)} = {m} demand + {n * m * (m - 1) // 2} collision")
    print(f"Aggregate nonzero coefficients: {nonzero}")
    print(f"Aggregate inequality: {aggregate.bound} <= 0")
    print(f"Contradictory exactly when m > n: {aggregate.bound > 0}")
    print(f"Cutting-planes size upper bound: {derivation_size_bound(m, n)}")
    if m * n <= enumerate_limit:
        count = sum(1 for _ in satisfying_assignments(m, n))
        print(f"Exhaustive model count: {count}")
    else:
        print(f"Exhaustive check skipped: 2^{m*n} assignments exceed the demo limit")


def main() -> None:
    print("=== Overloaded instance ===")
    demonstrate(4, 3)
    print("\n=== Exactly balanced instance ===")
    demonstrate(3, 3)
    print("\n=== Small exhaustive comparison ===")
    for m, n in ((2, 1), (2, 2), (3, 2)):
        demonstrate(m, n)
        print()


if __name__ == "__main__":
    main()
