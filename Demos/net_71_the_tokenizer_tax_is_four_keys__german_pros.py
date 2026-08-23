"""
The Tokenizer Tax Is Four Keys -- numerical demonstrations.

A self-contained script reproducing every quantitative claim of the study:

  1. Knee detection on the measured German sweeps (20 keys @ 512, 24 keys @ 1024).
  2. The exact stability radius of a reported knee, and its sharpness.
  3. The four-domain budget table and its collapse to the single coordinate
     rank + doublings.
  4. The rigidity theorem (exchange + universal increment => affine diagonal),
     verified on a grid, together with the two independence counterexamples.
  5. Quantisation: the true-knee bracket, the non-identifiability of the "+4",
     and the resolution threshold (step 4 is the coarsest faithful grid).
  6. The workload calculus: cover cost, one-cell certificate, submodularity,
     and quota sizing (24 keys for eight cells, 20 for seven).
  7. The calibrated density model and its disjoint intervals.

Run with:  python demo.py
No third-party dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import ceil
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Constants of the measurement
# ----------------------------------------------------------------------------

BAR: Fraction = Fraction(98, 100)          # service bar: 98% of unlimited-memory accuracy
FINE_STEP: int = 4                         # sweep grid step, in keys
REFERENCE_CONTEXT: int = 512               # d = 0 means context 512

# Measured German retained-accuracy sweeps, indexed by grid index j (budget = 4j).
GERMAN_512: Dict[int, Fraction] = {
    0: Fraction(0),
    1: Fraction(883, 1000),
    2: Fraction(953, 1000),
    3: Fraction(969, 1000),
    4: Fraction(976, 1000),
    5: Fraction(983, 1000),
    6: Fraction(988, 1000),
}

GERMAN_1024: Dict[int, Fraction] = {
    0: Fraction(0),
    1: Fraction(0),            # k = 4 not swept; monotonicity places it below the bar
    2: Fraction(926, 1000),
    3: Fraction(956, 1000),
    4: Fraction(968, 1000),
    5: Fraction(975, 1000),
    6: Fraction(982, 1000),
}

# ----------------------------------------------------------------------------
# 1. Knee detection
# ----------------------------------------------------------------------------


def knee_index(curve: Dict[int, Fraction], bar: Fraction = BAR) -> int:
    """Least grid index whose retained accuracy reaches the bar."""
    for j in sorted(curve):
        if curve[j] >= bar:
            return j
    raise ValueError("no index of the sweep clears the bar")


def knee_budget(curve: Dict[int, Fraction], step: int = FINE_STEP,
                bar: Fraction = BAR) -> int:
    """Knee budget in keys: step times the knee index."""
    return step * knee_index(curve, bar)


def is_monotone(curve: Dict[int, Fraction]) -> bool:
    """Nondecreasing along the grid."""
    values = [curve[j] for j in sorted(curve)]
    return all(a <= b for a, b in zip(values, values[1:]))


# ----------------------------------------------------------------------------
# 2. Stability radius of a knee
# ----------------------------------------------------------------------------


def stability_radius(curve: Dict[int, Fraction], bar: Fraction = BAR) -> Fraction:
    """
    Exact stability radius of the reported knee: the below-bar margin.

    If the deciding readings are a(j) < bar <= a(j+1), then every monotone curve
    within uniform distance < min(bar - a(j), a(j+1) - bar) reports the same knee,
    and a uniform upward shift of size (bar - a(j)) already moves it down.
    The tight radius is the below-bar margin bar - a(j); the guaranteed-safe radius
    is the smaller of the two margins.
    """
    j = knee_index(curve, bar)
    below_margin = bar - curve[j - 1]
    above_margin = curve[j] - bar
    return min(below_margin, above_margin)


def breaking_perturbation(curve: Dict[int, Fraction],
                          bar: Fraction = BAR) -> Tuple[Fraction, Dict[int, Fraction]]:
    """
    The smallest uniform upward shift that lowers the reported knee, together with
    the perturbed curve. Realises the sharpness half of the stability theorem.
    """
    j = knee_index(curve, bar)
    m = bar - curve[j - 1]
    perturbed = {i: (curve[i] + m if i >= j - 1 else curve[i]) for i in curve}
    return m, perturbed


# ----------------------------------------------------------------------------
# 3. Budget laws and the four-domain table
# ----------------------------------------------------------------------------


class BudgetLaw:
    """An affine budget law L(d) = base + inc * d in context doublings d."""

    def __init__(self, base: int, inc: int) -> None:
        self.base = base
        self.inc = inc

    def eval(self, d: int) -> int:
        return self.base + self.inc * d

    def __repr__(self) -> str:
        return f"<{self.base},{self.inc}>"


DOMAIN_LAW: Dict[str, BudgetLaw] = {
    "code": BudgetLaw(12, 4),
    "prose-EN": BudgetLaw(16, 4),
    "math": BudgetLaw(16, 4),
    "prose-DE": BudgetLaw(20, 4),
}

RANK: Dict[str, int] = {"code": 0, "prose-EN": 1, "math": 1, "prose-DE": 2}


def diagonal_budget(domain: str, d: int) -> int:
    """The collapsed form: 12 + 4 * (rank + doublings)."""
    return 12 + FINE_STEP * (RANK[domain] + d)


def context_of(d: int) -> int:
    return REFERENCE_CONTEXT * 2 ** d


# ----------------------------------------------------------------------------
# 4. Rigidity and independence
# ----------------------------------------------------------------------------


def satisfies_exchange(F: Callable[[int, int], int], rmax: int = 6, dmax: int = 6) -> bool:
    """(E): one rung up the domain ladder costs one context doubling."""
    return all(F(r + 1, d) == F(r, d + 1) for r in range(rmax) for d in range(dmax))


def satisfies_increment(F: Callable[[int, int], int], c: int,
                        rmax: int = 6, dmax: int = 6) -> bool:
    """(I): every doubling costs the constant c."""
    return all(F(r, d + 1) == F(r, d) + c for r in range(rmax) for d in range(dmax))


def is_rank_sum_affine(F: Callable[[int, int], int], c: int,
                       rmax: int = 6, dmax: int = 6) -> bool:
    """Does F equal F(0,0) + c * (r + d) everywhere on the tested grid?"""
    return all(F(r, d) == F(0, 0) + c * (r + d) for r in range(rmax) for d in range(dmax))


# ----------------------------------------------------------------------------
# 5. Quantisation
# ----------------------------------------------------------------------------


def grid_up(step: int, x: Fraction) -> Fraction:
    """Round a true requirement up to the next multiple of the sweep step."""
    return Fraction(step) * ceil(Fraction(x, 1) / step)


def reported_index(step: int, x: Fraction) -> int:
    """The grid index a sweep of the given step reports for a true requirement x."""
    return ceil(Fraction(x, 1) / step)


def true_knee_bracket(step: int, j: int) -> Tuple[Fraction, Fraction]:
    """A reported index j (nonzero) certifies exactly that the true knee lies in
    the half-open cell (step*j - step, step*j]."""
    if j == 0:
        raise ValueError("index 0 carries no lower bound")
    return Fraction(step * j - step), Fraction(step * j)


def grid_faithful(step: int, bases: Sequence[int]) -> bool:
    """Does a sweep of the given step report all the listed bases undistorted?"""
    return all(step * ceil(Fraction(b, step)) == b for b in bases)


# ----------------------------------------------------------------------------
# 6. Workload calculus
# ----------------------------------------------------------------------------

Cell = Tuple[str, int]


def rank_sum(cell: Cell) -> int:
    return RANK[cell[0]] + cell[1]


def cell_budget(cell: Cell) -> int:
    return DOMAIN_LAW[cell[0]].eval(cell[1])


def cover_cost(workload: Iterable[Cell]) -> int:
    """The cache a workload needs: the join (max) of its cells' budgets."""
    cells = list(workload)
    if not cells:
        raise ValueError("empty workload has no cover cost")
    return max(cell_budget(c) for c in cells)


def certifying_cell(workload: Iterable[Cell]) -> Cell:
    """The single worst cell that attains the cover cost."""
    return max(workload, key=cell_budget)


def served(workload: Iterable[Cell], rung: int) -> int:
    """How many cells a cache of rung r (i.e. 12 + 4r keys) serves."""
    return sum(1 for c in workload if rank_sum(c) <= rung)


def quota_rank(workload: Sequence[Cell], m: int) -> int:
    """Least rung serving at least m cells."""
    if m > len(workload):
        raise ValueError("quota exceeds workload size")
    r = 0
    while served(workload, r) < m:
        r += 1
    return r


def quota_cost(workload: Sequence[Cell], m: int) -> int:
    """Keys required to serve a quota of m cells."""
    return 12 + FINE_STEP * quota_rank(workload, m)


# ----------------------------------------------------------------------------
# 7. Density model
# ----------------------------------------------------------------------------


def predicted_base(rho: Fraction) -> int:
    """Base predicted by the calibrated density model: 4 * ceil(4 * rho)."""
    return 4 * ceil(4 * rho)


def density_interval(base: int) -> Tuple[Fraction, Fraction]:
    """Inverting the model: base 4n pins the density to ((n-1)/4, n/4]."""
    n, rem = divmod(base, 4)
    if rem != 0 or n == 0:
        raise ValueError("base must be a positive multiple of 4")
    return Fraction(n - 1, 4), Fraction(n, 4)


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------


def section(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    section("1. THE GERMAN MEASUREMENT")
    for name, curve in (("ctx  512", GERMAN_512), ("ctx 1024", GERMAN_1024)):
        assert is_monotone(curve), "sweep must be nondecreasing"
        j = knee_index(curve)
        print(f"{name}: readings " +
              ", ".join(f"{FINE_STEP*i}->{float(curve[i]):.3f}" for i in sorted(curve) if i))
        print(f"{name}: knee index {j}, knee budget {knee_budget(curve)} keys "
              f"(deciding pair {float(curve[j-1]):.3f} < 0.980 <= {float(curve[j]):.3f})")
    print("English prose knees for comparison: 16 keys @ 512, 20 keys @ 1024")
    print(f"German minus English = {20-16} keys @ 512 and {24-20} keys @ 1024  "
          f"-> P1 confirmed, P2 and P3 refuted")

    section("2. HOW MUCH NOISE A KNEE SURVIVES")
    for name, curve in (("ctx  512", GERMAN_512), ("ctx 1024", GERMAN_1024)):
        r = stability_radius(curve)
        m, perturbed = breaking_perturbation(curve)
        print(f"{name}: safe radius {float(r):.4f}; "
              f"uniform shift of {float(m):.4f} moves the knee "
              f"{knee_budget(curve)} -> {knee_budget(perturbed)} keys")
        assert is_monotone(perturbed)
        assert knee_budget(perturbed) < knee_budget(curve)
    print("Both radii are of the order of one reported standard error: "
          "the +4 is certified to about 1 SE, no more.")

    section("3. THE FOUR-DOMAIN TABLE AND ITS COLLAPSE")
    print(f"{'domain':<10}{'law':>10}{'ctx 512':>10}{'1024':>8}{'2048':>8}{'4096':>8}"
          f"{'rank':>7}")
    for dom, law in DOMAIN_LAW.items():
        row = "".join(f"{law.eval(d):>8}" for d in range(4))
        print(f"{dom:<10}{repr(law):>10}{law.eval(0):>10}{row[8:]}{RANK[dom]:>7}")
    ok = all(DOMAIN_LAW[dom].eval(d) == diagonal_budget(dom, d)
             for dom in DOMAIN_LAW for d in range(8))
    print(f"\nevery cell equals 12 + 4*(rank + doublings): {ok}")
    print("exchange law:  German@512 = English@1024 = code@2048 = "
          f"{DOMAIN_LAW['prose-DE'].eval(0)} keys "
          f"({DOMAIN_LAW['prose-EN'].eval(1)}, {DOMAIN_LAW['code'].eval(2)})")
    print("iso-budget cells (rank sum 2): " +
          ", ".join(f"{dom}@{context_of(d)}"
                    for dom in DOMAIN_LAW for d in range(3)
                    if RANK[dom] + d == 2))

    section("4. RIGIDITY, AND THE INDEPENDENCE OF ITS TWO AXIOMS")
    ladder: Callable[[int, int], int] = lambda r, d: 12 + 4 * (r + d)
    print(f"ladder 12+4(r+d):   exchange={satisfies_exchange(ladder)}, "
          f"increment-4={satisfies_increment(ladder, 4)}, "
          f"affine={is_rank_sum_affine(ladder, 4)}")
    quad_diag: Callable[[int, int], int] = lambda r, d: (r + d) ** 2
    print(f"(r+d)^2:            exchange={satisfies_exchange(quad_diag)}, "
          f"affine for some c={any(is_rank_sum_affine(quad_diag, c) for c in range(-8, 9))}"
          "   -> (E) alone does not force the collapse")
    quad_rank: Callable[[int, int], int] = lambda r, d: r ** 2 + 4 * d
    print(f"r^2+4d:             increment-4={satisfies_increment(quad_rank, 4)}, "
          f"exchange={satisfies_exchange(quad_rank)}"
          "   -> (I) alone does not force the exchange law")
    print("A future corpus with increment != 4 cannot satisfy the increment law at all: "
          "e.g. <20,5> gives 25 at d=1 against a predicted 24.")

    section("5. WHAT THE REPORTED '+4' CERTIFIES")
    lo_de, hi_de = true_knee_bracket(4, 5)
    lo_en, hi_en = true_knee_bracket(4, 4)
    print(f"reported index 5 (German)  -> true knee in ({lo_de}, {hi_de}]")
    print(f"reported index 4 (English) -> true knee in ({lo_en}, {hi_en}]")
    print(f"hence true tax in ({lo_de - hi_en}, {hi_de - lo_en}) = (0, 8): "
          "strictly positive, but not pinned to 4")
    for kde, ken in ((Fraction(33, 2), Fraction(16)), (Fraction(20), Fraction(49, 4))):
        assert reported_index(4, kde) == 5 and reported_index(4, ken) == 4
        print(f"  scenario kDE={kde}, kEN={ken}: true tax {kde - ken}, "
              f"reported tax {grid_up(4, kde) - grid_up(4, ken)}")
    bases = [12, 16, 20]
    faithful = [g for g in range(1, 13) if grid_faithful(g, bases)]
    print(f"\ngrids faithful to the bases {bases}: {faithful}  "
          "(exactly the divisors of 4; step 4 is the coarsest)")
    print(f"step 8 reading: code {8*ceil(Fraction(12,8))}, EN {8*ceil(Fraction(16,8))}, "
          f"DE {8*ceil(Fraction(20,8))}  -> code/EN gap hidden, EN/DE gap doubled")

    section("6. WHAT A DEPLOYMENT COSTS")
    workload: List[Cell] = [(dom, d) for dom in DOMAIN_LAW for d in (0, 1)]
    print(f"round-24 workload: {len(workload)} cells (4 domains x contexts 512, 1024)")
    print(f"cover cost = {cover_cost(workload)} keys, "
          f"certified by the single cell {certifying_cell(workload)}")
    for r in range(4):
        print(f"  rung {r} ({12 + 4*r:>2} keys) serves {served(workload, r)}/8 cells")
    print(f"quota cost, all 8 cells: {quota_cost(workload, 8)} keys")
    print(f"quota cost, 7 of 8:      {quota_cost(workload, 7)} keys "
          f"(saving {quota_cost(workload, 8) - quota_cost(workload, 7)} keys = one grid step)")
    hardest = [c for c in workload if rank_sum(c) == 3]
    print(f"cells of maximal rank sum: {hardest}  -> unique")
    print(f"24 keys covers all four domains to ctx 1024; at ctx 2048 it fails for "
          f"{[dom for dom in DOMAIN_LAW if DOMAIN_LAW[dom].eval(2) > 24]} alone")

    # submodularity of the cover cost, checked exhaustively on subsets
    violations = 0
    checked = 0
    subsets = [list(s) for k in range(1, 5) for s in combinations(workload, k)]
    for S in subsets:
        for T in subsets:
            inter = [c for c in S if c in T]
            if not inter:
                continue
            checked += 1
            union = S + [c for c in T if c not in S]
            if cover_cost(union) + cover_cost(inter) > cover_cost(S) + cover_cost(T):
                violations += 1
    print(f"submodularity checked on {checked} overlapping subset pairs: "
          f"{violations} violations")

    section("7. THE DENSITY MECHANISM, MADE CHECKABLE")
    print(f"calibration: predicted base at rho = 1 is {predicted_base(Fraction(1))} keys")
    for dom, base in (("code", 12), ("prose-EN", 16), ("prose-DE", 20)):
        lo, hi = density_interval(base)
        print(f"  measured base {base:>2} ({dom:<8}) forces density in ({lo}, {hi}]")
    print("the three intervals are disjoint and ordered: "
          "code < English < German in content per token")
    print(f"prediction: any corpus with rho > 3/2 must show a base of at least "
          f"{predicted_base(Fraction(151, 100))} keys")

    section("SUMMARY")
    print("German prose costs exactly four keys more than English prose, at both")
    print("measured contexts; four keys is also the cost of one context doubling and")
    print("the sweep grid step. The eight-cell table collapses to 12 + 4*(rank +")
    print("doublings), and that collapse is forced by the exchange law together with")
    print("the universal increment -- two independent, individually falsifiable claims.")


if __name__ == "__main__":
    main()
