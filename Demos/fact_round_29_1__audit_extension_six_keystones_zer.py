"""
Structural Reproducibility: numerical demonstrations.
=====================================================

Self-contained numerical companion to the paper "Structural Reproducibility:
An Arithmetic Theory of Audited Pipeline Statistics".

Every demonstration below checks, by direct computation, a statement that the
paper proves:

  1. Rebatching invariance      E(L, s) = E(L', s) whenever sum(L) = sum(L').
  2. Exact orbit-count law      |S_k| = min(k+1, N) for a single integer N,
                                for ARBITRARY deterministic step maps.
  3. Deficit slope detector     d(k+1) - d(k) = 1  <=>  N <= k+1,
                                so N is readable off the deficit column.
  4. Rotation exact curve       I(k) = log2 min(k+1, m); unit slope after
                                saturation; strict ramp before it.
  5. Capacity envelope          every congruential pipeline obeys
                                I(k) <= log2 min(k+1, m), attained by a=c=1.
  6. Synergy closed form        S(p,q) = log2( min(p,q) / gcd(p,q) ).
  7. One-bit quantisation gap   S(p,q) is 0 or >= 1; never in (0,1).
  8. Partition of unity         overlap + S / I(min) = 1.
  9. Exact ramp law             P1(q,r) = ramp(q / r^2), with no error term.
 10. Forbidden-zone audit       the reported synergies +0.1290 and +0.0049
                                are unattainable by integer-period channels,
                                and the reported capacity I(6) = 11.5307
                                violates I(k) <= log2(k+1).

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from math import gcd, log2
from typing import Callable, Dict, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# Section 0. The pipeline model
# ----------------------------------------------------------------------------


def step(a: int, c: int, m: int, x: int) -> int:
    """One step of the congruential pipeline: x -> (a*x + c) mod m."""
    return (a * x + c) % m


def run(a: int, c: int, m: int, n: int, s: int) -> int:
    """State after n steps from seed s."""
    x = s
    for _ in range(n):
        x = step(a, c, m, x)
    return x


def run_batches(a: int, c: int, m: int, schedule: Sequence[int], s: int) -> int:
    """Execute a schedule of batch sizes, one batch after another."""
    x = s
    for n in schedule:
        x = run(a, c, m, n, x)
    return x


def visited(a: int, c: int, m: int, s: int, k: int) -> Set[int]:
    """The set of distinct states seen at times 0, 1, ..., k."""
    seen: Set[int] = set()
    x = s
    for _ in range(k + 1):
        seen.add(x)
        x = step(a, c, m, x)
    return seen


def capacity(a: int, c: int, m: int, s: int, k: int) -> float:
    """Orbit capacity I(k) = log2 |S_k|, in bits."""
    return log2(len(visited(a, c, m, s, k)))


def deficit(a: int, c: int, m: int, s: int, k: int) -> float:
    """Deficit d(k) = k - I(k): bits owed against the ideal of one per step."""
    return k - capacity(a, c, m, s, k)


# ----------------------------------------------------------------------------
# Section 1. Rebatching invariance
# ----------------------------------------------------------------------------


def demo_rebatching() -> None:
    print("=" * 76)
    print("1. REBATCHING INVARIANCE    E(L,s) = E(L',s) when sum(L) = sum(L')")
    print("=" * 76)
    a, c, m, s = 1103515245, 12345, 2 ** 31, 7
    schedules: List[List[int]] = [
        [60],
        [30, 30],
        [1] * 60,
        [7, 13, 40],
        [59, 1],
        [0, 60, 0],
    ]
    outs = [run_batches(a, c, m, L, s) for L in schedules]
    for L, out in zip(schedules, outs):
        label = str(L) if len(L) <= 5 else f"[1]*{len(L)} (sixty unit batches)"
        print(f"  schedule {label:<34} total={sum(L):>3}  final state = {out}")
    assert len(set(outs)) == 1, "rebatching invariance violated"
    print(f"\n  All {len(outs)} schedules agree.  Theorem: the terminal state is a")
    print("  function of (seed, total step count) alone.\n")

    # Batch sensitivity certifies hidden state: a process with a hidden counter.
    print("  Contrast: a process carrying HIDDEN STATE (a per-batch reset).")

    def hidden_process(schedule: Sequence[int], s0: int) -> int:
        """Pipeline that also adds a per-batch penalty: not an iterated step."""
        x = s0
        for n in schedule:
            x = run(a, c, m, n, x)
            x = (x + 1) % m  # per-batch bookkeeping the unit step cannot see
        return x

    h1, h2 = hidden_process([60], s), hidden_process([30, 30], s)
    print(f"    one batch of 60 : {h1}")
    print(f"    two batches of 30: {h2}")
    assert h1 != h2
    print("    Different.  By the Rebatching Characterisation this DISPROVES that")
    print("    the process is the iterate of any visible unit step: hidden state.\n")


# ----------------------------------------------------------------------------
# Section 2. The exact orbit-count law, for arbitrary step maps
# ----------------------------------------------------------------------------


def orbit_counts(f: Callable[[int], int], s: int, kmax: int) -> List[int]:
    """|O_k| for k = 0..kmax, where O_k is the orbit prefix of f from s."""
    seen: Set[int] = set()
    counts: List[int] = []
    x = s
    for _ in range(kmax + 1):
        seen.add(x)
        counts.append(len(seen))
        x = f(x)
    return counts


def fitted_orbit_size(counts: Sequence[int]) -> int:
    """The orbit size N implied by a count column: its eventual maximum."""
    return max(counts)


def demo_orbit_count_law() -> None:
    print("=" * 76)
    print("2. EXACT ORBIT-COUNT LAW     |S_k| = min(k+1, N)  for ANY step map")
    print("=" * 76)
    m = 64
    maps: Dict[str, Callable[[int], int]] = {
        "rotation      x -> x+1 mod 64": lambda x: (x + 1) % m,
        "LCG           x -> 5x+3 mod 64": lambda x: (5 * x + 3) % m,
        "degenerate    x -> 4x   mod 64": lambda x: (4 * x) % m,
        "squaring      x -> x^2+1 mod 64": lambda x: (x * x + 1) % m,
        "no structure  x -> (x^3+37x+11) mod 64": lambda x: (x ** 3 + 37 * x + 11) % m,
    }
    for name, f in maps.items():
        counts = orbit_counts(f, 7, 80)
        N = fitted_orbit_size(counts)
        predicted = [min(k + 1, N) for k in range(len(counts))]
        ok = counts == predicted
        print(f"  {name:<40} N = {N:>3}   law holds: {ok}")
        assert ok, f"orbit-count law violated for {name}"
    print("\n  Finiteness alone forces the shape: no periodicity assumed.\n")


# ----------------------------------------------------------------------------
# Section 3. The deficit slope detector
# ----------------------------------------------------------------------------


def deficit_column(f: Callable[[int], int], s: int, kmax: int) -> List[float]:
    """The published deficit column d(k) = k - log2|S_k|."""
    return [k - log2(c) for k, c in enumerate(orbit_counts(f, s, kmax))]


def detect_orbit_size(column: Sequence[float], tol: float = 1e-9) -> int:
    """Recover the orbit size from a deficit column: the first unit jump."""
    for k in range(len(column) - 1):
        if abs((column[k + 1] - column[k]) - 1.0) < tol:
            return k + 1
    raise ValueError("column never saturates within the observed range")


def demo_detector() -> None:
    print("=" * 76)
    print("3. DEFICIT SLOPE DETECTOR    d(k+1)-d(k) = 1  <=>  orbit exhausted")
    print("=" * 76)
    m = 100
    cases: List[Tuple[str, Callable[[int], int], int]] = [
        ("x -> x+1 mod 100", lambda x: (x + 1) % m, 0),
        ("x -> 7x+3 mod 100", lambda x: (7 * x + 3) % m, 1),
        ("x -> 10x mod 100", lambda x: (10 * x) % m, 3),
        ("x -> x^2+1 mod 100", lambda x: (x * x + 1) % m, 5),
    ]
    print(f"  {'step map':<22}{'true N':>8}{'detected N':>13}   first deficit differences")
    for name, f, s in cases:
        col = deficit_column(f, s, 220)
        true_N = fitted_orbit_size(orbit_counts(f, s, 220))
        got = detect_orbit_size(col)
        diffs = " ".join(f"{col[k + 1] - col[k]:.3f}" for k in range(min(6, len(col) - 1)))
        print(f"  {name:<22}{true_N:>8}{got:>13}   {diffs}")
        assert got == true_N
    print("\n  The orbit size is recoverable from the deficit column alone --")
    print("  no access to the pipeline's internals is required.\n")


# ----------------------------------------------------------------------------
# Section 4-5. The rotation curve and the capacity envelope
# ----------------------------------------------------------------------------


def demo_rotation_and_envelope() -> None:
    print("=" * 76)
    print("4-5. ROTATION EXACT CURVE AND THE CAPACITY ENVELOPE")
    print("=" * 76)
    m, s = 12, 5
    print(f"  Rotation pipeline  x -> x+1 mod {m},  seed {s}")
    print(f"  {'k':>3}{'|S_k|':>8}{'I(k)':>10}{'predicted':>12}{'d(k)':>10}{'slope':>9}")
    prev_d = None
    for k in range(0, 17):
        card = len(visited(1, 1, m, s, k))
        I = log2(card)
        pred = log2(min(k + 1, m))
        d = k - I
        slope = "-" if prev_d is None else f"{d - prev_d:.4f}"
        print(f"  {k:>3}{card:>8}{I:>10.4f}{pred:>12.4f}{d:>10.4f}{slope:>9}")
        assert abs(I - pred) < 1e-12
        prev_d = d
    print("\n  Before saturation the slope is < 1 and strictly positive (ramping);")
    print("  from k = m-1 = 11 on it is exactly 1.\n")

    print("  Envelope check: I_{a,c}(k) <= log2 min(k+1, m) for every (a,c).")
    worst_gap = 0.0
    attained = False
    for a in range(0, m):
        for c in range(0, m):
            for k in range(0, 2 * m):
                I = capacity(a, c, m, s, k)
                env = log2(min(k + 1, m))
                assert I <= env + 1e-12, f"envelope violated at a={a}, c={c}, k={k}"
                worst_gap = max(worst_gap, env - I)
                if a == 1 and c == 1:
                    attained = attained or abs(env - I) < 1e-12
    print(f"    checked all {m * m} parameter pairs over k < {2 * m}: no violation")
    print(f"    largest shortfall below the envelope: {worst_gap:.4f} bits")
    print(f"    envelope attained by the rotation (a=c=1): {attained}\n")


# ----------------------------------------------------------------------------
# Section 6-8. The synergy calculus
# ----------------------------------------------------------------------------


def channel_capacity(n: int) -> float:
    """Capacity of a channel with n configurations, in bits."""
    return log2(n)


def lcm(p: int, q: int) -> int:
    return p * q // gcd(p, q)


def synergy_direct(p: int, q: int) -> float:
    """S(p,q) by its definition: I(lcm) - max(I(p), I(q))."""
    return channel_capacity(lcm(p, q)) - max(channel_capacity(p), channel_capacity(q))


def synergy_closed_form(p: int, q: int) -> float:
    """S(p,q) = log2( min(p,q) / gcd(p,q) )."""
    return log2(min(p, q) / gcd(p, q))


def overlap(p: int, q: int) -> float:
    """Overlap coefficient: I(gcd) / min(I(p), I(q))."""
    return channel_capacity(gcd(p, q)) / min(channel_capacity(p), channel_capacity(q))


def joint_configurations(p: int, q: int, ticks: int) -> int:
    """Number of distinct joint configurations (i mod p, i mod q), i < ticks."""
    return len({(i % p, i % q) for i in range(ticks)})


def demo_synergy() -> None:
    print("=" * 76)
    print("6-8. SYNERGY: CLOSED FORM, ONE-BIT GAP, PARTITION OF UNITY")
    print("=" * 76)

    print("  Joint orbit size equals lcm(p,q):")
    for p, q in [(4, 6), (3, 5), (12, 18), (7, 7)]:
        L = lcm(p, q)
        obs = joint_configurations(p, q, L)
        print(f"    p={p:>3}, q={q:>3}:  lcm = {L:>4}, observed configurations = {obs:>4}")
        assert obs == L

    print("\n  Closed form and inclusion-exclusion, over all 2 <= p,q <= 60:")
    max_err = 0.0
    for p in range(2, 61):
        for q in range(2, 61):
            max_err = max(max_err, abs(synergy_direct(p, q) - synergy_closed_form(p, q)))
            ie = (channel_capacity(lcm(p, q)) + channel_capacity(gcd(p, q))
                  - channel_capacity(p) - channel_capacity(q))
            max_err = max(max_err, abs(ie))
            unity = overlap(p, q) + synergy_direct(p, q) / channel_capacity(min(p, q))
            max_err = max(max_err, abs(unity - 1.0))
    print(f"    max deviation across closed form, inclusion-exclusion, unity: {max_err:.2e}")
    assert max_err < 1e-9

    print("\n  THE ONE-BIT GAP.  Exhaustive scan of 2 <= p,q <= 400:")
    in_gap = 0
    zero, unit, above = 0, 0, 0
    smallest_positive = float("inf")
    for p in range(2, 401):
        for q in range(2, 401):
            S = synergy_direct(p, q)
            if S < 1e-12:
                zero += 1
            else:
                smallest_positive = min(smallest_positive, S)
                if abs(S - 1.0) < 1e-12:
                    unit += 1
                else:
                    above += 1
                if S < 1.0 - 1e-12:
                    in_gap += 1
    total = 399 * 399
    print(f"    pairs examined              : {total}")
    print(f"    synergy exactly 0 (nested)  : {zero}")
    print(f"    synergy exactly 1 bit       : {unit}")
    print(f"    synergy above 1 bit         : {above}")
    print(f"    synergy strictly in (0,1)   : {in_gap}   <-- provably always 0")
    print(f"    smallest nonzero synergy    : {smallest_positive:.12f} bits")
    assert in_gap == 0 and abs(smallest_positive - 1.0) < 1e-12

    print("\n  Equality case: S(p,q) = 1 exactly when min(p,q) = 2*gcd(p,q).")
    for p, q in [(4, 6), (6, 10), (9, 15), (6, 4)]:
        print(f"    p={p:>3}, q={q:>3}:  S = {synergy_direct(p, q):.6f},"
              f"  min = {min(p, q)}, 2*gcd = {2 * gcd(p, q)}")
        assert (abs(synergy_direct(p, q) - 1.0) < 1e-12) == (min(p, q) == 2 * gcd(p, q))
    print()


# ----------------------------------------------------------------------------
# Section 9. The ramp law
# ----------------------------------------------------------------------------


def ramp(x: float) -> float:
    """The clamp of x to [0,1]."""
    return max(0.0, min(1.0, x))


def success_fraction(q: int, r: int) -> float:
    """P1(q,r): fraction of r x r grid cells whose reading-order index is < q."""
    count = sum(1 for i in range(r) for j in range(r) if i * r + j < q)
    return count / (r * r)


def demo_ramp() -> None:
    print("=" * 76)
    print("9. THE RAMP LAW IS EXACT     P1(q,r) = ramp(q / r^2)")
    print("=" * 76)
    worst = 0.0
    for r in range(1, 13):
        for q in range(0, 2 * r * r + 3):
            worst = max(worst, abs(success_fraction(q, r) - ramp(q / (r * r))))
    print(f"  grid sizes r = 1..12, budgets q = 0..2r^2+2")
    print(f"  maximum |P1(q,r) - ramp(q/r^2)| = {worst:.1e}   (exact identity, not a fit)")
    assert worst == 0.0
    r = 5
    print(f"\n  Sample column, r = {r} (so r^2 = {r * r}):")
    print(f"  {'q':>4}{'cells counted':>16}{'P1':>10}{'ramp(q/r^2)':>14}")
    for q in [0, 1, 7, 12, 24, 25, 26, 40]:
        cells = sum(1 for i in range(r) for j in range(r) if i * r + j < q)
        print(f"  {q:>4}{cells:>16}{success_fraction(q, r):>10.4f}{ramp(q / (r * r)):>14.4f}")
    print()


# ----------------------------------------------------------------------------
# Section 10. Auditing the audit: the forbidden zone
# ----------------------------------------------------------------------------


def attainable_synergies(bound: int) -> List[float]:
    """All synergy values attainable by integer channels with periods <= bound."""
    vals = sorted({round(synergy_direct(p, q), 12)
                   for p in range(2, bound + 1) for q in range(2, bound + 1)})
    return vals


def demo_forbidden_zone() -> None:
    print("=" * 76)
    print("10. AUDITING THE AUDIT: THE FORBIDDEN ZONE")
    print("=" * 76)
    vals = attainable_synergies(400)
    low = [v for v in vals if v < 2.0]
    print("  Attainable synergy values below 2 bits (periods up to 400):")
    print("    " + ", ".join(f"{v:.6f}" for v in low))
    print("\n  Every attainable value is log2 of a positive integer:")
    print("    0 = log2 1,  1 = log2 2,  1.584963 = log2 3,  2 = log2 4, ...")
    print("  so the open interval (0, 1) contains NO attainable value.\n")

    reported = {"S3a x S3b": 0.1290, "A4 x D4": 0.0049}
    print("  Reported audit synergies:")
    for name, value in reported.items():
        forbidden = 0.0 < value < 1.0
        nearest = min(vals, key=lambda v: abs(v - value))
        verdict = "IN THE FORBIDDEN ZONE" if forbidden else "attainable"
        print(f"    {name:<12} {value:+.4f} bits   -> {verdict}")
        print(f"      nearest attainable value: {nearest:.6f} bits"
              f"  (distance {abs(nearest - value):.4f})")
        assert forbidden
    print("\n  Conclusion: these numbers reproduce exactly on re-execution, yet no pair")
    print("  of exactly periodic integer channels can produce them.  Executional")
    print("  reproducibility does not certify semantic validity.")

    # Illustration of reconciliation (3): averaging over many nested pairs.
    print("\n  Illustration -- reconciliation by averaging.  Take 204 channel pairs of")
    print("  which exactly one is non-nested with unit synergy:")
    pairs = [(2, 4)] * 203 + [(4, 6)]
    avg = sum(synergy_direct(p, q) for p, q in pairs) / len(pairs)
    print(f"    mean synergy over the collection = {avg:.4f} bits")
    print("    -- a value in the forbidden zone, measuring PREVALENCE of non-nesting,")
    print("       not the synergy of any pair.\n")

    # A second admissibility check: the capacity/deficit pair.
    print("  Second admissibility check -- the capacity column.")
    print("  In the single-orbit model  |S_k| <= k+1,  so  I(k) <= log2(k+1)  and  d(k) >= 0.")
    for k, reported_I in [(6, 11.5307)]:
        bound = log2(k + 1)
        print(f"    reported I({k}) = {reported_I:.4f} bits;  model bound log2({k + 1}) "
              f"= {bound:.4f} bits")
        print(f"    implied deficit d({k}) = {k} - {reported_I:.4f} = {k - reported_I:+.4f}"
              "  -- negative, and the model forces d >= 0")
        assert reported_I > bound and k - reported_I < 0
    print("    Hence the reported capacity and the reported deficit column cannot BOTH be")
    print("    the single-orbit quantities: at least one measures something else.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 76)
    print("#  STRUCTURAL REPRODUCIBILITY -- NUMERICAL DEMONSTRATIONS".ljust(75) + "#")
    print("#" * 76)
    print()
    demo_rebatching()
    demo_orbit_count_law()
    demo_detector()
    demo_rotation_and_envelope()
    demo_synergy()
    demo_ramp()
    demo_forbidden_zone()
    print("=" * 76)
    print("All assertions passed: every computed value matches the proved statement.")
    print("=" * 76)


if __name__ == "__main__":
    main()
