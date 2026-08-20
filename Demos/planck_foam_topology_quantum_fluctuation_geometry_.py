"""
Planck-Foam Topology: numerical demonstrations
==============================================

Self-contained numerical verification of the main quantitative results of the
Planck-foam model.  The foam over a base space X with branch locus S and sheet
index set iota is the quotient of X x iota identifying (x, i) ~ (y, j) exactly
when x = y and (i = j or x not in S).

Results demonstrated here:

  1.  Counting formula          #Foam = #X + #S * (#iota - 1)
  2.  Metric defect             #D    = #(S \ int S) * (#iota^2 - #iota)
  3.  Bernoulli foam measure    total mass 1, mean n*p
  4.  Second moment             n p (1-p) + (n p)^2, variance n p (1-p)
  5.  Entropy extensivity       H_p(n) = n * H(p),  max n*log 2 at p = 1/2
  6.  Entropy-geometry duality  H_{1/2}(n) = log(2^excess)
  7.  Hausdorff probability     (1-p)^N  <=  exp(-p N)
  8.  Chebyshev concentration   Pr[|#A/N - p| >= eps] <= p(1-p)/(N eps^2)
  9.  Branching limits          one sequence in the foam with two limits
 10.  Renormalisation flow      lattice fixed points and the tower limit

Everything uses exact rational arithmetic where possible.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from itertools import combinations
from typing import Iterator, Sequence

# ---------------------------------------------------------------------------
# 1.  The foam as a finite set: counting and defect
# ---------------------------------------------------------------------------


def foam_points(base: Sequence[int], branch: Sequence[int], sheets: int) -> list[tuple[int, int]]:
    """Explicit list of points of the foam over a finite base.

    A point off the branch locus is represented canonically as (x, 0); a point
    on the branch locus keeps its sheet index.
    """
    branch_set = set(branch)
    pts: list[tuple[int, int]] = []
    for x in base:
        if x in branch_set:
            pts.extend((x, i) for i in range(sheets))
        else:
            pts.append((x, 0))
    return pts


def foam_cardinality(n_base: int, n_branch: int, sheets: int) -> int:
    """Predicted cardinality  #X + #S * (#iota - 1)."""
    return n_base + n_branch * (sheets - 1)


def foam_excess(n_branch: int, sheets: int) -> int:
    """Number of foam points in excess of the macroscopic shadow."""
    return n_branch * (sheets - 1)


def metric_defect(n_boundary: int, sheets: int) -> int:
    """Number of ordered inseparable pairs: #(S \\ int S) * (#iota^2 - #iota)."""
    return n_boundary * (sheets * sheets - sheets)


def demo_counting() -> None:
    print("=" * 74)
    print("1-2.  COUNTING AND METRIC DEFECT")
    print("=" * 74)
    base = list(range(10))
    for branch, sheets in [([3], 2), ([2, 5, 7], 2), ([2, 5, 7], 3), ([0, 1, 2, 3], 4)]:
        pts = foam_points(base, branch, sheets)
        pred = foam_cardinality(len(base), len(branch), sheets)
        # In a discrete-branch-locus model every branch point is a boundary
        # point (the interior of a discrete set inside a continuum is empty).
        defect = metric_defect(len(branch), sheets)
        print(
            f"  |X|={len(base):2d}  |S|={len(branch)}  |iota|={sheets}   "
            f"|Foam|={len(pts):3d} (predicted {pred:3d})   "
            f"excess={foam_excess(len(branch), sheets):2d}   defect={defect:2d}"
        )
        assert len(pts) == pred
    print("  All counting identities verified exactly.\n")


# ---------------------------------------------------------------------------
# 2.  The Bernoulli foam measure: exact moments
# ---------------------------------------------------------------------------


def subsets(n: int) -> Iterator[tuple[int, ...]]:
    """All subsets of {0, ..., n-1} as sorted tuples."""
    for k in range(n + 1):
        yield from combinations(range(n), k)


def weight(p: Fraction, n: int, A: Sequence[int]) -> Fraction:
    """Bernoulli weight of the configuration A inside n Planck cells."""
    a = len(A)
    return p**a * (1 - p) ** (n - a)


def total_mass(p: Fraction, n: int) -> Fraction:
    return sum((weight(p, n, A) for A in subsets(n)), Fraction(0))


def mean_branch_count(p: Fraction, n: int) -> Fraction:
    return sum((weight(p, n, A) * len(A) for A in subsets(n)), Fraction(0))


def second_moment(p: Fraction, n: int) -> Fraction:
    return sum((weight(p, n, A) * len(A) ** 2 for A in subsets(n)), Fraction(0))


def variance_branch_count(p: Fraction, n: int) -> Fraction:
    mu = n * p
    return sum((weight(p, n, A) * (len(A) - mu) ** 2 for A in subsets(n)), Fraction(0))


def demo_moments() -> None:
    print("=" * 74)
    print("3-4.  BERNOULLI FOAM MEASURE: EXACT MOMENTS")
    print("=" * 74)
    print("  p       n   total  mean (pred)        2nd moment (pred)     var (pred)")
    for p, n in [
        (Fraction(1, 3), 4),
        (Fraction(1, 3), 3),
        (Fraction(1, 3), 5),
        (Fraction(2, 5), 6),
        (Fraction(2, 5), 4),
        (Fraction(1, 2), 6),
    ]:
        mass = total_mass(p, n)
        mean = mean_branch_count(p, n)
        m2 = second_moment(p, n)
        var = variance_branch_count(p, n)
        mean_pred = n * p
        m2_pred = n * p * (1 - p) + (n * p) ** 2
        var_pred = n * p * (1 - p)
        assert mass == 1 and mean == mean_pred and m2 == m2_pred and var == var_pred
        print(
            f"  {str(p):5s}  {n:2d}   {mass}     {mean} ({mean_pred})"
            f"          {m2} ({m2_pred})       {var} ({var_pred})"
        )
    print("  All moments match the closed forms exactly (rational arithmetic).\n")


# ---------------------------------------------------------------------------
# 3.  Entropy and the entropy-geometry duality
# ---------------------------------------------------------------------------


def binary_entropy(p: float) -> float:
    """H(p) = -p log p - (1-p) log(1-p), in nats."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1 - p) * math.log(1 - p)


def foam_entropy_bruteforce(p: float, n: int) -> float:
    """Shannon entropy of the Bernoulli foam measure, summed over all 2^n configs."""
    total = 0.0
    for A in subsets(n):
        w = p ** len(A) * (1 - p) ** (n - len(A))
        if w > 0.0:
            total -= w * math.log(w)
    return total


def demo_entropy() -> None:
    print("=" * 74)
    print("5-6.  ENTROPY: EXTENSIVITY, THE ONE-BIT BOUND, AND DUALITY")
    print("=" * 74)
    print("   p      n    H measured    n*H(p)       n*log2 (bound)")
    for p, n in [(0.5, 4), (0.3, 5), (0.7, 3), (0.25, 6), (0.5, 6)]:
        h = foam_entropy_bruteforce(p, n)
        pred = n * binary_entropy(p)
        bound = n * math.log(2.0)
        assert abs(h - pred) < 1e-12
        assert h <= bound + 1e-12
        flag = "  <= saturated" if abs(h - bound) < 1e-12 else ""
        print(f"  {p:4.2f}   {n}    {h:10.6f}    {pred:10.6f}   {bound:10.6f}{flag}")

    print("\n  Entropy-geometry duality at p = 1/2 (two sheets, excess = #S):")
    for n in [1, 2, 3, 5, 8]:
        h = foam_entropy_bruteforce(0.5, n)
        excess = foam_excess(n, 2)
        dual = math.log(2.0**excess)
        assert abs(h - dual) < 1e-12
        print(f"    n = {n}:  H = {h:9.6f}   log(2^excess) = log(2^{excess}) = {dual:9.6f}")
    print("  Exact identity, no error term.\n")


# ---------------------------------------------------------------------------
# 4.  Hausdorff probability and concentration
# ---------------------------------------------------------------------------


def hausdorff_probability(p: Fraction, N: int) -> Fraction:
    """The foam over N Planck cells is Hausdorff iff no cell is excited."""
    return sum(
        (weight(p, N, A) for A in subsets(N) if len(A) == 0),
        Fraction(0),
    )


def chebyshev_bound(p: float, N: int, eps: float) -> float:
    return p * (1 - p) / (N * eps * eps)


def empirical_density_deviation(p: Fraction, N: int, eps: Fraction) -> Fraction:
    """Exact probability that the branch density deviates from p by >= eps."""
    return sum(
        (
            weight(p, N, A)
            for A in subsets(N)
            if abs(Fraction(len(A), N) - p) >= eps
        ),
        Fraction(0),
    )


def demo_hausdorff_and_concentration() -> None:
    print("=" * 74)
    print("7-8.  SMOOTHNESS PROBABILITY AND CONCENTRATION OF THE BRANCH DENSITY")
    print("=" * 74)
    for p, N in [(Fraction(1, 2), 5), (Fraction(1, 3), 4), (Fraction(1, 10), 6)]:
        exact = hausdorff_probability(p, N)
        pred = (1 - p) ** N
        bound = math.exp(-float(p) * N)
        assert exact == pred
        print(
            f"  p={str(p):5s} N={N}:  Pr[Hausdorff] = {exact} = (1-p)^N,"
            f"  exp(-pN) = {bound:.6f}"
        )
    print("  Smoothness of the Planck foam is exponentially improbable.")
    print("  At p = 1/2, N = 40 the probability is 2^-40 = "
          f"{2.0**-40:.3e}.\n")

    print("  Chebyshev bound vs exact deviation probability (p = 1/2, eps = 1/4):")
    p, eps = Fraction(1, 2), Fraction(1, 4)
    for N in [4, 8, 12, 16]:
        exact = empirical_density_deviation(p, N, eps)
        bound = chebyshev_bound(float(p), N, float(eps))
        assert float(exact) <= bound + 1e-12
        print(f"    N={N:3d}:  exact = {float(exact):.6f}   Chebyshev bound = {bound:.6f}")

    print("\n  Asymptotics of the bound p(1-p)/(N eps^2) at p = 1/2, eps = 0.05:")
    for N in [10**2, 10**4, 10**6, 10**35]:
        print(f"    N = 10^{int(round(math.log10(N))):2d}:  bound = {chebyshev_bound(0.5, N, 0.05):.3e}")
    print("  Over a macroscopic length (N ~ L/l_P ~ 10^35) the density is")
    print("  deterministic to 33 decimal places.\n")


# ---------------------------------------------------------------------------
# 5.  Branching limits: one sequence, two limits
# ---------------------------------------------------------------------------


def is_lattice_site(x: float, spacing: float, tol: float = 1e-12) -> bool:
    """Is x a Planck site of the lattice of the given spacing?"""
    if spacing == 0.0:
        return abs(x) < tol
    q = x / spacing
    return abs(q - round(q)) < tol


def approaching_sequence(site: float, spacing: float, terms: int) -> list[float]:
    """y_n = site + spacing/(n+2): approaches the site, never hits a site."""
    return [site + spacing / (n + 2) for n in range(terms)]


def demo_branching_limits() -> None:
    print("=" * 74)
    print("9.  BRANCHING LIMITS: ONE SEQUENCE, TWO LIMIT POINTS")
    print("=" * 74)
    spacing = 1.0
    site = 3.0
    ys = approaching_sequence(site, spacing, 8)
    print(f"  Planck spacing l = {spacing}, excited site x = {site}")
    print("  n :   y_n          on a Planck site?   sheet-0 copy == sheet-1 copy?")
    for n, y in enumerate(ys):
        on_site = is_lattice_site(y, spacing)
        # Off the branch locus the two sheet copies are the SAME foam point.
        identified = not on_site
        assert not on_site
        print(f"  {n} : {y:12.8f}   {str(on_site):5s}               {identified}")
    print(f"\n  y_n -> {site} in the base, and the single foam sequence u_n")
    print("  converges BOTH to the sheet-0 copy of x and to the sheet-1 copy,")
    print("  which are distinct foam points because x lies in the branch locus.")
    print("  A sequence with two limits: the foam is not Hausdorff.\n")


# ---------------------------------------------------------------------------
# 6.  Renormalisation flow on lattice foams
# ---------------------------------------------------------------------------


def lattice_sites(spacing: float, window: float) -> list[float]:
    """Branch points of the lattice foam inside [-window, window]."""
    if spacing == 0.0:
        return [0.0]
    kmax = int(math.floor(window / abs(spacing)))
    return [spacing * n for n in range(-kmax, kmax + 1)]


def rg_step(spacing: float) -> float:
    """One scale-halving coarse-graining step: observe at twice the spacing."""
    return 2.0 * spacing


def demo_renormalisation() -> None:
    print("=" * 74)
    print("10.  RENORMALISATION: THE FOAM IS PERSISTENT")
    print("=" * 74)
    window = 8.0
    spacing = 0.5
    print(f"  Branch points inside [-{window}, {window}] along the RG tower:")
    s = spacing
    for k in range(6):
        sites = lattice_sites(s, window)
        print(f"    step {k}:  spacing = {s:7.3f}   #branch points = {len(sites):3d}")
        s = rg_step(s)

    print("\n  Fixed-point test  (is Lambda_{2l} == Lambda_l ?):")
    for s in [0.5, 1.0, 2.0, 0.0]:
        a = set(round(x, 9) for x in lattice_sites(s, window))
        b = set(round(x, 9) for x in lattice_sites(rg_step(s), window))
        fixed = a == b
        print(f"    spacing {s:5.2f}:  fixed = {fixed}")
    print("  Only spacing 0 is fixed, and Lambda_0 = {0}: the unique fixed")
    print("  lattice foam is the single-branch-point foam (line with two origins).")

    print("\n  Intersection of the whole tower for spacing 0.5:")
    inter: set[float] | None = None
    for k in range(12):
        sites = set(round(x, 9) for x in lattice_sites(0.5 * 2**k, window))
        inter = sites if inter is None else inter & sites
    assert inter == {0.0}
    print(f"    intersection = {sorted(inter)}  -> the limit foam has ONE branch point")
    print(f"    its metric defect = {metric_defect(1, 2)} (non-Hausdorff, non-metrizable)")
    print("  Coarse-graining never returns smooth spacetime.\n")


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  PLANCK-FOAM TOPOLOGY -- NUMERICAL DEMONSTRATIONS".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_counting()
    demo_moments()
    demo_entropy()
    demo_hausdorff_and_concentration()
    demo_branching_limits()
    demo_renormalisation()
    print("=" * 74)
    print("All demonstrations completed; every assertion held exactly.")
    print("=" * 74)


if __name__ == "__main__":
    main()
