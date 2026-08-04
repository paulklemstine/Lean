"""
Close Proofs: The Fractal Dimension of Mathematical Truth
=========================================================

Self-contained numerical demonstrations of every result in the accompanying
paper.  Pure Python 3 (standard library only), fully type-hinted.

Part I  -- The first-disagreement metric on truth streams
            * closed balls of radius 2^-n are exactly prefix-agreement classes
            * the strong (ultrametric) triangle inequality
            * box-counting dimension = entropy rate of the prefix language
            * the paired-dependency truth set has dimension exactly 1/2
            * the golden-mean truth set has dimension log2((1+sqrt5)/2)

Part II -- The signed adjacency operator on the Boolean cube Q_n
            * linearity (additivity and real homogeneity)
            * the square law  A_n^2 = n * Id
            * explicit spectral projections P_+ , P_-
              with  P_+ + P_- = Id,  A P_± = ±sqrt(n) P_±,
              P_±^2 = P_±,  P_+ P_- = 0, and equal ranks 2^(n-1)
            * the >half-the-cube degree bound (max degree >= sqrt n)

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Iterable, List, Sequence, Tuple

Stream = Callable[[int], int]          # a truth stream, coordinate oracle
Word = Tuple[int, ...]                 # a finite prefix
CubeFn = List[float]                   # array of 2^n reals, indexed by bitmask

# ---------------------------------------------------------------------------
# PART I.1 -- the first-disagreement metric
# ---------------------------------------------------------------------------


def first_disagreement(x: Stream, y: Stream, depth: int = 64) -> int | None:
    """Least index k < depth with x(k) != y(k); None if no disagreement found."""
    for k in range(depth):
        if x(k) != y(k):
            return k
    return None


def cantor_dist(x: Stream, y: Stream, depth: int = 64) -> float:
    """d(x, y) = 2^-m where m is the first disagreement index (0 if none)."""
    m = first_disagreement(x, y, depth)
    return 0.0 if m is None else 2.0 ** (-m)


def agree_to(n: int, x: Stream, y: Stream) -> bool:
    """x =_n y : the streams agree on every coordinate k < n."""
    return all(x(k) == y(k) for k in range(n))


def ball_is_cylinder_check(x: Stream, y: Stream, n: int, depth: int = 64) -> bool:
    """Theorem: d(x,y) <= 2^-n  <=>  x and y agree on the first n coordinates."""
    return (cantor_dist(x, y, depth) <= 2.0 ** (-n) + 1e-15) == agree_to(n, x, y)


def ultrametric_check(x: Stream, y: Stream, z: Stream, depth: int = 64) -> bool:
    """Theorem: d(x,z) <= max(d(x,y), d(y,z))."""
    return cantor_dist(x, z, depth) <= max(
        cantor_dist(x, y, depth), cantor_dist(y, z, depth)
    ) + 1e-15


def random_stream(rng: random.Random) -> Stream:
    """A lazily-generated, memoised random truth stream."""
    memo: dict[int, int] = {}

    def s(k: int) -> int:
        if k not in memo:
            memo[k] = rng.randint(0, 1)
        return memo[k]

    return s


def perturbed_stream(base: Stream, split: int, rng: random.Random) -> Stream:
    """Agrees with `base` below `split`, then flips and goes its own way."""
    tail = random_stream(rng)

    def s(k: int) -> int:
        if k < split:
            return base(k)
        if k == split:
            return 1 - base(k)
        return tail(k)

    return s


def demo_metric(seed: int = 20260803) -> None:
    rng = random.Random(seed)
    print("=" * 74)
    print("PART I.1  The first-disagreement metric d(x,y) = 2^-(first disagreement)")
    print("=" * 74)

    base = random_stream(rng)
    print("\nDistances to streams that branch off at a prescribed depth:")
    print(f"{'branch depth m':>16} {'d(x,y)':>14} {'2^-m':>14}   balls=cylinders?")
    for m in range(0, 9):
        y = perturbed_stream(base, m, rng)
        d = cantor_dist(base, y)
        ok = all(ball_is_cylinder_check(base, y, n) for n in range(0, 12))
        print(f"{m:>16} {d:>14.9f} {2.0 ** -m:>14.9f}        {ok}")

    print("\nStrong triangle inequality on 20000 random triples:")
    bad = 0
    isosceles = 0
    for _ in range(20000):
        depth = rng.randint(0, 10)
        x = random_stream(rng)
        y = perturbed_stream(x, rng.randint(0, 10), rng)
        z = perturbed_stream(y, depth, rng)
        if not ultrametric_check(x, y, z):
            bad += 1
        dxy, dyz, dxz = cantor_dist(x, y), cantor_dist(y, z), cantor_dist(x, z)
        big = max(dxy, dyz, dxz)
        if sorted([dxy, dyz, dxz]).count(big) >= 2:
            isosceles += 1
    print(f"  violations of d(x,z) <= max(d(x,y), d(y,z)) : {bad}")
    print(f"  triangles with two equal longest sides      : {isosceles}/20000")
    print("  (in an ultrametric space EVERY triangle is isosceles)")


# ---------------------------------------------------------------------------
# PART I.2 -- prefix counting and box dimension
# ---------------------------------------------------------------------------


def admissible_prefixes(
    predicate: Callable[[Word], bool], n: int
) -> List[Word]:
    """All admissible words of length n, grown level by level (prefix-closed)."""
    level: List[Word] = [()]
    for _ in range(n):
        nxt: List[Word] = []
        for w in level:
            for b in (0, 1):
                cand = w + (b,)
                if predicate(cand):
                    nxt.append(cand)
        level = nxt
    return level


def paired_dependency(w: Word) -> bool:
    """Every odd coordinate restates the even one before it: w[2k+1] = w[2k]."""
    return all(w[i] == w[i - 1] for i in range(1, len(w), 2))


def golden_mean(w: Word) -> bool:
    """No two consecutive statements are simultaneously true."""
    return all(not (w[i] == 1 and w[i + 1] == 1) for i in range(len(w) - 1))


def unconstrained(w: Word) -> bool:
    """Total logical anarchy: every pattern admissible."""
    return True


def box_dimension_estimates(
    predicate: Callable[[Word], bool], max_n: int
) -> List[Tuple[int, int, float]]:
    """Returns (n, N(n), log2 N(n) / n) for n = 1..max_n."""
    out: List[Tuple[int, int, float]] = []
    for n in range(1, max_n + 1):
        count = len(admissible_prefixes(predicate, n))
        out.append((n, count, math.log2(count) / n))
    return out


def transfer_matrix_count(matrix: Sequence[Sequence[int]],
                          start: Sequence[int], n: int) -> int:
    """Number of length-n walks: e_start^T M^n 1, by repeated vector-matrix mult."""
    vec = list(start)
    size = len(matrix)
    for _ in range(n):
        vec = [sum(vec[i] * matrix[i][j] for i in range(size)) for j in range(size)]
    return sum(vec)


def spectral_radius_2x2(m: Sequence[Sequence[int]]) -> float:
    """Largest eigenvalue modulus of a 2x2 matrix, via the quadratic formula."""
    tr = m[0][0] + m[1][1]
    det = m[0][0] * m[1][1] - m[0][1] * m[1][0]
    disc = tr * tr - 4 * det
    if disc >= 0:
        r = math.sqrt(disc)
        return max(abs((tr + r) / 2), abs((tr - r) / 2))
    return math.sqrt(abs(det))


def demo_dimension(max_n: int = 18) -> None:
    print()
    print("=" * 74)
    print("PART I.2  Box dimension = lim log2 N(n) / n  (N(n) = admissible prefixes)")
    print("=" * 74)

    families = [
        ("unconstrained  (dim 1)", unconstrained, 1.0),
        ("paired dependency (dim 1/2)", paired_dependency, 0.5),
        ("golden-mean taboo", golden_mean, math.log2((1 + math.sqrt(5)) / 2)),
    ]
    for name, pred, target in families:
        print(f"\n{name}   -- exact dimension = {target:.6f}")
        print(f"{'n':>4} {'N(n)':>10} {'log2 N(n)/n':>14} {'error':>12}")
        for n, count, est in box_dimension_estimates(pred, max_n):
            if n % 3 == 0 or n <= 4:
                print(f"{n:>4} {count:>10} {est:>14.6f} {abs(est - target):>12.6f}")

    print("\nPaired dependency: N(n) = 2^ceil(n/2) exactly?")
    ok = all(
        count == 2 ** math.ceil(n / 2)
        for n, count, _ in box_dimension_estimates(paired_dependency, max_n)
    )
    print(f"  verified for n = 1..{max_n}: {ok}")
    print("  hence log2 N(n)/n = ceil(n/2)/n in [1/2, 1/2 + 1/(2n)] -> 1/2")

    print("\nSparsity: fair-coin measure of the truth set is at most N(n) 2^-n.")
    print(f"{'n':>4} {'N(n) 2^-n':>16}")
    for n in (2, 6, 10, 20, 40, 80):
        print(f"{n:>4} {float(Fraction(2 ** math.ceil(n / 2), 2 ** n)):>16.3e}")
    print("  -> 0 exponentially: random truth assignments are almost never")
    print("     admissible, i.e. the truth set has measure zero.")

    print("\nGolden-mean theory via its transfer matrix M = [[1,1],[1,0]]:")
    m = [[1, 1], [1, 0]]
    print(f"{'n':>4} {'N(n) enumerated':>17} {'N(n) via M^n':>14}")
    for n in range(1, 13):
        enum = len(admissible_prefixes(golden_mean, n))
        walks = transfer_matrix_count(m, [1, 1], n - 1)
        print(f"{n:>4} {enum:>17} {walks:>14}")
    rho = spectral_radius_2x2(m)
    print(f"  spectral radius rho(M) = {rho:.9f}  (golden ratio)")
    print(f"  dimension = log2 rho    = {math.log2(rho):.9f}")
    print("  counting and spectra agree: the dimension of truth is an eigenvalue.")


# ---------------------------------------------------------------------------
# PART II -- the signed adjacency operator on the Boolean cube
# ---------------------------------------------------------------------------


def signed_adj(n: int, v: CubeFn) -> CubeFn:
    """(A_n v), where A_0 = 0 and A_{n+1} = [[A_n, I], [I, -A_n]].

    Vertices of Q_n are bitmasks 0..2^n-1; the LEADING bit is the high bit,
    so the low half of the array is the facet 0*, the high half is 1*.
    Cost: O(n 2^n) -- a butterfly, like a fast Walsh-Hadamard transform.
    """
    if n == 0:
        return [0.0]
    half = 1 << (n - 1)
    low, high = v[:half], v[half:]
    a_low, a_high = signed_adj(n - 1, low), signed_adj(n - 1, high)
    return [a_low[i] + high[i] for i in range(half)] + [
        low[i] - a_high[i] for i in range(half)
    ]


def signed_adj_matrix(n: int) -> List[List[float]]:
    """Explicit 2^n x 2^n matrix of A_n (columns = images of basis vectors)."""
    size = 1 << n
    cols = []
    for j in range(size):
        e = [0.0] * size
        e[j] = 1.0
        cols.append(signed_adj(n, e))
    return [[cols[j][i] for j in range(size)] for i in range(size)]


def positive_part(n: int, r: float, v: CubeFn) -> CubeFn:
    """P_+ v = (v + r^-1 A_n v) / 2, the projection onto the +r eigenspace."""
    av = signed_adj(n, v)
    return [(v[i] + av[i] / r) / 2 for i in range(len(v))]


def negative_part(n: int, r: float, v: CubeFn) -> CubeFn:
    """P_- v = (v - r^-1 A_n v) / 2, the projection onto the -r eigenspace."""
    av = signed_adj(n, v)
    return [(v[i] - av[i] / r) / 2 for i in range(len(v))]


def max_abs_diff(a: Sequence[float], b: Sequence[float]) -> float:
    return max((abs(x - y) for x, y in zip(a, b)), default=0.0)


def matrix_rank(rows: List[List[float]], tol: float = 1e-9) -> int:
    """Rank by Gaussian elimination with partial pivoting."""
    mat = [row[:] for row in rows]
    nrows, ncols = len(mat), len(mat[0]) if mat else 0
    rank, pivot_row = 0, 0
    for col in range(ncols):
        piv = max(range(pivot_row, nrows), key=lambda i: abs(mat[i][col]), default=None)
        if piv is None or abs(mat[piv][col]) < tol:
            continue
        mat[pivot_row], mat[piv] = mat[piv], mat[pivot_row]
        pv = mat[pivot_row][col]
        for i in range(nrows):
            if i != pivot_row and abs(mat[i][col]) > tol:
                f = mat[i][col] / pv
                mat[i] = [mat[i][j] - f * mat[pivot_row][j] for j in range(ncols)]
        rank += 1
        pivot_row += 1
        if pivot_row == nrows:
            break
    return rank


def demo_signed_cube(seed: int = 271828) -> None:
    rng = random.Random(seed)
    print()
    print("=" * 74)
    print("PART II  The signed cube operator  A_{n+1} = [[A_n, I], [I, -A_n]]")
    print("=" * 74)

    print("\nA_2 and A_3 as matrices (rows indexed by vertex bitmask):")
    for n in (2, 3):
        print(f"  A_{n} =")
        for row in signed_adj_matrix(n):
            print("      [" + " ".join(f"{x:+.0f}" for x in row) + "]")

    print("\nChecks over random cube functions:")
    header = f"{'n':>3} {'linearity':>12} {'A^2 = n I':>12} {'P+ + P- = id':>14} " \
             f"{'A P+ = +rP+':>13} {'A P- = -rP-':>13} {'ranks':>14}"
    print(header)
    for n in range(1, 9):
        size = 1 << n
        r = math.sqrt(n)
        v = [rng.uniform(-1, 1) for _ in range(size)]
        w = [rng.uniform(-1, 1) for _ in range(size)]
        c = rng.uniform(-3, 3)

        lin = max(
            max_abs_diff(
                signed_adj(n, [v[i] + w[i] for i in range(size)]),
                [a + b for a, b in zip(signed_adj(n, v), signed_adj(n, w))],
            ),
            max_abs_diff(
                signed_adj(n, [c * x for x in v]),
                [c * x for x in signed_adj(n, v)],
            ),
        )
        sq = max_abs_diff(signed_adj(n, signed_adj(n, v)), [n * x for x in v])
        pp, pm = positive_part(n, r, v), negative_part(n, r, v)
        recon = max_abs_diff([a + b for a, b in zip(pp, pm)], v)
        eig_p = max_abs_diff(signed_adj(n, pp), [r * x for x in pp])
        eig_m = max_abs_diff(signed_adj(n, pm), [-r * x for x in pm])

        cols_p = []
        cols_m = []
        for j in range(size):
            e = [0.0] * size
            e[j] = 1.0
            cols_p.append(positive_part(n, r, e))
            cols_m.append(negative_part(n, r, e))
        rank_p = matrix_rank([[cols_p[j][i] for j in range(size)] for i in range(size)])
        rank_m = matrix_rank([[cols_m[j][i] for j in range(size)] for i in range(size)])
        ranks = f"{rank_p}+{rank_m}={size}"

        print(f"{n:>3} {lin:>12.2e} {sq:>12.2e} {recon:>14.2e} "
              f"{eig_p:>13.2e} {eig_m:>13.2e} {ranks:>14}")
    print("  every eigenspace has dimension exactly 2^(n-1): the cube splits in half")

    print("\nIdempotence and orthogonality of the projections (n = 6):")
    n = 6
    r = math.sqrt(n)
    v = [rng.uniform(-1, 1) for _ in range(1 << n)]
    pp, pm = positive_part(n, r, v), negative_part(n, r, v)
    print(f"  |P+(P+ v) - P+ v| = {max_abs_diff(positive_part(n, r, pp), pp):.2e}")
    print(f"  |P-(P- v) - P- v| = {max_abs_diff(negative_part(n, r, pm), pm):.2e}")
    print(f"  |P-(P+ v)|        = {max(abs(x) for x in negative_part(n, r, pp)):.2e}")
    print(f"  |P+(P- v)|        = {max(abs(x) for x in positive_part(n, r, pm)):.2e}")


def induced_max_degree(n: int, subset: Iterable[int]) -> int:
    """Maximum degree of the subgraph of Q_n induced on `subset`."""
    s = set(subset)
    best = 0
    for x in s:
        deg = sum(1 for b in range(n) if (x ^ (1 << b)) in s)
        best = max(best, deg)
    return best


def demo_degree_bound(seed: int = 31415, trials: int = 200) -> None:
    print()
    print("=" * 74)
    print("PART II (cont.)  Majorities of the cube are locally dense: deg >= sqrt(n)")
    print("=" * 74)
    rng = random.Random(seed)
    print(f"\n{'n':>3} {'|S|':>8} {'sqrt(n)':>10} {'min observed max-degree':>26}")
    for n in range(1, 11):
        size = 1 << n
        target = size // 2 + 1
        worst = n
        for _ in range(trials):
            s = rng.sample(range(size), target)
            worst = min(worst, induced_max_degree(n, s))
        flag = "OK" if worst >= math.sqrt(n) - 1e-12 else "VIOLATION"
        print(f"{n:>3} {target:>8} {math.sqrt(n):>10.4f} {worst:>18}  {flag}")
    print("\n  Every subset of more than half the vertices contains a vertex with")
    print("  at least sqrt(n) neighbours inside the subset -- forced by the fact")
    print("  that the +sqrt(n) eigenspace of the signed operator has dimension")
    print("  exactly 2^(n-1) and must meet the functions supported on the subset.")


def main() -> None:
    demo_metric()
    demo_dimension()
    demo_signed_cube()
    demo_degree_bound()
    print()
    print("=" * 74)
    print("Summary: closed balls are prefix classes; the metric is ultrametric;")
    print("the paired-dependency truth set has box dimension exactly 1/2, so it")
    print("is null yet uncountable; the signed cube operator squares to n times")
    print("the identity and splits every cube function into explicit +/-sqrt(n)")
    print("eigenparts of equal dimension 2^(n-1).")
    print("=" * 74)


if __name__ == "__main__":
    main()
