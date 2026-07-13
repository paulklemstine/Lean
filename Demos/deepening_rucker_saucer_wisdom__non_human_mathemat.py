"""
demo.py -- Numerical demonstrations of Universal Mathematics.

This self-contained script illustrates the main results of
"Universal Mathematics: The Invariant Core Shared by Every Consistent Theory".

We model:
  * statements as elements of a finite universe (frozensets over a ground set),
  * a consequence operator C : P(S) -> P(S) satisfying Tarski's axioms
      (1) inclusion   : G subset of C(G)
      (2) monotone    : G subset of D  =>  C(G) subset of C(D)
      (3) idempotence : C(C(G)) subset of C(G),
  * consistency      : C(G) != S  (the theory does not prove everything),
  * the universal core:
      Universal(base) = intersection of C(D) over all consistent D >= base.

Main theorems demonstrated:
  Theorem A  (universality of base) : base <= D consistent => C(base) <= C(D)
  Theorem B  (core equals base)     : base consistent => Universal(base) = C(base)
  Theorem C  (downward consistency) : base <= D, D consistent => base consistent

Every function is inlined; no external dependencies beyond the standard library.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, FrozenSet, Iterator, List, Set, Tuple

# A theory is a frozenset of "statements" (here, integers).
Theory = FrozenSet[int]
Consequence = Callable[[Theory], Theory]


def powerset(universe: FrozenSet[int]) -> Iterator[Theory]:
    """Yield every subset of the given finite universe as a frozenset."""
    elems: List[int] = sorted(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            yield frozenset(combo)


def verify_closure_axioms(C: Consequence, universe: FrozenSet[int]) -> bool:
    """Check the three Tarski/closure axioms exhaustively over the universe."""
    subsets: List[Theory] = list(powerset(universe))
    for g in subsets:
        # (1) inclusion
        if not g <= C(g):
            return False
        # (3) idempotence (equality; inclusion one way is enough with (1))
        if C(C(g)) != C(g):
            return False
    for g in subsets:
        for d in subsets:
            if g <= d and not (C(g) <= C(d)):  # (2) monotonicity
                return False
    return True


def is_consistent(C: Consequence, universe: FrozenSet[int], theory: Theory) -> bool:
    """A theory is consistent iff its closure is not the whole universe."""
    return C(theory) != universe


def consistent_extensions(
    C: Consequence, universe: FrozenSet[int], base: Theory
) -> Iterator[Theory]:
    """Yield every consistent theory D with base <= D <= universe."""
    for d in powerset(universe):
        if base <= d and is_consistent(C, universe, d):
            yield d


def universal_core(C: Consequence, universe: FrozenSet[int], base: Theory) -> Theory:
    """Universal(base) = intersection of C(D) over consistent extensions D of base."""
    core: Set[int] = set(universe)  # start with everything, then intersect
    found = False
    for d in consistent_extensions(C, universe, base):
        core &= set(C(d))
        found = True
    if not found:
        # No consistent extension: intersection over empty family = universe.
        return universe
    return frozenset(core)


# ---------------------------------------------------------------------------
# Example consequence operators.
# ---------------------------------------------------------------------------

def make_identity_C() -> Consequence:
    """Identity ('no deduction') system: C(G) = G. The witness model of the paper."""
    return lambda g: g


def make_threshold_C(universe: FrozenSet[int], trigger: int, unlock: int) -> Consequence:
    """
    A non-trivial closure operator: if 'trigger' is assumed, 'unlock' is deduced.
    C(G) = G, plus {unlock} whenever trigger in G. This is a genuine closure
    operator (adding a fixed implication) and lets deduction do real work.
    """
    def C(g: Theory) -> Theory:
        s = set(g)
        if trigger in s:
            s.add(unlock)
        return frozenset(s & set(universe))
    return C


def make_explosive_C(universe: FrozenSet[int], contradiction: FrozenSet[int]) -> Consequence:
    """
    An operator with 'explosion': if the theory contains the contradiction set,
    it proves everything (becomes inconsistent); otherwise it is the identity.
    Models the classical link between contradiction and triviality.
    """
    def C(g: Theory) -> Theory:
        if contradiction <= g:
            return universe
        return g
    return C


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_identity_system() -> None:
    print("=" * 70)
    print("DEMO 1: Identity system on {0,1,2,3} -- the non-vacuity witness")
    print("=" * 70)
    universe = frozenset({0, 1, 2, 3})
    C = make_identity_C()
    print("Closure axioms hold:", verify_closure_axioms(C, universe))

    base = frozenset({0})
    print("base =", set(base))
    print("base consistent:", is_consistent(C, universe, base))

    ext = frozenset({0, 1})
    print("Strict extension {0,1} consistent:", is_consistent(C, universe, ext))
    print("They disagree on statement 1:", (1 in C(ext)) and (1 not in C(base)))

    core = universal_core(C, universe, base)
    print("Universal(base) =", set(core))
    print("C(base)         =", set(C(base)))
    print("Theorem B (core == C(base)):", core == C(base))
    print()


def demo_threshold_system() -> None:
    print("=" * 70)
    print("DEMO 2: Threshold system where deduction does real work")
    print("=" * 70)
    universe = frozenset({0, 1, 2, 3})
    # Assuming 1 forces deducing 2.
    C = make_threshold_C(universe, trigger=1, unlock=2)
    print("Closure axioms hold:", verify_closure_axioms(C, universe))

    base = frozenset({1})
    print("base =", set(base), " C(base) =", set(C(base)),
          "  (1 forces 2)")
    print("base consistent:", is_consistent(C, universe, base))

    core = universal_core(C, universe, base)
    print("Universal(base) =", set(core))
    print("Theorem B (core == C(base)):", core == C(base))

    # Theorem A: every consistent extension proves C(base).
    ok = all(C(base) <= C(d) for d in consistent_extensions(C, universe, base))
    print("Theorem A (every consistent extension proves C(base)):", ok)
    print()


def demo_downward_consistency() -> None:
    print("=" * 70)
    print("DEMO 3: Downward inheritance of consistency (Theorem C)")
    print("=" * 70)
    universe = frozenset({0, 1, 2})
    # Contradiction: holding both 1 and 2 explodes to everything.
    C = make_explosive_C(universe, contradiction=frozenset({1, 2}))
    print("Closure axioms hold:", verify_closure_axioms(C, universe))

    violations = 0
    checked = 0
    for d in powerset(universe):
        if is_consistent(C, universe, d):
            for g in powerset(d):
                checked += 1
                if not is_consistent(C, universe, g):
                    violations += 1
    print(f"Checked {checked} (subtheory, consistent-theory) pairs.")
    print("Theorem C holds (no consistent theory has an inconsistent subtheory):",
          violations == 0)

    # Show the inconsistent theory explodes.
    bad = frozenset({1, 2})
    print("C({1,2}) = everything?", C(bad) == universe,
          "-> {1,2} is inconsistent.")
    print()


def demo_monotonicity_of_core() -> None:
    print("=" * 70)
    print("DEMO 4: Monotonicity of the universal core in the base")
    print("=" * 70)
    universe = frozenset({0, 1, 2, 3})
    C = make_threshold_C(universe, trigger=1, unlock=2)
    base = frozenset({0})
    base2 = frozenset({0, 1})
    core = universal_core(C, universe, base)
    core2 = universal_core(C, universe, base2)
    print("base  =", set(base), " -> Universal =", set(core))
    print("base' =", set(base2), " -> Universal =", set(core2))
    print("base <= base' :", base <= base2)
    print("Universal(base) <= Universal(base') :", core <= core2)
    print()


def main() -> None:
    demo_identity_system()
    demo_threshold_system()
    demo_downward_consistency()
    demo_monotonicity_of_core()
    print("All demonstrations completed. The universal core of a consistent")
    print("base equals its deductive closure -- exactly Theorem B.")


if __name__ == "__main__":
    main()
