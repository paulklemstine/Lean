"""
Dreamtime Algebra: Aboriginal Kinship Systems as Finite Groups
==============================================================

Numerical demonstrations that the four-section (Kariera-type) kinship system is
the Klein four-group Z/2 x Z/2 and the eight-subsection (Warlpiri-type) system is
(Z/2)^3, that marriage rules are coset restrictions, and that the subsection
system is a Z/2 double cover of the section system.

All arithmetic is performed with bit-vectors over Z/2 (addition is XOR).
Self-contained: run `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Tuple

Section = Tuple[int, int]           # element of Z/2 x Z/2
Subsection = Tuple[int, int, int]   # element of (Z/2)^3


# ---------------------------------------------------------------------------
# Core group arithmetic over (Z/2)^n
# ---------------------------------------------------------------------------
def add(x: Sequence[int], y: Sequence[int]) -> Tuple[int, ...]:
    """Coordinatewise addition modulo 2 (bitwise XOR)."""
    return tuple((a + b) % 2 for a, b in zip(x, y))


def translate(v: Sequence[int], elements: Sequence[Tuple[int, ...]]
              ) -> Dict[Tuple[int, ...], Tuple[int, ...]]:
    """The permutation T_v : x |-> x + v, as an explicit table."""
    return {x: add(x, v) for x in elements}


def sections() -> List[Section]:
    return [t for t in product((0, 1), repeat=2)]


def subsections() -> List[Subsection]:
    return [t for t in product((0, 1), repeat=3)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_exponent_two() -> None:
    """Every element is its own inverse: g + g = 0 (exponent 2)."""
    print("=" * 66)
    print("1. EXPONENT TWO: g + g = 0 for every section/subsection")
    print("=" * 66)
    for label, elems in (("Sec_4", sections()), ("Sub_8", subsections())):
        ok = all(add(g, g) == tuple(0 for _ in g) for g in elems)
        print(f"  {label}: g + g = 0 for all g  ->  {ok}")
    print()


def demo_named_relations() -> None:
    """mother = +(0,1), spouse = +(1,0), father = +(1,1); father = spouse+mother."""
    print("=" * 66)
    print("2. NAMED KINSHIP RELATIONS AND DESCENT CONSISTENCY")
    print("=" * 66)
    mother, spouse, father = (0, 1), (1, 0), (1, 1)
    print(f"  mother = +{mother}, spouse = +{spouse}, father = +{father}")
    print(f"  spouse + mother = {add(spouse, mother)}  (should equal father {father})")
    print(f"  Consistency father = spouse + mother: {add(spouse, mother) == father}")
    print()
    print("  Involution check (relation applied twice returns home):")
    for name, v in (("mother", mother), ("spouse", spouse), ("father", father)):
        twice = add(v, v)
        print(f"    {name}: applied twice = {twice}  involution -> {twice == (0, 0)}")
    print()


def demo_cayley_table() -> None:
    """Print the Cayley table; confirm it is Klein four (all diagonal = identity)."""
    print("=" * 66)
    print("3. CAYLEY TABLE OF THE FOUR-SECTION GROUP (Klein four-group)")
    print("=" * 66)
    elems = sections()
    names = {(0, 0): "e", (0, 1): "m", (1, 0): "s", (1, 1): "f"}
    header = "    " + "  ".join(names[e] for e in elems)
    print(header)
    for x in elems:
        row = "  ".join(names[add(x, y)] for y in elems)
        print(f"  {names[x]} {row}")
    diagonal_identity = all(add(x, x) == (0, 0) for x in elems)
    print(f"\n  All diagonal entries = e (exponent 2)  ->  {diagonal_identity}")
    print("  Not cyclic Z/4: no element has order 4.")
    print()


def element_order(g: Sequence[int]) -> int:
    """Additive order of g in (Z/2)^n."""
    zero = tuple(0 for _ in g)
    if tuple(g) == zero:
        return 1
    return 2  # every non-identity element of (Z/2)^n has order exactly 2


def demo_orders() -> None:
    """Show every non-identity element has order 2 -> group is elementary abelian."""
    print("=" * 66)
    print("4. ELEMENT ORDERS: group is NOT Z/4")
    print("=" * 66)
    for g in sections():
        print(f"  order({g}) = {element_order(g)}")
    print("  No element of order 4  ->  group is Z/2 x Z/2, not Z/4.")
    print()


def demo_marriage_cosets() -> None:
    """Marriage = coset restriction relative to matrimoiety M = ker(2nd coord)."""
    print("=" * 66)
    print("5. MARRIAGE AS A COSET RESTRICTION")
    print("=" * 66)
    elems = sections()
    M = [g for g in elems if g[1] == 0]            # matrimoiety subgroup
    coset_of = lambda g: frozenset(add(g, m) for m in M)
    cosets = sorted({coset_of(g) for g in elems}, key=lambda c: sorted(c))
    print(f"  Matrimoiety subgroup M = {sorted(M)}")
    for i, c in enumerate(cosets):
        print(f"  coset {i}: {sorted(c)}")
    print("\n  Marriage step = +(1,0). Spouse stays in the SAME coset:")
    for g in elems:
        spouse = add(g, (1, 0))
        same = coset_of(g) == coset_of(spouse)
        print(f"    {g} marries {spouse}: same coset -> {same}")
    print()


def demo_double_cover() -> None:
    """Subsections -> sections via q(a,b,c)=(a,b): surjective, kernel Z/2."""
    print("=" * 66)
    print("6. SUBSECTIONS AS A Z/2 DOUBLE COVER OF SECTIONS")
    print("=" * 66)
    q = lambda t: (t[0], t[1])
    subs = subsections()
    image = sorted({q(t) for t in subs})
    kernel = [t for t in subs if q(t) == (0, 0)]
    print(f"  q(a,b,c) = (a,b)")
    print(f"  image of q = {image}  (surjects onto all 4 sections)")
    print(f"  kernel of q = {kernel}  -> order {len(kernel)} = Z/2")
    fibers = {s: sorted(t for t in subs if q(t) == s) for s in image}
    print("  fibers (each section covered exactly twice):")
    for s, f in fibers.items():
        print(f"    {s} <- {f}  (size {len(f)})")
    print(f"  |Sub_8| / |Sec_4| = {len(subs)} / {len(image)} = {len(subs)//len(image)}")
    print()


def demo_simple_transitivity() -> None:
    """For any x,y there is a unique v with x+v=y (torsor structure)."""
    print("=" * 66)
    print("7. SIMPLE TRANSITIVITY (torsor): unique step between any two sections")
    print("=" * 66)
    elems = sections()
    all_unique = True
    for x in elems:
        for y in elems:
            solutions = [v for v in elems if add(x, v) == y]
            if len(solutions) != 1:
                all_unique = False
    print(f"  For every (x, y) there is exactly one v with x + v = y: {all_unique}")
    x, y = (0, 1), (1, 0)
    v = add(y, x)  # y - x = y + x in (Z/2)^n
    print(f"  Example: from {x} to {y}, the unique step is v = {v}"
          f"  (check {x}+{v} = {add(x, v)})")
    print()


def main() -> None:
    print("\nDREAMTIME ALGEBRA — NUMERICAL DEMONSTRATIONS\n")
    demo_exponent_two()
    demo_named_relations()
    demo_cayley_table()
    demo_orders()
    demo_marriage_cosets()
    demo_double_cover()
    demo_simple_transitivity()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
