"""
Numerical demonstrations for:

    The Structural Mathematics of Strange Loops:
    Fixed Points, Loop Length, and the Limits of Self-Modeling

This self-contained script illustrates the three pillars of the theory:

  1. Lawvere's fixed-point theorem: a complete (point-surjective) self-model
     f : A -> (A -> B) forces every transformation g : B -> B to have a fixed
     point. We construct that fixed point explicitly from the diagonal.

  2. The negative face (Cantor / Turing / liar): the self-negating behaviour
     d(x) = not f(x)(x) is never a row of any boolean self-model, so no boolean
     self-model can be complete.

  3. Loop length: in an asymmetric ("oriented") hierarchy, no closed loop of
     length 1 or 2 exists, but rock-paper-scissors gives a loop of length 3.
     Transitive (strict-order) hierarchies have no loops at all.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem: construct the forced fixed point
# ---------------------------------------------------------------------------

def lawvere_fixed_point(
    codes: Sequence[int],
    values: Sequence[object],
    f: Callable[[int, int], object],
    g: Callable[[object], object],
) -> Tuple[int, object]:
    """Given a point-surjective self-model f : A -> (A -> B) (with f(a)(x) =
    f(a, x)) and a transformation g : B -> B, return a code `a` and value `b`
    such that b = f(a)(a) and g(b) = b, following Lawvere's proof.

    The diagonal behaviour is  d(x) = g(f(x)(x)).  Point-surjectivity means
    some code `a` names d, i.e. f(a, x) == d(x) for all x.  Then
    b = f(a)(a) = d(a) = g(f(a)(a)) = g(b), a fixed point of g.
    """
    def diagonal(x: int) -> object:
        return g(f(x, x))

    for a in codes:
        if all(f(a, x) == diagonal(x) for x in codes):
            b = f(a, a)
            assert g(b) == b, "Lawvere fixed point failed to be fixed"
            return a, b
    raise ValueError("self-model is not point-surjective for this diagonal")


def demo_lawvere() -> None:
    """A complete boolean-valued self-model is impossible for negation, but a
    complete self-model into a *cyclic* value space forces a fixed point of any
    endomap that has one.  Here we use B = {0,1,2} and a g with a fixed point.
    """
    print("=" * 70)
    print("1. Lawvere's fixed-point theorem")
    print("=" * 70)

    codes: List[int] = [0, 1, 2]
    values: List[int] = [0, 1, 2]

    # Build a point-surjective self-model f : A -> (A -> B).  With |A| = 3 and
    # |B| = 3 there are 3^3 = 27 behaviours; we cannot surject onto all of them
    # with only 3 codes, so instead we demonstrate the CONSTRUCTIVE core: for a
    # chosen g, we hand-build f so that the diagonal behaviour d is one of its
    # rows, exactly as Lawvere's proof requires.
    g: Callable[[int], int] = lambda b: (b * b) % 3  # fixed points: 0 and 1

    # Make f's row 0 equal to the diagonal d(x) = g(f(x)(x)).  We solve this by
    # picking f(1,*) and f(2,*) freely, then setting f(0,x) = g(f(x,x)).
    table: Dict[Tuple[int, int], int] = {}
    for x in codes:
        table[(1, x)] = (x + 1) % 3
        table[(2, x)] = (2 * x) % 3
    # f(x,x) for x=1,2 now determined; set row 0 to the diagonal.
    for x in codes:
        fx_x = table[(x, x)] if x != 0 else None
        if x == 0:
            continue
        table[(0, x)] = g(table[(x, x)])
    # close the diagonal at 0: f(0,0) must equal g(f(0,0)); pick a g-fixed point.
    table[(0, 0)] = 0  # 0 is a fixed point of g

    def f(a: int, x: int) -> int:
        return table[(a, x)]

    a, b = lawvere_fixed_point(codes, values, f, g)
    print(f"  value space B = {values}, g(b) = b*b mod 3 (fixed points 0, 1)")
    print(f"  code a naming the diagonal behaviour: a = {a}")
    print(f"  forced fixed point b = f(a)(a) = {b},  check g(b) = {g(b)}")
    print()


# ---------------------------------------------------------------------------
# 2. The negative face: the self-negating diagonal is never representable
# ---------------------------------------------------------------------------

def self_negating_row(f: Callable[[int, int], bool], codes: Sequence[int]) -> List[bool]:
    """The behaviour d(x) = not f(x)(x)."""
    return [not f(x, x) for x in codes]


def diagonal_is_unrepresentable(
    f: Callable[[int, int], bool], codes: Sequence[int]
) -> bool:
    """Verify that d(x) = not f(x)(x) equals no row f(a, .) of the self-model."""
    d = self_negating_row(f, codes)
    for a in codes:
        row = [f(a, x) for x in codes]
        if row == d:
            return False  # would contradict Theorem 3.9 / 5.6
    return True


def demo_diagonal() -> None:
    """Exhaustively confirm that for EVERY boolean self-model on n codes, the
    self-negating diagonal is missing -- i.e. no boolean self-model is complete.
    """
    print("=" * 70)
    print("2. The self-negating diagonal is never a row (Cantor / Turing / liar)")
    print("=" * 70)
    for n in (1, 2, 3):
        codes = list(range(n))
        total = 0
        all_ok = True
        # enumerate all functions f : A x A -> Bool
        for bits in product([False, True], repeat=n * n):
            grid = {(a, x): bits[a * n + x] for a in codes for x in codes}
            f = lambda a, x, _grid=grid: _grid[(a, x)]
            total += 1
            if not diagonal_is_unrepresentable(f, codes):
                all_ok = False
                break
        print(f"  n = {n}: checked all {total} boolean self-models -> "
              f"diagonal always missing: {all_ok}")
    print("  Conclusion: no boolean self-model is point-surjective (complete).")
    print()


# ---------------------------------------------------------------------------
# 3. Loop length: minimum genuine strange loop has length 3
# ---------------------------------------------------------------------------

def is_asymmetric(vertices: Sequence[int], R: Callable[[int, int], bool]) -> bool:
    """R(a,b) implies not R(b,a) for all a, b."""
    return all(not (R(a, b) and R(b, a)) for a in vertices for b in vertices)


def is_transitive(vertices: Sequence[int], R: Callable[[int, int], bool]) -> bool:
    return all(
        (not (R(a, b) and R(b, c))) or R(a, c)
        for a in vertices for b in vertices for c in vertices
    )


def shortest_loop_length(
    vertices: Sequence[int], R: Callable[[int, int], bool], max_len: int = 6
) -> Optional[int]:
    """Smallest n >= 1 for which a closed R-loop v(0)->v(1)->...->v(0) of length
    n exists (vertices may repeat; consecutive pairs, and last->first, related).
    """
    for n in range(1, max_len + 1):
        for seq in product(vertices, repeat=n):
            if all(R(seq[i], seq[(i + 1) % n]) for i in range(n)):
                return n
    return None


def demo_loop_length() -> None:
    print("=" * 70)
    print("3. Minimum strange-loop length is 3")
    print("=" * 70)

    # rock-paper-scissors: successor relation on Z/3Z
    v3 = [0, 1, 2]
    rps: Callable[[int, int], bool] = lambda a, b: b == (a + 1) % 3
    print(f"  rock-paper-scissors on Z/3Z: asymmetric = {is_asymmetric(v3, rps)}, "
          f"transitive = {is_transitive(v3, rps)}")
    print(f"    shortest loop length = {shortest_loop_length(v3, rps)}  (expected 3)")

    # successor on Z/n Z for n = 3..6 : always asymmetric, shortest loop = n
    print("  successor relation on Z/nZ (b = a+1):")
    for n in range(3, 7):
        vn = list(range(n))
        Rn = lambda a, b, _n=n: b == (a + 1) % _n
        print(f"    n = {n}: asymmetric = {is_asymmetric(vn, Rn)}, "
              f"shortest loop = {shortest_loop_length(vn, Rn, max_len=n + 1)}")

    # a strict total order has no loop at all
    lt: Callable[[int, int], bool] = lambda a, b: a < b
    print(f"  strict order '<' on {{0,1,2,3}}: transitive = "
          f"{is_transitive([0,1,2,3], lt)}, "
          f"shortest loop = {shortest_loop_length([0,1,2,3], lt)}  (None = no loop)")
    print()


# ---------------------------------------------------------------------------
# 4. The consciousness dichotomy summarized numerically
# ---------------------------------------------------------------------------

def demo_dichotomy() -> None:
    print("=" * 70)
    print("4. Strange-loop dichotomy (boolean observations)")
    print("=" * 70)
    print("  (i)  IF a boolean self-model were complete, negation would have a")
    print("       fixed point b with (not b) = b.")
    print(f"       fixed points of boolean negation: "
          f"{[b for b in (False, True) if (not b) == b]}  (none!)")
    print("  (ii) Therefore no boolean self-model is complete (conscious).")
    print("  The same diagonal both forces the 'I' and forbids complete self-survey.")
    print()


def main() -> None:
    demo_lawvere()
    demo_diagonal()
    demo_loop_length()
    demo_dichotomy()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
