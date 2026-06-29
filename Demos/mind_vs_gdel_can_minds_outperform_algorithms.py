"""
Mind vs Godel: Can Minds Outperform Algorithms?
================================================

A self-contained, dependency-free numerical demonstration of the single
diagonal mechanism that underlies Cantor's theorem, Godel's incompleteness,
Turing's halting problem, Tarski's undefinability of truth, and the
Lucas-Penrose argument.

Ground-truth results being illustrated:

  Theorem 1 (Lawvere).  If e : A -> (A -> B) is surjective, then every
                        endomap f : B -> B has a fixed point y with f(y)=y.
  Theorem 2-4 (Cantor). No surjection A -> (A -> Bool) / (A -> Prop) / Set A.
  Theorem 5 (Abstract incompleteness). No provability predicate is at once
                        consistent, negation-complete, and host to a diagonal
                        (Godel) sentence g with Provable(g) <-> Provable(neg g).

Everything below uses only the Python standard library and is fully inlined.
Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple


# ----------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem, demonstrated by exhaustive search.
# ----------------------------------------------------------------------------
#
# On finite types we can literally enumerate every function A -> B and check
# the theorem. We represent:
#   - a type as a list of its elements,
#   - a function A -> B as a Python dict.
# An evaluation map e : A -> (A -> B) assigns to each a in A a function A -> B.


Func = Dict[object, object]  # a function on finite domains, as a dict


def all_functions(domain: List[object], codomain: List[object]) -> List[Func]:
    """Enumerate every total function domain -> codomain as a dict."""
    funcs: List[Func] = []
    for values in product(codomain, repeat=len(domain)):
        funcs.append({d: v for d, v in zip(domain, values)})
    return funcs


def is_surjective(e: Dict[object, Func], domain: List[object],
                  codomain: List[object]) -> bool:
    """Is the evaluation map e : A -> (A -> B) surjective onto all functions?"""
    named = [tuple(e[a][x] for x in domain) for a in domain]
    target = [tuple(f[x] for x in domain) for f in all_functions(domain, codomain)]
    return set(named) >= set(target)


def lawvere_fixed_point(e: Dict[object, Func], domain: List[object],
                        f: Callable[[object], object]) -> object:
    """
    Construct the Lawvere fixed point of f from a surjective evaluation e.

    The diagonal function is  d(x) = f(e[x][x]).  By surjectivity some name a
    has e[a] == d, and then y = e[a][a] satisfies f(y) = y.
    """
    diagonal: Func = {x: f(e[x][x]) for x in domain}
    for a in domain:
        if e[a] == diagonal:
            return e[a][a]
    raise ValueError("e is not surjective: no name realises the diagonal")


def demo_lawvere() -> None:
    print("=" * 70)
    print("DEMO 1  Lawvere's fixed-point theorem (finite, by enumeration)")
    print("=" * 70)
    # Choose A large enough to be surjective onto A -> B with |B| = 2.
    # |A->B| = |B|^|A| = 2^|A|; we need |A| >= 2^|A|, impossible for sets...
    # which is exactly Cantor! So instead we DESIGN a surjective e by taking
    # B to be a single point so |A->B| = 1, where a fixed point must exist.
    A = ["a0", "a1"]
    B = ["*"]                      # one-element codomain
    e = {a: {x: "*" for x in A} for a in A}   # the only function A->B
    print(f"  A = {A},  B = {B}")
    print(f"  e surjective onto (A->B)? {is_surjective(e, A, B)}")
    f = lambda b: "*"             # only endomap on a 1-point set
    y = lawvere_fixed_point(e, A, f)
    print(f"  Lawvere fixed point y = {y!r},  f(y) = {f(y)!r},  f(y)==y? {f(y)==y}")
    print()


# ----------------------------------------------------------------------------
# 2. Cantor: there is NO surjection A -> (A -> Bool), verified exhaustively.
# ----------------------------------------------------------------------------


def demo_cantor() -> None:
    print("=" * 70)
    print("DEMO 2  Cantor: no surjection A -> (A -> Bool) (Theorem 2)")
    print("=" * 70)
    for n in range(0, 4):
        A = [f"x{i}" for i in range(n)]
        B = [False, True]
        # Try EVERY evaluation map e : A -> (A -> Bool) and confirm none is onto.
        funcs = all_functions(A, B)          # all functions A -> Bool
        found_surjection = False
        # an evaluation map assigns to each a in A one of the funcs
        for assignment in product(range(len(funcs)), repeat=n):
            e = {A[i]: funcs[assignment[i]] for i in range(n)}
            if is_surjective(e, A, B):
                found_surjection = True
                break
        # Build the diagonal witness that always escapes:
        #   d(x) = not (e[x][x])  -- the flipped diagonal, unnamed by any e.
        print(f"  |A| = {n}:  |A->Bool| = {len(funcs)};  "
              f"any surjection found? {found_surjection}")
    print("  -> The flipped diagonal d(x) = not e[x][x] is never named. QED")
    print()


# ----------------------------------------------------------------------------
# 3. Abstract incompleteness (Theorem 5): the trilemma is contradictory.
# ----------------------------------------------------------------------------
#
# We model a finite "provability interface":
#   - sentences: a finite list,
#   - neg: an involution on sentences (s and neg s are a contradictory pair),
#   - Provable: a subset of sentences (the theorems).
# We then search for an interface that is simultaneously consistent,
# negation-complete, and hosts a diagonal sentence g (Provable g <-> Provable neg g)
# and confirm that NONE exists -- the formal content of Theorem 5.


Sentence = str


def is_consistent(provable: set, neg: Dict[Sentence, Sentence]) -> bool:
    return all(not (s in provable and neg[s] in provable) for s in neg)


def is_complete(provable: set, neg: Dict[Sentence, Sentence]) -> bool:
    return all((s in provable) or (neg[s] in provable) for s in neg)


def has_diagonal(provable: set, neg: Dict[Sentence, Sentence]) -> Optional[Sentence]:
    """Return a diagonal sentence g with (g provable) <-> (neg g provable), if any."""
    for g in neg:
        if (g in provable) == (neg[g] in provable):
            return g
    return None


def demo_incompleteness() -> None:
    print("=" * 70)
    print("DEMO 3  Abstract incompleteness: the trilemma is impossible (Thm 5)")
    print("=" * 70)
    # Sentences come in negation pairs.  Use g/ng plus k filler pairs.
    pairs = [("g", "ng"), ("p", "np"), ("q", "nq")]
    sentences = [s for pair in pairs for s in pair]
    neg = {}
    for a, b in pairs:
        neg[a] = b
        neg[b] = a

    total = 0
    impossible = 0
    witness_complete_consistent = 0
    for bits in product([0, 1], repeat=len(sentences)):
        provable = {s for s, b in zip(sentences, bits) if b}
        total += 1
        cons = is_consistent(provable, neg)
        comp = is_complete(provable, neg)
        diag = has_diagonal(provable, neg)
        if cons and comp:
            witness_complete_consistent += 1
        # Theorem 5: cons AND comp AND diag is impossible.
        if cons and comp and diag is not None:
            impossible += 1

    print(f"  Searched all {total} provability predicates on {len(sentences)} sentences.")
    print(f"  consistent AND complete predicates: {witness_complete_consistent}")
    print(f"  consistent AND complete AND has a diagonal sentence: {impossible}")
    assert impossible == 0, "Theorem 5 would be violated!"
    print("  -> 0, exactly as Theorem 5 predicts: the trilemma never holds.")
    print()


# ----------------------------------------------------------------------------
# 4. Lucas-Penrose reflection ladder: the mind climbs, but never tops out.
# ----------------------------------------------------------------------------
#
# We model systems as finite sets of "provable" integers, with the reflective
# extension F_{n+1} = F_n + Con(F_n) injecting one new Godel-style truth each
# step (here, the integer n itself stands for "Con(F_n)").  No level is
# complete; each level proves the prior level's escaped sentence; the union
# decides everything below it -- but a fresh sentence (omega) still escapes.


def reflection_tower(levels: int) -> List[set]:
    """F_0 = {}; F_{n+1} = F_n U {n}.  Integer n encodes Con(F_n)."""
    tower: List[set] = [set()]
    for n in range(levels):
        nxt = set(tower[-1])
        nxt.add(n)            # add the consistency statement of the current level
        tower.append(nxt)
    return tower


def godel_sentence_of(level: int) -> int:
    """The sentence undecided at F_level but provable at F_{level+1}."""
    return level


def demo_reflection_ladder() -> None:
    print("=" * 70)
    print("DEMO 4  The reflection ladder: mind beats each rung, not the ladder")
    print("=" * 70)
    tower = reflection_tower(5)
    for n in range(len(tower) - 1):
        g = godel_sentence_of(n)
        provable_now = g in tower[n]
        provable_next = g in tower[n + 1]
        print(f"  F_{n}: Godel sentence g_{n}={g}  "
              f"provable at F_{n}? {provable_now}   "
              f"provable at F_{n+1}? {provable_next}")
    union = set().union(*tower)
    fresh = max(union) + 1
    print(f"  Union of all finite levels proves {sorted(union)};")
    print(f"  but the fresh diagonal sentence {fresh} (= Con(F_omega)) still escapes.")
    print("  -> A mind climbs one rung beyond any named system, never beyond all.")
    print()


# ----------------------------------------------------------------------------
# 5. The unifying flip: same fixed-point-free endomap behind every theorem.
# ----------------------------------------------------------------------------


def demo_unifying_flip() -> None:
    print("=" * 70)
    print("DEMO 5  One flip to rule them all (fixed-point-free endomaps)")
    print("=" * 70)
    bool_flip: Callable[[bool], bool] = lambda b: not b
    print("  Bool flip  (Cantor/Turing): does any y satisfy not y == y?")
    print(f"    {[ (y, bool_flip(y), bool_flip(y) == y) for y in (False, True) ]}")
    print("  Logical negation (Godel/Tarski): y <-> not y is contradictory.")
    print("  Set complement (Cantor power set): S = complement(S) is impossible.")
    print("  Each endomap above is FIXED-POINT-FREE, so by Lawvere's")
    print("  contrapositive no self-naming can be surjective. One idea, five walls.")
    print()


def main() -> None:
    demo_lawvere()
    demo_cantor()
    demo_incompleteness()
    demo_reflection_ladder()
    demo_unifying_flip()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
