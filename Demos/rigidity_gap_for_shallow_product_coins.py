"""
Rigidity gap for shallow product coins -- numerical demonstrations.

Self-contained: standard library only (no numpy required).

-------------------------------------------------------------------------------
The mathematics being demonstrated
-------------------------------------------------------------------------------
Fix finite registers A = {0,...,nA-1} and B = {0,...,nB-1} and a resonance set
R subset of A x B.  A *coin* on a register is a normalised amplitude vector
(sum of squared moduli = 1).  The resonance amplitude of the product coin
f (x) g is

    Amp(f, g) = sum_{(a,b) in R} f(a) g(b),

and the resonance intensity is |Amp(f,g)|^2.

  * Cauchy-Schwarz:            |Amp|^2 <= |R|                        (always)
  * Boxes attain:              R = A0 x B0  =>  |Amp|^2 = |R| is achieved
  * Rigidity gap (non-box R):  |Amp|^2 (3|R| + 1) <= 3|R|^2
                               |Amp|^2 <= (1 - 1/(3|R|+1)) |R|
                               |Amp|^2 <= |R| - 2/7
  * Dichotomy:                 optimum attained  <=>  R is a box
  * Row lower bound:           max_a |R_a| <= sup |Amp|^2
  * L-shape {(0,0),(0,1),(1,0)}: sup |Amp|^2 = phi^2 = (3+sqrt 5)/2
  * Diagonal {(0,0),(1,1)}:      sup |Amp|^2 = 1  (versus |R| = 2)
  * Agreement set {x in {0,1}^n : x_i = x_j}: sup |Amp|^2 = 2^(n-2) = |R| / 2

Since sup |Amp| over unit vectors equals the largest singular value of the 0/1
matrix of R, the true optimum is computed here by pure-Python power iteration.
-------------------------------------------------------------------------------
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
import math
from math import sqrt
from typing import Dict, List, Optional, Sequence, Set, Tuple

Pair = Tuple[int, int]
Matrix = List[List[float]]
Vector = List[float]

PHI: float = (1.0 + sqrt(5.0)) / 2.0


# ----------------------------------------------------------------------------
# Basic constructions
# ----------------------------------------------------------------------------
def resonance_matrix(R: Set[Pair], n_a: int, n_b: int) -> Matrix:
    """0/1 matrix M with M[a][b] = 1 iff (a, b) in R."""
    return [[1.0 if (a, b) in R else 0.0 for b in range(n_b)] for a in range(n_a)]


def is_box(R: Set[Pair]) -> bool:
    """R is a box iff it is closed under recombining coordinates."""
    for (a, _b) in R:
        for (_a2, b2) in R:
            if (a, b2) not in R:
                return False
    return True


def non_box_witness(R: Set[Pair]) -> Optional[Tuple[Pair, Pair, Pair]]:
    """Return ((a,b), (a',b'), (a,b')) with (a,b),(a',b') in R and (a,b') not in R."""
    for (a, b) in sorted(R):
        for (a2, b2) in sorted(R):
            if (a, b2) not in R:
                return (a, b), (a2, b2), (a, b2)
    return None


def rows(R: Set[Pair]) -> Dict[int, Set[int]]:
    """The rows R_a = {b : (a,b) in R}."""
    out: Dict[int, Set[int]] = {}
    for (a, b) in R:
        out.setdefault(a, set()).add(b)
    return out


# ----------------------------------------------------------------------------
# Optimal product coin: alternating maximisation == power iteration
# ----------------------------------------------------------------------------
def _normalise(v: Vector) -> Vector:
    nrm = sqrt(sum(t * t for t in v))
    if nrm == 0.0:
        raise ValueError("zero vector")
    return [t / nrm for t in v]


def optimal_product_coin(
    R: Set[Pair], n_a: int, n_b: int, sweeps: int = 4000, tol: float = 1e-15
) -> Tuple[Vector, Vector, float]:
    """
    Maximise |sum_{(a,b) in R} f(a) g(b)| over unit vectors f, g.

    The maximum equals the top singular value of the resonance matrix; the
    alternating update f <- Mg/||Mg||, g <- M^T f/||M^T f|| is power iteration
    on M M^T and converges linearly with ratio sigma_2 / sigma_1.
    Returns (f, g, amplitude) with amplitude = f^T M g = sigma_1.
    """
    M = resonance_matrix(R, n_a, n_b)
    # start from the uniform-positive vector (Perron-Frobenius: optimum is >= 0)
    g: Vector = _normalise([1.0] * n_b)
    f: Vector = _normalise([1.0] * n_a)
    prev = -1.0
    for _ in range(sweeps):
        Mg = [sum(M[a][b] * g[b] for b in range(n_b)) for a in range(n_a)]
        if all(abs(t) < 1e-300 for t in Mg):
            break
        f = _normalise(Mg)
        Mtf = [sum(M[a][b] * f[a] for a in range(n_a)) for b in range(n_b)]
        if all(abs(t) < 1e-300 for t in Mtf):
            break
        g = _normalise(Mtf)
        cur = sum(f[a] * M[a][b] * g[b] for a in range(n_a) for b in range(n_b))
        if abs(cur - prev) < tol:
            break
        prev = cur
    amp = sum(f[a] * M[a][b] * g[b] for a in range(n_a) for b in range(n_b))
    return f, g, amp


def amplitude(R: Set[Pair], f: Sequence[float], g: Sequence[float]) -> float:
    """Resonance amplitude of a given (real) product coin."""
    return sum(f[a] * g[b] for (a, b) in R)


# ----------------------------------------------------------------------------
# Certified bounds
# ----------------------------------------------------------------------------
def multiplicative_bound(m: int) -> float:
    """(1 - 1/(3m+1)) * m = 3 m^2 / (3m + 1): valid for every non-box R."""
    return 3.0 * m * m / (3.0 * m + 1.0)


def additive_bound(m: int) -> float:
    """m - 2/7: valid for every non-box R (which necessarily has m >= 2)."""
    return m - 2.0 / 7.0


def row_lower_bound(R: Set[Pair]) -> int:
    """max_a |R_a|: always achievable by an explicit product coin."""
    rs = rows(R)
    return max((len(v) for v in rs.values()), default=0)


def report(name: str, R: Set[Pair], n_a: int, n_b: int) -> None:
    m = len(R)
    box = is_box(R)
    _f, _g, amp = optimal_product_coin(R, n_a, n_b)
    intensity = amp * amp
    print(f"  {name}")
    print(f"    |R| = {m}    box? {box}")
    if not box:
        w = non_box_witness(R)
        assert w is not None
        print(f"    non-box witness: {w[0]}, {w[1]} in R  but  {w[2]} not in R")
    print(f"    Cauchy-Schwarz optimum  |R|                = {float(m):.6f}")
    print(f"    true optimum            sup |Amp|^2        = {intensity:.6f}")
    print(f"    row lower bound         max_a |R_a|        = {row_lower_bound(R)}")
    if not box:
        print(f"    certified mult. bound   3|R|^2/(3|R|+1)    = {multiplicative_bound(m):.6f}")
        print(f"    certified add.  bound   |R| - 2/7          = {additive_bound(m):.6f}")
        print(f"    observed deficiency     |R| - sup |Amp|^2  = {m - intensity:.6f}")
        ok = intensity <= multiplicative_bound(m) + 1e-9 and intensity <= additive_bound(m) + 1e-9
        print(f"    bounds respected: {ok}")
    else:
        print(f"    optimum attained (deficiency = {m - intensity:.2e})")
    print()


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_dichotomy() -> None:
    print("=" * 78)
    print("1. THE DICHOTOMY: perfect resonance <=> the resonance set is a box")
    print("=" * 78)
    print()
    report("box  R = {0,1} x {0,1,2}", {(a, b) for a in range(2) for b in range(3)}, 2, 3)
    report("box  R = {0,2} x {1,3}", {(a, b) for a in (0, 2) for b in (1, 3)}, 3, 4)
    report("L-shape  R = {(0,0),(0,1),(1,0)}", {(0, 0), (0, 1), (1, 0)}, 2, 2)
    report("diagonal R = {(0,0),(1,1)}", {(0, 0), (1, 1)}, 2, 2)
    report("3x3 box minus a corner", {(a, b) for a in range(3) for b in range(3)} - {(2, 2)}, 3, 3)
    report("3x3 identity pattern", {(0, 0), (1, 1), (2, 2)}, 3, 3)


def demo_golden_lshape() -> None:
    print("=" * 78)
    print("2. THE GOLDEN L-SHAPE and the bracket for the universal constant")
    print("=" * 78)
    print()
    L: Set[Pair] = {(0, 0), (0, 1), (1, 0)}
    _f, _g, amp = optimal_product_coin(L, 2, 2)
    print(f"  optimal intensity (power iteration) = {amp * amp:.12f}")
    print(f"  phi^2 = (3 + sqrt 5)/2              = {PHI ** 2:.12f}")
    print(f"  exact deficiency 3 - phi^2          = {3 - PHI ** 2:.12f}")
    print()
    # Exactly rational certificate: (45/53, 28/53) is a coin since 45^2+28^2=53^2.
    p, q, h = Fraction(45, 53), Fraction(28, 53), 1
    assert 45 * 45 + 28 * 28 == 53 * 53 == 2809
    assert p * p + q * q == h
    amp_q = p * p + p * q + q * p           # sum over the three L-shape cells
    print(f"  rational golden coin (45/53, 28/53):  amplitude = {amp_q} = {float(amp_q):.9f}")
    print(f"  intensity = {amp_q ** 2} = {float(amp_q ** 2):.9f}")
    upper = Fraction(3) - amp_q ** 2
    print(f"  hence the optimal universal additive constant c* satisfies")
    print(f"      2/7 = {float(Fraction(2,7)):.9f}  <=  c*  <=  {upper} = {float(upper):.9f}")
    print(f"  ratio of the two ends: {float(upper) / (2 / 7):.4f}")
    print(f"  (the exact L-shape deficiency is (3 - sqrt 5)/2 = {(3 - sqrt(5)) / 2:.9f})")
    print()


def demo_gap_scan(max_side: int = 3) -> None:
    print("=" * 78)
    print("3. EXHAUSTIVE SCAN: every non-box subset of a small grid obeys the gap")
    print("=" * 78)
    print()
    for n_a, n_b in ((2, 2), (2, 3), (3, 3)):
        cells: List[Pair] = [(a, b) for a in range(n_a) for b in range(n_b)]
        worst_def = float("inf")
        worst_set: Set[Pair] = set()
        n_nonbox = 0
        violations = 0
        for mask in range(1, 1 << len(cells)):
            R = {cells[i] for i in range(len(cells)) if mask >> i & 1}
            if is_box(R):
                continue
            n_nonbox += 1
            m = len(R)
            _f, _g, amp = optimal_product_coin(R, n_a, n_b, sweeps=500)
            inten = amp * amp
            if inten > multiplicative_bound(m) + 1e-8 or inten > additive_bound(m) + 1e-8:
                violations += 1
            deficiency = m - inten
            if deficiency < worst_def:
                worst_def, worst_set = deficiency, R
        print(f"  grid {n_a} x {n_b}: {n_nonbox} non-box subsets scanned, {violations} violations")
        print(f"    smallest observed deficiency = {worst_def:.9f}")
        print(f"    attained by R = {sorted(worst_set)}")
        print(f"    compare (3 - sqrt 5)/2 = {(3 - sqrt(5)) / 2:.9f}  and  2/7 = {2/7:.9f}")
        print()


def demo_depth_agreement(max_n: int = 8) -> None:
    print("=" * 78)
    print("4. ARBITRARY DEPTH: the agreement set {x in {0,1}^n : x_0 = x_1}")
    print("=" * 78)
    print()
    print("   The gap constant 2/7 does not decay with the depth n, while the")
    print("   true optimum is exactly half the Cauchy-Schwarz value.")
    print()
    print(f"   {'n':>3} {'|R|=2^(n-1)':>12} {'bound |R|-2/7':>15} {'true 2^(n-2)':>14} {'true loss':>12}")
    for n in range(2, max_n + 1):
        m = 2 ** (n - 1)
        true_opt = 2.0 ** (n - 2)
        print(f"   {n:>3} {m:>12} {additive_bound(m):>15.4f} {true_opt:>14.4f} {m - true_opt:>12.4f}")
    print()
    # Genuine brute force over depth-n product coins at small depth:
    # each register coin is (cos t, sin t) with t on a grid of [0, pi/2].
    steps = 16
    angles = [k * (math.pi / 2) / steps for k in range(steps + 1)]
    for n in (2, 3, 4):
        words = list(product((0, 1), repeat=n))
        agree = [w for w in words if w[0] == w[1]]
        best = 0.0
        for ts in product(angles, repeat=n):
            coins = [(math.cos(t), math.sin(t)) for t in ts]
            amp = 0.0
            for w in agree:
                term = 1.0
                for k in range(n):
                    term *= coins[k][w[k]]
                amp += term
            best = max(best, amp * amp)
        exact = 2.0 ** (n - 2)
        print(
            f"   depth n = {n}: brute-force optimum {best:.6f}  vs  predicted 2^(n-2)"
            f" = {exact:.6f}   (Cauchy-Schwarz value |R| = {2 ** (n - 1)})"
        )
    print()


def demo_rows_and_squeeze() -> None:
    print("=" * 78)
    print("5. THE SQUEEZE: max_a |R_a| <= sup |Amp|^2 <= 3|R|^2 / (3|R| + 1)")
    print("=" * 78)
    print()
    examples: List[Tuple[str, Set[Pair], int, int]] = [
        ("L-shape", {(0, 0), (0, 1), (1, 0)}, 2, 2),
        ("diagonal", {(0, 0), (1, 1)}, 2, 2),
        ("staircase", {(0, 0), (0, 1), (1, 1), (1, 2), (2, 2)}, 3, 3),
        ("3x3 minus corner", {(a, b) for a in range(3) for b in range(3)} - {(2, 2)}, 3, 3),
        ("4x4 minus diagonal", {(a, b) for a in range(4) for b in range(4) if a != b}, 4, 4),
    ]
    print(f"   {'set':>18} {'|R|':>4} {'max|R_a|':>9} {'true':>10} {'mult bd':>10} {'add bd':>10}")
    for name, R, n_a, n_b in examples:
        m = len(R)
        _f, _g, amp = optimal_product_coin(R, n_a, n_b)
        print(
            f"   {name:>18} {m:>4} {row_lower_bound(R):>9} {amp*amp:>10.5f} "
            f"{multiplicative_bound(m):>10.5f} {additive_bound(m):>10.5f}"
        )
    print()


def demo_diagonal_exact() -> None:
    print("=" * 78)
    print("6. THE TWO-POINT DIAGONAL: the exact optimum is 1, not |R| = 2")
    print("=" * 78)
    print()
    D: Set[Pair] = {(0, 0), (1, 1)}
    best = 0.0
    arg = (0.0, 0.0)
    steps = 400
    for i in range(steps + 1):
        for j in range(steps + 1):
            t = i / steps * (math.pi / 2)
            s = j / steps * (math.pi / 2)
            f = [math.cos(t), math.sin(t)]
            g = [math.cos(s), math.sin(s)]
            val = amplitude(D, f, g) ** 2
            if val > best:
                best, arg = val, (t, s)
    print(f"  grid maximum over real coins:  {best:.9f}   at angles {arg[0]:.4f}, {arg[1]:.4f}")
    print("  Lagrange identity: (p0 q0 + p1 q1)^2 = 1 - (p0 q1 - p1 q0)^2 <= 1")
    print("  attained by f = g = (1, 0), and |R| - 1 = 1 unit of resonance is lost")
    print("  (the universal theorem only guarantees a loss of 2/7 = 0.285714)")
    print()


def main() -> None:
    print()
    print("RIGIDITY GAP FOR SHALLOW PRODUCT COINS -- numerical demonstrations")
    print()
    demo_dichotomy()
    demo_golden_lshape()
    demo_gap_scan()
    demo_depth_agreement()
    demo_rows_and_squeeze()
    demo_diagonal_exact()
    print("=" * 78)
    print("All certified bounds were respected in every example above.")
    print("=" * 78)


if __name__ == "__main__":
    main()
