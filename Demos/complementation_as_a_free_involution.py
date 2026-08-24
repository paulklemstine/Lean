#!/usr/bin/env python3
"""
Complementation as a Free Involution on Framed-Puzzle Assembly Spaces
=====================================================================

Numerical demonstration of the results on global tab-blank complementation.

MODEL
-----
A *framed puzzle* on n variables is a finite list of *clause pieces*.  A clause
piece is a list of *literal inputs* (notches), each a pair (i, p) with
i in {0,...,n-1} a variable index and p in {True, False} the polarity the notch
is milled for.  An *assembly* is a point a of the Boolean cube {0,1}^n: for each
variable you install either its true piece or its false piece.

  * The notch (i, p) fits under a  <=>  a[i] == p.
  * A clause piece snaps into place under a  <=>  some notch of it fits.
  * a assembles P  <=>  every clause piece of P snaps into place.

The assembly space A(P) is the set of all assemblies of P.

Global complementation re-mills every notch for the opposite polarity:
    P*  =  [[(i, not p) for (i, p) in c] for c in P],
and on assemblies it is Boolean negation  sigma(a)[i] = not a[i].

RESULTS DEMONSTRATED
--------------------
1.  Exact transport:            A(P*) = sigma(A(P)),   |A(P*)| = |A(P)|.
2.  Untagged parity:            |A(P) u A(P*)| is even for n >= 1.
3.  Self-dual parity:           a complement-stable assembly space has even size.
4.  Sharpness at n = 0:         the combined count is 1 -- odd.
5.  Orbit decomposition:        |S| = 2 |Gauge(S)| for complement-stable S.
6.  Sign of complementation:    sgn(sigma) = (-1)^(2^(n-1)); odd iff n = 1.
7.  Complete expressiveness:    every subset of the cube is an assembly space,
                                realised with 2^n - |S| clause pieces.
8.  Combined spectrum:          achievable combined counts on n >= 1 variables
                                are exactly the even numbers <= 2^n.
9.  Density of self-duality:    exactly 2^(2^(n-1)) complement-stable spaces,
                                the square root of the total 2^(2^n).
10. Cyclic divisibility:        with d interlock depths, d divides the combined
                                count over all d depth shifts.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# Types
# ----------------------------------------------------------------------------

Assembly = Tuple[bool, ...]            # a point of the Boolean cube {T,F}^n
Notch = Tuple[int, bool]               # (variable index, milled polarity)
ClausePiece = List[Notch]              # one clause piece
FramedPuzzle = List[ClausePiece]       # a framed puzzle on n variables

DAssembly = Tuple[int, ...]            # a point of (Z/d)^n
DNotch = Tuple[int, int]               # (variable index, milled depth)
DClausePiece = List[DNotch]
DFramedPuzzle = List[DClausePiece]


# ----------------------------------------------------------------------------
# 1.  The Boolean framed-puzzle model
# ----------------------------------------------------------------------------

def cube(n: int) -> List[Assembly]:
    """All 2^n assemblies of the Boolean cube, in lexicographic order."""
    return [tuple(bits) for bits in itertools.product([False, True], repeat=n)]


def notch_fits(a: Assembly, notch: Notch) -> bool:
    """The local dictionary: the notch (i,p) interlocks under a iff a[i] == p."""
    i, p = notch
    return a[i] == p


def piece_snaps(a: Assembly, piece: ClausePiece) -> bool:
    """A clause piece snaps into place iff at least one of its notches fits."""
    return any(notch_fits(a, notch) for notch in piece)


def assembles(puzzle: FramedPuzzle, a: Assembly) -> bool:
    """a assembles the puzzle iff every clause piece snaps into place."""
    return all(piece_snaps(a, piece) for piece in puzzle)


def assembly_space(puzzle: FramedPuzzle, n: int) -> Set[Assembly]:
    """A(P): the complete set of assemblies, by enumeration of the cube."""
    return {a for a in cube(n) if assembles(puzzle, a)}


def comp_puzzle(puzzle: FramedPuzzle) -> FramedPuzzle:
    """Global tab-blank complementation: re-mill every notch for -p."""
    return [[(i, not p) for (i, p) in piece] for piece in puzzle]


def comp_assembly(a: Assembly) -> Assembly:
    """sigma: Boolean negation of an assembly (swap every variable piece)."""
    return tuple(not bit for bit in a)


def combined_space(puzzle: FramedPuzzle, n: int) -> Set[Assembly]:
    """C(P) = A(P) u A(P*), the untagged combined assembly space."""
    return assembly_space(puzzle, n) | assembly_space(comp_puzzle(puzzle), n)


def polarity_gauge(space: Iterable[Assembly]) -> Set[Assembly]:
    """Gauge: the assemblies whose variable-0 piece exposes a tab (True)."""
    return {a for a in space if a[0]}


def orbits(space: Iterable[Assembly]) -> List[Tuple[Assembly, Assembly]]:
    """The free complementation orbits {a, sigma(a)}, one per gauge point."""
    return [(g, comp_assembly(g)) for g in sorted(polarity_gauge(space))]


# ----------------------------------------------------------------------------
# 2.  Complete expressiveness: exclusion pieces
# ----------------------------------------------------------------------------

def exclusion_piece(b: Assembly) -> ClausePiece:
    """E_b: the single clause piece that forbids exactly the assembly b.

    Its notch for variable i is milled for the opposite of b[i], so it snaps
    into place under a iff a differs from b somewhere, i.e. iff a != b.
    """
    return [(i, not bit) for i, bit in enumerate(b)]


def puzzle_of_set(S: Set[Assembly], n: int) -> FramedPuzzle:
    """P_S: the framed puzzle whose assembly space is exactly S.

    One exclusion piece per point of the cube that must NOT assemble, so
    |P_S| = 2^n - |S|.
    """
    return [exclusion_piece(b) for b in cube(n) if b not in S]


def stable_set_of_size(n: int, two_k: int) -> Set[Assembly]:
    """A complement-stable subset of the cube of prescribed even size 2k.

    Take k gauge points and adjoin their complements.
    """
    assert two_k % 2 == 0 and two_k <= 2 ** n, "size must be even and <= 2^n"
    k = two_k // 2
    gauge = sorted(polarity_gauge(cube(n)))
    chosen = gauge[:k]
    return set(chosen) | {comp_assembly(g) for g in chosen}


def stable_spaces(n: int) -> List[FrozenSet[Assembly]]:
    """Enumerate all complement-stable subsets of the cube.

    By the gauge parameterisation these are exactly T u sigma(T) for
    T a subset of the 2^(n-1)-element gauge, so there are 2^(2^(n-1)) of them.
    """
    gauge = sorted(polarity_gauge(cube(n)))
    out: List[FrozenSet[Assembly]] = []
    for r in range(len(gauge) + 1):
        for T in itertools.combinations(gauge, r):
            out.append(frozenset(set(T) | {comp_assembly(g) for g in T}))
    return out


# ----------------------------------------------------------------------------
# 3.  Sign of complementation as a permutation of the cube
# ----------------------------------------------------------------------------

def permutation_sign(perm: Dict[Assembly, Assembly]) -> int:
    """Sign of a permutation given as a dictionary, via cycle decomposition."""
    seen: Set[Assembly] = set()
    sign = 1
    for start in perm:
        if start in seen:
            continue
        length = 0
        x = start
        while x not in seen:
            seen.add(x)
            x = perm[x]
            length += 1
        if length % 2 == 0:          # a cycle of even length is an odd permutation
            sign = -sign
    return sign


def comp_sign(n: int) -> int:
    """sgn(sigma) computed by explicit cycle decomposition of the cube."""
    return permutation_sign({a: comp_assembly(a) for a in cube(n)})


# ----------------------------------------------------------------------------
# 4.  The d-ary cyclic model
# ----------------------------------------------------------------------------

def dcube(n: int, d: int) -> List[DAssembly]:
    """All d^n depth assignments in (Z/d)^n."""
    return [tuple(v) for v in itertools.product(range(d), repeat=n)]


def d_assembles(puzzle: DFramedPuzzle, a: DAssembly) -> bool:
    """Each clause piece needs one notch whose milled depth matches its variable."""
    return all(any(a[i] == t for (i, t) in piece) for piece in puzzle)


def shift_puzzle(puzzle: DFramedPuzzle, t: int, d: int) -> DFramedPuzzle:
    """Deepen every mill by t."""
    return [[(i, (s + t) % d) for (i, s) in piece] for piece in puzzle]


def shift_assembly(a: DAssembly, t: int, d: int) -> DAssembly:
    """Deepen every variable piece by t."""
    return tuple((v + t) % d for v in a)


def d_combined(puzzle: DFramedPuzzle, n: int, d: int) -> Set[DAssembly]:
    """The union of the assembly spaces of all d depth shifts."""
    out: Set[DAssembly] = set()
    for t in range(d):
        shifted = shift_puzzle(puzzle, t, d)
        out |= {a for a in dcube(n, d) if d_assembles(shifted, a)}
    return out


def depth_gauge(space: Iterable[DAssembly]) -> Set[DAssembly]:
    """Depth gauge: assemblies whose variable-0 piece is milled to depth 0."""
    return {a for a in space if a[0] == 0}


# ----------------------------------------------------------------------------
# Pretty-printing helpers
# ----------------------------------------------------------------------------

def fmt(a: Sequence[bool]) -> str:
    return "".join("1" if bit else "0" for bit in a)


def fmt_d(a: Sequence[int]) -> str:
    return "".join(str(v) for v in a)


def show_puzzle(puzzle: FramedPuzzle) -> str:
    if not puzzle:
        return "(no clause pieces)"
    return " AND ".join(
        "(" + " OR ".join(("" if p else "-") + f"x{i}" for (i, p) in piece) + ")"
        for piece in puzzle
    )


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_exact_transport() -> None:
    banner("1.  EXACT TRANSPORT:  A(P*) = sigma(A(P))")
    n = 3
    # P = (x0 or x1) and (-x1 or x2) and (x0 or -x2)
    P: FramedPuzzle = [[(0, True), (1, True)],
                       [(1, False), (2, True)],
                       [(0, True), (2, False)]]
    print(f"n = {n},   P  = {show_puzzle(P)}")
    print(f"          P* = {show_puzzle(comp_puzzle(P))}")

    A = assembly_space(P, n)
    Astar = assembly_space(comp_puzzle(P), n)
    sigmaA = {comp_assembly(a) for a in A}

    print(f"\n  A(P)          = {{{', '.join(fmt(a) for a in sorted(A))}}}   |A(P)|  = {len(A)}")
    print(f"  A(P*)         = {{{', '.join(fmt(a) for a in sorted(Astar))}}}   |A(P*)| = {len(Astar)}")
    print(f"  sigma(A(P))   = {{{', '.join(fmt(a) for a in sorted(sigmaA))}}}")
    assert Astar == sigmaA, "exact transport failed"
    assert len(Astar) == len(A)
    print("\n  VERIFIED: A(P*) = sigma(A(P)) and the two spaces are equinumerous.")


def demo_parity_and_orbits() -> None:
    banner("2-3-5.  UNTAGGED PARITY, SELF-DUAL PARITY, AND ORBIT DECOMPOSITION")
    n = 3
    P: FramedPuzzle = [[(0, True), (1, True)],
                       [(1, False), (2, True)],
                       [(0, True), (2, False)]]
    C = combined_space(P, n)
    G = polarity_gauge(C)
    print(f"  C(P) = A(P) u A(P*) = {{{', '.join(fmt(a) for a in sorted(C))}}}")
    print(f"  |C(P)| = {len(C)}   (even: {len(C) % 2 == 0})")
    print(f"  Gauge(C(P))  = {{{', '.join(fmt(a) for a in sorted(G))}}}   |Gauge| = {len(G)}")
    print(f"  |C(P)| = 2 * |Gauge| :  {len(C)} = 2 * {len(G)}   -> {len(C) == 2 * len(G)}")
    print("  Free orbits:")
    for g, s in orbits(C):
        print(f"      {{ {fmt(g)} , {fmt(s)} }}")
    assert len(C) % 2 == 0 and len(C) == 2 * len(G)

    print("\n  --- A self-dual example -------------------------------------------")
    # P2 = (x0 or -x0):  tautological piece; assembly space = whole cube.
    P2: FramedPuzzle = [[(0, True), (0, False)]]
    A2 = assembly_space(P2, n)
    A2star = assembly_space(comp_puzzle(P2), n)
    print(f"  P2 = {show_puzzle(P2)}")
    print(f"  A(P2*) == A(P2) ?  {A2star == A2}    |A(P2)| = {len(A2)}  (even: {len(A2) % 2 == 0})")
    print("  Self-duality does NOT create a fixed point: it collapses the two")
    print("  spaces onto one, on which complementation still acts freely.")
    assert A2star == A2 and len(A2) % 2 == 0

    print("\n  --- Random stress test --------------------------------------------")
    rng = random.Random(20260824)
    failures = 0
    for trial in range(400):
        m = rng.randint(0, 5)
        nn = rng.randint(1, 4)
        Pr: FramedPuzzle = [
            [(rng.randrange(nn), rng.choice([True, False]))
             for _ in range(rng.randint(1, 3))]
            for _ in range(m)
        ]
        Cr = combined_space(Pr, nn)
        if len(Cr) % 2 != 0 or len(Cr) != 2 * len(polarity_gauge(Cr)):
            failures += 1
    print(f"  400 random puzzles (n = 1..4):  parity + orbit identity failures = {failures}")
    assert failures == 0


def demo_sharpness_at_zero() -> None:
    banner("4.  SHARPNESS: THE BOUNDARY IS n = 0, NOT SELF-DUALITY")
    P0: FramedPuzzle = []
    A0 = assembly_space(P0, 0)
    C0 = combined_space(P0, 0)
    print(f"  n = 0.  The cube has {len(cube(0))} point: the empty assembly.")
    print(f"  Every zero-variable puzzle is self-complementary: P* == P ?  "
          f"{comp_puzzle(P0) == P0}")
    print(f"  A(P) = {A0},  |C(P)| = {len(C0)}   -> ODD, so parity genuinely fails.")
    print(f"  sigma fixes the empty assembly: {comp_assembly(()) == ()}")
    print("  This is the unique fixed configuration anywhere in the theory.")
    assert len(C0) == 1


def demo_sign() -> None:
    banner("6.  SIGN OF COMPLEMENTATION AS A PERMUTATION OF THE CUBE")
    print("   n | cube size | #transpositions 2^(n-1) | sgn(sigma) computed | predicted")
    print("  ---+-----------+-------------------------+---------------------+----------")
    for n in range(1, 8):
        computed = comp_sign(n)
        predicted = (-1) ** (2 ** (n - 1))
        assert computed == predicted
        print(f"   {n} | {2**n:9d} | {2**(n-1):23d} | {computed:19d} | {predicted:9d}")
    print("\n  Complementation is an ODD permutation exactly when n = 1;")
    print("  for every n >= 2 it is even.")


def demo_expressiveness() -> None:
    banner("7.  COMPLETE EXPRESSIVENESS: EVERY SUBSET IS AN ASSEMBLY SPACE")
    n = 3
    print(f"  n = {n}.  Round-tripping all {2**(2**n)} subsets of the cube:")
    total = 0
    for r in range(2 ** n + 1):
        for S_tuple in itertools.combinations(cube(n), r):
            S = set(S_tuple)
            P = puzzle_of_set(S, n)
            assert assembly_space(P, n) == S, "expressiveness failed"
            assert len(P) == 2 ** n - len(S), "piece count formula failed"
            total += 1
    print(f"  VERIFIED for all {total} subsets:  A(P_S) = S  and  |P_S| = 2^n - |S|.")

    print("\n  Example.  S = {110} (a singleton) on n = 3 variables:")
    S = {(True, True, False)}
    P = puzzle_of_set(S, 3)
    print(f"      pieces: {len(P)} = 2^3 - 1")
    print(f"      P_S  = {show_puzzle(P)}")
    print(f"      A(P_S) = {{{', '.join(fmt(a) for a in sorted(assembly_space(P, 3)))}}}")
    C = combined_space(P, 3)
    print(f"      C(P_S) = {{{', '.join(fmt(a) for a in sorted(C))}}}   |C| = {len(C)} (even)")


def demo_spectrum() -> None:
    banner("8.  THE EXACT SPECTRUM OF COMBINED ASSEMBLY COUNTS")
    for n in (1, 2, 3, 4):
        achievable = set()
        # every even 2k <= 2^n is achieved, by realising a stable set of that size
        for two_k in range(0, 2 ** n + 1, 2):
            S = stable_set_of_size(n, two_k)
            P = puzzle_of_set(S, n)
            c = len(combined_space(P, n))
            assert c == two_k, f"synthesis failed: wanted {two_k}, got {c}"
            achievable.add(c)
        predicted = set(range(0, 2 ** n + 1, 2))
        assert achievable == predicted
        print(f"  n = {n}:  achievable combined counts = {sorted(achievable)}"
              f"   = all even m <= 2^{n} = {2**n}")

    print("\n  Single-puzzle counts are UNCONSTRAINED (odd counts occur):")
    n = 3
    singles = []
    for k in range(2 ** n + 1):
        S = set(cube(n)[:k])
        P = puzzle_of_set(S, n)
        singles.append(len(assembly_space(P, n)))
    print(f"  n = 3:  realised single counts = {singles}")
    assert singles == list(range(2 ** n + 1))
    print("  This is exactly why parity must be a statement about the")
    print("  complement-stable UNION, never about one assembly space.")


def demo_density() -> None:
    banner("9.  DENSITY OF SELF-DUALITY: A SQUARE-ROOT LAW")
    print("   n | stable spaces (enumerated) | 2^(2^(n-1)) | all spaces 2^(2^n) | square?")
    print("  ---+----------------------------+-------------+--------------------+--------")
    for n in (1, 2, 3):
        enumerated = len(set(stable_spaces(n)))
        predicted = 2 ** (2 ** (n - 1))
        total = 2 ** (2 ** n)
        assert enumerated == predicted
        assert predicted * predicted == total
        print(f"   {n} | {enumerated:26d} | {predicted:11d} | {total:18d} |"
              f"   {predicted * predicted == total}")
    print("\n  For n = 4 the formula gives 2^8 = 256 stable spaces out of 2^16 = 65536.")
    print("  Self-duality is exactly a square-root condition: doubly-exponentially")
    print("  rare, yet realised in EVERY admissible even size (see section 8).")

    print("\n  Every stable space really is a self-dual assembly space:")
    n = 3
    checked = 0
    for S in set(stable_spaces(n)):
        P = puzzle_of_set(set(S), n)
        assert assembly_space(comp_puzzle(P), n) == assembly_space(P, n) == set(S)
        checked += 1
    print(f"      verified for all {checked} complement-stable spaces on n = 3.")


def demo_cyclic() -> None:
    banner("10.  CYCLIC GENERALISATION: d INTERLOCK DEPTHS")
    n, d = 2, 3
    Q: DFramedPuzzle = [[(0, 1)], [(1, 2)]]
    print(f"  n = {n}, d = {d}.  Q has one piece milled for depth 1 at x0,")
    print(f"                   and one milled for depth 2 at x1.")
    for t in range(d):
        shifted = shift_puzzle(Q, t, d)
        space = {a for a in dcube(n, d) if d_assembles(shifted, a)}
        print(f"      shift {t}:  A_d(Q^+{t}) = "
              f"{{{', '.join(fmt_d(a) for a in sorted(space))}}}")
    C = d_combined(Q, n, d)
    G = depth_gauge(C)
    print(f"  Combined C_d(Q) = {{{', '.join(fmt_d(a) for a in sorted(C))}}}")
    print(f"  |C_d(Q)| = {len(C)},  depth gauge size = {len(G)},  "
          f"|C| = d * |gauge| : {len(C) == d * len(G)}")
    assert len(C) % d == 0 and len(C) == d * len(G)

    print("\n  Random stress test of the divisibility law:")
    rng = random.Random(7)
    print("   d | trials | all divisible by d | all equal d*|gauge|")
    print("  ---+--------+--------------------+--------------------")
    for d in (2, 3, 4, 5):
        ok_div = ok_gauge = 0
        trials = 120
        for _ in range(trials):
            nn = rng.randint(1, 3)
            R: DFramedPuzzle = [
                [(rng.randrange(nn), rng.randrange(d)) for _ in range(rng.randint(1, 2))]
                for _ in range(rng.randint(0, 4))
            ]
            Cd = d_combined(R, nn, d)
            ok_div += (len(Cd) % d == 0)
            ok_gauge += (len(Cd) == d * len(depth_gauge(Cd)))
        assert ok_div == trials and ok_gauge == trials
        print(f"   {d} | {trials:6d} | {ok_div:18d} | {ok_gauge:19d}")
    print("\n  Tab-blank parity is the d = 2 slice: the constraint on solution")
    print("  counts is the ORDER of the group acting freely on configurations.")


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    demo_exact_transport()
    demo_parity_and_orbits()
    demo_sharpness_at_zero()
    demo_sign()
    demo_expressiveness()
    demo_spectrum()
    demo_density()
    demo_cyclic()
    banner("ALL DEMONSTRATIONS COMPLETED -- every assertion held.")


if __name__ == "__main__":
    main()
