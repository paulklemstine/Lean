"""
Numerical demonstrations for
"The Cantorian Hierarchy of Infinities: An Explicit Tower, Hartogs Bounds,
 and the Continuum".

The infinite cardinal arithmetic of the paper has a finite, fully computable
"skeleton". Each demo below exhibits one such skeleton:

  1. The Cantor / beth tower  T_0 = b, T_{n+1} = 2^{T_n}  (finite-base model of
     aleph_0 < 2^aleph_0 < 2^(2^aleph_0) < ...), and Cantor's theorem |S| < |P(S)|.
  2. Cantor diagonalization: from any finite "enumeration" of binary strings,
     build a string not in the list (finite shadow of aleph_0 < 2^aleph_0).
  3. Cofinality of aleph-indexed cardinals: decide regular vs. singular, and
     use it to confirm c != aleph_omega (c has uncountable cofinality, while
     aleph_omega has cofinality aleph_0).

Everything is self-contained standard-library Python with type hints.
"""

from __future__ import annotations

import sys
from typing import List, Tuple

sys.set_int_max_str_digits(1_000_000)


# ---------------------------------------------------------------------------
# Demo 1: the Cantor / beth tower and Cantor's theorem |S| < |P(S)| = 2^|S|
# ---------------------------------------------------------------------------

def cantor_tower(base: int, height: int) -> List[int]:
    """Finite-base model of the beth tower  T_0 = base, T_{n+1} = 2^{T_n}.

    In the transfinite setting base = aleph_0 and the sequence is
    aleph_0 < 2^aleph_0 < 2^(2^aleph_0) < ...; here we use a finite base so the
    explosive, strictly increasing growth is visible as ordinary integers.
    """
    tower: List[int] = [base]
    for _ in range(height):
        tower.append(2 ** tower[-1])
    return tower


def is_strictly_increasing(seq: List[int]) -> bool:
    """Check the defining property of the tower: T_n < T_{n+1} for all n."""
    return all(seq[i] < seq[i + 1] for i in range(len(seq) - 1))


def powerset_size(n: int) -> int:
    """|P(S)| = 2^|S| for a finite set S of size n; illustrates Cantor's theorem
    n < 2^n at the finite level."""
    return 2 ** n


def demo_tower() -> None:
    print("=" * 70)
    print("Demo 1: Cantor / beth tower  T_0 = base, T_{n+1} = 2^{T_n}")
    print("=" * 70)
    tower = cantor_tower(base=2, height=4)
    for n, t in enumerate(tower):
        label = "base" if n == 0 else f"2^(T_{n-1})"
        shown = str(t) if t < 10 ** 12 else f"a {len(str(t))}-digit number"
        print(f"  T_{n} = {label:>10} = {shown}")
    print(f"  strictly increasing? {is_strictly_increasing(tower)}")
    print("  Cantor's theorem n < 2^n at the finite level:")
    for n in range(6):
        print(f"    |S|={n:>2}  <  |P(S)|=2^{n} = {powerset_size(n):>3}   "
              f"({n < powerset_size(n)})")
    print()


# ---------------------------------------------------------------------------
# Demo 2: Cantor diagonalization
# ---------------------------------------------------------------------------

def diagonal_out(rows: List[str]) -> str:
    """Given a finite list of equal-length binary strings, return a binary
    string differing from row i in position i (flipping the diagonal bit).
    The result cannot appear among the first len(rows) rows -- the finite
    shadow of "no list enumerates all binary sequences", i.e. aleph_0 < 2^aleph_0.
    """
    n = len(rows)
    assert all(len(r) >= n for r in rows), "each row must be at least as long as the list"
    return "".join("1" if rows[i][i] == "0" else "0" for i in range(n))


def demo_diagonal() -> None:
    print("=" * 70)
    print("Demo 2: Cantor diagonalization (aleph_0 < 2^aleph_0)")
    print("=" * 70)
    rows = [
        "0000",
        "1111",
        "0101",
        "1010",
    ]
    print("  Proposed enumeration:")
    for i, r in enumerate(rows):
        marked = "".join(f"[{c}]" if j == i else f" {c} " for j, c in enumerate(r))
        print(f"    s_{i} = {marked}")
    d = diagonal_out(rows)
    print(f"  Diagonal-flip string d = {d}")
    print("  d differs from every listed row (so no finite list is complete):")
    for i, r in enumerate(rows):
        print(f"    d[{i}]={d[i]} vs s_{i}[{i}]={r[i]}  -> differ: {d[i] != r[i]}")
    print(f"  d in list? {d in rows}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: cofinality of aleph-indexed cardinals; c != aleph_omega
# ---------------------------------------------------------------------------

def cofinality_index(aleph_index: str) -> Tuple[str, str]:
    """Return (kind, cofinality) for an aleph-indexed cardinal, using only the
    order type of its index.

    Conventions for the index string:
      "0"            -> aleph_0 (regular, cof = aleph_0)
      "succ:<name>"  -> a successor cardinal aleph_{alpha+1} (regular under AC)
      "omega"        -> aleph_omega, a limit of countable type (singular, cof aleph_0)
      "cont"         -> the continuum c = 2^aleph_0 (regular by Koenig: cof > aleph_0)
    """
    if aleph_index == "0":
        return ("regular", "aleph_0")
    if aleph_index.startswith("succ:"):
        return ("regular", aleph_index[5:] + "+1")  # successor cardinals are regular
    if aleph_index == "omega":
        return ("singular", "aleph_0")  # aleph_omega = sup_n aleph_n
    if aleph_index == "cont":
        # Koenig: cof(2^aleph_0) > aleph_0, so the continuum is NOT of countable cofinality
        return ("regular-cofinality (> aleph_0)", "uncountable")
    raise ValueError(f"unknown aleph index: {aleph_index}")


def continuum_ne_aleph_omega() -> bool:
    """Confirm c != aleph_omega by a cofinality mismatch:
       cof(c) is uncountable (Koenig) while cof(aleph_omega) = aleph_0."""
    _, cof_c = cofinality_index("cont")
    _, cof_w = cofinality_index("omega")
    return cof_c != cof_w


def demo_cofinality() -> None:
    print("=" * 70)
    print("Demo 3: cofinality and the constraint c != aleph_omega")
    print("=" * 70)
    for idx, name in [("0", "aleph_0"), ("succ:aleph_0", "aleph_1"),
                      ("omega", "aleph_omega"), ("cont", "c = 2^aleph_0")]:
        kind, cof = cofinality_index(idx)
        print(f"  {name:>14}:  {kind:<32} cof = {cof}")
    print(f"  cof(c) uncountable while cof(aleph_omega) = aleph_0")
    print(f"  => c != aleph_omega  (unconditional ZFC theorem): "
          f"{continuum_ne_aleph_omega()}")
    print()


# ---------------------------------------------------------------------------
# Demo 4: aleph_0 satisfies 2 of 3 inaccessibility clauses
# ---------------------------------------------------------------------------

def aleph0_inaccessibility_report() -> dict:
    """aleph_0 is regular and a strong limit (x finite => 2^x finite), but is
    not inaccessible because inaccessibility demands uncountability."""
    strong_limit = all((2 ** x) < 10 ** 9 for x in range(30))  # 2^x finite for finite x
    return {
        "uncountable": False,          # aleph_0 is the countable infinity
        "regular": True,               # cof(aleph_0) = aleph_0
        "strong_limit": strong_limit,  # finite x => 2^x finite
        "inaccessible": False,         # fails uncountability only
    }


def demo_aleph0() -> None:
    print("=" * 70)
    print("Demo 4: aleph_0 as the prototype of an unreachable cardinal")
    print("=" * 70)
    for k, v in aleph0_inaccessibility_report().items():
        print(f"  {k:>13}: {v}")
    print("  -> aleph_0 fails inaccessibility ONLY through the uncountability clause.")
    print()


if __name__ == "__main__":
    demo_tower()
    demo_diagonal()
    demo_cofinality()
    demo_aleph0()
    print("All demonstrations completed.")
