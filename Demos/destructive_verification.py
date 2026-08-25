"""
Destructive Verification: verdicts with a residual dish.
=========================================================

Numerical demonstrations of the theory of verification-as-state-transition.

A *test* on a finite type of *dishes* D = {0, 1, ..., n-1} is a map

    t : D -> Bool x D,

returning a *verdict* v(d) and a *residual dish* r(d).  This single change of
type -- from the classical predicate model D -> Bool -- separates three notions
that the predicate model conflates:

    nondestructive :  r(d) = d for all d          (a certificate check)
    reversible     :  r is a bijection            (nothing lost)
    repeatable     :  v(r(d)) = v(d) for all d    (answer is stable)

This script demonstrates, by direct computation:

  1. The taxonomy is strict: no implication holds beyond
     nondestructive => reversible and nondestructive => repeatable.
  2. Certificates commute; a single destructive participant breaks it,
     observably in the verdict.
  3. Census: (2n)^n tests, 2^n certificates, 2^n * n! reversible tests.
  4. Transcript rigidity: a transcript constant on its first n entries is
     constant forever; the fuse test shows depth n-1 is attained.
  5. State-complexity duality: transcripts on <= n dishes are exactly the
     eventually periodic streams with preperiod + period <= n, realised by
     the explicit rho test.
  6. Stabilisation: some batch length N makes the residue idempotent, and the
     original residue map is a bijection on the stabilised core.
  7. Observational equivalence is decided by n runs; the five-dish clock test
     realises a distinguishing delay of 3.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product
from math import factorial, gcd
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Set, Tuple

# A test on n dishes is a list of (verdict, residue) pairs indexed by dish.
Test = List[Tuple[bool, int]]


# ---------------------------------------------------------------------------
# 1. Basic accessors and the taxonomy
# ---------------------------------------------------------------------------

def verdict(t: Test, d: int) -> bool:
    """The verdict returned by test `t` on dish `d`."""
    return t[d][0]


def residue(t: Test, d: int) -> int:
    """The residual dish left over by test `t` on dish `d`."""
    return t[d][1]


def is_nondestructive(t: Test) -> bool:
    """True iff the dish comes back untouched: r(d) = d for every dish."""
    return all(residue(t, d) == d for d in range(len(t)))


def is_reversible(t: Test) -> bool:
    """True iff the residue map is a bijection (no information lost)."""
    return len({residue(t, d) for d in range(len(t))}) == len(t)


def is_repeatable(t: Test) -> bool:
    """True iff re-running on the residue reproduces the verdict."""
    return all(verdict(t, residue(t, d)) == verdict(t, d) for d in range(len(t)))


def is_destructive(t: Test) -> bool:
    """True iff the test is not nondestructive."""
    return not is_nondestructive(t)


def classify(t: Test) -> str:
    """Human-readable classification of a test."""
    tags = []
    tags.append("nondestructive" if is_nondestructive(t) else "destructive")
    tags.append("reversible" if is_reversible(t) else "irreversible")
    tags.append("repeatable" if is_repeatable(t) else "non-repeatable")
    return ", ".join(tags)


# ---------------------------------------------------------------------------
# 2. Sequential composition: the verification monoid
# ---------------------------------------------------------------------------

def seq(t1: Test, t2: Test) -> Test:
    """Run `t1`, then `t2` on the residue; conjoin the verdicts."""
    n = len(t1)
    assert len(t2) == n
    out: Test = []
    for d in range(n):
        r1 = residue(t1, d)
        out.append((verdict(t1, d) and verdict(t2, r1), residue(t2, r1)))
    return out


def unit(n: int) -> Test:
    """The trivial certificate: accepts everything, touches nothing."""
    return [(True, d) for d in range(n)]


def batch(t: Test, m: int) -> Test:
    """Run `t` exactly `m` times, accepting iff every run accepted."""
    out = unit(len(t))
    for _ in range(m):
        out = seq(out, t)
    return out


# ---------------------------------------------------------------------------
# 3. Transcripts, destruction depth, orbits
# ---------------------------------------------------------------------------

def transcript(t: Test, d: int, length: int) -> List[bool]:
    """The first `length` verdicts obtained by re-running `t` on its residue."""
    out: List[bool] = []
    cur = d
    for _ in range(length):
        out.append(verdict(t, cur))
        cur = residue(t, cur)
    return out


def destruction_depth(t: Test, d: int) -> Optional[int]:
    """
    Least m with transcript(m) != transcript(0), or None if the transcript is
    constant.  By transcript rigidity it suffices to look at m < n.
    """
    n = len(t)
    tr = transcript(t, d, n)
    for m in range(1, n):
        if tr[m] != tr[0]:
            return m
    return None


def minimal_recurrence(t: Test, d: int) -> Tuple[int, int]:
    """
    Minimal (preperiod i, period p) of the orbit of `d` under the residue map:
    the first repeated dish occurs at index i + p and first occurred at index i.
    Runs in O(n) time and space.  Guarantees i + p <= n.
    """
    first_seen: Dict[int, int] = {}
    cur = d
    step = 0
    while cur not in first_seen:
        first_seen[cur] = step
        cur = residue(t, cur)
        step += 1
    i = first_seen[cur]
    p = step - i
    return i, p


def state_complexity(t: Test, d: int) -> int:
    """preperiod + period of the transcript of `t` at `d` (the dish count needed)."""
    i, p = minimal_recurrence(t, d)
    return i + p


def observationally_equivalent(t: Test, d: int, e: int) -> bool:
    """
    Decide observational equivalence using exactly n runs.
    Justified by the sharpened indistinguishability theorem.
    """
    n = len(t)
    return transcript(t, d, n) == transcript(t, e, n)


# ---------------------------------------------------------------------------
# 4. The named tests
# ---------------------------------------------------------------------------

FLIP: Test = [(True, 1), (True, 0)]            # accepts, swaps: rev + rep, destructive
READFLIP: Test = [(False, 1), (True, 0)]       # reports, swaps: rev, NOT rep
BURN: Test = [(True, 0), (True, 0)]            # accepts, incinerates: rep, NOT rev
READ: Test = [(False, 0), (True, 1)]           # a certificate reporting the dish


def fuse_test(k: int) -> Test:
    """
    The fuse test on k + 2 dishes: the dish advances one notch per run and
    sticks at the last notch, where the verdict flips.  Destruction depth k+1.
    """
    n = k + 2
    return [(j <= k, min(j + 1, k + 1)) for j in range(n)]


def rho_test(i: int, p: int, stream: Sequence[bool]) -> Test:
    """
    The rho test on i + p dishes realising the eventually periodic stream
    `stream` (which must satisfy stream[m+p] == stream[m] for m >= i).
    Residue map: a tail 0 -> 1 -> ... -> i+p-1 feeding back to position i.
    """
    n = i + p
    assert p > 0 and len(stream) >= n
    return [(bool(stream[j]), j + 1 if j + 1 < n else i) for j in range(n)]


CLOCK: Test = [
    (True, 1),   # 0 -> 1
    (False, 0),  # 1 -> 0     two-cycle {0,1}
    (True, 3),   # 2 -> 3
    (False, 4),  # 3 -> 4
    (True, 2),   # 4 -> 2     three-cycle {2,3,4}
]


# ---------------------------------------------------------------------------
# 5. Enumeration helpers
# ---------------------------------------------------------------------------

def all_tests(n: int) -> Iterable[Test]:
    """Enumerate all (2n)^n tests on n dishes."""
    cell = [(v, r) for v in (False, True) for r in range(n)]
    for combo in product(cell, repeat=n):
        yield list(combo)


def fmt(stream: Sequence[bool]) -> str:
    """Render a Boolean stream as a compact string of T/F."""
    return "".join("T" if b else "F" for b in stream)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_taxonomy() -> None:
    print("=" * 72)
    print("1.  THE TAXONOMY IS STRICT  (two dishes suffice)")
    print("=" * 72)
    named = [("flip      t(d)=(true, not d)", FLIP),
             ("readflip  t(d)=(d,    not d)", READFLIP),
             ("burn      t(d)=(true, 0)    ", BURN),
             ("read      t(d)=(d,    d)    ", READ)]
    for name, t in named:
        print(f"  {name}   ->  {classify(t)}")
    print()
    print("  flip     : reversible + repeatable, yet DESTRUCTIVE")
    print("             => reversibility does not imply nondestructiveness.")
    print("  readflip : reversible, yet NOT repeatable")
    print("             => reversibility does not imply repeatability.")
    print("             (nothing lost, but the second run contradicts the first:")
    print("              a measurement that disturbs what it measures)")
    print("  burn     : repeatable, yet NOT reversible")
    print("             => repeatability does not imply reversibility;")
    print("                the answer is stable because destruction is total.")
    print()
    assert is_reversible(FLIP) and is_repeatable(FLIP) and is_destructive(FLIP)
    assert is_reversible(READFLIP) and not is_repeatable(READFLIP)
    assert is_repeatable(BURN) and not is_reversible(BURN)
    print("  Certificates ARE reversible and repeatable (checked exhaustively")
    print("  over all tests on n = 1, 2, 3 dishes):")
    for n in (1, 2, 3):
        ok = all(is_reversible(t) and is_repeatable(t)
                 for t in all_tests(n) if is_nondestructive(t))
        print(f"    n = {n}: {ok}")
    print()


def demo_commutation() -> None:
    print("=" * 72)
    print("2.  CERTIFICATES COMMUTE;  DESTRUCTIVE TESTS DO NOT")
    print("=" * 72)
    n = 3
    certs = [t for t in all_tests(n) if is_nondestructive(t)]
    print(f"  On n = {n} dishes there are {len(certs)} certificates.")
    all_commute = all(seq(a, b) == seq(b, a) for a in certs for b in certs)
    print(f"  Every pair of certificates commutes: {all_commute}")
    assert all_commute
    print()
    ab, ba = seq(READ, BURN), seq(BURN, READ)
    print("  Now insert one destructive test.  With  read(d) = (d, d)  and")
    print("  burn(d) = (true, 0)  on two dishes:")
    print(f"    read then burn : verdicts {fmt([verdict(ab, d) for d in range(2)])}"
          f"   residues {[residue(ab, d) for d in range(2)]}")
    print(f"    burn then read : verdicts {fmt([verdict(ba, d) for d in range(2)])}"
          f"   residues {[residue(ba, d) for d in range(2)]}")
    print("  The two orderings differ IN THE VERDICT, not merely in the residue:")
    print("  the order of a battery becomes observable to the verifier.")
    assert ab != ba
    assert [verdict(ab, d) for d in range(2)] != [verdict(ba, d) for d in range(2)]
    print()
    print("  Fraction of commuting ordered pairs among ALL tests on 2 dishes:")
    ts = list(all_tests(2))
    comm = sum(1 for a in ts for b in ts if seq(a, b) == seq(b, a))
    print(f"    {comm} / {len(ts) ** 2} = {comm / len(ts) ** 2:.4f}")
    print()
    print("  Repeatability is NOT closed under composition:")
    comp = seq(READ, FLIP)
    print(f"    read (repeatable) . flip (repeatable)  ->  {classify(comp)}")
    assert is_repeatable(READ) and is_repeatable(FLIP) and not is_repeatable(comp)
    print()


def demo_census() -> None:
    print("=" * 72)
    print("3.  CENSUS:  (2n)^n TESTS,  2^n CERTIFICATES,  2^n * n! REVERSIBLE")
    print("=" * 72)
    print(f"  {'n':>3} {'tests':>10} {'(2n)^n':>10} {'certs':>8} {'2^n':>8}"
          f" {'revers.':>9} {'2^n n!':>9} {'ratio':>8}")
    for n in (1, 2, 3):
        ts = list(all_tests(n))
        c = sum(1 for t in ts if is_nondestructive(t))
        r = sum(1 for t in ts if is_reversible(t))
        print(f"  {n:>3} {len(ts):>10} {(2 * n) ** n:>10} {c:>8} {2 ** n:>8}"
              f" {r:>9} {2 ** n * factorial(n):>9} {(2 * n) ** n / 2 ** n:>8.0f}")
        assert len(ts) == (2 * n) ** n
        assert c == 2 ** n
        assert r == 2 ** n * factorial(n)
    print()
    print("  The ratio (2n)^n / 2^n = n^n: the classical predicate model of")
    print("  verification describes an exponentially thin sliver of the tests.")
    print()


def demo_rigidity() -> None:
    print("=" * 72)
    print("4.  TRANSCRIPT RIGIDITY AND THE SHARP DEPTH HIERARCHY")
    print("=" * 72)
    print("  Rigidity: on n dishes, a transcript constant on its first n entries")
    print("  is constant forever.  Verified exhaustively for n = 1..4 by")
    print("  comparing against 40 further runs:")
    for n in (1, 2, 3, 4):
        ok = True
        for t in all_tests(n):
            for d in range(n):
                tr = transcript(t, d, n)
                if all(b == tr[0] for b in tr):
                    long = transcript(t, d, n + 40)
                    if not all(b == long[0] for b in long):
                        ok = False
        print(f"    n = {n}: rigidity holds for all {(2 * n) ** n} tests: {ok}")
        assert ok
    print()
    print("  Sharpness: the fuse test on n = k+2 dishes hides its")
    print("  destructiveness for exactly n-1 runs and never for n.")
    print(f"    {'k':>3} {'n':>3} {'transcript from dish 0':>26} {'depth':>6}"
          f" {'n-1':>4}")
    for k in range(6):
        t = fuse_test(k)
        n = k + 2
        print(f"    {k:>3} {n:>3} {fmt(transcript(t, 0, n + 2)):>26}"
              f" {destruction_depth(t, 0):>6} {n - 1:>4}")
        assert destruction_depth(t, 0) == n - 1
    print()
    print("  Corollary (finite testing certifies infinite testing): a dish that")
    print("  survives n consecutive accepting runs survives arbitrarily many.")
    for k in range(4):
        t = fuse_test(k)
        n = k + 2
        survives_n = verdict(batch(t, n), 0)
        survives_nm1 = verdict(batch(t, n - 1), 0)
        print(f"    fuse_{k} on {n} dishes: accepted after {n-1} runs ="
              f" {survives_nm1}, after {n} runs = {survives_n}")
    print()


def demo_realization() -> None:
    print("=" * 72)
    print("5.  STATE-COMPLEXITY DUALITY:  WHICH VERDICT STREAMS EXIST?")
    print("=" * 72)
    print("  A stream is the transcript of a test on <= n dishes IFF it is")
    print("  eventually periodic with preperiod + period <= n.")
    print()
    print("  Synthesis (the rho test): a tail of length i feeding a cycle of")
    print("  length p realises any such stream on exactly i + p dishes.")
    print(f"    {'i':>2} {'p':>2} {'target prefix':>18} {'realised prefix':>18} {'ok':>4}")
    cases = [(0, 1, [True]), (0, 2, [True, False]), (1, 2, [False, True, True]),
             (2, 3, [True, True, False, True, False]),
             (3, 2, [False, False, True, True, False])]
    for i, p, base in cases:
        stream = [base[m] if m < i + p else base[i + (m - i) % p]
                  for m in range(i + p + 12)]
        t = rho_test(i, p, stream)
        got = transcript(t, 0, i + p + 12)
        print(f"    {i:>2} {p:>2} {fmt(stream)[:18]:>18} {fmt(got)[:18]:>18}"
              f" {str(got == stream):>4}")
        assert got == stream
    print()
    print("  Analysis: every transcript really is eventually periodic with")
    print("  preperiod + period <= n.  Checked over all tests on n = 1..4:")
    for n in (1, 2, 3, 4):
        worst = max(state_complexity(t, d) for t in all_tests(n) for d in range(n))
        print(f"    n = {n}: max observed state complexity i+p = {worst} (bound {n})")
        assert worst <= n
    print()
    print("  Strict hierarchy: the stream rejecting exactly at the multiples of")
    print("  n needs exactly n dishes.  (Its period must be a multiple of n.)")
    for n in range(1, 7):
        stream = [(m % n) != 0 for m in range(4 * n + 4)]
        t = rho_test(0, n, stream)
        print(f"    n = {n}: stream {fmt(stream[:12]):<12} realised on"
              f" {len(t)} dishes; state complexity {state_complexity(t, 0)}")
        assert state_complexity(t, 0) == n
    print()
    print("  Certificates sit at the bottom of the scale, at complexity 1:")
    for t in all_tests(2):
        if is_nondestructive(t):
            assert all(state_complexity(t, d) == 1 for d in range(2))
    print("    every certificate on 2 dishes has state complexity 1: True")
    print()


def demo_stabilisation() -> None:
    print("=" * 72)
    print("6.  STABILISATION:  DESTRUCTION IS CONFINED TO THE TRANSIENT")
    print("=" * 72)
    print("  For every test there is a batch length N > 0 with r^N idempotent;")
    print("  on the stabilised core the ORIGINAL residue map is a bijection.")
    print()

    def stabilise(t: Test) -> Tuple[int, Set[int]]:
        n = len(t)
        for N in range(1, 4 * n + 4):
            rN = [residue(batch(t, N), d) for d in range(n)]
            if all(rN[rN[d]] == rN[d] for d in range(n)):
                return N, set(rN)
        raise RuntimeError("no idempotent iterate found")

    for name, t in [("fuse_2", fuse_test(2)), ("clock", CLOCK), ("burn", BURN),
                    ("rho(2,3)", rho_test(2, 3, [True, False, True, False, True]))]:
        N, core = stabilise(t)
        images = {residue(t, c) for c in core}
        bijective = images == core and len(images) == len(core)
        print(f"    {name:<10} n = {len(t)}  N = {N}  core = {sorted(core)}"
              f"  residue bijective on core: {bijective}")
        assert bijective
    print()
    print("  Exhaustive check over all tests on n = 1..4 dishes:")
    for n in (1, 2, 3, 4):
        ok = True
        for t in all_tests(n):
            N, core = stabilise(t)
            if {residue(t, c) for c in core} != core:
                ok = False
        print(f"    n = {n}: residue map bijective on the stabilised core: {ok}")
        assert ok
    print()


def demo_indistinguishability() -> None:
    print("=" * 72)
    print("7.  OBSERVATIONAL EQUIVALENCE IS DECIDED BY n RUNS")
    print("=" * 72)
    print("  If two dishes give the same verdict for the first n runs, they")
    print("  give the same verdict forever.  Checked exhaustively:")
    for n in (1, 2, 3, 4):
        ok = True
        worst_delay = -1
        for t in all_tests(n):
            for d in range(n):
                for e in range(d + 1, n):
                    a, b = transcript(t, d, 3 * n + 12), transcript(t, e, 3 * n + 12)
                    if a[:n] == b[:n] and a != b:
                        ok = False
                    for m, (x, y) in enumerate(zip(a, b)):
                        if x != y:
                            worst_delay = max(worst_delay, m)
                            break
        print(f"    n = {n}: n-prefix agreement implies full agreement: {ok};"
              f"  worst first-disagreement index = {worst_delay}"
              f"  (bound n-1 = {n - 1})")
        assert ok
    print()
    print("  The enumeration shows the true threshold is n-1, not n: no pair")
    print("  ever first disagrees at index n-1.  This is Conjecture 1.")
    print()
    print("  Watching really is necessary.  The five-dish clock test has a")
    print("  two-cycle {0,1} and a three-cycle {2,3,4} with verdicts TFTFT:")
    a = transcript(CLOCK, 0, 8)
    b = transcript(CLOCK, 2, 8)
    print(f"    transcript from dish 0 : {fmt(a)}   (period 2)")
    print(f"    transcript from dish 2 : {fmt(b)}   (period 3)")
    first = next(m for m in range(8) if a[m] != b[m])
    print(f"    they agree at steps 0,1,2 and first disagree at step {first}")
    assert a[:3] == b[:3] and a[3] != b[3]
    print(f"    Fine-Wilf window for coprime periods 2 and 3:"
          f" 2 + 3 - gcd(2,3) = {2 + 3 - gcd(2, 3)} = n - 1")
    print(f"    observationally equivalent (n-run test): "
          f"{observationally_equivalent(CLOCK, 0, 2)}")
    print()


def demo_invariance() -> None:
    print("=" * 72)
    print("8.  A REPEATABLE TEST PRESERVES THE PROPERTY IT DECIDES")
    print("=" * 72)
    print("  If t is repeatable and accepts exactly the dishes with property P,")
    print("  then P(r(d)) <=> P(d): destruction is steered, not forbidden.")
    print("  Checked over all tests on n = 1..4 (P = the accepted set):")
    for n in (1, 2, 3, 4):
        ok = True
        witnesses = 0
        for t in all_tests(n):
            if not is_repeatable(t):
                continue
            witnesses += 1
            for d in range(n):
                if verdict(t, residue(t, d)) != verdict(t, d):
                    ok = False
        print(f"    n = {n}: {witnesses} repeatable tests, invariance holds: {ok}")
        assert ok
    print()
    print("  It genuinely uses repeatability -- readflip decides {1} on two")
    print("  dishes but is not repeatable, and it destroys that very property:")
    print(f"    readflip: 1 satisfies P, residue(1) = {residue(READFLIP, 1)}"
          f" which does not.")
    print()


def main() -> None:
    print()
    print("#" * 72)
    print("#  DESTRUCTIVE VERIFICATION: VERDICTS WITH A RESIDUAL DISH")
    print("#" * 72)
    print()
    demo_taxonomy()
    demo_commutation()
    demo_census()
    demo_rigidity()
    demo_realization()
    demo_stabilisation()
    demo_indistinguishability()
    demo_invariance()
    print("=" * 72)
    print("All assertions passed.")
    print("=" * 72)
    print()


if __name__ == "__main__":
    main()
