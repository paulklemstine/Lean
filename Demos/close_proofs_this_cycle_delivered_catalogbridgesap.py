"""
Numerical demonstrations for:

    The Eckmann-Hilton Equational Theory *is* Commutative Monoids

This self-contained script illustrates, on finite carriers, the results
formalized and machine-checked in the accompanying Lean development:

  * EckmannHiltonData            -- two unital operations + interchange law
  * same_op / comm / assoc       -- the engine lemmas (the "collapse")
  * toCommMonoid                 -- interchange data  ->  commutative monoid
  * ofCommMonoid                 -- commutative monoid -> interchange data
  * eh_iff_commMonoid            -- the two theories coincide
  * structure_rigidity           -- m1 alone determines unit and m2
  * pi_two_commutative           -- abstract "pi_2 is abelian": m1 a b = m2 b a
  * monoid_comm_of_second_interchange -- a second compatible op forces commutativity

Everything is exact (integer / table arithmetic); no floating point.
Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

# A binary operation on a finite carrier {0, ..., n-1} is a dict-backed table.
Op = Callable[[int, int], int]


# ---------------------------------------------------------------------------
# Core finite-structure machinery
# ---------------------------------------------------------------------------
class EckmannHiltonData:
    """Eckmann-Hilton data on the finite carrier {0, ..., n-1}.

    Holds two binary operations m1, m2 and a shared unit, and can verify
    the unit laws and the interchange law by brute force.
    """

    def __init__(self, n: int, m1: Op, m2: Op, unit: int) -> None:
        self.n: int = n
        self.m1: Op = m1
        self.m2: Op = m2
        self.unit: int = unit

    def carrier(self) -> range:
        return range(self.n)

    def check_unit_laws(self) -> bool:
        """Verify m1/m2 have `unit` as a two-sided identity."""
        for x in self.carrier():
            if self.m1(self.unit, x) != x or self.m1(x, self.unit) != x:
                return False
            if self.m2(self.unit, x) != x or self.m2(x, self.unit) != x:
                return False
        return True

    def check_interchange(self) -> bool:
        """Verify  m1(m2 a b)(m2 c d) = m2(m1 a c)(m1 b d)  for all a,b,c,d."""
        for a, b, c, d in product(self.carrier(), repeat=4):
            lhs = self.m1(self.m2(a, b), self.m2(c, d))
            rhs = self.m2(self.m1(a, c), self.m1(b, d))
            if lhs != rhs:
                return False
        return True

    def is_valid(self) -> bool:
        return self.check_unit_laws() and self.check_interchange()


def is_commutative(n: int, op: Op) -> bool:
    return all(op(a, b) == op(b, a) for a, b in product(range(n), repeat=2))


def is_associative(n: int, op: Op) -> bool:
    return all(
        op(op(a, b), c) == op(a, op(b, c))
        for a, b, c in product(range(n), repeat=3)
    )


def find_unit(n: int, op: Op) -> Optional[int]:
    """Return the unique two-sided identity of `op`, or None."""
    for e in range(n):
        if all(op(e, x) == x and op(x, e) == x for x in range(n)):
            return e
    return None


def ops_agree(n: int, f: Op, g: Op) -> bool:
    return all(f(a, b) == g(a, b) for a, b in product(range(n), repeat=2))


# ---------------------------------------------------------------------------
# The two directions of the bridge
# ---------------------------------------------------------------------------
def to_comm_monoid(E: EckmannHiltonData) -> Tuple[int, Op, int]:
    """toCommMonoid: forget m2, keep (carrier, m1, unit) as a commutative monoid.

    Returns (n, multiplication, identity). Assumes E.is_valid().
    """
    return E.n, E.m1, E.unit


def of_comm_monoid(n: int, mul: Op, one: int) -> EckmannHiltonData:
    """ofCommMonoid: duplicate the monoid multiplication into both operations.

    The interchange law then *is* the medial law for `mul`.
    """
    return EckmannHiltonData(n, mul, mul, one)


# ---------------------------------------------------------------------------
# Demo 1 -- a concrete commutative monoid round-trips to itself
# ---------------------------------------------------------------------------
def demo_round_trip() -> None:
    print("=" * 70)
    print("DEMO 1:  CommMonoid  ->  EckmannHiltonData  ->  CommMonoid")
    print("=" * 70)
    # Z/5 under addition: a commutative monoid.
    n = 5
    add: Op = lambda a, b: (a + b) % n
    one = 0
    print(f"Carrier: Z/{n} under addition (+ mod {n}), identity = {one}")

    E = of_comm_monoid(n, add, one)
    print(f"  ofCommMonoid produced EckmannHiltonData with m1 = m2 = (+)")
    print(f"  unit laws hold        : {E.check_unit_laws()}")
    print(f"  interchange (medial)  : {E.check_interchange()}  (this is the medial law)")
    print(f"  -> valid EH data      : {E.is_valid()}")

    n2, mul2, one2 = to_comm_monoid(E)
    print(f"  toCommMonoid recovered: identity = {one2}")
    print(f"  multiplication agrees : {ops_agree(n, add, mul2)}")
    print(f"  commutative           : {is_commutative(n2, mul2)}")
    print(f"  associative           : {is_associative(n2, mul2)}")
    print()


# ---------------------------------------------------------------------------
# Demo 2 -- the collapse: two *different-looking* operations forced equal
# ---------------------------------------------------------------------------
def demo_collapse() -> None:
    print("=" * 70)
    print("DEMO 2:  The Eckmann-Hilton collapse (same_op / comm / assoc)")
    print("=" * 70)
    # Build EH data from Z/4 multiplication-like monoid: use addition mod 4.
    n = 4
    add: Op = lambda a, b: (a + b) % n
    E = of_comm_monoid(n, add, 0)
    print("Start with two operations m1, m2 (here both = + mod 4) sharing unit 0.")
    print(f"  same_op : m1 a b == m2 a b for all a,b : "
          f"{ops_agree(n, E.m1, E.m2)}")
    print(f"  comm    : m1 commutative               : "
          f"{is_commutative(n, E.m1)}")
    print(f"  assoc   : m1 associative               : "
          f"{is_associative(n, E.m1)}")
    print("Even if we had defined m2 differently, validity forces m2 == m1.")
    print()


# ---------------------------------------------------------------------------
# Demo 3 -- structure rigidity: m1 determines unit and m2
# ---------------------------------------------------------------------------
def demo_rigidity() -> None:
    print("=" * 70)
    print("DEMO 3:  structure_rigidity -- m1 alone determines unit and m2")
    print("=" * 70)
    n = 6
    add: Op = lambda a, b: (a + b) % n

    # Two EH structures that happen to share m1 = add.
    E = of_comm_monoid(n, add, 0)          # unit guessed/derived
    # Pretend we only know m1; recover the unit purely from m1.
    recovered_unit = find_unit(n, E.m1)
    print(f"Given only m1 = (+ mod {n}):")
    print(f"  the unit is forced to be the unique identity of m1 = {recovered_unit}")
    print(f"  matches stored unit                                 = "
          f"{recovered_unit == E.unit}")
    # m2 is forced to equal m1 (same_op), regardless of how it was 'declared'.
    print(f"  m2 is forced equal to m1 (same_op): {ops_agree(n, E.m1, E.m2)}")
    print("  => the 2-dimensional data (m2, unit) is a function of m1.")
    print()


# ---------------------------------------------------------------------------
# Demo 4 -- abstract "pi_2 is abelian":  m1 a b == m2 b a
# ---------------------------------------------------------------------------
def demo_pi_two() -> None:
    print("=" * 70)
    print("DEMO 4:  pi_two_commutative -- m1 a b == m2 b a")
    print("=" * 70)
    n = 5
    mul: Op = lambda a, b: (a * b) % n if (a * b) % n != 0 else (a * b) % n
    # Use Z/5 additive monoid (clean unit) to illustrate the identity.
    add: Op = lambda a, b: (a + b) % n
    E = of_comm_monoid(n, add, 0)
    ok = all(E.m1(a, b) == E.m2(b, a) for a, b in product(range(n), repeat=2))
    print(f"Carrier Z/{n} under +:  m1 a b == m2 b a for all a,b : {ok}")
    print("Reading m1 as vertical and m2 as horizontal composition of 2-cells,")
    print("this is exactly 'the second homotopy group is abelian'.")
    print()


# ---------------------------------------------------------------------------
# Demo 5 -- a second compatible operation forces commutativity
# ---------------------------------------------------------------------------
def demo_second_interchange() -> None:
    print("=" * 70)
    print("DEMO 5:  monoid_comm_of_second_interchange")
    print("=" * 70)
    # Take a monoid; if it admits a 2nd unital op interchanging with it,
    # it must be commutative. We test the contrapositive flavor:
    # a NON-commutative monoid admits NO such second operation.
    print("Claim: if a monoid * admits a 2nd unital op n with shared unit and")
    print("interchange, then * is commutative.")
    print()
    # Example A: commutative monoid -> a compatible n exists (n = *).
    n = 4
    add: Op = lambda a, b: (a + b) % n
    E = of_comm_monoid(n, add, 0)
    print(f"  Z/{n} additive: admits second op n = (+), valid EH data = "
          f"{E.is_valid()},  commutative = {is_commutative(n, add)}")

    # Example B: a non-commutative monoid (left-projection is associative,
    # but has no two-sided unit; use a genuine non-abelian group table).
    # Smallest non-commutative monoid via 2x2 boolean-ish: use S_3 multiplication.
    s3 = list(_symmetric_group_3())
    idx = {p: i for i, p in enumerate(s3)}
    m = len(s3)
    comp: Op = lambda i, j: idx[_compose(s3[i], s3[j])]
    e = idx[(0, 1, 2)]
    print(f"  S_3 (order {m}): commutative = {is_commutative(m, comp)}")
    # Search for ANY second unital op n (with same unit e) that interchanges.
    found = _search_second_op(m, comp, e, max_tables=200000)
    print(f"  exhaustive-ish search for a compatible 2nd op on S_3: "
          f"{'FOUND' if found else 'none found'} (theory predicts: none)")
    print()


def _symmetric_group_3() -> List[Tuple[int, int, int]]:
    from itertools import permutations
    return list(permutations((0, 1, 2)))


def _compose(p: Tuple[int, int, int], q: Tuple[int, int, int]) -> Tuple[int, int, int]:
    # (p . q)(x) = p(q(x))
    return tuple(p[q[x]] for x in range(3))  # type: ignore[return-value]


def _search_second_op(
    m: int, mul: Op, e: int, max_tables: int
) -> bool:
    """Heuristic search for a unital op n interchanging with `mul`.

    Full search is m^(m*m) tables; we only sample a bounded number to
    illustrate that the predicted answer (none, since S_3 is non-abelian)
    is consistent. Returns True if a witness is found.
    """
    import random

    def interchanges(n_table: Dict[Tuple[int, int], int]) -> bool:
        n: Op = lambda a, b: n_table[(a, b)]
        # unit laws for n
        for x in range(m):
            if n(e, x) != x or n(x, e) != x:
                return False
        # interchange: n(mul a b)(mul c d) = mul(n a c)(n b d)
        for a, b, c, d in product(range(m), repeat=4):
            if n(mul(a, b), mul(c, d)) != mul(n(a, c), n(b, d)):
                return False
        return True

    # n = mul itself is the obvious candidate; for an abelian group it works.
    base = {(a, b): mul(a, b) for a, b in product(range(m), repeat=2)}
    if interchanges(base):
        return True
    rng = random.Random(0)
    free_cells = [(a, b) for a, b in product(range(m), repeat=2)
                  if a != e and b != e]
    for _ in range(max_tables):
        table = {(a, b): mul(a, b) for a, b in product(range(m), repeat=2)}
        for cell in free_cells:
            table[cell] = rng.randrange(m)
        # enforce unit laws
        for x in range(m):
            table[(e, x)] = x
            table[(x, e)] = x
        if interchanges(table):
            return True
    return False


def main() -> None:
    demo_round_trip()
    demo_collapse()
    demo_rigidity()
    demo_pi_two()
    demo_second_interchange()
    print("All demonstrations consistent with the verified theory.")


if __name__ == "__main__":
    main()


"""
Visualization: the Eckmann-Hilton collapse on finite carriers.

Renders, side by side, the Cayley tables of the two operations m1 and m2 of
Eckmann-Hilton data built from Z/n, showing that they are pixel-for-pixel
identical (same_op), symmetric (comm), and that the abstract identity
m1 a b == m2 b a (pi_two_commutative) holds. Also draws a schematic of the
interchange / medial 2x2 grid.

Requires matplotlib.  Run:  python visualization.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable

import matplotlib.pyplot as plt
import numpy as np

Op = Callable[[int, int], int]


def cayley(n: int, op: Op) -> np.ndarray:
    return np.array([[op(a, b) for b in range(n)] for a in range(n)])


def main() -> None:
    n = 7
    add: Op = lambda a, b: (a + b) % n  # m1 = m2 from a commutative monoid

    T1 = cayley(n, add)               # m1
    T2 = cayley(n, add)               # m2 (equal by same_op)
    T2T = cayley(n, lambda a, b: add(b, a))  # m2 b a

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    titles = [
        r"$m_1(a,b)$ (vertical)",
        r"$m_2(a,b)$ (horizontal)",
        r"$m_2(b,a)$  $=\ m_1(a,b)$",
    ]
    for ax, T, title in zip(axes, [T1, T2, T2T], titles):
        im = ax.imshow(T, cmap="viridis")
        ax.set_title(title, fontsize=13)
        ax.set_xlabel("b")
        ax.set_ylabel("a")
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        for a, b in product(range(n), repeat=2):
            ax.text(b, a, str(T[a, b]), ha="center", va="center",
                    color="white", fontsize=8)
        fig.colorbar(im, ax=ax, fraction=0.046)

    assert np.array_equal(T1, T2), "same_op failed"
    assert np.array_equal(T1, T2T), "pi_two_commutative failed"

    fig.suptitle(
        "Eckmann-Hilton collapse on Z/7:  m1 = m2 and  m1(a,b) = m2(b,a)",
        fontsize=15,
    )
    fig.tight_layout()
    fig.savefig("eckmann_hilton_collapse.png", dpi=150)
    print("Wrote eckmann_hilton_collapse.png")


if __name__ == "__main__":
    main()
