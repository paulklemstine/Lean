"""
Numerical demonstrations for the retention-knee theory of attention profiles.

Everything in this file is self-contained (standard library only) and mirrors
the exact statements of the theory:

  * retained mass and the knee  k*(w, tau) = min { k : R_w(k) >= tau }
  * additive law     : k*(delay_d w, tau) = d + k*(w, tau)
  * root law         : k_geom(r^m, t)     = ceil( k_geom(r, t) / m )
  * exactness        : B = m*A  <=>  m | B
  * two-sided bound  : B <= m*A < B + m
  * French entry     : English knee 20 under a square-root tax => French knee in {39, 40}
  * master knee      : the five-domain table is covered by B in {118, 119, 120}
  * tail classes     : heavy tails beat every geometric profile by an unbounded factor
  * grids            : a coarse grid never underestimates the knee

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# Core definitions
# ----------------------------------------------------------------------------


def retained(w: Callable[[int], float], k: int) -> float:
    """Retained mass R_w(k) = sum_{i < k} w_i."""
    return math.fsum(w(i) for i in range(k))


def kstar(w: Callable[[int], float], tau: float, kmax: int = 200_000) -> int:
    """Knee: least k with R_w(k) >= tau. Returns -1 if unreached below kmax."""
    total = 0.0
    if tau <= 0.0:
        return 0
    for k in range(kmax):
        total += w(k)
        if total >= tau:
            return k + 1
    return -1


def delay(d: int, w: Callable[[int], float]) -> Callable[[int], float]:
    """Prefix the profile with d massless positions."""
    return lambda i: 0.0 if i < d else w(i - d)


def geom(r: float) -> Callable[[int], float]:
    """Geometric profile w_i = (1 - r) r^i, whose retained mass is 1 - r^k."""
    return lambda i: (1.0 - r) * r**i


def heavy(i: int) -> float:
    """Heavy (telescoping) profile w_i = 1/((i+1)(i+2)); R(k) = k/(k+1)."""
    return 1.0 / ((i + 1) * (i + 2))


def ceil_div(a: int, m: int) -> int:
    """Ceiling division ceil(a / m) on the naturals."""
    if m <= 0:
        raise ValueError("m must be positive")
    return -((-a) // m)


def kgeom(r: float, t: float) -> int:
    """Geometric knee: least k with r^k <= t (t is the tail budget 1 - tau)."""
    if not 0.0 <= r < 1.0:
        raise ValueError("need 0 <= r < 1")
    if t <= 0.0:
        raise ValueError("need t > 0")
    if r == 0.0:
        return 0 if 1.0 <= t else 1
    k, cur = 0, 1.0
    while cur > t:
        cur *= r
        k += 1
    return k


def ideal_knee(r: float, t: float) -> float:
    """The real-valued ideal knee log(t) / log(r)."""
    return math.log(t) / math.log(r)


def grid_knee(
    w: Callable[[int], float], tau: float, grid: Sequence[int]
) -> Optional[int]:
    """Least tested cut-off in `grid` that clears the gate, or None."""
    for k in sorted(grid):
        if retained(w, k) >= tau:
            return k
    return None


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_additive_law() -> None:
    print("=" * 74)
    print("1. ADDITIVE LAW:  k*(delay_d w, tau) = d + k*(w, tau), at every gate")
    print("=" * 74)
    w = geom(0.80)
    for d in (0, 4, 9):
        for tau in (0.50, 0.90, 0.98, 0.999):
            base = kstar(w, tau)
            shifted = kstar(delay(d, w), tau)
            ok = shifted == d + base
            print(
                f"  d={d:2d}  tau={tau:<6} k*(w)={base:4d}  "
                f"k*(delay)={shifted:4d}  d+k*={d + base:4d}  {'OK' if ok else 'FAIL'}"
            )
            assert ok
    print("  -> the shift is exact and independent of the gate.\n")


def demo_root_law() -> None:
    print("=" * 74)
    print("2. ROOT LAW:  k_geom(r^m, t) = ceil( k_geom(r, t) / m )")
    print("=" * 74)
    print(f"  {'r':>6} {'m':>3} {'t':>9} {'B=fine':>7} {'A=coarse':>9} "
          f"{'ceil(B/m)':>10} {'m*A':>5} {'B+m':>5}")
    for r in (0.90, 0.85, 0.5):
        for m in (2, 3, 5, 6, 10):
            for t in (0.02, 0.01, 1e-4):
                B = kgeom(r, t)
                A = kgeom(r**m, t)
                assert A == ceil_div(B, m), (r, m, t)
                # two-sided bound  B <= m*A < B + m
                assert B <= m * A < B + m
                print(
                    f"  {r:>6} {m:>3} {t:>9} {B:>7} {A:>9} "
                    f"{ceil_div(B, m):>10} {m * A:>5} {B + m:>5}"
                )
    print("  -> the ceiling law and the two-sided bound hold in every case.\n")


def demo_exactness_and_ideal() -> None:
    print("=" * 74)
    print("3. EXACTNESS (B = m*A  <=>  m | B) AND THE IDEAL KNEE")
    print("=" * 74)
    r, m = 0.9, 2
    for t in (0.05, 0.02, 0.01, 0.005, 0.001):
        B = kgeom(r, t)
        A = kgeom(r**m, t)
        exact = B == m * A
        divides = B % m == 0
        kap = ideal_knee(r, t)
        assert exact == divides
        assert kap <= B < kap + 1
        print(
            f"  t={t:<7} B={B:4d} A={A:4d}  m|B: {str(divides):5}  "
            f"B=m*A: {str(exact):5}  ideal={kap:8.4f}  (ceil = {math.ceil(kap)})"
        )
    print("  -> exactness holds precisely on multiples; the integer knee is")
    print("     always the ceiling of the ideal knee, never off by one or more.\n")


def demo_gate_invariance() -> None:
    print("=" * 74)
    print("4. GATE INVARIANCE OF THE TAX RATIO")
    print("=" * 74)
    r_fr, r_en = 0.90, 0.90**2  # English decays like the square of French
    predicted = math.log(r_en) / math.log(r_fr)
    print(f"  predicted ratio log(r_EN)/log(r_FR) = {predicted:.6f}")
    print(f"  {'gate tau':>10} {'k*_FR':>7} {'k*_EN':>7} {'ratio':>9} "
          f"{'|k_FR - 2 k_EN|':>16}")
    for tau in (0.90, 0.95, 0.98, 0.995, 0.999, 0.9999):
        t = 1.0 - tau
        fr, en = kgeom(r_fr, t), kgeom(r_en, t)
        ratio = fr / en
        gap = abs(fr - 2 * en)
        assert gap <= 2  # integer half of the prediction
        print(f"  {tau:>10} {fr:>7} {en:>7} {ratio:>9.4f} {gap:>16}")
    print("  -> the ratio hugs its gate-independent limit; the integer")
    print("     discrepancy |k_FR - 2 k_EN| never exceeds the multiplier.\n")


def demo_french_entry() -> None:
    print("=" * 74)
    print("5. THE FRENCH ENTRY:  39 OR 40, AND THE PARITY BIT")
    print("=" * 74)
    # Reported measurement, gate 0.98
    measured: Dict[int, float] = {36: 0.9795, 40: 0.9830, 48: 0.9855,
                                  56: 0.9896, 64: 0.9916}
    tau = 0.98
    fails = [k for k, v in sorted(measured.items()) if v < tau]
    passes = [k for k, v in sorted(measured.items()) if v >= tau]
    a, b = max(fails), min(passes)
    print(f"  measured retained masses at gate {tau}: {measured}")
    print(f"  highest failing cut-off a = {a}, lowest passing cut-off b = {b}")
    print(f"  rigorous bracket:  {a} < k* <= {b}")
    assert a == 36 and b == 40

    # Structural consequence of a square-root decay tax with English knee 20.
    admissible: Set[int] = set()
    for r in [0.5 + 0.0005 * j for j in range(1000)]:
        for t in (1e-2, 5e-3, 2e-3, 1e-3, 5e-4, 1e-4, 1e-5, 1e-6, 1e-8):
            if kgeom(r**2, t) == 20:
                admissible.add(kgeom(r, t))
    print(f"  scanning ratios/gates with English knee exactly 20:")
    print(f"  observed French knees = {sorted(admissible)}")
    assert admissible <= {39, 40} and admissible
    print("  -> the data plus the square-root tax pin the French knee to {39, 40};")
    print("     only the extra parity assumption selects 40, and the reported")
    print("     grid {36,40,48,56,64} never tests 39.\n")


def covers_table(B: int, entries: Iterable[int] = (12, 20, 24, 40)) -> bool:
    """Does some tax exponent send B to each table entry under the ceiling law?

    For entries v >= 2 the exponent is bounded by B, so the search is finite.
    """
    for v in entries:
        if not any(ceil_div(B, m) == v for m in range(1, B + 1)):
            return False
    return True


def demo_master_knee() -> None:
    print("=" * 74)
    print("6. THE MASTER KNEE AND ITS GAUGE FREEDOM")
    print("=" * 74)
    exps = (10, 6, 6, 5, 3)
    for B in (118, 120):
        row = [ceil_div(B, m) for m in exps]
        print(f"  B={B}  exponents {exps} -> {row}")
        assert row == [12, 20, 20, 24, 40]

    covering = [B for B in range(1, 200) if covers_table(B)]
    print(f"  exhaustive search: least master covering the table = {min(covering)}")
    assert min(covering) == 118
    assert all(not covers_table(B) for B in range(118))

    sols = [
        B
        for B in range(0, 400)
        if (ceil_div(B, 10) == 12 and ceil_div(B, 6) == 20
            and ceil_div(B, 5) == 24 and ceil_div(B, 3) == 40)
    ]
    print(f"  exact solution set for exponents (10,6,5,3): {sols}")
    assert sols == [118, 119, 120]

    # Interval form of each ceiling equation.
    print("  interval form of each equation  m(v-1) < B <= m v :")
    for m, v in ((10, 12), (6, 20), (5, 24), (3, 40)):
        print(f"    ceil(B/{m:2d}) = {v:2d}   <=>   {m * (v - 1):3d} < B <= {m * v:3d}")
    print("  -> the intersection is {118, 119, 120}: the table cannot")
    print("     distinguish these three masters.\n")


def demo_rigidity() -> None:
    print("=" * 74)
    print("7. MULTIPLICATIVE RIGIDITY:  R_A(m k) = R_B(k)")
    print("=" * 74)
    m = 2
    r = 0.81
    B_prof = geom(r)          # coarse profile
    A_prof = geom(r ** 0.5)   # fine profile: square-root tail
    print(f"  A = geom(sqrt(r)),  B = geom(r) with r = {r}, m = {m}")
    print(f"  {'k':>4} {'R_A(mk)':>12} {'R_B(k)':>12} {'difference':>13}")
    for k in range(1, 9):
        ra, rb = retained(A_prof, m * k), retained(B_prof, k)
        print(f"  {k:>4} {ra:>12.9f} {rb:>12.9f} {abs(ra - rb):>13.2e}")
        assert abs(ra - rb) < 1e-12
    print("  -> the fine retention curve, sampled at multiples of m, is exactly")
    print("     the coarse one: a block dilation, as the rigidity theorem forces.\n")


def demo_tail_classes() -> None:
    print("=" * 74)
    print("8. TAIL CLASSES: heavy tails beat geometric ones by any factor")
    print("=" * 74)
    r = 0.9
    print(f"  {'gate tau':>12} {'geometric k*':>14} {'heavy k*':>10} {'factor':>9}")
    for n in (10, 20, 40, 80, 160):
        tau = 1.0 - r**n
        kg = kstar(geom(r), tau)
        kh = math.ceil(1.0 / (1.0 - tau)) - 1  # least k with k/(k+1) >= tau
        while kh / (kh + 1) < tau:
            kh += 1
        print(f"  {tau:>12.9f} {kg:>14} {kh:>10} {kh / max(kg, 1):>9.1f}")
    print("  -> the geometric knee grows like log(1/t), the heavy one like 1/t:")
    print("     the separating factor is unbounded, not a constant.\n")


def demo_grids() -> None:
    print("=" * 74)
    print("9. COARSE GRIDS NEVER UNDERESTIMATE THE KNEE")
    print("=" * 74)
    w = geom(0.9)
    grid = [36, 40, 48, 56, 64]
    print(f"  grid = {grid}")
    print(f"  {'gate tau':>10} {'true k*':>9} {'grid k*':>9} {'safe?':>7}")
    for tau in (0.95, 0.97, 0.98, 0.99, 0.995):
        true_k = kstar(w, tau)
        g = grid_knee(w, tau, grid)
        safe = g is None or true_k <= g
        print(f"  {tau:>10} {true_k:>9} {str(g):>9} {str(safe):>7}")
        assert safe
    print("  -> the reported value is the least tested point at or above the")
    print("     true knee: a coarse grid over-provisions, never under-provisions.\n")


def main() -> None:
    print()
    print("RETENTION KNEES OF ATTENTION PROFILES - NUMERICAL DEMONSTRATIONS")
    print()
    demo_additive_law()
    demo_root_law()
    demo_exactness_and_ideal()
    demo_gate_invariance()
    demo_french_entry()
    demo_master_knee()
    demo_rigidity()
    demo_tail_classes()
    demo_grids()
    print("=" * 74)
    print("All assertions passed: every numerical check agrees with the theory.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""Bracket-and-bisect refinement of a coarse knee measurement.

A coarse grid of tested cut-offs never underestimates the knee: the reported
value is the least tested point at or above the true knee.  A failing test at a
and a passing test at b therefore bracket the truth, a < k* <= b, and because
retention is monotone the bracket can be closed by bisection using
ceil(log2(b - a)) further probes.  This is the optimal number of probes for a
comparison-based search on a monotone predicate.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Sequence, Tuple


def grid_report(
    retained_at: Dict[int, float], gate: float
) -> Tuple[Optional[int], Optional[int]]:
    """Return (highest failing cut-off, lowest passing cut-off) on the grid."""
    fails = [k for k, v in retained_at.items() if v < gate]
    passes = [k for k, v in retained_at.items() if v >= gate]
    return (max(fails) if fails else None, min(passes) if passes else None)


def bracket(retained_at: Dict[int, float], gate: float) -> Tuple[int, int]:
    """Rigorous bracket a < k* <= b from a coarse grid of measurements."""
    a, b = grid_report(retained_at, gate)
    if a is None or b is None:
        raise ValueError("grid does not bracket the knee: need a fail and a pass")
    if a >= b:
        raise ValueError("measurements are not monotone")
    return a, b


def bisect_knee(
    retained: Callable[[int], float], gate: float, lo: int, hi: int
) -> Tuple[int, int]:
    """Close a bracket (lo, hi] to the exact knee; returns (knee, probes used).

    Precondition: retained(lo) < gate <= retained(hi), retained monotone.
    """
    probes = 0
    while hi - lo > 1:
        mid = (lo + hi) // 2
        probes += 1
        if retained(mid) >= gate:
            hi = mid
        else:
            lo = mid
    return hi, probes


def probes_needed(lo: int, hi: int) -> int:
    """Worst-case number of additional probes to close the bracket."""
    return max(0, math.ceil(math.log2(hi - lo)))


if __name__ == "__main__":
    measured = {36: 0.9795, 40: 0.9830, 48: 0.9855, 56: 0.9896, 64: 0.9916}
    gate = 0.98
    a, b = bracket(measured, gate)
    print(f"coarse grid gives  {a} < k* <= {b}")
    print(f"probes needed to close the bracket: {probes_needed(a, b)}")

    # Simulated fine profile whose knee is genuinely 39.
    r = 0.9
    fine = lambda k: 1.0 - r ** (k * math.log(0.02) / (39 * math.log(r)))
    knee, used = bisect_knee(fine, gate, a, b)
    print(f"bisection resolves the knee to {knee} using {used} probes")


"""Ceiling-law reconstruction of domain knees from a single master profile.

Given a master geometric knee B and a vector of integer tax exponents
(m_1, ..., m_n), the knee observed in domain j is exactly ceil(B / m_j).
This module computes the reconstruction, checks it against a measured table,
and reports the two-sided bound B <= m*A < B + m for each domain.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple


def ceil_div(a: int, m: int) -> int:
    """Ceiling division ceil(a / m) on the naturals; m must be positive."""
    if m <= 0:
        raise ValueError("tax exponent must be positive")
    return -((-a) // m)


def reconstruct_table(master: int, exponents: Sequence[int]) -> List[int]:
    """Knees predicted by the ceiling law for each tax exponent."""
    return [ceil_div(master, m) for m in exponents]


def two_sided_bounds(master: int, exponents: Sequence[int]) -> List[Tuple[int, int, int]]:
    """For each exponent m return (B, m*ceil(B/m), B+m), witnessing B <= m*A < B+m."""
    out: List[Tuple[int, int, int]] = []
    for m in exponents:
        a = ceil_div(master, m)
        assert master <= m * a < master + m
        out.append((master, m * a, master + m))
    return out


def check_against_measurement(
    master: int, exponents: Sequence[int], measured: Sequence[int]
) -> Dict[str, object]:
    """Compare the reconstruction with a measured knee table."""
    if len(exponents) != len(measured):
        raise ValueError("exponent vector and measurement must have equal length")
    predicted = reconstruct_table(master, exponents)
    residuals = [p - q for p, q in zip(predicted, measured)]
    return {
        "master": master,
        "exponents": list(exponents),
        "predicted": predicted,
        "measured": list(measured),
        "residuals": residuals,
        "exact_match": all(r == 0 for r in residuals),
        "two_sided": two_sided_bounds(master, exponents),
    }


if __name__ == "__main__":
    domains = ["code", "EN prose", "math", "DE prose", "FR prose"]
    measured = [12, 20, 20, 24, 40]
    exponents = [10, 6, 6, 5, 3]
    for master in (118, 119, 120):
        report = check_against_measurement(master, exponents, measured)
        print(f"master knee B = {master}")
        for d, m, p, q in zip(domains, exponents, report["predicted"], measured):
            print(f"   {d:<10} exponent {m:>2}  predicted {p:>3}  measured {q:>3}")
        print(f"   exact match: {report['exact_match']}\n")


"""Exhaustive master-knee search with a finite exponent bound.

A master knee B "realizes" a table entry v if some positive integer exponent m
satisfies ceil(B / m) = v.  A priori the exponent ranges over all positive
integers; the search is made finite by the observation that for v >= 2 any such
m satisfies m <= B (if m > B then ceil(B/m) <= 1 < v).  The whole covering
predicate is therefore decidable in O(B) work per entry.
"""

from __future__ import annotations

from typing import Dict, List, Optional, Sequence, Set


def ceil_div(a: int, m: int) -> int:
    """Ceiling division ceil(a / m); m must be positive."""
    if m <= 0:
        raise ValueError("m must be positive")
    return -((-a) // m)


def realizing_exponents(master: int, value: int) -> List[int]:
    """All exponents m with ceil(master / m) = value (finite for value >= 2)."""
    if value < 2:
        raise ValueError("finiteness argument requires value >= 2")
    return [m for m in range(1, master + 1) if ceil_div(master, m) == value]


def realizes(master: int, value: int) -> bool:
    """Does some exponent send the master knee to this table entry?"""
    return any(ceil_div(master, m) == value for m in range(1, master + 1))


def covers_table(master: int, entries: Sequence[int] = (12, 20, 24, 40)) -> bool:
    """Does the master knee realize every entry of the measured table?"""
    return all(realizes(master, v) for v in entries)


def least_master(
    entries: Sequence[int] = (12, 20, 24, 40), limit: int = 1000
) -> Optional[int]:
    """Least master knee covering the table, searching B = 0, 1, ..., limit."""
    for master in range(limit + 1):
        if covers_table(master, entries):
            return master
    return None


def solution_set_for_exponents(
    constraints: Dict[int, int], limit: int = 1000
) -> List[int]:
    """All B <= limit satisfying ceil(B/m) = v for every (m, v) constraint.

    Equivalently, by the interval form of ceiling division, the intersection of
    the half-open intervals ( m(v-1), m v ].
    """
    lo, hi = 0, limit
    for m, v in constraints.items():
        lo = max(lo, m * (v - 1) + 1)
        hi = min(hi, m * v)
    return list(range(lo, hi + 1)) if lo <= hi else []


if __name__ == "__main__":
    print("least master covering (12, 20, 24, 40):", least_master())
    print("no smaller master works:", all(not covers_table(b) for b in range(118)))
    sols = solution_set_for_exponents({10: 12, 6: 20, 5: 24, 3: 40})
    print("exact solution set for exponents (10, 6, 5, 3):", sols)
    for v in (12, 20, 24, 40):
        print(f"exponents realizing {v:>2} from 118:", realizing_exponents(118, v))


"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")


def read(*parts: str) -> str:
    with open(os.path.join(*parts), "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Physics/AttentionKneeMultiplier.lean",
    "Catalog/Physics/AttentionKneeSpectrum.lean",
    "Catalog/Physics/AttentionKneeRigidity.lean",
    "Catalog/Physics/AttentionKneeMasterKnee.lean",
]


def lean_source() -> str:
    chunks = []
    for path in LEAN_FILES:
        chunks.append(f"-- ===== {path} =====\n" + read(ROOT, path).rstrip() + "\n")
    return "\n".join(chunks)


def main() -> None:
    demo_py = read(ROOT, "demo.py")

    package: Dict[str, Any] = {
        "title": "Retention Knees of Attention Profiles: Additive Delay, "
                 "Multiplicative Decay Tax, and the Gauge Freedom of the Master Knee",
        "domain": "Physics",
        "description": "A rigorous theory of the retention knee of a discrete "
                       "attention profile, proving that an additive delay and a "
                       "multiplicative decay tax are structurally distinct laws, "
                       "sharpening the reported French knee of 40 to the exact "
                       "alternative {39, 40}, and showing that the five-domain knee "
                       "table determines the underlying master profile only up to "
                       "the three-element ambiguity {118, 119, 120}.",
        "authors": ["Aristotle"],
        "date": "2026-09-01",
        "key_results": [
            "Additive delay law: prefixing a profile with d massless positions "
            "shifts its retention knee by exactly +d at every positive gate.",
            "Root-of-ratio law: a profile whose decay ratio is the m-th power of "
            "another's has knee equal to the ceiling of the finer knee divided by m, "
            "with exact equality precisely when m divides that knee.",
            "Sharp two-sided bound B <= mA < B + m, whence an English knee of 20 "
            "under a square-root decay tax forces a French knee of 39 or 40 and "
            "nothing else; the reported value 40 requires an unverifiable parity "
            "assumption.",
            "Exact gauge freedom of the master knee: a master reproduces the "
            "five-domain table with exponents (10, 6, 5, 3) if and only if it equals "
            "118, 119 or 120, and no master below 118 reproduces it under any "
            "exponent vector, so 118 and 120 are observationally indistinguishable.",
            "Multiplicative rigidity: if the knee law k*(A) = m k*(B) holds at every "
            "gate, then the taxed retention curve is a block dilation of the untaxed "
            "one, R_A(mk) = R_B(k), with no geometric hypothesis.",
            "Tail-class separation: a heavy-tailed profile exceeds every geometric "
            "profile's knee by an arbitrarily large factor, so across tail classes "
            "no bounded tax of either kind exists.",
        ],
        "keywords": [
            "retention knee",
            "attention profile",
            "geometric tail",
            "ceiling division",
            "tokenizer tax",
            "multiplicative rigidity",
            "tail-class dichotomy",
            "gauge freedom",
        ],
        "article": read(ROOT, "ARTICLE.md"),
        "research_paper": read(ROOT, "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT, "RESEARCH_PAPER.tex"),
        "demo": demo_py,
        "demos": [
            {
                "name": "Complete Numerical Verification of the Knee Laws",
                "description": (
                    "A self-contained suite of nine numerical experiments that "
                    "instantiate every theorem of the theory and assert it. It "
                    "verifies the additive delay law across four gates and three "
                    "delays; the ceiling root law and the sharp two-sided bound "
                    "B <= mA < B + m over a grid of ratios, exponents and gates; the "
                    "exactness criterion B = mA if and only if m divides B; the "
                    "one-position accuracy of the integer knee against the ideal "
                    "knee log t / log r; gate invariance of the tax ratio together "
                    "with the integer prediction |k_FR - 2 k_EN| <= 2; the reduction "
                    "of the reported French measurement to the bracket 36 < k* <= 40 "
                    "and, under a square-root tax with English knee 20, to the "
                    "two-element set {39, 40}; the exhaustive master-knee search "
                    "returning 118 as the minimum and {118, 119, 120} as the exact "
                    "solution set; the block-dilation identity R_A(mk) = R_B(k) of "
                    "the rigidity theorem to twelve decimal places; the unbounded "
                    "separation between heavy and geometric tails; and the safety of "
                    "coarse measurement grids."
                ),
                "code": demo_py,
            },
            {
                "name": "Context Doubling as an Experimental Tail-Class Discriminator",
                "description": (
                    "Simulates a geometric-tailed and a power-law-tailed attention "
                    "profile, truncates each at contexts 512, 1024, 2048, 4096 and "
                    "8192, renormalises, and measures the knee response at gate 0.98. "
                    "The geometric profile's knee saturates (the additive response "
                    "vanishes once truncation stops biting) while the power-law "
                    "profile's knee scales by a factor close to two per doubling. "
                    "This makes concrete the theoretical claim that the two tail "
                    "classes are separated by an unbounded factor rather than a "
                    "constant, and that a single doubling of the context suffices to "
                    "decide which class a corpus inhabits."
                ),
                "code": read(ASSETS, "demo_context_doubling.py"),
            },
        ],
        "algorithms": [
            {
                "name": "Ceiling-Law Reconstruction of Domain Knees from a Master Profile",
                "description": (
                    "Given a master knee B and a vector of integer tax exponents "
                    "(m_1, ..., m_n), the root-of-ratio law states that the knee "
                    "observed in domain j is exactly ceil(B / m_j). This algorithm "
                    "evaluates the reconstruction, compares it entry by entry with a "
                    "measured table, and certifies the sharp two-sided bound "
                    "B <= m*ceil(B/m) < B + m for each domain, which is the exact "
                    "statement of how much the ceiling can hide. The mathematical "
                    "foundation is the adjunction ceil(a/m) <= n if and only if "
                    "a <= mn, from which the law follows by comparing down-sets. "
                    "Complexity is O(n) integer operations for n domains, with no "
                    "floating-point arithmetic and hence no rounding risk."
                ),
                "pseudocode": (
                    "INPUT : master knee B, exponents m[1..n], measured knees v[1..n]\n"
                    "OUTPUT: predicted knees, residuals, two-sided certificates\n"
                    "\n"
                    "1. for j = 1 to n:\n"
                    "2.     p[j] <- CEILDIV(B, m[j])            # = -((-B) div m[j])\n"
                    "3.     residual[j] <- p[j] - v[j]\n"
                    "4.     assert B <= m[j] * p[j] < B + m[j]  # sharp two-sided bound\n"
                    "5. exact_match <- (residual[j] = 0 for all j)\n"
                    "6. return (p, residual, exact_match)"
                ),
                "code": read(ASSETS, "alg_knee_reconstruction.py"),
            },
            {
                "name": "Exhaustive Master-Knee Search under a Finite Exponent Bound",
                "description": (
                    "Decides, for each candidate master knee B, whether some choice "
                    "of integer tax exponents reproduces every entry of the measured "
                    "table, and returns the least such B. A priori the exponent "
                    "ranges over all positive integers, so the search is infinite; it "
                    "is made finite by the exponent bound, which states that if "
                    "ceil(B/m) = v with v >= 2 then m <= B (otherwise m > B forces "
                    "ceil(B/m) <= 1 < v). Every table entry is at least 2, so testing "
                    "m = 1, ..., B suffices. The covering predicate therefore costs "
                    "O(B) integer operations per entry and O(B^2) to scan all masters "
                    "up to B. A companion routine computes the exact solution set for "
                    "a fixed exponent vector by intersecting the half-open intervals "
                    "m(v-1) < B <= mv, in O(n) time."
                ),
                "pseudocode": (
                    "INPUT : table entries v[1..n] (each >= 2), search limit L\n"
                    "OUTPUT: least master knee covering the table, or NONE\n"
                    "\n"
                    "1. function REALIZES(B, v):\n"
                    "2.     for m = 1 to B:                     # finite by exponent bound\n"
                    "3.         if CEILDIV(B, m) = v: return TRUE\n"
                    "4.     return FALSE\n"
                    "\n"
                    "5. function COVERS(B):\n"
                    "6.     return REALIZES(B, v[j]) for all j\n"
                    "\n"
                    "7. for B = 0 to L:\n"
                    "8.     if COVERS(B): return B\n"
                    "9. return NONE\n"
                    "\n"
                    "-- exact solution set for a FIXED exponent vector m[1..n]:\n"
                    "10. lo <- 0 ; hi <- +infinity\n"
                    "11. for j = 1 to n:\n"
                    "12.     lo <- max(lo, m[j]*(v[j]-1) + 1)   # interval form of the\n"
                    "13.     hi <- min(hi, m[j]*v[j])           # ceiling equation\n"
                    "14. return { lo, lo+1, ..., hi }           # = {118, 119, 120}"
                ),
                "code": read(ASSETS, "alg_master_search.py"),
            },
            {
                "name": "Bracket-and-Bisect Refinement of a Coarse Knee Measurement",
                "description": (
                    "Converts a coarse grid measurement into a rigorous bracket and "
                    "then closes it optimally. Because retention is monotone, a "
                    "failing probe at a and a passing probe at b certify a < k* <= b, "
                    "and a coarse grid can therefore only ever over-provision, never "
                    "under-provision. The bracket is closed by bisection on the "
                    "monotone predicate 'retained mass at k reaches the gate', using "
                    "ceil(log2(b - a)) further probes, which is optimal for any "
                    "comparison-based search. Applied to the reported French data "
                    "(retained 0.9795 at k = 36, 0.9830 at k = 40, gate 0.98), the "
                    "bracket is 36 < k* <= 40 and just two additional probes decide "
                    "between the theoretically admissible values 39 and 40."
                ),
                "pseudocode": (
                    "INPUT : grid measurements {k -> R(k)}, gate tau, oracle R(.)\n"
                    "OUTPUT: exact knee k*, number of extra probes used\n"
                    "\n"
                    "1. a <- max { k in grid : R(k) <  tau }    # highest failing probe\n"
                    "2. b <- min { k in grid : R(k) >= tau }    # lowest passing probe\n"
                    "3. assert a < b                            # bracket a < k* <= b\n"
                    "4. probes <- 0\n"
                    "5. while b - a > 1:\n"
                    "6.     mid <- floor((a + b) / 2)\n"
                    "7.     probes <- probes + 1\n"
                    "8.     if R(mid) >= tau: b <- mid\n"
                    "9.     else:             a <- mid\n"
                    "10. return (b, probes)                     # worst case ceil(log2(b-a))"
                ),
                "code": read(ASSETS, "alg_grid_refine.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Five-Domain Knee Table and Its Ceiling-Law Reconstruction",
                "description": (
                    "Left panel: retention curves R(k) = 1 - r^k for five geometric "
                    "profiles calibrated so that their knees at gate 0.98 are exactly "
                    "the measured values 12, 20, 20, 24 and 40, with each knee marked "
                    "where the curve crosses the gate. Right panel: the knees "
                    "predicted by the ceiling law from the three admissible master "
                    "knees 118, 119 and 120 under the exponent vector "
                    "(10, 6, 6, 5, 3), plotted against the measurement. All three "
                    "masters produce identical bars, making the observational "
                    "degeneracy visible at a glance."
                ),
                "code": read(ASSETS, "viz_five_domains.py"),
            },
            {
                "name": "Divergence of Additive and Multiplicative Taxes, and the Tail-Class Gap",
                "description": (
                    "Left panel: as the gate tightens, the knee of a geometric "
                    "profile and that of its m-th power diverge linearly in "
                    "log(1/t); the shaded region is the growing error of the best "
                    "fixed additive prediction, illustrating that no constant shift "
                    "can imitate a root tax. Right panel: a log-log comparison of the "
                    "geometric knee, which grows like log(1/t), with the heavy "
                    "telescoping profile's knee, which grows like 1/t, showing that "
                    "the two tail classes are separated by an unbounded factor rather "
                    "than a constant."
                ),
                "code": read(ASSETS, "viz_tax_divergence.py"),
            },
            {
                "name": "Interval Geometry of the Master Knee: Why the Answer Is a Set",
                "description": (
                    "Each ceiling equation ceil(B/m) = v is equivalent to the "
                    "half-open interval condition m(v-1) < B <= mv. This figure draws "
                    "the four intervals arising from the exponent vector (10, 6, 5, 3) "
                    "and the table entries (12, 20, 24, 40), then their intersection, "
                    "which collapses to the three integers 118, 119 and 120. It makes "
                    "visually obvious that all four intervals share the right endpoint "
                    "120 -- which is exactly why exact divisibility appears to single "
                    "that value out -- while the binding constraint is the left "
                    "endpoint 117."
                ),
                "code": read(ASSETS, "viz_master_intervals.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Knee Laboratory: Watch a Delay and a Root Tax Come Apart",
                "description": (
                    "An interactive canvas showing three retention curves at once: a "
                    "geometric profile with decay ratio r, the same profile taxed by "
                    "an m-th power of its ratio, and the same profile delayed by d "
                    "massless positions. Sliders control the ratio, the gate, the "
                    "root exponent and the delay. A live panel reports the fine knee "
                    "B, the coarse knee A, the delayed knee and the real-valued ideal "
                    "knee, and checks four laws in real time: the ceiling root law "
                    "A = ceil(B/m), the sharp two-sided bound B <= mA < B + m, the "
                    "exactness criterion (B = mA exactly when m divides B), and the "
                    "closed form B = ceil(log t / log r). Dragging the gate towards 1 "
                    "makes the central phenomenon self-evident: the delayed curve "
                    "keeps a constant distance d forever, while the root-taxed curve "
                    "pulls away without limit, so no fixed additive constant can ever "
                    "describe a multiplicative tax."
                ),
                "html": read(ASSETS, "widget_knee_lab.html"),
            },
            {
                "title": "The Master Knee Explorer: Three Masters, One Fingerprint",
                "description": (
                    "A slider sweeps the candidate master knee B while a live table "
                    "evaluates ceil(B/m) for each domain's tax exponent and marks "
                    "each entry against the measured value, delivering an immediate "
                    "verdict on whether that master reproduces the whole five-domain "
                    "table. Beneath it, an interval strip renders the geometry behind "
                    "the verdict: each ceiling equation ceil(B/m) = v is the "
                    "half-open interval m(v-1) < B <= mv, and their intersection is "
                    "drawn in red, containing exactly the three integers 118, 119 and "
                    "120. Users discover for themselves that the frequently quoted "
                    "master 120 is merely the shared right endpoint of the four "
                    "intervals, and that the measurement cannot distinguish it from "
                    "118 or 119 -- a genuine gauge freedom rather than measurement "
                    "noise."
                ),
                "html": read(ASSETS, "widget_master_knee.html"),
            },
        ],
        "interactive_layout": read(ASSETS, "interactive_layout.md"),
        "lean_proofs": lean_source(),
        "future_directions": read(ASSETS, "future_directions.md"),
        "modules": {"demo": demo_py},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"wrote {out} ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    main()


"""Context doubling as a tail-class discriminator.

The theory predicts a sharp experimental signature. If a domain's attention
profile has a geometric tail, its knee grows like log(1/t) and responds to a
doubling of the context length by an *additive* shift.  If the tail is a power
law, the knee grows like a power of 1/t and responds by a *multiplicative*
factor.  Because the two classes are separated by an unbounded factor rather
than a constant, one doubling suffices to tell them apart.

This script simulates both classes, truncates each profile at a sequence of
context lengths, renormalises, and reports the knee response.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple


def geometric_weights(n: int, r: float) -> List[float]:
    """Truncated geometric profile of length n, renormalised to total mass 1."""
    raw = [r**i for i in range(n)]
    s = math.fsum(raw)
    return [x / s for x in raw]


def power_law_weights(n: int, alpha: float) -> List[float]:
    """Truncated power-law (Zipf-like) profile of length n, renormalised."""
    raw = [(i + 1.0) ** (-alpha) for i in range(n)]
    s = math.fsum(raw)
    return [x / s for x in raw]


def knee(weights: Sequence[float], gate: float) -> int:
    """Least k whose cumulative mass reaches the gate; len(weights) if never."""
    total = 0.0
    for k, w in enumerate(weights):
        total += w
        if total >= gate:
            return k + 1
    return len(weights)


def response_table(
    builder: Callable[[int], List[float]], gate: float, contexts: Sequence[int]
) -> List[Tuple[int, int, float, int]]:
    """(context, knee, knee ratio vs previous, knee difference vs previous)."""
    out: List[Tuple[int, int, float, int]] = []
    prev: int = 0
    for n in contexts:
        k = knee(builder(n), gate)
        ratio = (k / prev) if prev else float("nan")
        diff = (k - prev) if prev else 0
        out.append((n, k, ratio, diff))
        prev = k
    return out


def main() -> None:
    gate = 0.98
    contexts = [512, 1024, 2048, 4096, 8192]

    print(f"gate tau = {gate}\n")
    print("GEOMETRIC TAIL  (r = 0.90):  expect an ADDITIVE response")
    print(f"  {'context':>8} {'knee':>6} {'ratio':>8} {'difference':>11}")
    for n, k, ratio, diff in response_table(
        lambda n: geometric_weights(n, 0.90), gate, contexts
    ):
        print(f"  {n:>8} {k:>6} {ratio:>8.3f} {diff:>11}")

    print("\nPOWER-LAW TAIL  (alpha = 1.2):  expect a MULTIPLICATIVE response")
    print(f"  {'context':>8} {'knee':>6} {'ratio':>8} {'difference':>11}")
    for n, k, ratio, diff in response_table(
        lambda n: power_law_weights(n, 1.2), gate, contexts
    ):
        print(f"  {n:>8} {k:>6} {ratio:>8.3f} {diff:>11}")

    print("\nInterpretation: a geometric-class domain settles to a bounded knee")
    print("(the additive response saturates once the truncation stops biting),")
    print("while a polynomial-class domain keeps scaling its knee with the")
    print("context. One doubling of the context separates the two classes.")


if __name__ == "__main__":
    main()


"""Visualization: retention curves and knees for the five-domain table.

Each domain is modelled as a geometric profile whose ratio is chosen so that
its knee at the gate tau = 0.98 matches the measured value (code 12,
English prose 20, mathematics 20, German prose 24, French prose 40).  The plot
overlays the retention curves R(k) = 1 - r^k, marks each knee where the curve
crosses the gate, and annotates the two structural claims visible in the data:
German = English + 4 (additive) and French = 2 x English (multiplicative).
"""

from __future__ import annotations

import math
from typing import Dict, List

import matplotlib.pyplot as plt
import numpy as np


def ratio_for_knee(knee: int, gate: float) -> float:
    """Geometric ratio whose knee at this gate is exactly the given integer."""
    return float(np.exp(math.log(1.0 - gate) / knee))


def main() -> None:
    gate = 0.98
    table: Dict[str, int] = {
        "code": 12,
        "English prose": 20,
        "mathematics": 20,
        "German prose": 24,
        "French prose": 40,
    }
    colors = ["#2e7d32", "#1565c0", "#6a1b9a", "#ef6c00", "#c62828"]

    ks = np.arange(0, 65)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    for (name, knee), color in zip(table.items(), colors):
        r = ratio_for_knee(knee, gate)
        curve = 1.0 - r**ks
        ax1.plot(ks, curve, label=f"{name}  (k*={knee})", color=color, lw=2)
        ax1.plot([knee], [gate], "o", color=color, ms=7)
        ax1.vlines(knee, 0, gate, color=color, ls=":", lw=1)

    ax1.axhline(gate, color="black", ls="--", lw=1)
    ax1.text(1, gate + 0.004, f"gate $\\tau = {gate}$", fontsize=9)
    ax1.set_xlabel("positions retained, $k$")
    ax1.set_ylabel("retained mass $R(k)$")
    ax1.set_ylim(0.5, 1.005)
    ax1.set_title("Retention curves and knees at a fixed gate")
    ax1.legend(loc="lower right", fontsize=9)
    ax1.grid(alpha=0.25)

    # Right panel: the ceiling-law reconstruction from a master knee.
    masters: List[int] = [118, 119, 120]
    exponents = [10, 6, 6, 5, 3]
    names = list(table.keys())
    width = 0.25
    x = np.arange(len(names))
    for j, master in enumerate(masters):
        predicted = [-((-master) // m) for m in exponents]
        ax2.bar(x + (j - 1) * width, predicted, width,
                label=f"master $B={master}$", alpha=0.85)
    ax2.plot(x, list(table.values()), "k*", ms=14, label="measured", zorder=5)
    ax2.set_xticks(x)
    ax2.set_xticklabels([n.replace(" ", "\n") for n in names], fontsize=9)
    ax2.set_ylabel("knee $\\lceil B/m\\rceil$")
    ax2.set_title("Three masters, one fingerprint: $B \\in \\{118,119,120\\}$")
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.25, axis="y")

    fig.suptitle("The five-domain knee table and its ceiling-law reconstruction",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("five_domain_knees.png", dpi=160)
    print("wrote five_domain_knees.png")


if __name__ == "__main__":
    main()


"""Visualization: the master knee is pinned only to a three-element set.

Each ceiling equation ceil(B/m) = v is equivalent to the half-open interval
condition m(v-1) < B <= m v.  Plotting the four intervals coming from the
exponent vector (10, 6, 5, 3) and the table entries (12, 20, 24, 40) shows the
intersection collapsing to {118, 119, 120}: the measured table determines the
master knee only up to this residual gauge freedom, and the frequently quoted
value 120 is simply the right endpoint, not a distinguished solution.
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt


def main() -> None:
    constraints: List[Tuple[int, int]] = [(10, 12), (6, 20), (5, 24), (3, 40)]
    fig, ax = plt.subplots(figsize=(11, 4.6))

    lo_all, hi_all = 0, 10**9
    for i, (m, v) in enumerate(constraints):
        lo, hi = m * (v - 1) + 1, m * v
        lo_all, hi_all = max(lo_all, lo), min(hi_all, hi)
        ax.hlines(i, lo, hi, lw=10, color="#1565c0", alpha=0.65)
        ax.plot([lo], [i], marker="|", ms=18, color="#0d47a1")
        ax.plot([hi], [i], marker="|", ms=18, color="#0d47a1")
        ax.text(lo - 1.5, i, f"$\\lceil B/{m}\\rceil={v}$", ha="right",
                va="center", fontsize=10)
        ax.text((lo + hi) / 2, i + 0.28, f"${lo - 1} < B \\leq {hi}$",
                ha="center", fontsize=9)

    solutions = list(range(lo_all, hi_all + 1))
    ax.hlines(len(constraints), lo_all, hi_all, lw=14, color="#c62828")
    ax.text(lo_all - 1.5, len(constraints), "intersection", ha="right",
            va="center", fontsize=11, fontweight="bold")
    for b in solutions:
        ax.plot([b], [len(constraints)], "o", color="white", ms=6, zorder=4)
        ax.text(b, len(constraints) + 0.32, str(b), ha="center", fontsize=10)

    ax.set_yticks([])
    ax.set_xlim(105, 126)
    ax.set_ylim(-0.7, len(constraints) + 0.9)
    ax.set_xlabel("candidate master knee $B$")
    ax.set_title("Gauge freedom of the master knee: the admissible set is "
                 "$\\{118, 119, 120\\}$")
    ax.grid(alpha=0.25, axis="x")
    fig.tight_layout()
    fig.savefig("master_intervals.png", dpi=160)
    print("wrote master_intervals.png; solution set =", solutions)


if __name__ == "__main__":
    main()


"""Visualization: an additive delay can never imitate a multiplicative tax.

Left panel: as the gate tightens (tail budget t -> 0), the knee of a geometric
profile with ratio r and that of its m-th power diverge linearly in
log(1/t), so their difference is unbounded; an additive tax of any fixed size d
tracks a constant gap and is eventually wrong by an arbitrary amount.

Right panel: the two tail classes.  A geometric profile has knee ~ log(1/t)
while the heavy telescoping profile w_i = 1/((i+1)(i+2)) has knee ~ 1/t, so the
separation between the classes is an unbounded factor rather than a constant.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def kgeom(r: float, t: float) -> int:
    """Least k with r^k <= t."""
    return max(0, math.ceil(math.log(t) / math.log(r)))


def main() -> None:
    r, m, d = 0.9, 2, 4
    ts = np.logspace(-1, -12, 200)
    fine = np.array([kgeom(r, t) for t in ts], dtype=float)
    coarse = np.array([kgeom(r**m, t) for t in ts], dtype=float)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.0))

    logs = np.log10(1.0 / ts)
    ax1.plot(logs, fine, label=f"fine knee, ratio $r={r}$", color="#c62828", lw=2)
    ax1.plot(logs, coarse, label=f"coarse knee, ratio $r^{m}$", color="#1565c0", lw=2)
    ax1.plot(logs, coarse + d, ls="--", color="#1565c0",
             label=f"additive prediction, $+{d}$")
    ax1.fill_between(logs, coarse + d, fine, where=fine > coarse + d,
                     color="#c62828", alpha=0.15,
                     label="error of the additive law")
    ax1.set_xlabel("gate tightness  $\\log_{10}(1/t)$")
    ax1.set_ylabel("knee")
    ax1.set_title("No fixed additive constant reproduces a root tax")
    ax1.legend(fontsize=9)
    ax1.grid(alpha=0.25)

    # Tail classes.
    heavy_knee: List[float] = [1.0 / t for t in ts]
    ax2.loglog(1.0 / ts, fine, color="#1565c0", lw=2,
               label="geometric tail:  $k^* = \\Theta(\\log(1/t))$")
    ax2.loglog(1.0 / ts, heavy_knee, color="#ef6c00", lw=2,
               label="heavy tail:  $k^* = \\Theta(1/t)$")
    ax2.set_xlabel("$1/t$")
    ax2.set_ylabel("knee")
    ax2.set_title("Tail classes are separated by an unbounded factor")
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.25, which="both")

    fig.suptitle("Additive versus multiplicative taxes, and the tail-class dichotomy",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("tax_divergence.png", dpi=160)
    print("wrote tax_divergence.png")


if __name__ == "__main__":
    main()
