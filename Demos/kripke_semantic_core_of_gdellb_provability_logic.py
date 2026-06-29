"""
demo.py -- Numerical demonstrations for

    "The Kripke-Semantic Core of Gödel-Löb Provability Logic:
     Ordinal Ranks, Polymodal Reductions, and Categorical Products"

This is a self-contained Python script (standard library only) that reproduces,
on finite frames, every headline result of the package:

  * GL frames: finite, irreflexive, transitive accessibility relations.
  * The box / diamond operators on subsets of worlds.
  * Loeb soundness check:  box((box S)^c  ∪ S)  ⊆  box S.
  * The ordinal (here: natural-number) rank of a world, strictly decreasing
    along accessibility (Theorem `gl_rank_lt_of_R`).
  * The rank-stratification theorem  box^k(∅) = { w | rank w < k }
    (Theorem `boxSet_iterate_eq_rank_lt`), and its two corollaries
    box(∅) = {dead ends}  and  rank w = 0  iff w is a dead end.
  * The canonical frame (ℕ, >) with rank n = n and box^k(∅) = {0,...,k-1}.
  * Polymodal GLP frames: nested relations, box monotone in the level index.
  * The synchronized product: diamond factors (◇(A×B) = ◇A × ◇B) but box does
    NOT factor, with the explicit boolEdge × unitDead witness.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import Callable, Dict, FrozenSet, Hashable, List, Set, Tuple

World = Hashable
Relation = Callable[[World, World], bool]


# --------------------------------------------------------------------------- #
# 1. GL frames                                                                #
# --------------------------------------------------------------------------- #
class GLFrame:
    """A finite GL frame: worlds + a transitive, irreflexive relation R.

    The constructor *verifies* irreflexivity and transitivity, so any instance
    is guaranteed to be a genuine GL frame.
    """

    def __init__(self, worlds: List[World], R: Relation) -> None:
        self.worlds: List[World] = list(worlds)
        self.R: Relation = R
        self._check_irreflexive()
        self._check_transitive()

    def _check_irreflexive(self) -> None:
        for w in self.worlds:
            if self.R(w, w):
                raise ValueError(f"R is reflexive at {w!r}: not a GL frame")

    def _check_transitive(self) -> None:
        for w in self.worlds:
            for v in self.worlds:
                for u in self.worlds:
                    if self.R(w, v) and self.R(v, u) and not self.R(w, u):
                        raise ValueError(
                            f"R not transitive: {w!r}->{v!r}->{u!r}"
                        )

    def successors(self, w: World) -> List[World]:
        return [v for v in self.worlds if self.R(w, v)]

    def is_maximal(self, w: World) -> bool:
        """A dead end: a world with no successors."""
        return len(self.successors(w)) == 0

    # -- modal operators ---------------------------------------------------- #
    def box(self, S: Set[World]) -> Set[World]:
        """box S = { w | every successor of w is in S }."""
        return {w for w in self.worlds if all(v in S for v in self.successors(w))}

    def diamond(self, S: Set[World]) -> Set[World]:
        """diamond S = { w | some successor of w is in S }."""
        return {w for w in self.worlds if any(v in S for v in self.successors(w))}

    # -- ordinal (natural) rank --------------------------------------------- #
    def rank(self, w: World) -> int:
        """rank w = max over successors v of (rank v + 1); dead ends have 0.

        On finite frames the ordinal rank is a natural number computed by the
        recursion of Definition 3.4. Memoized; well-defined because R is acyclic.
        """
        memo: Dict[World, int] = {}

        def go(x: World) -> int:
            if x in memo:
                return memo[x]
            succ = self.successors(x)
            memo[x] = 0 if not succ else 1 + max(go(v) for v in succ)
            return memo[x]

        return go(w)

    # -- iterated box ------------------------------------------------------- #
    def box_iterate(self, S: Set[World], k: int) -> Set[World]:
        out: Set[World] = set(S)
        for _ in range(k):
            out = self.box(out)
        return out


# --------------------------------------------------------------------------- #
# 2. Checks of the main theorems on a frame                                   #
# --------------------------------------------------------------------------- #
def all_subsets(worlds: List[World]) -> List[FrozenSet[World]]:
    subs: List[FrozenSet[World]] = []
    n = len(worlds)
    for mask in range(1 << n):
        subs.append(frozenset(worlds[i] for i in range(n) if mask & (1 << i)))
    return subs


def check_loeb(F: GLFrame) -> bool:
    """Verify  box((box S)^c ∪ S) ⊆ box S  for ALL subsets S (Theorem 2.6)."""
    U = set(F.worlds)
    for S in all_subsets(F.worlds):
        Sset = set(S)
        boxS = F.box(Sset)
        impl = (U - boxS) | Sset           # (box S)^c ∪ S  =  box S -> S
        if not F.box(impl).issubset(boxS):
            return False
    return True


def check_rank_descent(F: GLFrame) -> bool:
    """Verify rank v < rank w whenever R w v (Theorem 3.5)."""
    return all(
        F.rank(v) < F.rank(w)
        for w in F.worlds
        for v in F.successors(w)
    )


def check_rank_stratification(F: GLFrame, kmax: int) -> bool:
    """Verify box^k(∅) = { w | rank w < k } for 0 <= k <= kmax (Theorem 5.3)."""
    for k in range(kmax + 1):
        lhs = F.box_iterate(set(), k)
        rhs = {w for w in F.worlds if F.rank(w) < k}
        if lhs != rhs:
            return False
    return True


def check_box_empty_is_maximal(F: GLFrame) -> bool:
    """Verify box(∅) = {dead ends} and rank 0 iff maximal (Lemmas 5.1, 5.2)."""
    deads = {w for w in F.worlds if F.is_maximal(w)}
    rank0 = {w for w in F.worlds if F.rank(w) == 0}
    return F.box(set()) == deads == rank0


# --------------------------------------------------------------------------- #
# 3. The canonical frame (ℕ, >)  truncated to {0,...,N-1}                      #
# --------------------------------------------------------------------------- #
def nat_frame(N: int) -> GLFrame:
    """Worlds 0..N-1 with R n m  iff  n > m (the converse-well-founded (ℕ,>))."""
    return GLFrame(list(range(N)), lambda n, m: n > m)


# --------------------------------------------------------------------------- #
# 4. Polymodal GLP frames                                                     #
# --------------------------------------------------------------------------- #
class GLPFrame:
    """A polymodal GLP frame: one world set, a nested family R_0 ⊇ R_1 ⊇ ...

    `R(n, w, v)` is the n-th accessibility relation; each is irreflexive and
    transitive, and R(n+1) ⊆ R(n).
    """

    def __init__(self, worlds: List[World],
                 R: Callable[[int, World, World], bool],
                 levels: int) -> None:
        self.worlds = list(worlds)
        self.R = R
        self.levels = levels

    def level(self, n: int) -> GLFrame:
        """The n-th level as an ordinary GL frame."""
        return GLFrame(self.worlds, lambda w, v, n=n: self.R(n, w, v))

    def check_nesting(self) -> bool:
        return all(
            (not self.R(n + 1, w, v)) or self.R(n, w, v)
            for n in range(self.levels - 1)
            for w in self.worlds
            for v in self.worlds
        )

    def check_box_monotone_in_level(self, S: Set[World]) -> bool:
        """Verify box_n S ⊆ box_m S for n <= m (Theorem 7.5)."""
        for n in range(self.levels):
            for m in range(n, self.levels):
                if not self.level(n).box(S).issubset(self.level(m).box(S)):
                    return False
        return True


# --------------------------------------------------------------------------- #
# 5. Synchronized product and box/diamond factorization                       #
# --------------------------------------------------------------------------- #
def synchronized_product(F: GLFrame, G: GLFrame) -> GLFrame:
    worlds: List[World] = list(iproduct(F.worlds, G.worlds))
    def R(p: Tuple[World, World], q: Tuple[World, World]) -> bool:
        return F.R(p[0], q[0]) and G.R(p[1], q[1])
    return GLFrame(worlds, R)


def rectangle(A: Set[World], B: Set[World]) -> Set[Tuple[World, World]]:
    return {(a, b) for a in A for b in B}


def check_diamond_factors(F: GLFrame, G: GLFrame,
                          A: Set[World], B: Set[World]) -> bool:
    """Verify ◇(A×B) = ◇A × ◇B in the product (Theorem 6.3)."""
    P = synchronized_product(F, G)
    lhs = P.diamond(rectangle(A, B))
    rhs = rectangle(F.diamond(A), G.diamond(B))
    return lhs == rhs


def box_factor_report(F: GLFrame, G: GLFrame,
                      A: Set[World], B: Set[World]
                      ) -> Tuple[bool, bool, Set[Tuple[World, World]]]:
    """Return (subset_holds, equality_holds, witnesses) for box factorization.

    By Theorem 6.4 the rectangle-of-boxes is always a subset of the box-of-the-
    rectangle; equality can fail.  `witnesses` are the points in the strict gap.
    """
    P = synchronized_product(F, G)
    box_rect = P.box(rectangle(A, B))
    rect_box = rectangle(F.box(A), G.box(B))
    subset_holds = rect_box.issubset(box_rect)
    equality_holds = (rect_box == box_rect)
    witnesses = box_rect - rect_box
    return subset_holds, equality_holds, witnesses


# --------------------------------------------------------------------------- #
# 6. Driver                                                                   #
# --------------------------------------------------------------------------- #
def demo_canonical() -> None:
    print("=" * 70)
    print("1. Canonical frame (N, >) truncated to {0,...,7}")
    print("=" * 70)
    F = nat_frame(8)
    print("rank(n) for n = 0..7:", [F.rank(n) for n in range(8)])
    print("  -> rank n == n :", all(F.rank(n) == n for n in range(8)))
    for k in range(5):
        Sk = sorted(F.box_iterate(set(), k))
        print(f"  box^{k}(empty) = {Sk}  (expected {list(range(k))})")
    print("  Loeb soundness holds for all subsets :", check_loeb(F))
    print("  rank descent along R                 :", check_rank_descent(F))
    print("  rank stratification box^k=∅<k        :",
          check_rank_stratification(F, 8))
    print("  box(∅)=dead ends=rank0               :",
          check_box_empty_is_maximal(F))


def demo_branching() -> None:
    print()
    print("=" * 70)
    print("2. A branching GL frame (not a linear order)")
    print("=" * 70)
    # Worlds: top sees a and b; a sees leaf; b is a dead end; leaf dead.
    #   top -> a -> leaf ;  top -> b ; top -> leaf (transitive closure)
    edges = {
        ("top", "a"), ("top", "b"), ("top", "leaf"),
        ("a", "leaf"),
    }
    worlds = ["top", "a", "b", "leaf"]
    F = GLFrame(worlds, lambda w, v: (w, v) in edges)
    for w in worlds:
        print(f"  rank({w!r}) = {F.rank(w)}  maximal={F.is_maximal(w)}")
    print("  Loeb soundness                :", check_loeb(F))
    print("  rank descent along R          :", check_rank_descent(F))
    print("  rank stratification           :", check_rank_stratification(F, 4))
    print("  box(∅)=dead ends=rank0        :", check_box_empty_is_maximal(F))


def demo_polymodal() -> None:
    print()
    print("=" * 70)
    print("3. Polymodal GLP frame: box monotone in the level index")
    print("=" * 70)
    # Worlds 0..3. R_n relates a>b only when (a - b) > n : strictly nested.
    worlds = [0, 1, 2, 3]
    def R(n: int, w: int, v: int) -> bool:
        return (w - v) > n
    G = GLPFrame(worlds, R, levels=4)
    print("  nesting R_{n+1} ⊆ R_n         :", G.check_nesting())
    S = {0, 1}
    print("  box_n S ⊆ box_m S for n<=m    :",
          G.check_box_monotone_in_level(S))
    for n in range(4):
        print(f"    box_{n}({sorted(S)}) = {sorted(G.level(n).box(S))}")


def demo_product() -> None:
    print()
    print("=" * 70)
    print("4. Synchronized product: diamond factors, box does NOT")
    print("=" * 70)
    boolEdge = GLFrame([True, False], lambda x, y: (x is True) and (y is False))
    unitDead = GLFrame(["()"], lambda x, y: False)

    A: Set[World] = {True}
    B: Set[World] = {"()"}  # univ of unitDead

    print("  diamond factors  ◇(A×B)=◇A×◇B :",
          check_diamond_factors(boolEdge, unitDead, A, B))

    subset_ok, eq_ok, witnesses = box_factor_report(boolEdge, unitDead, A, B)
    print("  box subset       (□A)×(□B) ⊆ □(A×B):", subset_ok)
    print("  box equality holds                 :", eq_ok)
    print("  strict witnesses in □(A×B)\\(□A×□B) :", sorted(map(str, witnesses)))

    # Edgeless coincidence: box factors when both frames are edgeless.
    dead2 = GLFrame([0, 1], lambda x, y: False)
    _, eq_edgeless, _ = box_factor_report(dead2, unitDead, {0}, {"()"})
    print("  box factors when both edgeless     :", eq_edgeless)


def main() -> None:
    demo_canonical()
    demo_branching()
    demo_polymodal()
    demo_product()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
