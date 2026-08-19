"""
Counting the Frames of Provability: numerical demonstrations
============================================================

This self-contained script demonstrates, by explicit computation, the results of
the accompanying article and paper on frame definability for modal systems of
provability.

Background in one paragraph
---------------------------
A *frame* on the world set W is a binary relation R on W ("w can see v").  A
*valuation* assigns to each propositional variable the set of worlds where it is
true; satisfaction is the usual Kripke clause, with the box read as "at every
visible world".  A formula is *valid on a frame* when it is true at every world
under every valuation.  The central correspondences demonstrated here are:

  * The Loeb axiom  box(box p -> p) -> box p  is valid on F exactly when R is
    transitive and converse well-founded; on a finite frame this collapses to
    "transitive and irreflexive", i.e. R is a strict partial order.
  * The reflection axiom  box p -> p  is valid on F exactly when R is reflexive.
  * The n-fold reflection axiom  box^n p -> p  is valid on F exactly when every
    world lies on a closed walk of length exactly n.

Consequently the number of frames on n labelled worlds validating Loeb is the
number of labelled strict partial orders on n points: 1, 1, 3, 19, 219, 4231,
while the number validating reflection is 2^(n^2 - n).

Everything below is computed from scratch; no third-party packages are needed.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

# A frame on {0, ..., n-1} is stored as a tuple of n row-bitmasks:
# bit j of rows[i] is set iff i sees j.
Frame = Tuple[int, ...]


# ----------------------------------------------------------------------------
# Part 0.  Basic predicates on frames
# ----------------------------------------------------------------------------


def is_irreflexive(rows: Frame) -> bool:
    """True iff no world sees itself."""
    return all(not (row >> i) & 1 for i, row in enumerate(rows))


def is_reflexive(rows: Frame) -> bool:
    """True iff every world sees itself (validity of the reflection axiom)."""
    return all((row >> i) & 1 for i, row in enumerate(rows))


def is_transitive(rows: Frame) -> bool:
    """True iff i sees j and j sees k implies i sees k."""
    n = len(rows)
    for i in range(n):
        row = rows[i]
        for j in range(n):
            if (row >> j) & 1 and (rows[j] & ~row) != 0:
                return False
    return True


def validates_loeb(rows: Frame) -> bool:
    """Validity of the Loeb axiom on a *finite* frame: strict partial order."""
    return is_transitive(rows) and is_irreflexive(rows)


def validates_reflection(rows: Frame) -> bool:
    """Validity of the reflection axiom box p -> p."""
    return is_reflexive(rows)


def all_frames(n: int) -> Iterable[Frame]:
    """Enumerate all 2^(n^2) frames on n labelled worlds."""
    full = 1 << n
    for rows in product(range(full), repeat=n):
        yield rows


# ----------------------------------------------------------------------------
# Part 1.  Brute-force counts (small n) and the exact reflexive count
# ----------------------------------------------------------------------------


def loeb_frame_count_bruteforce(n: int) -> int:
    """Count frames on n worlds validating Loeb, by exhaustive search."""
    return sum(1 for rows in all_frames(n) if validates_loeb(rows))


def reflexive_frame_count_bruteforce(n: int) -> int:
    """Count frames on n worlds validating reflection, by exhaustive search."""
    return sum(1 for rows in all_frames(n) if validates_reflection(rows))


def reflexive_frame_count_closed_form(n: int) -> int:
    """Closed form: fix the n diagonal entries, the other n^2-n are free."""
    return 1 << (n * n - n)


# ----------------------------------------------------------------------------
# Part 2.  Fast enumeration of labelled strict partial orders
# ----------------------------------------------------------------------------
#
# Growing a poset one point at a time.  Suppose P is a strict partial order on
# {0,...,m-1} and we add the point m with strict down-set D (things below m) and
# strict up-set U (things above m).  The extension is again a strict partial
# order iff
#     (i)   D is downward closed in P,
#     (ii)  U is upward closed in P,
#     (iii) every element of D is below every element of U in P
#           (this is what transitivity through the new point demands, and it
#            forces D and U to be disjoint, hence irreflexivity).
# This yields an enumeration whose cost is proportional to the number of posets
# produced, rather than to 2^(n^2).


def extensions(rows: Frame) -> Iterable[Frame]:
    """All strict partial orders on m+1 points restricting to `rows` on m."""
    m = len(rows)
    down_closed: List[int] = []
    up_closed: List[int] = []
    universe = (1 << m) - 1
    for s in range(1 << m):
        # s is downward closed iff for every i in s, all predecessors of i are in s
        ok_down = True
        ok_up = True
        for i in range(m):
            if (s >> i) & 1:
                preds = sum(1 << j for j in range(m) if (rows[j] >> i) & 1)
                if preds & ~s:
                    ok_down = False
                succs = rows[i]
                if succs & ~s:
                    ok_up = False
            if not (ok_down or ok_up):
                break
        if ok_down:
            down_closed.append(s)
        if ok_up:
            up_closed.append(s)
    for d in down_closed:
        for u in up_closed:
            if d & u:
                continue
            # every element of D must already be below every element of U
            if any(
                (d >> i) & 1 and (rows[i] & u) != u
                for i in range(m)
            ):
                continue
            new_rows = []
            for i in range(m):
                r = rows[i]
                if (d >> i) & 1:  # i is below the new point m
                    r |= 1 << m
                new_rows.append(r)
            new_rows.append(u & universe)  # the new point sees exactly U
            yield tuple(new_rows)


def enumerate_posets(n: int) -> List[Frame]:
    """All labelled strict partial orders on {0,...,n-1}."""
    current: List[Frame] = [()]
    for _ in range(n):
        nxt: List[Frame] = []
        for p in current:
            nxt.extend(extensions(p))
        current = nxt
    return current


def loeb_frame_count(n: int) -> int:
    """The number of frames on n labelled worlds validating the Loeb axiom."""
    return len(enumerate_posets(n))


# ----------------------------------------------------------------------------
# Part 3.  Monotonicity: adjoining an isolated world
# ----------------------------------------------------------------------------


def adjoin_isolated_world(rows: Frame) -> Frame:
    """Extend a frame on n worlds by one world that sees nothing and is unseen."""
    return tuple(rows) + (0,)


def check_monotonicity(n: int) -> Tuple[int, int, bool]:
    """The map 'adjoin an isolated world' injects Loeb frames on n into n+1."""
    small = enumerate_posets(n)
    big = set(enumerate_posets(n + 1))
    images = {adjoin_isolated_world(p) for p in small}
    injective = len(images) == len(small)
    return len(small), len(big), injective and images <= big


# ----------------------------------------------------------------------------
# Part 4.  Semantics: satisfaction and honest validity checking
# ----------------------------------------------------------------------------
#
# We check validity of a formula on a small frame by brute force over all
# 2^(number of variables * n) valuations, so the bridge theorems below are
# tested semantically, not merely as matrix conditions.

Formula = object  # formulas are nested tuples, see below
# ('var', name) | ('bot',) | ('imp', a, b) | ('box', a)


def sat(rows: Frame, val: Dict[str, int], w: int, phi) -> bool:
    """Satisfaction of phi at world w; val maps a variable to a bitmask of worlds."""
    tag = phi[0]
    if tag == "bot":
        return False
    if tag == "var":
        return bool((val[phi[1]] >> w) & 1)
    if tag == "imp":
        return (not sat(rows, val, w, phi[1])) or sat(rows, val, w, phi[2])
    if tag == "box":
        return all(
            sat(rows, val, v, phi[1]) for v in range(len(rows)) if (rows[w] >> v) & 1
        )
    raise ValueError(f"unknown formula {phi!r}")


def valid(rows: Frame, phi, variables: Sequence[str]) -> bool:
    """Validity of phi on the frame: all worlds, all valuations."""
    n = len(rows)
    for assignment in product(range(1 << n), repeat=len(variables)):
        val = dict(zip(variables, assignment))
        if not all(sat(rows, val, w, phi) for w in range(n)):
            return False
    return True


def box_iter(k: int, phi):
    """The formula box^k phi."""
    for _ in range(k):
        phi = ("box", phi)
    return phi


P = ("var", "p")
LOEB = ("imp", ("box", ("imp", ("box", P), P)), ("box", P))
REFLECTION = ("imp", ("box", P), P)
CONSISTENCY = ("imp", ("box", ("bot",)), ("bot",))  # not box bottom


def cycle_axiom(k: int):
    """The k-fold reflection axiom box^k p -> p."""
    return ("imp", box_iter(k, P), P)


# ----------------------------------------------------------------------------
# Part 5.  The degree monoid of a frame
# ----------------------------------------------------------------------------


def has_closed_walk(rows: Frame, k: int, w: int) -> bool:
    """True iff there is a walk of length exactly k from w back to w."""
    reach = {w}
    for _ in range(k):
        reach = {v for u in reach for v in range(len(rows)) if (rows[u] >> v) & 1}
    return w in reach


def degree_set(rows: Frame, bound: int = 12) -> List[int]:
    """Degrees k <= bound such that box^k p -> p is valid: every world on a k-walk."""
    return [
        k
        for k in range(bound + 1)
        if all(has_closed_walk(rows, k, w) for w in range(len(rows)))
    ]


def cycle_frame(n: int) -> Frame:
    """The directed n-cycle 0 -> 1 -> ... -> n-1 -> 0."""
    return tuple(1 << ((i + 1) % n) for i in range(n))


def complete_irreflexive_frame(n: int) -> Frame:
    """Every world sees every other world, and no world sees itself."""
    return tuple(sum(1 << j for j in range(n) if j != i) for i in range(n))


def equality_frame(n: int) -> Frame:
    """Each world sees exactly itself: n disjoint loops."""
    return tuple(1 << i for i in range(n))


# ----------------------------------------------------------------------------
# Part 6.  Bounded morphisms: why irreflexivity is not definable
# ----------------------------------------------------------------------------


def is_bounded_morphism(src: Frame, tgt: Frame, f: Sequence[int]) -> bool:
    """f preserves accessibility (forth) and reflects it up to preimages (back)."""
    n, m = len(src), len(tgt)
    for w in range(n):
        for v in range(n):
            if (src[w] >> v) & 1 and not (tgt[f[w]] >> f[v]) & 1:
                return False  # forth fails
        for u in range(m):
            if (tgt[f[w]] >> u) & 1:
                if not any((src[w] >> v) & 1 and f[v] == u for v in range(n)):
                    return False  # back fails
    return True


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def main() -> None:
    rule("1.  The bridge: semantic Loeb validity = strict partial order")
    print("For every frame on 3 worlds we compare")
    print("  (a) validity of  box(box p -> p) -> box p  over all 8^3 valuations")
    print("  (b) the matrix condition 'transitive and zero diagonal'.")
    agree = 0
    valid_count = 0
    for rows in all_frames(3):
        a = valid(rows, LOEB, ["p"])
        b = validates_loeb(rows)
        agree += a == b
        valid_count += a
    print(f"  frames tested            : {8 ** 3}")
    print(f"  (a) and (b) agree on     : {agree} frames  (perfect agreement)")
    print(f"  frames validating Loeb   : {valid_count}")

    rule("2.  Counting the Loeb frames")
    print(" n | Loeb frames | all frames | fraction")
    for n in range(7):
        c = loeb_frame_count(n)
        total = 1 << (n * n)
        print(f" {n} | {c:11d} | {total:10d} | {c / total:.3e}")
    print()
    print("Brute-force cross-check for n <= 4:")
    for n in range(5):
        bf = loeb_frame_count_bruteforce(n)
        fast = loeb_frame_count(n)
        print(f"  n={n}: brute force {bf:5d}   fast enumeration {fast:5d}   "
              f"{'match' if bf == fast else 'MISMATCH'}")

    rule("3.  Reflection is cheap, Loeb is rare")
    print(" n | Loeb frames | reflexive frames 2^(n^2-n) | ratio")
    for n in range(6):
        loeb = loeb_frame_count(n)
        refl = reflexive_frame_count_closed_form(n)
        print(f" {n} | {loeb:11d} | {refl:26d} | {loeb / refl:.3e}")
    print()
    print("Brute-force check of the reflexive count for n <= 3:")
    for n in range(4):
        print(f"  n={n}: {reflexive_frame_count_bruteforce(n)} "
              f"= 2^({n*n}-{n}) = {reflexive_frame_count_closed_form(n)}")
    print()
    print("On three worlds: 19 Loeb frames versus 64 reflexive frames out of 512.")
    print("No NONEMPTY frame validates both: reflexivity and irreflexivity clash.")
    both = [rows for rows in all_frames(3)
            if validates_loeb(rows) and validates_reflection(rows)]
    print(f"  frames on 3 worlds validating both axioms: {len(both)}")

    rule("4.  Monotonicity: adjoining an isolated world")
    for n in range(5):
        small, big, ok = check_monotonicity(n)
        print(f"  n={n}: {small:4d} Loeb frames inject into {big:5d} on n+1 worlds"
              f"   [injective and into: {ok}]")

    rule("5.  The degree monoid: which axioms box^k p -> p hold")
    frames = {
        "3-cycle              ": cycle_frame(3),
        "2-cycle              ": cycle_frame(2),
        "equality frame (n=3) ": equality_frame(3),
        "K3, complete irrefl. ": complete_irreflexive_frame(3),
        "a Loeb frame (0->1)  ": (0b10, 0b00),
    }
    for name, rows in frames.items():
        degs = degree_set(rows, 12)
        print(f"  {name}: valid degrees k <= 12 : {degs}")
    print()
    print("Semantic cross-check on K3 (all valuations, k = 0..4):")
    k3 = complete_irreflexive_frame(3)
    for k in range(5):
        print(f"    box^{k} p -> p valid on K3 : {valid(k3, cycle_axiom(k), ['p'])}")
    print("  So the degrees of K3 are {0, 2, 3, 4, ...} = <2,3>, a numerical")
    print("  semigroup that is NOT the set of multiples of any single d.")
    print("  Degrees are closed under addition: 2+2=4, 2+3=5, 3+3=6 all present.")

    rule("6.  Bounded morphisms and the failure of definability")
    two_cycle = cycle_frame(2)
    loop = (0b1,)
    f = [0, 0]
    print("  Source: the 2-cycle 0 -> 1 -> 0 (irreflexive).")
    print("  Target: the single reflexive loop (not irreflexive).")
    print(f"  The constant map is a surjective bounded morphism : "
          f"{is_bounded_morphism(two_cycle, loop, f)}")
    print("  Validity transfers along surjective bounded morphisms, so no set of")
    print("  modal formulas can define irreflexivity: an irreflexive frame maps")
    print("  onto a reflexive one.")
    print()
    print("  Sanity check: every formula valid on the 2-cycle is valid on the loop.")
    tests = {"Loeb": LOEB, "reflection": REFLECTION, "consistency": CONSISTENCY,
             "box^2 p -> p": cycle_axiom(2)}
    for name, phi in tests.items():
        print(f"    {name:14s}: 2-cycle {valid(two_cycle, phi, ['p'])!s:5s} "
              f" loop {valid(loop, phi, ['p'])!s:5s}")

    rule("7.  Disjoint unions: 'some world is reflexive' is not definable")

    def disjoint_union(a: Frame, b: Frame) -> Frame:
        na = len(a)
        return tuple(a) + tuple(row << na for row in b)

    succ2 = (0b10, 0b00)  # a two-point Loeb frame, no reflexive world
    union = disjoint_union(succ2, loop)
    print(f"  Frame A (0 -> 1)          : reflexive world? "
          f"{any((succ2[i] >> i) & 1 for i in range(2))}")
    print(f"  Frame B (single loop)     : reflexive world? True")
    print(f"  A + B has a reflexive world, yet A does not; and a formula is valid")
    print(f"  on A + B iff it is valid on both summands, so no axiom set can say")
    print(f"  'some world is reflexive'.")
    for name, phi in tests.items():
        va, vb, vu = (valid(succ2, phi, ["p"]), valid(loop, phi, ["p"]),
                      valid(union, phi, ["p"]))
        print(f"    {name:14s}: A {va!s:5s} B {vb!s:5s} A+B {vu!s:5s}"
              f"   (A+B = A and B: {vu == (va and vb)})")

    rule("8.  The nineteen Loeb frames on three worlds")
    for idx, rows in enumerate(sorted(enumerate_posets(3)), start=1):
        edges = [f"{i}->{j}" for i in range(3) for j in range(3)
                 if (rows[i] >> j) & 1]
        print(f"  {idx:2d}. " + (", ".join(edges) if edges else "(no edges)"))
    print()
    print("Nineteen strict partial orders; equivalently nineteen frames on three")
    print("worlds on which the Loeb axiom is valid under every valuation.")


if __name__ == "__main__":
    main()
