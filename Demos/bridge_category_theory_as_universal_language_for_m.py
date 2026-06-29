"""Numerical demonstration of the topos subobject-lattice results.

This script builds *concrete finite frames* (complete Heyting algebras) and
verifies, by exhaustive computation, every theorem proved in the Phase A Lean
development:

    himp_isGreatest   universal property: a ⇨ c is greatest x with a ⊓ x ≤ c
    le_dneg           a ≤ aᶜᶜ                       (extensive)
    dneg_monotone     a ≤ b ⟹ aᶜᶜ ≤ bᶜᶜ            (monotone)
    dneg_idem         aᶜᶜᶜᶜ = aᶜᶜ                   (idempotent)
    dneg_inf          (a ⊓ b)ᶜᶜ = aᶜᶜ ⊓ bᶜᶜ        (meet-preserving)
    dneg_bot/top      ⊥ᶜᶜ = ⊥ , ⊤ᶜᶜ = ⊤
    isRegular_inf     regular a, b ⟹ regular (a ⊓ b)
    isRegular_iff     regular a ⟺ aᶜᶜ ≤ a
    lfp_dneg_eq_bot   ⋂ {x | dneg x ≤ x}  = ⊥
    gfp_dneg_eq_top   ⋃ {x | x ≤ dneg x}  = ⊤

The frame used is the lattice of *down-sets* (order ideals) of a finite poset.
Down-sets of any poset form a complete Heyting algebra — the Alexandrov-open
sets of a finite topological space — so it is a faithful finite model of the
subobject lattice `Opens X`.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, List, Set, Tuple

# A frame element is a down-closed set of poset points, stored as a frozenset.
Elt = FrozenSet[int]


class Frame:
    """The frame of down-sets of a finite poset (a complete Heyting algebra)."""

    def __init__(self, points: List[int], leq: Callable[[int, int], bool]) -> None:
        self.points: List[int] = points
        self.leq = leq  # leq(p, q) means p ≤ q in the poset
        self.elements: List[Elt] = self._all_downsets()
        self.bot: Elt = frozenset()
        self.top: Elt = frozenset(points)

    def _is_downset(self, s: Set[int]) -> bool:
        # s is down-closed: q ∈ s and p ≤ q ⟹ p ∈ s
        return all(p in s for q in s for p in self.points if self.leq(p, q))

    def _all_downsets(self) -> List[Elt]:
        downs: List[Elt] = []
        n = len(self.points)
        for r in range(n + 1):
            for combo in combinations(self.points, r):
                s = set(combo)
                if self._is_downset(s):
                    downs.append(frozenset(s))
        return downs

    # ---- lattice operations ------------------------------------------------
    def meet(self, a: Elt, b: Elt) -> Elt:
        return a & b

    def join(self, a: Elt, b: Elt) -> Elt:
        return a | b

    def le(self, a: Elt, b: Elt) -> bool:
        return a <= b

    def himp(self, a: Elt, c: Elt) -> Elt:
        """Heyting implication: the join of every element x with a ⊓ x ≤ c.

        In a frame this join itself satisfies the constraint, so it is the
        *greatest* such x (this is exactly `himp_isGreatest`).
        """
        result: Set[int] = set()
        for x in self.elements:
            if self.le(self.meet(a, x), c):
                result |= x
        return frozenset(result)

    def compl(self, a: Elt) -> Elt:
        """Pseudocomplement aᶜ = a ⇨ ⊥."""
        return self.himp(a, self.bot)

    def dneg(self, a: Elt) -> Elt:
        """Double negation aᶜᶜ — the nucleus / regularization operator."""
        return self.compl(self.compl(a))

    def is_regular(self, a: Elt) -> bool:
        return self.dneg(a) == a


def fmt(a: Elt) -> str:
    return "{" + ",".join(map(str, sorted(a))) + "}" if a else "∅"


# ---------------------------------------------------------------------------
# Theorem checkers (each returns True iff the theorem holds on this frame).
# ---------------------------------------------------------------------------

def check_himp_isGreatest(F: Frame) -> bool:
    for a in F.elements:
        for c in F.elements:
            h = F.himp(a, c)
            witnesses = [x for x in F.elements if F.le(F.meet(a, x), c)]
            # membership: a ⊓ h ≤ c
            if not F.le(F.meet(a, h), c):
                return False
            # greatest: every witness is below h
            if not all(F.le(x, h) for x in witnesses):
                return False
    return True


def check_le_dneg(F: Frame) -> bool:
    return all(F.le(a, F.dneg(a)) for a in F.elements)


def check_dneg_monotone(F: Frame) -> bool:
    return all(
        (not F.le(a, b)) or F.le(F.dneg(a), F.dneg(b))
        for a in F.elements
        for b in F.elements
    )


def check_dneg_idem(F: Frame) -> bool:
    return all(F.dneg(F.dneg(a)) == F.dneg(a) for a in F.elements)


def check_dneg_inf(F: Frame) -> bool:
    return all(
        F.dneg(F.meet(a, b)) == F.meet(F.dneg(a), F.dneg(b))
        for a in F.elements
        for b in F.elements
    )


def check_dneg_bounds(F: Frame) -> bool:
    return F.dneg(F.bot) == F.bot and F.dneg(F.top) == F.top


def check_isRegular_inf(F: Frame) -> bool:
    for a in F.elements:
        for b in F.elements:
            if F.is_regular(a) and F.is_regular(b):
                if not F.is_regular(F.meet(a, b)):
                    return False
    return True


def check_isRegular_iff(F: Frame) -> bool:
    return all(
        F.is_regular(a) == F.le(F.dneg(a), a) for a in F.elements
    )


def lfp_dneg(F: Frame) -> Elt:
    """sInf of pre-fixed points {x | dneg x ≤ x} = intersection of them."""
    pre = [x for x in F.elements if F.le(F.dneg(x), x)]
    acc = F.top
    for x in pre:
        acc = F.meet(acc, x)
    return acc


def gfp_dneg(F: Frame) -> Elt:
    """sSup of post-fixed points {x | x ≤ dneg x} = union of them."""
    post = [x for x in F.elements if F.le(x, F.dneg(x))]
    acc = F.bot
    for x in post:
        acc = F.join(acc, x)
    return acc


def run_on(name: str, F: Frame) -> Tuple[str, bool]:
    print(f"\n=== Frame: {name} ===")
    print(f"  elements ({len(F.elements)}): " + ", ".join(fmt(a) for a in F.elements))
    regs = [a for a in F.elements if F.is_regular(a)]
    print(f"  regular elements: " + ", ".join(fmt(a) for a in regs))
    print(f"  example: dneg{fmt(F.elements[1])} = {fmt(F.dneg(F.elements[1]))}")

    checks = {
        "himp_isGreatest": check_himp_isGreatest(F),
        "le_dneg": check_le_dneg(F),
        "dneg_monotone": check_dneg_monotone(F),
        "dneg_idem": check_dneg_idem(F),
        "dneg_inf": check_dneg_inf(F),
        "dneg_bot/dneg_top": check_dneg_bounds(F),
        "isRegular_inf": check_isRegular_inf(F),
        "isRegular_iff": check_isRegular_iff(F),
        "lfp_dneg_eq_bot": lfp_dneg(F) == F.bot,
        "gfp_dneg_eq_top": gfp_dneg(F) == F.top,
    }
    for k, v in checks.items():
        print(f"    [{'PASS' if v else 'FAIL'}] {k}")
    print(f"  lfp(dneg) = {fmt(lfp_dneg(F))}   gfp(dneg) = {fmt(gfp_dneg(F))}")
    return name, all(checks.values())


def main() -> None:
    # (1) Two-element chain 0 < 1: down-sets ∅ ⊂ {0} ⊂ {0,1}.
    #     {0} is NOT regular: dneg{0} = ⊤. This is the intuitionistic phenomenon.
    chain = Frame([0, 1], lambda p, q: p == q or (p == 0 and q == 1))

    # (2) Three-element chain 0 < 1 < 2 (a longer Heyting chain).
    def chain3_leq(p: int, q: int) -> bool:
        return p <= q
    chain3 = Frame([0, 1, 2], chain3_leq)

    # (3) "V" poset: 0 < 2, 1 < 2 (two minimal points under a top).
    def v_leq(p: int, q: int) -> bool:
        if p == q:
            return True
        return q == 2 and p in (0, 1)
    vshape = Frame([0, 1, 2], v_leq)

    # (4) Diamond poset 0 < 1, 0 < 2, 1 < 3, 2 < 3.
    diamond_edges = {(0, 1), (0, 2), (1, 3), (2, 3), (0, 3)}

    def diamond_leq(p: int, q: int) -> bool:
        return p == q or (p, q) in diamond_edges
    diamond = Frame([0, 1, 2, 3], diamond_leq)

    results = [
        run_on("2-chain (0<1)", chain),
        run_on("3-chain (0<1<2)", chain3),
        run_on("V-poset (0<2, 1<2)", vshape),
        run_on("diamond (0<1,2<3)", diamond),
    ]

    print("\n" + "=" * 48)
    ok = all(r[1] for r in results)
    for name, passed in results:
        print(f"  {'ALL PASS' if passed else 'SOME FAIL'} :: {name}")
    print(f"\nOverall: {'ALL THEOREMS VERIFIED' if ok else 'FAILURE DETECTED'}")


if __name__ == "__main__":
    main()
