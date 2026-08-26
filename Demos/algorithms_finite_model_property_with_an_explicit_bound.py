"""Reference implementations of the three procedures behind the finite model property.

  1. ``bounded_model_search``      -- the decision procedure guaranteed by the theorem.
  2. ``filtrate``                  -- the compatibility-preserving filtration.
  3. ``finite_canonical_model``    -- the finite canonical model over a subformula closure.

Each is written against the same tiny data model of formulas and frames, is fully type
hinted, and is exercised by ``self_test`` at the bottom.

Run:  python3 algorithms.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, FrozenSet, Iterator, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# Shared data model
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Form:
    """A formula of temporal Godel-Lob logic.

    ``kind`` is one of ``atom``, ``bot``, ``imp``, ``box``, ``glob``.
    """

    kind: str
    idx: int = -1
    args: Tuple["Form", ...] = ()

    def __str__(self) -> str:
        if self.kind == "atom":
            return "pqr"[self.idx]
        if self.kind == "bot":
            return "F"
        if self.kind == "imp":
            a, b = self.args
            return f"~{a}" if b.kind == "bot" else f"({a}->{b})"
        if self.kind == "box":
            return f"[]{self.args[0]}"
        return f"[T]{self.args[0]}"


def Atom(i: int) -> Form:
    """Propositional atom ``p_i``."""
    return Form("atom", i)


Bot: Form = Form("bot")


def Imp(a: Form, b: Form) -> Form:
    """Implication ``a -> b``."""
    return Form("imp", -1, (a, b))


def Neg(a: Form) -> Form:
    """Negation ``a -> F``."""
    return Imp(a, Bot)


def Box(a: Form) -> Form:
    """Provability box ``[]a``."""
    return Form("box", -1, (a,))


def Glob(a: Form) -> Form:
    """Temporal box ``[T]a``."""
    return Form("glob", -1, (a,))


def subformulas(a: Form) -> FrozenSet[Form]:
    """The subformula closure of ``a``, including ``a`` itself."""
    out: Set[Form] = {a}
    for s in a.args:
        out |= subformulas(s)
    return frozenset(out)


def subformula_count(a: Form) -> int:
    """``sub(A)``: the number of distinct subformulas -- the bound parameter."""
    return len(subformulas(a))


@dataclass(frozen=True)
class Frame:
    """A finite frame on worlds ``0..n-1``, relations given as sets of ordered pairs."""

    n: int
    R: FrozenSet[Tuple[int, int]]
    T: FrozenSet[Tuple[int, int]]


Valuation = Dict[int, FrozenSet[int]]


def is_legal(f: Frame) -> bool:
    """Check the five temporal Godel-Lob frame conditions.

    R transitive; R converse well-founded (on a finite carrier: irreflexive, given
    transitivity); T reflexive; T transitive; and compatibility
    ``T(w,w') and R(w',v) => R(w,v)``.
    """
    n = f.n
    if any((w, w) in f.R for w in range(n)):
        return False
    if any((w, w) not in f.T for w in range(n)):
        return False
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if (a, b) in f.R and (b, c) in f.R and (a, c) not in f.R:
                    return False
                if (a, b) in f.T and (b, c) in f.T and (a, c) not in f.T:
                    return False
                if (a, b) in f.T and (b, c) in f.R and (a, c) not in f.R:
                    return False
    return True


def sat(f: Frame, val: Valuation, a: Form, w: int) -> bool:
    """Satisfaction of ``a`` at world ``w``."""
    if a.kind == "atom":
        return w in val.get(a.idx, frozenset())
    if a.kind == "bot":
        return False
    if a.kind == "imp":
        return (not sat(f, val, a.args[0], w)) or sat(f, val, a.args[1], w)
    if a.kind == "box":
        return all(sat(f, val, a.args[0], v) for v in range(f.n) if (w, v) in f.R)
    return all(sat(f, val, a.args[0], v) for v in range(f.n) if (w, v) in f.T)


# ---------------------------------------------------------------------------
# Algorithm 1 -- exhaustive bounded model search
# ---------------------------------------------------------------------------


def all_frames(n: int) -> Iterator[Frame]:
    """Enumerate every legal frame on exactly ``n`` worlds.

    The provability relation is generated only over off-diagonal pairs, since
    irreflexivity is forced, and is pruned for transitivity before the temporal
    relation is enumerated at all.  Cost: O(2^(n^2 - n) * 2^(n^2) * n^3) in the worst
    case, which is practical for n <= 3.
    """
    off = [(i, j) for i in range(n) for j in range(n) if i != j]
    allp = [(i, j) for i in range(n) for j in range(n)]
    for rb in product([False, True], repeat=len(off)):
        R = frozenset(p for p, b in zip(off, rb) if b)
        if any((a, c) not in R for (a, b) in R for c in range(n) if (b, c) in R):
            continue
        for tb in product([False, True], repeat=len(allp)):
            T = frozenset(p for p, b in zip(allp, tb) if b)
            fr = Frame(n, R, T)
            if is_legal(fr):
                yield fr


def bounded_model_search(
    a: Form, max_worlds: Optional[int] = None
) -> Optional[Tuple[Frame, Valuation, int]]:
    """Decide derivability of ``a`` by exhaustive search over bounded models.

    Returns the first countermodel found as ``(frame, valuation, refuting world)``, or
    ``None`` if none exists within the bound.  With ``max_worlds = 2 ** (2 *
    subformula_count(a))`` the answer ``None`` is a *proof* that ``a`` is derivable, by
    the finite model property with an explicit bound.  The default caps the search at 3
    worlds, which is what is computationally feasible; the bound is what makes the
    procedure correct in principle, not fast in practice.
    """
    if max_worlds is None:
        max_worlds = 3
    ids = sorted({s.idx for s in subformulas(a) if s.kind == "atom"})
    for n in range(1, max_worlds + 1):
        subsets = [frozenset(w for w in range(n) if (m >> w) & 1) for m in range(1 << n)]
        for fr in all_frames(n):
            for combo in product(subsets, repeat=len(ids)):
                val: Valuation = dict(zip(ids, combo))
                for w in range(n):
                    if not sat(fr, val, a, w):
                        return (fr, val, w)
    return None


# ---------------------------------------------------------------------------
# Algorithm 2 -- filtration
# ---------------------------------------------------------------------------


def filt_R(closure: FrozenSet[Form], S: FrozenSet[Form], Sp: FrozenSet[Form]) -> bool:
    """The filtered accessibility relation.

    ``S`` sees ``S'`` iff (forth) every boxed formula of the closure realised at ``S``
    is realised at ``S'`` together with its argument, and (strict) at least one boxed
    formula of the closure is realised at ``S'`` but not at ``S``.  The strictness
    clause forces the box-count to increase, which is what recovers converse
    well-foundedness on the quotient.
    """
    boxes = [c for c in closure if c.kind == "box"]
    forth = all((c.args[0] in Sp and c in Sp) for c in boxes if c in S)
    strict = any((c in Sp and c not in S) for c in boxes)
    return forth and strict


def filt_T(closure: FrozenSet[Form], S: FrozenSet[Form], Sp: FrozenSet[Form]) -> bool:
    """The filtered temporal relation, with the []-persistence clause.

    Besides transmitting each temporally boxed formula together with its argument, the
    relation demands that every boxed formula realised at ``S`` still be realised at
    ``S'``.  Without this clause the compatibility condition does not survive
    quotienting; with it, compatibility is immediate.
    """
    globs = [c for c in closure if c.kind == "glob"]
    boxes = [c for c in closure if c.kind == "box"]
    forth = all((c.args[0] in Sp and c in Sp) for c in globs if c in S)
    persist = all(c in Sp for c in boxes if c in S)
    return forth and persist


def box_count(closure: FrozenSet[Form], S: FrozenSet[Form]) -> int:
    """The measure ``beta(S)``: how many boxed formulas of the closure hold at ``S``."""
    return sum(1 for c in closure if c.kind == "box" and c in S)


def filtrate(
    f: Frame, val: Valuation, a: Form
) -> Tuple[Frame, Valuation, List[FrozenSet[Form]], Dict[int, int]]:
    """Filtrate the model ``(f, val)`` through the subformulas of ``a``.

    Complexity: O(|f| * sub(a)) to compute the subformula theories with memoised
    satisfaction, then O(m^2 * sub(a)) to build the two relations, where m <=
    2^sub(a) is the number of distinct theories.  The output is guaranteed to be a
    legal frame, to have at most 2^sub(a) worlds, and to agree with the input on every
    subformula of ``a`` at every world.
    """
    closure = subformulas(a)
    thetas: List[FrozenSet[Form]] = []
    index: Dict[FrozenSet[Form], int] = {}
    quotient: Dict[int, int] = {}
    for w in range(f.n):
        th = frozenset(s for s in closure if sat(f, val, s, w))
        if th not in index:
            index[th] = len(thetas)
            thetas.append(th)
        quotient[w] = index[th]
    m = len(thetas)
    R = frozenset(
        (i, j) for i in range(m) for j in range(m) if filt_R(closure, thetas[i], thetas[j])
    )
    T = frozenset(
        (i, j) for i in range(m) for j in range(m) if filt_T(closure, thetas[i], thetas[j])
    )
    ids = {s.idx for s in closure if s.kind == "atom"}
    fval: Valuation = {
        p: frozenset(i for i in range(m) if Atom(p) in thetas[i]) for p in ids
    }
    return Frame(m, R, T), fval, thetas, quotient


# ---------------------------------------------------------------------------
# Algorithm 3 -- the finite canonical model
# ---------------------------------------------------------------------------


def coherent(closure: FrozenSet[Form], t: FrozenSet[Form]) -> bool:
    """Necessary conditions for a decided subset to be a canonical world.

    Falsity is never asserted; an implication of the closure belongs to the world iff
    its antecedent is absent or its consequent present; and a temporally boxed formula
    of the world carries its argument, since ``[T]B -> B`` is an axiom.  These are the
    cheap filters that prune the 2^|closure| subsets before any derivability test.  The
    last clause is exactly what reflexivity of time needs on the constructed frame.
    """
    if Bot in t:
        return False
    for c in closure:
        if c.kind == "imp":
            left, right = c.args
            if left in closure and right in closure:
                if (c in t) != ((left not in t) or (right in t)):
                    return False
        if c.kind == "glob" and c in t and c.args[0] not in t:
            return False
    return True


def finite_canonical_model(a: Form) -> Tuple[Frame, Valuation, List[FrozenSet[Form]]]:
    """Build the finite canonical model over the subformula closure of ``a``.

    Worlds are the coherent decided subsets of the closure -- at most 2^sub(a) of them,
    which is where the bound comes from -- connected by the *same* two filtration
    relations.  Converse well-foundedness is then automatic from the strict growth of
    the box-count, and reflexivity of time is exactly the coherence clause for ``[T]``.
    Complexity: O(2^sub(a) * sub(a)) to enumerate and filter the worlds, then
    O(4^sub(a) * sub(a)) to build the relations.
    """
    closure = subformulas(a)
    items = sorted(closure, key=str)
    worlds = [
        t
        for t in (
            frozenset(x for i, x in enumerate(items) if (m >> i) & 1)
            for m in range(1 << len(items))
        )
        if coherent(closure, t)
    ]
    k = len(worlds)
    R = frozenset(
        (i, j) for i in range(k) for j in range(k) if filt_R(closure, worlds[i], worlds[j])
    )
    T = frozenset(
        (i, j) for i in range(k) for j in range(k) if filt_T(closure, worlds[i], worlds[j])
    )
    ids = {s.idx for s in closure if s.kind == "atom"}
    val: Valuation = {p: frozenset(i for i in range(k) if Atom(p) in worlds[i]) for p in ids}
    return Frame(k, R, T), val, worlds


# ---------------------------------------------------------------------------
# Self test
# ---------------------------------------------------------------------------


def self_test() -> None:
    """Exercise all three algorithms and report."""
    p = Atom(0)

    print("Algorithm 1 -- exhaustive bounded model search")
    for label, form, expect in [
        ("Lob's axiom", Imp(Box(Imp(Box(p), p)), Box(p)), None),
        ("4 for []", Imp(Box(p), Box(Box(p))), None),
        ("interaction", Imp(Box(p), Glob(Box(p))), None),
        ("consistency []F->F", Imp(Box(Bot), Bot), 1),
        ("collapse [T]p->[]p", Imp(Glob(p), Box(p)), 2),
    ]:
        res = bounded_model_search(form)
        got = None if res is None else res[0].n
        print(f"   {label:<22} minimal countermodel: {got}   (expected {expect})")
        assert got == expect, label

    print()
    print("Algorithm 2 -- filtration")
    target = Imp(Glob(p), Box(p))
    fr = Frame(4, frozenset({(0, 1), (0, 2), (1, 2)}), frozenset({(w, w) for w in range(4)}))
    assert is_legal(fr)
    val: Valuation = {0: frozenset({0, 1, 3})}
    g, gval, thetas, quotient = filtrate(fr, val, target)
    assert is_legal(g), "the filtered frame must be legal"
    closure = subformulas(target)
    for w in range(fr.n):
        for s in closure:
            assert sat(g, gval, s, quotient[w]) == sat(fr, val, s, w)
    print(f"   {fr.n} worlds -> {g.n} theories; filtered frame legal; truth lemma verified")
    for i, th in enumerate(thetas):
        print(f"     S{i}: beta={box_count(closure, th)}  "
              f"{{{', '.join(sorted(str(x) for x in th))}}}")

    print()
    print("Algorithm 3 -- the finite canonical model")
    for form in [Imp(Box(Bot), Bot), Imp(Glob(p), Box(p)), Imp(Box(p), Box(Box(p)))]:
        cf, cval, worlds = finite_canonical_model(form)
        sc = subformula_count(form)
        print(
            f"   {str(form):<20} closure {sc}, 2^{sc}={2 ** sc} subsets, "
            f"{len(worlds)} coherent worlds, legal frame: {is_legal(cf)}"
        )
        assert is_legal(cf)
        assert len(worlds) <= 2**sc

    print()
    print("all self tests passed")


if __name__ == "__main__":
    self_test()
