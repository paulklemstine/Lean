"""Numerical demonstrations for the diagonal core of self-reference.

This self-contained script illustrates the results of
"Self-Quantifying Types and the Diagonal Core of Self-Reference":

  1. Lawvere's fixed-point theorem: a point-surjective family A -> (A -> B)
     forces every self-map of B to have a fixed point (and the diagonal
     construction locates that fixed point).
  2. Cantor / no self-quantifying surjection: for finite T, no map
     T -> (T -> Bool) is surjective; the diagonal predicate d(x) = not f(x)(x)
     is always missed.
  3. The strict cardinal gap  |T| < |T -> Prop| = 2^|T|.
  4. An abstract self-referential system in which the Goedel sentence is true
     but unprovable, while "not true" is not definable (Tarski).

Every function is inlined; run `python demo.py`.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem (finite illustration)
# ---------------------------------------------------------------------------
def lawvere_find_fixed_point(
    A: List[int],
    B: List[int],
    f: Callable[[int], Callable[[int], int]],
    g: Callable[[int], int],
) -> Optional[Tuple[int, int]]:
    """If ``f : A -> (A -> B)`` is point-surjective, return ``(a, b)`` with
    ``b = f(a)(a)`` a fixed point of ``g``, found via the diagonal
    construction ``h(x) = g(f(x)(x))``. Returns ``None`` if the diagonal
    function is genuinely missing from the family (so f is not surjective)."""
    # The diagonal function whose existence in the family forces a fixed point.
    def diagonal(x: int) -> int:
        return g(f(x)(x))

    for a in A:
        if all(f(a)(x) == diagonal(x) for x in A):
            b = f(a)(a)
            assert g(b) == b, "Lawvere diagonal did not yield a fixed point!"
            return a, b
    return None


def demo_lawvere() -> None:
    print("=" * 70)
    print("1. Lawvere's fixed-point theorem")
    print("=" * 70)
    # For Lawvere we need f : A -> (A -> B) with A the *same* index and domain
    # set. A finite A can be point-surjective onto (A -> B) only when every
    # self-map of B has a fixed point (that is the theorem). We take B = {0,1}
    # and g(b) = 0 for all b, whose unique fixed point is 0; then the Lawvere
    # diagonal h(x) = g(f(x)(x)) is the constant-0 row, so any family that
    # contains it yields the fixed point.
    A = [0, 1, 2]
    B = [0, 1]
    g = lambda b: 0  # self-map of B with fixed point 0
    # A family whose row 0 is the constant-0 function (= the diagonal here).
    rows = {0: [0, 0, 0], 1: [1, 0, 1], 2: [0, 1, 1]}
    f = lambda a: (lambda x: rows[a][x])
    res = lawvere_find_fixed_point(A, B, f, g)
    print(f"  value space B = {B}, self-map g(b) = 0 has fixed point 0")
    print(f"  Lawvere diagonal located (index a, fixed point b) = {res}")
    print(f"  check: g(b) == b  ->  {g(res[1]) == res[1]}\n")


# ---------------------------------------------------------------------------
# 2. Cantor: no finite family surjects onto its predicate space
# ---------------------------------------------------------------------------
def cantor_missing_predicate(
    T: List[int], f: Callable[[int], Callable[[int], bool]]
) -> Callable[[int], bool]:
    """Return the diagonal predicate d(x) = not f(x)(x), which differs from
    every row f(a) at the point a, proving f is not surjective."""
    return lambda x: not f(x)(x)


def demo_cantor() -> None:
    print("=" * 70)
    print("2. Cantor: no type surjects onto its own predicates")
    print("=" * 70)
    T = [0, 1, 2]
    # An arbitrary candidate family f : T -> (T -> Bool).
    table = {0: [True, False, True], 1: [False, False, True], 2: [True, True, False]}
    f = lambda a: (lambda x: table[a][x])
    d = cantor_missing_predicate(T, f)
    d_vals = [d(x) for x in T]
    print(f"  candidate family rows: {[table[a] for a in T]}")
    print(f"  diagonal predicate d  : {d_vals}")
    for a in T:
        assert d(a) != f(a)(a)
    print("  d differs from every row f(a) at point a  ->  f is NOT surjective\n")


# ---------------------------------------------------------------------------
# 3. The strict cardinal gap  |T| < 2^|T|
# ---------------------------------------------------------------------------
def demo_cardinal_gap() -> None:
    print("=" * 70)
    print("3. Strict cardinal gap  |T| < |T -> Prop| = 2^|T|")
    print("=" * 70)
    for n in range(0, 8):
        pred_space = 2 ** n
        assert n < pred_space
        print(f"  |T| = {n:2d}   |T -> Prop| = 2^{n} = {pred_space:3d}   gap holds: {n < pred_space}")
    print()


# ---------------------------------------------------------------------------
# 4. Self-referential system: Goedel true-but-unprovable, Tarski undefinable
# ---------------------------------------------------------------------------
class SelfRefSystem:
    """A concrete finite self-referential system (the paper's example model).

    Sentences are booleans; Tr(b) = (b is True); nothing is provable;
    a predicate phi is Definable iff phi(True); the diagonal always returns
    True. This satisfies soundness, the restricted diagonal fixed-point
    property, and representability of negated provability.
    """

    def __init__(self) -> None:
        self.sentences: List[bool] = [False, True]

    def Tr(self, b: bool) -> bool:
        return b is True

    def Pr(self, b: bool) -> bool:
        return False

    def sound(self) -> bool:
        return all((not self.Pr(s)) or self.Tr(s) for s in self.sentences)

    def definable(self, phi: Callable[[bool], bool]) -> bool:
        return phi(True)

    def diag(self, phi: Callable[[bool], bool]) -> bool:
        return True

    def diag_spec_holds(self, phi: Callable[[bool], bool]) -> bool:
        """Restricted fixed-point property for definable phi."""
        if not self.definable(phi):
            return True  # vacuous
        d = self.diag(phi)
        return self.Tr(d) == phi(d)

    def goedel(self) -> bool:
        return self.diag(lambda s: not self.Pr(s))


def demo_selfref() -> None:
    print("=" * 70)
    print("4. Self-referential system: Goedel and Tarski")
    print("=" * 70)
    M = SelfRefSystem()
    print(f"  soundness holds                       : {M.sound()}")
    negPr = lambda s: not M.Pr(s)
    print(f"  negated provability definable         : {M.definable(negPr)}")
    print(f"  diagonal fixed-point on negPr holds   : {M.diag_spec_holds(negPr)}")
    G = M.goedel()
    goedel_true = M.Tr(G)
    goedel_unprovable = not M.Pr(G)
    print(f"  Goedel sentence G is true             : {goedel_true}")
    print(f"  Goedel sentence G is unprovable       : {goedel_unprovable}")
    print(f"  => true but unprovable                : {goedel_true and goedel_unprovable}")
    # Tarski: "not true" would need Tr(diag) == not Tr(diag): impossible.
    negTr = lambda s: not M.Tr(s)
    # Were negTr definable, the fixed point would satisfy a contradiction:
    would_contradict = (M.Tr(M.diag(negTr)) == (not M.Tr(M.diag(negTr))))
    print(f"  'not true' definable would force Tr==!Tr (impossible): {would_contradict}")
    print("  => 'not true' is NOT definable (Tarski)\n")


if __name__ == "__main__":
    demo_lawvere()
    demo_cantor()
    demo_cardinal_gap()
    demo_selfref()
    print("All demonstrations completed successfully.")
