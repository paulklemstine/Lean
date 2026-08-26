"""
Certified Evidence: numerical demonstrations
============================================

Self-contained numerical companion to the paper
"Certified Evidence: The Exact Logical Strength of Bounded Verification,
with Application to the 3n+1 Problem".

Every demonstration below corresponds to a theorem in the paper:

  1. The reflection calculus: bounded checks, the gluing law, and
     counterexample extraction.
  2. Insufficiency: the truncation operator produces a predicate with an
     identical certificate on [1, N] and a failure at N + 1.
  3. Descent certificates: soundness in action, with the periodic certificate
     for  n^5 = n (mod 10)  (ten inputs) and the shift certificate for the
     numerical semigroup <3,5>  (three inputs).
  4. The Collatz instance: the accelerated map, the mod-4 sieve, the exact
     workload  floor((B+1)/4) + 2  at scale 2, the drop-below test and its
     average cost, and reproduction of the certified bounds
     20 -> 1000 -> 4000 -> 131072.
  5. The scale-k sieve: enumeration of non-contracting residue classes via the
     integer condition  2^k <= 3^{s_k(r)},  and the vanishing density of the
     examined fraction.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Tuple

Predicate = Callable[[int], bool]


# ---------------------------------------------------------------------------
# 1. The reflection calculus
# ---------------------------------------------------------------------------


def check_from(p: Predicate, lo: int, length: int) -> bool:
    """Bounded conjunction of p over the `length` inputs starting at `lo`."""
    for k in range(lo, lo + length):
        if not p(k):
            return False
    return True


def check_range(p: Predicate, lo: int, hi: int) -> bool:
    """Bounded conjunction over the closed window [lo, hi]; empty windows pass."""
    return check_from(p, lo, max(0, hi + 1 - lo))


def first_fail(p: Predicate, lo: int, length: int) -> Optional[int]:
    """The least counterexample in the window, or None if the window is certified."""
    for k in range(lo, lo + length):
        if not p(k):
            return k
    return None


def demo_reflection() -> None:
    print("=" * 74)
    print("1. THE REFLECTION CALCULUS")
    print("=" * 74)

    def p(n: int) -> bool:
        return n * n >= n  # true everywhere

    def q(n: int) -> bool:
        return n != 37  # a planted counterexample

    print(f"  check_range(n^2 >= n, 1, 50)          = {check_range(p, 1, 50)}")
    print(f"  check_range(n != 37, 1, 50)           = {check_range(q, 1, 50)}")
    print(f"  first_fail(n != 37, 1, 50)            = {first_fail(q, 1, 50)}"
          "   <- explicit counterexample extraction")

    # Gluing law:  C(lo, hi) = C(lo, mid) AND C(mid+1, hi).
    lo, mid, hi = 1, 23, 50
    glued = check_range(p, lo, mid) and check_range(p, mid + 1, hi)
    print(f"\n  Gluing law on [{lo},{hi}] split at {mid}:")
    print(f"    whole = {check_range(p, lo, hi)},  left AND right = {glued}"
          f"   -> agree: {check_range(p, lo, hi) == glued}")

    # Gluing across many chunks: chunked / parallel / resumable certification.
    chunks: List[Tuple[int, int]] = [(1, 10), (11, 20), (21, 30), (31, 40), (41, 50)]
    chunked = all(check_range(p, a, b) for a, b in chunks)
    print(f"    five-chunk certification of [1,50]  = {chunked}"
          f"   -> agree: {chunked == check_range(p, lo, hi)}")
    print()


# ---------------------------------------------------------------------------
# 2. Insufficiency: truncation and the version space
# ---------------------------------------------------------------------------


def truncate(p: Predicate, bound: int) -> Predicate:
    """The truncation of p at `bound`: agrees below, false above."""

    def q(k: int) -> bool:
        return p(k) and k <= bound

    return q


def demo_insufficiency() -> None:
    print("=" * 74)
    print("2. NO FINITE CERTIFICATE IS SOUND")
    print("=" * 74)

    def always_true(_: int) -> bool:
        return True

    print("  For each bound N, the truncation of a predicate at N produces the")
    print("  SAME certificate on [1,N] and is false at N+1.\n")
    print(f"    {'N':>10}  {'cert on [1,N] agrees':>22}  {'value at N+1':>14}")
    for bound in (20, 100, 1000, 10 ** 4, 10 ** 5):
        sabotaged = truncate(always_true, bound)
        agrees = check_range(sabotaged, 1, bound) == check_range(always_true, 1, bound)
        print(f"    {bound:>10}  {str(agrees):>22}  {str(sabotaged(bound + 1)):>14}")

    print("\n  The version space after a certificate on [1,N] is grafted from")
    print("  arbitrary behaviour beyond N; the grafting map is injective, so the")
    print("  version space has the cardinality of the continuum.  Counting the")
    print("  hypotheses distinguishable on the first m untested inputs:\n")
    print(f"    {'m untested inputs':>20}  {'distinct consistent hypotheses':>32}")
    for m in (1, 2, 4, 8, 16, 32, 64):
        print(f"    {m:>20}  {2 ** m:>32}")
    print("    (as m -> oo this is 2^aleph_0 = the continuum, for every N)")
    print()


# ---------------------------------------------------------------------------
# 3. Descent certificates
# ---------------------------------------------------------------------------


def descent_certificate_holds(
    p: Predicate, bound: int, reduce: Callable[[int], int], test_up_to: int
) -> bool:
    """Verify empirically that (bound, reduce) is a descent certificate for p
    on [1, test_up_to]: base window certified, reduction positive and strictly
    decreasing above the window, and truth transported upward."""
    if not check_range(p, 1, bound):
        return False
    for n in range(bound + 1, test_up_to + 1):
        r = reduce(n)
        if not (1 <= r < n):
            return False
        if p(r) and not p(n):
            return False
    return True


def demo_descent() -> None:
    print("=" * 74)
    print("3. DESCENT CERTIFICATES: FINITE WINDOWS THAT PROVE INFINITE THEOREMS")
    print("=" * 74)

    # (a) Periodic certificate:  n^5 = n (mod 10),  period 10, window of size 10.
    def last_digit_pow5(n: int) -> bool:
        return (n ** 5) % 10 == n % 10

    window_ok = check_range(last_digit_pow5, 1, 10)
    periodic_ok = all(last_digit_pow5(n + 10) == last_digit_pow5(n) for n in range(0, 500))
    print("  (a) Periodic certificate for  n^5 = n (mod 10):")
    print(f"        window [1,10] certified          : {window_ok}   (10 inputs)")
    print(f"        period 10 verified on [0,499]    : {periodic_ok}")
    print(f"        descent certificate (r(n)=n-10)  : "
          f"{descent_certificate_holds(last_digit_pow5, 10, lambda n: n - 10, 2000)}")
    print(f"        conclusion holds on [1,20000]    : "
          f"{check_range(last_digit_pow5, 1, 20000)}   <- proved from 10 inputs")

    # (b) Shift certificate: representability in the semigroup <3,5>.
    def repr35(n: int) -> bool:
        return any(5 * y <= n and (n - 5 * y) % 3 == 0 for y in range(n // 5 + 1))

    print("\n  (b) Shift certificate for the numerical semigroup <3,5>:")
    print(f"        window [8,10] certified          : "
          f"{check_range(repr35, 8, 10)}   (3 inputs)")
    print(f"        closed under n -> n+3 on [8,2000]: "
          f"{all((not repr35(n)) or repr35(n + 3) for n in range(8, 2001))}")
    print(f"        conclusion holds on [8,20000]    : {check_range(repr35, 8, 20000)}")
    gaps = [n for n in range(0, 200) if not repr35(n)]
    print(f"        complete gap set                 : {gaps}")
    print(f"        Frobenius number 3*5-3-5 = 7     : {max(gaps) == 7}")
    print()


# ---------------------------------------------------------------------------
# 4. The Collatz instance
# ---------------------------------------------------------------------------


def accelerated(n: int) -> int:
    """T(n) = n/2 for even n, (3n+1)/2 for odd n."""
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def classical(n: int) -> int:
    """The classical 3n+1 map."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def reaches_one(fuel: int, n: int) -> bool:
    """Fuelled checker: iterate T at most `fuel` times looking for 1."""
    x = n
    for _ in range(fuel):
        if x == 1:
            return True
        if x == 0:
            return False
        x = accelerated(x)
    return False


def orbit_length_to_one(n: int) -> int:
    """Number of accelerated steps until the orbit of n reaches 1."""
    steps, x = 0, n
    while x != 1:
        x = accelerated(x)
        steps += 1
    return steps


def drops_below(fuel: int, n: int) -> bool:
    """Succeed as soon as the orbit of n falls strictly below n."""
    x = accelerated(n)
    for _ in range(fuel):
        if x < n:
            return True
        x = accelerated(x)
    return False


def drop_steps(n: int) -> int:
    """Number of accelerated steps until the orbit of n falls below n."""
    steps, x = 1, accelerated(n)
    while x >= n:
        x = accelerated(x)
        steps += 1
    return steps


def sieved_drop(fuel: int, n: int) -> bool:
    """The production checker: skip n outside 3 mod 4, else test drop-below."""
    if n % 4 != 3:
        return True
    return drops_below(fuel, n)


def check_pow2(p: Predicate, lo: int, depth: int) -> bool:
    """Balanced binary evaluation of the conjunction over 2^depth inputs."""
    if depth == 0:
        return p(lo)
    return check_pow2(p, lo, depth - 1) and check_pow2(p, lo + 2 ** (depth - 1), depth - 1)


def demo_collatz() -> None:
    print("=" * 74)
    print("4. THE COLLATZ INSTANCE: SEMANTICS, SIEVE, AND CERTIFIED BOUNDS")
    print("=" * 74)

    print("  A sample orbit under the classical map, n = 27:")
    x, traj = 27, [27]
    while x != 1:
        x = classical(x)
        traj.append(x)
    print(f"        length {len(traj) - 1} steps, peak {max(traj)}, "
          f"first terms {traj[:10]} ...")

    print("\n  Two accelerated steps on the residue classes modulo 4:")
    for r, formula in ((0, "m"), (1, "3m+1"), (2, "3m+2"), (3, "9m+8")):
        m = 7
        n = 4 * m + r
        two = accelerated(accelerated(n))
        verdict = "DESCENDS" if two < n else "grows  <- must be examined"
        print(f"        4m+{r}: T^2({n}) = {two}  = {formula} at m={m}    {verdict}")

    # Exact workload at scale 2:  |ND(2,B)| = floor((B+1)/4) + 2.
    print("\n  Exact scale-2 workload  |{n <= B : T^2(n) >= n}| = floor((B+1)/4) + 2:")
    print(f"    {'B':>8}  {'measured':>10}  {'predicted':>10}  {'match':>6}")
    for bound in (10, 100, 1000, 10000, 50000):
        measured = sum(
            1 for n in range(1, bound + 1) if accelerated(accelerated(n)) >= n
        )
        predicted = (bound + 1) // 4 + 2
        print(f"    {bound:>8}  {measured:>10}  {predicted:>10}  "
              f"{str(measured == predicted):>6}")

    # Work per input: orbit-to-one vs drop-below.
    sample = range(3, 20003, 4)  # the examined class, 3 mod 4
    avg_full = sum(orbit_length_to_one(n) for n in sample) / len(list(sample))
    avg_drop = sum(drop_steps(n) for n in sample) / len(list(sample))
    print("\n  Work per examined input (class 3 mod 4, n < 20000):")
    print(f"        average accelerated steps, orbit to 1     : {avg_full:8.2f}")
    print(f"        average accelerated steps, drop below n   : {avg_drop:8.2f}")
    print(f"        speedup from early stopping               : {avg_full / avg_drop:8.2f}x")

    # Relative completeness: the cheap test never loses a certificate.
    lost = [n for n in range(3, 20003, 4)
            if reaches_one(400, n) and not drops_below(400, n)]
    print(f"        certificates lost by the cheap test       : {len(lost)}"
          "        <- relative completeness")

    # Reproducing the certified bounds.
    print("\n  Reproducing the certified bounds (each check below is exhaustive):")
    print(f"        naive orbit check on [1,20]        : "
          f"{check_range(lambda n: reaches_one(130, n), 1, 20)}"
          f"   (examined {20})")
    print(f"        naive orbit check on [1,1000]      : "
          f"{check_range(lambda n: reaches_one(130, n), 1, 1000)}"
          f"   (examined {1000})")
    sieved_4000 = check_range(lambda n: True if n % 4 != 3 else reaches_one(200, n), 1, 4000)
    print(f"        mod-4 sieve on [1,4000]            : {sieved_4000}"
          f"   (examined {(4000 + 1) // 4})")
    balanced = check_pow2(lambda n: sieved_drop(400, n), 1, 17)
    print(f"        sieve + drop-below, balanced, 2^17 : {balanced}"
          f"   (examined {2 ** 17 // 4})")
    print(f"        => every n <= {1 + 2 ** 17 - 1} reaches 1 under 3n+1;"
          f" a {(2 ** 17) // 20}x extension of the 20-input evidence")
    print()


# ---------------------------------------------------------------------------
# 5. The scale-k sieve and vanishing density
# ---------------------------------------------------------------------------


def odd_step_count(k: int, r: int) -> int:
    """s_k(r): the number of odd steps in the first k iterations of T from r."""
    s, x = 0, r
    for _ in range(k):
        if x % 2 == 1:
            s += 1
            x = (3 * x + 1) // 2
        else:
            x = x // 2
    return s


def noncontracting_classes(k: int) -> List[int]:
    """Residues r < 2^k with 2^k <= 3^{s_k(r)}: the classes a scale-k sieve
    must examine."""
    return [r for r in range(2 ** k) if 2 ** k <= 3 ** odd_step_count(k, r)]


def demo_scale_sieve() -> None:
    print("=" * 74)
    print("5. THE SCALE-k SIEVE: 2^k <= 3^{s_k(r)} AND VANISHING DENSITY")
    print("=" * 74)

    print("  Scale 2, class by class:")
    for r in range(4):
        s = odd_step_count(2, r)
        print(f"        r = {r}:  s_2(r) = {s},  4 <= 3^{s} = {3 ** s}"
              f"  -> {'NON-CONTRACTING' if 4 <= 3 ** s else 'contracting'}")
    print(f"        non-contracting classes at scale 2 = {noncontracting_classes(2)}"
          "   <- the mod-4 sieve, confirmed optimal")

    print("\n  Density of the examined residue classes as the scale grows:")
    print(f"    {'k':>4}  {'|NC_k|':>10}  {'2^k':>10}  {'density':>10}  "
          f"{'inputs per 10^6 certified':>26}")
    for k in range(2, 19):
        nc = len(noncontracting_classes(k))
        density = nc / 2 ** k
        print(f"    {k:>4}  {nc:>10}  {2 ** k:>10}  {density:>10.5f}  "
              f"{int(density * 10 ** 6):>26}")
    print("\n  The density is not monotone in k (the threshold k log2/log3 crosses")
    print("  integers irregularly), but along any residue class of k it decreases;")
    print("  e.g. for k = 4, 7, 10, 13, 16:")
    subseq = [(k, len(noncontracting_classes(k)) / 2 ** k) for k in (4, 7, 10, 13, 16)]
    print("        " + "  ".join(f"k={k}: {d:.4f}" for k, d in subseq))

    print("\n  Non-contraction requires s_k(r) >= k log2/log3 = 0.6309 k, while a")
    print("  random residue has s_k ~ Binomial(k, 1/2) with mean 0.5 k, so the")
    print("  density tends to 0: for every eps > 0 some scale certifies [1,B]")
    print("  from fewer than eps*B examined inputs, for all large B.")

    # Empirical soundness check of the scale-k sieve for a few k.
    print("\n  Empirical soundness of the scale-k sieve on [1,20000]:")
    for k in (2, 4, 6, 8):
        must_check = [n for n in range(1, 20001) if iterate(accelerated, k, n) >= n]
        ok = all(reaches_one(500, n) for n in must_check)
        covered = all(reaches_one(500, n) for n in range(1, 20001))
        print(f"        k = {k:>2}: examined {len(must_check):>6} of 20000 inputs "
              f"({100 * len(must_check) / 20000:5.2f}%), "
              f"examined all certified: {ok}, whole range holds: {covered}")
    print()


def iterate(f: Callable[[int], int], k: int, n: int) -> int:
    """The k-fold iterate of f applied to n."""
    x = n
    for _ in range(k):
        x = f(x)
    return x


# ---------------------------------------------------------------------------
# 6. The learning dichotomy
# ---------------------------------------------------------------------------


def demo_learning_dichotomy() -> None:
    print("=" * 74)
    print("6. THE LEARNING DICHOTOMY: SAME EVIDENCE, OPPOSITE CONCLUSIONS")
    print("=" * 74)

    period = 6
    horizon = 60

    def target(n: int) -> bool:
        return n % period in (1, 2, 5)

    evidence: Dict[int, bool] = {k: target(k) for k in range(1, period + 1)}
    print(f"  Evidence: the values of a predicate at 1..{period} -> "
          f"{[int(evidence[k]) for k in range(1, period + 1)]}\n")

    # Unrestricted class: count hypotheses consistent with the evidence, as a
    # function of how far beyond the window we look.
    print("  Unrestricted hypothesis class - hypotheses consistent with the")
    print("  evidence, distinguishable on the next m inputs:")
    for m in (1, 2, 4, 8):
        print(f"        m = {m:>2}:  {2 ** m:>6} consistent hypotheses")
    print("        (2^aleph_0 = the continuum in the limit)\n")

    # Periodic class: enumerate all period-`period` predicates consistent with
    # the evidence and check they all agree on [1, horizon].
    consistent: List[Tuple[bool, ...]] = []
    for mask in range(2 ** period):
        pattern = tuple(bool((mask >> i) & 1) for i in range(period))

        def hyp(n: int, pattern: Tuple[bool, ...] = pattern) -> bool:
            return pattern[n % period]

        if all(hyp(k) == evidence[k] for k in range(1, period + 1)):
            consistent.append(pattern)

    def behaviour(pattern: Tuple[bool, ...]) -> Tuple[bool, ...]:
        return tuple(pattern[n % period] for n in range(1, horizon + 1))

    behaviours = {behaviour(pat) for pat in consistent}
    print(f"  Period-{period} hypothesis class - consistent hypotheses: "
          f"{len(consistent)}")
    print(f"        distinct behaviours on [1,{horizon}]: {len(behaviours)}"
          "   <- the version space is a singleton")

    # Sharpness: T-1 samples do not suffice.
    print(f"\n  Sharpness: with only {period - 1} samples (1..{period - 1}) the two")
    print("  period-T hypotheses  p = true  and  q(k) = (k mod T != 0)  agree,")
    print("  and differ at T:")
    p_vals = [True for k in range(1, period)]
    q_vals = [k % period != 0 for k in range(1, period)]
    print(f"        agree on [1,{period - 1}] : {p_vals == q_vals}")
    print(f"        differ at {period}         : {True != (period % period != 0)}")
    print(f"        => sample complexity of the period-{period} class is exactly {period}")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  CERTIFIED EVIDENCE - numerical companion".ljust(73) + "#")
    print("#  what bounded verification proves, and what it provably cannot"
          .ljust(73) + "#")
    print("#" * 74)
    print()
    demo_reflection()
    demo_insufficiency()
    demo_descent()
    demo_collatz()
    demo_scale_sieve()
    demo_learning_dichotomy()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  * A bounded check is exactly the bounded statement: sound, complete,")
    print("    gluable, and refutation-complete on finite windows.")
    print("  * No finite window is sound for a universal statement; the version")
    print("    space after any check has the cardinality of the continuum.")
    print("  * A finite window plus a well-founded reduction is a SOUND AND")
    print("    COMPLETE proof system; ten inputs give n^5 = n (mod 10) and three")
    print("    inputs give the semigroup <3,5> with gap set {1,2,4,7}.")
    print("  * The mod-4 sieve is exactly optimal at its scale; higher scales")
    print("    drive the examined fraction to zero; early stopping and balanced")
    print("    evaluation carry the certified Collatz bound from 20 to 131072.")
    print("  * Evidence is worthless or conclusive according to the hypothesis")
    print("    class, never according to the amount of computation.")
    print()


if __name__ == "__main__":
    main()
