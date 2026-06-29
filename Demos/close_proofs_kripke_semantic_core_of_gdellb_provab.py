"""
Ordinal Rank as a Functor on GL Frames -- numerical demonstrations.

This self-contained script demonstrates, on concrete finite Gödel-Löb (GL)
frames, the four main results of the package:

  (3.1) rank is monotone under shrinking the accessibility relation;
  (4.3) the diamond rank stratification   : diamond^k(univ) = {w : rank(w) >= k},
        complementing the Loeb stratification: box^k(empty) = {w : rank(w) < k};
  (5.1) the synchronized-product rank is the pointwise minimum of coordinate ranks;
  (6.1) polymodal rank is antitone in the modality index.

A GL frame here is a finite, irreflexive, transitive accessibility relation,
represented as a set of worlds plus a successor function. The ordinal rank of a
world (a natural number on finite frames) is the length of the longest
accessibility chain issuing from it.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import Callable, Dict, FrozenSet, Iterable, List, Set, Tuple

# A world is any hashable object; we use ints and tuples of ints.
World = object


# ---------------------------------------------------------------------------
# GL frame data structure
# ---------------------------------------------------------------------------
class GLFrame:
    """A finite GL frame: worlds + an irreflexive, transitive relation R.

    `R[w]` is the set of worlds accessible from `w` (i.e. {v : w R v}).
    """

    def __init__(self, worlds: Iterable[World],
                 edges: Iterable[Tuple[World, World]]) -> None:
        self.worlds: List[World] = list(worlds)
        self._succ: Dict[World, Set[World]] = {w: set() for w in self.worlds}
        for (w, v) in edges:
            self._succ[w].add(v)
        self._validate()

    def succ(self, w: World) -> Set[World]:
        return self._succ[w]

    def R(self, w: World, v: World) -> bool:
        return v in self._succ[w]

    def _validate(self) -> None:
        # irreflexivity
        for w in self.worlds:
            assert not self.R(w, w), f"irreflexivity violated at {w!r}"
        # transitivity
        for w in self.worlds:
            for v in self.succ(w):
                for u in self.succ(v):
                    assert self.R(w, u), f"transitivity violated: {w!r}->{v!r}->{u!r}"

    # ----- modal operators on sets of worlds -----
    def boxSet(self, S: Set[World]) -> Set[World]:
        """box S = {w : every successor of w lies in S}."""
        return {w for w in self.worlds if self.succ(w) <= S}

    def diamondSet(self, S: Set[World]) -> Set[World]:
        """diamond S = {w : some successor of w lies in S}."""
        return {w for w in self.worlds if self.succ(w) & S}

    def iterate(self, op: Callable[[Set[World]], Set[World]],
                S: Set[World], k: int) -> Set[World]:
        for _ in range(k):
            S = op(S)
        return S

    # ----- ordinal rank (a natural number on finite frames) -----
    def rank(self, w: World, _memo: Dict[World, int] | None = None) -> int:
        """rank(w) = 0 if w is a dead end, else 1 + max rank over successors."""
        if _memo is None:
            _memo = {}
        if w in _memo:
            return _memo[w]
        s = self.succ(w)
        if not s:
            _memo[w] = 0
            return 0
        r = 1 + max(self.rank(v, _memo) for v in s)
        _memo[w] = r
        return r

    def rank_all(self) -> Dict[World, int]:
        memo: Dict[World, int] = {}
        return {w: self.rank(w, memo) for w in self.worlds}


def transitive_closure(worlds: Iterable[World],
                       base_edges: Iterable[Tuple[World, World]]
                       ) -> List[Tuple[World, World]]:
    """Return the transitive closure of `base_edges` (assumed acyclic)."""
    worlds = list(worlds)
    reach: Dict[World, Set[World]] = {w: set() for w in worlds}
    for (a, b) in base_edges:
        reach[a].add(b)
    changed = True
    while changed:
        changed = False
        for a in worlds:
            new = set()
            for b in list(reach[a]):
                new |= reach[b]
            if not new <= reach[a]:
                reach[a] |= new
                changed = True
    return [(a, b) for a in worlds for b in reach[a]]


def synchronized_product(F: GLFrame, G: GLFrame) -> GLFrame:
    """Worlds are pairs; a step requires BOTH coordinates to step."""
    worlds = list(iproduct(F.worlds, G.worlds))
    edges = []
    for (a, b) in worlds:
        for c in F.succ(a):
            for d in G.succ(b):
                edges.append(((a, b), (c, d)))
    return GLFrame(worlds, edges)


# ---------------------------------------------------------------------------
# Demonstration 1 : ordinal rank = longest chain; Loeb soundness sanity check
# ---------------------------------------------------------------------------
def demo_rank_and_loeb() -> None:
    print("=" * 70)
    print("DEMO 1 : ordinal rank as longest accessibility chain")
    print("=" * 70)
    # The canonical frame (0..4 , >) : world n sees all m < n.  rank(n) = n.
    n = 5
    worlds = list(range(n))
    edges = [(a, b) for a in worlds for b in worlds if a > b]
    F = GLFrame(worlds, edges)
    ranks = F.rank_all()
    print("Frame ({0,..,4}, >):  rank(n) should equal n")
    for w in worlds:
        print(f"  rank({w}) = {ranks[w]}")
    assert all(ranks[w] == w for w in worlds)

    # Loeb soundness:  box((box S)^c U S)  subset of  box S.
    def universe() -> Set[int]:
        return set(worlds)

    import random
    random.seed(0)
    for _ in range(200):
        S = {w for w in worlds if random.random() < 0.5}
        boxS = F.boxSet(S)
        antecedent = (universe() - boxS) | S          # (box S)^c U S  =  box S -> S
        assert F.boxSet(antecedent) <= boxS
    print("  Loeb's axiom box(box S -> S) -> box S verified on 200 random S.  OK")
    print()


# ---------------------------------------------------------------------------
# Demonstration 2 : the box / diamond rank stratification (Thms 4.1 & 4.3)
# ---------------------------------------------------------------------------
def demo_stratification() -> None:
    print("=" * 70)
    print("DEMO 2 : box^k(empty) = {rank < k}   and   diamond^k(univ) = {rank >= k}")
    print("=" * 70)
    # A little branching tree so ranks are non-uniform.
    #   a -> b,c ;  b -> d ;  c -> d,e ;  d,e dead ends
    base = [("a", "b"), ("a", "c"), ("b", "d"), ("c", "d"), ("c", "e")]
    worlds = ["a", "b", "c", "d", "e"]
    F = GLFrame(worlds, transitive_closure(worlds, base))
    ranks = F.rank_all()
    print("ranks:", ranks)
    univ = set(worlds)
    empty: Set[str] = set()
    maxk = max(ranks.values()) + 2
    for k in range(maxk + 1):
        boxk = F.iterate(F.boxSet, empty, k)
        diak = F.iterate(F.diamondSet, univ, k)
        lt = {w for w in worlds if ranks[w] < k}
        ge = {w for w in worlds if ranks[w] >= k}
        assert boxk == lt, (k, boxk, lt)
        assert diak == ge, (k, diak, ge)
        assert boxk == univ - diak  # exact complements
        print(f"  k={k}:  box^k(empty)={sorted(boxk)!s:24}  "
              f"diamond^k(univ)={sorted(diak)!s}")
    print("  box^k(empty) = {rank<k}, diamond^k(univ) = {rank>=k}, exact complements. OK")
    print()


# ---------------------------------------------------------------------------
# Demonstration 3 : product rank = pointwise minimum (Thm 5.1)
# ---------------------------------------------------------------------------
def demo_product_min() -> None:
    print("=" * 70)
    print("DEMO 3 : rank(a,b) = min(rank a, rank b) in the synchronized product")
    print("=" * 70)
    # F = chain of length 3 (ranks 0,1,2) ; G = chain of length 4 (ranks 0,1,2,3)
    def chain(m: int) -> GLFrame:
        ws = list(range(m))
        return GLFrame(ws, [(a, b) for a in ws for b in ws if a > b])

    F, G = chain(3), chain(4)
    rF, rG = F.rank_all(), G.rank_all()
    P = synchronized_product(F, G)
    rP = P.rank_all()
    print("  (a,b)   rank_P   min(rank a, rank b)")
    ok = True
    for (a, b) in P.worlds:
        expected = min(rF[a], rG[b])
        flag = "OK" if rP[(a, b)] == expected else "FAIL"
        ok &= rP[(a, b)] == expected
        print(f"  ({a},{b})     {rP[(a,b)]:>3}            {expected:>3}     {flag}")
    assert ok
    print("  rank of every product world equals the minimum of the two coordinates. OK")
    print()


# ---------------------------------------------------------------------------
# Demonstration 4 : polymodal rank is antitone in the level (Thm 6.1)
# ---------------------------------------------------------------------------
def demo_polymodal_antitone() -> None:
    print("=" * 70)
    print("DEMO 4 : polymodal rank is antitone in the modality index")
    print("=" * 70)
    # A GLP frame: nested relations R0 superset R1 superset R2 on worlds 0..4.
    worlds = list(range(5))
    # R0 = full strict order (n > m); R1 keeps only steps of size >= 2;
    # R2 keeps only steps of size >= 3.  Each is irreflexive + transitive.
    def level_frame(min_gap: int) -> GLFrame:
        base = [(a, b) for a in worlds for b in worlds if a - b >= min_gap]
        return GLFrame(worlds, transitive_closure(worlds, base))

    levels = {n: level_frame(min_gap) for n, min_gap in
              {0: 1, 1: 2, 2: 3}.items()}
    ranks = {n: levels[n].rank_all() for n in levels}
    print("  world | rank_0  rank_1  rank_2   (should be non-increasing)")
    for w in worlds:
        row = [ranks[n][w] for n in (0, 1, 2)]
        print(f"    {w}   |   {row[0]}       {row[1]}       {row[2]}")
        assert row[0] >= row[1] >= row[2]
    # also verify the full pairwise statement n <= m => rank_m <= rank_n
    for n in (0, 1, 2):
        for m in (0, 1, 2):
            if n <= m:
                assert all(ranks[m][w] <= ranks[n][w] for w in worlds)
    print("  n <= m  =>  rank_m(w) <= rank_n(w) for all worlds.  OK")
    print()


# ---------------------------------------------------------------------------
# Demonstration 5 : the engine -- rank monotone under shrinking the relation
# ---------------------------------------------------------------------------
def demo_rank_monotone() -> None:
    print("=" * 70)
    print("DEMO 5 : shrinking a well-founded relation can only lower ranks (Thm 3.1)")
    print("=" * 70)
    worlds = list(range(6))
    big_base = [(a, b) for a in worlds for b in worlds if a > b]
    F_big = GLFrame(worlds, transitive_closure(worlds, big_base))
    # remove some edges (keep gaps >= 2) then re-close
    small_base = [(a, b) for a in worlds for b in worlds if a - b >= 2]
    F_small = GLFrame(worlds, transitive_closure(worlds, small_base))
    rb, rs = F_big.rank_all(), F_small.rank_all()
    print("  world | rank(small R)  rank(big R)   (small <= big)")
    for w in worlds:
        print(f"    {w}   |     {rs[w]}             {rb[w]}")
        assert rs[w] <= rb[w]
    print("  every rank under the smaller relation is <= its rank under the larger. OK")
    print()


def main() -> None:
    demo_rank_and_loeb()
    demo_stratification()
    demo_product_min()
    demo_polymodal_antitone()
    demo_rank_monotone()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
