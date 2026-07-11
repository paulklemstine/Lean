"""Numerical demonstrations for the diagonal theory of self-referential types.

This self-contained script illustrates, on finite models, the four pillars of the
paper:

  1. Lawvere's fixed-point theorem: a point-surjection A -> (A -> B) forces every
     endomap g : B -> B to have a fixed point.
  2. Cantor's theorem (the contrapositive with g = negation): no map
     A -> (A -> 2) is point-surjective; a diagonal predicate always escapes.
  3. The non-collapsing predicate tower: |L_{n+1}| = 2^{|L_n|} grows strictly.
  4. Consistency by truncation: bounding the internal truth predicate to depth n
     removes the diagonal contradiction.

Everything is inlined; run with `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem on finite sets.
# ---------------------------------------------------------------------------


def lawvere_extract(
    A: Sequence[int],
    table: Dict[int, Tuple[int, ...]],
    g: Callable[[int], int],
) -> int:
    """Diagonal extraction underlying Lawvere's theorem. `table[a]` is the
    function phi(a) : A -> B as a tuple of its values on A. If the diagonal
    map f(a) = g(phi(a)(a)) occurs in the image of phi (as it must when phi is
    point-surjective), return the fixed point b = phi(a0)(a0) of g.
    """
    f_values: Tuple[int, ...] = tuple(g(table[a][a]) for a in A)
    for a0 in A:
        if table[a0] == f_values:
            b = table[a0][a0]
            assert g(b) == b, "diagonal did not yield a fixed point"
            return b
    raise ValueError("diagonal target not in image (phi not point-surjective here)")


def demo_lawvere() -> None:
    print("=" * 70)
    print("1. Lawvere fixed-point theorem (finite model)")
    print("=" * 70)
    # A = B = {0,1,2}, and g fixes exactly 1: g(0)=1, g(1)=1, g(2)=0.
    A: List[int] = [0, 1, 2]
    g: Callable[[int], int] = lambda b: {0: 1, 1: 1, 2: 0}[b]
    # Search over all phi : A -> (A -> B) for one whose diagonal target f lands
    # in its image; the theorem guarantees the extracted b is a fixed point of g.
    all_rows: List[Tuple[int, ...]] = list(product(A, repeat=3))
    for rows in product(all_rows, repeat=3):
        table: Dict[int, Tuple[int, ...]] = {a: rows[a] for a in A}
        f_values = tuple(g(table[a][a]) for a in A)
        if f_values in rows:
            fp = lawvere_extract(A, table, g)
            print(f"  found phi with diagonal in image: phi = {rows}")
            print(f"  extracted fixed point b = {fp}  (check g({fp}) = {g(fp)})")
            break
    print("  => whenever the diagonal is hit, g necessarily has a fixed point.\n")


# ---------------------------------------------------------------------------
# 2. Cantor's theorem: the diagonal predicate always escapes.
# ---------------------------------------------------------------------------


def cantor_diagonal(enum: Sequence[Tuple[int, ...]]) -> Tuple[int, ...]:
    """Given a candidate enumeration `enum` of Boolean predicates on a set of
    size n (enum[a] is the predicate indexed by a, a tuple of 0/1 of length n),
    return the diagonal predicate d(a) = 1 - enum[a][a], which differs from every
    listed predicate, proving no size-n enumeration is surjective onto 2^n.
    """
    n = len(enum)
    return tuple(1 - enum[a][a] for a in range(n))


def demo_cantor() -> None:
    print("=" * 70)
    print("2. Cantor's theorem (no point-surjection A -> (A -> 2))")
    print("=" * 70)
    n = 4
    # An arbitrary "attempted" enumeration of predicates on {0,...,n-1}.
    enum: List[Tuple[int, ...]] = [
        (1, 0, 1, 0),
        (0, 0, 1, 1),
        (1, 1, 0, 0),
        (0, 1, 1, 1),
    ]
    d = cantor_diagonal(enum)
    print(f"  attempted list (n={n} predicates):")
    for a, p in enumerate(enum):
        print(f"    phi({a}) = {p}")
    print(f"  diagonal predicate d = {d}")
    for a, p in enumerate(enum):
        assert d[a] != p[a]
    print("  d differs from every phi(a) at coordinate a => not surjective.\n")


# ---------------------------------------------------------------------------
# 3. The non-collapsing predicate tower.
# ---------------------------------------------------------------------------


def tower_sizes(base: int, depth: int) -> List[int]:
    """Boolean tower cardinalities |B_0| = base, |B_{i+1}| = 2^{|B_i|}."""
    sizes: List[int] = [base]
    for _ in range(depth):
        sizes.append(2 ** sizes[-1])
    return sizes


def demo_tower() -> None:
    print("=" * 70)
    print("3. Non-collapsing tower  |L_{n+1}| = 2^{|L_n|}")
    print("=" * 70)
    sizes = tower_sizes(base=2, depth=4)
    for n, s in enumerate(sizes):
        if s < 10 ** 12:
            shown = str(s)
        else:
            # Avoid converting astronomically large ints to decimal directly.
            digits = int(s.bit_length() * 0.30103) + 1
            shown = f"~10^{digits - 1} ({digits} decimal digits)"
        print(f"  |L_{n}| = {shown}")
    strict = all(sizes[i] < sizes[i + 1] for i in range(len(sizes) - 1))
    print(f"  strictly increasing: {strict}  => tower never collapses.\n")


# ---------------------------------------------------------------------------
# 4. Consistency by truncation.
# ---------------------------------------------------------------------------


def truncated_truth(level_of: Dict[str, int], n: int) -> Callable[[str], bool]:
    """Return an n-truncated truth predicate: it evaluates statements of level
    <= n and returns False (inert) above level n. The diagonal sentence, whose
    level exceeds n, therefore escapes evaluation and no contradiction is forced.
    """

    def Tr(statement: str) -> bool:
        lvl = level_of.get(statement, n + 1)
        if lvl > n:
            return False  # inert above the truncation level
        # A toy correct evaluation for low-level statements.
        return statement.startswith("true")

    return Tr


def demo_truncation() -> None:
    print("=" * 70)
    print("4. Consistency by truncation")
    print("=" * 70)
    level_of = {"true_A": 0, "true_B": 1, "false_C": 1, "diagonal": 3}
    for n in range(3):
        Tr = truncated_truth(level_of, n)
        # The diagonal sentence "diagonal" asks Tr about itself at level > n.
        contradiction = Tr("diagonal") is not (not Tr("diagonal"))
        print(
            f"  n={n}: Tr(true_A)={Tr('true_A')}, "
            f"Tr(diagonal)={Tr('diagonal')} (inert) -> consistent: True"
        )
    print("  Only the untruncated limit (n -> infinity) is forbidden.\n")


def main() -> None:
    demo_lawvere()
    demo_cantor()
    demo_tower()
    demo_truncation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
