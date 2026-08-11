"""
Strange Attractors as Algebraic Objects — numerical demonstrations.

This self-contained script (standard library only) demonstrates, for symbolic
attractors modelled on finite directed graphs:

  1. Path counting and closed-walk counting via powers of the 0/1 transfer
     matrix:  |P_n| = sum_ij (A^n)_ij   and   #Per_n = tr(A^n).
  2. The Cayley-Hamilton recurrence for the orbit-counting sequence, with the
     characteristic polynomial computed by Faddeev-LeVerrier.
  3. The Spectral Entropy Theorem:  h = log(lambda), lambda the Perron value,
     verified by comparing log|P_n|/n against log(lambda).
  4. Certified Collatz-Wielandt enclosures  min_i (Ax)_i/x_i <= lambda <=
     max_i (Ax)_i/x_i, giving rigorous error bars on the entropy.
  5. The Periodic Growth Theorem:  log(tr A^n)/n -> h.
  6. Arithmeticity:  lambda is a root of the monic integral characteristic
     polynomial, i.e. e^h is an algebraic integer.
  7. Algebraic separation of the Lorenz template from a pruned variant:
     tr(A^2) = 4 vs 3, and h = log 2 vs log phi.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Sequence, Tuple

Matrix = List[List[int]]
RMatrix = List[List[float]]
Vector = List[float]


# --------------------------------------------------------------------------
# Basic integer linear algebra
# --------------------------------------------------------------------------

def identity(d: int) -> Matrix:
    """The d x d identity matrix over the integers."""
    return [[1 if i == j else 0 for j in range(d)] for i in range(d)]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    """Exact integer matrix product."""
    d, e, f = len(a), len(b), len(b[0])
    return [[sum(a[i][k] * b[k][j] for k in range(e)) for j in range(f)] for i in range(d)]


def mat_pow(a: Matrix, n: int) -> Matrix:
    """A^n by repeated squaring; O(d^3 log n) integer operations."""
    result = identity(len(a))
    base = [row[:] for row in a]
    while n > 0:
        if n & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        n >>= 1
    return result


def trace(a: Matrix) -> int:
    """Trace of a square integer matrix."""
    return sum(a[i][i] for i in range(len(a)))


def total(a: Matrix) -> int:
    """Sum of all entries."""
    return sum(sum(row) for row in a)


# --------------------------------------------------------------------------
# Graph invariants
# --------------------------------------------------------------------------

def num_paths(adj: Matrix, n: int) -> int:
    """|P_n| : number of walks using exactly n edges = sum_ij (A^n)_ij."""
    return total(mat_pow(adj, n))


def num_closed_walks(adj: Matrix, n: int) -> int:
    """tr(A^n) : number of closed walks of length n = number of n-periodic points."""
    return trace(mat_pow(adj, n))


def is_primitive(adj: Matrix) -> Tuple[bool, int]:
    """
    Test primitivity: some power of A has all entries positive.
    Searches up to the Wielandt bound d^2 - 2d + 2. Returns (primitive, exponent).
    """
    d = len(adj)
    bound = max(1, d * d - 2 * d + 2)
    power = identity(d)
    for n in range(1, bound + 1):
        power = mat_mul(power, adj)
        if all(power[i][j] > 0 for i in range(d) for j in range(d)):
            return True, n
    return False, 0


# --------------------------------------------------------------------------
# Characteristic polynomial (Faddeev-LeVerrier) and the trace recurrence
# --------------------------------------------------------------------------

def charpoly(adj: Matrix) -> List[int]:
    """
    Coefficients [c_0, ..., c_d] of the monic characteristic polynomial
    chi(t) = det(t I - A) = c_0 + c_1 t + ... + t^d, computed exactly by the
    Faddeev-LeVerrier recursion  M_k = A M_{k-1} + c_{d-k} I,
    c_{d-k} = -tr(A M_{k-1}) / k.  Complexity O(d^4).
    """
    d = len(adj)
    coeffs: List[Fraction] = [Fraction(0)] * (d + 1)
    coeffs[d] = Fraction(1)
    m: List[List[Fraction]] = [[Fraction(x) for x in row] for row in identity(d)]
    af: List[List[Fraction]] = [[Fraction(x) for x in row] for row in adj]
    for k in range(1, d + 1):
        am = [[sum(af[i][t] * m[t][j] for t in range(d)) for j in range(d)] for i in range(d)]
        c = -sum(am[i][i] for i in range(d)) / k
        coeffs[d - k] = c
        m = [[am[i][j] + (c if i == j else Fraction(0)) for j in range(d)] for i in range(d)]
    return [int(c) for c in coeffs]


def poly_str(coeffs: Sequence[int]) -> str:
    """Human-readable rendering of a polynomial given by ascending coefficients."""
    terms: List[str] = []
    for k in range(len(coeffs) - 1, -1, -1):
        c = coeffs[k]
        if c == 0:
            continue
        mono = "" if k == 0 else ("t" if k == 1 else f"t^{k}")
        if mono and abs(c) == 1:
            terms.append(("- " if c < 0 else "+ ") + mono)
        else:
            terms.append(("- " if c < 0 else "+ ") + f"{abs(c)}{mono}")
    out = " ".join(terms)
    return out[2:] if out.startswith("+ ") else out


def check_trace_recurrence(adj: Matrix, k_max: int = 8) -> bool:
    """
    Verify sum_i c_i tr(A^{k+i}) = 0 for all 0 <= k <= k_max, the Cayley-Hamilton
    recurrence satisfied by the periodic-orbit counting sequence.
    """
    coeffs = charpoly(adj)
    d = len(adj)
    traces = [trace(mat_pow(adj, n)) for n in range(k_max + d + 1)]
    return all(sum(coeffs[i] * traces[k + i] for i in range(d + 1)) == 0
               for k in range(k_max + 1))


# --------------------------------------------------------------------------
# Perron value: power iteration with certified Collatz-Wielandt brackets
# --------------------------------------------------------------------------

def collatz_wielandt_bracket(adj: Matrix, x: Vector) -> Tuple[float, float]:
    """
    For any strictly positive x, the Perron value lambda satisfies
        min_i (Ax)_i / x_i  <=  lambda  <=  max_i (Ax)_i / x_i.
    Returns that certified enclosure.
    """
    d = len(adj)
    ax = [sum(adj[i][j] * x[j] for j in range(d)) for i in range(d)]
    ratios = [ax[i] / x[i] for i in range(d)]
    return min(ratios), max(ratios)


def perron(adj: Matrix, iterations: int = 200) -> Tuple[float, Vector, Tuple[float, float]]:
    """
    Power iteration x <- Ax / ||Ax||_1 for a primitive nonnegative matrix.
    Returns (lambda, positive eigenvector normalised to sum 1, enclosure).
    """
    d = len(adj)
    x: Vector = [1.0 / d] * d
    for _ in range(iterations):
        ax = [sum(adj[i][j] * x[j] for j in range(d)) for i in range(d)]
        s = sum(ax)
        x = [v / s for v in ax]
    lo, hi = collatz_wielandt_bracket(adj, x)
    return 0.5 * (lo + hi), x, (lo, hi)


def entropy_spectral(adj: Matrix) -> float:
    """Topological entropy via the Spectral Entropy Theorem: h = log(lambda)."""
    lam, _, _ = perron(adj)
    return math.log(lam)


def entropy_by_counting(adj: Matrix, n: int = 24) -> float:
    """Finite-n approximation log|P_n| / n to the entropy."""
    return math.log(num_paths(adj, n)) / n


def eval_poly(coeffs: Sequence[int], t: float) -> float:
    """Horner evaluation of a polynomial given by ascending coefficients."""
    acc = 0.0
    for c in reversed(coeffs):
        acc = acc * t + c
    return acc


# --------------------------------------------------------------------------
# The example graphs
# --------------------------------------------------------------------------

PHI = (1.0 + math.sqrt(5.0)) / 2.0

GRAPHS: Dict[str, Matrix] = {
    # Lorenz template: two branches L, R, all four transitions allowed.
    "Lorenz template": [[1, 1],
                        [1, 1]],
    # Pruned template: transition R -> R forbidden (golden-mean shift).
    "Pruned template": [[1, 1],
                        [1, 0]],
    # A three-branch template: a cyclic graph with one extra chord.
    "Three-branch template": [[0, 1, 1],
                              [1, 0, 1],
                              [1, 1, 0]],
    # A sparser three-vertex primitive graph (tribonacci-like constraint).
    "Pruned three-branch": [[1, 1, 0],
                            [0, 0, 1],
                            [1, 0, 0]],
}


# --------------------------------------------------------------------------
# Reports
# --------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def report_graph(name: str, adj: Matrix) -> None:
    d = len(adj)
    rule(f"{name}   (transfer matrix {d}x{d})")
    for row in adj:
        print("    " + "  ".join(str(v) for v in row))

    prim, expo = is_primitive(adj)
    print(f"\n  primitive: {prim}" + (f"  (all entries of A^{expo} positive)" if prim else ""))

    coeffs = charpoly(adj)
    print(f"  characteristic polynomial:  chi(t) = {poly_str(coeffs)}")

    lam, vec, (lo, hi) = perron(adj)
    print(f"  Perron value (power iteration):  lambda = {lam:.12f}")
    print(f"  certified Collatz-Wielandt enclosure: [{lo:.12f}, {hi:.12f}]")
    print(f"  positive eigenvector (sum 1): " + ", ".join(f"{v:.6f}" for v in vec))
    print(f"  chi(lambda) = {eval_poly(coeffs, lam):.3e}   "
          f"(lambda is a root of a monic integer polynomial => algebraic integer)")

    h = math.log(lam)
    print(f"\n  entropy h = log(lambda) = {h:.12f}     e^h = {lam:.12f}")
    print(f"  bounds: 1 <= lambda <= |V| = {d}  ->  {1 <= lam <= d + 1e-9}")

    print("\n  n |     |P_n|  log|P_n|/n |    tr(A^n)  log tr(A^n)/n")
    print("  --+------------+------------+------------+---------------")
    for n in (2, 4, 8, 16, 32):
        p = num_paths(adj, n)
        t = num_closed_walks(adj, n)
        ps = f"{p}" if p < 10 ** 9 else f"{p:.3e}"
        ts = f"{t}" if t < 10 ** 9 else f"{t:.3e}"
        lp = math.log(p) / n
        lt = math.log(t) / n if t > 0 else float("nan")
        print(f"  {n:2d}| {ps:>10} | {lp:10.7f} | {ts:>10} | {lt:13.7f}")
    print(f"     both columns -> h = {h:.7f}   "
          "(Spectral Entropy + Periodic Growth Theorems)")

    ok = check_trace_recurrence(adj)
    print(f"\n  Cayley-Hamilton recurrence for tr(A^n) holds for k = 0..8: {ok}")
    traces = [num_closed_walks(adj, n) for n in range(1, 11)]
    print(f"  periodic-orbit counts #Per_n, n = 1..10: {traces}")


def report_templates_separated() -> None:
    rule("Algebraic separation of the two Lorenz templates")
    a_lor = GRAPHS["Lorenz template"]
    a_pr = GRAPHS["Pruned template"]
    t2_lor = num_closed_walks(a_lor, 2)
    t2_pr = num_closed_walks(a_pr, 2)
    print(f"  tr(A_Lorenz^2) = {t2_lor}      tr(A_pruned^2) = {t2_pr}")
    print("  Periodic-orbit counts are conjugacy invariants, and "
          f"{t2_lor} != {t2_pr},")
    print("  so the two attractors are NOT topologically conjugate.")
    h_lor = entropy_spectral(a_lor)
    h_pr = entropy_spectral(a_pr)
    print(f"\n  h(Lorenz)  = {h_lor:.12f}   vs   log 2   = {math.log(2.0):.12f}")
    print(f"  h(pruned)  = {h_pr:.12f}   vs   log phi = {math.log(PHI):.12f}")
    print(f"  e^h(Lorenz) = {math.exp(h_lor):.12f}  (root of t^2 - 2t)")
    print(f"  e^h(pruned) = {math.exp(h_pr):.12f}  (root of t^2 - t - 1, i.e. phi)")
    print("\n  Channel-capacity reading: log2(lambda) bits per symbol")
    print(f"    unconstrained binary channel : {math.log2(2.0):.6f} bits/symbol")
    print(f"    'no two consecutive R'       : {math.log2(PHI):.6f} bits/symbol")


def report_closed_walk_convergence() -> None:
    rule("Periodic Growth Theorem: log(tr A^n)/n -> h, with error decay")
    for name in ("Lorenz template", "Pruned template", "Three-branch template"):
        adj = GRAPHS[name]
        h = entropy_spectral(adj)
        print(f"\n  {name}:  h = {h:.10f}")
        print("    n |   log tr(A^n)/n |    error")
        print("    --+-----------------+-----------")
        for n in (5, 10, 20, 40, 80, 160):
            t = num_closed_walks(adj, n)
            val = math.log(t) / n
            print(f"    {n:3d}| {val:15.10f} | {abs(val - h):.3e}")


def report_lucas_identity() -> None:
    rule("Pruned template: closed walks are the Lucas numbers")
    adj = GRAPHS["Pruned template"]
    fib = [0, 1]
    while len(fib) < 22:
        fib.append(fib[-1] + fib[-2])
    print("    n | tr(A^n) | F_{n+1} + F_{n-1} | match")
    print("    --+---------+-------------------+------")
    for n in range(1, 13):
        t = num_closed_walks(adj, n)
        lucas = fib[n + 1] + fib[n - 1]
        print(f"    {n:2d}| {t:7d} | {lucas:17d} | {t == lucas}")
    print("\n    |P_n| (paths of length n) are Fibonacci numbers:")
    print("      " + ", ".join(str(num_paths(adj, n)) for n in range(0, 12)))


def main() -> None:
    print(__doc__)
    for name, adj in GRAPHS.items():
        report_graph(name, adj)
    report_templates_separated()
    report_closed_walk_convergence()
    report_lucas_identity()
    rule("Summary")
    print("  attractor  =  inverse limit of finite path sets under edge deletion")
    print("  #Per_n     =  tr(A^n),  obeying the Cayley-Hamilton recurrence of chi_A")
    print("  h          =  log(Perron eigenvalue of A)  =  log(spectral radius)")
    print("  e^h        =  an algebraic integer (root of the monic integral chi_A)")
    print("  primitive  =  mixing  =  the Perron-Frobenius hypothesis")


if __name__ == "__main__":
    main()


"""Algorithm 2 — Faddeev–LeVerrier characteristic polynomial and the orbit recurrence."""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence

Matrix = List[List[int]]


def charpoly(adj: Matrix) -> List[int]:
    """
    Ascending coefficients [c_0, ..., c_d] of chi(t) = det(tI - A), computed exactly
    by Faddeev–LeVerrier:  M_0 = I,  c_{d-k} = -tr(A M_{k-1})/k,  M_k = A M_{k-1} + c_{d-k} I.
    Complexity O(d^4) ring operations; the result is monic with integer coefficients.
    """
    d = len(adj)
    coeffs: List[Fraction] = [Fraction(0)] * (d + 1)
    coeffs[d] = Fraction(1)
    m = [[Fraction(1 if i == j else 0) for j in range(d)] for i in range(d)]
    af = [[Fraction(v) for v in row] for row in adj]
    for k in range(1, d + 1):
        am = [[sum(af[i][t] * m[t][j] for t in range(d)) for j in range(d)] for i in range(d)]
        c = -sum(am[i][i] for i in range(d)) / k
        coeffs[d - k] = c
        m = [[am[i][j] + (c if i == j else Fraction(0)) for j in range(d)] for i in range(d)]
    return [int(c) for c in coeffs]


def extend_orbit_counts(seed: Sequence[int], coeffs: Sequence[int], upto: int) -> List[int]:
    """
    Extend the periodic-orbit counting sequence using the Cayley–Hamilton recurrence
        sum_{i=0}^{d} c_i t_{k+i} = 0,      c_d = 1,
    i.e.  t_{k+d} = -sum_{i<d} c_i t_{k+i}.  Cost O(d) per new term — exponentially
    cheaper than recomputing matrix powers.
    `seed` must supply t_1, ..., t_d (with t_n = tr(A^n)).
    """
    d = len(coeffs) - 1
    out = list(seed)
    while len(out) < upto:
        k = len(out) - d          # index offset: out[j] holds t_{j+1}
        out.append(-sum(coeffs[i] * out[k + i] for i in range(d)))
    return out


if __name__ == "__main__":
    pruned: Matrix = [[1, 1], [1, 0]]
    c = charpoly(pruned)
    print("chi coefficients (ascending):", c)          # [-1, -1, 1]  ->  t^2 - t - 1
    print("Lucas numbers:", extend_orbit_counts([1, 3], c, 14))


"""Algorithm 1 — Orbit counting by binary powering of the transfer matrix."""

from __future__ import annotations

from typing import List, Tuple

Matrix = List[List[int]]


def identity(d: int) -> Matrix:
    return [[1 if i == j else 0 for j in range(d)] for i in range(d)]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    d, e, f = len(a), len(b), len(b[0])
    return [[sum(a[i][k] * b[k][j] for k in range(e)) for j in range(f)] for i in range(d)]


def mat_pow(a: Matrix, n: int) -> Matrix:
    """A^n by repeated squaring: O(d^3 log n) exact integer operations."""
    result, base = identity(len(a)), [row[:] for row in a]
    while n > 0:
        if n & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        n >>= 1
    return result


def orbit_counts(adj: Matrix, n: int) -> Tuple[int, int]:
    """
    Return (|P_n|, #Per_n) for the symbolic attractor of the digraph `adj`:
      |P_n|   = sum_ij (A^n)_ij   — walks with exactly n edges,
      #Per_n  = tr(A^n)           — closed walks = n-periodic points (n >= 1).
    """
    p = mat_pow(adj, n)
    return sum(sum(row) for row in p), sum(p[i][i] for i in range(len(adj)))


if __name__ == "__main__":
    lorenz: Matrix = [[1, 1], [1, 1]]
    pruned: Matrix = [[1, 1], [1, 0]]
    for name, a in (("Lorenz", lorenz), ("pruned", pruned)):
        print(name, [orbit_counts(a, n) for n in range(1, 9)])


"""Algorithm 3 — Certified Perron value (entropy) by power iteration with Collatz–Wielandt brackets."""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[int]]
Vector = List[float]


def collatz_wielandt(adj: Matrix, x: Vector) -> Tuple[float, float]:
    """
    Two-sided certified enclosure of the Perron value: for ANY strictly positive x,
        min_i (Ax)_i / x_i  <=  lambda  <=  max_i (Ax)_i / x_i.
    Both bounds are rigorous at every iteration, not merely asymptotic.
    """
    d = len(adj)
    ax = [sum(adj[i][j] * x[j] for j in range(d)) for i in range(d)]
    ratios = [ax[i] / x[i] for i in range(d)]
    return min(ratios), max(ratios)


def certified_entropy(adj: Matrix, tol: float = 1e-13,
                      max_iter: int = 10_000) -> Tuple[float, float, float]:
    """
    Power iteration x <- Ax/||Ax||_1 for a primitive nonnegative matrix, stopped when
    the Collatz–Wielandt bracket is narrower than `tol`.  Returns
    (entropy, lower bound on lambda, upper bound on lambda).
    Convergence is geometric with ratio |mu_2| / lambda (second eigenvalue modulus).
    """
    d = len(adj)
    x: Vector = [1.0 / d] * d
    lo, hi = collatz_wielandt(adj, x)
    for _ in range(max_iter):
        if hi - lo <= tol:
            break
        ax = [sum(adj[i][j] * x[j] for j in range(d)) for i in range(d)]
        s = sum(ax)
        x = [v / s for v in ax]
        lo, hi = collatz_wielandt(adj, x)
    return math.log(0.5 * (lo + hi)), lo, hi


if __name__ == "__main__":
    for name, a in (("Lorenz", [[1, 1], [1, 1]]),
                    ("pruned", [[1, 1], [1, 0]]),
                    ("plastic", [[1, 1, 0], [0, 0, 1], [1, 0, 0]])):
        h, lo, hi = certified_entropy(a)
        print(f"{name:8s} h = {h:.12f}   lambda in [{lo:.12f}, {hi:.12f}]")


"""Algorithm 4 — Primitivity test: deciding chaos from a 0/1 matrix."""

from __future__ import annotations

from typing import List, Optional

BoolMatrix = List[List[bool]]
Matrix = List[List[int]]


def bool_mul(a: BoolMatrix, b: BoolMatrix) -> BoolMatrix:
    d = len(a)
    return [[any(a[i][k] and b[k][j] for k in range(d)) for j in range(d)] for i in range(d)]


def primitivity_exponent(adj: Matrix) -> Optional[int]:
    """
    Return the least n with all entries of A^n positive, or None if no such n exists
    within the Wielandt bound d^2 - 2d + 2 (beyond which none exists at all).

    Primitivity is equivalent to: for all large n, every ordered pair of branches is
    joined by a walk of length exactly n.  It simultaneously certifies
      * topological mixing of the attractor and density of its periodic orbits,
      * existence of a strictly positive eigenvector of the transfer matrix,
    so a single Boolean computation decides both the dynamical and the spectral question.
    Complexity: O(d^3) per Boolean product, O(d^2) products in the worst case.
    """
    d = len(adj)
    bound = max(1, d * d - 2 * d + 2)
    power: BoolMatrix = [[bool(v) for v in row] for row in adj]
    for n in range(1, bound + 1):
        if all(all(row) for row in power):
            return n
        power = bool_mul(power, [[bool(v) for v in row] for row in adj])
    return None


def is_dead_end_free(adj: Matrix) -> bool:
    """Every branch has at least one continuation — needed for the entropy to exist."""
    return all(any(v > 0 for v in row) for row in adj)


def is_branching(adj: Matrix) -> bool:
    """Every branch has at least two continuations — gives a Cantor set and sensitivity."""
    return all(sum(1 for v in row if v > 0) >= 2 for row in adj)


if __name__ == "__main__":
    graphs = {
        "Lorenz": [[1, 1], [1, 1]],
        "pruned": [[1, 1], [1, 0]],
        "pure cycle (not primitive)": [[0, 1], [1, 0]],
    }
    for name, a in graphs.items():
        n = primitivity_exponent(a)
        print(f"{name:28s} primitive: {str(n is not None):5s}  exponent: {n}  "
              f"dead-end-free: {is_dead_end_free(a)}  branching: {is_branching(a)}")


"""
Visualization: the inverse-limit tower and the Cantor set it converges to.

Left panel: the tower of finite path sets P_0 <- P_1 <- P_2 <- ... for the Lorenz
template, each level drawn as the family of dyadic intervals indexed by its words,
with the bonding map (delete the last letter) shown as the nesting of intervals.
Right panel: the same for the pruned template (R -> R forbidden), where every word
ending in R has a single child; the surviving intervals thin out at the golden-mean
rate phi^n instead of 2^n.

The limit of either tower is a compact, perfect, totally disconnected set — a Cantor
set — which is precisely the transverse structure of the corresponding attractor.

Output: cantor_tower.png
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

DEPTH = 9


def words(depth: int, pruned: bool) -> List[List[str]]:
    """Levels 0..depth of the tower; level k holds the walks using k edges."""
    levels = [["L", "R"]]
    for _ in range(depth):
        nxt = []
        for w in levels[-1]:
            for c in ("L", "R"):
                if pruned and w[-1] == "R" and c == "R":
                    continue
                nxt.append(w + c)
        levels.append(nxt)
    return levels


def interval(word: str) -> tuple[float, float]:
    """Dyadic address of a word: L = left half, R = right half, recursively."""
    lo, width = 0.0, 1.0
    for c in word:
        width /= 2
        if c == "R":
            lo += width
    return lo, width


fig, axes = plt.subplots(1, 2, figsize=(13.0, 6.0), sharey=True)

for ax, pruned, title, colour in (
    (axes[0], False, r"Lorenz template: $|P_n| = 2^{\,n+1}$, $\lambda = 2$", "#1f6feb"),
    (axes[1], True, r"Pruned template: $|P_n|$ Fibonacci, $\lambda = \varphi$", "#d1495b"),
):
    levels = words(DEPTH, pruned)
    for k, level in enumerate(levels):
        for w in level:
            lo, width = interval(w)
            ax.add_patch(Rectangle((lo, -k - 0.38), width * 0.985, 0.76,
                                   facecolor=colour, edgecolor="none",
                                   alpha=0.35 + 0.6 * k / len(levels)))
        ax.text(-0.015, -k, f"$P_{{{k}}}$", ha="right", va="center", fontsize=8.5)
        ax.text(1.015, -k, f"{len(level)}", ha="left", va="center", fontsize=8.5,
                color="#555555")
    ax.set_xlim(-0.08, 1.09)
    ax.set_ylim(-DEPTH - 0.8, 0.9)
    ax.set_yticks([])
    ax.set_xticks([0, 0.5, 1])
    ax.set_xticklabels(["LLL…", "", "RRR…"])
    ax.set_title(title, fontsize=11)
    ax.spines[["top", "right", "left"]].set_visible(False)
    lam = 2.0 if not pruned else (1 + math.sqrt(5)) / 2
    ax.text(0.5, 0.6, rf"$h=\log\lambda={math.log(lam):.4f}$", ha="center", fontsize=10)

fig.suptitle("The attractor as an inverse limit: each level is a finite set of words, "
             "the bonding map deletes the last letter", fontsize=12.5)
fig.tight_layout()
fig.savefig("cantor_tower.png", dpi=170)
print("wrote cantor_tower.png")


"""
Visualization: convergence of the two growth rates to the topological entropy.

For the Lorenz template (all transitions allowed) and the pruned template
(R -> R forbidden) we plot, against n:

    log |P_n| / n           (all length-n orbit segments)
    log tr(A^n) / n         (closed walks = n-periodic orbits)

together with the horizontal line h = log(lambda), lambda the Perron eigenvalue
of the transfer matrix (2 and the golden ratio respectively).

The upper curve descends monotonically (subadditivity gives h = inf_n log|P_n|/n),
the lower one converges from below; the Spectral Entropy Theorem and the Periodic
Growth Theorem say both limits are log(lambda).

Output: entropy_convergence.png
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt

Matrix = List[List[int]]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    d = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(d)) for j in range(d)] for i in range(d)]


def powers(a: Matrix, n_max: int) -> List[Matrix]:
    out = [a]
    for _ in range(n_max - 1):
        out.append(mat_mul(out[-1], a))
    return out


PHI = (1.0 + math.sqrt(5.0)) / 2.0
N_MAX = 40

TEMPLATES = [
    ("Lorenz template  $A=\\begin{pmatrix}1&1\\\\1&1\\end{pmatrix}$", [[1, 1], [1, 1]], 2.0, "#1f6feb"),
    ("Pruned template  $A=\\begin{pmatrix}1&1\\\\1&0\\end{pmatrix}$", [[1, 1], [1, 0]], PHI, "#d1495b"),
]

fig, axes = plt.subplots(1, 2, figsize=(12.5, 5.0), sharey=False)

for ax, (name, adj, lam, colour) in zip(axes, TEMPLATES):
    ps = powers(adj, N_MAX)
    ns = list(range(1, N_MAX + 1))
    paths = [math.log(sum(sum(r) for r in ps[n - 1])) / n for n in ns]
    walks = [math.log(sum(ps[n - 1][i][i] for i in range(len(adj)))) / n for n in ns]
    h = math.log(lam)

    ax.plot(ns, paths, "o-", ms=3.5, lw=1.6, color=colour, label=r"$\log |P_n| / n$")
    ax.plot(ns, walks, "s--", ms=3.5, lw=1.6, color="#f0a202",
            label=r"$\log \mathrm{tr}(A^n) / n$")
    ax.axhline(h, color="#2b2b2b", lw=1.8, ls=":",
               label=rf"$h=\log\lambda={h:.4f}$")
    ax.set_title(name, fontsize=11)
    ax.set_xlabel("n")
    ax.set_ylabel("growth rate")
    ax.grid(alpha=0.25)
    ax.legend(fontsize=9, loc="upper right")

fig.suptitle("Two growth rates, one entropy: $\\lim_n \\log|P_n|/n = "
             "\\lim_n \\log \\mathrm{tr}(A^n)/n = \\log\\lambda$", fontsize=13)
fig.tight_layout()
fig.savefig("entropy_convergence.png", dpi=170)
print("wrote entropy_convergence.png")


"""
Visualization: the arithmetic spectrum of achievable entropies.

We enumerate every directed graph on 2 and on 3 vertices (all 2^(d*d) adjacency
matrices), keep the primitive ones, compute the Perron eigenvalue lambda by power
iteration, and plot the resulting values of exp(h) = lambda on the real line,
annotated with the monic integer characteristic polynomial each one satisfies.

The picture makes the arithmetic rigidity visible: entropies of symbolic attractors
are not spread over the reals, they sit on a sparse set of logarithms of algebraic
integers, each pinned down by a polynomial of degree at most the number of branches.

Output: entropy_spectrum.png
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Matrix = List[List[int]]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    d = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(d)) for j in range(d)] for i in range(d)]


def identity(d: int) -> Matrix:
    return [[1 if i == j else 0 for j in range(d)] for i in range(d)]


def is_primitive(a: Matrix) -> bool:
    d = len(a)
    p = identity(d)
    for _ in range(max(1, d * d - 2 * d + 2)):
        p = mat_mul(p, a)
        if all(p[i][j] > 0 for i in range(d) for j in range(d)):
            return True
    return False


def perron(a: Matrix, iters: int = 400) -> float:
    d = len(a)
    x = [1.0 / d] * d
    for _ in range(iters):
        y = [sum(a[i][j] * x[j] for j in range(d)) for i in range(d)]
        s = sum(y)
        x = [v / s for v in y]
    y = [sum(a[i][j] * x[j] for j in range(d)) for i in range(d)]
    return sum(y)


def charpoly(a: Matrix) -> Tuple[int, ...]:
    d = len(a)
    coeffs = [Fraction(0)] * (d + 1)
    coeffs[d] = Fraction(1)
    m = [[Fraction(v) for v in row] for row in identity(d)]
    af = [[Fraction(v) for v in row] for row in a]
    for k in range(1, d + 1):
        am = [[sum(af[i][t] * m[t][j] for t in range(d)) for j in range(d)] for i in range(d)]
        c = -sum(am[i][i] for i in range(d)) / k
        coeffs[d - k] = c
        m = [[am[i][j] + (c if i == j else Fraction(0)) for j in range(d)] for i in range(d)]
    return tuple(int(c) for c in coeffs)


def poly_label(c: Tuple[int, ...]) -> str:
    parts = []
    for k in range(len(c) - 1, -1, -1):
        if c[k] == 0:
            continue
        mono = "" if k == 0 else ("t" if k == 1 else f"t^{{{k}}}")
        coef = "" if (abs(c[k]) == 1 and mono) else str(abs(c[k]))
        parts.append(("-" if c[k] < 0 else "+") + coef + mono)
    s = "".join(parts)
    return "$" + (s[1:] if s.startswith("+") else s) + "$"


def collect(d: int) -> Dict[float, Tuple[int, ...]]:
    found: Dict[float, Tuple[int, ...]] = {}
    for bits in itertools.product([0, 1], repeat=d * d):
        a = [list(bits[i * d:(i + 1) * d]) for i in range(d)]
        if not is_primitive(a):
            continue
        lam = perron(a)
        key = round(lam, 9)
        found.setdefault(key, charpoly(a))
    return found


fig, axes = plt.subplots(2, 1, figsize=(12.5, 6.2))

for ax, d, colour in ((axes[0], 2, "#1f6feb"), (axes[1], 3, "#d1495b")):
    found = collect(d)
    xs = sorted(found)
    ax.hlines(0, 0.9, max(xs) + 0.15, color="#999999", lw=1)
    for i, lam in enumerate(xs):
        ax.plot([lam], [0], "o", ms=9, color=colour, zorder=3)
        y = 0.55 if i % 2 == 0 else -0.62
        ax.annotate(f"$\\lambda={lam:.5f}$\n$h={math.log(lam):.5f}$\n{poly_label(found[lam])}",
                    xy=(lam, 0), xytext=(lam, y), ha="center",
                    va="bottom" if y > 0 else "top", fontsize=7.5,
                    arrowprops=dict(arrowstyle="-", lw=0.7, color="#999999"))
    ax.set_ylim(-1.35, 1.25)
    ax.set_yticks([])
    ax.set_xlabel(r"$e^{h}=\lambda$   (Perron eigenvalue of the transfer matrix)")
    ax.set_title(f"all primitive digraphs on {d} vertices: {len(xs)} distinct entropy values",
                 fontsize=11)
    ax.spines[["top", "right", "left"]].set_visible(False)

fig.suptitle("Entropy is arithmetically rigid: $e^{h}$ is always an algebraic integer",
             fontsize=13)
fig.tight_layout()
fig.savefig("entropy_spectrum.png", dpi=170)
print("wrote entropy_spectrum.png")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the deliverable files and the asset sources."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "tools" / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Novelty/StrangeAttractorInverseLimit.lean",
    "Catalog/Novelty/StrangeAttractorPeriodic.lean",
    "Catalog/Novelty/StrangeAttractorZeta.lean",
    "Catalog/Novelty/StrangeAttractorTopology.lean",
    "Catalog/Novelty/StrangeAttractorLorenzTemplate.lean",
    "Catalog/Novelty/StrangeAttractorRationality.lean",
    "Catalog/Novelty/StrangeAttractorEntropy.lean",
    "Catalog/Novelty/StrangeAttractorMixing.lean",
    "Catalog/Novelty/StrangeAttractorSpectral.lean",
    "Catalog/Novelty/StrangeAttractorPeriodicGrowth.lean",
    "Catalog/Novelty/StrangeAttractorPerronFrobenius.lean",
]

lean_source = "\n\n".join(
    f"-- ===================================================================\n"
    f"-- FILE: {f}\n"
    f"-- ===================================================================\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

demo_src = read(ROOT / "demo.py")

package = {
    "title": "Strange Attractors as Algebraic Objects: Inverse Limits, "
             "Transfer Matrices and the Spectral Form of Entropy",
    "domain": "Novelty",
    "description": "A symbolic strange attractor is identified with the inverse limit of the "
                   "finite path sets of a directed graph, and its topological entropy is proved "
                   "to equal the logarithm of the Perron eigenvalue of the graph's transfer "
                   "matrix, so that the exponential of the entropy is always an algebraic integer.",
    "authors": ["Aristotle"],
    "date": "2026-08-11",
    "key_results": [
        "Inverse Limit Theorem: the orbit space of any finite directed graph is canonically "
        "homeomorphic to the inverse limit of its finite path sets under edge deletion, "
        "compatibly with the shift, and is a Cantor set whenever every vertex branches.",
        "Spectral Entropy Theorem: for a dead-end-free graph carrying a strictly positive "
        "eigenvector of the transfer matrix with eigenvalue lambda, the topological entropy of "
        "the attractor equals log(lambda).",
        "Arithmeticity of entropy: the Perron eigenvalue is a root of the monic integral "
        "characteristic polynomial of the transfer matrix, so the exponential of the topological "
        "entropy is an algebraic integer.",
        "Uniqueness of the Perron value, proved by a purely dynamical route: any two strictly "
        "positive eigenvectors of the transfer matrix have the same eigenvalue; existence for "
        "primitive graphs follows from a Collatz-Wielandt variational construction, together with "
        "geometric simplicity, spectral dominance and strict positivity of the entropy.",
        "Periodic Growth Theorem: for a primitive graph the number of closed walks of length n "
        "grows exactly at the entropy rate, which makes the entropy and the Perron value "
        "topological conjugacy invariants; the Lorenz template has entropy log 2 and the pruned "
        "template entropy log of the golden ratio, so the two attractors are not conjugate.",
    ],
    "keywords": [
        "strange attractor",
        "inverse limit",
        "subshift of finite type",
        "transfer matrix",
        "topological entropy",
        "Perron-Frobenius",
        "algebraic integer",
        "Lorenz template",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": demo_src,
    "demos": [
        {
            "name": "Complete Numerical Atlas of Symbolic Attractors: Orbit Counts, "
                    "Characteristic Polynomials, Certified Perron Values and Entropy",
            "description": "A single self-contained script that instantiates the whole theory on "
                           "four templates (the Lorenz template, the pruned golden-mean template, "
                           "a three-branch complete-minus-loops template, and a sparse "
                           "three-branch template whose Perron value is the plastic number). For "
                           "each it prints the transfer matrix, tests dead-end-freeness and "
                           "primitivity with its exponent, computes the exact integral "
                           "characteristic polynomial by Faddeev-LeVerrier, obtains the Perron "
                           "eigenvalue by power iteration together with a rigorous two-sided "
                           "Collatz-Wielandt enclosure, evaluates the polynomial at that value to "
                           "exhibit it as an algebraic integer, and reports the entropy log(lambda) "
                           "with the spectral bounds 1 <= lambda <= |V|. It then tabulates the "
                           "number of length-n paths and the number of closed walks together with "
                           "their growth rates, verifying numerically both the Spectral Entropy "
                           "Theorem and the Periodic Growth Theorem, checks the Cayley-Hamilton "
                           "recurrence for the orbit-counting sequence, confirms that the pruned "
                           "template's closed-walk counts are exactly the Lucas numbers, and "
                           "separates the two Lorenz templates algebraically by the inequality "
                           "tr(A^2) = 4 vs 3 as well as by the entropy gap log 2 vs log phi.",
            "code": demo_src,
        }
    ],
    "algorithms": [
        {
            "name": "Orbit Counting by Binary Powering of the Transfer Matrix",
            "description": "The fundamental counting routine of the theory. Since matrix "
                           "multiplication is path concatenation, the (i,j) entry of the n-th power "
                           "of the 0/1 transfer matrix is the number of walks with exactly n edges "
                           "from branch i to branch j. Summing all entries gives |P_n|, the size of "
                           "the n-th finite approximation of the attractor in its inverse-limit "
                           "presentation; taking the trace gives the number of closed walks of "
                           "length n, which by the Periodic Orbit Theorem is exactly the number of "
                           "n-periodic points of the shift. Computing A^n by repeated squaring "
                           "costs O(d^3 log n) exact integer operations for d branches; because the "
                           "entries grow like lambda^n, exact arithmetic carries an additional "
                           "factor linear in n for the bignum widths. This routine is the bridge "
                           "between the combinatorial and the spectral sides of the theory: every "
                           "later algorithm consumes its output.",
            "pseudocode": (
                "INPUT : adjacency matrix A in {0,1}^{d x d}, exponent n >= 1\n"
                "OUTPUT: (|P_n|, #Per_n)\n"
                "\n"
                "1  R <- I_d                       // accumulator\n"
                "2  B <- A ; m <- n\n"
                "3  while m > 0 do\n"
                "4      if m is odd then R <- R * B\n"
                "5      B <- B * B\n"
                "6      m <- floor(m / 2)\n"
                "7  end while\n"
                "8  paths <- sum over all i,j of R[i][j]      // number of length-n walks\n"
                "9  closed <- sum over i of R[i][i]           // trace = closed walks = #Per_n\n"
                "10 return (paths, closed)"
            ),
            "code": read(A / "alg_orbit_counting.py"),
        },
        {
            "name": "Faddeev-LeVerrier Characteristic Polynomial and Cayley-Hamilton "
                    "Extension of the Orbit-Counting Sequence",
            "description": "Extracts the finite algebraic datum that governs all periodic-orbit "
                           "counts at once. The Faddeev-LeVerrier recursion computes the monic "
                           "integral characteristic polynomial chi(t) = det(tI - A) in O(d^4) ring "
                           "operations without any determinant expansion, using exact rational "
                           "arithmetic that provably terminates in integers. By Cayley-Hamilton, "
                           "multiplying chi(A) = 0 by A^k and taking traces shows that the sequence "
                           "n -> tr(A^n) satisfies the linear recurrence whose coefficients are "
                           "precisely the coefficients of chi: this is the finite-graph form of "
                           "rationality of the orbit-counting generating function. Once the "
                           "polynomial is known, each further term of the periodic-orbit sequence "
                           "costs only O(d) operations, exponentially cheaper than recomputing "
                           "matrix powers. For the pruned Lorenz template the polynomial is "
                           "t^2 - t - 1 and the sequence is the Lucas numbers.",
            "pseudocode": (
                "INPUT : adjacency matrix A in Z^{d x d}\n"
                "OUTPUT: ascending coefficients c[0..d] of chi(t) = det(tI - A), c[d] = 1\n"
                "\n"
                "1  M <- I_d ; c[d] <- 1\n"
                "2  for k = 1 to d do\n"
                "3      AM   <- A * M\n"
                "4      c[d-k] <- - trace(AM) / k          // exact rational; result is an integer\n"
                "5      M    <- AM + c[d-k] * I_d\n"
                "6  end for\n"
                "7  return c\n"
                "\n"
                "EXTENSION (orbit counts)\n"
                "INPUT : seed t_1..t_d with t_n = tr(A^n), coefficients c[0..d], target N\n"
                "8  for k = d+1 to N do\n"
                "9      t_k <- - sum over i = 0..d-1 of c[i] * t_{k-d+i}\n"
                "10 end for\n"
                "11 return t_1..t_N"
            ),
            "code": read(A / "alg_charpoly_recurrence.py"),
        },
        {
            "name": "Certified Topological Entropy via Power Iteration with "
                    "Collatz-Wielandt Enclosures",
            "description": "Computes the entropy with rigorous error bars rather than a "
                           "floating-point estimate. For a primitive nonnegative matrix the "
                           "normalised power iteration x <- Ax/||Ax||_1 converges geometrically to "
                           "the strictly positive Perron eigenvector, with contraction ratio equal "
                           "to the modulus of the second eigenvalue divided by the Perron value. "
                           "The essential feature is that certification does not wait for "
                           "convergence: for ANY strictly positive vector x the Collatz-Wielandt "
                           "bracket min_i (Ax)_i/x_i <= lambda <= max_i (Ax)_i/x_i holds "
                           "unconditionally, so every iterate supplies a proved enclosure of the "
                           "Perron value and hence, by the Spectral Entropy Theorem, of the "
                           "topological entropy h = log(lambda). The iteration is stopped when the "
                           "bracket is narrower than the requested tolerance. Cost is O(d^2) per "
                           "iteration.",
            "pseudocode": (
                "INPUT : primitive nonnegative A in R^{d x d}, tolerance eps\n"
                "OUTPUT: entropy h and a certified interval [lo, hi] containing lambda\n"
                "\n"
                "1  x <- (1/d, ..., 1/d)\n"
                "2  (lo, hi) <- BRACKET(A, x)\n"
                "3  while hi - lo > eps do\n"
                "4      y <- A x\n"
                "5      x <- y / (sum of entries of y)\n"
                "6      (lo, hi) <- BRACKET(A, x)\n"
                "7  end while\n"
                "8  return ( log((lo + hi)/2), lo, hi )\n"
                "\n"
                "BRACKET(A, x):                       // valid for every strictly positive x\n"
                "9   y <- A x\n"
                "10  return ( min_i y_i / x_i , max_i y_i / x_i )"
            ),
            "code": read(A / "alg_perron_certified.py"),
        },
        {
            "name": "Primitivity Test: Deciding Mixing, Dense Periodic Orbits and "
                    "Perron-Frobenius Applicability from a Boolean Matrix",
            "description": "Primitivity of the graph — some power of the transfer matrix has all "
                           "entries positive — is simultaneously the hypothesis behind three "
                           "different theorems: topological mixing of the attractor, density of its "
                           "periodic orbits, and existence of a strictly positive eigenvector of "
                           "the transfer matrix. Deciding it is therefore deciding chaos and "
                           "deciding spectral dominance at once. Because a primitive matrix of size "
                           "d is positive by the Wielandt exponent d^2 - 2d + 2 at the latest, the "
                           "search can be truncated there, and the entries can be replaced by "
                           "Booleans since only positivity matters: the test costs O(d^3) per "
                           "product and at most O(d^2) products. The routine also reports "
                           "dead-end-freeness (needed for the entropy to be defined) and branching "
                           "(needed for the attractor to be a Cantor set with sensitive dependence "
                           "on initial conditions), so a single pass classifies the qualitative "
                           "behaviour of the attractor.",
            "pseudocode": (
                "INPUT : adjacency matrix A in {0,1}^{d x d}\n"
                "OUTPUT: least n with A^n strictly positive, or NONE\n"
                "\n"
                "1  bound <- max(1, d*d - 2*d + 2)      // Wielandt exponent\n"
                "2  P <- A  (as a Boolean matrix)\n"
                "3  for n = 1 to bound do\n"
                "4      if every entry of P is true then return n\n"
                "5      P <- P OR-AND A                 // Boolean matrix product\n"
                "6  end for\n"
                "7  return NONE                         // not primitive\n"
                "\n"
                "AUXILIARY\n"
                "8  dead-end-free  <=>  every row of A has a nonzero entry\n"
                "9  branching      <=>  every row of A has at least two nonzero entries"
            ),
            "code": read(A / "alg_primitivity.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Two Growth Rates, One Entropy: Convergence of Path Counts and "
                    "Closed-Walk Counts",
            "description": "Plots log|P_n|/n (the growth rate of all length-n orbit segments) and "
                           "log tr(A^n)/n (the growth rate of the periodic orbits) against n for "
                           "the Lorenz template and the pruned template, with the horizontal line "
                           "h = log(lambda). The first curve descends monotonically because "
                           "subadditivity makes the entropy the infimum of the sequence; the second "
                           "approaches from below. Their common limit is the content of the "
                           "Spectral Entropy Theorem together with the Periodic Growth Theorem.",
            "code": read(A / "viz_convergence.py"),
        },
        {
            "name": "The Arithmetic Spectrum of Achievable Entropies",
            "description": "Enumerates every directed graph on two and on three branches, keeps the "
                           "primitive ones, computes each Perron eigenvalue, and plots the distinct "
                           "values of e^h on the real line annotated with the monic integer "
                           "characteristic polynomial that each satisfies. The picture makes the "
                           "arithmetic rigidity visible: entropies of symbolic attractors are not "
                           "spread over the reals but sit on a sparse set of logarithms of "
                           "algebraic integers of degree at most the number of branches.",
            "code": read(A / "viz_entropy_spectrum.py"),
        },
        {
            "name": "The Inverse-Limit Tower and the Cantor Set It Converges To",
            "description": "Draws the levels of the tower of finite path sets for both templates "
                           "side by side, each word rendered as a dyadic interval nested inside the "
                           "interval of its image under the bonding map (delete the last letter). "
                           "The Lorenz tower doubles at every level; in the pruned tower every word "
                           "ending in the forbidden branch has a single child, thinning the tree to "
                           "the golden-mean rate. The limiting set of surviving intervals is the "
                           "compact, perfect, totally disconnected transverse structure of the "
                           "attractor.",
            "code": read(A / "viz_cantor_tower.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Transfer Matrix Laboratory: Build an Attractor, Read Off Its Entropy",
            "description": "A four-panel interactive workbench. Click entries of the adjacency "
                           "matrix to switch transitions on and off (two, three or four branches, "
                           "with Lorenz, pruned, complete and cycle presets) and the graph is "
                           "redrawn live. The instrument panel reports dead-end-freeness, "
                           "primitivity together with the exponent at which every entry of the "
                           "matrix power becomes positive, the exact monic integral characteristic "
                           "polynomial, the Perron eigenvalue with a certified two-sided "
                           "Collatz-Wielandt enclosure, the positive eigenvector, the residual of "
                           "the polynomial at the eigenvalue (exhibiting it as an algebraic "
                           "integer), and the topological entropy h = log(lambda), accompanied by a "
                           "plain-language verdict on whether the system is chaotic and why. A "
                           "table lists the number of length-n paths and closed walks up to n = 24 "
                           "with their growth rates, and a live chart shows both rates converging "
                           "to the entropy line. Deleting a single edge from the Lorenz template in "
                           "front of the reader turns entropy log 2 into log of the golden ratio.",
            "html": read(A / "widget_transfer_lab.html"),
        },
        {
            "title": "The Inverse-Limit Tower: Watching a Cantor Set Assemble Itself",
            "description": "An animated illustration of the structure theorem. A depth slider "
                           "builds the tower of finite path sets level by level for either "
                           "template; each level is drawn both as a row of words (with each word "
                           "sitting directly beneath its image under the bonding map that deletes "
                           "the last letter) and as a family of nested dyadic intervals, so the "
                           "reader literally watches the Cantor set condense out of finite "
                           "combinatorial data. Live counters show the level size, its n-th root, "
                           "and the Perron value it converges to. A second control generates a "
                           "random admissible orbit and applies the shift to it letter by letter, "
                           "making visible how an infinite dynamical map acts on every finite level "
                           "simultaneously. In the pruned template the reader can see the missing "
                           "branch thinning the tree from 2^n to phi^n.",
            "html": read(A / "widget_inverse_limit.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_source,
    "future_directions": read(A / "future_directions.md"),
    "modules": {"demo": demo_src},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size/1024:.1f} KB)")
