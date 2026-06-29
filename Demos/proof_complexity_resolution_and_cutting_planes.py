"""Numerical demonstrations for:

    Resolution and Cutting Planes: The Pigeonhole Principle as a Separation Witness

Every routine below mirrors a formally proved result:

  * build_php_cnf / php_is_unsatisfiable  ->  PHP_unsat
  * add_sound                             ->  add_sound
  * cg_rounding_sound                     ->  cg_rounding_sound
  * counting_refutation                   ->  php_cp_counting
  * resolution_size_blowup (illustrative) ->  Haken's lower bound (companion)

Self-contained: standard library only. Run with `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from math import ceil
from typing import Dict, List, Tuple

# A Boolean clause is a list of signed literals (var_index, is_positive).
Var = Tuple[int, int]            # (pigeon, hole)
Literal = Tuple[Var, bool]       # (variable, polarity)
Clause = List[Literal]


# ---------------------------------------------------------------------------
# 1. The pigeonhole CNF and its unsatisfiability  (mirrors PHP_unsat)
# ---------------------------------------------------------------------------

def build_php_cnf(n: int) -> List[Clause]:
    """Construct PHP_n: n+1 pigeons into n holes.

    Variables x_{p,h} mean 'pigeon p sits in hole h'.
    Pigeon clauses: each pigeon sits in some hole (positive disjunction).
    Hole clauses: no two distinct pigeons share a hole (binary negative).
    """
    clauses: List[Clause] = []
    pigeons = range(n + 1)
    holes = range(n)
    # pigeon clauses
    for p in pigeons:
        clauses.append([((p, h), True) for h in holes])
    # hole clauses over ordered distinct pigeon pairs
    for h in holes:
        for p1 in pigeons:
            for p2 in pigeons:
                if p1 != p2:
                    clauses.append([((p1, h), False), ((p2, h), False)])
    return clauses


def clause_satisfied(clause: Clause, assign: Dict[Var, bool]) -> bool:
    return any(assign[v] == pol for (v, pol) in clause)


def php_is_unsatisfiable(n: int) -> bool:
    """Brute-force check that PHP_n has no satisfying assignment.

    Returns True iff every assignment falsifies some clause (mirrors PHP_unsat).
    """
    cnf = build_php_cnf(n)
    variables = [(p, h) for p in range(n + 1) for h in range(n)]
    for bits in product([False, True], repeat=len(variables)):
        assign = dict(zip(variables, bits))
        if all(clause_satisfied(c, assign) for c in cnf):
            return False  # found a model -> would mean satisfiable
    return True


# ---------------------------------------------------------------------------
# 2. Cutting-planes soundness rules  (mirror add_sound, cg_rounding_sound)
# ---------------------------------------------------------------------------

def add_sound(c1: List[int], c2: List[int], d1: int, d2: int,
              x: List[int]) -> bool:
    """Verify add_sound on a concrete integer point.

    Given d1 <= <c1,x> and d2 <= <c2,x>, check d1+d2 <= <c1+c2, x>.
    Returns True when the hypotheses hold AND the conclusion holds.
    """
    lhs1 = sum(a * xi for a, xi in zip(c1, x))
    lhs2 = sum(a * xi for a, xi in zip(c2, x))
    if not (d1 <= lhs1 and d2 <= lhs2):
        return True  # hypotheses vacuous -> nothing claimed
    summed = sum((a + b) * xi for a, b, xi in zip(c1, c2, x))
    return d1 + d2 <= summed


def cg_rounding_sound(c: List[int], d: int, k: int, x: List[int]) -> bool:
    """Verify cg_rounding_sound on a concrete integer point.

    Requires k > 0 and k | c_i for all i. Given d <= <c,x>, check
    ceil(d/k) <= <c/k, x>.
    """
    assert k > 0 and all(ci % k == 0 for ci in c), "CG hypotheses violated"
    lhs = sum(ci * xi for ci, xi in zip(c, x))
    if not (d <= lhs):
        return True
    rounded_bound = ceil(d / k)
    divided = sum((ci // k) * xi for ci, xi in zip(c, x))
    return rounded_bound <= divided


# ---------------------------------------------------------------------------
# 3. The counting refutation  (mirrors php_cp_counting)
# ---------------------------------------------------------------------------

def counting_refutation(n: int, x: Dict[Var, int]) -> Tuple[int, int, int]:
    """Run the double-counting cutting-planes refutation of PHP_n.

    Assumes x satisfies the row lower bounds (sum_h x_{p,h} >= 1) and the
    column upper bounds (sum_p x_{p,h} <= 1). Returns (lower, total, upper)
    where lower = n+1, total = sum of all variables, upper = n. The
    refutation is the impossible chain  lower <= total <= upper.
    """
    # row lower bounds
    for p in range(n + 1):
        row = sum(x[(p, h)] for h in range(n))
        assert row >= 1, f"row {p} violates lower bound"
    # column upper bounds
    for h in range(n):
        col = sum(x[(p, h)] for p in range(n + 1))
        assert col <= 1, f"column {h} violates upper bound"
    total = sum(x[(p, h)] for p in range(n + 1) for h in range(n))
    lower = n + 1   # = sum over rows of 1
    upper = n       # = sum over columns of 1
    return lower, total, upper


# ---------------------------------------------------------------------------
# 4. Resolution-size blowup (illustrative, companion to Haken)
# ---------------------------------------------------------------------------

def resolution_lower_bound_estimate(n: int, c: float = 0.2) -> int:
    """Illustrative lower-bound magnitude 2^{c n} on resolution refutation size.

    Not a proof: a numerical sense of how astronomically large any resolution
    refutation of PHP_n must be, contrasting the O(n) cutting-planes proof.
    """
    return int(2 ** (c * n))


def cutting_planes_step_count(n: int) -> int:
    """Number of addition steps in the counting refutation: O(n)."""
    return (n + 1) + n  # sum the n+1 rows, then the n columns


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("Pigeonhole principle: resolution vs. cutting planes")
    print("=" * 68)

    print("\n[1] Unsatisfiability of PHP_n (brute force, mirrors PHP_unsat)")
    for n in range(1, 4):
        unsat = php_is_unsatisfiable(n)
        print(f"    PHP_{n}: {n+1} pigeons, {n} holes -> "
              f"unsatisfiable = {unsat}")

    print("\n[2] Soundness of the addition rule (add_sound)")
    c1, c2 = [2, 0, 1], [1, 3, 0]
    d1, d2 = 1, 2
    x = [1, 1, 1]
    print(f"    c1={c1}, c2={c2}, d1={d1}, d2={d2}, x={x}")
    print(f"    <c1,x>={sum(a*xi for a,xi in zip(c1,x))} >= {d1}, "
          f"<c2,x>={sum(a*xi for a,xi in zip(c2,x))} >= {d2}")
    print(f"    summed bound d1+d2={d1+d2} <= "
          f"<c1+c2,x>={sum((a+b)*xi for a,b,xi in zip(c1,c2,x))}: "
          f"{add_sound(c1, c2, d1, d2, x)}")

    print("\n[3] Soundness of Chvatal-Gomory rounding (cg_rounding_sound)")
    c, d, k = [6, 6, 6], 7, 6
    x3 = [1, 0, 1]
    print(f"    c={c}, d={d}, k={k}, x={x3}")
    print(f"    d/k = {d}/{k} = {d/k:.3f}, ceil = {ceil(d/k)}")
    print(f"    rounded inequality holds: {cg_rounding_sound(c, d, k, x3)}")

    print("\n[4] Counting refutation (php_cp_counting)")
    for n in (3, 5, 8):
        # A 'best try' assignment: put pigeon p in hole min(p, n-1).
        x_assign: Dict[Var, int] = {(p, h): 0 for p in range(n + 1)
                                    for h in range(n)}
        for p in range(n + 1):
            x_assign[(p, min(p, n - 1))] = 1
        # This necessarily violates a column upper bound; show the clash.
        # Repair so rows are satisfied; columns will then overflow.
        try:
            lower, total, upper = counting_refutation(n, x_assign)
            print(f"    n={n}: {lower} <= {total} <= {upper}  (impossible)")
        except AssertionError as e:
            # Demonstrate that any row-satisfying x forces a column overflow:
            # use the saturating assignment all-ones row choice and report.
            print(f"    n={n}: no x can satisfy both families -> {e}")
            # Construct the formal contradiction symbolically instead:
            print(f"          symbolic refutation: n+1 = {n+1} <= total "
                  f"<= n = {n}  ==>  {n+1} <= {n}  (False)")

    print("\n[5] The separation: proof sizes on PHP_n")
    print(f"    {'n':>4} | {'cutting-planes steps':>22} | "
          f"{'resolution >= 2^(0.2n)':>24}")
    for n in (10, 25, 50, 100):
        cp = cutting_planes_step_count(n)
        res = resolution_lower_bound_estimate(n)
        print(f"    {n:>4} | {cp:>22} | {res:>24}")

    print("\nConclusion: cutting planes refutes PHP_n in O(n) steps;")
    print("resolution provably requires 2^Omega(n).  Same truth, different cost.")


if __name__ == "__main__":
    main()
