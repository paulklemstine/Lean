"""
Gated readouts and coprime boundary blocks: numerical demonstrations.

Self-contained (standard library only). Running this file reproduces, by direct
computation, every quantitative claim of the two-layer theory of
boundary-block internalization:

  Layer 1 (additive gate)
    * exact intervention arithmetic:  zeroN -> 0,
      zero1_j -> drive - w_j,  flip1_j -> drive - 2 w_j,  scale_c -> c * drive
    * uniform-block survival laws:  zero1 iff thr <= (k-1)a,  flip1 iff thr <= (k-2)a
    * flip is an EXACT dependence marker at k = 2 and uninformative at k >= 3
    * the severity staircase  zeroN <= flip1 <= zero1 <= control
    * internalization (b < d) is width-invariant; curing is width-monotone
    * retention rho(k) = b/(b+kg) is strictly decreasing, k*rho(k) -> b/g,
      and sum_k rho(k) diverges (harmonic, never geometric)
    * logical independence of the k = 1 outcome and the internalization trait
    * identifiability: control + k zeroings recover the block exactly;
      one retention reading determines the whole profile

  Layer 2 (arithmetic capacity, Chinese Remainder Theorem)
    * a pairwise coprime block resolves every range below prod(m_i) >= 2^k
    * within the margin A <= 2^(k-1) every single-dimension ablation is a no-op
    * the empty block resolves only ranges with at most one element
    * Fermat blocks 2^(2^i)+1 realise the configuration at every width
    * honest boundary: (2,3,5) resolves A = 30, but dropping 5 breaks it
    * sign flips are always free at the capacity layer

Every check prints PASS/FAIL; the script exits non-zero if any check fails.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import gcd
from typing import Callable, Dict, List, Sequence, Tuple

Q = Fraction

# --------------------------------------------------------------------------- #
# bookkeeping
# --------------------------------------------------------------------------- #

FAILURES: List[str] = []


def check(label: str, condition: bool) -> None:
    """Record and report a single verification."""
    status = "PASS" if condition else "FAIL"
    if not condition:
        FAILURES.append(label)
    print(f"  [{status}] {label}")


def header(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------- #
# Layer 1: the additive gate
# --------------------------------------------------------------------------- #


def drive(block: Sequence[Q]) -> Q:
    """Aggregate drive of a boundary block: the block is read collectively."""
    return sum(block, Q(0))


def zero_all(block: Sequence[Q]) -> List[Q]:
    """zeroN: ablate the whole boundary block."""
    return [Q(0) for _ in block]


def zero_one(block: Sequence[Q], j: int) -> List[Q]:
    """zero1_j: ablate a single coordinate."""
    out = list(block)
    out[j] = Q(0)
    return out


def flip_one(block: Sequence[Q], j: int) -> List[Q]:
    """flip1_j: negate a single coordinate."""
    out = list(block)
    out[j] = -out[j]
    return out


def scale_block(block: Sequence[Q], c: Q) -> List[Q]:
    """scale_c: rescale the whole block."""
    return [c * w for w in block]


def survives(thr: Q, block: Sequence[Q]) -> bool:
    """The answer path fires iff the aggregate drive reaches the threshold."""
    return thr <= drive(block)


def is_dependent(thr: Q) -> bool:
    """Boundary-dependent iff whole-block ablation kills the answer path."""
    return not survives(thr, [Q(0)])


def uniform(k: int, a: Q) -> List[Q]:
    """The uniform block of width k and coordinate size a."""
    return [a for _ in range(k)]


def demo_intervention_arithmetic() -> None:
    header("1. Exact arithmetic of the four interventions")
    block = [Q(3, 2), Q(1, 5), Q(-7, 4), Q(2)]
    d = drive(block)
    print(f"  block = {[str(w) for w in block]},  drive = {d}")
    check("zeroN drives the aggregate to 0", drive(zero_all(block)) == 0)
    for j in range(len(block)):
        check(
            f"zero1_{j} costs exactly w_{j}",
            drive(zero_one(block, j)) == d - block[j],
        )
        check(
            f"flip1_{j} costs exactly 2*w_{j}",
            drive(flip_one(block, j)) == d - 2 * block[j],
        )
        check(
            f"flip1_{j} = 2*zero1_{j} - control (flip reads are redundant)",
            drive(flip_one(block, j)) == 2 * drive(zero_one(block, j)) - d,
        )
    c = Q(1, 10)
    check("scale_0.1 rescales the drive", drive(scale_block(block, c)) == c * d)


def demo_uniform_laws() -> None:
    header("2. Uniform blocks: the (k-1) and (k-2) survival laws")
    a = Q(1)
    for k in (2, 3, 4, 5):
        blk = uniform(k, a)
        check(f"k={k}: intact drive = k*a", drive(blk) == k * a)
        check(f"k={k}: zero1 drive = (k-1)*a", drive(zero_one(blk, 0)) == (k - 1) * a)
        check(f"k={k}: flip1 drive = (k-2)*a", drive(flip_one(blk, 0)) == (k - 2) * a)


def demo_flip_marker() -> None:
    header("3. Sign sensitivity: an exact marker at k = 2, noise at k >= 3")
    a = Q(1)
    thresholds = [Q(-1), Q(0), Q(1, 4), Q(1), Q(3, 2)]

    print("  k = 2: flip survival is EQUIVALENT to self-sufficiency")
    for thr in thresholds:
        flip_ok = survives(thr, flip_one(uniform(2, a), 0))
        self_sufficient = not is_dependent(thr)
        check(
            f"thr={thr}: flip survives ({flip_ok}) == self-sufficient ({self_sufficient})",
            flip_ok == self_sufficient,
        )

    print("  k = 3: a boundary-DEPENDENT gate can be entirely flip-free")
    thr = Q(1)  # dependent (thr > 0) yet thr <= a
    check("k=3, thr=1, a=1: gate is boundary-dependent", is_dependent(thr))
    check(
        "k=3, thr=1, a=1: every single flip is survived",
        all(survives(thr, flip_one(uniform(3, a), j)) for j in range(3)),
    )
    check(
        "k=2, thr=1, a=1: no flip is survived (same gate, smaller width)",
        not any(survives(thr, flip_one(uniform(2, a), j)) for j in range(2)),
    )


def demo_severity_staircase() -> None:
    header("4. The ablation battery is totally ordered in severity")
    a = Q(1)
    ok = True
    for k in (2, 3, 4):
        blk = uniform(k, a)
        for num in range(-4, 9):
            thr = Q(num, 2)
            s_none = survives(thr, zero_all(blk))
            s_flip = survives(thr, flip_one(blk, 0))
            s_zero = survives(thr, zero_one(blk, 0))
            s_ctl = survives(thr, blk)
            ok &= (not s_none or s_flip) and (not s_flip or s_zero) and (not s_zero or s_ctl)
    check("zeroN => flip1 => zero1 => control, over a grid of thresholds", ok)
    check(
        "no arm has a flip hit without a whole-block hit",
        all(
            survives(Q(n, 2), zero_all(uniform(k, a))) <= survives(Q(n, 2), flip_one(uniform(k, a), 0))
            for k in (2, 3, 4)
            for n in range(-4, 9)
        ),
    )


# --------------------------------------------------------------------------- #
# Seeds
# --------------------------------------------------------------------------- #


class Seed:
    """A learner: base drive, per-dimension gain, demand, separation requirement."""

    def __init__(self, base: Q, gain: Q, demand: Q, sep: int) -> None:
        assert gain >= 0, "gain must be non-negative"
        self.base = base
        self.gain = gain
        self.demand = demand
        self.sep = sep

    def threshold(self) -> Q:
        """Residual drive the answer path needs from the block (width-free)."""
        return self.demand - self.base

    def cures(self, k: int) -> bool:
        """Resolution AND capacity."""
        return self.sep <= k and self.demand <= self.base + k * self.gain

    def dependent(self, k: int) -> bool:
        """Boundary dependence at width k -- provably independent of k."""
        return is_dependent(self.threshold())

    def retention(self, k: int) -> Q:
        """Share of the required drive surviving whole-block ablation."""
        return self.base / (self.base + k * self.gain)

    def __repr__(self) -> str:
        return (
            f"Seed(base={self.base}, gain={self.gain}, "
            f"demand={self.demand}, sep={self.sep})"
        )


def demo_seed_laws() -> None:
    header("5. Width sets curing; the learner sets internalization")
    family = [
        Seed(Q(1), Q(1), Q(3), 1),      # dependent, capacity-limited
        Seed(Q(2), Q(1), Q(1), 2),      # self-sufficient, resolution-limited
        Seed(Q(1, 2), Q(3, 4), Q(2), 3),  # dependent, needs 3 dims to resolve
        Seed(Q(5), Q(1, 3), Q(4), 1),   # self-sufficient
        Seed(Q(3), Q(2), Q(7), 2),      # dependent
    ]
    widths = range(1, 9)

    check(
        "dependence is width-invariant for every learner",
        all(s.dependent(k) == s.dependent(1) for s in family for k in widths),
    )
    check(
        "the DEPENDENT SET is literally the same set at every width",
        len({tuple(s.dependent(k) for s in family) for k in widths}) == 1,
    )
    check(
        "curing is monotone in the width",
        all(
            not s.cures(k) or s.cures(m)
            for s in family
            for k in widths
            for m in widths
            if k <= m
        ),
    )
    print("  cure pattern by width (T = cures):")
    for k in widths:
        print(f"    k={k}: " + " ".join("T" if s.cures(k) else "." for s in family))
    print("  dependence pattern (D = boundary-dependent, S = self-sufficient):")
    for k in (1, 3, 8):
        print(f"    k={k}: " + " ".join("D" if s.dependent(k) else "S" for s in family))


def demo_retention() -> None:
    header("6. Retention: dependence deepens, but only harmonically")
    s = Seed(Q(1), Q(1, 2), Q(3), 1)
    profile = [(k, s.retention(k)) for k in range(1, 9)]
    for k, r in profile:
        print(f"    k={k}:  rho = {r} = {float(r):.4f}")
    check(
        "retention is strictly decreasing in the width",
        all(profile[i][1] > profile[i + 1][1] for i in range(len(profile) - 1)),
    )
    check("retention stays below 1", all(r < 1 for _, r in profile))
    limit = s.base / s.gain
    tail = s.retention(200000) * 200000
    check(
        f"k*rho(k) -> base/gain = {limit} (harmonic law); at k=2e5 it is {float(tail):.4f}",
        abs(float(tail) - float(limit)) < 1e-3,
    )
    partial = sum((float(s.retention(k)) for k in range(1, 200001)))
    check(
        f"the retention series diverges (partial sum to 2e5 = {partial:.2f} >> any bound)",
        partial > 20.0,
    )
    flat = Seed(Q(1), Q(0), Q(1, 2), 1)
    check(
        "a boundary-free learner (gain 0) retains 1 at every width",
        all(flat.retention(k) == 1 for k in range(1, 20)),
    )


def demo_no_k1_predictor() -> None:
    header("7. The k = 1 rung carries no information about the trait")
    catalogue: Dict[Tuple[bool, bool], Seed] = {
        (False, False): Seed(Q(2), Q(1), Q(1), 2),
        (False, True): Seed(Q(1), Q(1), Q(3), 1),
        (True, False): Seed(Q(2), Q(1), Q(1), 1),
        (True, True): Seed(Q(1), Q(1), Q(2), 1),
    }
    for (cures1, dep), s in catalogue.items():
        check(
            f"realised: cures at k=1 = {cures1}, dependent = {dep}  [{s}]",
            s.cures(1) == cures1 and s.dependent(2) == dep and s.cures(2),
        )
    s = catalogue[(False, True)]
    t = catalogue[(False, False)]
    check(
        "an indistinguishable pair: both fail at k=1, both cure at k=2, "
        "one dependent forever and one self-sufficient forever",
        (not s.cures(1))
        and (not t.cures(1))
        and s.cures(2)
        and t.cures(2)
        and all(s.dependent(k) for k in range(1, 12))
        and all(not t.dependent(k) for k in range(1, 12)),
    )


def demo_identifiability() -> None:
    header("8. Identifiability of the block and of the retention profile")
    w = [Q(3, 2), Q(-1, 3), Q(5, 6), Q(2)]
    v = [Q(1), Q(1, 6), Q(5, 6), Q(2)]  # a different block, same aggregate drive
    check("the two blocks share a control reading", drive(w) == drive(v))
    check(
        "but the zero battery separates them (control + k zeroings identify the block)",
        any(drive(zero_one(w, j)) != drive(zero_one(v, j)) for j in range(len(w))),
    )
    recovered = [drive(w) - drive(zero_one(w, j)) for j in range(len(w))]
    check("the block is reconstructed exactly from the battery", recovered == w)

    s = Seed(Q(2), Q(1), Q(5), 1)
    t = Seed(Q(4), Q(2), Q(9), 1)  # same gain/base ratio, different scale
    check("two learners agree on retention at k = 1", s.retention(1) == t.retention(1))
    check(
        "hence they agree at EVERY width (profiles never cross)",
        all(s.retention(m) == t.retention(m) for m in range(1, 40)),
    )


def demo_recorded_table() -> None:
    header("9. A recorded retention table, checked exactly")
    dep_cut = Q(95, 100)
    ret2: Dict[int, Q] = {13: Q(7544, 10000), 14: Q(9141, 10000),
                          15: Q(8037, 10000), 17: Q(9067, 10000)}
    ret3: Dict[int, Q] = {13: Q(7041, 10000), 14: Q(9014, 10000),
                          15: Q(7104, 10000), 17: Q(7437, 10000)}
    learners = list(range(8, 20))
    r2 = {i: ret2.get(i, Q(1)) for i in learners}
    r3 = {i: ret3.get(i, Q(1)) for i in learners}

    dep2 = {i for i in learners if r2[i] <= dep_cut}
    dep3 = {i for i in learners if r3[i] <= dep_cut}
    print(f"  dependent at k=2: {sorted(dep2)}")
    print(f"  dependent at k=3: {sorted(dep3)}")
    check("the dependent set is the same at k = 2 and k = 3", dep2 == dep3)
    check("and equals {13, 14, 15, 17}", dep2 == {13, 14, 15, 17})
    check(
        f"pooled internalization: {len(learners) - len(dep2)}/{len(learners)} self-sufficient",
        len(learners) - len(dep2) == 8,
    )
    check(
        "dependence deepens with the width on every dependent learner",
        all(r3[i] < r2[i] for i in sorted(dep2)),
    )
    print("  fitted gain/base ratios from the k = 3 readings (rho = 1/(1+k g/b)):")
    for i in sorted(dep2):
        ratio = (1 / r3[i] - 1) / 3
        print(f"    learner {i}: g/b = {float(ratio):.4f}  "
              f"=> predicted rho(2) = {float(1 / (1 + 2 * ratio)):.4f} "
              f"(measured {float(r2[i]):.4f})")


# --------------------------------------------------------------------------- #
# Layer 2: arithmetic capacity
# --------------------------------------------------------------------------- #


def pairwise_coprime(moduli: Sequence[int]) -> bool:
    """Exclusivity of dimensions, modelled as pairwise coprimality."""
    return all(gcd(abs(p), abs(q)) == 1 for p, q in combinations(moduli, 2))


def resolves(moduli: Sequence[int], A: int) -> bool:
    """Do residues mod the surviving moduli separate every two answers in [0, A)?"""
    seen: Dict[Tuple[int, ...], int] = {}
    for x in range(max(A, 0)):
        key = tuple(x % abs(m) for m in moduli)
        if key in seen:
            return False
        seen[key] = x
    return True


def capacity(moduli: Sequence[int]) -> int:
    """Product of the surviving moduli: the block's capacity."""
    prod = 1
    for m in moduli:
        prod *= abs(m)
    return prod


def fermat_block(k: int) -> List[int]:
    """The Fermat block 2^(2^i)+1, i < k: k pairwise coprime exclusive dimensions."""
    return [2 ** (2 ** i) + 1 for i in range(k)]


def demo_crt_layer() -> None:
    header("10. Capacity layer: the Chinese Remainder Theorem as an ablation law")
    for moduli in ([3, 5], [3, 5, 17], [2, 3, 5, 7], [4, 9, 25]):
        cap = capacity(moduli)
        check(
            f"moduli {moduli} (pairwise coprime: {pairwise_coprime(moduli)}) "
            f"resolve every range up to their capacity {cap}",
            (not pairwise_coprime(moduli)) or resolves(moduli, cap),
        )
        check(
            f"moduli {moduli} FAIL to resolve capacity+1 = {cap + 1}",
            not resolves(moduli, cap + 1),
        )
    check("the empty block resolves A = 1", resolves([], 1))
    check("the empty block FAILS to resolve A = 2 (zeroN is fatal)", not resolves([], 2))


def demo_collective_use_crt() -> None:
    header("11. Collective use at the capacity layer, and Fermat realisation")
    for k in (2, 3, 4):
        moduli = fermat_block(k)
        A = 2 ** (k - 1)
        cap = capacity(moduli)
        print(f"  k={k}: block {moduli}, capacity {cap}, answer range A={A} "
              f"(margin 2^(k-1))")
        check(f"k={k}: moduli are pairwise coprime and all >= 2",
              pairwise_coprime(moduli) and all(m >= 2 for m in moduli))
        check(f"k={k}: capacity >= 2^k", cap >= 2 ** k)
        check(f"k={k}: the intact block resolves A", resolves(moduli, A))
        check(
            f"k={k}: EVERY single-dimension ablation is a no-op",
            all(resolves([m for i, m in enumerate(moduli) if i != j], A)
                for j in range(k)),
        )
        check(f"k={k}: the whole-block ablation is fatal (A >= 2)",
              not resolves([], A))


def demo_honest_boundaries() -> None:
    header("12. Two honest boundaries of the capacity layer")
    moduli = [2, 3, 5]
    A = 30
    check("(2,3,5) resolves A = 30 exactly (A equals the capacity)", resolves(moduli, A))
    check(
        "but dropping the modulus 5 destroys resolution: 0 and 6 collide mod 2 and 3",
        not resolves([2, 3], A) and 0 % 2 == 6 % 2 and 0 % 3 == 6 % 3,
    )
    check(
        "with the margin A <= 2^(k-1) = 4 restored, every single drop is a no-op",
        all(resolves([m for m in moduli if m != j], 4) for j in moduli),
    )
    signed = [-2, 3, -5]
    check(
        "sign flips are ALWAYS free at the capacity layer (divisibility is sign-blind)",
        all(resolves(signed, a) == resolves(moduli, a) for a in range(1, 40)),
    )
    print("  => the k = 2 sign sensitivity cannot be a capacity effect;")
    print("     it lives in the additive gate, where flipping costs 2*w_j.")


# --------------------------------------------------------------------------- #

def main() -> int:
    print("Gated readouts and coprime boundary blocks -- numerical demonstrations")
    demo_intervention_arithmetic()
    demo_uniform_laws()
    demo_flip_marker()
    demo_severity_staircase()
    demo_seed_laws()
    demo_retention()
    demo_no_k1_predictor()
    demo_identifiability()
    demo_recorded_table()
    demo_crt_layer()
    demo_collective_use_crt()
    demo_honest_boundaries()

    header("SUMMARY")
    if FAILURES:
        print(f"  {len(FAILURES)} check(s) FAILED:")
        for f in FAILURES:
            print(f"    - {f}")
        return 1
    print("  All checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
