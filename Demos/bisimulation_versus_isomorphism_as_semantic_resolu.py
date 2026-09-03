#!/usr/bin/env python3
"""
Bisimulation versus isomorphism as semantic resolution
=======================================================

Numerical demonstration of the results on descending tag-indexed frames.

Setting
-------
Worlds are natural numbers.  A frame is a family of relations indexed by a *tag*,
and a world `m` may step, at tag `i`, only to worlds `n < m`.  This makes every
frame image-finite (a world has at most `m` successors) and converse
well-founded (the height of world `m` is at most `m`).

The observational language is multi-modal:

    a ::= bot | atom p | a -> a | Box_i a

with `Box_i a` true at `m` iff every `i`-successor of `m` satisfies `a`.

What this script verifies
-------------------------
1.  Hennessy-Milner: partition refinement (bisimilarity) agrees exactly with
    exhaustive formula enumeration (modal equivalence) on all witness frames.
2.  The multiplicity gap: worlds 3 and 4 of the frame
        1 -> 0, 2 -> 0, 3 -> 1, 3 -> 2, 4 -> 1
    are bisimilar but have out-degrees 2 and 1, hence are not isomorphic.
3.  Refutation of the multiplicity conjecture: the shared diamond
        5 -> 3, 5 -> 4, 3 -> 1, 4 -> 1
    and its unravelling
        5 -> 3, 5 -> 4, 3 -> 1, 4 -> 2
    are bisimilar, out-degree matched at every related pair, and NOT isomorphic
    (4 vs 5 reachable worlds).
4.  The depth ladder in the chain frame `m + 1 -> m`: worlds k and k+1 agree up
    to depth k and are separated at depth k+1 by the height formula Box^(k+1) bot.
5.  The collapse threshold: on worlds of height <= k, depth-k agreement already
    implies full modal equivalence.
6.  The naming budget: k atoms of the binary naming valuation separate all
    worlds below 2^k atomically, and 2^k + 1 worlds always collide.

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Set, Tuple

# ---------------------------------------------------------------------------
# 1.  Frames, valuations, formulas, semantics
# ---------------------------------------------------------------------------

Edge = Tuple[int, int, int]  # (tag, source, target)

Valuation = Callable[[int, int], bool]  # (world, atom) -> truth value


@dataclass(frozen=True)
class Frame:
    """A descending tag-indexed frame given by an explicit finite edge set.

    Only edges with ``target < source`` are retained: the descending condition
    is enforced structurally, so image-finiteness and converse well-foundedness
    hold by construction.
    """

    name: str
    edges: FrozenSet[Edge]

    @staticmethod
    def of(name: str, edges: Iterable[Edge]) -> "Frame":
        kept = frozenset((i, m, n) for (i, m, n) in edges if n < m)
        return Frame(name, kept)

    def successors(self, tag: int, world: int) -> List[int]:
        """The i-successors of a world, in increasing order."""
        return sorted(n for (i, m, n) in self.edges if i == tag and m == world)

    def out_degree(self, tag: int, world: int) -> int:
        """The multiplicity-sensitive observation: number of successors."""
        return len(self.successors(tag, world))

    def tags(self) -> List[int]:
        return sorted({i for (i, _, _) in self.edges}) or [0]

    def reachable(self, root: int) -> Set[int]:
        """Worlds reachable from ``root`` along steps of arbitrary tags."""
        seen: Set[int] = {root}
        frontier = [root]
        while frontier:
            m = frontier.pop()
            for i in self.tags():
                for n in self.successors(i, m):
                    if n not in seen:
                        seen.add(n)
                        frontier.append(n)
        return seen

    def height(self, world: int) -> int:
        """Length of the longest path leaving ``world`` (bounded by ``world``)."""
        best = 0
        for i in self.tags():
            for n in self.successors(i, world):
                best = max(best, 1 + self.height(n))
        return best


# --- formulas -------------------------------------------------------------

@dataclass(frozen=True)
class Bot:
    pass


@dataclass(frozen=True)
class Atom:
    p: int


@dataclass(frozen=True)
class Imp:
    a: "Formula"
    b: "Formula"


@dataclass(frozen=True)
class Box:
    tag: int
    a: "Formula"


Formula = object  # one of Bot, Atom, Imp, Box


def box_depth(a: Formula) -> int:
    """Maximal nesting of boxes."""
    if isinstance(a, (Bot, Atom)):
        return 0
    if isinstance(a, Imp):
        return max(box_depth(a.a), box_depth(a.b))
    if isinstance(a, Box):
        return 1 + box_depth(a.a)
    raise TypeError(a)


def show(a: Formula) -> str:
    if isinstance(a, Bot):
        return "⊥"
    if isinstance(a, Atom):
        return f"p{a.p}"
    if isinstance(a, Imp):
        if isinstance(a.b, Bot):
            return f"¬({show(a.a)})"
        return f"({show(a.a)} → {show(a.b)})"
    if isinstance(a, Box):
        return f"□{a.tag}({show(a.a)})"
    raise TypeError(a)


def sat(frame: Frame, val: Valuation, world: int, a: Formula) -> bool:
    """Satisfaction of a formula at a world."""
    if isinstance(a, Bot):
        return False
    if isinstance(a, Atom):
        return val(world, a.p)
    if isinstance(a, Imp):
        return (not sat(frame, val, world, a.a)) or sat(frame, val, world, a.b)
    if isinstance(a, Box):
        return all(sat(frame, val, n, a.a) for n in frame.successors(a.tag, world))
    raise TypeError(a)


def box_pow(tag: int, j: int) -> Formula:
    """The height formula □^j ⊥: 'you cannot take j steps'."""
    out: Formula = Bot()
    for _ in range(j):
        out = Box(tag, out)
    return out


# --- valuations -----------------------------------------------------------

def constant_valuation(world: int, atom: int) -> bool:
    """Every atom true everywhere: only the transition structure is observable."""
    return True


def nominal_valuation(world: int, atom: int) -> bool:
    """One atom per world: the atom p is true exactly at world p."""
    return world == atom


def binary_valuation(world: int, atom: int) -> bool:
    """Binary naming: atom p is true at m iff the p-th bit of m is set."""
    return bool((world >> atom) & 1)


# ---------------------------------------------------------------------------
# 2.  The witness frames
# ---------------------------------------------------------------------------

MULT = Frame.of("multiplicity", [(0, 1, 0), (0, 2, 0), (0, 3, 1), (0, 3, 2), (0, 4, 1)])
SHARE = Frame.of("shared diamond", [(0, 5, 3), (0, 5, 4), (0, 3, 1), (0, 4, 1)])
TREE = Frame.of("unravelling", [(0, 5, 3), (0, 5, 4), (0, 3, 1), (0, 4, 2)])


def chain(n: int) -> Frame:
    """The linear chain: world m+1 sees exactly world m."""
    return Frame.of("chain", [(0, m + 1, m) for m in range(n)])


# ---------------------------------------------------------------------------
# 3.  Algorithm: partition refinement (bisimilarity), depth-graded
# ---------------------------------------------------------------------------

World = Tuple[str, int]  # (frame name, world index)


def refine(
    frames: Dict[str, Frame],
    vals: Dict[str, Valuation],
    worlds: List[World],
    atoms: int,
    rounds: int | None = None,
) -> Dict[World, int]:
    """Partition refinement computing depth-graded observational equivalence.

    Returns a map from each world to its block index.  Running to stabilization
    (``rounds=None``) yields exactly the bisimilarity classes, which by the
    Hennessy-Milner theorem are the modal-equivalence classes.  Halting after
    ``k`` rounds yields exactly the depth-``k`` equivalence classes.

    Complexity: O(rounds * |worlds| * |edges|) in this direct implementation.
    """
    tags = sorted({t for f in frames.values() for t in f.tags()})

    # round 0: atomic type
    sig0 = {w: tuple(vals[w[0]](w[1], p) for p in range(atoms)) for w in worlds}
    block = _index(sig0, worlds)

    k = 0
    while rounds is None or k < rounds:
        sig = {}
        for w in worlds:
            fname, m = w
            f = frames[fname]
            per_tag = tuple(
                tuple(sorted({block[(fname, n)] for n in f.successors(t, m)}))
                for t in tags
            )
            sig[w] = (block[w], per_tag)
        new_block = _index(sig, worlds)
        k += 1
        if rounds is None and _same_partition(block, new_block, worlds):
            return block
        block = new_block
    return block


def _index(sig: Dict[World, object], worlds: List[World]) -> Dict[World, int]:
    codes: Dict[object, int] = {}
    out: Dict[World, int] = {}
    for w in worlds:
        s = sig[w]
        if s not in codes:
            codes[s] = len(codes)
        out[w] = codes[s]
    return out


def _same_partition(a: Dict[World, int], b: Dict[World, int], worlds: List[World]) -> bool:
    for u, v in combinations(worlds, 2):
        if (a[u] == a[v]) != (b[u] == b[v]):
            return False
    return True


# ---------------------------------------------------------------------------
# 4.  Exhaustive formula enumeration (brute-force modal equivalence)
# ---------------------------------------------------------------------------

def all_formulas(layers: int, atoms: int = 1, tags: Tuple[int, ...] = (0,)) -> List[Formula]:
    """All formulas built in ``layers`` closure rounds from ⊥ and the atoms."""
    current: List[Formula] = [Bot()] + [Atom(p) for p in range(atoms)]
    for _ in range(layers):
        nxt = list(current)
        nxt += [Imp(a, b) for a in current for b in current]
        nxt += [Box(t, a) for t in tags for a in current]
        current = nxt
    return current


def separating_formulas(
    f1: Frame, v1: Valuation, m: int,
    f2: Frame, v2: Valuation, n: int,
    layers: int = 3,
    max_report: int = 3,
) -> Tuple[int, List[str]]:
    """Count formulas separating two pointed models, with a few examples."""
    seps: List[str] = []
    count = 0
    for a in all_formulas(layers):
        if sat(f1, v1, m, a) != sat(f2, v2, n, a):
            count += 1
            if len(seps) < max_report:
                seps.append(show(a))
    return count, seps


# ---------------------------------------------------------------------------
# 5.  Isomorphism of generated submodels (brute force)
# ---------------------------------------------------------------------------

def pointed_isomorphic(f1: Frame, r1: int, f2: Frame, r2: int) -> bool:
    """Is there a bijection of generated submodels matching roots and edges?"""
    A = sorted(f1.reachable(r1))
    B = sorted(f2.reachable(r2))
    if len(A) != len(B):
        return False
    tags = sorted(set(f1.tags()) | set(f2.tags()))
    rest_a = [x for x in A if x != r1]
    for perm in _permutations([x for x in B if x != r2]):
        img = {r1: r2}
        img.update(dict(zip(rest_a, perm)))
        ok = True
        for t in tags:
            e1 = {(img[m], img[n]) for m in A for n in f1.successors(t, m) if n in img}
            e2 = {(m, n) for m in B for n in f2.successors(t, m)}
            if e1 != e2:
                ok = False
                break
        if ok:
            return True
    return False


def _permutations(xs: List[int]) -> Iterable[Tuple[int, ...]]:
    if not xs:
        yield ()
        return
    for i, x in enumerate(xs):
        for rest in _permutations(xs[:i] + xs[i + 1:]):
            yield (x,) + rest


# ---------------------------------------------------------------------------
# 6.  The demonstrations
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_multiplicity_gap() -> None:
    rule("1.  The multiplicity gap:  bisimilar, non-isomorphic, different out-degree")
    print("Frame: 1→0, 2→0, 3→1, 3→2, 4→1   (constant valuation)")
    worlds = [("M", w) for w in range(5)]
    block = refine({"M": MULT}, {"M": constant_valuation}, worlds, atoms=1)
    classes: Dict[int, List[int]] = {}
    for (_, w) in worlds:
        classes.setdefault(block[("M", w)], []).append(w)
    print(f"  bisimilarity classes         : {sorted(map(sorted, classes.values()))}")
    print(f"  3 and 4 bisimilar?           : {block[('M', 3)] == block[('M', 4)]}")
    cnt, ex = separating_formulas(MULT, constant_valuation, 3,
                                  MULT, constant_valuation, 4, layers=3)
    print(f"  separating formulas (6560)   : {cnt}")
    print(f"  out-degree of 3              : {MULT.out_degree(0, 3)}")
    print(f"  out-degree of 4              : {MULT.out_degree(0, 4)}")
    print(f"  isomorphic generated submodels? : {pointed_isomorphic(MULT, 3, MULT, 4)}")
    print("  ⇒ bisimulation invariance is STRICTLY stronger than isomorphism invariance.")
    # control
    cnt2, ex2 = separating_formulas(MULT, constant_valuation, 3,
                                    MULT, constant_valuation, 1, layers=3)
    print(f"  control (worlds 3 vs 1)      : {cnt2} separating formulas, e.g. {ex2[:2]}")


def demo_sharing_refutation() -> None:
    rule("2.  Refutation:  multiplicity does NOT close the bisimulation/iso gap")
    print("Shared diamond S : 5→3, 5→4, 3→1, 4→1        (4 reachable worlds)")
    print("Unravelling   T : 5→3, 5→4, 3→1, 4→2        (5 reachable worlds)")
    worlds = [("S", w) for w in sorted(SHARE.reachable(5))]
    worlds += [("T", w) for w in sorted(TREE.reachable(5))]
    frames = {"S": SHARE, "T": TREE}
    vals = {"S": constant_valuation, "T": constant_valuation}
    block = refine(frames, vals, worlds, atoms=1)
    print(f"  roots bisimilar?             : {block[('S', 5)] == block[('T', 5)]}")
    cnt, _ = separating_formulas(SHARE, constant_valuation, 5,
                                 TREE, constant_valuation, 5, layers=3)
    print(f"  separating formulas (6560)   : {cnt}")
    print("  out-degrees along the bisimulation:")
    matched = True
    for (fa, a) in worlds:
        for (fb, b) in worlds:
            if fa == "S" and fb == "T" and block[(fa, a)] == block[(fb, b)]:
                da, db = SHARE.out_degree(0, a), TREE.out_degree(0, b)
                print(f"      S:{a} ~ T:{b}   deg {da} vs {db}   {'ok' if da == db else 'MISMATCH'}")
                matched = matched and da == db
    print(f"  all multiplicities matched?  : {matched}")
    print(f"  reachable world counts       : |S| = {len(SHARE.reachable(5))}, "
          f"|T| = {len(TREE.reachable(5))}")
    print(f"  isomorphic generated submodels? : {pointed_isomorphic(SHARE, 5, TREE, 5)}")
    print("  ⇒ counting successors is strictly weaker than naming worlds;")
    print("    the residual invisible structure is SHARING, not multiplicity.")


def demo_depth_ladder() -> None:
    rule("3.  The depth ladder in the chain, and where it collapses")
    N = 7
    C = chain(N)
    print(f"Chain frame on worlds 0..{N}:  m+1 → m")
    print("  height formula □^j ⊥ holds at m iff m < j:")
    for j in range(1, 5):
        truth = [m for m in range(N + 1) if sat(C, constant_valuation, m, box_pow(0, j))]
        print(f"      j = {j}:  true at {truth}")
    print()
    print("  depth-k refinement: worlds k and k+1 agree at depth k, differ at depth k+1")
    worlds = [("C", w) for w in range(N + 1)]
    for k in range(0, 5):
        bk = refine({"C": C}, {"C": constant_valuation}, worlds, atoms=1, rounds=k)
        bk1 = refine({"C": C}, {"C": constant_valuation}, worlds, atoms=1, rounds=k + 1)
        same_k = bk[("C", k)] == bk[("C", k + 1)]
        same_k1 = bk1[("C", k)] == bk1[("C", k + 1)]
        print(f"      k = {k}:  depth-{k} equivalent = {same_k},  "
              f"depth-{k+1} equivalent = {same_k1}")
    print()
    print("  collapse threshold: on worlds of height ≤ k, depth-k agreement")
    print("  already implies full modal equivalence.  Heights in the chain:")
    print("      " + ", ".join(f"h({m})={C.height(m)}" for m in range(N + 1)))
    for k in range(1, 5):
        stable = refine({"C": C}, {"C": constant_valuation}, worlds, atoms=1)
        at_k = refine({"C": C}, {"C": constant_valuation}, worlds, atoms=1, rounds=k)
        lo = [w for w in worlds if C.height(w[1]) <= k]
        agree = all((at_k[u] == at_k[v]) == (stable[u] == stable[v])
                    for u, v in combinations(lo, 2))
        print(f"      k = {k}: depth-{k} partition agrees with bisimilarity "
              f"on the {len(lo)} worlds of height ≤ {k}: {agree}")


def demo_naming_budget() -> None:
    rule("4.  The naming budget:  k atoms name exactly 2^k worlds")
    print("Binary naming: atom p is true at m iff the p-th bit of m is set.")
    for k in range(1, 5):
        N = 2 ** k
        types = {tuple(binary_valuation(m, p) for p in range(k)) for m in range(N)}
        print(f"  k = {k}:  worlds 0..{N-1}  →  {len(types)} distinct atomic types "
              f"(all distinct: {len(types) == N})")
    print()
    print("Lower bound (pigeonhole): with k atoms, 2^k + 1 worlds must collide.")
    for k in range(1, 5):
        N = 2 ** k
        collision = None
        for m, n in combinations(range(N + 1), 2):
            if all(binary_valuation(m, p) == binary_valuation(n, p) for p in range(k)):
                collision = (m, n)
                break
        print(f"  k = {k}:  worlds 0..{N} — collision at {collision}")
    print()
    print("Nominal valuation (one atom per world) forces equality at depth 0:")
    for (m, n) in [(3, 4), (5, 5)]:
        eq = all(nominal_valuation(m, p) == nominal_valuation(n, p) for p in range(8))
        print(f"  worlds {m}, {n}: atomically indistinguishable = {eq}  (equal = {m == n})")
    print()
    print("With nominals, the multiplicity witness is no longer a witness:")
    cnt, ex = separating_formulas(MULT, nominal_valuation, 3,
                                  MULT, nominal_valuation, 4, layers=2)
    print(f"  worlds 3 and 4 of the multiplicity frame: {cnt} separating formulas, "
          f"e.g. {ex[:2]}")


def demo_hennessy_milner_agreement() -> None:
    rule("5.  Hennessy–Milner: refinement and formula enumeration agree everywhere")
    pairs = [
        ("M:3 vs M:4", MULT, 3, MULT, 4),
        ("M:1 vs M:2", MULT, 1, MULT, 2),
        ("M:3 vs M:1", MULT, 3, MULT, 1),
        ("M:0 vs M:1", MULT, 0, MULT, 1),
        ("S:5 vs T:5", SHARE, 5, TREE, 5),
        ("S:3 vs T:4", SHARE, 3, TREE, 4),
        ("S:1 vs T:2", SHARE, 1, TREE, 2),
        ("S:5 vs T:3", SHARE, 5, TREE, 3),
    ]
    all_ok = True
    print(f"  {'pair':<14} {'bisimilar':<11} {'separating formulas':<21} agree")
    for label, f1, m, f2, n in pairs:
        fs = {"A": f1, "B": f2}
        vs = {"A": constant_valuation, "B": constant_valuation}
        ws = [("A", w) for w in sorted(f1.reachable(m))] + \
             [("B", w) for w in sorted(f2.reachable(n))]
        blk = refine(fs, vs, ws, atoms=1)
        bis = blk[("A", m)] == blk[("B", n)]
        cnt, _ = separating_formulas(f1, constant_valuation, m,
                                     f2, constant_valuation, n, layers=3)
        ok = bis == (cnt == 0)
        all_ok = all_ok and ok
        print(f"  {label:<14} {str(bis):<11} {cnt:<21} {'✓' if ok else '✗'}")
    print(f"\n  Hennessy–Milner agreement on all tested pairs: {all_ok}")


def demo_theory_transfer() -> None:
    rule("6.  Truncated theories cannot detect sharing")
    print("The truncated theory at level N is the set of formulas valid at every")
    print("world ≤ N.  For bisimilar frames covering each other's truncations, the")
    print("two theories prove exactly the same formulas.")
    forms = all_formulas(2)
    for N in range(1, 6):
        th_s = {show(a) for a in forms
                if all(sat(SHARE, constant_valuation, m, a) for m in range(N + 1))}
        th_t = {show(a) for a in forms
                if all(sat(TREE, constant_valuation, m, a) for m in range(N + 1))}
        print(f"  N = {N}:  |Th(S)| = {len(th_s):<4} |Th(T)| = {len(th_t):<4} "
              f"equal = {th_s == th_t}")
    print("  …yet the two frames are not isomorphic. Deduction is blind to sharing.")


def main() -> None:
    print(__doc__.split("Run with:")[0].strip())
    demo_multiplicity_gap()
    demo_sharing_refutation()
    demo_depth_ladder()
    demo_naming_budget()
    demo_hennessy_milner_agreement()
    demo_theory_transfer()
    rule("Summary")
    print("  • Modal observation resolves pointed models exactly up to bisimulation.")
    print("  • Isomorphism is strictly finer; out-degree witnesses the first gap.")
    print("  • Multiplicity does NOT close the gap: the shared diamond and its")
    print("    unravelling are bisimilar, degree-matched, and non-isomorphic.")
    print("  • Naming closes it, and costs exactly ⌈log₂ N⌉ atoms.")
    print("  • Depth-k observation suffices on worlds of height ≤ k, sharply.")


if __name__ == "__main__":
    main()
