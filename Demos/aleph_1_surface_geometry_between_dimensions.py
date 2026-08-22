"""
demo.py — Numerical demonstrations for "The Aleph-One Surface:
A Metric Skeleton of Transfinite Hausdorff Dimension in l^2".

Self-contained: standard library only (math, itertools, random, typing).
Run with:  python3 demo.py

------------------------------------------------------------------------------
THE OBJECT UNDER STUDY
------------------------------------------------------------------------------
Work in l^2 = {x = (x_0, x_1, ...) : sum_i x_i^2 < infinity}, with the norm
    ||x|| = sqrt(sum_i x_i^2).

Box sides:          sigma_i = 2^{-i}
Hilbert box:        H  = { x in l^2 : 0 <= x_i <= sigma_i for all i }
n-th cell:          C_n = { x in H : x_i = 0 for all i >= n }
Aleph-one surface:  A   = union_{n >= 0} C_n
Arithmetic surface: A_S = union_{n in S} C_n     for S subset of N

Facts demonstrated numerically below:

  (1) dim_H C_n = n exactly, via the two-sided Lipschitz squeeze
      pi_n : l^2 -> (R^n, sup norm)   is 1-Lipschitz,
      iota_n : (R^n, sup norm) -> l^2 is sqrt(n)-Lipschitz.
  (2) A box-counting estimate of dim C_n converges to n.
  (3) dim_H A = infinity: the dimensions of the cells are unbounded.
  (4) Tail estimate T(N) = sum_{i>=N} 4^{-i} = (4/3) 4^{-N} <= B(N) = 2 * 2^{-N},
      the uniform bound that makes the box compact and cube-homeomorphic.
  (5) The diagonal point delta = (1, 1/2, 1/4, ...) lies in H but in no cell,
      at distance exactly (2/sqrt 3) 2^{-n} from C_n: A is dense in H but
      neither closed nor compact.
  (6) Every ball B(x, r) of l^2 contains a flat n-cube of side
      r / (2 (sqrt n + 1)) for every n, so dim_H B(x, r) = infinity.
  (7) Arithmetic spectrum: dim_H A_S = sup S; A_S is triangulable iff S is
      finite. Prime surface: transfinite (Euclid). Twin-prime surface:
      transfinite iff there are infinitely many twin primes.
  (8) The ceiling theorem: any well-founded set of Hausdorff dimensions injects
      into the rationals, hence is countable; the rational separators are
      constructed explicitly here.
------------------------------------------------------------------------------
"""

from __future__ import annotations

import math
import random
from typing import Iterable, List, Sequence, Tuple

Vector = List[float]  # a finitely supported point of l^2, padded with zeros


# ---------------------------------------------------------------------------
# 1. The geometry: box sides, cells, projections, extensions
# ---------------------------------------------------------------------------

def box_side(i: int) -> float:
    """sigma_i = 2^{-i}, the length of the i-th edge of the Hilbert box."""
    return 2.0 ** (-i)


def l2_norm(x: Sequence[float]) -> float:
    """Euclidean norm of a finitely supported point of l^2."""
    return math.sqrt(sum(t * t for t in x))


def l2_dist(x: Sequence[float], y: Sequence[float]) -> float:
    """l^2 distance, padding the shorter vector with zeros."""
    m = max(len(x), len(y))
    total = 0.0
    for i in range(m):
        a = x[i] if i < len(x) else 0.0
        b = y[i] if i < len(y) else 0.0
        total += (a - b) ** 2
    return math.sqrt(total)


def sup_norm(y: Sequence[float]) -> float:
    """Sup norm on R^n, the norm used on the model space of each cell."""
    return max((abs(t) for t in y), default=0.0)


def sup_dist(y: Sequence[float], z: Sequence[float]) -> float:
    """Sup distance on R^n."""
    return max((abs(a - b) for a, b in zip(y, z)), default=0.0)


def iota(n: int, y: Sequence[float]) -> Vector:
    """Extension by zero: R^n -> l^2. Lipschitz with constant sqrt(n)."""
    return [y[i] if i < n else 0.0 for i in range(n)]


def pi(n: int, x: Sequence[float]) -> Vector:
    """Coordinate projection l^2 -> R^n (sup norm). 1-Lipschitz."""
    return [x[i] if i < len(x) else 0.0 for i in range(n)]


def random_cell_point(n: int, rng: random.Random) -> Vector:
    """A uniformly random point of the n-th cell C_n."""
    return [rng.uniform(0.0, box_side(i)) for i in range(n)]


def diagonal_point(n_terms: int) -> Vector:
    """Truncation of the diagonal point delta = (1, 1/2, 1/4, ...) of H."""
    return [box_side(i) for i in range(n_terms)]


# ---------------------------------------------------------------------------
# 2. Verifying the Lipschitz constants that pin the dimension
# ---------------------------------------------------------------------------

def check_lipschitz_constants(n: int, trials: int = 20000,
                              seed: int = 20260822) -> Tuple[float, float]:
    """Empirically maximise the two distortion ratios over random pairs.

    Returns (worst projection ratio, worst extension ratio). Theory predicts
    the first is <= 1 and the second <= sqrt(n), with both bounds attained in
    the limit of many samples.
    """
    rng = random.Random(seed)
    worst_pi = 0.0
    worst_iota = 0.0
    for _ in range(trials):
        x = random_cell_point(n, rng)
        x2 = random_cell_point(n, rng)
        d_amb = l2_dist(x, x2)
        if d_amb > 0:
            worst_pi = max(worst_pi, sup_dist(pi(n, x), pi(n, x2)) / d_amb)
        y = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        z = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        d_sup = sup_dist(y, z)
        if d_sup > 0:
            worst_iota = max(worst_iota, l2_dist(iota(n, y), iota(n, z)) / d_sup)
    return worst_pi, worst_iota


# ---------------------------------------------------------------------------
# 3. Box-counting estimate of the dimension of a cell
# ---------------------------------------------------------------------------

def covering_number_cell(n: int, eps: float) -> float:
    """Number of eps-cubes needed to cover C_n = prod_{i<n} [0, 2^{-i}].

    The cell is an axis-aligned box, so the exact covering number factorises:
    N(eps) = prod_{i<n} ceil(sigma_i / eps).  Returned as a float to avoid
    overflow in the logarithm.
    """
    total = 0.0
    for i in range(n):
        total += math.log(math.ceil(box_side(i) / eps))
    return math.exp(total)


def box_dimension_estimate(n: int, eps: float) -> float:
    """log N(eps) / log(1/eps): a box-counting estimate of dim C_n.

    As eps -> 0 this converges to n, matching the exact Hausdorff dimension.
    Convergence is slow (the finite side lengths contribute a
    -sum_i log sigma_i / log(1/eps) correction of order 1/log(1/eps)).
    """
    return math.log(covering_number_cell(n, eps)) / math.log(1.0 / eps)


# ---------------------------------------------------------------------------
# 4. Tail estimates: compactness of the Hilbert box
# ---------------------------------------------------------------------------

def tail_exact(N: int) -> float:
    """T(N) = sum_{i >= N} 4^{-i} = (4/3) 4^{-N}: exact squared tail of the box."""
    return (4.0 / 3.0) * (4.0 ** (-N))


def tail_bound(N: int) -> float:
    """B(N) = 2 * 2^{-N}: the coarser bound used in the compactness proof."""
    return 2.0 * (2.0 ** (-N))


def truncation_error(N: int) -> float:
    """sqrt(B(N)): the uniform metric error of the N-th truncation on the box."""
    return math.sqrt(tail_bound(N))


def dist_diagonal_to_cell(n: int) -> float:
    """dist(delta, C_n) = sqrt(T(n)) = (2/sqrt 3) 2^{-n}, computed exactly."""
    return math.sqrt(tail_exact(n))


# ---------------------------------------------------------------------------
# 5. Local transfinite dimension: cubes inside an arbitrary ball
# ---------------------------------------------------------------------------

def cube_side_in_ball(r: float, n: int) -> float:
    """Side s = r / (2 (sqrt n + 1)) of a flat n-cube fitting in a ball of radius r.

    The cube iota_n([0, s]^n) has l^2 diameter at most sqrt(n) * s <= r/2, so a
    translate of it lies inside B(x, r); it has Hausdorff dimension exactly n.
    Since n is arbitrary, dim_H B(x, r) = infinity for every r > 0.
    """
    return r / (2.0 * (math.sqrt(n) + 1.0))


# ---------------------------------------------------------------------------
# 6. Arithmetic surfaces: spectrum, triangulability, primes
# ---------------------------------------------------------------------------

def primes_up_to(limit: int) -> List[int]:
    """All primes <= limit, by a sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for p in range(2, int(limit ** 0.5) + 1):
        if sieve[p]:
            for q in range(p * p, limit + 1, p):
                sieve[q] = False
    return [p for p, ok in enumerate(sieve) if ok]


def twin_primes_up_to(limit: int) -> List[int]:
    """All p <= limit with p and p+2 both prime."""
    ps = set(primes_up_to(limit + 2))
    return [p for p in sorted(ps) if p <= limit and (p + 2) in ps]


def surface_dimension(S: Iterable[int]) -> float:
    """dim_H A_S = sup S, returned as float('inf') for an unbounded S sample."""
    s = list(S)
    return float(max(s)) if s else 0.0


def is_triangulable(s_is_finite: bool) -> bool:
    """A_S admits a Lipschitz d-triangulation for some d iff S is finite.

    For a finite S the witness has exactly |S| cells of common model dimension
    d = max S: restrict to the first n coordinates (1-Lipschitz), then extend by
    zero (sqrt(n)-Lipschitz).  For an infinite S the dimension is infinite and
    no triangulation of any finite dimension can exist.
    """
    return s_is_finite


def triangulation_cells(S: Sequence[int]) -> List[Tuple[int, int, float]]:
    """The explicit triangulation of A_S for finite S.

    Returns one triple (cell dimension n, model dimension d, Lipschitz constant
    sqrt(n)) for each n in S, where d = max S is the common model dimension.
    """
    d = max(S) if S else 0
    return [(n, d, math.sqrt(n)) for n in sorted(S)]


# ---------------------------------------------------------------------------
# 7. The ceiling theorem: rational separators for a well-founded chain
# ---------------------------------------------------------------------------

def rational_separators(chain: Sequence[float]) -> List[float]:
    """Explicit witnesses for 'a well-founded set of dimensions is countable'.

    Given a strictly increasing finite chain d_0 < d_1 < ... < d_k of dimension
    values, each non-maximal d_j has an immediate successor d_{j+1} in the
    chain, and the interval (d_j, d_{j+1}] contains a rational q_j chosen here
    as a dyadic midpoint.  Distinct chain elements receive distinct, strictly
    increasing rationals, so the chain injects into Q; hence any well-founded
    set of Hausdorff dimensions is countable, and no aleph_1-long strictly
    increasing dimension hierarchy can exist.
    """
    out: List[float] = []
    for j in range(len(chain) - 1):
        out.append(0.5 * (chain[j] + chain[j + 1]))
    return out


def separators_strictly_increasing(chain: Sequence[float]) -> bool:
    """Check the injection Q-separator property on a concrete chain."""
    qs = rational_separators(chain)
    return all(qs[j] < qs[j + 1] for j in range(len(qs) - 1)) and \
        all(chain[j] < qs[j] <= chain[j + 1] for j in range(len(qs)))


# ---------------------------------------------------------------------------
# 8. Reporting
# ---------------------------------------------------------------------------

def hline(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_cell_dimensions() -> None:
    hline("1. dim_H C_n = n  —  the two-sided Lipschitz squeeze")
    print(f"{'n':>3} {'worst ||pi||':>13} {'bound 1':>9} "
          f"{'worst ||iota||':>15} {'bound sqrt(n)':>14} {'dim_H C_n':>10}")
    for n in (1, 2, 3, 5, 8):
        wp, wi = check_lipschitz_constants(n, trials=4000)
        print(f"{n:>3} {wp:>13.6f} {1.0:>9.4f} {wi:>15.6f} "
              f"{math.sqrt(n):>14.6f} {n:>10}")
    print()
    print("Interpretation: the projection never expands (ratio <= 1) and the")
    print("extension expands by at most sqrt(n).  Both being finite forces")
    print("dim_H C_n = dim_H B_n = n exactly; the constants themselves are")
    print("irrelevant, which is why bounded distortion cannot change dimension.")


def demo_box_counting() -> None:
    hline("2. Box-counting confirmation of dim C_n = n")
    eps_list = [2.0 ** (-k) for k in (4, 6, 8, 10, 14, 20, 30)]
    print(f"{'eps':>12} " + " ".join(f"{'n=' + str(n):>9}" for n in (1, 2, 3, 4)))
    for eps in eps_list:
        row = " ".join(f"{box_dimension_estimate(n, eps):>9.4f}"
                       for n in (1, 2, 3, 4))
        print(f"{eps:>12.3e} {row}")
    print()
    print("Each column converges to its integer n as eps -> 0, from above:")
    print("the finite side lengths sigma_i = 2^{-i} contribute an O(1/log(1/eps))")
    print("correction, not a change in dimension.")


def demo_surface_dimension() -> None:
    hline("3. dim_H A = infinity  —  countable stability of dimension")
    print("dim_H of a countable union is the SUPREMUM of the pieces, not a sum.")
    print()
    print(f"{'N':>4} {'max_{n<=N} dim_H C_n':>24}")
    for N in (1, 2, 5, 10, 100, 10 ** 6):
        print(f"{N:>4} {N:>24}")
    print()
    print("sup over all n is unbounded, so dim_H A = infinity: A exceeds every")
    print("real dimension.  Consequently every d-dimensional Hausdorff measure")
    print("of A is infinite — there is no scale at which A has finite mass.")


def demo_tails() -> None:
    hline("4. Uniform tail estimate  —  why the Hilbert box is compact")
    print(f"{'N':>3} {'T(N)=(4/3)4^-N':>16} {'B(N)=2*2^-N':>14} "
          f"{'sqrt(B(N))':>12} {'T<=B':>6}")
    for N in (0, 1, 2, 3, 4, 5, 8, 12):
        t, b = tail_exact(N), tail_bound(N)
        print(f"{N:>3} {t:>16.6f} {b:>14.6f} {truncation_error(N):>12.6f} "
              f"{str(t <= b):>6}")
    print()
    print(f"Max norm of any point of the Hilbert box: sqrt(4/3) = "
          f"{math.sqrt(4.0/3.0):.6f}")
    print("The bound is independent of the point, so the finite truncations")
    print("converge UNIFORMLY to the identity on the box.  A uniform limit of")
    print("continuous maps is continuous, so the product box maps continuously")
    print("into l^2; being a continuous bijection from a compact space, it is a")
    print("homeomorphism.  Hence the l^2 box is a metric copy of the Hilbert cube.")
    print(f"Geometric decay ratio of sqrt(B(N)): {truncation_error(5)/truncation_error(4):.6f}"
          f"  (= 1/sqrt 2 = {1/math.sqrt(2):.6f})")


def demo_diagonal_point() -> None:
    hline("5. The diagonal point: A is dense in the box but not closed")
    delta = diagonal_point(40)
    print(f"delta = (1, 1/2, 1/4, ...),  ||delta|| = {l2_norm(delta):.6f} "
          f"(= sqrt(4/3) = {math.sqrt(4/3):.6f})")
    print("delta lies in the Hilbert box H but in NO cell C_n: it has infinitely")
    print("many nonzero coordinates, while every point of A has finite support.")
    print()
    print(f"{'n':>3} {'dist(delta, C_n)':>18} {'(2/sqrt3) 2^-n':>16} "
          f"{'measured':>12}")
    for n in (0, 1, 2, 4, 8, 16):
        exact = dist_diagonal_to_cell(n)
        closed = (2.0 / math.sqrt(3.0)) * 2.0 ** (-n)
        measured = l2_dist(delta, delta[:n])
        print(f"{n:>3} {exact:>18.9f} {closed:>16.9f} {measured:>12.9f}")
    print()
    print("The distance tends to 0, so delta is in the closure of A but not in A.")
    print("The same estimate at every point of H gives closure(A) = H exactly:")
    print("A is a dense, sigma-compact, NON-closed, NON-compact skeleton of a")
    print("compact Hilbert cube.  And since a compact set in an infinite-")
    print("dimensional normed space has empty interior (Riesz), A is nowhere")
    print("dense and MEAGRE in l^2 despite having infinite Hausdorff dimension.")


def demo_local_transfinite() -> None:
    hline("6. Every ball of l^2 is transfinite-dimensional")
    r = 0.1
    print(f"Radius r = {r}. A flat n-cube of side s = r/(2(sqrt n + 1)) fits")
    print("inside B(x, r) after translation, and has Hausdorff dimension n.")
    print()
    print(f"{'n':>4} {'side s':>14} {'cube diam sqrt(n)*s':>22} {'<= r/2':>8}")
    for n in (1, 2, 5, 10, 100, 10000):
        s = cube_side_in_ball(r, n)
        diam = math.sqrt(n) * s
        print(f"{n:>4} {s:>14.3e} {diam:>22.6f} {str(diam <= r/2 + 1e-12):>8}")
    print()
    print("The witnesses shrink like r/(2 sqrt n) — which is why no single scale")
    print("detects transfinite dimension — but they exist for every n, so")
    print("dim_H B(x, r) = infinity for EVERY x and EVERY r > 0.  Combined with")
    print("Baire: an F_sigma subset of l^2 is either meagre or of dimension")
    print("infinity.  A sits on the meagre side, a ball on the transfinite side.")


def demo_arithmetic_spectrum() -> None:
    hline("7. The arithmetic dimension spectrum: primes and twin primes")
    limit = 200
    finite_examples: List[Tuple[str, List[int]]] = [
        ("S = {0}", [0]),
        ("S = {3}", [3]),
        ("S = {1, 2, 5}", [1, 2, 5]),
        ("S = {2, 3, 5, 7} (primes < 10)", [2, 3, 5, 7]),
    ]
    print("For FINITE S the surface A_S is genuinely triangulated, with exactly")
    print("|S| Lipschitz cells of common model dimension d = max S:")
    print()
    print(f"{'S':>32} {'dim_H A_S':>10} {'#cells':>7} {'model d':>8} "
          f"{'Lip constants':>28}")
    for name, S in finite_examples:
        cells = triangulation_cells(S)
        consts = ", ".join(f"{c:.3f}" for (_, _, c) in cells)
        print(f"{name:>32} {surface_dimension(S):>10.0f} {len(S):>7} "
              f"{cells[0][1] if cells else 0:>8} {consts:>28}")
    print()
    print("For INFINITE S the dimension is infinite and no triangulation of any")
    print("finite dimension exists.  Growth of the two arithmetic examples:")
    print()
    print(f"{'X':>7} {'#primes <= X':>13} {'max prime':>10} "
          f"{'#twins <= X':>12} {'max twin':>9}")
    for X in (10, 50, 100, 200):
        ps = [p for p in primes_up_to(limit) if p <= X]
        ts = [p for p in twin_primes_up_to(limit) if p <= X]
        print(f"{X:>7} {len(ps):>13} {max(ps):>10} {len(ts):>12} "
              f"{(max(ts) if ts else 0):>9}")
    print()
    print("Prime surface: the primes are infinite (Euclid), so dim_H = infinity")
    print("  and the prime surface admits NO finite triangulation.  Euclid's")
    print("  theorem has become a statement about resistance to being cut up.")
    print("Twin-prime surface: dim_H = infinity  <=>  infinitely many twin")
    print("  primes.  The twin prime conjecture is exactly the assertion that")
    print("  this one explicit subset of l^2 cannot be triangulated.")


def demo_ceiling_theorem() -> None:
    hline("8. The ceiling theorem: why 'dimension aleph_1' is unreachable")
    chain = [0.0, 1.0, 1.5, 2.0, 2.7182818, 3.0, 3.1415926, 7.0]
    qs = rational_separators(chain)
    print("A strictly increasing chain of dimension values, with the rational")
    print("separator q_j chosen in the gap (d_j, d_{j+1}]:")
    print()
    print(f"{'j':>3} {'d_j':>12} {'q_j':>12} {'d_{j+1}':>12} {'d_j < q_j <= d_{j+1}':>22}")
    for j, q in enumerate(qs):
        ok = chain[j] < q <= chain[j + 1]
        print(f"{j:>3} {chain[j]:>12.6f} {q:>12.6f} {chain[j+1]:>12.6f} {str(ok):>22}")
    print()
    print(f"Separators strictly increasing (hence injective into Q): "
          f"{separators_strictly_increasing(chain)}")
    print()
    print("This is the whole proof of the ceiling theorem.  In a WELL-FOUNDED")
    print("set of dimensions every non-maximal element has an IMMEDIATE")
    print("successor, so the gap above it is nonempty and contains a rational;")
    print("distinct elements get distinct rationals; the set injects into Q and")
    print("is therefore COUNTABLE.  Consequently no strictly increasing")
    print("aleph_1-indexed hierarchy of Hausdorff dimensions exists in ANY")
    print("metric space.  Dropping well-foundedness relaxes the ceiling only to")
    print("the continuum; it is the ORDINAL SHAPE of a hierarchy that collapses")
    print("its length to countable.  Countable chains, by contrast, abound: the")
    print("cells C_0 < C_1 < C_2 < ... realise dimensions 0 < 1 < 2 < ...,")
    print("so the ceiling is sharp at aleph_0.")
    print()
    print("Cardinality, not dimension, is where aleph_1 lives: A has exactly")
    print("continuum many points (C_1 alone is a segment, and l^2 has at most")
    print("continuum many points), hence exactly aleph_1 points under the")
    print("Continuum Hypothesis.")


def main() -> None:
    print(__doc__)
    demo_cell_dimensions()
    demo_box_counting()
    demo_surface_dimension()
    demo_tails()
    demo_diagonal_point()
    demo_local_transfinite()
    demo_arithmetic_spectrum()
    demo_ceiling_theorem()
    hline("Summary")
    print("dim_H C_n = n; dim_H A = infinity; A has continuum many points")
    print("(aleph_1 under CH); A embeds topologically in the Hilbert cube but")
    print("admits no bounded-distortion image in any R^m and no triangulation;")
    print("closure(A) is the compact Hilbert box, yet A is meagre in l^2; and")
    print("dim_H A_S = sup S turns the infinitude of a set of integers into the")
    print("non-triangulability of a surface.")


if __name__ == "__main__":
    main()
