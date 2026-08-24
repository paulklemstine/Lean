"""Algorithm A -- Anchored Fermat Ascent with Square-Hit Detection.

Scans a_j = floor(sqrt(N)) + j upward and returns the factorization at the first
index whose energy E(a_j) = a_j^2 - N is a perfect square.  Correctness: a hit
E(a) = b^2 with b <= a is equivalent to N = (a-b)(a+b).  Cost: for a modulus with
factorization N = u(u+2k) the hit is reached after j = Theta(k^2/sqrt(N)) steps,
with the explicit envelope k^2/(2(u+k)) <= j <= k^2/(2 floor(sqrt N)) + 1.
"""

from __future__ import annotations

import math
from typing import NamedTuple, Optional


class AscentResult(NamedTuple):
    offset: int          # frontier offset j of the hit from the anchor
    smaller: int         # factor a - b
    larger: int          # factor a + b
    energy: int          # the perfect-square energy at the hit
    root: int            # b, the square root of that energy


def anchored_fermat_ascent(modulus: int, budget: int = 10 ** 7) -> Optional[AscentResult]:
    """Return the factorization found by the anchored ascent, or None within budget."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    m: int = math.isqrt(modulus)
    for j in range(budget):
        a: int = m + j
        e: int = a * a - modulus
        if e < 0:
            continue                      # only possible at j = 0
        b: int = math.isqrt(e)
        if b * b == e:
            return AscentResult(offset=j, smaller=a - b, larger=a + b, energy=e, root=b)
    return None


def frontier_envelope(u: int, k: int) -> tuple[float, int, float]:
    """Return (lower bound, measured offset, upper bound) for N = u(u+2k)."""
    modulus: int = u * (u + 2 * k)
    m: int = math.isqrt(modulus)
    j: int = (u + k) - m
    lower: float = k * k / (2 * (u + k))
    upper: float = k * k / (2 * m) + 1 if m > 0 else float("inf")
    return lower, j, upper


if __name__ == "__main__":
    for u, k in [(59, 21), (997, 6), (10007, 1500), (1000003, 500)]:
        n = u * (u + 2 * k)
        result = anchored_fermat_ascent(n)
        lo, j, hi = frontier_envelope(u, k)
        print(f"N = {n:>16}  hit {result}   envelope {lo:.3f} <= {j} <= {hi:.3f}")


"""Algorithm B -- Exact Empirical Independence Test (counting mutual information).

Two aligned columns T (feature) and S (secret) on a finite instance set Omega are
"exactly independent" when every joint fibre has exactly the product cardinality:

    |{T = t and S = s}| * |Omega| == |{T = t}| * |{S = s}|   for all t, s.

This identity is equivalent to the empirical mutual information being exactly 0,
and unlike a p-value it is a statement about the data, not about a null model.
Cost: O(|Omega|) to tabulate plus O(|T-values| * |S-values|) to check.
"""

from __future__ import annotations

import math
from collections import Counter
from typing import Hashable, List, Sequence, Tuple


def contingency(
    feature: Sequence[Hashable], secret: Sequence[Hashable]
) -> Tuple[Counter, Counter, Counter]:
    """Return (joint counts, feature marginal, secret marginal)."""
    if len(feature) != len(secret):
        raise ValueError("columns must be aligned")
    return Counter(zip(feature, secret)), Counter(feature), Counter(secret)


def exactly_independent(
    feature: Sequence[Hashable], secret: Sequence[Hashable]
) -> bool:
    """Check the counting identity in every cell of the contingency table."""
    n: int = len(feature)
    joint, pf, ps = contingency(feature, secret)
    for t, ct in pf.items():
        for s, cs in ps.items():
            if joint[(t, s)] * n != ct * cs:
                return False
    return True


def mutual_information_bits(
    feature: Sequence[Hashable], secret: Sequence[Hashable]
) -> float:
    """Empirical mutual information in bits (exactly 0 iff exactly independent)."""
    n: int = len(feature)
    if n == 0:
        return 0.0
    joint, pf, ps = contingency(feature, secret)
    total: float = 0.0
    for (t, s), c in joint.items():
        pj = c / n
        total += pj * math.log2(pj / ((pf[t] / n) * (ps[s] / n)))
    return max(total, 0.0)


def violating_cells(
    feature: Sequence[Hashable], secret: Sequence[Hashable]
) -> List[Tuple[Hashable, Hashable, int, int]]:
    """List the cells (t, s, observed*|Omega|, expected) where independence fails."""
    n: int = len(feature)
    joint, pf, ps = contingency(feature, secret)
    out: List[Tuple[Hashable, Hashable, int, int]] = []
    for t, ct in pf.items():
        for s, cs in ps.items():
            lhs, rhs = joint[(t, s)] * n, ct * cs
            if lhs != rhs:
                out.append((t, s, lhs, rhs))
    return out


if __name__ == "__main__":
    constant = ["(-1,+1,+1,...)"] * 8
    secret = [0, 1, 0, 1, 1, 0, 1, 0]
    print("constant sensor : exact =", exactly_independent(constant, secret),
          " MI =", mutual_information_bits(constant, secret))
    coupled = [0, 1, 0, 1, 1, 0, 1, 0]
    print("coupled feature : exact =", exactly_independent(coupled, secret),
          " MI =", mutual_information_bits(coupled, secret))
    print("violations      :", violating_cells(coupled, secret))


"""Algorithm C -- Magnitude-Conditioned Null (the correct control).

A row-shuffle permutation null breaks the pairing between feature and secret while
preserving both marginals, so it tests association.  A deterministic function of the
modulus inherits the drift of the secret's marginal across scales and is flagged as
significant even though it transfers nothing beyond knowing the modulus.

The correct control conditions on magnitude cells.  Its verdict is exact: a feature
has zero information about every secret inside every magnitude cell if and only if
it is a deterministic function of the magnitude.  This routine reports both nulls
side by side, so the discrepancy between them is itself the diagnosis.

Cost: O(R * |Omega|) for R shuffle replicates, O(|Omega|) for the conditional null.
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Dict, Hashable, List, NamedTuple, Sequence


def mutual_information_bits(
    feature: Sequence[Hashable], secret: Sequence[Hashable]
) -> float:
    n = len(feature)
    if n == 0:
        return 0.0
    joint, pf, ps = Counter(zip(feature, secret)), Counter(feature), Counter(secret)
    return max(
        sum((c / n) * math.log2((c / n) / ((pf[t] / n) * (ps[s] / n)))
            for (t, s), c in joint.items()),
        0.0,
    )


def conditional_mutual_information_bits(
    feature: Sequence[Hashable],
    secret: Sequence[Hashable],
    magnitude: Sequence[Hashable],
) -> float:
    n = len(feature)
    cells: Dict[Hashable, List[int]] = {}
    for i, c in enumerate(magnitude):
        cells.setdefault(c, []).append(i)
    return sum(
        (len(idx) / n)
        * mutual_information_bits([feature[i] for i in idx], [secret[i] for i in idx])
        for idx in cells.values()
    )


def is_magnitude_mirror(
    feature: Sequence[Hashable], magnitude: Sequence[Hashable]
) -> bool:
    """True iff the feature is a deterministic function of the magnitude."""
    seen: Dict[Hashable, Hashable] = {}
    for f, m in zip(feature, magnitude):
        if m in seen and seen[m] != f:
            return False
        seen[m] = f
    return True


class NullReport(NamedTuple):
    observed_bits: float
    shuffle_mean_bits: float
    shuffle_z: float
    conditional_bits: float
    is_mirror: bool
    verdict: str


def audit_feature(
    feature: Sequence[Hashable],
    secret: Sequence[Hashable],
    magnitude: Sequence[Hashable],
    replicates: int = 300,
    seed: int = 20260824,
) -> NullReport:
    """Run both nulls and return the diagnosis."""
    rng = random.Random(seed)
    observed = mutual_information_bits(feature, secret)
    pool = list(secret)
    draws: List[float] = []
    for _ in range(replicates):
        rng.shuffle(pool)
        draws.append(mutual_information_bits(feature, pool))
    mu = sum(draws) / len(draws)
    sd = math.sqrt(sum((d - mu) ** 2 for d in draws) / len(draws))
    z = (observed - mu) / sd if sd > 0 else float("inf")
    cond = conditional_mutual_information_bits(feature, secret, magnitude)
    mirror = is_magnitude_mirror(feature, magnitude)

    if mirror and cond == 0.0 and z > 3.0:
        verdict = ("MIRROR: unconditional signal is scale stratification; the feature is "
                   "a deterministic function of the magnitude and transfers nothing.")
    elif mirror:
        verdict = "MIRROR: deterministic function of the magnitude; no transfer possible."
    elif cond > 0.0:
        verdict = ("SURVIVES: information persists inside magnitude cells, so the feature "
                   "is provably not a function of the magnitude.")
    else:
        verdict = "NO SIGNAL: nothing detected either unconditionally or within cells."
    return NullReport(observed, mu, z, cond, mirror, verdict)


if __name__ == "__main__":
    rng = random.Random(7)
    scale = [rng.uniform(7, 21) for _ in range(2000)]
    secret = [1 if rng.random() < 0.5 + 0.7 * ((s - 14) / 14) else 0 for s in scale]

    def quantize(values: Sequence[float], bins: int) -> List[int]:
        order = sorted(range(len(values)), key=lambda i: values[i])
        out = [0] * len(values)
        for rank, i in enumerate(order):
            out[i] = rank * bins // len(values)
        return out

    magnitude = quantize(scale, 32)
    mirror_feature = quantize([3 * math.atan(s / 8) + 0.01 * s for s in scale], 32)
    oracle_bit = [1 if rng.random() < 0.5 else 0 for _ in scale]

    print("mirror feature :", audit_feature(mirror_feature, secret, magnitude).verdict)
    print("random bit     :", audit_feature(oracle_bit, secret, magnitude).verdict)


"""Algorithm D -- Positional Oracle Capacity Profile.

For a factor-derived column d (canonically the smallest nontrivial factor of each
instance) the positional oracle is the bit 1{d <= B}.  Its below-threshold fraction
p(B) is monotone in B, and its capacity is the binary entropy H(p(B)), which is
capped at one bit, increases while p(B) <= 1/2, decreases once p(B) >= 1/2, attains
its maximum exactly when the threshold halves the instance set, and has interval
superlevel sets.  The last property is what makes "the smallest B reaching a given
fraction of the peak" a well-defined number rather than a grid artifact.

Cost: O(|Omega| log |Omega|) to sort the column, then O(log |Omega|) per threshold.
"""

from __future__ import annotations

import bisect
import math
from typing import List, NamedTuple, Sequence, Tuple


def binary_entropy_bits(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


class OracleProfile(NamedTuple):
    thresholds: List[int]
    fractions: List[float]
    capacities: List[float]
    peak_threshold: int
    peak_capacity: float
    peak_fraction: float
    interval_lo: int
    interval_hi: int
    median: int


def oracle_capacity_profile(
    factors: Sequence[int], grid: Sequence[int], peak_fraction: float = 0.90
) -> OracleProfile:
    """Compute the full capacity profile and the target-fraction interval."""
    if not factors:
        raise ValueError("empty instance set")
    ordered: List[int] = sorted(factors)
    n: int = len(ordered)

    fractions: List[float] = []
    capacities: List[float] = []
    for b in grid:
        count = bisect.bisect_right(ordered, b)
        p = count / n
        fractions.append(p)
        capacities.append(binary_entropy_bits(p))

    peak_i: int = max(range(len(grid)), key=lambda i: capacities[i])
    target: float = peak_fraction * capacities[peak_i]
    reaching: List[int] = [grid[i] for i in range(len(grid)) if capacities[i] >= target]

    return OracleProfile(
        thresholds=list(grid),
        fractions=fractions,
        capacities=capacities,
        peak_threshold=grid[peak_i],
        peak_capacity=capacities[peak_i],
        peak_fraction=fractions[peak_i],
        interval_lo=min(reaching),
        interval_hi=max(reaching),
        median=ordered[n // 2],
    )


def balanced_threshold(factors: Sequence[int]) -> Tuple[int, float]:
    """The threshold that halves the instance set, where the capacity peaks."""
    ordered = sorted(factors)
    b = ordered[(len(ordered) - 1) // 2]
    p = bisect.bisect_right(ordered, b) / len(ordered)
    return b, binary_entropy_bits(p)


def multi_read_pigeonhole_bound(instances: int, reads: int) -> float:
    """Lower bound |Omega| / 2^L on the largest indistinguishable class."""
    return instances / (2 ** reads)


if __name__ == "__main__":
    import random

    rng = random.Random(11)
    factors = [int(math.exp(rng.gauss(12.3, 2.2))) + 2 for _ in range(6000)]
    grid = sorted({int(math.exp(x / 10.0)) + 2 for x in range(10, 260)})
    prof = oracle_capacity_profile(factors, grid)
    print(f"median d              : {prof.median}")
    print(f"peak capacity         : {prof.peak_capacity:.4f} bits at B = {prof.peak_threshold}")
    print(f"fraction at the peak  : {prof.peak_fraction:.4f}")
    print(f">=90% of peak on      : [{prof.interval_lo}, {prof.interval_hi}]")
    print(f"balanced threshold    : {balanced_threshold(factors)}")
    print(f"after 4 reads at least: {multi_read_pigeonhole_bound(len(factors), 4):.1f} "
          f"instances remain indistinguishable")


"""Focused demonstration: auditing four candidate side channels the right way.

Four features are put through the same audit on one synthetic instance family whose
secret bit is scale-stratified (its marginal drifts with the size of the modulus):

    1.  the window sign vector      -- a structural constant;
    2.  plain log of the modulus    -- the magnitude itself;
    3.  a smooth "spectral summary"  -- a strictly increasing recoding of the magnitude;
    4.  the positional oracle bit 1{d <= B} -- factor-derived.

For each we report the raw mutual information with the secret, the verdict of a
row-shuffle permutation null, the information remaining inside magnitude cells, and
whether the feature is a deterministic function of the magnitude.  Features 1-3 are
exactly null once magnitude is held fixed; only feature 4 survives.

Run:  python3 demo_mirror_audit.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Dict, Hashable, List, Sequence, Tuple


def mutual_information_bits(feature: Sequence[Hashable], secret: Sequence[Hashable]) -> float:
    n = len(feature)
    if n == 0:
        return 0.0
    joint, pf, ps = Counter(zip(feature, secret)), Counter(feature), Counter(secret)
    return max(
        sum((c / n) * math.log2((c / n) / ((pf[t] / n) * (ps[s] / n)))
            for (t, s), c in joint.items()),
        0.0,
    )


def conditional_mi_bits(
    feature: Sequence[Hashable], secret: Sequence[Hashable], cell: Sequence[Hashable]
) -> float:
    n = len(feature)
    groups: Dict[Hashable, List[int]] = {}
    for i, c in enumerate(cell):
        groups.setdefault(c, []).append(i)
    return sum(
        (len(idx) / n)
        * mutual_information_bits([feature[i] for i in idx], [secret[i] for i in idx])
        for idx in groups.values()
    )


def shuffle_z(
    feature: Sequence[Hashable], secret: Sequence[Hashable], reps: int = 200, seed: int = 5
) -> Tuple[float, float]:
    rng = random.Random(seed)
    obs = mutual_information_bits(feature, secret)
    pool = list(secret)
    draws: List[float] = []
    for _ in range(reps):
        rng.shuffle(pool)
        draws.append(mutual_information_bits(feature, pool))
    mu = sum(draws) / len(draws)
    sd = math.sqrt(sum((d - mu) ** 2 for d in draws) / len(draws))
    return obs, ((obs - mu) / sd if sd > 0 else float("inf"))


def is_mirror(feature: Sequence[Hashable], magnitude: Sequence[Hashable]) -> bool:
    seen: Dict[Hashable, Hashable] = {}
    for f, m in zip(feature, magnitude):
        if m in seen and seen[m] != f:
            return False
        seen[m] = f
    return True


def quantize(values: Sequence[float], bins: int) -> List[int]:
    order = sorted(range(len(values)), key=lambda i: values[i])
    out = [0] * len(values)
    for rank, i in enumerate(order):
        out[i] = rank * bins // len(values)
    return out


def main() -> None:
    rng = random.Random(31337)
    count = 4000
    scale: List[float] = []
    secret: List[int] = []
    factor: List[float] = []
    for _ in range(count):
        s = rng.uniform(7.0, 21.0)
        scale.append(s)
        secret.append(1 if rng.random() < min(max(0.5 + 0.7 * ((s - 14) / 14), 0.02), 0.98) else 0)
        factor.append(math.exp(4 + 0.30 * s + 1.6 * rng.gauss(0.0, 1.0)))

    magnitude = quantize(scale, 32)
    median_factor = sorted(factor)[count // 2]

    features: List[Tuple[str, List[Hashable]]] = [
        ("window sign vector", ["(-1,+1,+1,...)"] * count),
        ("plain log N", quantize(scale, 32)),
        ("spectral summary", quantize([3 * math.atan(s / 8) + 0.01 * s for s in scale], 32)),
        ("oracle bit 1{d <= median}", [1 if f <= median_factor else 0 for f in factor]),
    ]

    header = f"{'feature':<26}{'MI':>10}{'shuffle z':>12}{'MI | magnitude':>16}{'mirror':>9}"
    print(header)
    print("-" * len(header))
    for name, feat in features:
        mi, z = shuffle_z(feat, secret)
        cond = conditional_mi_bits(feat, secret, magnitude)
        print(f"{name:<26}{mi:>10.6f}{(z if math.isfinite(z) else 0.0):>12.1f}"
              f"{cond:>16.6f}{str(is_mirror(feat, magnitude)):>9}")

    print()
    print("Reading the table:")
    print(" * 'plain log N' and 'spectral summary' report the SAME mutual information -")
    print("   an injective recoding cannot change a single fibre count.")
    print(" * both are flagged by the shuffle null (z well past 3) yet vanish exactly")
    print("   once magnitude is held fixed: that is stratification, not transfer.")
    print(" * the sign vector is a constant, so it is null before any statistics.")
    print(" * only the factor-derived oracle bit keeps information inside magnitude")
    print("   cells - and even that is capped at one bit per read.")


if __name__ == "__main__":
    main()


"""Visualization: the magnitude mirror collapse versus the surviving oracle.

Left panel  -- mutual information of a "spectral" feature with a secret bit, as the
               analysis is refined: raw (row-shuffle null rejected), conditioned on
               coarse magnitude deciles (shrinking), conditioned on magnitude cells
               that resolve the feature (exactly zero).  The identical bar for plain
               log N shows that the sophisticated feature IS the magnitude channel.
Right panel -- the capacity profile of the positional oracle bit 1{d <= B}: the
               below-threshold fraction p(B) is monotone, the binary entropy H(p(B))
               is unimodal, capped at one bit, maximal exactly at balance p = 1/2,
               and the >= 90%-of-peak thresholds form an interval.

Run:  python3 viz_mirror_and_oracle.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Dict, List, Sequence

import matplotlib.pyplot as plt


def mutual_information_bits(feature: Sequence[object], secret: Sequence[object]) -> float:
    n = len(feature)
    if n == 0:
        return 0.0
    joint, pf, ps = Counter(zip(feature, secret)), Counter(feature), Counter(secret)
    return max(
        sum(
            (c / n) * math.log2((c / n) / ((pf[t] / n) * (ps[s] / n)))
            for (t, s), c in joint.items()
        ),
        0.0,
    )


def conditional_mi_bits(
    feature: Sequence[object], secret: Sequence[object], cell: Sequence[object]
) -> float:
    n = len(feature)
    groups: Dict[object, List[int]] = {}
    for i, c in enumerate(cell):
        groups.setdefault(c, []).append(i)
    return sum(
        (len(idx) / n)
        * mutual_information_bits([feature[i] for i in idx], [secret[i] for i in idx])
        for idx in groups.values()
    )


def quantize(values: Sequence[float], bins: int) -> List[int]:
    order = sorted(range(len(values)), key=lambda i: values[i])
    out = [0] * len(values)
    for rank, i in enumerate(order):
        out[i] = rank * bins // len(values)
    return out


def binary_entropy_bits(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def main() -> None:
    rng = random.Random(4242)
    count = 5000
    log_n: List[float] = []
    secret: List[int] = []
    factors: List[float] = []
    for _ in range(count):
        scale = rng.uniform(7.0, 21.0)
        bias = 0.5 + 0.7 * ((scale - 14.0) / 14.0)
        secret.append(1 if rng.random() < min(max(bias, 0.02), 0.98) else 0)
        log_n.append(scale)
        factors.append(math.exp(4 + 0.30 * scale + 1.6 * rng.gauss(0.0, 1.0)))

    spectral = quantize([3 * math.atan(x / 8) + 0.01 * x for x in log_n], 32)
    plain = quantize(log_n, 32)
    deciles = quantize(log_n, 10)
    cells = quantize(log_n, 32)

    bars = [
        ("spectral\n(raw)", mutual_information_bits(spectral, secret)),
        ("plain $\\log N$\n(raw)", mutual_information_bits(plain, secret)),
        ("spectral\n| deciles", conditional_mi_bits(spectral, secret, deciles)),
        ("spectral\n| magnitude", conditional_mi_bits(spectral, secret, cells)),
    ]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    colors = ["#60a5fa", "#94a3b8", "#fbbf24", "#f87171"]
    ax1.bar([b[0] for b in bars], [b[1] for b in bars], color=colors)
    for i, (_, v) in enumerate(bars):
        ax1.text(i, v + 0.003, f"{v:.4f}", ha="center", fontsize=9)
    ax1.set_ylabel("mutual information with the secret (bits)")
    ax1.set_title("The mirror collapse: identical to $\\log N$, exactly null given magnitude")
    ax1.grid(alpha=0.25, axis="y")

    factors.sort()
    grid = [math.exp(x / 8.0) for x in range(40, 260)]
    ps = [sum(1 for d in factors if d <= b) / len(factors) for b in grid]
    hs = [binary_entropy_bits(p) for p in ps]
    peak_i = max(range(len(hs)), key=lambda i: hs[i])
    target = 0.9 * hs[peak_i]
    band = [grid[i] for i in range(len(hs)) if hs[i] >= target]

    ax2.plot(grid, hs, color="#2563eb", lw=2.2, label="capacity $H(p(B))$")
    ax2.plot(grid, ps, color="#94a3b8", lw=1.5, label="below-threshold fraction $p(B)$")
    ax2.axhline(1.0, color="black", lw=0.8, ls=":")
    if band:
        ax2.axvspan(min(band), max(band), color="#60a5fa", alpha=0.12,
                    label="$\\ge 90\\%$ of peak (an interval)")
    ax2.scatter([grid[peak_i]], [hs[peak_i]], color="#f59e0b", zorder=5,
                label=f"peak {hs[peak_i]:.4f} bits at $p={ps[peak_i]:.3f}$")
    ax2.set_xscale("log")
    ax2.set_xlabel("threshold $B$")
    ax2.set_ylabel("bits / fraction")
    ax2.set_title("Positional oracle $\\mathbf{1}\\{d\\le B\\}$: unimodal, peak at balance")
    ax2.legend(fontsize=8, loc="upper left")
    ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("mirror_and_oracle.png", dpi=160)
    print("wrote mirror_and_oracle.png")


if __name__ == "__main__":
    main()


"""Visualization: the anchored energy window and the two-sided frontier cost law.

Left panel  -- the Fermat energy E(a) = a^2 - N on the anchored window for several
               moduli of very different sizes, rescaled by 2*floor(sqrt(N)).  Every
               curve is negative exactly at j = 0 and positive from j = 1 onward:
               the unique zero crossing sits at sqrt(N) for every modulus, so the
               sign pattern of the window is the same constant vector everywhere.
Right panel -- the frontier offset j = (u+k) - floor(sqrt(u(u+2k))) measured against
               its proven envelope  k^2/(2(u+k))  <=  j  <=  k^2/(2 floor(sqrt N)) + 1.

Run:  python3 viz_window_and_frontier.py
"""

from __future__ import annotations

import math
import random
from typing import List, Tuple

import matplotlib.pyplot as plt


def frontier_offset(u: int, k: int) -> int:
    n = u * (u + 2 * k)
    return (u + k) - math.isqrt(n)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Left: the energy on the anchored window ---------------------------- #
    moduli: List[int] = [5959, 1_005_973, 130_161_049, 999_999_999_989]
    js = list(range(0, 9))
    for n in moduli:
        m = math.isqrt(n)
        vals = [(m + j) ** 2 - n for j in js]
        scaled = [v / (2 * m) for v in vals]
        ax1.plot(js, scaled, marker="o", label=f"N = {n:,}")
    ax1.axhline(0.0, color="black", lw=1)
    ax1.axvspan(-0.25, 0.25, color="crimson", alpha=0.10)
    ax1.text(0.05, ax1.get_ylim()[1] * 0.55, "the only sign change\nlives here, at $\\sqrt{N}$",
             color="crimson", fontsize=9)
    ax1.set_xlabel("window offset $j$   (position $a_j=\\lfloor\\sqrt N\\rfloor+j$)")
    ax1.set_ylabel("$E(a_j)\\,/\\,2\\lfloor\\sqrt N\\rfloor$")
    ax1.set_title("Anchored energy: negative at $j=0$, positive for all $j\\ge 1$")
    ax1.legend(fontsize=8)
    ax1.grid(alpha=0.25)

    # ---- Right: the frontier cost law -------------------------------------- #
    rng = random.Random(20260824)
    xs: List[float] = []
    ys: List[float] = []
    los: List[float] = []
    his: List[float] = []
    for _ in range(600):
        u = rng.randrange(10 ** 5, 10 ** 8)
        k = rng.randrange(1, int(u ** 0.75))
        n = u * (u + 2 * k)
        j = frontier_offset(u, k)
        xs.append(k * k / math.isqrt(n))
        ys.append(max(j, 1))
        los.append(max(k * k / (2 * (u + k)), 1e-3))
        his.append(k * k / (2 * math.isqrt(n)) + 1)

    ax2.scatter(xs, ys, s=8, alpha=0.5, label="measured offset $j$")
    order = sorted(range(len(xs)), key=lambda i: xs[i])
    ax2.plot([xs[i] for i in order], [los[i] for i in order], color="crimson", lw=1.5,
             label="lower bound $k^2/(2(u+k))$")
    ax2.plot([xs[i] for i in order], [his[i] for i in order], color="seagreen", lw=1.5,
             label="upper bound $k^2/(2\\lfloor\\sqrt N\\rfloor)+1$")
    ax2.set_xscale("log")
    ax2.set_yscale("log")
    ax2.set_xlabel("$k^2/\\lfloor\\sqrt N\\rfloor$   (imbalance, rescaled)")
    ax2.set_ylabel("frontier offset $j$")
    ax2.set_title("Frontier cost law: $j=\\Theta(k^2/\\sqrt N)$")
    ax2.legend(fontsize=8)
    ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("window_and_frontier.png", dpi=160)
    print("wrote window_and_frontier.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the individual deliverables in this repository."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"

LEAN_FILES = [
    "Catalog/Combinatorics/MagnitudeMirrorSeal.lean",
    "Catalog/Combinatorics/MagnitudeMirrorTransfer.lean",
    "Catalog/Combinatorics/MagnitudeMirrorTreeBridge.lean",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


INTERACTIVE_LAYOUT = r"""
# The Mirror and the Oracle
### A guided tour of what the Fermat ascent window does — and does not — reveal

Take a large integer $N$ that you would like to factor. Fermat's idea is to look for a
representation $N = a^2 - b^2$, because that is the same thing as $N = (a-b)(a+b)$. So define
the **energy**

$$E(a) \;=\; a^2 - N,$$

start at the **anchor** $m = \lfloor\sqrt N\rfloor$, and walk upward through
$a_j = m + j$, asking at each step whether $E(a_j)$ is a perfect square. When it is — a **hit** —
you have factored $N$.

Around this simple walk a research programme grew up, proposing that the *shape* of the energy
along the window leaks information about where the factors are. This page is the story of testing
that proposal honestly: two of the proposed channels turn out to be illusions of two very
different kinds, and exactly one channel survives. By the end you will be able to say precisely
why.

---

## 1. Meet the window

Start by playing. Choose a factorization $N = u\,(u+2k)$ — $u$ is the smaller factor and $k$ is
the *imbalance*, half the gap between the two factors — and scan the anchored window.

{{interactive_demo:0}}

Two things to notice, and they pull in opposite directions.

**The sign column never changes.** Whatever you type, the signs read $(-1, +1, +1, +1, \dots)$.
That is not luck. By the definition of the integer square root, $m^2 \le N < (m+1)^2$, so
$E(m) \le 0$ while $E(m+j) > 0$ for every $j \ge 1$. The energy is strictly increasing, so it has
exactly one zero crossing and it sits between $j = 0$ and $j = 1$ — at $\sqrt N$, where it must be.

**The hit moves around a lot.** For a balanced factorization ($k$ small) the hit is a step or two
from the anchor; for an unbalanced one it is far away. That is the real geometry.

<details>
<summary><strong>Click to reveal: why there is no event at a divisor offset</strong></summary>

The refuted mechanism claimed a sign change at $j = d$ for a nontrivial divisor $d$ of $N$. But
for every $d \ge 1$ we have shown $E(m+d) > 0$ and $E(m+d+1) > 0$ — both sides of the alleged
event are strictly positive. The energy has one crossing, at the anchor, for every modulus. The
event does not exist.

The *hit*, by contrast, is genuinely arithmetic:

> **Theorem (hits are factorizations).** If $b \le a$ and $E(a) = b^2$ then $(a-b)(a+b) = N$.
> Conversely, for any $u, k$, the modulus $N = u(u+2k)$ has $E(u+k) = k^2$.

And the anchor itself is a hit precisely when $N$ is a perfect square, since $E(m) = 0$ iff
$m^2 = N$.
</details>

---

## 2. A statistic that never varies

If a feature takes the *same value* on every instance of your data set, it cannot distinguish
instances, so its mutual information with anything at all is exactly zero. Not "small". Not
"insignificant". Zero, as an identity between counts.

Here is the notion of independence used throughout, deliberately stated by counting rather than
by probability:

> **Definition.** Statistics $T$ and $S$ are *exactly independent* on a finite instance set
> $\Omega$ when, for every pair of values $(t, s)$,
> $$|\{T = t \text{ and } S = s\}| \cdot |\Omega| \;=\; |\{T = t\}| \cdot |\{S = s\}| .$$

Dividing by $|\Omega|^2$ this says the empirical joint distribution factorizes, i.e. the empirical
mutual information is exactly $0$.

{{algorithm:1}}

Applied to the window sign vector, and to *any* post-processing of it — a hit count, a bracket
flag, a hash, a learned score — the verdict is immediate and exact: zero bits. A reported
measurement of $0.000000$ bits from such a sensor is an identity being echoed back, not a
negative experimental finding.

---

## 3. The subtler illusion: a mirror of the size of $N$

The second proposed channel was not constant. It was a smooth, sophisticated-looking "spectral
summary" of the energy profile, and it *did* show a signal: $0.1836$ bits of mutual information
against a secret bit of a factor, with a row-shuffle permutation null rejected at $z \gg 3$.

Then someone computed the mutual information of the cheapest imaginable feature, $\log N$. It came
back $0.1836$ bits. Identically.

<details>
<summary><strong>Click to reveal: why an exact coincidence is not a coincidence</strong></summary>

> **Theorem (injective recoding preserves information exactly).** If $g$ is injective — in
> particular, if $g$ is strictly monotone — then $g \circ F$ and $F$ have exactly the same fibre
> counts, hence exactly the same mutual information with every secret.

The proof is one line: for $d = g(t)$, the fibre $\{g\circ F = d\}$ *equals* the fibre
$\{F = t\}$, and likewise for joint fibres, so the two defining identities are literally the same
equation. Values outside the image of $g$ contribute $0 = 0$.

So if the spectral summary is a strictly increasing function of $\log N$ on your data — and it
was — then it *had to* report the same number to every decimal place. There was never a second
channel to find.
</details>

Call a feature a **magnitude mirror** when it is a deterministic function of the magnitude:
$\Phi(w) = g(M(w))$ for all instances $w$, where $M$ buckets the size of $N$. Now run the audit
yourself. Choose a feature, choose how finely to bucket the magnitude, and compare the two nulls.

{{interactive_demo:1}}

Watch the pattern: the shuffle null keeps rejecting, and the conditional information keeps
collapsing to *exactly* zero. Inside a magnitude cell a mirror is a constant, and a constant is
uninformative — end of story.

> **Theorem (the collapse is a characterization).** A feature has exactly zero information about
> *every* secret inside *every* magnitude cell **if and only if** it is a deterministic function
> of the magnitude.

That "if and only if" is the difference between weak evidence and proof. A measured exact
conditional null does not fail to reject a hypothesis; it *establishes* determinism.

<details>
<summary><strong>Click to reveal: the proof of the characterization</strong></summary>

One direction is the constancy argument above. For the converse, take the secret to be the feature
itself. A statistic that is exactly independent of *itself* on a nonempty set must be constant:
with $n_0 = |\{T = T(w_0)\}| \ge 1$, the defining identity at $(T(w_0), T(w_0))$ reads
$n_0 |\Omega| = n_0^2$, so $n_0 = |\Omega|$. Applying this inside each magnitude cell makes the
feature constant per cell, and reading off those values defines the function $g$ with
$\Phi = g \circ M$.
</details>

---

## 4. Why the standard null model lied

A row shuffle destroys the pairing between feature and secret while preserving both marginals. It
tests *association*. But a mirror can be associated with a secret for a completely uninteresting
reason: the secret's own distribution drifts with the size of $N$.

> **Diagnosis theorem.** If a magnitude mirror shows *any* unconditional dependence on a secret,
> then the secret's marginal provably differs between magnitude cells. Conversely, if the secret's
> marginal is homogeneous across cells, a mirror is unconditionally uninformative too.

Rejecting a shuffle null therefore *certifies scale stratification*. It can never certify transfer.

<details>
<summary><strong>Click to reveal: the smallest possible counterexample</strong></summary>

Take $\Omega = \{2, 3\}$, magnitude $M(N) = N$, feature $\Phi(N) = 2N$ (a strictly monotone
recoding of $M$), and secret $S(N) = N \bmod 2$. The feature separates the two instances and so
does the secret, so the joint identity fails: the feature has a full bit of unconditional
information. Yet every magnitude cell contains a single instance, and on a one-point set every
statistic is exactly independent of every other — exactly zero conditional information.

One bit of "signal", zero bits of transfer. That is the whole pathology, in two data points.
</details>

Here is the correct control, implemented:

{{algorithm:2}}

And here is the full audit of four competing features on one stratified instance family — three
mirrors and one genuine channel:

{{demo:1}}

<details>
<summary><strong>Click to reveal: why combining probes cannot rescue them</strong></summary>

Magnitude mirrors form a closed class. Constants are mirrors; a post-processing of a mirror is a
mirror; a pair of mirrors is a mirror; any finite tuple of mirrors is a mirror; and a mirror of a
coarse magnitude is a mirror of any finer one. Consequently an entire battery of mirrors, read
jointly and fed through an arbitrary function — a hash, a score, a trained model — is a *single*
mirror, and inside every magnitude cell it is exactly uninformative about every secret. There is
no rescue by combination.
</details>

---

## 5. What survives: the positional oracle

One channel is genuinely different. Let $d$ be the smallest nontrivial factor of the instance and
consider the single bit $\mathbb 1\{d \le B\}$.

It is **not** a magnitude mirror: two instances of the same size can have wildly different
smallest factors — $14 = 2\cdot 7$ and $15 = 3\cdot 5$ live in the same coarse magnitude cell but
give different oracle bits — and one can exhibit a magnitude cell on which the bit is genuinely
informative. The collapse argument of §3 simply does not reach it.

Its behaviour is completely determined by one function: the below-threshold fraction
$p(B) = |\{d \le B\}| / |\Omega|$, which is monotone in $B$. The capacity of the bit is the binary
entropy $H(p(B))$, and therefore

* it never exceeds one bit;
* it increases while $p(B) \le 1/2$ and decreases once $p(B) \ge 1/2$;
* it is maximal **exactly** when $B$ splits the instance set into two equal halves;
* its superlevel sets are intervals — so "the smallest $B$ reaching $90\%$ of the peak" is a real
  endpoint, not a grid artifact.

{{visualization:1}}

{{algorithm:3}}

On the tested family the measured profile peaks at $0.4798$ bits near $B \approx 22758$, with the
$90\%$-of-peak threshold at $B^\ast = 10420$ and a median smallest factor of $215782$: exactly the
shape the theory forces.

<details>
<summary><strong>Click to reveal: the price of the surviving channel</strong></summary>

> **Pigeonhole.** For any $L$ Boolean statistics there is a sign pattern whose fibre contains at
> least $|\Omega| / 2^L$ instances.

So reading $L$ oracle bits still leaves that many mutually indistinguishable instances: the
channel is real, but rationed at one bit per read. A single read can at best halve your candidate
set.
</details>

---

## 6. The cost of the only real channel

The retracted mechanism was, in effect, mistaking a genuine cost law for a channel. Here is the
law. Write $N = u(u+2k)$, so the Fermat centre is $u+k$ and the frontier offset from the anchor is
$j = (u+k) - \lfloor\sqrt N\rfloor$. Then

$$\frac{k^2}{2(u+k)} \;\le\; j \;\le\; \frac{k^2}{2\lfloor\sqrt N\rfloor} + 1,
\qquad\text{i.e.}\qquad j = \Theta\!\left(\frac{k^2}{\sqrt N}\right).$$

{{visualization:0}}

{{algorithm:0}}

The cost of the ascent is a pure function of the imbalance $k$: no residues, no spectra, no window
length. Balanced semiprimes are found in a couple of steps; unbalanced ones are hopeless. And $k$
is precisely the quantity the surviving oracle reads.

<details>
<summary><strong>Click to reveal: where both inequalities come from</strong></summary>

Write $u + k = m + j$ with $m = \lfloor\sqrt N\rfloor$. Squaring, $(m+j)^2 = N + k^2$. Expanding
gives $2mj + j^2 = k^2 + (N - m^2)$, and $N - m^2 \le 2m$ because $N < (m+1)^2$; dropping
$j^2 \ge 0$ yields the upper law $2mj \le k^2 + 2m$. For the lower law, $m^2 \le N$ gives
$k^2 \le 2mj + j^2 \le 2(m+j)j = 2(u+k)j$.
</details>

---

## 7. A closing surprise: the window is a Pythagorean tree

Restrict the square-hit window to *square* moduli. A factorization $s^2 = u(u+2k)$ says exactly

$$k^2 + s^2 = (u+k)^2,$$

so $(k,\, s,\, u+k)$ is a Pythagorean triple — and conversely every triple with $k \le c$ arises
this way, from $u = c - k$. For $N = s^2$ the anchor *is* $s$, the Fermat centre is the hypotenuse
$c$, and the frontier offset obeys the exact identity

$$(c - s)(c + s) = k^2 .$$

Moreover every such hit lies strictly above a smaller one in the classical Barning–Hall descent on
primitive triples: the parent hypotenuse $-2k - 2s + 3c$ is strictly less than $c$. The square-hit
window *is* the [Pythagorean tree](https://en.wikipedia.org/wiki/Tree_of_primitive_Pythagorean_triples),
and the Fermat ascent is a walk in it.

The smallest case is the oldest triple in mathematics: $144 = 12^2 = 8\cdot(8 + 2\cdot 5)$ gives
$(5, 12, 13)$, with frontier offset $13 - 12 = 1$ and $1 \cdot 25 = 5^2$.

{{demo:0}}

---

## 8. What to take away

1. **Check for constants before you check for significance.** A measured $0.000000$ usually means
   your statistic never varies.
2. **A monotone function of a covariate *is* that covariate.** If your fancy feature reports the
   same information as $\log N$ to four decimals, it is $\log N$.
3. **Shuffle nulls test the wrong hypothesis for deterministic features.** Condition on the
   covariate, or test what your feature adds to already knowing it. Exact conditional nullity is
   not weak evidence — it is equivalent to determinism.
4. **Know why your surviving channel survives.** The positional oracle is outside the sealed class
   for a provable reason, its capacity is unimodal with a peak exactly at balance, and it reads the
   one parameter, the imbalance $k$, that controls the cost of the only real algorithm in sight.

Further reading: [Fermat's factorization method](https://en.wikipedia.org/wiki/Fermat%27s_factorization_method),
[mutual information](https://en.wikipedia.org/wiki/Mutual_information),
[binary entropy](https://en.wikipedia.org/wiki/Binary_entropy_function),
[Simpson's paradox](https://en.wikipedia.org/wiki/Simpson%27s_paradox) — the classical cousin of the
stratification trap described here.
"""

FUTURE_DIRECTIONS = r"""# Future Directions — after the magnitude-mirror seal

Three cycles of work produced: (1) the structural identity that kills the
energy-ascent sensors, (2) an exact *characterisation* of the probes that the
magnitude argument kills (they are precisely the deterministic functions of the
magnitude), (3) closure of that probe class under joint reads, a proof that the
surviving positional oracle lies strictly outside it, and a bridge showing that
the square-hit window over square moduli *is* the Pythagorean tree, with a
two-sided cost law for the frontier.

What the cycles could **not** settle, stated as falsifiable conjectures.

## A. Mirror-Rank Dichotomy for Deterministic Probes

**The key insight is** that mirroring the magnitude is not a binary property but the
bottom of a rank filtration: a probe has *mirror rank r* if its fibres refine the
magnitude partition into at most `r` classes per cell, and rank `1` is exactly the
mirror case sealed in cycle 2.

**Conjecture.** For every probe realized by a `poly(log N)`-time read of the
isqrt window (sign vectors, bracket flags, spectral summaries, Gauss magnitudes)
the mirror rank is `1`, while `1{d ≤ B}` has mirror rank `≥ 2` on every instance
family containing two same-magnitude instances with different smallest factor.
Hence there is no probe of intermediate rank in the realized class: a dichotomy,
not a spectrum.

**Why now?** Cycle 3 supplies both endpoints (the joint seal for mirror batteries,
and the informativeness of the oracle within a magnitude cell); what is missing is
the rank definition and the proof that window-local reads cannot separate
same-magnitude instances, which is a finite computation on the window recurrence.

## B. Frontier-Cost Exponent Law for Balanced Semiprimes

**The key insight is** that the two frontier bounds together pin the Fermat frontier
at `j = Θ(k²/√N)`, so the *cost* of the only surviving channel is a pure function of
the imbalance `k`, with no dependence on residues, spectra, or window length.

**Conjecture.** For semiprimes with `k ≤ N^{1/4}` the anchored ascent finds the
hit in `O(1)` steps, and for `k = N^{α}` with `1/4 < α < 1/2` it needs
`Θ(N^{2α−1/2})` steps — with matching constants `1/2` and `2` from the two
inequalities already proved.

**Why now?** Both directions of the law hold over the natural numbers with no
side conditions; upgrading them to an exponent statement needs only a clean
integer-square-root asymptotic wrapper, and it would turn the stipulated oracle
cost laws into theorems rather than assumptions.

## C. Conditional-Null Completeness of Magnitude Stratification

**The key insight is** that the mirror characterisation makes "exactly 0.0000 bits
given the magnitude cell" logically equivalent to being a mirror, so a *measured*
exact conditional null is a proof of determinism, not a failure to reject.

**Conjecture.** The equivalence survives coarsening: if a feature has exactly zero
conditional information given a coarse magnitude, it is a mirror of that coarse
magnitude, and exact conditional nulls composed along a refinement chain
characterise the entire mirror hierarchy.
"""


def main() -> None:
    article = read(ROOT / "ARTICLE.md")
    paper_md = read(ROOT / "RESEARCH_PAPER.md")
    paper_tex = read(ROOT / "RESEARCH_PAPER.tex")
    demo_py = read(ROOT / "demo.py")

    lean_sources: List[str] = []
    for rel in LEAN_FILES:
        lean_sources.append(
            f"-- ===================================================================\n"
            f"-- FILE: {rel}\n"
            f"-- ===================================================================\n"
            + read(ROOT / rel)
        )
    lean_proofs = "\n\n".join(lean_sources)

    package: Dict[str, object] = {
        "title": "The Magnitude-Mirror Seal: Structural Sensors, Deterministic Features, "
                 "and the Surviving Positional Oracle of the Fermat Ascent",
        "domain": "Combinatorics",
        "description": (
            "An exact, counting-based information calculus for the Fermat ascent window: the sign "
            "structure of the energy a^2 - N is a constant of every modulus, all smooth spectral "
            "summaries are deterministic functions of the magnitude and collapse to exactly zero "
            "information inside every magnitude cell, and the only surviving channel is the "
            "factor-derived positional oracle, whose capacity profile and Theta(k^2/sqrt N) cost "
            "law are determined exactly."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-24",
        "key_results": [
            "Anchored energy dichotomy: E(a) = a^2 - N satisfies E(m) <= 0 < E(m+j) for every j >= 1 "
            "at the anchor m = floor(sqrt N), so the unique zero crossing lies at sqrt N and never at "
            "a divisor offset",
            "Structural nullity of bracket sensors: the window sign vector and negative-energy count "
            "are constants on non-squares, so they and all their post-processings have exactly zero "
            "empirical mutual information with every secret",
            "Mirror characterisation: a feature has exactly zero information about every secret inside "
            "every magnitude cell if and only if it is a deterministic function of the magnitude, and "
            "such mirrors are closed under post-processing, pairing, finite tupling and refinement",
            "Stratification-is-not-transfer theorem: a magnitude mirror with unconditional signal forces "
            "the secret's marginal to vary across magnitude cells, so row-shuffle permutation nulls are "
            "provably the wrong control for deterministic functions of the modulus",
            "Positional oracle survives: the bit 1{d <= B} is not a magnitude mirror, is informative "
            "within a single magnitude cell, has unimodal binary-entropy capacity capped at one bit and "
            "maximal exactly at combinatorial balance, and reads the imbalance k that governs the "
            "two-sided Fermat frontier law j = Theta(k^2/sqrt N)",
            "Pythagorean bridge: over square moduli the square-hit window is exactly the set of "
            "Pythagorean triples, with frontier identity (c-s)(c+s) = k^2 and strict Barning-Hall descent",
        ],
        "keywords": [
            "Fermat factorization",
            "integer square root window",
            "exact mutual information",
            "magnitude mirror",
            "conditional null",
            "binary entropy",
            "Pythagorean triples",
            "Barning-Hall descent",
        ],
        "article": article,
        "research_paper": paper_md,
        "research_paper_tex": paper_tex,
        "demo": demo_py,
        "demos": [
            {
                "name": "Complete Numerical Verification Suite for the Anchored Window, "
                        "the Mirror Collapse and the Positional Oracle",
                "description": (
                    "A single self-contained script that reproduces every quantitative claim of the "
                    "work. It verifies that the window sign vector is one and the same vector across "
                    "hundreds of random moduli and that its mutual information with a secret factor "
                    "bit is exactly zero; runs the anchored Fermat ascent and confirms that each "
                    "square hit factors the modulus; constructs a scale-stratified instance family on "
                    "which a smooth spectral summary and plain log N report identical mutual "
                    "information, a row-shuffle null is rejected at large z, and the information "
                    "collapses to exactly zero once magnitude is held fixed; exhibits the minimal "
                    "two-instance witness separating stratification from transfer; computes the "
                    "below-threshold profile and binary-entropy capacity of the positional oracle "
                    "with its peak, its 90%-of-peak interval and the multi-read pigeonhole bound; "
                    "checks the two-sided frontier cost law on a range of imbalances; and enumerates "
                    "all square-hit factorizations of squares below a bound, confirming that each is "
                    "a Pythagorean triple with frontier identity (c-s)(c+s) = k^2 and strict "
                    "Barning-Hall descent."
                ),
                "code": demo_py,
            },
            {
                "name": "Side-by-Side Audit of Four Candidate Side Channels Under Both Null Models",
                "description": (
                    "A focused experiment that puts four features through the same audit on one "
                    "synthetic instance family whose secret bit is scale-stratified: the window sign "
                    "vector (a structural constant), plain log of the modulus, a smooth spectral "
                    "summary that is a strictly increasing recoding of the magnitude, and the "
                    "factor-derived positional oracle bit. For each feature it reports raw mutual "
                    "information, the z-score of a row-shuffle permutation null, the information "
                    "remaining inside magnitude cells, and whether the feature is a deterministic "
                    "function of the magnitude. The output makes the central distinction visible in "
                    "one table: the mirrors are flagged by the shuffle null yet vanish exactly under "
                    "conditioning, while only the oracle bit survives."
                ),
                "code": read(ASSETS / "demo_mirror_audit.py"),
            },
        ],
        "algorithms": [
            {
                "name": "Anchored Fermat Ascent with Square-Hit Detection and Frontier Envelope",
                "description": (
                    "Scans the anchored window a_j = floor(sqrt N) + j upward and returns the "
                    "factorization at the first index whose energy E(a_j) = a_j^2 - N is a perfect "
                    "square. Correctness rests on the equivalence between a hit E(a) = b^2 with "
                    "b <= a and the factorization N = (a-b)(a+b). The routine also reports the proven "
                    "envelope k^2/(2(u+k)) <= j <= k^2/(2 floor(sqrt N)) + 1 for the frontier offset "
                    "of a modulus presented as N = u(u+2k), so the measured cost can be compared "
                    "against the law. Complexity: O(j) steps, each one integer square root, with "
                    "j = Theta(k^2/sqrt N); balanced factorizations (k <= N^{1/4}) terminate in O(1) "
                    "steps, while k = N^alpha with 1/4 < alpha < 1/2 requires Theta(N^{2 alpha - 1/2})."
                ),
                "pseudocode": (
                    "ANCHORED-ASCENT(N, budget):\n"
                    "  1. m <- floor(sqrt(N))                       # the anchor\n"
                    "  2. for j <- 0, 1, 2, ..., budget-1:\n"
                    "  3.     a <- m + j\n"
                    "  4.     e <- a*a - N                          # the energy\n"
                    "  5.     if e < 0: continue                    # possible only at j = 0\n"
                    "  6.     b <- floor(sqrt(e))\n"
                    "  7.     if b*b = e:                           # square hit\n"
                    "  8.         return (offset j, factors a-b and a+b)\n"
                    "  9. return NONE\n"
                    "\n"
                    "FRONTIER-ENVELOPE(u, k):\n"
                    "  1. N <- u*(u + 2k);  m <- floor(sqrt(N))\n"
                    "  2. j <- (u + k) - m                          # measured offset\n"
                    "  3. lower <- k^2 / (2*(u+k))\n"
                    "  4. upper <- k^2 / (2*m) + 1\n"
                    "  5. assert lower <= j <= upper\n"
                    "  6. return (lower, j, upper)"
                ),
                "code": read(ASSETS / "algo_anchored_ascent.py"),
            },
            {
                "name": "Exact Empirical Independence Test by Contingency-Table Identity",
                "description": (
                    "Decides whether a feature column and a secret column on a finite instance set "
                    "are exactly independent, in the counting sense that every joint fibre has exactly "
                    "the product cardinality: |{T=t and S=s}| * |Omega| = |{T=t}| * |{S=s}|. This "
                    "identity is equivalent to the empirical mutual information being exactly zero, so "
                    "unlike a p-value it is a statement about the data itself. The routine returns the "
                    "boolean verdict, the mutual information in bits, and the list of violating cells "
                    "for diagnosis. Complexity: O(|Omega|) to build the contingency table and "
                    "O(|values of T| * |values of S|) to check it."
                ),
                "pseudocode": (
                    "EXACTLY-INDEPENDENT(T[1..n], S[1..n]):\n"
                    "  1. joint  <- multiset counts of pairs (T[i], S[i])\n"
                    "  2. margT  <- counts of T[i];   margS <- counts of S[i]\n"
                    "  3. for each value t with margT[t] > 0:\n"
                    "  4.     for each value s with margS[s] > 0:\n"
                    "  5.         if joint[t,s] * n != margT[t] * margS[s]:\n"
                    "  6.             return FALSE\n"
                    "  7. return TRUE\n"
                    "\n"
                    "MUTUAL-INFORMATION-BITS(T, S):\n"
                    "  1. total <- 0\n"
                    "  2. for each cell (t,s) with joint[t,s] > 0:\n"
                    "  3.     p <- joint[t,s]/n\n"
                    "  4.     total <- total + p * log2( p / ((margT[t]/n)*(margS[s]/n)) )\n"
                    "  5. return max(total, 0)      # zero exactly when the identity holds"
                ),
                "code": read(ASSETS / "algo_exact_independence.py"),
            },
            {
                "name": "Magnitude-Conditioned Null Versus Row-Shuffle Null: The Correct Control",
                "description": (
                    "Runs both null models side by side and returns the diagnosis. The row-shuffle "
                    "null permutes the secret column, preserving both marginals, and therefore tests "
                    "association; a deterministic function of the modulus inherits the drift of the "
                    "secret's marginal across scales and is flagged as significant even though it "
                    "transfers nothing. The magnitude-conditioned null averages the within-cell mutual "
                    "information, and its verdict is exact: the aggregate is zero if and only if the "
                    "feature is a deterministic function of the magnitude. The discrepancy between the "
                    "two nulls is itself the diagnosis of scale stratification. Complexity: "
                    "O(R |Omega|) for R shuffle replicates plus O(|Omega|) for the conditional pass."
                ),
                "pseudocode": (
                    "AUDIT-FEATURE(Phi, S, M, replicates R):\n"
                    "  1. observed <- MI(Phi, S)\n"
                    "  2. for r <- 1..R:  draws[r] <- MI(Phi, RANDOM-PERMUTATION(S))\n"
                    "  3. mu <- mean(draws);  sd <- stdev(draws)\n"
                    "  4. z  <- (observed - mu)/sd                       # shuffle-null verdict\n"
                    "  5. cond <- 0\n"
                    "  6. for each magnitude cell c in image(M):\n"
                    "  7.     I_c <- instances with M = c\n"
                    "  8.     cond <- cond + (|I_c|/|Omega|) * MI(Phi|I_c, S|I_c)\n"
                    "  9. mirror <- TRUE iff Phi is constant on every cell of M\n"
                    " 10. if mirror and cond = 0 and z > 3:\n"
                    " 11.     return 'MIRROR: signal is scale stratification, not transfer'\n"
                    " 12. if cond > 0: return 'SURVIVES: information persists within cells'\n"
                    " 13. return 'NO SIGNAL'"
                ),
                "code": read(ASSETS / "algo_magnitude_conditioned_null.py"),
            },
            {
                "name": "Positional Oracle Capacity Profile with Peak Localisation and Superlevel Interval",
                "description": (
                    "Computes the below-threshold fraction p(B) = |{d <= B}|/|Omega| and the capacity "
                    "H(p(B)) of the oracle bit 1{d <= B} over a grid of thresholds, then localises the "
                    "peak and the interval of thresholds reaching a target fraction of it. The theory "
                    "guarantees that p is monotone, that H(p) is capped at one bit, ascends while "
                    "p <= 1/2, descends once p >= 1/2, attains its maximum exactly when the threshold "
                    "halves the instance set, and has interval superlevel sets, so the returned "
                    "endpoints are genuine and not artifacts of the grid. The pigeonhole helper reports "
                    "the |Omega|/2^L bound on the largest class of instances left indistinguishable by "
                    "L Boolean reads. Complexity: O(|Omega| log |Omega|) to sort, O(log |Omega|) per "
                    "threshold."
                ),
                "pseudocode": (
                    "ORACLE-CAPACITY-PROFILE(d[1..n], grid, target fraction f):\n"
                    "  1. sorted_d <- SORT(d)\n"
                    "  2. for each B in grid:\n"
                    "  3.     count <- number of entries of sorted_d that are <= B   (binary search)\n"
                    "  4.     p[B]  <- count / n\n"
                    "  5.     H[B]  <- -p log2 p - (1-p) log2 (1-p)     (0 at p in {0,1})\n"
                    "  6. peak <- argmax_B H[B]\n"
                    "  7. theta <- f * H[peak]\n"
                    "  8. reaching <- { B in grid : H[B] >= theta }      # provably an interval\n"
                    "  9. return (p, H, peak, min(reaching), max(reaching), median(sorted_d))\n"
                    "\n"
                    "PIGEONHOLE-BOUND(n, L):  return n / 2^L"
                ),
                "code": read(ASSETS / "algo_oracle_profile.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Anchored Energy Window and the Two-Sided Frontier Cost Law",
                "description": (
                    "Left panel: the rescaled energy E(a_j)/(2 floor(sqrt N)) on the anchored window "
                    "for moduli spanning nine orders of magnitude. Every curve is negative exactly at "
                    "j = 0 and positive from j = 1 onward, so the unique zero crossing sits at sqrt N "
                    "for every modulus and the window sign pattern is one and the same constant vector. "
                    "Right panel: the measured frontier offset j for six hundred random factorizations "
                    "plotted against its proven envelope k^2/(2(u+k)) <= j <= k^2/(2 floor(sqrt N)) + 1 "
                    "on log-log axes, exhibiting the law j = Theta(k^2/sqrt N)."
                ),
                "code": read(ASSETS / "viz_window_and_frontier.py"),
            },
            {
                "name": "The Mirror Collapse Beside the Surviving Oracle Capacity Profile",
                "description": (
                    "Left panel: four bars showing the mutual information of a spectral summary with a "
                    "secret bit as the analysis is refined - raw, the identical value for plain log N, "
                    "the shrunken value given coarse magnitude deciles, and exactly zero given magnitude "
                    "cells that resolve the feature. Right panel: the capacity profile of the positional "
                    "oracle, plotting the monotone below-threshold fraction p(B) together with the "
                    "unimodal binary entropy H(p(B)), the peak marked at p = 1/2, and the shaded band of "
                    "thresholds achieving at least ninety percent of the peak, which the theory forces to "
                    "be an interval."
                ),
                "code": read(ASSETS / "viz_mirror_and_oracle.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Anchored Energy Window Explorer",
                "description": (
                    "An interactive scan of the Fermat ascent window. Choose the smaller factor u and "
                    "the imbalance k, and the widget builds the modulus N = u(u+2k), computes the "
                    "anchor floor(sqrt N), and tabulates the energy, its sign, and any perfect-square "
                    "hit at each offset, highlighting the row where the factorization drops out. Two "
                    "lessons emerge from play: the sign column always reads (-1, +1, +1, ...) no matter "
                    "which modulus is chosen, so no sign-based sensor can distinguish instances; and the "
                    "distance to the hit obeys the displayed two-sided cost law, moving from one step "
                    "for balanced factorizations to thousands for unbalanced ones. Preset buttons cover "
                    "a balanced semiprime, an unbalanced one, and a square modulus, where the anchor "
                    "itself is the hit and the window data becomes a Pythagorean triple."
                ),
                "html": read(ASSETS / "widget_window.html"),
            },
            {
                "title": "Mirror or Channel? An Information Laboratory",
                "description": (
                    "A live audit bench for candidate side channels. The widget synthesises an instance "
                    "family whose secret bit is scale-stratified by an adjustable amount, then evaluates "
                    "any of four features - the structurally constant window sign vector, plain log of "
                    "the modulus, a smooth spectral summary that is a strictly increasing recoding of "
                    "it, or the factor-derived positional oracle bit - under two competing nulls. It "
                    "reports the raw mutual information, the row-shuffle permutation z-score, and the "
                    "information surviving inside magnitude cells, whose number the user controls. The "
                    "spectral summary and plain log of the modulus always agree to the last displayed "
                    "digit, the shuffle null always rejects, and conditioning always drives the mirrors "
                    "to exactly zero, while only the oracle bit survives. A live canvas plots the "
                    "oracle's below-threshold fraction and its binary-entropy capacity, marking the "
                    "peak at combinatorial balance and shading the interval of thresholds reaching "
                    "ninety percent of it."
                ),
                "html": read(ASSETS / "widget_mirror.html"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_py},
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
Numerical demonstrations for
"Structural Sensors, Magnitude Mirrors, and the Surviving Positional Oracle".

Pure standard library (math, random, itertools, collections).  Run with:

    python3 demo.py

Each section prints a short verdict corresponding to one theorem of the paper:

  1.  Anchored energy:  E(m) <= 0 < E(m+j) for every j >= 1 -- one zero crossing,
      always between j = 0 and j = 1.  Sign vectors are CONSTANT on non-squares,
      so bracket / sign-count sensors have exactly zero mutual information.
  2.  Square hits:  E(a) = b^2  <=>  N = (a-b)(a+b).
  3.  Magnitude mirrors:  a strictly monotone recoding of log N has EXACTLY the
      same mutual information as log N, and collapses to exactly 0 bits inside
      every magnitude cell -- while a row-shuffle null happily calls it signal.
  4.  Positional oracle 1{d <= B}:  monotone below-threshold profile, unimodal
      binary-entropy capacity, peak exactly at combinatorial balance, interval
      superlevel sets.
  5.  Fermat frontier:  k^2/(2(u+k)) <= j <= k^2/(2 isqrt(N)) + 1.
  6.  Pythagorean bridge:  s^2 = u(u+2k)  <=>  (k, s, u+k) is a triple, with
      (c-s)(c+s) = k^2 and strict Barning-Hall descent.
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Section 0.  Small arithmetic helpers                                         #
# --------------------------------------------------------------------------- #


def isqrt(n: int) -> int:
    """Integer square root, floor(sqrt(n)) for n >= 0."""
    return math.isqrt(n)


def energy(modulus: int, a: int) -> int:
    """The Fermat energy E(a) = a^2 - N."""
    return a * a - modulus


def anchor(modulus: int) -> int:
    """The window anchor m = floor(sqrt(N))."""
    return isqrt(modulus)


def is_perfect_square(n: int) -> bool:
    """True iff n >= 0 is a perfect square."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def sign(x: int) -> int:
    """The sign of an integer, in {-1, 0, +1}."""
    return (x > 0) - (x < 0)


def sign_vector(modulus: int, length: int) -> Tuple[int, ...]:
    """The bracket sensor: signs of the energy on the anchored window."""
    m = anchor(modulus)
    return tuple(sign(energy(modulus, m + j)) for j in range(length))


def negative_count(modulus: int, length: int) -> int:
    """The sign-count sensor: number of negative-energy window positions."""
    m = anchor(modulus)
    return sum(1 for j in range(length) if energy(modulus, m + j) < 0)


def smallest_nontrivial_factor(n: int) -> int:
    """Smallest factor > 1 of n (returns n itself if n is prime)."""
    if n % 2 == 0:
        return 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return f
        f += 2
    return n


# --------------------------------------------------------------------------- #
# Section 0b.  Exact empirical independence and mutual information             #
# --------------------------------------------------------------------------- #


def mutual_information_bits(
    feature: Sequence[object], secret: Sequence[object]
) -> float:
    """Empirical mutual information (in bits) of two aligned columns."""
    n = len(feature)
    if n == 0:
        return 0.0
    joint = Counter(zip(feature, secret))
    pf = Counter(feature)
    ps = Counter(secret)
    total = 0.0
    for (t, s), c in joint.items():
        p_joint = c / n
        total += p_joint * math.log2(p_joint / ((pf[t] / n) * (ps[s] / n)))
    return max(total, 0.0)


def exactly_independent(
    feature: Sequence[object], secret: Sequence[object]
) -> bool:
    """The counting criterion: |{T=t,S=s}| * |O| == |{T=t}| * |{S=s}| for all cells."""
    n = len(feature)
    joint = Counter(zip(feature, secret))
    pf = Counter(feature)
    ps = Counter(secret)
    for t in pf:
        for s in ps:
            if joint[(t, s)] * n != pf[t] * ps[s]:
                return False
    return True


def conditional_mutual_information_bits(
    feature: Sequence[object],
    secret: Sequence[object],
    magnitude: Sequence[object],
) -> float:
    """Weighted average of the within-cell mutual informations."""
    n = len(feature)
    cells: Dict[object, List[int]] = {}
    for i, c in enumerate(magnitude):
        cells.setdefault(c, []).append(i)
    total = 0.0
    for idxs in cells.values():
        w = len(idxs) / n
        total += w * mutual_information_bits(
            [feature[i] for i in idxs], [secret[i] for i in idxs]
        )
    return total


def shuffle_null_z(
    feature: Sequence[object],
    secret: Sequence[object],
    replicates: int = 400,
    seed: int = 20260824,
) -> Tuple[float, float, float]:
    """Row-shuffle permutation null: returns (observed MI, null mean, z-score)."""
    rng = random.Random(seed)
    observed = mutual_information_bits(feature, secret)
    pool = list(secret)
    draws: List[float] = []
    for _ in range(replicates):
        rng.shuffle(pool)
        draws.append(mutual_information_bits(feature, pool))
    mu = sum(draws) / len(draws)
    var = sum((d - mu) ** 2 for d in draws) / len(draws)
    sd = math.sqrt(var)
    z = (observed - mu) / sd if sd > 0 else float("inf")
    return observed, mu, z


def binary_entropy_bits(p: float) -> float:
    """Binary entropy in bits; H(0) = H(1) = 0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# --------------------------------------------------------------------------- #
# Section 1.  The anchored energy and the bracket sensors                      #
# --------------------------------------------------------------------------- #


def demo_energy_structure(sample: Iterable[int], window: int = 8) -> None:
    print("=" * 78)
    print("1.  The anchored energy has exactly one sign change, at the anchor")
    print("=" * 78)
    moduli = [n for n in sample if not is_perfect_square(n)]
    vectors = {sign_vector(n, window) for n in moduli}
    counts = {negative_count(n, window) for n in moduli}
    print(f"    non-square moduli tested          : {len(moduli)}")
    print(f"    distinct window sign vectors      : {len(vectors)}  -> {vectors}")
    print(f"    distinct negative-energy counts   : {counts}")
    ok = all(
        energy(n, anchor(n)) < 0
        and all(energy(n, anchor(n) + j) > 0 for j in range(1, window))
        for n in moduli
    )
    print(f"    E(m) < 0 < E(m+j) for all j >= 1  : {ok}")

    # A sensor that is constant carries exactly zero information about anything.
    secret = [smallest_nontrivial_factor(n) % 2 for n in moduli]
    feature = [sign_vector(n, window) for n in moduli]
    mi = mutual_information_bits(feature, secret)
    print(f"    MI(sign vector ; secret bit)      : {mi:.6f} bits")
    print(f"    exact counting independence       : {exactly_independent(feature, secret)}")

    # ... and so does any post-processing of it (Lemma: data processing).
    hashed = [hash(v) % 7 for v in feature]
    print(
        "    MI(hash of sign vector ; secret)  : "
        f"{mutual_information_bits(hashed, secret):.6f} bits"
    )
    print()


# --------------------------------------------------------------------------- #
# Section 2.  Square hits are factorizations                                   #
# --------------------------------------------------------------------------- #


def fermat_ascent(modulus: int, budget: int = 10 ** 6) -> Optional[Tuple[int, int, int]]:
    """Anchored ascent: returns (offset j, factor u, factor v) at the first hit."""
    m = anchor(modulus)
    for j in range(budget):
        a = m + j
        e = a * a - modulus
        if e >= 0 and is_perfect_square(e):
            b = isqrt(e)
            return j, a - b, a + b
    return None


def demo_square_hits() -> None:
    print("=" * 78)
    print("2.  The real window event is the square hit, and it factors N")
    print("=" * 78)
    for u, k in [(59, 21), (101, 40), (997, 6), (10007, 1500)]:
        n = u * (u + 2 * k)
        print(f"    N = {n:>12}  =  {u} * {u + 2 * k}   (imbalance k = {k})")
        print(f"        E(u+k) = {energy(n, u + k):>12}  and k^2 = {k * k:>12}")
        found = fermat_ascent(n)
        assert found is not None
        j, a_minus_b, a_plus_b = found
        print(
            f"        ascent hit at offset j = {j:<6} -> {a_minus_b} * {a_plus_b} "
            f"= {a_minus_b * a_plus_b}"
        )
    print()


# --------------------------------------------------------------------------- #
# Section 3.  Magnitude mirrors: the kill shot, reproduced                     #
# --------------------------------------------------------------------------- #


def build_instance_table(
    count: int = 4000, seed: int = 11235
) -> Tuple[List[int], List[int]]:
    """Semiprime-like instances whose scale varies over several decades.

    Returns (moduli, secret bits).  The secret is a bit of the smaller factor.
    The instances are constructed so that -- exactly as in real data -- the
    secret's marginal DRIFTS with the magnitude of N: this is the scale
    stratification that fools a row-shuffle null.
    """
    rng = random.Random(seed)
    moduli: List[int] = []
    secrets: List[int] = []
    for _ in range(count):
        scale = rng.uniform(3.0, 9.0)           # decades of magnitude
        u = int(10 ** (scale / 2))
        # stratification: the parity bias of the small factor drifts with scale
        bias = 0.15 + 0.7 * (scale - 3.0) / 6.0
        bit = 1 if rng.random() < bias else 0
        u = u + ((bit - u) % 2)                 # force parity of u to equal bit
        k = rng.randrange(1, max(2, u // 4))
        moduli.append(u * (u + 2 * k))
        secrets.append(bit)
    return moduli, secrets


def demo_magnitude_mirror() -> None:
    print("=" * 78)
    print("3.  Magnitude mirrors: the spectral feature IS log N")
    print("=" * 78)
    moduli, secrets = build_instance_table()

    # Two features.  One is "plain magnitude"; the other is a fancy-looking
    # strictly monotone recoding of it -- i.e. a magnitude mirror.
    def plain_log(n: int) -> float:
        return math.log(n)

    def spectral_summary(n: int) -> float:
        """A smooth 'spectral' statistic of the anchored window.

        It looks like an energy-profile summary, but it is a strictly increasing
        function of log N, hence a magnitude mirror.
        """
        x = math.log(n)
        return math.atan(x / 8.0) * 3.0 + 0.01 * x

    def quantize(values: Sequence[float], bins: int) -> List[int]:
        order = sorted(range(len(values)), key=lambda i: values[i])
        out = [0] * len(values)
        for rank, i in enumerate(order):
            out[i] = rank * bins // len(values)
        return out

    feat_log = quantize([plain_log(n) for n in moduli], 32)
    feat_spec = quantize([spectral_summary(n) for n in moduli], 32)
    deciles = quantize([plain_log(n) for n in moduli], 10)
    cells = quantize([plain_log(n) for n in moduli], 32)   # magnitude at the
    #                                                        feature's own resolution

    mi_log = mutual_information_bits(feat_log, secrets)
    mi_spec = mutual_information_bits(feat_spec, secrets)
    print(f"    MI(log N            ; secret)      : {mi_log:.6f} bits")
    print(f"    MI(spectral summary ; secret)      : {mi_spec:.6f} bits")
    print(f"    identical to 1e-12                 : {abs(mi_log - mi_spec) < 1e-12}")

    obs, mu, z = shuffle_null_z(feat_spec, secrets)
    print(f"    row-shuffle null: MI = {obs:.4f}, null mean = {mu:.4f}, z = {z:.1f}")
    print("      -> the WRONG null happily calls this 'signal'")

    cmi_dec = conditional_mutual_information_bits(feat_spec, secrets, deciles)
    print(f"    MI(spectral ; secret | log-N decile): {cmi_dec:.6f} bits")
    print("      -> the residue is stratification INSIDE a coarse decile")

    # Exactly zero, cell by cell, once the magnitude cells resolve the mirror:
    # inside such a cell the feature is a constant.
    cmi = conditional_mutual_information_bits(feat_spec, secrets, cells)
    exact_cells = all(
        exactly_independent(
            [feat_spec[i] for i in range(len(moduli)) if cells[i] == c],
            [secrets[i] for i in range(len(moduli)) if cells[i] == c],
        )
        for c in set(cells)
    )
    print(f"    MI(spectral ; secret | magnitude)   : {cmi:.6f} bits")
    print(f"    exact counting independence per cell: {exact_cells}")
    print("      -> stratification, not transfer")
    print()


def demo_stratification_witness() -> None:
    print("=" * 78)
    print("3b. Two-instance witness: unconditional signal, exact conditional null")
    print("=" * 78)
    omega = [2, 3]
    magnitude = [n for n in omega]        # M = identity
    feature = [2 * n for n in omega]      # a strictly monotone recoding of M
    secret = [n % 2 for n in omega]
    print(f"    MI(feature ; secret)                : "
          f"{mutual_information_bits(feature, secret):.6f} bits")
    print(f"    exactly independent unconditionally : "
          f"{exactly_independent(feature, secret)}")
    print(f"    MI given the magnitude cell         : "
          f"{conditional_mutual_information_bits(feature, secret, magnitude):.6f} bits")
    print()


# --------------------------------------------------------------------------- #
# Section 4.  The positional oracle 1{d <= B}                                  #
# --------------------------------------------------------------------------- #


def below_fraction(factors: Sequence[int], threshold: int) -> float:
    """p(B) = fraction of instances whose factor statistic is at most B."""
    if not factors:
        return 0.0
    return sum(1 for d in factors if d <= threshold) / len(factors)


def oracle_capacity_profile(
    factors: Sequence[int], grid: Sequence[int]
) -> List[Tuple[int, float, float]]:
    """Returns (B, p(B), H(p(B))) for every threshold in the grid."""
    return [
        (b, below_fraction(factors, b), binary_entropy_bits(below_fraction(factors, b)))
        for b in grid
    ]


def demo_positional_oracle(count: int = 6000, seed: int = 7) -> None:
    print("=" * 78)
    print("4.  The surviving channel: capacity profile of the bit 1{d <= B}")
    print("=" * 78)
    rng = random.Random(seed)
    # A heavy-tailed smallest-factor distribution, the empirical shape of d.
    factors = [int(math.exp(rng.gauss(12.3, 2.2))) + 2 for _ in range(count)]
    factors.sort()
    median = factors[len(factors) // 2]

    grid = sorted({int(math.exp(x / 12.0)) + 2 for x in range(12, 260)})
    profile = oracle_capacity_profile(factors, grid)

    peak_b, peak_p, peak_h = max(profile, key=lambda row: row[2])
    target = 0.90 * peak_h
    reaching = [b for (b, _, h) in profile if h >= target]
    b_star, b_top = min(reaching), max(reaching)

    print(f"    instances                          : {count}")
    print(f"    median of the factor statistic d   : {median}")
    print(f"    capacity peak                      : {peak_h:.4f} bits at B = {peak_b}")
    print(f"    below-threshold fraction at peak   : {peak_p:.4f}  (balance = 0.5)")
    print(f"    >= 90% of peak on the interval     : [{b_star}, {b_top}]")

    # monotonicity of p, unimodality of H, interval superlevel sets
    mono = all(profile[i][1] <= profile[i + 1][1] for i in range(len(profile) - 1))
    contiguous = all(
        h >= target
        for (b, _, h) in profile
        if b_star <= b <= b_top
    )
    capped = all(h <= 1.0 + 1e-12 for (_, _, h) in profile)
    print(f"    p(B) monotone in B                 : {mono}")
    print(f"    superlevel set is an interval      : {contiguous}")
    print(f"    capacity <= 1 bit everywhere       : {capped}")

    print("\n    B            p(B)     H(p(B)) bits")
    for b, p, h in profile[:: max(1, len(profile) // 12)]:
        bar = "#" * int(round(40 * h))
        print(f"    {b:>10}  {p:6.3f}   {h:6.4f}  {bar}")
    print()


def demo_oracle_not_mirror() -> None:
    print("=" * 78)
    print("4b. The oracle bit is not a magnitude mirror (and is informative)")
    print("=" * 78)
    instances = [(2, 7), (3, 5)]                       # N = 14 and N = 15
    magnitude = [(u * v) // 8 for (u, v) in instances]  # both land in cell 1
    oracle = [1 if u <= 2 else 0 for (u, _) in instances]
    secret = [v % 4 for (_, v) in instances]
    print(f"    magnitude cells                    : {magnitude}")
    print(f"    oracle bit 1{{d <= 2}}               : {oracle}")
    print(f"    same cell, different bit -> mirror : {len(set(magnitude)) == 1 and len(set(oracle)) == 1}")
    print(f"    MI within the single cell          : "
          f"{mutual_information_bits(oracle, secret):.6f} bits")
    print()


def demo_multi_oracle_pigeonhole(count: int = 5000, reads: int = 4, seed: int = 3) -> None:
    print("=" * 78)
    print("4c. Pigeonhole: L Boolean reads leave a class of size >= |Omega| / 2^L")
    print("=" * 78)
    rng = random.Random(seed)
    patterns = Counter(
        tuple(rng.randrange(2) for _ in range(reads)) for _ in range(count)
    )
    biggest = max(patterns.values())
    print(f"    |Omega| = {count}, L = {reads}, 2^L = {2 ** reads}")
    print(f"    largest indistinguishable class    : {biggest}")
    print(f"    |Omega| <= 2^L * class             : {count <= 2 ** reads * biggest}")
    print()


# --------------------------------------------------------------------------- #
# Section 5.  The two-sided Fermat frontier cost law                           #
# --------------------------------------------------------------------------- #


def frontier_offset(u: int, k: int) -> int:
    """j = (u + k) - floor(sqrt(u(u+2k)))."""
    n = u * (u + 2 * k)
    return (u + k) - isqrt(n)


def demo_frontier_law() -> None:
    print("=" * 78)
    print("5.  Frontier cost law:  k^2/(2(u+k))  <=  j  <=  k^2/(2 isqrt N) + 1")
    print("=" * 78)
    print(f"    {'u':>12} {'k':>10} {'j':>8} {'lower':>12} {'upper':>12}  ok")
    cases: List[Tuple[int, int]] = [
        (59, 21), (101, 3), (1009, 40), (99991, 7),
        (1000003, 500), (12345701, 20000), (999999937, 1),
    ]
    all_ok = True
    for u, k in cases:
        n = u * (u + 2 * k)
        j = frontier_offset(u, k)
        lower = k * k / (2 * (u + k))
        upper = k * k / (2 * isqrt(n)) + 1
        ok = lower - 1e-9 <= j <= upper + 1e-9
        all_ok = all_ok and ok
        print(f"    {u:>12} {k:>10} {j:>8} {lower:>12.3f} {upper:>12.3f}  {ok}")
    print(f"    two-sided law holds in all cases   : {all_ok}")

    # The exponent: k = N^alpha means roughly j ~ N^(2 alpha - 1/2).
    print("\n    exponent check (u ~ 10^8, k = u^beta):")
    u = 10 ** 8
    for beta in [0.1, 0.25, 0.4, 0.5, 0.6, 0.75]:
        k = max(1, int(u ** beta))
        n = u * (u + 2 * k)
        j = frontier_offset(u, k)
        alpha = math.log(k) / math.log(n)
        predicted = 2 * alpha - 0.5
        actual = math.log(max(j, 1)) / math.log(n)
        print(
            f"      k = {k:<12} alpha = {alpha:5.3f}  j = {j:<10} "
            f"log_N j = {actual:6.3f}  (2a - 1/2 = {predicted:6.3f})"
        )
    print()


# --------------------------------------------------------------------------- #
# Section 6.  The Pythagorean bridge over square moduli                        #
# --------------------------------------------------------------------------- #


def barning_hall_child(x: int, y: int, z: int) -> Tuple[int, int, int]:
    """One Barning-Hall child of a primitive triple (x, y, z)."""
    return (x - 2 * y + 2 * z, 2 * x - y + 2 * z, 2 * x - 2 * y + 3 * z)


def demo_pythagorean_bridge(limit: int = 400) -> None:
    print("=" * 78)
    print("6.  Square moduli: the square-hit window IS the Pythagorean tree")
    print("=" * 78)
    found: List[Tuple[int, int, int, int]] = []
    for s in range(3, limit):
        n = s * s
        for u in range(1, s + 1):
            if n % u == 0:
                v = n // u
                if (v - u) % 2 == 0 and v >= u:
                    k = (v - u) // 2
                    if k > 0:
                        found.append((u, k, s, u + k))
    print(f"    factorizations s^2 = u(u+2k) with s < {limit}: {len(found)}")

    triples_ok = all(k * k + s * s == c * c for (_, k, s, c) in found)
    anchors_ok = all(isqrt(u * (u + 2 * k)) == s for (u, k, s, _) in found)
    identity_ok = all((c - s) * (c + s) == k * k for (_, k, s, c) in found)
    descent_ok = all(
        -2 * k - 2 * s + 3 * c < c for (_, k, s, c) in found if k > 0 and s > 0
    )
    print(f"    every hit gives a Pythagorean triple : {triples_ok}")
    print(f"    the anchor is exactly s              : {anchors_ok}")
    print(f"    frontier identity (c-s)(c+s) = k^2   : {identity_ok}")
    print(f"    Barning-Hall parent hypotenuse < c   : {descent_ok}")

    print("\n    a few hits and their triples:")
    for u, k, s, c in found[:8]:
        print(
            f"      {s}^2 = {s * s:>7} = {u} * {u + 2 * k:<7} -> triple "
            f"({k}, {s}, {c}), offset c - s = {c - s}, (c-s)(c+s) = {(c - s) * (c + s)} = {k}^2"
        )

    # The classical (5, 12, 13) instance and its descent.
    u, k, s = 8, 5, 12
    c = u + k
    print(f"\n    classical case: {u} * {u + 2 * k} = {s}^2 -> triple ({k}, {s}, {c})")
    print(f"      parent hypotenuse expression      : "
          f"-2k - 2s + 3c = {-2 * k - 2 * s + 3 * c} < c = {c}")
    print(f"      one Barning-Hall child of (3,4,5) : {barning_hall_child(3, 4, 5)}")
    print()


# --------------------------------------------------------------------------- #
# Main                                                                         #
# --------------------------------------------------------------------------- #


def main() -> None:
    rng = random.Random(2026)
    sample = [rng.randrange(10 ** 6, 10 ** 12) for _ in range(500)]

    demo_energy_structure(sample)
    demo_square_hits()
    demo_magnitude_mirror()
    demo_stratification_witness()
    demo_positional_oracle()
    demo_oracle_not_mirror()
    demo_multi_oracle_pigeonhole()
    demo_frontier_law()
    demo_pythagorean_bridge()

    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
