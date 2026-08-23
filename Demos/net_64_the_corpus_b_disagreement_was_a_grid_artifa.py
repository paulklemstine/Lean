"""
Threshold sweeps: grid artifacts, replication margins, and exact sweep capacity.

Self-contained numerical demonstration of the results of the accompanying paper.

Contents
--------
1.  Knees and grid knees; the factorisation theorem; the measured corpus row.
2.  The doubling-grid artifact bound and the underdetermination of the truth.
3.  The replication law and the certified tolerance of the measured margins.
4.  Scale invariance: absolute accuracy level does not move the knee.
5.  The logarithmic chain and the Zipf / geometric profile trichotomy.
6.  Exact sweep capacity Sigma(a*b, s), optimal grids, rigidity, and the
    product law -- each checked against brute-force enumeration.

Run with:  python3 demo.py            (no third-party dependencies)
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Callable, Iterable, Optional, Sequence

# ---------------------------------------------------------------------------
# 1. Knees and grid knees
# ---------------------------------------------------------------------------


def knee(curve: Callable[[int], Fraction], gate: Fraction, k_max: int) -> Optional[int]:
    """Least budget k in [0, k_max] with curve(k) >= gate, or None."""
    for k in range(k_max + 1):
        if curve(k) >= gate:
            return k
    return None


def grid_knee(
    grid: Iterable[int], curve: Callable[[int], Fraction], gate: Fraction
) -> Optional[int]:
    """Least *sampled* budget clearing the gate -- the only thing a sweep reports."""
    for k in sorted(grid):
        if curve(k) >= gate:
            return k
    return None


def grid_ceiling(grid: Iterable[int], k_star: int) -> Optional[int]:
    """Least grid point at or above k_star (the right-hand side of factorisation)."""
    above = [k for k in sorted(grid) if k >= k_star]
    return above[0] if above else None


def bracketing_cell(
    grid: Sequence[int], curve: Callable[[int], Fraction], gate: Fraction
) -> tuple[Optional[int], Optional[int]]:
    """(last failing sample, first passing sample): the sharpest honest report."""
    lo: Optional[int] = None
    for k in sorted(grid):
        if curve(k) >= gate:
            return lo, k
        lo = k
    return lo, None


# --- the measured corpus-B row at context 2048 ------------------------------

GATE = Fraction(98, 100)
FINE_GRID = [16, 20, 24, 28, 32]
COARSE_GRID = [8, 16, 32, 64]

_MEASURED = {
    20: Fraction(9790, 10000),
    24: Fraction(9832, 10000),
    28: Fraction(9853, 10000),
    32: Fraction(9862, 10000),
}


def corpus_b(k: int) -> Fraction:
    """Monotone retention curve interpolating the measured row.

    All retention gain is realised at the measured budgets: the curve is
    constant on [20, 23], jumps at 24, and so on.  Below 20 it is the
    measured value 0.9790 minus a small deficit, still below the gate.
    """
    if k < 20:
        return Fraction(9700, 10000) * Fraction(min(k, 20), 20)
    if k < 24:
        return _MEASURED[20]
    if k < 28:
        return _MEASURED[24]
    if k < 32:
        return _MEASURED[28]
    return _MEASURED[32]


def demo_factorisation() -> None:
    print("=" * 74)
    print("1.  THE FACTORISATION THEOREM AND THE MEASURED ROW")
    print("=" * 74)
    k_star = knee(corpus_b, GATE, 64)
    fine = grid_knee(FINE_GRID, corpus_b, GATE)
    coarse = grid_knee(COARSE_GRID, corpus_b, GATE)
    print(f"  measured row (gate {float(GATE)}):")
    for k in (20, 24, 28, 32):
        mark = "PASS" if _MEASURED[k] >= GATE else "fail"
        print(f"      k = {k:>2}   retained = {float(_MEASURED[k]):.4f}   {mark}")
    print(f"\n  true knee                      k* = {k_star}")
    print(f"  fine-grid reading   {FINE_GRID}  -> {fine}")
    print(f"  coarse-grid reading {COARSE_GRID}       -> {coarse}")
    print("  ONE curve, TWO readings: the 24-vs-32 disagreement is a grid artifact.")

    assert k_star == 24 and fine == 24 and coarse == 32
    # factorisation: reading == least grid point >= k*
    for grid in (FINE_GRID, COARSE_GRID, [1, 3, 7, 25, 60], list(range(1, 65, 5))):
        assert grid_knee(grid, corpus_b, GATE) == grid_ceiling(grid, k_star)
    print("  factorisation theorem verified on 4 grids: reading = ceil_G(k*).")

    # exactness iff membership; refinement lowers the reading
    assert (fine == k_star) == (k_star in FINE_GRID)
    assert (coarse == k_star) == (k_star in COARSE_GRID)
    union = sorted(set(FINE_GRID) | set(COARSE_GRID))
    assert grid_knee(union, corpus_b, GATE) <= coarse
    print("  exactness-iff-membership and refinement-monotonicity verified.")
    print(f"  bracketing cell from the fine grid: {bracketing_cell(FINE_GRID, corpus_b, GATE)}")


# ---------------------------------------------------------------------------
# 2. Doubling bound and underdetermination
# ---------------------------------------------------------------------------


def step_curve(c: int) -> Callable[[int], Fraction]:
    """All-or-nothing retention profile: 0 below c, 1 at and above c."""
    return lambda k: Fraction(1) if k >= c else Fraction(0)


def demo_artifact_bound() -> None:
    print()
    print("=" * 74)
    print("2.  THE DOUBLING BOUND AND THE UNDERDETERMINATION OF THE TRUTH")
    print("=" * 74)
    dyadic = [2 ** j for j in range(0, 12)]
    worst = 0.0
    for c in range(1, 600):
        curve = step_curve(c)
        reading = grid_knee(dyadic, curve, GATE)
        assert reading is not None and reading < 2 * c
        worst = max(worst, reading / c)
    print(f"  over all true knees 1..599: max (dyadic reading)/k* = {worst:.4f} < 2")
    print(f"  measured inflation 32/24 = {32/24:.4f}, comfortably inside the bound.")

    print("\n  underdetermination on the coarse grid {8,16,32,64}:")
    for c in (17, 24, 32):
        curve = step_curve(c)
        vals = [float(curve(k)) for k in COARSE_GRID]
        print(
            f"      true knee {c:>2}: samples {vals} -> coarse reading "
            f"{grid_knee(COARSE_GRID, curve, GATE)}"
        )
    a, b = 17, 32
    assert all(step_curve(a)(k) == step_curve(b)(k) for k in COARSE_GRID)
    print("  the curves are indistinguishable on the grid AT EVERY GATE,")
    print("  yet their true knees are 17 and 32.  No inference removes the artifact.")


# ---------------------------------------------------------------------------
# 3. The replication law
# ---------------------------------------------------------------------------


def replication_tolerance(
    curve: Callable[[int], Fraction], gate: Fraction, k_star_val: int
) -> Fraction:
    """Largest eps* such that every eps<eps* perturbation preserves the knee."""
    up = curve(k_star_val) - gate
    down = min(gate - curve(j) for j in range(k_star_val))
    return min(up, down)


def demo_replication() -> None:
    print()
    print("=" * 74)
    print("3.  THE REPLICATION LAW")
    print("=" * 74)
    eps_star = replication_tolerance(corpus_b, GATE, 24)
    print(f"  clearance margin at 24 : {float(corpus_b(24) - GATE):.4f}")
    print(f"  miss margin at 20..23  : {float(GATE - corpus_b(23)):.4f}")
    print(f"  certified tolerance    : eps* = {float(eps_star):.4f}")
    eps = Fraction(9, 10000)
    assert eps < eps_star
    print(f"  hence every corpus uniformly within eps = {float(eps)} has knee exactly 24.")

    # a randomised-looking but deterministic sweep of perturbations
    bad = 0
    for t in range(-9, 10):
        delta = Fraction(t, 10000)
        perturbed = lambda k, d=delta: corpus_b(k) + d
        if knee(perturbed, GATE, 64) != 24:
            bad += 1
    print(f"  19 perturbations of size <= {float(eps)}: knee changed in {bad} of them.")
    assert bad == 0

    # necessity of the margin hypothesis
    eps_big = Fraction(1, 1000)
    N = 40
    a_curve = lambda k: GATE + eps_big / 2 if k >= 1 else Fraction(0)
    b_curve = lambda k: GATE + eps_big / 2 if k >= N else GATE - eps_big / 2
    assert all(abs(a_curve(j) - b_curve(j)) <= eps_big for j in range(1, 80))
    print(
        f"\n  necessity: two curves within {float(eps_big)} everywhere on [1,80) have knees "
        f"{knee(a_curve, GATE, 80)} and {knee(b_curve, GATE, 80)}."
    )
    print("  Without margins, the knee is wildly discontinuous.")


# ---------------------------------------------------------------------------
# 4. Scale invariance
# ---------------------------------------------------------------------------


def retention(raw: Callable[[int], Fraction], ctx: int) -> Callable[[int], Fraction]:
    return lambda k: raw(k) / raw(ctx)


def demo_scale_invariance() -> None:
    print()
    print("=" * 74)
    print("4.  ACCURACY LEVEL AND KNEE POSITION ARE INDEPENDENT")
    print("=" * 74)
    ctx = 2048
    base_a = Fraction(4760, 10000)             # corpus A full-context accuracy
    raw_a = lambda k: base_a if k >= ctx else base_a * corpus_b(k)
    difficulty = Fraction(4946, 4760)          # corpus B is the easier text
    raw_b = lambda k: difficulty * raw_a(k)
    ka = knee(retention(raw_a, ctx), GATE, 64)
    kb = knee(retention(raw_b, ctx), GATE, 64)
    print(f"  corpus A full-context accuracy 0.4760,  retention knee = {ka}")
    print(f"  corpus B full-context accuracy 0.4946,  retention knee = {kb}")
    assert ka == kb == 24
    print("  the retention curves are literally equal, so the knees coincide at EVERY gate.")


# ---------------------------------------------------------------------------
# 5. The chain and the profile trichotomy
# ---------------------------------------------------------------------------


def measured_knee(ctx: int) -> int:
    """The closed-form chain k*(ctx) = 4 log2(ctx) - 20."""
    return 4 * ctx.bit_length() - 4 - 20      # bit_length()-1 == log2 for powers of two


def harmonic(n: int) -> Fraction:
    return sum((Fraction(1, i + 1) for i in range(n)), Fraction(0))


def zipf_curve(n: int) -> Callable[[int], Fraction]:
    hn = harmonic(n)
    return lambda k: harmonic(min(k, n)) / hn


def geometric_curve(n: int) -> Callable[[int], Fraction]:
    denom = 1 - Fraction(1, 2) ** n
    return lambda k: (1 - Fraction(1, 2) ** min(k, n)) / denom


def demo_trichotomy() -> None:
    print()
    print("=" * 74)
    print("5.  THE LOGARITHMIC CHAIN AND THE PROFILE TRICHOTOMY")
    print("=" * 74)
    for ctx in (512, 1024, 2048):
        print(f"      k*({ctx:>4}) = {measured_knee(ctx)}")
    assert (measured_knee(512), measured_knee(1024), measured_knee(2048)) == (16, 20, 24)
    print("  slope forced by the first two cells: (20-16)/(10-9) = 4 keys per doubling;")
    print("  the third cell 24 was therefore a prediction, and it was confirmed twice.")

    kz = knee(zipf_curve(2 ** 11), GATE, 2 ** 11)
    print(f"\n  Zipf profile at ctx=2048 : knee = {kz}  (> 32; measured is 24)  -- TOO DEAR")
    assert kz is not None and kz > 32
    kg512 = knee(geometric_curve(512), GATE, 512)
    kg2048 = knee(geometric_curve(2048), GATE, 2048)
    print(f"  geometric profile        : knee = {kg512} at ctx=512 and {kg2048} at ctx=2048")
    assert kg512 == kg2048 == 6
    print("                             -- TOO CHEAP AND CONTEXT-FREE")
    print("  the measured chain moves by 8 keys, so it is neither.")


# ---------------------------------------------------------------------------
# 6. Sweep capacity, optimal grids, rigidity, and the product law
# ---------------------------------------------------------------------------


def geo_sum(r: int, s: int) -> int:
    """Sigma(r, s) = r + r^2 + ... + r^s."""
    total, term = 0, 1
    for _ in range(s):
        term *= r
        total += term
    return total


def asym_grid(a: int, b: int, s: int) -> list[int]:
    """The unique capacity-optimal (a,b)-localising grid."""
    return [b * (geo_sum(a * b, j) + 1) for j in range(s)]


def localises(grid: Sequence[int], a: int, b: int, n: int) -> bool:
    """Is `grid` an (a,b)-localiser of [1, n]?  (a=1 is the deployment-safe case.)"""
    return all(
        any(g <= b * c and c <= a * g for g in grid) for c in range(1, n + 1)
    )


def min_points(a: int, b: int, n: int) -> int:
    """Least number of sample points localising [1,n] at tolerance (a,b)."""
    s = 0
    while geo_sum(a * b, s) < n:
        s += 1
    return s


def brute_force_capacity(a: int, b: int, s: int, n_max: int) -> tuple[int, list[list[int]]]:
    """Exhaustive capacity and the list of all optimal grids (small parameters only)."""
    best, optima = 0, []
    for grid in combinations(range(1, n_max + 1), s):
        n = 0
        while n + 1 <= n_max and localises(grid, a, b, n + 1):
            n += 1
        if n > best:
            best, optima = n, [list(grid)]
        elif n == best and n > 0:
            optima.append(list(grid))
    return best, optima


def demo_capacity() -> None:
    print()
    print("=" * 74)
    print("6.  EXACT SWEEP CAPACITY, RIGIDITY, AND THE PRODUCT LAW")
    print("=" * 74)

    print("  capacity table  Sigma(a*b, s)  (rows: tolerance product; cols: points s)")
    print("      ab \\ s |" + "".join(f"{s:>8}" for s in range(1, 7)))
    for ab in (1, 2, 3, 4, 8):
        print(f"      {ab:>6} |" + "".join(f"{geo_sum(ab, s):>8}" for s in range(1, 7)))

    # attainment + rigidity by exhaustive search, small cases
    print("\n  brute-force check of capacity and uniqueness of the optimum:")
    for (a, b, s, n_max) in [(1, 2, 2, 12), (1, 2, 3, 20), (1, 3, 2, 18), (2, 2, 2, 30)]:
        cap, optima = brute_force_capacity(a, b, s, n_max)
        predicted = geo_sum(a * b, s)
        grid = asym_grid(a, b, s)
        ok = cap == predicted and optima == [sorted(grid)]
        print(
            f"      (a,b)=({a},{b}), s={s}: capacity {cap} (predicted {predicted}), "
            f"unique optimum {optima[0]} (predicted {sorted(grid)})  {'OK' if ok else 'MISMATCH'}"
        )
        assert ok

    # rigidity is a capacity phenomenon: one below capacity the optimum is not unique
    print("\n  rigidity is sharp: at r=2 with two points,")
    print(f"      {{2,6}} localises [1,5]: {localises([2, 6], 1, 2, 5)}")
    print(f"      {{2,5}} localises [1,5]: {localises([2, 5], 1, 2, 5)}")
    print(f"      {{2,5}} localises [1,6]: {localises([2, 5], 1, 2, 6)}  <- only {{2,6}} survives")
    assert localises([2, 6], 1, 2, 5) and localises([2, 5], 1, 2, 5)
    assert not localises([2, 5], 1, 2, 6) and localises([2, 6], 1, 2, 6)

    # the measured sweep, sized
    print("\n  the measured sweep, sized:")
    opt4 = asym_grid(1, 2, 4)
    print(f"      unique optimal 4-point doubling sweep : {opt4}, covers [1,{geo_sum(2,4)}]")
    print(f"      the grid actually used {COARSE_GRID} localises [1,30]? "
          f"{localises(COARSE_GRID, 1, 2, 30)}")
    blind = [c for c in range(1, 31) if not any(c <= g <= 2 * c for g in COARSE_GRID)]
    print(f"      its blind budgets below 30            : {blind[:8]} ...")
    print(f"      honest cost of covering [1,64]        : {min_points(1, 2, 64)} points "
          f"(the sweep used 4)")
    assert opt4 == [2, 6, 14, 30] and not localises(COARSE_GRID, 1, 2, 30)
    assert min_points(1, 2, 64) == 6

    # two-sided relaxation and its price
    print("\n  two-sided relaxation at r=2 with 4 points:")
    ts = asym_grid(2, 2, 4)
    print(f"      optimal grid {ts}, covers [1,{geo_sum(4,4)}]")
    assert ts == [2, 10, 42, 170] and localises(ts, 2, 2, 340)
    assert not localises(ts, 2, 2, 341)
    print("      price of never under-provisioning: Sigma(r,2s-1) < Sigma(r^2,s) < Sigma(r,2s)")
    for r in (2, 3, 4):
        for s in (1, 2, 3, 4):
            lo, mid, hi = geo_sum(r, 2 * s - 1), geo_sum(r * r, s), geo_sum(r, 2 * s)
            assert lo < mid < hi
        print(f"          r={r}: e.g. s=3 gives {geo_sum(r,5)} < {geo_sum(r*r,3)} < {geo_sum(r,6)}")

    # the product law
    print("\n  the product law: capacity depends on (a,b) only through a*b.")
    print("      (a,b) | product |  capacity with 4 points | optimal grid")
    for (a, b) in [(1, 2), (2, 1), (1, 4), (2, 2), (4, 1), (1, 6), (2, 3), (3, 2)]:
        cap = geo_sum(a * b, 4)
        print(f"      ({a},{b}) |   {a*b:>2}    |          {cap:>6}         | {asym_grid(a,b,4)}")
    for (a, b, a2, b2) in [(1, 4, 2, 2), (1, 6, 2, 3), (2, 3, 3, 2), (1, 9, 3, 3)]:
        for s in range(1, 6):
            assert geo_sum(a * b, s) == geo_sum(a2 * b2, s)
            assert localises(asym_grid(a, b, s), a, b, geo_sum(a * b, s))
            assert localises(asym_grid(a2, b2, s), a2, b2, geo_sum(a2 * b2, s))
    print("      verified for s = 1..5 on four tolerance pairs.")

    print("\n  the tolerance trade with four sample points:")
    print(f"      factor 2 upward only      -> [1,{geo_sum(1*2,4)}]")
    print(f"      factor 2 on either side   -> [1,{geo_sum(2*2,4)}]")
    print(f"      factor 4 upward only      -> [1,{geo_sum(1*4,4)}]   (identical!)")
    assert geo_sum(2, 4) == 30 and geo_sum(4, 4) == 340


def main() -> None:
    demo_factorisation()
    demo_artifact_bound()
    demo_replication()
    demo_scale_invariance()
    demo_trichotomy()
    demo_capacity()
    print()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
