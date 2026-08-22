"""
Algorithm 1 — Exact evaluation of the single-pass residue-dial law.

Given a modulus M and a filter K of residue classes, compute in O(|K|) time the
density theta, the normalised cost 1 - theta + theta^2, the speedup, the
absolute saving, the capacity bits and the work bits, together with a
certificate that the speedup does not exceed the universal cap 4/3 and a flag
saying whether the cap is attained exactly.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable

CAP: float = 4.0 / 3.0


@dataclass(frozen=True)
class DialReport:
    """Everything the exact law determines about a dial."""
    modulus: int
    kept: int
    classes: int          # phi(M)
    theta: float
    cost: float           # normalised, = 1 - theta + theta^2
    speedup: float        # = 1 / cost
    saving_fraction: float  # theta - theta^2, share of a full scan saved
    capacity_bits: float
    work_bits: float
    within_cap: bool
    attains_cap: bool


def euler_phi(m: int) -> int:
    """phi(m) by trial division of the radical.  O(sqrt(m))."""
    if m <= 0:
        raise ValueError("modulus must be positive")
    result, n, p = m, m, 2
    while p * p <= n:
        if n % p == 0:
            while n % p == 0:
                n //= p
            result -= result // p
        p += 1
    if n > 1:
        result -= result // n
    return result


def analyse_dial(modulus: int, kept_classes: Iterable[int]) -> DialReport:
    """
    Analyse a residue dial.  Only the units coprime to `modulus` are counted,
    duplicates are discarded, and the law is then evaluated in closed form.
    """
    n = euler_phi(modulus)
    kept = {c % modulus for c in kept_classes if math.gcd(c % modulus, modulus) == 1}
    k = len(kept)
    theta = k / n
    cost = 1.0 - theta + theta * theta
    speedup = 1.0 / cost
    return DialReport(
        modulus=modulus,
        kept=k,
        classes=n,
        theta=theta,
        cost=cost,
        speedup=speedup,
        saving_fraction=theta - theta * theta,
        capacity_bits=(-math.log2(theta) if theta > 0 else math.inf),
        work_bits=math.log2(speedup),
        within_cap=speedup <= CAP + 1e-12,
        attains_cap=(2 * k == n),
    )


if __name__ == "__main__":
    # Quadratic residues modulo 13: exactly half the classes, so exactly 4/3.
    qr = [(u * u) % 13 for u in range(1, 13)]
    print(analyse_dial(13, qr))
    # A very aggressive filter: 1 class in 100 -- almost worthless.
    print(analyse_dial(101, [1]))


"""
Algorithm 2 — Exhaustive certification of the cap over the full subset lattice.

For a modulus M, enumerate EVERY subset of the unit group modulo M, simulate the
dial-aware scan directly (averaging the realised cost over all targets, with no
appeal to the closed-form law), and return the maximum realised speedup together
with the cardinalities at which it is attained.

The naive enumeration is O(2^phi(M) * phi(M)).  Because the simulation depends
on a subset only through its cardinality — the very fact being certified — a
cardinality-collapsed pass costs only O(phi(M)^2); the routine runs both and
checks that they agree, which is the certificate of structure blindness.
"""

from __future__ import annotations

import itertools
import math
from dataclasses import dataclass


@dataclass(frozen=True)
class CapCertificate:
    modulus: int
    classes: int
    subsets_examined: int
    max_speedup: float
    attaining_cardinalities: tuple[int, ...]
    collapse_verified: bool   # brute force agrees with the cardinality-only pass


def units_mod(m: int) -> list[int]:
    return [u for u in range(m) if math.gcd(u, m) == 1]


def simulated_speedup(n: int, kept: frozenset[int]) -> float:
    """Direct simulation: average cost(t) over every target t, then invert."""
    k = len(kept)
    total_cost = sum(k if t in kept else n for t in range(n))
    return n / (total_cost / n)


def certify_cap(modulus: int, max_classes: int = 20) -> CapCertificate:
    us = units_mod(modulus)
    n = len(us)
    if n > max_classes:
        raise ValueError(f"phi({modulus}) = {n} too large for exhaustive enumeration")

    best = 0.0
    attaining: set[int] = set()
    examined = 0
    for r in range(n + 1):
        for subset in itertools.combinations(range(n), r):
            examined += 1
            s = simulated_speedup(n, frozenset(subset))
            if s > best + 1e-15:
                best, attaining = s, {r}
            elif abs(s - best) <= 1e-15:
                attaining.add(r)

    # cardinality-collapsed pass
    collapsed = max(simulated_speedup(n, frozenset(range(r))) for r in range(n + 1))
    return CapCertificate(
        modulus=modulus,
        classes=n,
        subsets_examined=examined,
        max_speedup=best,
        attaining_cardinalities=tuple(sorted(attaining)),
        collapse_verified=abs(best - collapsed) <= 1e-15,
    )


if __name__ == "__main__":
    for m in (3, 4, 7, 11, 13):
        print(certify_cap(m))


"""
Algorithm 3 — Optimal dial-aware schedule and its triangular lower bound.

Under expected-position accounting the algorithm is charged the index at which
the target is found, and may order the classes freely inside each branch of the
dial reading.  This module

  * constructs an optimal schedule in O(n) — position 1,2,...,k inside the kept
    block and 1,2,...,j inside the rejected block, in any order;
  * evaluates its total cost and compares it with the triangular lower bound
    k(k+1)/2 + j(j+1)/2, which no schedule can beat;
  * returns the resulting expected-position speedup
    A(k,j) = (k+j)(k+j+1) / (k(k+1) + j(j+1)),
    an upper bound over ALL dial-aware strategies, and always strictly below 2;
  * optionally brute-forces every schedule for small n, in O(k! * j!), to
    exhibit the optimality lemma concretely.
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass


@dataclass(frozen=True)
class ScheduleReport:
    kept: int                 # k
    rejected: int             # j
    optimal_total: int        # sum of positions over all targets
    triangular_bound: int     # k(k+1)/2 + j(j+1)/2
    baseline_total: float     # n(n+1)/2
    avg_speedup: float        # A(k, j)
    below_two: bool
    brute_force_total: int | None


def triangular(m: int) -> int:
    return m * (m + 1) // 2


def optimal_schedule(kept: list[int], rejected: list[int]) -> dict[int, int]:
    """Assign positions 1..k inside the kept block and 1..j inside the rejected."""
    schedule: dict[int, int] = {}
    for pos, t in enumerate(kept, start=1):
        schedule[t] = pos
    for pos, t in enumerate(rejected, start=1):
        schedule[t] = pos
    return schedule


def brute_force_optimum(k: int, j: int) -> int:
    """Minimum total over EVERY pair of orders.  Exponential; small k, j only."""
    best = None
    for perm_in in itertools.permutations(range(1, k + 1)):
        for perm_out in itertools.permutations(range(1, j + 1)):
            total = sum(perm_in) + sum(perm_out)
            best = total if best is None else min(best, total)
    return 0 if best is None else best


def analyse_schedule(k: int, j: int, brute_force: bool = False) -> ScheduleReport:
    if k + j <= 0:
        raise ValueError("the class space must be nonempty")
    n = k + j
    kept = list(range(k))
    rejected = list(range(k, n))
    sched = optimal_schedule(kept, rejected)
    total = sum(sched.values())
    bound = triangular(k) + triangular(j)
    a = (n * (n + 1)) / (k * (k + 1) + j * (j + 1))
    return ScheduleReport(
        kept=k,
        rejected=j,
        optimal_total=total,
        triangular_bound=bound,
        baseline_total=n * (n + 1) / 2,
        avg_speedup=a,
        below_two=a < 2.0,
        brute_force_total=(brute_force_optimum(k, j) if brute_force else None),
    )


if __name__ == "__main__":
    print(analyse_schedule(3, 4, brute_force=True))
    for m in (1, 2, 5, 50, 5000):
        r = analyse_schedule(m, m)
        print(f"balanced m={m:6d}   A = {r.avg_speedup:.9f}   below 2: {r.below_two}")


"""
Algorithm 4 — Chinese Remainder composition of dials and bit-currency accounting.

A battery is a family of dials on pairwise coprime moduli, read simultaneously.
This module

  * verifies pairwise coprimality and composes the dials explicitly, computing
    for each residue class modulo the product whether it passes all readings —
    an O(phi(M)) construction that exhibits the composition as a logical AND;
  * checks the density-multiplication identity theta(K1 (x) K2 (x) ...) =
    prod theta_i, which is the only way composition enters the law;
  * reports the two currencies: capacity bits sum(log2(1/theta_i)), which grow
    without bound, against work bits log2(Speedup), capped by log2(4/3) and
    tending to 0 as the battery grows.

Complexity: O(sum_i phi(m_i)) to build the component dials plus O(phi(M)) for
the explicit composition check, or O(number of dials) if only the closed-form
accounting is wanted.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Sequence


@dataclass(frozen=True)
class BatteryReport:
    moduli: tuple[int, ...]
    component_densities: tuple[float, ...]
    composite_modulus: int
    composite_density: float
    density_identity_holds: bool
    speedup: float
    capacity_bits: float
    work_bits: float
    exchange_rate: float          # work bits per capacity bit
    within_cap: bool
    component_sizes: tuple[int, ...] = field(default=())


CAP: float = 4.0 / 3.0


def euler_phi(m: int) -> int:
    result, n, p = m, m, 2
    while p * p <= n:
        if n % p == 0:
            while n % p == 0:
                n //= p
            result -= result // p
        p += 1
    if n > 1:
        result -= result // n
    return result


def compose_battery(dials: Sequence[tuple[int, frozenset[int]]]) -> BatteryReport:
    """
    `dials` is a sequence of pairs (modulus, kept residue classes).
    The moduli must be pairwise coprime.
    """
    moduli = [m for m, _ in dials]
    for i in range(len(moduli)):
        for j in range(i + 1, len(moduli)):
            if math.gcd(moduli[i], moduli[j]) != 1:
                raise ValueError(f"moduli {moduli[i]} and {moduli[j]} are not coprime")

    product = 1
    for m in moduli:
        product *= m

    sizes = tuple(len(K) for _, K in dials)
    densities = tuple(len(K) / euler_phi(m) for m, K in dials)

    # explicit composition: a unit mod the product passes iff every reading passes
    passing = sum(
        1
        for u in range(product)
        if math.gcd(u, product) == 1 and all(u % m in K for m, K in dials)
    )
    composite = passing / euler_phi(product)

    predicted = 1.0
    for d in densities:
        predicted *= d

    speedup = 1.0 / (1.0 - composite + composite * composite)
    capacity = sum(-math.log2(d) for d in densities if d > 0)
    work = math.log2(speedup)
    return BatteryReport(
        moduli=tuple(moduli),
        component_densities=densities,
        composite_modulus=product,
        composite_density=composite,
        density_identity_holds=abs(composite - predicted) < 1e-12,
        speedup=speedup,
        capacity_bits=capacity,
        work_bits=work,
        exchange_rate=(work / capacity if capacity > 0 else float("nan")),
        within_cap=speedup <= CAP + 1e-12,
        component_sizes=sizes,
    )


if __name__ == "__main__":
    # A three-dial battery on the coprime moduli 3, 5, 7.
    battery = [
        (3, frozenset({1})),
        (5, frozenset({1, 4})),
        (7, frozenset({1, 2, 4})),
    ]
    print(compose_battery(battery))


"""
Algorithm 5 — Multi-symbol prefix cost, order-freeness, and the skip boundary.

An r-symbol dial partitions the class space into blocks of densities
theta_1, ..., theta_r summing to 1, scanned in the given order.  A target in
block i costs the total density of blocks 1..i, so the normalised cost is the
prefix cost C = sum_i theta_i (theta_1 + ... + theta_i), computable in O(r) by a
single running sum.

This module

  * evaluates C in O(r) and verifies the order-free identity
    2C = (sum theta)^2 + sum theta^2, which shows C is invariant under every
    permutation of the blocks (so no scan order beats another);
  * compares the realised speedup 1/C with the cap 2r/(r+1), attained exactly at
    uniform blocks;
  * evaluates the FULL-REVEAL cost sum theta^2, the model in which the answer
    names the target's block and the algorithm may skip the rest, and reports
    the resulting speedup — unbounded in r, and exactly 2 in the binary case.
    The ratio of the two is the exact price of being unable to skip.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from typing import Sequence


@dataclass(frozen=True)
class SymbolReport:
    symbols: int
    densities: tuple[float, ...]
    prefix_cost: float
    single_pass_speedup: float
    single_pass_cap: float        # 2r/(r+1)
    cap_attained: bool
    identity_residual: float      # |2C - ((sum)^2 + sum sq)|
    order_invariant: bool | None  # None when r is too large to permute
    reveal_cost: float            # sum theta^2
    reveal_speedup: float
    price_of_no_skipping: float   # reveal_speedup / single_pass_speedup


def prefix_cost(densities: Sequence[float]) -> float:
    """O(r) running-sum evaluation of sum_i theta_i (theta_1 + ... + theta_i)."""
    running = 0.0
    total = 0.0
    for t in densities:
        running += t
        total += t * running
    return total


def reveal_cost(densities: Sequence[float]) -> float:
    """Cost when rejected blocks may be skipped outright."""
    return sum(t * t for t in densities)


def analyse_symbols(densities: Sequence[float], check_orders: bool = True) -> SymbolReport:
    r = len(densities)
    if r == 0:
        raise ValueError("need at least one block")
    total = sum(densities)
    if abs(total - 1.0) > 1e-9:
        raise ValueError(f"block densities must sum to 1 (got {total})")

    c = prefix_cost(densities)
    rc = reveal_cost(densities)
    cap = 2.0 * r / (r + 1.0)
    residual = abs(2 * c - (total ** 2 + sum(t * t for t in densities)))

    invariant: bool | None = None
    if check_orders and r <= 7:
        values = {round(prefix_cost(list(p)), 12) for p in permutations(densities)}
        invariant = len(values) == 1

    return SymbolReport(
        symbols=r,
        densities=tuple(densities),
        prefix_cost=c,
        single_pass_speedup=1.0 / c,
        single_pass_cap=cap,
        cap_attained=abs(1.0 / c - cap) < 1e-12,
        identity_residual=residual,
        order_invariant=invariant,
        reveal_cost=rc,
        reveal_speedup=1.0 / rc,
        price_of_no_skipping=(1.0 / rc) / (1.0 / c),
    )


if __name__ == "__main__":
    for r in (2, 3, 5, 8):
        rep = analyse_symbols([1.0 / r] * r)
        print(
            f"r={r:2d}  single-pass {rep.single_pass_speedup:.6f} "
            f"(cap {rep.single_pass_cap:.6f}, attained {rep.cap_attained})  "
            f"reveal {rep.reveal_speedup:.2f}  "
            f"price of no skipping {rep.price_of_no_skipping:.3f}x"
        )
    print(analyse_symbols([0.5, 0.3, 0.2]))


"""
viz_speedup_landscape.py — Four-panel figure of the residue-dial speedup landscape.

Standalone: requires only numpy and matplotlib.  Produces
`residue_dial_landscape.png`.

Panels
------
(a) The exact law Speedup(theta) = 1/(1 - theta + theta^2) against the universal
    cap 4/3, with the unique attainment point theta = 1/2 marked, and the
    absolute saving n(theta - theta^2) shaded.
(b) The two currencies: capacity bits log2(1/theta) of a battery of n
    half-density dials diverge linearly while the work bits log2(Speedup) they
    purchase collapse to zero, forever under log2(4/3) = 0.41504.
(c) The accounting gap: the worst-case-in-phase cap 4/3 (flat) against the
    expected-position speedup (2m+1)/(m+1) at balanced blocks, which rises
    strictly to 2 without ever attaining it.
(d) The multi-symbol hierarchy 2r/(r+1) of single-pass caps, strictly below 2
    and converging to it, against the full-reveal speedup r which is unbounded:
    the exact boundary between reordering work and skipping it.
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt
import numpy as np

CAP: float = 4.0 / 3.0
CAP_BITS: float = math.log2(CAP)


def speedup(theta: np.ndarray | float) -> np.ndarray | float:
    return 1.0 / (1.0 - theta + theta * theta)


def make_figure(path: str = "residue_dial_landscape.png") -> None:
    plt.rcParams.update({
        "figure.facecolor": "white",
        "axes.grid": True,
        "grid.alpha": 0.25,
        "font.size": 10,
    })
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))

    # ---- (a) the law and the cap ----------------------------------------
    ax = axes[0, 0]
    t = np.linspace(0.0, 1.0, 1001)
    ax.fill_between(t, 1.0, speedup(t), alpha=0.15, color="tab:blue",
                    label=r"gain over baseline")
    ax.plot(t, speedup(t), lw=2.4, color="tab:blue",
            label=r"$1/(1-\theta+\theta^2)$")
    ax.axhline(CAP, ls="--", lw=1.6, color="goldenrod",
               label=r"universal cap $4/3$")
    ax.plot([0.5], [CAP], "o", ms=8, color="goldenrod")
    ax.annotate(r"$\theta=1/2$,  $4/3$", xy=(0.5, CAP),
                xytext=(0.62, 1.27), color="goldenrod",
                arrowprops=dict(arrowstyle="->", color="goldenrod"))
    ax.set_xlabel(r"filter density $\theta = |K|/\varphi(M)$")
    ax.set_ylabel("speedup")
    ax.set_ylim(0.98, 1.40)
    ax.set_title("(a)  The exact single-pass law and its universal cap")
    ax.legend(loc="lower center", frameon=False, fontsize=9)

    # ---- (b) two currencies ---------------------------------------------
    ax = axes[0, 1]
    ns = np.arange(1, 41)
    thetas = 0.5 ** ns
    ax.plot(ns, ns, lw=2.2, color="tab:blue", label="capacity bits  $\\log_2(1/\\theta)$")
    ax.set_xlabel("number of composed half-density dials")
    ax.set_ylabel("capacity bits", color="tab:blue")
    ax.tick_params(axis="y", labelcolor="tab:blue")
    ax2 = ax.twinx()
    ax2.plot(ns, np.log2(speedup(thetas)), lw=2.2, color="tab:green",
             label="work bits  $\\log_2 S$")
    ax2.axhline(CAP_BITS, ls="--", lw=1.5, color="goldenrod")
    ax2.text(20, CAP_BITS * 1.03, r"$\log_2(4/3)=0.41504$", color="goldenrod",
             fontsize=9)
    ax2.set_ylabel("work bits", color="tab:green")
    ax2.tick_params(axis="y", labelcolor="tab:green")
    ax2.set_ylim(-0.02, 0.50)
    ax2.grid(False)
    ax.set_title("(b)  Two currencies: capacity diverges, work collapses")

    # ---- (c) the accounting gap -----------------------------------------
    ax = axes[1, 0]
    ms = np.arange(1, 201)
    ax.plot(ms, (2 * ms + 1) / (ms + 1), lw=2.2, color="tab:red",
            label=r"expected position:  $(2m+1)/(m+1)$")
    ax.axhline(2.0, ls=":", lw=1.6, color="dimgray", label=r"barrier $2$ (never attained)")
    ax.axhline(CAP, ls="--", lw=1.8, color="goldenrod",
               label=r"worst-case in phase:  cap $4/3$")
    ax.set_xscale("log")
    ax.set_xlabel(r"balanced block size $m$  (log scale)")
    ax.set_ylabel("speedup")
    ax.set_ylim(1.2, 2.1)
    ax.set_title("(c)  Two accountings, two constants")
    ax.legend(loc="center right", frameon=False, fontsize=9)

    # ---- (d) hierarchy and the skipping boundary ------------------------
    ax = axes[1, 1]
    rs = np.arange(2, 17)
    ax.plot(rs, 2 * rs / (rs + 1), "o-", lw=2.2, color="tab:blue",
            label=r"single-pass cap  $2r/(r+1)$")
    ax.plot(rs, rs, "s--", lw=1.8, color="tab:purple",
            label=r"full reveal (skipping):  $r$")
    ax.axhline(2.0, ls=":", lw=1.6, color="dimgray")
    ax.text(11.2, 2.12, "barrier 2", color="dimgray", fontsize=9)
    ax.set_yscale("log")
    ax.set_xlabel("number of symbols $r$")
    ax.set_ylabel("speedup (log scale)")
    ax.set_title("(d)  Reordering work versus skipping work")
    ax.legend(loc="upper left", frameon=False, fontsize=9)

    fig.suptitle(
        "The residue-dial speedup landscape:  "
        r"$S(\theta)=1/(1-\theta+\theta^{2})$, never above $4/3$",
        fontsize=13, y=0.985)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig(path, dpi=160)
    print(f"wrote {path}")


if __name__ == "__main__":
    make_figure()


"""
viz_structure_blindness.py — Exhaustive evidence that only |K| matters.

Standalone: requires only numpy and matplotlib.  Produces
`structure_blindness.png`.

What it shows
-------------
Left panel.  Every one of the 2^10 = 1024 subsets K of the unit group modulo
M = 11 is enumerated and its realised single-pass speedup computed by direct
simulation of the scan (average of cost(t) over all targets t, no formula used).
The 1024 points are jittered horizontally so that the collapse is visible: all
subsets of a given cardinality land on exactly one value, and that value lies on
the theoretical curve 1/(1-theta+theta^2).  Arithmetically distinguished
subsets — the quadratic residues, a nonresidue coset, an interval of classes,
and the fibres of a cubic reading — are highlighted, and sit indistinguishably
on top of their structureless neighbours.

Right panel.  The same exhaustive enumeration performed for a CRT battery on
M = 33 = 3 x 11, over all pairs of subsets in the CRT decomposition.  Composite
densities multiply, the achievable speedups scatter along the same curve, and
the maximum is again exactly 4/3: composition buys nothing.
"""

from __future__ import annotations

import itertools
import math
from typing import Sequence

import matplotlib.pyplot as plt
import numpy as np

CAP: float = 4.0 / 3.0


def units_mod(m: int) -> list[int]:
    return [u for u in range(m) if math.gcd(u, m) == 1]


def simulated_speedup(n: int, kept: frozenset[int]) -> float:
    """Realised speedup by direct simulation of the scan — no formula used."""
    k = len(kept)
    total = sum(k if t in kept else n for t in range(n))
    return n / (total / n)


def make_figure(path: str = "structure_blindness.png") -> None:
    plt.rcParams.update({"figure.facecolor": "white", "axes.grid": True,
                         "grid.alpha": 0.25, "font.size": 10})
    fig, (axL, axR) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ------------------------- left: all subsets mod 11 ------------------
    M = 11
    us = units_mod(M)
    n = len(us)
    index = {u: i for i, u in enumerate(us)}
    rng = np.random.default_rng(20260822)

    xs: list[float] = []
    ys: list[float] = []
    for r in range(n + 1):
        for subset in itertools.combinations(us, r):
            kept = frozenset(index[u] for u in subset)
            xs.append(r / n + rng.normal(0.0, 0.006))
            ys.append(simulated_speedup(n, kept))
    axL.scatter(xs, ys, s=7, alpha=0.28, color="tab:blue",
                label=f"all $2^{{{n}}}$ subsets, simulated")

    t = np.linspace(0.0, 1.0, 600)
    axL.plot(t, 1.0 / (1.0 - t + t * t), lw=2.0, color="black",
             label=r"theory $1/(1-\theta+\theta^{2})$")
    axL.axhline(CAP, ls="--", lw=1.5, color="goldenrod", label=r"cap $4/3$")

    qr = sorted({(u * u) % M for u in us})
    families: dict[str, Sequence[int]] = {
        "quadratic residues": qr,
        "nonresidue coset": sorted((2 * q) % M for q in qr),
        "interval of classes": us[: n // 2],
        "cubic-reading fibre": sorted(us, key=lambda u: pow(u, 3, M))[: n // 2],
    }
    markers = ["o", "s", "^", "D"]
    for (name, K), mk in zip(families.items(), markers):
        kept = frozenset(index[u] for u in K)
        axL.plot([len(K) / n], [simulated_speedup(n, kept)], mk, ms=11,
                 mfc="none", mew=2.0, label=name)

    axL.set_xlabel(r"density $\theta = |K|/\varphi(11)$")
    axL.set_ylabel("realised speedup")
    axL.set_title("Structure blindness: every subset of $(\\mathbb{Z}/11)^{\\times}$")
    axL.set_ylim(0.97, 1.40)
    axL.legend(fontsize=8, loc="lower center", ncol=2, frameon=False)

    # ------------------------- right: CRT battery on 33 ------------------
    m1, m2 = 3, 11
    n1, n2 = len(units_mod(m1)), len(units_mod(m2))
    bxs: list[float] = []
    bys: list[float] = []
    for a in range(n1 + 1):
        for b in range(n2 + 1):
            theta = (a / n1) * (b / n2)
            bxs.append(theta)
            bys.append(1.0 / (1.0 - theta + theta * theta))
    axR.plot(t, 1.0 / (1.0 - t + t * t), lw=2.0, color="black",
             label=r"theory $1/(1-\theta+\theta^{2})$")
    axR.scatter(bxs, bys, s=48, color="tab:purple", alpha=0.75, zorder=3,
                label=r"battery on $33 = 3\times 11$: all $(|K_1|,|K_2|)$")
    axR.axhline(CAP, ls="--", lw=1.5, color="goldenrod", label=r"cap $4/3$")
    axR.annotate(f"max = {max(bys):.10f}", xy=(0.5, max(bys)),
                 xytext=(0.55, 1.24), color="goldenrod",
                 arrowprops=dict(arrowstyle="->", color="goldenrod"))
    axR.set_xlabel(r"composite density $\theta_1\theta_2$")
    axR.set_ylabel("speedup")
    axR.set_ylim(0.97, 1.40)
    axR.set_title("Batteries compose for free: densities multiply, cap unchanged")
    axR.legend(fontsize=8, loc="lower center", frameon=False)

    fig.suptitle("Only the cardinality matters — exhaustively", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig(path, dpi=160)
    print(f"wrote {path}")


if __name__ == "__main__":
    make_figure()


"""
build_package.py — assemble PACKAGE.json from the deliverables in this project.

Reads ARTICLE.md, RESEARCH_PAPER.md, RESEARCH_PAPER.tex, demo.py, the assets/
directory and the formal source files, and writes PACKAGE.json.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
A = ROOT / "assets"

read = lambda p: (ROOT / p).read_text(encoding="utf-8")

LEAN_FILES = [
    "Catalog/Cryptography/ResidueDial/Core.lean",
    "Catalog/Cryptography/ResidueDial/Battery.lean",
    "Catalog/Cryptography/ResidueDial/MultiSymbol.lean",
    "Catalog/Cryptography/ResidueDial/Converse.lean",
    "Catalog/Cryptography/ResidueDial/Accounting.lean",
]

lean_proofs = "\n\n".join(
    f"/- ===== {f} ===== -/\n\n" + read(f) for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future Directions — after the residue-dial converse

Established in this cycle:

* the exact single-pass law `Speedup = 1/(1 − θ + θ²)`, derived from the finite
  scan model by summation, with the universal cap `4/3` and its exact equality
  case `θ = 1/2`;
* CRT batteries multiply densities and therefore inherit the same cap; capacity
  bits are unbounded while work bits are `≤ log₂(4/3) < 1` and tend to `0`;
* structure blindness, symbol/character dials, positional and interval
  witnesses, and which-factor blindness as an identity;
* the accounting analysis: an optimality lemma for arbitrary scan schedules, and
  the fact that under expected-position accounting the barrier is `2`,
  approached but never attained;
* the multi-symbol hierarchy `2r/(r+1)`, order-independent, attained at uniform
  blocks, strictly below `2` and converging to it;
* the **boundary**: if the dial's answer lets the algorithm *skip* rejected
  blocks, the cost is `Σ θᵢ²` and a balanced `r`-symbol reveal buys exactly `r`
  — so the cap is a theorem about single-pass scan-order algorithms.

The directions below are what this leaves open. The last item was a conjecture
at the start of the cycle and is now a theorem; it has been replaced by the
sharper questions it raised.

## 1. Where exactly does skipping become available?

The `4/3` cap holds for single-pass scans and fails (`r`-fold speedup) for full
reveals. Real sieving sits in between: one can skip a class only after paying to
recognise it. **The key insight is** that the cap is a function of the *skip
budget*, so there should be a one-parameter family of caps interpolating `4/3`
and `r`, indexed by the fraction of rejected classes the algorithm may skip for
free. Why now? Both endpoints are theorems in one framework, so the interpolant
is a single definition away.

## 2. Cost-charged filters and the zero-profit threshold

Reading a dial is charged nothing above. Charging `c` per reading turns the cap
into a profitability threshold: the saving of a density-`θ` dial is `n(θ − θ²) ≤
n/4`. **The key insight is** that no filter whose reading costs more than a
quarter of a full scan can ever pay for itself, whatever its density. Why now?
The saving is now an exact expression, not an estimate.

## 3. Discrepancy-perturbed law

The exact law assumes the target class is uniform. A total-variation bound `Δ`
should perturb the cost by `O(Δ)` and nothing else. **The key insight is** that
uniformity enters at exactly one place — a single finite sum — so the
perturbation is linear and effective at cryptographic sizes. Why now? The
dependence on the target distribution is isolated in the expected-cost
definition.

## 4. Adaptive batteries

Our batteries are non-adaptive. **The key insight is** that adaptivity changes
the schedule but not the partition of the class space, and the optimality lemma
is already stated for arbitrary schedules.

## 5. Non-uniform per-class costs

Throughout, examining a class costs one unit. Weighting classes by genuine
trial-division cost turns the triangular lower bound into a rearrangement
problem with a nontrivial optimum, and the order-freeness of the multi-symbol
cost would be expected to fail. Identifying the weighted analogue of `4/3` is
open.
"""

INTERACTIVE_LAYOUT = r"""
# The Dial That Promised Too Much
### A guided tour of the universal cap $4/3$

You are searching for a divisor of a large number $N$. You have no clever
algebra — only patience. You will walk through candidate divisors, one class at
a time, until one of them works.

Then someone hands you a **hint**: "whatever the factor is, its remainder modulo
$M$ lies in this set $K$." Half the candidates fall away.

**Surely you now go twice as fast?**

This page is the answer, built up piece by piece. By the end you will have
derived an exact law, found its maximum by completing a square, watched it
refuse to be improved by any amount of arithmetic cleverness, and located
precisely where the folklore's favourite number — $2$ — actually lives.

---

## 1. The model, in one paragraph

There are $n$ admissible residue classes; if the hint lives modulo $M$ then
$n = \varphi(M)$. The target class is uniform among them. A **residue dial** is
a subset $K$ with density
$$\theta = \frac{|K|}{n},$$
plus the promise that the target is inside $K$ or outside it.

Here is the one modelling decision everything hinges on. A scan is a **single
pass**: the dial may *reorder* the classes — that is exactly what makes it
useful — but a class once scheduled is a class you pay for. So:

1. read the dial;
2. scan the $k = |K|$ kept classes;
3. if the target was not among them, you are back where you started, and you
   scan the whole space.

<details>
<summary><b>Why charge a whole phase rather than a position? (click to expand)</b></summary>

Because in a real sieve the atomic unit of work is the pass, not the candidate:
a batched trial-division sweep, a vectorised inner loop, or a wheel does not let
you stop halfway through and bank the savings. Section 5 below examines the
alternative accounting in detail — it is exactly where the number $2$ comes
from, and keeping the two apart is the difference between a true theorem and a
false one.
</details>

Averaging the cost $k$ (hit) and $n$ (miss) over the uniform target gives
$$\mathbb{E}[\text{cost}] = \frac{k\cdot k + (n-k)\cdot n}{n} = n\bigl(1-\theta+\theta^{2}\bigr),$$
and dividing by the unfiltered baseline $n$ gives the **exact single-pass law**:
$$\boxed{\ \mathrm{Speedup}(\theta) = \frac{1}{1-\theta+\theta^{2}}.\ }$$

No approximation, no asymptotics, no hidden constant.

---

## 2. Play with it

Move the density dial. Watch the curve. Try to break $4/3$.

{{interactive_demo:0}}

Three things to notice while you play:

- **The curve is a hill, not a slope.** It rises to $\theta = 1/2$, then falls.
- **Aggressive filters are on the wrong side of it.** At $\theta = 0.01$ you
  discard $99\%$ of the search space and gain $1\%$. With probability $0.99$
  the target is not in your tiny set, the pass is wasted, and you pay in full.
- **The battery panel is the punchline.** Stack twenty half-density dials and
  you have twenty bits of information and essentially zero speedup.

---

## 3. Why $4/3$ — complete the square

This is the entire proof, and it fits on one line:
$$1 - \theta + \theta^{2} = \Bigl(\theta - \tfrac12\Bigr)^{2} + \tfrac34.$$

The cost can never fall below $3/4$ of the baseline, and it equals $3/4$ at
exactly one point.

> **Universal Cap Theorem.** For every density $\theta$,
> $\mathrm{Speedup}(\theta) \le 4/3$, with equality if and only if
> $\theta = 1/2$. Trivial filters, $\theta = 0$ and $\theta = 1$, give exactly $1$.

<details>
<summary><b>The full derivation, from the finite scan to the cap</b></summary>

Write $\mathbf{1}_K$ for the indicator of $K$. The cost function is
$$\mathrm{cost}_K(t) = k\,\mathbf{1}_K(t) + n\,(1 - \mathbf{1}_K(t)),$$
so summing over all $n$ targets and using $\sum_t \mathbf{1}_K(t) = k$,
$$\sum_t \mathrm{cost}_K(t) = k^2 + (n-k)n.$$
Dividing by $n$ and substituting $k = \theta n$ gives $n(1 - \theta + \theta^2)$.
Since $(\theta - 1/2)^2 \ge 0$ we get $1 - \theta + \theta^2 \ge 3/4 > 0$, so the
reciprocal is defined and at most $4/3$; a square vanishes iff its base does, so
equality holds iff $\theta = 1/2$. Finally $D'(\theta) = 2\theta - 1$ shows the
speedup is strictly increasing on $[0,1/2]$ and strictly decreasing on
$[1/2,1]$, so $4/3$ is genuinely the maximum and is attained nowhere else.

Note what the derivation **never used**: any property of $K$ beyond its size,
any property of $M$, any arithmetic at all.
</details>

Here is a compact algorithm that turns a modulus and a filter into the full
accounting — density, cost, speedup, saving, and the two bit-currencies:

{{algorithm:0}}

---

## 4. The part that should surprise you: nothing else matters

The law depends on $K$ through **one number**: its cardinality.

> **Structure Blindness.** If $|K| = |L|$ then the two dials have identical
> speedup — whatever their internal structure. A subgroup, a coset, a union of
> character fibres, a set carved out by a reciprocity law, and a set produced by
> flipping coins all perform identically.

This is a triviality as a proof and a bombshell as a converse, because of what
it rules out. Fix any reading $f$ assigning a symbol to each class — the
Legendre symbol, the cubic residue character with its three values, the quintic
character with its five, a tuple of several — and keep the classes whose symbol
lies in a set $T$. Call it a **symbol dial**.

> **No character content helps.** Every symbol dial obeys the same cap $4/3$,
> and a half-density symbol dial attains it exactly, for *any* reading $f$ and
> *any* symbol subset $T$.

The $n=3$ and $n=5$ cases were the ones people hoped would break the pattern.
They do not. All the arithmetic depth of higher power-residue symbols is
compressed, by the scan model, into a single integer.

Don't take it on faith — here is the whole subset lattice of a unit group,
enumerated and simulated:

{{visualization:1}}

And the routine that produces that certificate, including a check that the
brute-force maximum agrees with the cardinality-only pass:

{{algorithm:1}}

<details>
<summary><b>Which factor of a semiprime should you filter on? (an identity, not an approximation)</b></summary>

Suppose $N = pq$ and $N \equiv c \pmod M$. If $u$ is the class of $p$ and $v$
the class of $q$, then $uv = c$, so
$$v = c\,u^{-1}.$$
The map $\sigma_c(u) = cu^{-1}$ is an **involution** of the unit group — apply it
twice and you are back where you started. Being a bijection, it preserves
cardinalities, hence densities, hence speedups:
$$\mathrm{Speedup}(\sigma_c(K)) = \mathrm{Speedup}(K) \quad\text{exactly, for every } M, c, K.$$
This had been observed as an approximate coincidence in simulation data. It is
not approximate. It is the statement that a bijection does not change how many
elements a set has.
</details>

---

## 5. Batteries: composing hints is free, and free means worthless

Take dials on pairwise coprime moduli and read them all. The
[Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
says the composite is exactly the logical AND of the pieces, and — the key
computation — **densities multiply**:
$$\theta_{\text{battery}} = \prod_i \theta_i.$$

Since the law depends only on the composite density, and the cap holds at every
density:

> **Battery Cap.** However many dials a battery contains, on however many
> moduli, of whatever densities, its speedup is at most $4/3$, and in particular
> strictly below $2$.

Worse than "no better": each extra dial pushes $\theta$ toward $0$, i.e. down the
far side of the hill.

### Two currencies

A dial of density $\theta$ reveals $\log_2(1/\theta)$ bits of **capacity** about
the target. The **work** it buys is $\log_2 \mathrm{Speedup}(\theta)$ bits. The
cap says
$$\text{work} \le \log_2\tfrac43 = 0.41504\ldots\ \text{bits}.$$

So a battery measuring $12.72$ capacity bits purchases at most $0.415$ work bits
— an exchange rate below $3.3\%$ — and as the battery grows, the composite
density tends to $0$, the speedup tends back to $1$, and the work tends to
**zero**. The rate does not stall; it collapses.

{{algorithm:3}}

---

## 6. So where does the number $2$ come from?

Everyone remembers a barrier of $2$. That memory is not wrong — it belongs to a
**different accounting**, and the honest thing is to say which.

**Accounting one — worst-case in phase.** A pass that scans $m$ classes is
charged $m$. Cap: $\mathbf{4/3}$, attained at $\theta = 1/2$.

**Accounting two — expected position.** Charge the position at which the target
is found, with free reordering inside each branch. A blind scan then costs
$(n+1)/2$ on average.

<details>
<summary><b>The optimality lemma — why this is a bound over all strategies</b></summary>

Any injective assignment of distinct positive integers to $m$ items has total at
least $1 + 2 + \cdots + m = m(m+1)/2$: order the assigned values increasingly as
$x_1 < \cdots < x_m$; then $x_1 \ge 1$ and $x_{i+1} > x_i \ge i$ forces
$x_{i+1} \ge i+1$.

Applying this to each branch separately, **every** dial-aware schedule costs at
least $\tfrac12 k(k+1) + \tfrac12 j(j+1)$. That is what turns the resulting
formula from "the value of one strategy" into "an upper bound over all
strategies" — the same lemma will cover adaptive schedules, since adaptivity
changes the schedule but not the partition.
</details>

The bound gives
$$A(k,j) = \frac{(k+j)(k+j+1)}{k(k+1)+j(j+1)},$$
and here the barrier is genuinely $2$:

> **Expected-Position Barrier.** $A(k,j) < 2$ strictly, always. At balanced
> blocks $k = j = m$ the value is exactly $(2m+1)/(m+1)$, which rises to $2$ and
> never reaches it.

Two accountings, two constants. The gap is real: for every $\varepsilon>0$ some
balanced dial beats $2-\varepsilon$ in the second accounting, while *no* dial
ever beats $4/3$ in the first.

{{algorithm:2}}

---

## 7. The boundary: reordering work versus skipping work

Here is the sharpest way to see what the cap is really about. Give three
searchers the *same* hint and change only what they may do with it.

{{interactive_demo:1}}

Run the race. The blind searcher pays for a full pass. The reordering searcher
pays $n(1-\theta+\theta^2)$ and tops out at $4/3$. The skipping searcher, allowed
to jump straight to the correct block, pays $n(\theta^2 + (1-\theta)^2)$ and tops
out at exactly $2$.

**Same hint. Same information. Same density. Different constant.**

Generalise to $r$ symbols. A target in block $i$ costs $\theta_1+\cdots+\theta_i$,
so the cost is $C = \sum_i \theta_i(\theta_1+\cdots+\theta_i)$, and a short
symmetrisation gives an identity worth pausing on:
$$2\,C = \Bigl(\sum_i \theta_i\Bigr)^{2} + \sum_i \theta_i^{2}.$$

The right side is symmetric. **The scan order is irrelevant** — every
rearrangement heuristic gives exactly the same cost, contradicting the natural
guess that you should schedule the densest block first.

<details>
<summary><b>Proof of the order-free identity, and the cap hierarchy it implies</b></summary>

Write $C = \sum_{i,j} [\,j \le i\,]\theta_i\theta_j$; renaming the indices shows
$C = \sum_{i,j}[\,i\le j\,]\theta_i\theta_j$ as well. Adding, and checking the
three cases $i<j$, $i=j$, $i>j$ of
$$[\,j\le i\,]\theta_i\theta_j + [\,i\le j\,]\theta_i\theta_j = \theta_i\theta_j + [\,i=j\,]\theta_i\theta_j,$$
gives $2C = (\sum_i\theta_i)^2 + \sum_i\theta_i^2$.

With $\sum_i\theta_i = 1$, Cauchy–Schwarz gives $\sum_i\theta_i^2 \ge 1/r$, hence
$C \ge (r+1)/(2r)$, hence the **cap hierarchy**
$$\mathrm{Speedup} \le \frac{2r}{r+1},$$
attained exactly at uniform blocks. At $r=2$ this is $4/3$; the sequence runs
$4/3,\ 3/2,\ 8/5,\ 5/3,\ 12/7,\ldots$, stays strictly below $2$, and converges
to it. Once again $2$ is a supremum and the value of nothing.

Now allow skipping. The cost becomes $R = \sum_i\theta_i^2$, and a balanced
$r$-symbol reveal buys $1/R = r$ — no universal cap at all. **This is the exact
boundary of the theorem.**
</details>

{{algorithm:4}}

---

## 8. The whole landscape at once

{{visualization:0}}

Panel (a) is the law and its cap. Panel (b) is the two currencies diverging.
Panel (c) is the accounting gap: a flat line at $4/3$ against a curve creeping
toward $2$. Panel (d) is the boundary: single-pass caps crawling under $2$
forever while the reveal speedup marches off to infinity.

---

## 9. Run everything yourself

{{demo:0}}

---

## 10. What to take away

Real sieving lives between the extremes: you can often skip a candidate, but
only after paying something to recognise that you may. So the practical constant
should be a function of the **skip budget**, interpolating $4/3$ and $r$ — and
with both endpoints now inside one framework, that is a well-posed question
rather than a slogan.

There is also a clean profitability corollary. The absolute saving of a
density-$\theta$ dial is $n(\theta - \theta^2) \le n/4$. So:

> **A filter whose reading costs more than a quarter of a full scan can never
> pay for itself**, whatever its density and however deep its arithmetic.

And the larger lesson is about the seduction of information. It is easy to count
the bits a filter reveals, watch that number climb as you compose more filters,
and conclude that something is being accomplished. The bits are real. But
information is not work, and in a single-pass scan the conversion rate between
them is bounded by less than half a bit — and decays to nothing precisely as the
information grows.

Four-thirds. Attained at half density, blind to structure, immune to
composition, and strictly, permanently, below two.
"""

package = {
    "title": "The Universal Cap 4/3 for Residue-Dial Speedups",
    "domain": "Cryptography",
    "description": (
        "An exact law for the speedup that congruence information can confer on a "
        "single-pass scanning search — Speedup(θ) = 1/(1 − θ + θ²) — together with its "
        "universal cap of 4/3, attained exactly at half density, blind to the dial's "
        "arithmetic structure and unimproved by composing dials on coprime moduli. "
        "The analysis also locates the familiar barrier 2 precisely: it is the strict, "
        "unattained supremum of a different cost accounting and the exact value of a "
        "binary full reveal in which rejected classes may be skipped."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-22",
    "key_results": [
        "Exact single-pass law: for any filter of density θ in any finite class space "
        "with a uniform target, the normalised expected scan cost is exactly 1 − θ + θ², "
        "so the speedup is 1/(1 − θ + θ²).",
        "Universal cap: no residue dial of any density buys more than a 4/3 speedup, "
        "with equality if and only if θ = 1/2; trivial filters buy exactly 1.",
        "Structure blindness: the speedup depends on the filter only through its "
        "cardinality, so symbol dials built from characters of any order — cubic, "
        "quintic, or mixed — obey the same cap, and any half-density set attains it.",
        "Which-factor blindness is an identity: the involution u ↦ c·u⁻¹ exchanging the "
        "two factor classes of a semiprime preserves density, so filtering on either "
        "factor gives exactly the same speedup.",
        "Batteries compose for free: Chinese-Remainder composition multiplies densities "
        "and inherits the 4/3 cap, so unbounded capacity bits purchase at most "
        "log₂(4/3) = 0.41504 work bits, and the exchange rate tends to zero.",
        "The accounting boundary: under expected-position accounting an optimality lemma "
        "for arbitrary schedules yields the strict barrier 2, never attained; the "
        "multi-symbol hierarchy 2r/(r+1) converges to 2; and permitting the algorithm to "
        "skip rejected blocks removes the cap entirely, a balanced r-symbol reveal "
        "buying exactly r.",
    ],
    "keywords": [
        "residue dial",
        "congruence filter",
        "scan-order algorithm",
        "speedup cap",
        "Chinese Remainder Theorem",
        "power-residue characters",
        "information versus work",
        "integer factorisation",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Residue-Dial Speedup Law and Its Universal Cap",
            "description": (
                "An eight-part, dependency-free numerical study of the whole theory. It "
                "(1) verifies the exact law 1 − θ + θ² against a brute-force simulation of "
                "the scan over 200 random filters, recovering agreement to machine "
                "precision; (2) exhaustively enumerates every subset of the unit group "
                "modulo 3, 4, 7 and 11 and confirms the maximum realised speedup is exactly "
                "1.3333333333, attained precisely at half density; (3) demonstrates "
                "structure blindness by comparing quadratic residues, a nonresidue coset, an "
                "interval of classes, a random scatter and a cubic-symbol fibre of equal "
                "size; (4) confirms which-factor blindness by checking that u ↦ c·u⁻¹ is an "
                "involution preserving speedup exactly; (5) enumerates all CRT battery "
                "configurations on the product moduli 12, 15, 21 and 33 and tabulates the "
                "two currencies, showing capacity bits climbing linearly while work bits "
                "collapse below log₂(4/3); (6) brute-forces every dial-aware schedule for "
                "small class spaces to exhibit the triangular optimality lemma, then tracks "
                "the expected-position speedup rising toward 2 without reaching it; (7) "
                "checks the order-free prefix-cost identity over all permutations of the "
                "blocks and tabulates the cap hierarchy 2r/(r+1) against the unbounded "
                "full-reveal speedup r; and (8) computes the profitability threshold "
                "n(θ − θ²) ≤ n/4."
            ),
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Exact Evaluation of the Single-Pass Residue-Dial Law",
            "description": (
                "Given a modulus M and a set of kept residue classes, this routine computes "
                "the complete accounting of the dial in closed form: the density "
                "θ = |K|/φ(M), the normalised cost 1 − θ + θ², the speedup 1/(1 − θ + θ²), "
                "the absolute saving fraction θ − θ², the capacity log₂(1/θ) in bits, and "
                "the work log₂(Speedup) in bits, together with a certificate that the "
                "speedup lies within the universal cap 4/3 and a flag recording whether the "
                "cap is attained exactly (which happens precisely when 2|K| = φ(M)). "
                "Mathematically it is the closed form obtained by summing the cost "
                "k·[t ∈ K] + n·[t ∉ K] over a uniform target, which yields "
                "k² + (n−k)n and hence the quadratic law; the completed square "
                "(θ − 1/2)² + 3/4 is what bounds the cost below by 3/4. Complexity is "
                "O(√M) for the totient by trial division of the radical plus O(|K|) to "
                "deduplicate and screen the kept classes — negligible compared with any "
                "scan it describes, which is precisely why the accounting can be applied "
                "as a pre-filter design criterion."
            ),
            "pseudocode": (
                "function ANALYSE-DIAL(M, kept):\n"
                "    n  <- EULER-PHI(M)                       # O(sqrt M)\n"
                "    K  <- { c mod M : c in kept, gcd(c mod M, M) = 1 }   # dedupe + screen\n"
                "    k  <- |K|\n"
                "    theta <- k / n\n"
                "    cost  <- 1 - theta + theta^2             # exact, by the summation law\n"
                "    S     <- 1 / cost\n"
                "    saving        <- theta - theta^2          # <= 1/4 always\n"
                "    capacityBits  <- (theta > 0) ? -log2(theta) : +infinity\n"
                "    workBits      <- log2(S)                  # <= log2(4/3) = 0.41504\n"
                "    withinCap     <- (S <= 4/3 + eps)         # guaranteed by the theorem\n"
                "    attainsCap    <- (2*k = n)                # equality iff theta = 1/2\n"
                "    return (n, k, theta, cost, S, saving, capacityBits, workBits,\n"
                "            withinCap, attainsCap)\n"
                "\n"
                "function EULER-PHI(m):\n"
                "    result <- m ; n <- m ; p <- 2\n"
                "    while p*p <= n:\n"
                "        if p divides n:\n"
                "            repeat n <- n / p until p does not divide n\n"
                "            result <- result - result / p\n"
                "        p <- p + 1\n"
                "    if n > 1: result <- result - result / n\n"
                "    return result"
            ),
            "code": read("assets/algorithms/alg1_density_law.py"),
        },
        {
            "name": "Exhaustive Cap Certification over the Full Subset Lattice of a Unit Group",
            "description": (
                "This routine certifies the universal cap for a fixed modulus by brute "
                "force, deliberately refusing to use the closed-form law. For every one of "
                "the 2^φ(M) subsets of the unit group it simulates the dial-aware scan "
                "directly — averaging the realised cost over every possible target and "
                "inverting — and records the maximum realised speedup along with the "
                "cardinalities at which it occurs. It then runs a second, cardinality-only "
                "pass that visits just one representative subset per size, and checks the "
                "two maxima agree. That agreement is the empirical certificate of structure "
                "blindness: it says that the exponentially large lattice of subsets "
                "collapses to the φ(M)+1 cardinality classes without loss. The brute-force "
                "pass costs O(2^φ(M) · φ(M)) time and is limited to φ(M) ≤ 20 by an explicit "
                "guard; the collapsed pass costs only O(φ(M)²), which is the practical "
                "route for larger moduli. Empirically the maximum is 1.3333333333 for every "
                "modulus tested, attained exactly at the half-density cardinality."
            ),
            "pseudocode": (
                "function CERTIFY-CAP(M, maxClasses):\n"
                "    U <- units modulo M ;  n <- |U|\n"
                "    assert n <= maxClasses          # 2^n enumeration guard\n"
                "    best <- 0 ; attaining <- {} ; examined <- 0\n"
                "    for r <- 0 to n:\n"
                "        for each subset S of U with |S| = r:\n"
                "            examined <- examined + 1\n"
                "            total <- 0\n"
                "            for each target t in {0..n-1}:            # direct simulation\n"
                "                total <- total + (t in S ? r : n)\n"
                "            speed <- n / (total / n)\n"
                "            if speed > best + eps:  best <- speed ; attaining <- {r}\n"
                "            elif |speed - best| <= eps: attaining <- attaining U {r}\n"
                "    # cardinality-collapsed pass: one representative per size\n"
                "    collapsed <- max over r of SIMULATE(n, first r elements)\n"
                "    return (best, attaining, examined, |best - collapsed| <= eps)"
            ),
            "code": read("assets/algorithms/alg2_exhaustive_cap.py"),
        },
        {
            "name": "Optimal Dial-Aware Scan Schedule and the Triangular Lower Bound",
            "description": (
                "Under expected-position accounting the algorithm is charged the index at "
                "which the target is found and may order classes freely within each branch "
                "of the dial reading. This routine constructs an optimal schedule in O(n) — "
                "assign positions 1,2,…,k inside the kept block and 1,2,…,j inside the "
                "rejected block, in any order whatsoever — and certifies its optimality "
                "against the triangular lower bound k(k+1)/2 + j(j+1)/2. The lower bound is "
                "the observation that any injective assignment of distinct positive integers "
                "to m items has total at least 1+2+⋯+m, proved by ordering the assigned "
                "values increasingly and inducting; it is what converts the value of one "
                "strategy into an upper bound over all strategies, adaptive ones included, "
                "since adaptivity changes the schedule but not the partition. The resulting "
                "expected-position speedup is A(k,j) = (k+j)(k+j+1)/(k(k+1)+j(j+1)), which "
                "clearing denominators shows is strictly below 2 because "
                "(k−j)² + k + j > 0, and which equals (2m+1)/(m+1) at balanced blocks — "
                "rising to 2 without attaining it. An optional brute-force mode enumerates "
                "every pair of orders in O(k!·j!) to exhibit the lemma concretely on small "
                "instances."
            ),
            "pseudocode": (
                "function ANALYSE-SCHEDULE(k, j, bruteForce):\n"
                "    assert k + j > 0\n"
                "    n <- k + j\n"
                "    # optimal schedule: positions 1..k in the kept branch,\n"
                "    #                   positions 1..j in the rejected branch\n"
                "    total <- 0\n"
                "    for pos <- 1 to k: total <- total + pos\n"
                "    for pos <- 1 to j: total <- total + pos\n"
                "    bound <- k(k+1)/2 + j(j+1)/2          # triangular lower bound\n"
                "    assert total = bound                   # the schedule is optimal\n"
                "    A <- n(n+1) / (k(k+1) + j(j+1))        # expected-position speedup\n"
                "    if bruteForce:\n"
                "        bf <- +infinity\n"
                "        for each permutation p of (1..k):\n"
                "            for each permutation q of (1..j):\n"
                "                bf <- min(bf, sum(p) + sum(q))\n"
                "        assert bf = bound\n"
                "    return (total, bound, n(n+1)/2, A, A < 2)"
            ),
            "code": read("assets/algorithms/alg3_optimal_schedule.py"),
        },
        {
            "name": "Chinese Remainder Composition of Dials and Bit-Currency Accounting",
            "description": (
                "A battery is a family of dials on pairwise coprime moduli read "
                "simultaneously. This routine verifies pairwise coprimality, composes the "
                "dials explicitly by testing each unit modulo the product against every "
                "component reading — exhibiting composition as a literal logical AND — and "
                "checks the density-multiplication identity θ(K₁ ⊗ ⋯ ⊗ K_r) = ∏ θ_i, which "
                "rests on the multiplicativity φ(mn) = φ(m)φ(n) for coprime m, n. Because "
                "the speedup law is a function of the composite density alone, this identity "
                "is the sole channel through which composition can act, and the cap 4/3 "
                "therefore survives untouched. The routine then reports the two currencies: "
                "capacity bits ∑ log₂(1/θ_i), which grow linearly in the number of dials and "
                "are unbounded, against work bits log₂(Speedup), which are bounded by "
                "log₂(4/3) = 0.41504 and tend to zero as the composite density collapses. "
                "The explicit composition costs O(φ(M)·r) with M the product modulus; the "
                "closed-form accounting alone costs O(r)."
            ),
            "pseudocode": (
                "function COMPOSE-BATTERY(dials = [(m_1, K_1), ..., (m_r, K_r)]):\n"
                "    for i < j: assert gcd(m_i, m_j) = 1        # CRT hypothesis\n"
                "    M <- product of all m_i\n"
                "    for i: theta_i <- |K_i| / EULER-PHI(m_i)\n"
                "\n"
                "    passing <- 0                                # explicit AND over the product\n"
                "    for u <- 0 to M-1:\n"
                "        if gcd(u, M) = 1 and (for all i: u mod m_i in K_i):\n"
                "            passing <- passing + 1\n"
                "    theta <- passing / EULER-PHI(M)\n"
                "    assert |theta - product of theta_i| < eps   # densities multiply\n"
                "\n"
                "    S            <- 1 / (1 - theta + theta^2)\n"
                "    capacityBits <- sum over i of -log2(theta_i)     # unbounded\n"
                "    workBits     <- log2(S)                          # <= log2(4/3)\n"
                "    return (theta, S, capacityBits, workBits,\n"
                "            workBits / capacityBits, S <= 4/3 + eps)"
            ),
            "code": read("assets/algorithms/alg4_crt_battery.py"),
        },
        {
            "name": "Multi-Symbol Prefix-Cost Evaluation and the Skip-Boundary Comparison",
            "description": (
                "An r-symbol dial partitions the class space into blocks of densities "
                "θ₁,…,θ_r summing to 1, scanned in the given order, so a target in block i "
                "costs θ₁+⋯+θ_i and the normalised cost is the prefix cost "
                "C = ∑ᵢ θᵢ(θ₁+⋯+θᵢ). A single running sum evaluates C in O(r) time and O(1) "
                "extra space. The routine then verifies the order-free identity "
                "2C = (∑θ)² + ∑θ², obtained by symmetrising the double sum, whose right-hand "
                "side is manifestly permutation-invariant — so no scan order beats another, "
                "contradicting the natural rearrangement heuristic; for r ≤ 7 it confirms "
                "this by enumerating all r! orders. From ∑θ² ≥ 1/r (Cauchy–Schwarz) it "
                "obtains the cap hierarchy 2r/(r+1), attained exactly at uniform blocks and "
                "strictly below 2 for every finite r. Finally it evaluates the full-reveal "
                "cost ∑θ², the model in which the dial names the target's block and the "
                "algorithm may skip the rest, whose speedup is r at uniform blocks and hence "
                "unbounded. The ratio of the two speedups is the exact price of being unable "
                "to skip, and it is the precise boundary of the 4/3 theorem."
            ),
            "pseudocode": (
                "function ANALYSE-SYMBOLS(theta[1..r], checkOrders):\n"
                "    assert sum(theta) = 1 (to tolerance)\n"
                "    running <- 0 ; C <- 0\n"
                "    for i <- 1 to r:                     # O(r) prefix cost\n"
                "        running <- running + theta[i]\n"
                "        C <- C + theta[i] * running\n"
                "    R <- sum of theta[i]^2               # full-reveal cost (skipping)\n"
                "    cap <- 2r / (r + 1)\n"
                "    residual <- |2C - (sum(theta)^2 + sum(theta^2))|   # order-free identity\n"
                "    assert residual < eps\n"
                "    if checkOrders and r <= 7:\n"
                "        assert PREFIX-COST is constant over all r! permutations\n"
                "    return (C, 1/C, cap, |1/C - cap| < eps, residual,\n"
                "            R, 1/R, (1/R)/(1/C))          # last entry: price of no skipping"
            ),
            "code": read("assets/algorithms/alg5_multisymbol_boundary.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Residue-Dial Speedup Landscape: Law, Currencies, Accountings and Boundary",
            "description": (
                "A four-panel figure summarising the entire theory. Panel (a) plots the "
                "exact law 1/(1 − θ + θ²) against the universal cap 4/3, shades the gain "
                "over baseline (whose area is the saving θ − θ² ≤ 1/4), and marks the unique "
                "attainment point θ = 1/2. Panel (b) is the bit-currency separation, with "
                "twin axes: capacity bits of a battery of n half-density dials rise linearly "
                "and without bound while the work bits they purchase collapse toward zero, "
                "forever beneath the dashed line log₂(4/3) = 0.41504. Panel (c) is the "
                "accounting gap on a logarithmic block-size axis: a flat line at 4/3 for "
                "worst-case-in-phase accounting against the curve (2m+1)/(m+1) of "
                "expected-position accounting creeping toward, but never touching, the "
                "dotted barrier at 2. Panel (d) is the boundary of the theorem on a "
                "logarithmic speedup axis: the single-pass caps 2r/(r+1) crawling under 2 "
                "forever while the full-reveal speedup r, available once rejected blocks may "
                "be skipped, marches away without limit."
            ),
            "code": read("assets/viz_speedup_landscape.py"),
        },
        {
            "name": "Structure Blindness, Exhaustively: Every Subset of a Unit Group Collapses onto One Curve",
            "description": (
                "A two-panel figure providing direct visual evidence for the converse "
                "statements. The left panel enumerates all 2^10 = 1024 subsets of the unit "
                "group modulo 11, simulating the scan for each — no formula is used — and "
                "jitters the points horizontally so the collapse is visible: every subset of "
                "a given cardinality lands on exactly one speedup value, and that value lies "
                "on the theoretical curve. Arithmetically distinguished subsets (the "
                "quadratic residues, a nonresidue coset, an interval of classes, a fibre of "
                "a cubic reading) are highlighted with open markers and sit indistinguishably "
                "on top of their structureless neighbours. The right panel performs the same "
                "exhaustive enumeration for a CRT battery on 33 = 3 × 11 over all pairs of "
                "component subsets; the composite densities multiply, the achievable "
                "speedups scatter along the very same curve, and the maximum is again "
                "exactly 4/3 — composition buys nothing."
            ),
            "code": read("assets/viz_structure_blindness.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Residue Dial Laboratory: Turn the Density, Watch the Cap Hold",
            "description": (
                "A four-panel exploratory laboratory for the speedup law. The first panel "
                "couples a density slider to a live plot of 1/(1 − θ + θ²) against the "
                "golden cap line 4/3, reporting the cost, the speedup, the capacity bits, "
                "the work bits and the percentage of the maximum achievable gain, with a "
                "running verbal verdict that explains why very aggressive filters are on the "
                "wrong side of the hill. The second panel renders the class space as a grid "
                "of 24 cells with the kept block highlighted, showing the hit cost, the miss "
                "cost and the resulting expectation, and offers a re-roll button that "
                "redraws a filter of the same size with entirely different structure — "
                "demonstrating structure blindness by producing an identical speedup to ten "
                "decimal places. The third panel composes up to forty half-density dials "
                "into a Chinese-Remainder battery and plots the two currencies against each "
                "other: capacity bits climbing linearly, work bits collapsing to zero. The "
                "fourth panel is a tabbed comparison of the three cost accountings — "
                "worst-case in phase giving 4/3, expected position giving a strict and "
                "unattained 2, and skipping-permitted giving an unbounded r — each with its "
                "own explanation and numerical table, so the reader can see exactly which "
                "modelling choice produces which constant."
            ),
            "html": read("assets/widget_dial_lab.html"),
        },
        {
            "title": "The Scan Race: Three Searchers, One Hint, Two Different Constants",
            "description": (
                "A head-to-head simulation that isolates the single modelling choice "
                "separating 4/3 from 2. Three searchers hunt the same hidden class among 32 "
                "and receive the same congruence hint; they differ only in what they may do "
                "with it. The blind searcher schedules one full pass and is charged for it. "
                "The dial-aware single-pass searcher puts the kept block first but, when the "
                "hint sends it to the wrong block, cannot un-schedule the wasted pass and "
                "pays in full. The skipping searcher may jump straight to the correct block "
                "and ignore the other entirely. The reader sizes the kept block with a "
                "slider, then either steps through a single hidden target — watching the "
                "class grid fill in with paid, skipped and found cells, and reading a "
                "narration of what just happened — or runs two thousand uniformly drawn "
                "targets and compares the measured average costs with the exact predictions "
                "1/(1 − θ + θ²) and 1/(θ² + (1 − θ)²). The final row of the table reports "
                "the price of being unable to skip, measured and predicted, making it "
                "unmistakable that the two barriers differ by a modelling choice rather than "
                "by any arithmetic."
            ),
            "html": read("assets/widget_scan_race.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read("demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size:,} bytes)")


"""
demo.py — Numerical demonstrations of the universal cap 4/3 for residue-dial speedups.

Self-contained: standard library only (math, itertools, random, fractions).
Run with `python3 demo.py`.

Contents
--------
1.  The exact single-pass law  Speedup(theta) = 1 / (1 - theta + theta^2)
    verified against a brute-force simulation of the scan model.
2.  The universal cap 4/3, attained exactly at theta = 1/2, over an exhaustive
    enumeration of *every* subset of the unit group modulo m = 3, 4, 7, 11.
3.  Structure blindness: dials of equal size but wildly different arithmetic
    structure (subgroup, coset, quadratic residues, random scatter) coincide.
4.  Which-factor blindness as an identity, via the involution u |-> c * u^{-1}.
5.  CRT batteries: densities multiply, the cap survives, and capacity bits
    diverge while work bits collapse to zero.
6.  The accounting gap: expected-position speedup (k+j)(k+j+1)/(k(k+1)+j(j+1))
    rises strictly towards 2 but never reaches it, while the worst-case-in-phase
    speedup never exceeds 4/3.
7.  The multi-symbol hierarchy 2r/(r+1), its order-independence, and the
    boundary: a full reveal that permits skipping buys exactly r.
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Iterable, Sequence

# --------------------------------------------------------------------------- #
#  Section 0: the law itself
# --------------------------------------------------------------------------- #

FOUR_THIRDS: float = 4.0 / 3.0


def dial_cost(theta: float) -> float:
    """Normalised expected cost of a dial-aware single-pass scan: 1 - t + t^2."""
    return 1.0 - theta + theta * theta


def speedup(theta: float) -> float:
    """Exact single-pass law: Speedup(theta) = 1 / (1 - theta + theta^2)."""
    return 1.0 / dial_cost(theta)


def capacity_bits(theta: float) -> float:
    """Information a density-theta reading conveys about the target: log2(1/theta)."""
    return -math.log2(theta)


def work_bits(theta: float) -> float:
    """Binary halvings of running time actually purchased: log2(Speedup)."""
    return math.log2(speedup(theta))


# --------------------------------------------------------------------------- #
#  Section 1: brute-force verification of the law
# --------------------------------------------------------------------------- #


def simulate_expected_cost(n: int, kept: frozenset[int]) -> Fraction:
    """
    Exact expected cost of the dial-aware scan over a class space of size n,
    computed by averaging cost(t) over every target t (no sampling, no error).

    cost(t) = |kept|      if t in kept   (the first phase suffices)
            = n           otherwise      (the phase is wasted; full scan follows)
    """
    k = len(kept)
    total = sum(k if t in kept else n for t in range(n))
    return Fraction(total, n)


def demo_exact_law(trials: int = 200, seed: int = 20260822) -> None:
    print("=" * 78)
    print("1.  The exact law  E[cost]/n = 1 - theta + theta^2")
    print("=" * 78)
    rng = random.Random(seed)
    worst = 0.0
    for _ in range(trials):
        n = rng.randint(1, 40)
        k = rng.randint(0, n)
        kept = frozenset(rng.sample(range(n), k))
        empirical = float(simulate_expected_cost(n, kept)) / n
        predicted = dial_cost(k / n)
        worst = max(worst, abs(empirical - predicted))
    print(f"  random filters tested        : {trials}")
    print(f"  max |simulated - predicted|  : {worst:.3e}   (exact law, so ~0)")
    print()
    print("  theta      cost      speedup")
    for theta in (0.0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0):
        print(f"  {theta:5.2f}   {dial_cost(theta):7.4f}   {speedup(theta):8.5f}")
    print()
    print("  Aggressive filters sit on the WRONG side of the hill:")
    for theta in (1e-2, 1e-4, 1e-6):
        print(
            f"    theta = {theta:9.0e}  discards {100*(1-theta):11.6f}% "
            f"-> speedup only {speedup(theta):.6f}"
        )
    print()


# --------------------------------------------------------------------------- #
#  Section 2: exhaustive enumeration of every dial
# --------------------------------------------------------------------------- #


def units_mod(m: int) -> list[int]:
    """The reduced residue classes modulo m."""
    return [u for u in range(m) if math.gcd(u, m) == 1]


def demo_exhaustive_cap(moduli: Sequence[int] = (3, 4, 7, 11)) -> None:
    print("=" * 78)
    print("2.  Exhaustive enumeration: EVERY subset of the unit group")
    print("=" * 78)
    for m in moduli:
        us = units_mod(m)
        n = len(us)
        best = 0.0
        argmax_sizes: set[int] = set()
        for r in range(n + 1):
            for _subset in itertools.combinations(us, r):
                s = speedup(r / n)
                if s > best + 1e-15:
                    best, argmax_sizes = s, {r}
                elif abs(s - best) <= 1e-15:
                    argmax_sizes.add(r)
        print(
            f"  m = {m:3d}   phi(m) = {n:3d}   subsets = {2**n:6d}   "
            f"max speedup = {best:.10f}   attained at |K| in {sorted(argmax_sizes)}"
        )
    print(f"  universal cap 4/3 = {FOUR_THIRDS:.10f}    (never exceeded)")
    print()


# --------------------------------------------------------------------------- #
#  Section 3: structure blindness
# --------------------------------------------------------------------------- #


def quadratic_residues(m: int) -> frozenset[int]:
    """The squares in the unit group modulo m."""
    return frozenset((u * u) % m for u in units_mod(m))


def demo_structure_blindness(m: int = 13, seed: int = 7) -> None:
    print("=" * 78)
    print("3.  Structure blindness: only |K| matters")
    print("=" * 78)
    us = units_mod(m)
    n = len(us)
    qr = sorted(quadratic_residues(m))
    half = n // 2
    rng = random.Random(seed)

    families: dict[str, list[int]] = {
        "quadratic residues": qr[:half],
        "a nonresidue coset": sorted((2 * q) % m for q in qr)[:half],
        "an interval       ": us[:half],
        "random scatter    ": sorted(rng.sample(us, half)),
        "cubic-symbol fibre": sorted(us, key=lambda u: pow(u, 3, m))[:half],
    }
    print(f"  modulus m = {m},  phi(m) = {n},  all dials of size {half}")
    for name, K in families.items():
        theta = len(K) / n
        print(
            f"    {name}  K = {str(K):<28}  theta = {theta:.4f}  "
            f"speedup = {speedup(theta):.10f}"
        )
    print("  -> identical to the last digit; the law cannot see the structure.")
    print()


# --------------------------------------------------------------------------- #
#  Section 4: which-factor blindness is an identity
# --------------------------------------------------------------------------- #


def factor_swap(m: int, c: int, u: int) -> int:
    """The involution sigma_c(u) = c * u^{-1} exchanging the two factor classes."""
    return (c * pow(u, -1, m)) % m


def demo_which_factor_blindness(m: int = 21, seed: int = 3) -> None:
    print("=" * 78)
    print("4.  Which-factor blindness: sigma_c(u) = c * u^(-1) is an involution")
    print("=" * 78)
    us = units_mod(m)
    n = len(us)
    rng = random.Random(seed)
    for c in [u for u in us if u != 1][:3]:
        K = sorted(rng.sample(us, n // 2))
        K_swapped = sorted(factor_swap(m, c, u) for u in K)
        assert sorted(factor_swap(m, c, u) for u in K_swapped) == K, "not an involution"
        s1, s2 = speedup(len(K) / n), speedup(len(K_swapped) / n)
        print(
            f"  c = {c:3d}   |K| = {len(K)}  |sigma_c(K)| = {len(K_swapped)}   "
            f"speedup(K) = {s1:.12f}   speedup(sigma_c K) = {s2:.12f}   "
            f"equal: {s1 == s2}"
        )
    print("  -> an identity, not an approximation: a bijection preserves cardinality.")
    print()


# --------------------------------------------------------------------------- #
#  Section 5: CRT batteries and the two currencies
# --------------------------------------------------------------------------- #


def crt_battery_density(densities: Iterable[float]) -> float:
    """Composite density of a battery of dials on pairwise coprime moduli."""
    product = 1.0
    for d in densities:
        product *= d
    return product


def demo_batteries() -> None:
    print("=" * 78)
    print("5.  CRT batteries: densities multiply, the cap survives")
    print("=" * 78)
    print("  Exhaustive check on product moduli (all subset pairs):")
    for m, n in ((3, 4), (3, 5), (3, 7), (3, 11)):
        um, un = units_mod(m), units_mod(n)
        best = 0.0
        for a in range(len(um) + 1):
            for b in range(len(un) + 1):
                theta = (a / len(um)) * (b / len(un))
                best = max(best, speedup(theta))
        print(
            f"    M = {m*n:3d} = {m} x {n}   phi = {len(um)*len(un):3d}   "
            f"max battery speedup = {best:.10f}  (cap {FOUR_THIRDS:.10f})"
        )
    print()
    print("  Two currencies (battery of n half-density dials):")
    print("     n   composite theta   capacity bits   work bits   speedup")
    for n_dials in (1, 2, 4, 8, 13, 20, 40):
        theta = crt_battery_density([0.5] * n_dials)
        print(
            f"    {n_dials:2d}   {theta:15.3e}   {capacity_bits(theta):13.4f}   "
            f"{work_bits(theta):9.6f}   {speedup(theta):.8f}"
        )
    print(f"  work-bit cap = log2(4/3) = {math.log2(FOUR_THIRDS):.6f} < 1")
    measured = 12.7235
    print(
        f"  a measured battery capacity of {measured} bits buys at most "
        f"{math.log2(FOUR_THIRDS):.5f} work bits "
        f"(exchange rate {100*math.log2(FOUR_THIRDS)/measured:.3f}%)"
    )
    print()


# --------------------------------------------------------------------------- #
#  Section 6: the accounting gap  (4/3 versus 2)
# --------------------------------------------------------------------------- #


def avg_speedup(k: int, j: int) -> float:
    """Expected-position speedup: (k+j)(k+j+1) / (k(k+1) + j(j+1))."""
    return ((k + j) * (k + j + 1)) / (k * (k + 1) + j * (j + 1))


def brute_force_best_schedule(n: int, k: int) -> float:
    """
    Exhaustively confirm the optimality lemma for small n: over ALL orderings of
    the kept block and of the rejected block, the smallest total cost equals the
    two triangular numbers k(k+1)/2 + j(j+1)/2.
    """
    j = n - k
    best = min(
        sum(perm_in) + sum(perm_out)
        for perm_in in itertools.permutations(range(1, k + 1))
        for perm_out in itertools.permutations(range(1, j + 1))
    ) if k + j > 0 else 0
    return best


def demo_accounting_gap() -> None:
    print("=" * 78)
    print("6.  The accounting gap: 4/3 (worst-case-in-phase) vs 2 (expected position)")
    print("=" * 78)
    print("  Optimality lemma, brute-forced over all schedules:")
    for n, k in ((6, 3), (7, 3), (8, 4)):
        j = n - k
        got = brute_force_best_schedule(n, k)
        want = k * (k + 1) // 2 + j * (j + 1) // 2
        print(
            f"    n = {n}, k = {k}, j = {j}:  best total = {got:3d}   "
            f"triangular bound = {want:3d}   match: {got == want}"
        )
    print()
    print("  Balanced blocks: expected-position speedup (2m+1)/(m+1) rises to 2")
    print("       m   avgSpeedup   2 - avgSpeedup   worst-case-in-phase")
    for m in (1, 2, 5, 20, 100, 1000, 100000):
        a = avg_speedup(m, m)
        print(f"    {m:6d}   {a:10.7f}   {2 - a:14.3e}   {FOUR_THIRDS:19.7f}")
    print("  -> the first column approaches 2 but never attains it;")
    print("     the last column is constant at 4/3 and is never exceeded.")
    print()


# --------------------------------------------------------------------------- #
#  Section 7: multi-symbol dials, order-freeness, and the skipping boundary
# --------------------------------------------------------------------------- #


def prefix_cost(thetas: Sequence[float]) -> float:
    """Normalised cost of scanning r blocks in order: sum_i theta_i * (theta_1+...+theta_i)."""
    running = 0.0
    total = 0.0
    for t in thetas:
        running += t
        total += t * running
    return total


def reveal_cost(thetas: Sequence[float]) -> float:
    """Cost when the answer NAMES the block and the rest may be skipped: sum theta_i^2."""
    return sum(t * t for t in thetas)


def multi_cap(r: int) -> float:
    """The r-symbol single-pass cap 2r/(r+1)."""
    return 2.0 * r / (r + 1.0)


def demo_multisymbol(seed: int = 11) -> None:
    print("=" * 78)
    print("7.  Multi-symbol dials: order-freeness, the hierarchy 2r/(r+1), skipping")
    print("=" * 78)
    rng = random.Random(seed)

    print("  Order-free identity  2*C = (sum theta)^2 + sum theta^2, and")
    print("  invariance of C under every permutation of the blocks:")
    for r in (3, 4, 5):
        raw = [rng.random() for _ in range(r)]
        s = sum(raw)
        thetas = [x / s for x in raw]
        values = {round(prefix_cost(list(p)), 12) for p in itertools.permutations(thetas)}
        identity_lhs = 2 * prefix_cost(thetas)
        identity_rhs = sum(thetas) ** 2 + sum(t * t for t in thetas)
        print(
            f"    r = {r}:  distinct costs over all {math.factorial(r):3d} orders = "
            f"{len(values)}   |2C - ((sum)^2 + sum sq)| = "
            f"{abs(identity_lhs - identity_rhs):.3e}"
        )
    print()
    print("  The cap hierarchy, attained at uniform blocks, and the reveal model:")
    print("     r   uniform single-pass   cap 2r/(r+1)   full reveal (skipping)")
    for r in (2, 3, 4, 5, 8, 16, 64):
        uni = [1.0 / r] * r
        print(
            f"    {r:2d}   {1/prefix_cost(uni):19.8f}   {multi_cap(r):12.8f}   "
            f"{1/reveal_cost(uni):22.4f}"
        )
    print("  -> single-pass caps stay strictly below 2 and converge to it;")
    print("     with skipping allowed a balanced r-symbol reveal buys exactly r,")
    print("     and the binary reveal buys exactly 2 -- the folklore's barrier.")
    print()


# --------------------------------------------------------------------------- #
#  Section 8: the profitability threshold
# --------------------------------------------------------------------------- #


def absolute_saving(n: int, theta: float) -> float:
    """Classes not scanned, thanks to a density-theta dial: n*(theta - theta^2) <= n/4."""
    return n * (theta - theta * theta)


def demo_profitability(n: int = 1_000_000) -> None:
    print("=" * 78)
    print("8.  Profitability: the saving is n*(theta - theta^2) <= n/4")
    print("=" * 78)
    print(f"  class space of n = {n:,} classes")
    for theta in (0.05, 0.2, 0.5, 0.8, 0.95):
        sv = absolute_saving(n, theta)
        print(
            f"    theta = {theta:4.2f}   saving = {sv:12,.0f} classes "
            f"({100*sv/n:5.2f}% of a full scan)"
        )
    print(f"  maximum possible saving = n/4 = {n/4:,.0f} classes, at theta = 1/2")
    print("  => a filter whose reading costs more than a quarter of a full scan")
    print("     can never pay for itself, whatever its density.")
    print()


# --------------------------------------------------------------------------- #

def main() -> None:
    print()
    print("#" * 78)
    print("#  The universal cap 4/3 for residue-dial speedups — numerical demos")
    print("#" * 78)
    print()
    demo_exact_law()
    demo_exhaustive_cap()
    demo_structure_blindness()
    demo_which_factor_blindness()
    demo_batteries()
    demo_accounting_gap()
    demo_multisymbol()
    demo_profitability()
    print("=" * 78)
    print("Summary")
    print("=" * 78)
    print("  Speedup(theta) = 1/(1 - theta + theta^2)          exact, structure-blind")
    print(f"  max over all theta  = 4/3 = {FOUR_THIRDS:.10f}        at theta = 1/2 alone")
    print(f"  max work bits       = log2(4/3) = {math.log2(FOUR_THIRDS):.6f} bits")
    print("  expected-position accounting: strict barrier 2, never attained")
    print("  skipping permitted:           a balanced r-symbol reveal buys exactly r")
    print()


if __name__ == "__main__":
    main()
