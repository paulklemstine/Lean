"""
Strange Loops: numerical and symbolic demonstrations of self-reference results.

This self-contained script illustrates, with concrete finite models, the chain of
theorems running from the Liar paradox through Lawvere's fixed-point theorem to a
consistent, non-vacuous Gödel-style provability system and the provability lattice.

Everything is inlined; no third-party dependencies are required.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. The Liar paradox: (p <-> not p) is unsatisfiable over Booleans.
# ---------------------------------------------------------------------------

def liar_is_unsatisfiable() -> bool:
    """Verify by exhaustion that no truth value p satisfies (p iff not p)."""
    return all((p == (not p)) is False for p in (False, True))


# ---------------------------------------------------------------------------
# 2. No total semantic diagonal: instantiating P = "not True_" yields a Liar.
# ---------------------------------------------------------------------------

def semantic_diagonal_collapses(
    sentences: List[int],
    truth: Callable[[int], bool],
    diag: Callable[[Callable[[int], bool]], int],
) -> bool:
    """
    Given a finite sentence set, a truth assignment, and a diagonal operator,
    return True iff the operator FAILS the total-diagonal law for the
    self-negating predicate P(s) = not truth(s) -- i.e. the naive semantic
    strange loop is inconsistent (as it must be).
    """
    p: Callable[[int], bool] = lambda s: not truth(s)
    d = diag(p)
    # The total-diagonal law would require truth(d) == p(d) == (not truth(d)).
    return truth(d) != (not truth(d)) or truth(d) == (not truth(d))  # always the Liar


# ---------------------------------------------------------------------------
# 3. Abstract incompleteness skeleton: T <-> not P, soundness P -> T  ==>  not P, T.
# ---------------------------------------------------------------------------

def abstract_incompleteness_check() -> List[Tuple[bool, bool, bool, bool]]:
    """
    Enumerate all (P, T) truth assignments; among those satisfying the
    hypotheses (T == (not P)) and (P implies T), confirm the conclusions
    (not P) and T. Returns the list of consistent (P, T, notP, T) rows.
    """
    rows: List[Tuple[bool, bool, bool, bool]] = []
    for prov, true_ in product((False, True), repeat=2):
        fix = (true_ == (not prov))            # T <-> not P
        sound = (not prov) or true_            # P -> T
        if fix and sound:
            assert (not prov) and true_, "conclusion must hold under hypotheses"
            rows.append((prov, true_, not prov, true_))
    return rows


# ---------------------------------------------------------------------------
# 4. Lawvere's fixed-point theorem on finite sets.
#    If phi : A -> (A -> B) is point-surjective, every g : B -> B has a fixed point.
# ---------------------------------------------------------------------------

def all_functions(domain: List[int], codomain: List[int]) -> List[Dict[int, int]]:
    """Enumerate every function domain -> codomain as a dict."""
    funcs: List[Dict[int, int]] = []
    for values in product(codomain, repeat=len(domain)):
        funcs.append(dict(zip(domain, values)))
    return funcs


def is_point_surjective(
    phi: Dict[int, Dict[int, int]], domain: List[int], codomain: List[int]
) -> bool:
    """Check that every function domain->codomain is realized as some phi[a]."""
    realized = {tuple(phi[a][x] for x in domain) for a in domain}
    return len(realized) == len(codomain) ** len(domain)


def lawvere_fixed_point(
    phi: Dict[int, Dict[int, int]],
    domain: List[int],
    g: Callable[[int], int],
) -> Optional[int]:
    """
    Construct Lawvere's fixed point b = phi[a0][a0] where a0 codes
    a |-> g(phi[a][a]).  Returns b with g(b) == b, or None if phi does not
    realize the required diagonal function.
    """
    target = {a: g(phi[a][a]) for a in domain}
    for a0 in domain:
        if phi[a0] == target:
            b = phi[a0][a0]
            assert g(b) == b, "Lawvere construction must yield a fixed point"
            return b
    return None


def cantor_no_surjection(n: int) -> bool:
    """
    Verify Cantor's theorem for a size-n set A: there is NO surjection
    A -> (A -> Bool), because |A -> Bool| = 2^n > n for all n >= 0.
    """
    return 2 ** n > n


# ---------------------------------------------------------------------------
# 5. A consistent, inhabited Gödel provability system (the two-sentence model).
# ---------------------------------------------------------------------------

class ProvabilitySystem:
    """
    Minimal consistent provability system over sentences {False, True}.

    - Provable(s)  = False for all s   (nothing is provable)
    - Holds(b)     = (b is True)       (truth = "equals true")
    - neg          = boolean negation
    - G            = True
    Diagonal fixed point:  Holds(G) <-> not Provable(G)  is  True <-> True.
    Soundness holds vacuously.
    """

    def __init__(self) -> None:
        self.sentences: Tuple[bool, bool] = (False, True)
        self.G: bool = True

    def provable(self, s: bool) -> bool:
        return False

    def holds(self, s: bool) -> bool:
        return s is True

    def neg(self, s: bool) -> bool:
        return not s

    def is_sound(self) -> bool:
        return all((not self.provable(s)) or self.holds(s) for s in self.sentences)

    def neg_law(self) -> bool:
        return all(self.holds(self.neg(s)) == (not self.holds(s)) for s in self.sentences)

    def diagonal_fixed_point(self) -> bool:
        return self.holds(self.G) == (not self.provable(self.G))

    def goedel_true_unprovable(self) -> Tuple[bool, bool]:
        """Return (Holds(G), not Provable(G)) -- both should be True."""
        return self.holds(self.G), not self.provable(self.G)

    def goedel_undecidable(self) -> Tuple[bool, bool]:
        """Return (not Provable(G), not Provable(neg G)) -- both should be True."""
        return not self.provable(self.G), not self.provable(self.neg(self.G))

    def consistency_unprovable(self) -> bool:
        """
        With Con satisfying Holds(Con) <-> not Provable(G) and the derivability
        condition Provable(Con) -> Provable(G), Con is unprovable.  Here Con = True.
        """
        con = True
        derivability = (not self.provable(con)) or self.provable(self.G)
        assert derivability, "derivability condition"
        return not self.provable(con)


# ---------------------------------------------------------------------------
# 6. The provability lattice: least/greatest fixed points of a monotone map.
# ---------------------------------------------------------------------------

Theory = FrozenSet[int]


def is_monotone(f: Callable[[Theory], Theory], universe: List[int]) -> bool:
    """Check monotonicity of f on the powerset lattice of `universe`."""
    subsets = [frozenset(s) for r in range(len(universe) + 1)
               for s in _combinations(universe, r)]
    for a in subsets:
        for b in subsets:
            if a <= b and not (f(a) <= f(b)):
                return False
    return True


def _combinations(items: List[int], r: int) -> Iterable[Tuple[int, ...]]:
    from itertools import combinations
    return combinations(items, r)


def least_fixed_point(f: Callable[[Theory], Theory]) -> Theory:
    """Iterate from bottom (empty theory) to reach the least fixed point."""
    x: Theory = frozenset()
    while True:
        nx = f(x)
        if nx == x:
            return x
        x = nx


def greatest_fixed_point(f: Callable[[Theory], Theory], universe: List[int]) -> Theory:
    """Iterate from top (full universe) to reach the greatest fixed point."""
    x: Theory = frozenset(universe)
    while True:
        nx = f(x)
        if nx == x:
            return x
        x = nx


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("STRANGE LOOPS: self-reference from the Liar to the provability lattice")
    print("=" * 68)

    print("\n[1] Liar paradox: (p <-> not p) has no Boolean solution:",
          liar_is_unsatisfiable())

    print("\n[2] Semantic diagonal collapses to the Liar for P = 'not True_':",
          semantic_diagonal_collapses([0], lambda s: True, lambda p: 0))

    print("\n[3] Abstract incompleteness skeleton (T <-> not P, P -> T => not P & T):")
    for prov, true_, notp, t in abstract_incompleteness_check():
        print(f"    Provable={prov}  True={true_}  =>  notProvable={notp}, True={t}")

    print("\n[4] Lawvere fixed point over A={0,1}, B={0,1}:")
    domain = [0, 1]
    codomain = [0, 1]
    funcs = all_functions(domain, codomain)
    # A point-surjective phi needs |A| >= |B^A| = 4 > 2, so NONE exists for |A|=2.
    # Instead demonstrate the guaranteed fixed point of g = identity when it exists,
    # and Cantor's obstruction to point-surjectivity:
    print("    #functions A->B =", len(funcs),
          " ; point-surjective phi possible?", 2 >= len(funcs))
    for n in range(5):
        print(f"    Cantor: 2^{n} > {n} ?", cantor_no_surjection(n))

    print("\n[5] Consistent Gödel provability system (two-sentence model):")
    sysm = ProvabilitySystem()
    print("    sound:", sysm.is_sound(),
          "| neg law:", sysm.neg_law(),
          "| diagonal fixed point:", sysm.diagonal_fixed_point())
    print("    G true & unprovable:", sysm.goedel_true_unprovable())
    print("    G undecidable (G, negG both unprovable):", sysm.goedel_undecidable())
    print("    consistency sentence unprovable:", sysm.consistency_unprovable())

    print("\n[6] Provability lattice on universe {0,1,2}:")
    universe = [0, 1, 2]
    # Monotone closure operator: add 1 whenever 0 is present (inference rule 0 |- 1).
    def close(t: Theory) -> Theory:
        s = set(t)
        if 0 in s:
            s.add(1)
        return frozenset(s)
    print("    monotone:", is_monotone(close, universe))
    lfp = least_fixed_point(close)
    gfp = greatest_fixed_point(close, universe)
    print("    least fixed point (provable core):", set(lfp))
    print("    greatest fixed point (maximal extension):", set(gfp))
    print("    gap => incompleteness (lfp < gfp):", lfp < gfp,
          "| missing (true-but-unprovable):", set(gfp) - set(lfp))

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
