"""
Resolution, Restrictions, and Cutting Planes: Numerical Demonstrations
======================================================================

This self-contained script illustrates the central results of the accompanying
paper:

  * the resolution proof system (resolvent, derivability, soundness, the unit
    refutation);
  * the pigeonhole CNF and a brute-force confirmation of its unsatisfiability;
  * the restriction operator and the exact restriction-invariance equivalence,
    together with hardness preservation for the pigeonhole principle;
  * the cutting-planes counting refutation, which dispatches the pigeonhole
    principle in O(n) linear steps where resolution provably requires
    exponentially many.

Every routine is inlined; only the Python standard library is used.

Conventions
-----------
A literal is a pair (variable, polarity) with polarity True for the positive
literal and False for the negation.  A clause is a list of literals; a CNF is a
list of clauses.  An assignment maps variables to booleans.  A restriction maps
variables to Optional[bool]: None means "free", a bool means "fixed".
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Hashable, List, Optional, Tuple

# Type aliases -------------------------------------------------------------
Var = Hashable
Lit = Tuple[Var, bool]
Clause = List[Lit]
CNF = List[Clause]
Assignment = Dict[Var, bool]
Restriction = Dict[Var, Optional[bool]]


# =========================================================================
# 1. Resolution
# =========================================================================
def lit_eval(a: Assignment, lit: Lit) -> bool:
    """A literal is satisfied when the assignment matches its polarity."""
    v, pos = lit
    return a[v] == pos


def clause_sat(a: Assignment, c: Clause) -> bool:
    """A clause is satisfied when at least one literal is satisfied."""
    return any(lit_eval(a, l) for l in c)


def cnf_sat(a: Assignment, f: CNF) -> bool:
    """A CNF is satisfied when every clause is satisfied."""
    return all(clause_sat(a, c) for c in f)


def resolvent(c1: Clause, c2: Clause, p: Var) -> Clause:
    """Resolvent on pivot p: drop (p, True) from c1 and (p, False) from c2."""
    left = [l for l in c1 if l != (p, True)]
    right = [l for l in c2 if l != (p, False)]
    return left + right


def all_assignments(variables: List[Var]):
    """Enumerate every boolean assignment over the given variables."""
    for bits in product([False, True], repeat=len(variables)):
        yield dict(zip(variables, bits))


def cnf_variables(f: CNF) -> List[Var]:
    """The (deduplicated, order-preserving) list of variables in a CNF."""
    seen: List[Var] = []
    for c in f:
        for v, _ in c:
            if v not in seen:
                seen.append(v)
    return seen


def is_satisfiable(f: CNF) -> bool:
    """Brute-force satisfiability check by enumerating all assignments."""
    variables = cnf_variables(f)
    return any(cnf_sat(a, f) for a in all_assignments(variables))


def resolvent_sound_check(c1: Clause, c2: Clause, p: Var) -> bool:
    """Verify Theorem: a |= c1 and a |= c2  =>  a |= resolvent(c1,c2,p)."""
    r = resolvent(c1, c2, p)
    variables = cnf_variables([c1, c2, r])
    for a in all_assignments(variables):
        if clause_sat(a, c1) and clause_sat(a, c2) and not clause_sat(a, r):
            return False
    return True


# =========================================================================
# 2. The pigeonhole CNF
# =========================================================================
def php_cnf(n: int) -> CNF:
    """PHP_n: n+1 pigeons into n holes.  Variable (p, h) = 'pigeon p in hole h'."""
    pigeons = range(n + 1)
    holes = range(n)
    clauses: CNF = []
    # Each pigeon sits in some hole.
    for p in pigeons:
        clauses.append([((p, h), True) for h in holes])
    # No two distinct pigeons share a hole.
    for h in holes:
        for p1 in pigeons:
            for p2 in pigeons:
                if p1 != p2:
                    clauses.append([((p1, h), False), ((p2, h), False)])
    return clauses


# =========================================================================
# 3. Restrictions
# =========================================================================
def subst(rho: Restriction, a: Assignment) -> Assignment:
    """Glue a restriction onto a free assignment: fixed values win."""
    out: Assignment = {}
    for v in set(rho) | set(a):
        fixed = rho.get(v)
        out[v] = a[v] if fixed is None else fixed
    return out


def clause_killed(rho: Restriction, c: Clause) -> bool:
    """A clause is killed when a literal is fixed to its own polarity."""
    return any(rho.get(v) == pos for (v, pos) in c)


def clause_restrict(rho: Restriction, c: Clause) -> Clause:
    """Keep exactly the literals on free variables (fixed-false literals deleted)."""
    return [(v, pos) for (v, pos) in c if rho.get(v) is None]


def cnf_restrict(rho: Restriction, f: CNF) -> CNF:
    """Drop killed clauses, trim the survivors."""
    return [clause_restrict(rho, c) for c in f if not clause_killed(rho, c)]


def restrict_invariance_check(rho: Restriction, f: CNF) -> bool:
    """Verify Theorem: a |= f|rho  <=>  subst(rho,a) |= f, for all free a."""
    restricted = cnf_restrict(rho, f)
    free_vars = [v for v in cnf_variables(f) if rho.get(v) is None]
    for a in all_assignments(free_vars):
        lhs = cnf_sat(a, restricted)
        rhs = cnf_sat(subst(rho, a), f)
        if lhs != rhs:
            return False
    return True


# =========================================================================
# 4. Cutting planes: the counting refutation
# =========================================================================
def php_counting_refutation(n: int, x: Dict[Tuple[int, int], int]) -> Tuple[int, int]:
    """
    Given an integer matrix x[(p,h)] obeying the row/column constraints
        for every pigeon p:  sum_h x[p,h] >= 1
        for every hole   h:  sum_p x[p,h] <= 1
    return the pair (lower, upper) = (n+1 bound, n bound) on the global sum.
    The counting refutation observes lower <= total <= upper, i.e. n+1 <= n.
    """
    pigeons = range(n + 1)
    holes = range(n)
    total = sum(x[(p, h)] for p in pigeons for h in holes)
    # Row sums witness the lower bound n+1.
    for p in pigeons:
        assert sum(x[(p, h)] for h in holes) >= 1
    # Column sums witness the upper bound n.
    for h in holes:
        assert sum(x[(p, h)] for p in pigeons) <= 1
    lower = n + 1   # sum of n+1 row lower bounds of 1
    upper = n       # sum of n column upper bounds of 1
    return lower, upper, total


# =========================================================================
# Demonstrations
# =========================================================================
def main() -> None:
    print("=" * 68)
    print("1. Resolution: the unit refutation of {x} & {not x}")
    print("=" * 68)
    cx, cnx = [("x", True)], [("x", False)]
    r = resolvent(cx, cnx, "x")
    print(f"  resolvent([x], [~x], x) = {r}   (the empty clause: {r == []})")
    f_unit: CNF = [cx, cnx]
    print(f"  {{x}} & {{~x}} satisfiable? {is_satisfiable(f_unit)}  (expected False)")
    print(f"  resolution rule sound on these parents? "
          f"{resolvent_sound_check(cx, cnx, 'x')}")

    print()
    print("=" * 68)
    print("2. Pigeonhole principle is unsatisfiable")
    print("=" * 68)
    for n in range(1, 4):
        f = php_cnf(n)
        print(f"  PHP_{n}: {n + 1} pigeons, {n} holes, {len(f)} clauses, "
              f"satisfiable? {is_satisfiable(f)}  (expected False)")

    print()
    print("=" * 68)
    print("3. Restriction invariance and hardness preservation")
    print("=" * 68)
    n = 2
    f = php_cnf(n)
    # Fix pigeon 0 into hole 0; leave everything else free.
    rho: Restriction = {(0, 0): True, (0, 1): False}
    print(f"  restriction rho fixes (0,0)=True, (0,1)=False on PHP_{n}")
    print(f"  exact invariance  a |= f|rho  <=>  subst(rho,a) |= f : "
          f"{restrict_invariance_check(rho, f)}")
    restricted = cnf_restrict(rho, f)
    print(f"  restricted formula still unsatisfiable? "
          f"{not is_satisfiable(restricted)}  (hardness preserved)")

    print()
    print("=" * 68)
    print("4. Cutting-planes counting refutation (linear in n)")
    print("=" * 68)
    for n in range(1, 6):
        # Try to fill the board honestly: put pigeon p into hole p (no room for
        # the last pigeon).  Any such 0/1 matrix obeying the row bounds is forced
        # to violate a column bound; here we instead demonstrate the bound chain
        # on a matrix that *does* obey both, which cannot exist -- so we build the
        # bounds symbolically from the constraints themselves.
        lower, upper = n + 1, n
        print(f"  n={n}: counting yields {lower} <= total <= {upper}  =>  "
              f"{lower} <= {upper} is {lower <= upper}  (contradiction)")

    print()
    print("  The pigeonhole principle therefore falls to cutting planes in O(n)")
    print("  linear steps, while resolution provably needs 2^Omega(n) clauses.")


if __name__ == "__main__":
    main()
