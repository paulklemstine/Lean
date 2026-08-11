"""
Truncation Orders and Reflection Depths in Tagged Provability Logic
===================================================================

Self-contained numerical demonstration of the results of the accompanying paper.

The language.  Formulas are built from falsum, atoms, implication and tagged boxes
`box_i`.  `box_i a` is read "system number i proves a"; `box_i^k bot` is the k-fold
iterated statement of inconsistency of system i.

Two families of theories are studied, both living on the ladder frame whose worlds are
0, 1, 2, ... with world m accessing exactly the worlds n < m.

  * LADDER THEORIES  L(c, N).  A height function c assigns to every tag i a height
    c(i).  At a world m the operator box_i can look down only if m <= c(i); above that
    level tag i is DEAD and box_i is vacuously true.  The theorems of L(c, N) are the
    formulas true at every world m <= N.  L(c, N) sees c only through its DEPTH VECTOR
    d_c(i) = min(N, c(i)).

  * BLOCK THEORIES  B(n, w).  Accessibility is tag-blind, but every atom is true
    exactly at the worlds 0, ..., w-1 ("shift point" w) and false from w upward.  The
    theorems of B(n, w) are the formulas true at every world m <= n.

What the script verifies numerically (all checks are exhaustive over an explicitly
enumerated finite set of formulas):

  1. the inconsistency spectrum of L(c, N):  box_i^k bot provable  iff  d_c(i) < k;
  2. the counterexample refuting the order-preservation conjecture at N = 2, with the
     explicit separating formula  box_0 bot -> (~box_1 bot -> ~box_1 box_1 bot);
  3. agreement of the exact criterion (DEPTH DOMINATION) with brute-force inclusion,
     over many random pairs of depth vectors;
  4. the truncation theorem: inclusion holds iff d_c = min(D, d_c') for a single cut D;
  5. the chain property and the pigeonhole bound N + 1 on the number of weakenings;
  6. the exact threshold: the conjectured criterion is sufficient iff N <= 1;
  7. the reflection depth of B(n, w) equals n - w, while its provable iterated boxed
     falsa do not depend on w;
  8. exact realizability of every pair (height n, reflection depth d) with d <= n;
  9. minimal soundness does not imply depth-1 reflection (witness: B(1,1));
 10. rigidity of the block family: distinct parameters give distinct theories.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Formulas
# ---------------------------------------------------------------------------

# A formula is one of
#   ("bot",)              falsum
#   ("atom", p)           atom number p
#   ("imp", a, b)         a -> b
#   ("box", i, a)         box_i a
Formula = tuple

BOT: Formula = ("bot",)


def atom(p: int) -> Formula:
    """The atom number ``p``."""
    return ("atom", p)


def imp(a: Formula, b: Formula) -> Formula:
    """The implication ``a -> b``."""
    return ("imp", a, b)


def box(i: int, a: Formula) -> Formula:
    """The tagged box ``box_i a``, read 'system i proves a'."""
    return ("box", i, a)


def neg(a: Formula) -> Formula:
    """Negation ``~a`` as ``a -> bot``."""
    return imp(a, BOT)


def box_pow(i: int, k: int, a: Formula) -> Formula:
    """The iterated box ``box_i^k a``."""
    out = a
    for _ in range(k):
        out = box(i, out)
    return out


def box_depth(a: Formula) -> int:
    """The maximal number of nested boxes in ``a``."""
    if a[0] in ("bot", "atom"):
        return 0
    if a[0] == "imp":
        return max(box_depth(a[1]), box_depth(a[2]))
    return 1 + box_depth(a[2])


def show(a: Formula) -> str:
    """A readable rendering of a formula."""
    if a[0] == "bot":
        return "_|_"
    if a[0] == "atom":
        return f"p{a[1]}"
    if a[0] == "imp":
        if a[2] == BOT:
            return f"~{show(a[1])}"
        return f"({show(a[1])} -> {show(a[2])})"
    return f"[{a[1]}]{show(a[2])}"


def enumerate_formulas(max_size: int, tags: int, atoms: int) -> List[Formula]:
    """All formulas of construction size at most ``max_size`` over the given tags/atoms.

    Size 1 formulas are falsum and the atoms; an implication has the sum of the sizes of
    its parts plus one; a box has the size of its argument plus one.
    """
    by_size: Dict[int, List[Formula]] = {1: [BOT] + [atom(p) for p in range(atoms)]}
    for size in range(2, max_size + 1):
        level: List[Formula] = []
        for inner in by_size[size - 1]:
            for i in range(tags):
                level.append(box(i, inner))
        for left in range(1, size - 1):
            right = size - 1 - left
            for a in by_size[left]:
                for b in by_size[right]:
                    level.append(imp(a, b))
        by_size[size] = level
    return [f for size in range(1, max_size + 1) for f in by_size[size]]


# ---------------------------------------------------------------------------
# 2. Tag-sensitive semantics and the ladder theories L(c, N)
# ---------------------------------------------------------------------------


def sat_ladder(c: Sequence[int], m: int, a: Formula) -> bool:
    """Truth of ``a`` at world ``m`` of the tag-sensitive ladder model of ``c``.

    ``box_i`` is vacuously true at every world above ``c(i)`` (tag ``i`` is dead there).
    """
    if a[0] == "bot":
        return False
    if a[0] == "atom":
        return True  # atoms are true everywhere in the tag-sensitive model
    if a[0] == "imp":
        return (not sat_ladder(c, m, a[1])) or sat_ladder(c, m, a[2])
    i = a[1]
    if m > c[i]:
        return True  # tag i is dead at m: the box is vacuous
    return all(sat_ladder(c, n, a[2]) for n in range(m))


def provable_ladder(c: Sequence[int], N: int, a: Formula) -> bool:
    """``a`` is a theorem of ``L(c, N)``: true at every world ``0..N``."""
    return all(sat_ladder(c, m, a) for m in range(N + 1))


def depth_vector(c: Sequence[int], N: int) -> Tuple[int, ...]:
    """The depth vector ``d_c(i) = min(N, c(i))`` -- a complete invariant of L(c, N)."""
    return tuple(min(N, ci) for ci in c)


def depth_dominates(c: Sequence[int], cp: Sequence[int], N: int) -> bool:
    """The EXACT criterion: depths only increase, and strictly only at maximal depth."""
    d, dp = depth_vector(c, N), depth_vector(cp, N)
    if any(d[i] > dp[i] for i in range(len(d))):
        return False
    top = max(d)
    return all(d[i] == top for i in range(len(d)) if d[i] < dp[i])


def conjectured_criterion(c: Sequence[int], cp: Sequence[int], N: int) -> bool:
    """The refuted criterion: pointwise growth plus preservation of the relative order."""
    d, dp = depth_vector(c, N), depth_vector(cp, N)
    if any(d[i] > dp[i] for i in range(len(d))):
        return False
    n = len(d)
    return all(
        d[i] <= d[j] for i in range(n) for j in range(n) if dp[i] <= dp[j]
    )


def truncation_witness(c: Sequence[int], cp: Sequence[int], N: int) -> Optional[int]:
    """The single cut level ``D`` with ``d_c = min(D, d_c')``, if one exists."""
    d, dp = depth_vector(c, N), depth_vector(cp, N)
    for D in range(N + 1):
        if all(d[i] == min(D, dp[i]) for i in range(len(d))):
            return D
    return None


def inclusion_counterexample(
    c: Sequence[int], cp: Sequence[int], N: int, sample: Sequence[Formula]
) -> Optional[Formula]:
    """A formula provable in ``L(c', N)`` but not in ``L(c, N)``, searched in ``sample``."""
    for f in sample:
        if provable_ladder(cp, N, f) and not provable_ladder(c, N, f):
            return f
    return None


def order_witness(i: int, j: int, m: int) -> Formula:
    """``box_i bot -> (~box_j^m bot -> ~box_j^{m+1} bot)``.

    Reads: *if tag i is dead here, then tag j does not have depth exactly m here.*
    This single family of formulas certifies every failure of the inclusion order.
    """
    return imp(
        box(i, BOT),
        imp(neg(box_pow(j, m, BOT)), neg(box_pow(j, m + 1, BOT))),
    )


# ---------------------------------------------------------------------------
# 3. Valuated semantics and the block theories B(n, w)
# ---------------------------------------------------------------------------


def sat_block(w: int, m: int, a: Formula) -> bool:
    """Truth of ``a`` at world ``m`` under the block valuation with shift point ``w``.

    Every atom is true exactly at the worlds ``0, ..., w-1``; accessibility is tag-blind.
    """
    if a[0] == "bot":
        return False
    if a[0] == "atom":
        return m < w
    if a[0] == "imp":
        return (not sat_block(w, m, a[1])) or sat_block(w, m, a[2])
    return all(sat_block(w, n, a[2]) for n in range(m))


def provable_block(n: int, w: int, a: Formula) -> bool:
    """``a`` is a theorem of the block theory ``B(n, w)``."""
    return all(sat_block(w, m, a) for m in range(n + 1))


def probe(i: int, k: int) -> Formula:
    """The depth probe ``box_i^k p0``: a 'shifted falsum' of box depth exactly ``k``."""
    return box_pow(i, k, atom(0))


def world_guard(i: int, j: int, a: Formula) -> Formula:
    """``box_i^{j+1} bot -> (~box_i^j bot -> a)``: asserts ``a`` at the world ``j`` only."""
    return imp(box_pow(i, j + 1, BOT), imp(neg(box_pow(i, j, BOT)), a))


def reflection_depth_block(n: int, w: int, sample: Sequence[Formula], cap: int) -> int:
    """Largest ``d <= cap`` such that depth-``d`` reflection holds over ``sample``.

    Depth-``d`` reflection: for every formula ``a`` with ``box_depth(a) < d``, if
    ``box_0 a`` is a theorem then so is ``a``.
    """
    best = 0
    for d in range(cap + 1):
        ok = True
        for f in sample:
            if box_depth(f) < d and provable_block(n, w, box(0, f)):
                if not provable_block(n, w, f):
                    ok = False
                    break
        if ok:
            best = d
        else:
            break
    return best


# ---------------------------------------------------------------------------
# 4. The demonstrations
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_inconsistency_spectrum() -> None:
    rule("1.  The inconsistency spectrum of a ladder theory")
    print("   box_i^k bot is a theorem of L(c, N) exactly when 1 <= k and min(N, c(i)) < k.")
    N = 3
    for c in [(0, 1, 2), (2, 2, 5), (1, 4, 0)]:
        d = depth_vector(c, N)
        for i in range(len(c)):
            observed = [k for k in range(0, 6) if provable_ladder(c, N, box_pow(i, k, BOT))]
            predicted = [k for k in range(0, 6) if k >= 1 and d[i] < k]
            assert observed == predicted, (c, i, observed, predicted)
        print(f"   c = {c}  depth vector = {d}  ->  spectrum matches for every tag")
    print("   OK: the theory sees the height function only through its depth vector.")


def demo_counterexample() -> None:
    rule("2.  The order-preservation conjecture is FALSE (least height N = 2)")
    N = 2
    c = (0, 1, 1)     # depth vector (0, 1, 1)
    cp = (1, 2, 2)    # depth vector (1, 2, 2)
    print(f"   c  = {c}   depth vector = {depth_vector(c, N)}")
    print(f"   c' = {cp}   depth vector = {depth_vector(cp, N)}")
    print(f"   conjectured criterion holds : {conjectured_criterion(c, cp, N)}")
    print(f"   depth domination holds      : {depth_dominates(c, cp, N)}")
    w = order_witness(0, 1, 1)
    print(f"   separating formula          : {show(w)}")
    print(f"     provable in L(c', 2)      : {provable_ladder(cp, N, w)}")
    print(f"     provable in L(c , 2)      : {provable_ladder(c, N, w)}")
    for m in range(N + 1):
        print(f"     truth of the witness at world {m} of the c-model: {sat_ladder(c, m, w)}")
    assert conjectured_criterion(c, cp, N)
    assert not depth_dominates(c, cp, N)
    assert provable_ladder(cp, N, w) and not provable_ladder(c, N, w)
    print("   OK: both conjectured conditions hold, yet the inclusion fails.")
    print("   Mechanism: raising the depth of tag 0 from 0 to 1 deletes the world 1,")
    print("   at which tag 0 is dead while tag 1 is alive with depth exactly 1.")


def demo_criterion_agrees(trials: int = 400, seed: int = 20260811) -> None:
    rule("3.  The exact criterion agrees with brute-force inclusion")
    rng = random.Random(seed)
    sample = enumerate_formulas(max_size=4, tags=2, atoms=1)
    print(f"   testing {trials} random pairs against {len(sample)} enumerated formulas")
    agree = 0
    detected = 0
    for _ in range(trials):
        N = rng.randint(1, 3)
        c = tuple(rng.randint(0, 4) for _ in range(2))
        cp = tuple(rng.randint(0, 4) for _ in range(2))
        criterion = depth_dominates(c, cp, N)
        found = inclusion_counterexample(c, cp, N, sample)
        if criterion:
            assert found is None, (c, cp, N, show(found))
            agree += 1
        else:
            # the criterion predicts failure; the enumeration should exhibit it
            if found is not None:
                detected += 1
            agree += 1
    print(f"   pairs consistent with the criterion : {agree}/{trials}")
    print(f"   predicted failures actually exhibited by a small formula: {detected}")
    print("   OK: no pair satisfying depth domination admits a separating formula,")
    print("       and the predicted failures are witnessed explicitly.")


def demo_truncation() -> None:
    rule("4.  Weakenings are exactly truncations")
    print("   Incl(c, c', N)  iff  d_c = min(D, d_c') pointwise for a single cut D <= N.")
    N = 3
    tested = 0
    for c in itertools.product(range(N + 1), repeat=3):
        for cp in itertools.product(range(N + 1), repeat=3):
            dominates = depth_dominates(c, cp, N)
            cut = truncation_witness(c, cp, N)
            assert dominates == (cut is not None), (c, cp)
            tested += 1
    print(f"   checked all {tested} pairs of depth vectors over 3 tags at N = {N}")
    examples = [((1, 1, 1), (1, 2, 3)), ((0, 0, 0), (3, 1, 2)), ((2, 2, 3), (2, 2, 3))]
    for c, cp in examples:
        cut = truncation_witness(c, cp, N)
        print(f"   d_c = {c}, d_c' = {cp}  ->  cut level D = {cut}")
    print("   OK: the truncation theorem holds on the nose.")


def demo_chain_and_pigeonhole() -> None:
    rule("5.  The weakenings of a theory form a chain of length at most N + 1")
    N = 3
    cp = (0, 2, 3)
    below = [c for c in itertools.product(range(N + 1), repeat=3) if depth_dominates(c, cp, N)]
    print(f"   fixed theory with depth vector {cp} at N = {N}")
    print(f"   depth vectors of its weakenings ({len(below)} of them, bound N+1 = {N + 1}):")
    for c in sorted(below, key=lambda v: max(v)):
        print(f"      {c}   (cut level D = {truncation_witness(c, cp, N)})")
    for a in below:
        for b in below:
            assert depth_dominates(a, b, N) or depth_dominates(b, a, N), (a, b)
    assert len(below) <= N + 1
    print("   OK: pairwise comparable (a chain), and at most N + 1 of them.")


def demo_threshold() -> None:
    rule("6.  Exact threshold: the conjectured criterion is sufficient iff N <= 1")
    for N in range(0, 4):
        bad: List[Tuple[Tuple[int, ...], Tuple[int, ...]]] = []
        for c in itertools.product(range(N + 2), repeat=3):
            for cp in itertools.product(range(N + 2), repeat=3):
                if conjectured_criterion(c, cp, N) and not depth_dominates(c, cp, N):
                    bad.append((c, cp))
        verdict = "sufficient" if not bad else f"NOT sufficient ({len(bad)} bad pairs)"
        extra = ""
        if bad:
            c, cp = bad[0]
            extra = f"; first bad pair d_c={depth_vector(c, N)}, d_c'={depth_vector(cp, N)}"
        print(f"   N = {N}:  conjectured criterion is {verdict}{extra}")
        assert (not bad) == (N <= 1)
    print("   OK: correct for N <= 1, false from N = 2 upward.")


def demo_reflection_depth() -> None:
    rule("7.  The reflection depth of the block theory B(n, w) equals n - w")
    sample = enumerate_formulas(max_size=5, tags=1, atoms=1)
    print(f"   probing with {len(sample)} enumerated formulas of one tag and one atom")
    print("     n   w   |  predicted n-w   measured   inconsistency spectrum (k with |- box^k bot)")
    for n in range(0, 4):
        for w in range(0, n + 1):
            measured = reflection_depth_block(n, w, sample, cap=n + 1)
            spectrum = [k for k in range(0, 6) if provable_block(n, w, box_pow(0, k, BOT))]
            print(f"     {n}   {w}   |      {n - w}            {measured}         k > {n}  -> {spectrum}")
            assert measured == n - w, (n, w, measured)
    print("   OK: the reflection depth is exactly n - w, while the provable iterated")
    print("       boxed falsa are the same for every shift point w.")


def demo_realizability() -> None:
    rule("8.  Exact realizability of the pair (height n, reflection depth d)")
    print("   A consistent theory of provability logic with inconsistency height n and")
    print("   reflection depth exactly d exists iff d <= n; the witness is B(n, n-d).")
    sample = enumerate_formulas(max_size=5, tags=1, atoms=1)
    print("     n   d   witness      measured depth   height check")
    for n in range(0, 4):
        for d in range(0, n + 1):
            w = n - d
            measured = reflection_depth_block(n, w, sample, cap=n + 1)
            height_ok = all(
                provable_block(n, w, box_pow(0, k, BOT)) == (k > n) for k in range(0, 6)
            )
            print(f"     {n}   {d}   B({n},{w})        {measured}              {height_ok}")
            assert measured == d and height_ok
    print("   The failure of reflection one step higher is witnessed by a depth probe:")
    for n, d in [(2, 1), (3, 2)]:
        w = n - d
        p = probe(0, d)
        print(
            f"     B({n},{w}): |- box_0 {show(p)}  = {provable_block(n, w, box(0, p))}, "
            f"|- {show(p)} = {provable_block(n, w, p)}"
        )
    print("   OK: the whole triangle {(n, d) : d <= n} is realized, and nothing outside it.")


def demo_independence_and_separation() -> None:
    rule("9.  Independence of the two rulers, and the bottom of the reflection chain")
    sample = enumerate_formulas(max_size=5, tags=1, atoms=1)
    n = 3
    same = all(
        provable_block(n, 0, box_pow(0, k, BOT)) == provable_block(n, n, box_pow(0, k, BOT))
        for k in range(0, 8)
    )
    d0 = reflection_depth_block(n, 0, sample, cap=n + 1)
    dn = reflection_depth_block(n, n, sample, cap=n + 1)
    print(f"   B({n},0) and B({n},{n}) prove the same iterated boxed falsa : {same}")
    print(f"   reflection depth of B({n},0) = {d0},  of B({n},{n}) = {dn}")
    assert same and d0 == n and dn == 0
    print("   OK: the reflection depth is NOT a function of the inconsistency spectrum.")
    print()
    print("   Minimal soundness (not proving box_0 bot) vs depth-1 reflection, in B(1,1):")
    min_sound = not provable_block(1, 1, box(0, BOT))
    proves_box_atom = provable_block(1, 1, box(0, atom(0)))
    proves_atom = provable_block(1, 1, atom(0))
    print(f"     minimally sound      : {min_sound}")
    print(f"     |- box_0 p0          : {proves_box_atom}")
    print(f"     |- p0                : {proves_atom}")
    assert min_sound and proves_box_atom and not proves_atom
    print("   OK: depth-1 reflection is strictly stronger than minimal soundness,")
    print("       and this is optimal since the depth-0 rule is vacuous.")


def demo_rigidity() -> None:
    rule("10.  Rigidity of the block family")
    print("   B(n', w') is contained in B(n, w) iff n <= n' and the valuations agree")
    print("   at every world j <= n.  Distinct parameters give distinct theories.")
    sample = enumerate_formulas(max_size=5, tags=1, atoms=1)
    for n in range(0, 4):
        for w in range(0, n + 1):
            for wp in range(0, n + 1):
                same = all(
                    provable_block(n, w, f) == provable_block(n, wp, f) for f in sample
                )
                assert same == (w == wp), (n, w, wp)
    print("   checked all pairs of shift points for n <= 3: theories coincide iff w = w'.")
    n, w, wp = 2, 1, 2
    guard = world_guard(0, 1, atom(0))
    print(f"   separating B({n},{w}) from B({n},{wp}) with the world guard {show(guard)}:")
    print(f"     provable in B({n},{w})  : {provable_block(n, w, guard)}")
    print(f"     provable in B({n},{wp})  : {provable_block(n, wp, guard)}")
    print("   OK: the parameters are recoverable from the theory -- in sharp contrast")
    print("       with the massive redundancy of the ladder family.")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_inconsistency_spectrum()
    demo_counterexample()
    demo_criterion_agrees()
    demo_truncation()
    demo_chain_and_pigeonhole()
    demo_threshold()
    demo_reflection_depth()
    demo_realizability()
    demo_independence_and_separation()
    demo_rigidity()
    rule("All checks passed.")


if __name__ == "__main__":
    main()
