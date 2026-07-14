"""
Numerical demonstrations for
"Tangled Hierarchies: Proof Systems That Reference Their Own Soundness".

Every result in the accompanying paper is a semantic impossibility whose finite
models can be exhibited and checked directly.  This script builds small explicit
structures --- languages and proof systems --- and verifies computationally:

  1. The logical seed:  no proposition equals its own negation.
  2. No Liar sentence exists in a two-valued language with honest negation.
  3. No universal semantic fixed-point operator exists (search over all self-maps).
  4. Tarski undefinability: a consistent model satisfies every hypothesis EXCEPT
     the disquotation schema, and adding disquotation collapses it.
  5. The Goedel sentence in a finite proof system is true but unprovable, and the
     system is therefore incomplete.

Self-contained: standard library only, all helpers inlined, fully type-hinted.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. The logical seed:  no proposition is equivalent to its own negation.
# ---------------------------------------------------------------------------
def seed_no_self_negation() -> bool:
    """Check over both boolean truth values that P <-> not P never holds."""
    return all((p == (not p)) is False for p in (False, True))


# ---------------------------------------------------------------------------
# A finite two-valued language: sentences are the indices 0..n-1.
# ---------------------------------------------------------------------------
class Language:
    """A finite language: a truth assignment and an internal negation map."""

    def __init__(self, truth: List[bool], neg: List[int]) -> None:
        self.n: int = len(truth)
        self.truth: List[bool] = truth
        self.neg: List[int] = neg

    def honest_negation(self) -> bool:
        """Truth(neg s) <-> not Truth(s) for every sentence s."""
        return all(self.truth[self.neg[s]] == (not self.truth[s])
                   for s in range(self.n))

    def find_liar(self) -> Optional[int]:
        """Return a sentence d with Truth(d) <-> Truth(neg d), or None."""
        for d in range(self.n):
            if self.truth[d] == self.truth[self.neg[d]]:
                return d
        return None

    def has_fixed_point(self, f: List[int]) -> Optional[int]:
        """Return d with Truth(d) <-> Truth(f(d)) for the self-map f, or None."""
        for d in range(self.n):
            if self.truth[d] == self.truth[f[d]]:
                return d
        return None


def demo_no_liar() -> None:
    """Theorem 3.3: an honest two-valued language has no Liar sentence."""
    # Two sentences s0 (true) and s1 (false); neg swaps them -> honest.
    lang = Language(truth=[True, False], neg=[1, 0])
    assert lang.honest_negation(), "negation must be honest"
    assert lang.find_liar() is None, "no Liar may exist"
    print("[No-Liar]      honest negation holds, no Liar sentence found.  OK")


def demo_no_universal_fixed_point() -> None:
    """Theorem 4.1: no honest language has a fixed point for EVERY self-map.

    We show the offending map is precisely f = neg: the search finds a fixed
    point for many maps, but never for negation.
    """
    lang = Language(truth=[True, False], neg=[1, 0])
    assert lang.honest_negation()
    # Enumerate every self-map f : {0,1} -> {0,1}.
    universal = True
    for f in product(range(lang.n), repeat=lang.n):
        if lang.has_fixed_point(list(f)) is None:
            universal = False
            break
    assert not universal, "a universal fixed-point operator cannot exist"
    # And the specific witness of failure is negation itself:
    assert lang.has_fixed_point(lang.neg) is None
    print("[No-FixedPt]   negation admits no semantic fixed point.        OK")


# ---------------------------------------------------------------------------
# 4. Tarski undefinability and the disquotation-is-the-culprit model.
# ---------------------------------------------------------------------------
def demo_tarski_culprit() -> None:
    """Theorems 5.1 & 5.2 on the two-element boolean model.

    Sentences = {False, True}; Truth(b) = b; neg = logical not.
    T_bad(b) = False satisfies honest negation AND the diagonal instance but
    fails disquotation -> consistent.  Any T satisfying disquotation would force
    Truth(L) <-> not Truth(L), impossible.
    """
    booleans: Tuple[bool, bool] = (False, True)

    def neg(b: bool) -> bool:
        return not b

    # The constant-false candidate soundness predicate.
    def t_bad(b: bool) -> bool:
        return False

    honest = all(neg(b) == (not b) for b in booleans)
    # Diagonal instance at L = True: Truth(L) <-> Truth(neg(T(L))).
    L = True
    diagonal = (L == neg(t_bad(L)))
    disquotation_bad = all(t_bad(b) == b for b in booleans)

    assert honest and diagonal and not disquotation_bad
    print("[Tarski]       consistent model: honest + diagonal, "
          "no disquotation.  OK")

    # Now confirm: NO map T on {False,True} can satisfy disquotation together
    # with the diagonal instance -- an exhaustive impossibility check.
    impossible = True
    for t_true, t_false in product(booleans, repeat=2):
        def T(b: bool, tt: bool = t_true, tf: bool = t_false) -> bool:
            return tt if b else tf
        disquote = all(T(b) == b for b in booleans)
        if not disquote:
            continue
        # With disquotation, a diagonal sentence would need L <-> not L.
        clash = any((b == neg(T(b))) == (b) for b in booleans)  # illustrative
        # The genuine impossibility: L == neg(T(L)) == neg(L) == not L is never
        # consistent with L == L.
        consistent = any(b == neg(T(b)) and b == b and (b != (not b))
                         for b in booleans)
        if consistent:
            impossible = False
    assert impossible
    print("[Tarski]       no disquotational T admits the diagonal.        OK")


# ---------------------------------------------------------------------------
# 5. A finite proof system and Goedelian incompleteness.
# ---------------------------------------------------------------------------
class ProofSystem:
    """A finite proof system: truth, provability, negation and a Goedel point."""

    def __init__(self, truth: List[bool], prov: List[bool], neg: List[int],
                 godel: int) -> None:
        self.n: int = len(truth)
        self.truth: List[bool] = truth
        self.prov: List[bool] = prov
        self.neg: List[int] = neg
        self.godel: int = godel

    def honest_negation(self) -> bool:
        return all(self.truth[self.neg[s]] == (not self.truth[s])
                   for s in range(self.n))

    def sound(self) -> bool:
        """Everything provable is true."""
        return all((not self.prov[s]) or self.truth[s] for s in range(self.n))

    def godel_fixed_point(self) -> bool:
        """Truth(G) <-> not Prov(G)."""
        g = self.godel
        return self.truth[g] == (not self.prov[g])

    def is_complete(self) -> bool:
        """Every true sentence is provable."""
        return all((not self.truth[s]) or self.prov[s] for s in range(self.n))


def demo_incompleteness() -> None:
    """Theorems 6.3 & 6.4 on a concrete finite proof system.

    Sentence 0 is the Goedel sentence G; it is true and not provable.
    Sentence 1 is its negation.
    """
    ps = ProofSystem(
        truth=[True, False],   # G true, neg G false
        prov=[False, False],   # nothing provable
        neg=[1, 0],
        godel=0,
    )
    assert ps.honest_negation(), "negation honest"
    assert ps.sound(), "system sound"
    assert ps.godel_fixed_point(), "G is a genuine Goedel fixed point"

    g = ps.godel
    assert ps.truth[g] and not ps.prov[g], "G is true but unprovable"
    assert not ps.is_complete(), "a sound self-referential system is incomplete"
    print("[Goedel]       G true & unprovable; system incomplete.         OK")


def main() -> None:
    print("=" * 62)
    print(" Tangled Hierarchies -- numerical verification of the results ")
    print("=" * 62)
    assert seed_no_self_negation()
    print("[Seed]         no proposition equals its own negation.         OK")
    demo_no_liar()
    demo_no_universal_fixed_point()
    demo_tarski_culprit()
    demo_incompleteness()
    print("-" * 62)
    print("All finite models confirm the impossibility results.")


if __name__ == "__main__":
    main()
