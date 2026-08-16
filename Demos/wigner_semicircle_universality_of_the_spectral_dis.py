"""
Numerical laboratory for the Wigner semicircle law via the exact walk calculus.
==============================================================================

Everything demonstrated here corresponds to a theorem stated in the accompanying
paper.  The script is self-contained: it uses NumPy when available (for fast
eigenvalue computation) and otherwise falls back to a pure-Python symmetric
eigensolver, so it runs anywhere.

Demonstrations
--------------
1.  Semicircle moments are the Catalan numbers
        (1/2pi) * int_{-2}^{2} x^{2k} sqrt(4 - x^2) dx = C_k.
2.  The exact ensemble dichotomy and "moments are cardinalities":
        E[tr(W^m)] = #{even closed m-walks},
    verified against brute-force averaging over all 2^{N(N-1)/2} sign matrices
    in exact integer arithmetic.
3.  Exact vanishing of all odd trace moments at every finite N.
4.  Exact finite-N formulas:  E[tr(W^4)] = 2N(N-1)^2 - 2N(N-1) + m4 * N(N-1),
    and the deterministic identity tr(W^2) = N(N-1).
5.  The two-sided sandwich  (1 - 1/N)^k <= E[m_{2k}] <= (k+1)^{2k}.
6.  Universality: Monte-Carlo spectral moments for Rademacher, Gaussian,
    uniform and sparse (heavy-fourth-moment) entry laws all approach the
    Catalan numbers.
7.  Exact variance of the second spectral moment, 2(m4 - 1)(N - 1)/N^3.
8.  Bulk tightness and the deterministic edge floor sqrt(1 - 1/N).
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

try:  # NumPy is optional.
    import numpy as _np

    HAVE_NUMPY = True
except Exception:  # pragma: no cover
    _np = None
    HAVE_NUMPY = False


# ----------------------------------------------------------------------------
# 0. Combinatorial reference sequence: the Catalan numbers
# ----------------------------------------------------------------------------


def catalan(k: int) -> int:
    """C_k = binom(2k, k) / (k + 1), the k-th Catalan number."""
    return math.comb(2 * k, k) // (k + 1)


def catalan_by_convolution(kmax: int) -> List[int]:
    """Catalan numbers from the recursion C_{k+1} = sum_{i<=k} C_i C_{k-i}."""
    c: List[int] = [1]
    for k in range(kmax):
        c.append(sum(c[i] * c[k - i] for i in range(k + 1)))
    return c


# ----------------------------------------------------------------------------
# 1. Moments of the semicircle density (numerical integration)
# ----------------------------------------------------------------------------


def semicircle_moment_numeric(m: int, panels: int = 200_000) -> float:
    """(1/2pi) int_{-2}^{2} x^m sqrt(4 - x^2) dx by the substitution x = 2 sin t.

    The substitution removes the square-root singularity at the endpoints, so
    plain Simpson quadrature in t converges rapidly.
    """
    if panels % 2:
        panels += 1
    a, b = -math.pi / 2.0, math.pi / 2.0
    h = (b - a) / panels

    def f(t: float) -> float:
        # x = 2 sin t, sqrt(4 - x^2) = 2 cos t, dx = 2 cos t dt
        return (2.0 * math.sin(t)) ** m * 4.0 * math.cos(t) ** 2

    total = f(a) + f(b)
    for i in range(1, panels):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return (h / 3.0) * total / (2.0 * math.pi)


# ----------------------------------------------------------------------------
# 2. Exact walk enumeration:  E[tr(W^m)] = #{even closed m-walks}
# ----------------------------------------------------------------------------


def is_even_closed_walk(walk: Sequence[int]) -> bool:
    """True iff the closed walk is loop-free with all edge multiplicities even.

    `walk` lists the vertices v_0, ..., v_{m-1}; the steps are
    v_0 -> v_1 -> ... -> v_{m-1} -> v_0.
    """
    mult: Dict[Tuple[int, int], int] = {}
    m = len(walk)
    for t in range(m):
        a, b = walk[t], walk[(t + 1) % m]
        if a == b:  # a loop kills the monomial (zero diagonal)
            return False
        e = (a, b) if a < b else (b, a)
        mult[e] = mult.get(e, 0) + 1
    return all(v % 2 == 0 for v in mult.values())


def count_even_closed_walks(n_vertices: int, length: int) -> int:
    """Exhaustively count even closed walks of the given length. O(N^m * m)."""
    return sum(
        1
        for walk in itertools.product(range(n_vertices), repeat=length)
        if is_even_closed_walk(walk)
    )


# ----------------------------------------------------------------------------
# 3. Exact ensemble averaging over all sign configurations (integer arithmetic)
# ----------------------------------------------------------------------------


def sign_matrix(n: int, mask: int) -> List[List[int]]:
    """The symmetric zero-diagonal +-1 matrix encoded by the bitmask `mask`."""
    edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    w = [[0] * n for _ in range(n)]
    for idx, (i, j) in enumerate(edges):
        s = 1 if (mask >> idx) & 1 else -1
        w[i][j] = s
        w[j][i] = s
    return w


def mat_mul(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def trace_power(a: List[List[int]], m: int) -> int:
    n = len(a)
    p = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    for _ in range(m):
        p = mat_mul(p, a)
    return sum(p[i][i] for i in range(n))


def exact_expected_trace_power(n: int, m: int) -> float:
    """E[tr(W^m)] by enumerating all 2^{n(n-1)/2} sign configurations exactly."""
    n_edges = n * (n - 1) // 2
    total = 0
    for mask in range(1 << n_edges):
        total += trace_power(sign_matrix(n, mask), m)
    return total / float(1 << n_edges)


# ----------------------------------------------------------------------------
# 4. Symmetric eigenvalues (NumPy, or pure-Python cyclic Jacobi fallback)
# ----------------------------------------------------------------------------


def eigenvalues_symmetric(a: List[List[float]], sweeps: int = 60) -> List[float]:
    """Eigenvalues of a real symmetric matrix, sorted increasingly."""
    if HAVE_NUMPY:
        return sorted(_np.linalg.eigvalsh(_np.array(a, dtype=float)).tolist())
    n = len(a)
    m = [row[:] for row in a]
    for _ in range(sweeps):
        off = math.sqrt(sum(m[i][j] ** 2 for i in range(n) for j in range(n) if i != j))
        if off < 1e-12:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-15:
                    continue
                theta = 0.5 * math.atan2(2.0 * m[p][q], m[q][q] - m[p][p])
                c, s = math.cos(theta), math.sin(theta)
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
    return sorted(m[i][i] for i in range(n))


# ----------------------------------------------------------------------------
# 5. Entry laws and Monte-Carlo sampling
# ----------------------------------------------------------------------------

EntrySampler = Callable[[random.Random], float]


def rademacher(rng: random.Random) -> float:
    """+-1 with equal probability; m4 = 1 (the minimum possible)."""
    return 1.0 if rng.random() < 0.5 else -1.0


def gaussian(rng: random.Random) -> float:
    """Standard normal; m4 = 3."""
    return rng.gauss(0.0, 1.0)


def uniform_law(rng: random.Random) -> float:
    """Uniform on [-sqrt(3), sqrt(3)]; variance 1, m4 = 9/5."""
    return rng.uniform(-math.sqrt(3.0), math.sqrt(3.0))


def sparse_law(p: float = 0.1) -> EntrySampler:
    """+-1/sqrt(p) with probability p, else 0; variance 1, m4 = 1/p."""

    def sampler(rng: random.Random) -> float:
        if rng.random() < p:
            return (1.0 if rng.random() < 0.5 else -1.0) / math.sqrt(p)
        return 0.0

    return sampler


def sample_wigner(n: int, sampler: EntrySampler, rng: random.Random) -> List[List[float]]:
    """A symmetric zero-diagonal matrix with i.i.d. entries above the diagonal."""
    w = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            x = sampler(rng)
            w[i][j] = x
            w[j][i] = x
    return w


def normalized_moments(w: List[List[float]], orders: Sequence[int]) -> Dict[int, float]:
    """m_k = (1/N) sum_i (lambda_i / sqrt(N))^k for each requested order k."""
    n = len(w)
    lam = eigenvalues_symmetric(w)
    out: Dict[int, float] = {}
    for k in orders:
        out[k] = sum((x / math.sqrt(n)) ** k for x in lam) / n
    return out


def spectral_radius_normalized(w: List[List[float]]) -> float:
    n = len(w)
    lam = eigenvalues_symmetric(w)
    return max(abs(x) for x in lam) / math.sqrt(n)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_1_catalan() -> None:
    print("=" * 78)
    print("1. Semicircle moments are the Catalan numbers")
    print("=" * 78)
    print(f"{'2k':>4} {'numeric integral':>20} {'Catalan C_k':>14} {'abs error':>12}")
    for k in range(0, 6):
        num = semicircle_moment_numeric(2 * k)
        print(f"{2*k:>4} {num:>20.10f} {catalan(k):>14d} {abs(num - catalan(k)):>12.2e}")
    print("\nOdd moments vanish by symmetry of the density:")
    for m in (1, 3, 5):
        print(f"   moment {m}: {semicircle_moment_numeric(m):+.2e}")
    print("\nCatalan numbers regenerated from C_{k+1} = sum_i C_i C_{k-i}:")
    print("   ", catalan_by_convolution(9))
    print()


def demo_2_dichotomy() -> None:
    print("=" * 78)
    print("2. Moments are cardinalities: E[tr(W^m)] = #{even closed m-walks}")
    print("=" * 78)
    print(f"{'N':>3} {'m':>3} {'walk count':>12} {'exact ensemble avg':>20} {'match':>7}")
    for n, m in [(2, 4), (3, 3), (3, 4), (3, 5), (3, 6), (4, 3), (4, 4), (2, 6)]:
        walks = count_even_closed_walks(n, m)
        avg = exact_expected_trace_power(n, m)
        ok = abs(walks - avg) < 1e-9
        print(f"{n:>3} {m:>3} {walks:>12d} {avg:>20.6f} {str(ok):>7}")
    print("\nEvery odd-order entry above is exactly 0: no closed walk of odd length")
    print("can pair up its edges, so the sign-flip involution kills it.\n")


def demo_3_closed_forms() -> None:
    print("=" * 78)
    print("3. Exact finite-N formulas for the Rademacher ensemble (m4 = 1)")
    print("=" * 78)
    print(f"{'N':>3} {'E[tr W^4] exact':>18} {'2N(N-1)^2 - N(N-1)':>22} {'E[m_4]':>12}")
    for n in (2, 3, 4):
        exact = exact_expected_trace_power(n, 4)
        formula = 2 * n * (n - 1) ** 2 - n * (n - 1)
        print(f"{n:>3} {exact:>18.4f} {formula:>22d} {exact / n**3:>12.6f}")
    print("\n(N-1)(2N-3)/N^2  ->  2 = C_2 as N grows:")
    for n in (10, 100, 1000, 10_000):
        print(f"   N = {n:>6}:  {(n - 1) * (2 * n - 3) / n**2:.8f}")
    print()


def demo_4_self_averaging_and_sandwich() -> None:
    print("=" * 78)
    print("4. Deterministic second moment and the two-sided sandwich")
    print("=" * 78)
    rng = random.Random(20260816)
    for n in (5, 12, 30):
        w = sample_wigner(n, rademacher, rng)
        tr2 = sum(w[i][j] * w[j][i] for i in range(n) for j in range(n))
        print(
            f"   N={n:>3}: tr(W^2) = {tr2:>10.1f}   N(N-1) = {n*(n-1):>6d}"
            f"   m_2 = {tr2 / n**2:.8f}   1 - 1/N = {1 - 1/n:.8f}"
        )
    print("\n   sandwich  (1 - 1/N)^k <= E[m_2k] <= (k+1)^{2k}   (Monte Carlo, R = 40)")
    print(f"   {'N':>4} {'k':>3} {'lower':>12} {'E[m_2k]':>12} {'upper':>16}")
    for n in (20, 60):
        for k in (1, 2, 3):
            acc = 0.0
            reps = 40
            for _ in range(reps):
                w = sample_wigner(n, rademacher, rng)
                acc += normalized_moments(w, [2 * k])[2 * k]
            est = acc / reps
            lo = (1 - 1 / n) ** k
            hi = float((k + 1) ** (2 * k))
            print(f"   {n:>4} {k:>3} {lo:>12.6f} {est:>12.6f} {hi:>16.1f}")
    print()


def demo_5_universality() -> None:
    print("=" * 78)
    print("5. Universality: four different entry laws, one limit")
    print("=" * 78)
    rng = random.Random(11235)
    laws: List[Tuple[str, EntrySampler, float]] = [
        ("Rademacher", rademacher, 1.0),
        ("Gaussian", gaussian, 3.0),
        ("Uniform", uniform_law, 9.0 / 5.0),
        ("Sparse p=0.1", sparse_law(0.1), 10.0),
    ]
    n, reps = 120, 12
    orders = [2, 3, 4, 6]
    print(f"   N = {n}, {reps} replicates.  Targets: 1, 0, 2, 5 (C_1, 0, C_2, C_3)")
    header = "   " + f"{'law':<14}{'m4':>6}" + "".join(f"{'m_' + str(k):>11}" for k in orders)
    print(header)
    for name, sampler, m4 in laws:
        acc = {k: 0.0 for k in orders}
        for _ in range(reps):
            w = sample_wigner(n, sampler, rng)
            mom = normalized_moments(w, orders)
            for k in orders:
                acc[k] += mom[k]
        row = "   " + f"{name:<14}{m4:>6.2f}" + "".join(f"{acc[k]/reps:>11.4f}" for k in orders)
        print(row)
    print("\n   The third moment is ~0 for every law; the even ones approach the")
    print("   Catalan numbers regardless of the fourth moment m4.\n")


def demo_6_variance() -> None:
    print("=" * 78)
    print("6. Exact variance of the second spectral moment: 2(m4-1)(N-1)/N^3")
    print("=" * 78)
    rng = random.Random(9001)
    reps = 400
    print(f"   {'law':<14}{'N':>5}{'empirical var':>18}{'2(m4-1)(N-1)/N^3':>20}")
    for name, sampler, m4 in [
        ("Rademacher", rademacher, 1.0),
        ("Gaussian", gaussian, 3.0),
        ("Sparse p=0.1", sparse_law(0.1), 10.0),
    ]:
        for n in (10, 25):
            vals: List[float] = []
            for _ in range(reps):
                w = sample_wigner(n, sampler, rng)
                tr2 = sum(w[i][j] * w[j][i] for i in range(n) for j in range(n))
                vals.append(tr2 / n**2)
            mean = sum(vals) / len(vals)
            var = sum((v - mean) ** 2 for v in vals) / len(vals)
            pred = 2 * (m4 - 1) * (n - 1) / n**3
            print(f"   {name:<14}{n:>5}{var:>18.8f}{pred:>20.8f}")
    print("\n   For the sign ensemble the variance is exactly zero: the second")
    print("   spectral moment is a constant, not merely concentrated.\n")


def demo_7_bulk_and_edge() -> None:
    print("=" * 78)
    print("7. Bulk tightness and the deterministic edge floor")
    print("=" * 78)
    rng = random.Random(4242)
    print("   fraction of |lambda|/sqrt(N) >= t   (Rademacher, 10 replicates)")
    print(f"   {'N':>5}" + "".join(f"{'t=' + str(t):>10}" for t in (1.5, 2.0, 2.5, 3.0)))
    for n in (20, 60, 120):
        fracs: Dict[float, float] = {t: 0.0 for t in (1.5, 2.0, 2.5, 3.0)}
        reps = 10
        for _ in range(reps):
            w = sample_wigner(n, rademacher, rng)
            lam = [abs(x) / math.sqrt(n) for x in eigenvalues_symmetric(w)]
            for t in fracs:
                fracs[t] += sum(1 for x in lam if x >= t) / n
        print(f"   {n:>5}" + "".join(f"{fracs[t]/reps:>10.4f}" for t in (1.5, 2.0, 2.5, 3.0)))
    print("\n   The bulk stays inside [-2, 2]; the bound (k+1)^{2k}/t^{2k} is uniform in N.")
    print("\n   spectral radius of W/sqrt(N) vs. the deterministic floor sqrt(1 - 1/N):")
    print(f"   {'N':>5}{'radius':>12}{'floor':>12}{'floor <= radius':>18}")
    for n in (10, 40, 160):
        w = sample_wigner(n, rademacher, rng)
        r = spectral_radius_normalized(w)
        floor = math.sqrt(1 - 1 / n)
        print(f"   {n:>5}{r:>12.6f}{floor:>12.6f}{str(floor <= r + 1e-9):>18}")
    print("\n   The floor holds for every realisation, with no exceptions; the true")
    print("   edge sits at 2, which the higher moments detect.\n")


def demo_8_histogram() -> None:
    print("=" * 78)
    print("8. The semicircle itself: an ASCII histogram of the spectrum")
    print("=" * 78)
    rng = random.Random(2718)
    n, reps, bins = 200, 6, 31
    counts = [0] * bins
    lo, hi = -2.6, 2.6
    total = 0
    for _ in range(reps):
        w = sample_wigner(n, rademacher, rng)
        for x in eigenvalues_symmetric(w):
            y = x / math.sqrt(n)
            b = int((y - lo) / (hi - lo) * bins)
            if 0 <= b < bins:
                counts[b] += 1
                total += 1
    width = (hi - lo) / bins
    scale = 46.0 / max(counts)
    print("   value      empirical                                      predicted")
    for b in range(bins):
        centre = lo + (b + 0.5) * width
        emp = counts[b] / (total * width)
        pred = math.sqrt(max(0.0, 4 - centre**2)) / (2 * math.pi)
        bar = "#" * int(counts[b] * scale)
        print(f"   {centre:>6.2f} {emp:>8.4f} {bar:<48}{pred:>8.4f}")
    print()


def main() -> None:
    print()
    print("Wigner semicircle law: numerical companion")
    print(f"(NumPy {'available' if HAVE_NUMPY else 'not available - using Jacobi fallback'})")
    print()
    demo_1_catalan()
    demo_2_dichotomy()
    demo_3_closed_forms()
    demo_4_self_averaging_and_sandwich()
    demo_5_universality()
    demo_6_variance()
    demo_7_bulk_and_edge()
    demo_8_histogram()
    print("Done.")


if __name__ == "__main__":
    main()
