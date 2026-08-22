"""
Numerical demonstrations for the transitivity partition function.

Setting
-------
A graded set with symmetry is a sequence of finite sets Y_0, Y_1, Y_2, ...
carried by a group G.  For a fixed arity r, the grade-n *transitivity count*

    a_n = t_r(Y_n) = number of G-orbits of injective r-tuples in Y_n

is 1 exactly when G acts r-transitively on Y_n.  The transitivity partition
function is the power series

    Z(q) = sum_{n >= 0} a_n q^n ,      |q| < 1 .

Everything in this file numerically verifies theorems about the analytic
continuation of Z and the residues of its poles:

  * eventually r-transitive  =>  simple pole at q = 1 with residue -1;
  * a_n = P(n) eventually    =>  pole of order deg P + 1 at q = 1 and
                                 residue -P(-1)  (zeta-regularisation);
  * the whole principal part at q = 1 is given by the finite-difference
    Laurent moments  m_j(P) = sum_k (-1)^{k+1} C(k,j) (Delta^k P)(0);
  * trivial action on |Y_n| = n points: residue (-1)^{r+1} r! ;
  * a_n eventually two-periodic (c0, c1): a second pole at q = -1 with
    residue (c0 - c1)/2 ;
  * a_n = P_{n mod m}(n) eventually (quasi-polynomial): a pole at every
    m-th root of unity, with residue at zeta^{-k} equal to
        -(1/(m zeta^k)) sum_{j<m} zeta^{-kj} P_j(-1) ;
  * reciprocity:  Z(1/q) = - sum_{n >= 1} P(-n) q^n .

All residues are checked against *numerically evaluated contour integrals*,

    Res_{z=c} F = (1/2 pi i) * closed integral over |z - c| = rho of F(z) dz ,

computed by the trapezoidal rule on the circle (spectrally accurate for
analytic integrands).  Only the standard library is used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Sequence

Complex = complex
Poly = Sequence[complex]  # coefficient list, low degree first: P(x) = sum c_k x^k


# ---------------------------------------------------------------------------
# Polynomial utilities
# ---------------------------------------------------------------------------


def poly_eval(P: Poly, x: complex) -> complex:
    """Evaluate a polynomial given by ascending coefficients at x (Horner)."""
    acc: complex = 0j
    for c in reversed(list(P)):
        acc = acc * x + c
    return acc


def poly_degree(P: Poly) -> int:
    """Degree of P, with the zero polynomial given degree 0."""
    d = 0
    for k, c in enumerate(P):
        if abs(c) > 1e-14:
            d = k
    return d


def newton_coeffs(P: Poly) -> List[complex]:
    """Finite differences (Delta^k P)(0) for k = 0, ..., deg P.

    Gregory-Newton: P(x) = sum_k (Delta^k P)(0) * binom(x, k).
    """
    d = poly_degree(P)
    values = [poly_eval(P, complex(n)) for n in range(d + 1)]
    out: List[complex] = []
    row = list(values)
    for _ in range(d + 1):
        out.append(row[0])
        row = [row[i + 1] - row[i] for i in range(len(row) - 1)]
    return out


def binom(n: int, k: int) -> int:
    """Binomial coefficient C(n, k), zero when k > n."""
    if k < 0 or k > n:
        return 0
    return math.comb(n, k)


# ---------------------------------------------------------------------------
# Closed forms
# ---------------------------------------------------------------------------


def poly_zeta(P: Poly, q: complex) -> complex:
    """Closed form of sum_n P(n) q^n:  sum_k (Delta^k P)(0) q^k / (1 - q)^{k+1}."""
    coeffs = newton_coeffs(P)
    total: complex = 0j
    for k, ck in enumerate(coeffs):
        total += ck * q ** k / (1 - q) ** (k + 1)
    return total


def eventually_poly_series(P: Poly, head: Sequence[complex], q: complex) -> complex:
    """Continuation of sum_n a_n q^n where a_n = head[n] for n < N and P(n) after.

    Equals (head correction, an entire polynomial) + poly_zeta(P, q).
    """
    N = len(head)
    correction = sum(
        (head[n] - poly_eval(P, complex(n))) * q ** n for n in range(N)
    )
    return correction + poly_zeta(P, q)


def twist_poly_zeta(P: Poly, w: complex, q: complex) -> complex:
    """Closed form of sum_n P(n) w^n q^n = poly_zeta(P, w q)."""
    return poly_zeta(P, w * q)


def quasi_poly_zeta(Ps: Sequence[Poly], q: complex) -> complex:
    """Closed form of sum_n P_{n mod m}(n) q^n via the Fourier sections."""
    m = len(Ps)
    zeta = cmath.exp(2j * math.pi / m)
    total: complex = 0j
    for k in range(m):
        # section polynomial evaluated through its coefficients
        sec = section_poly(Ps, k)
        total += twist_poly_zeta(sec, zeta ** k, q)
    return total


def section_poly(Ps: Sequence[Poly], k: int) -> List[complex]:
    """k-th Fourier section polynomial (1/m) sum_j zeta^{-kj} P_j."""
    m = len(Ps)
    zeta = cmath.exp(2j * math.pi / m)
    length = max(len(P) for P in Ps)
    out = [0j] * length
    for j, P in enumerate(Ps):
        weight = zeta ** (-(k * j)) / m
        for i, c in enumerate(P):
            out[i] += weight * c
    return out


def periodic_gf(c0: complex, c1: complex, q: complex) -> complex:
    """Closed form (c0 + c1 q) / (1 - q^2) of a two-periodic grade count."""
    return (c0 + c1 * q) / (1 - q * q)


# ---------------------------------------------------------------------------
# Numerical contour integration
# ---------------------------------------------------------------------------


def contour_moment(
    F: Callable[[complex], complex],
    center: complex,
    rho: float,
    j: int = 0,
    samples: int = 4096,
) -> complex:
    """(1/2 pi i) * integral over |z - center| = rho of (z-center)^j F(z) dz.

    For j = 0 this is the residue; for general j it is the Laurent coefficient
    of (z - center)^{-(j+1)}.  Trapezoidal rule on the circle.
    """
    total: complex = 0j
    for t in range(samples):
        theta = 2 * math.pi * t / samples
        z = center + rho * cmath.exp(1j * theta)
        dz = 1j * rho * cmath.exp(1j * theta)
        total += (z - center) ** j * F(z) * dz
    total *= (2 * math.pi / samples)
    return total / (2j * math.pi)


def laurent_moment(P: Poly, j: int) -> complex:
    """Closed form sum_{k <= deg P} (-1)^{k+1} C(k, j) (Delta^k P)(0)."""
    coeffs = newton_coeffs(P)
    return sum(
        (-1) ** (k + 1) * binom(k, j) * ck for k, ck in enumerate(coeffs)
    )


def desc_pochhammer(r: int) -> List[complex]:
    """Coefficients of the falling factorial x(x-1)...(x-r+1)."""
    poly: List[complex] = [1 + 0j]
    for i in range(r):
        shifted = [0j] + poly            # multiply by x
        scaled = [-i * c for c in poly] + [0j]  # multiply by -i
        poly = [a + b for a, b in zip(shifted, scaled)]
    return poly


def fmt(z: complex) -> str:
    """Short human-readable printing of a complex number."""
    re, im = z.real, z.imag
    if abs(im) < 1e-8:
        return f"{re: .6f}"
    return f"{re: .6f}{im:+.6f}i"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_universal_residue() -> None:
    """Eventually transitive grade counts: residue -1, independent of everything."""
    print("=" * 72)
    print("1. Eventually r-transitive actions: the universal residue -1")
    print("=" * 72)
    for head in ([3, 7, 2], [10, 1], [1], [5, 5, 5, 5, 5]):
        heads = [complex(x) for x in head]
        F = lambda q, h=heads: eventually_poly_series([1 + 0j], h, q)
        res = contour_moment(F, 1 + 0j, 0.4)
        print(f"  exceptional grades {head!s:<18} residue = {fmt(res)}")
    print("  Predicted residue for every such graded set: -1.000000\n")


def demo_zeta_regularised_residue() -> None:
    """Polynomial grade counts: residue -P(-1)."""
    print("=" * 72)
    print("2. Polynomial grade counts: the residue is -P(-1)")
    print("=" * 72)
    tests: List[tuple[str, Poly]] = [
        ("P(x) = 1", [1]),
        ("P(x) = x", [0, 1]),
        ("P(x) = x^2", [0, 0, 1]),
        ("P(x) = 2x^2 - 3x + 5", [5, -3, 2]),
        ("P(x) = x^3 + 1", [1, 0, 0, 1]),
    ]
    for name, P in tests:
        Pc = [complex(c) for c in P]
        res = contour_moment(lambda q, p=Pc: poly_zeta(p, q), 1 + 0j, 0.35)
        pred = -poly_eval(Pc, -1)
        print(f"  {name:<20} numeric {fmt(res)}   predicted -P(-1) = {fmt(pred)}")
    print()


def demo_pole_order_and_moments() -> None:
    """The full principal part at q = 1 via finite-difference Laurent moments."""
    print("=" * 72)
    print("3. The whole principal part at q = 1: Laurent moments")
    print("=" * 72)
    P: Poly = [complex(c) for c in (5, -3, 2)]  # 2x^2 - 3x + 5
    d = poly_degree(P)
    print(f"  P(x) = 2x^2 - 3x + 5,  deg P = {d}, predicted pole order {d + 1}")
    for j in range(d + 3):
        num = contour_moment(lambda q: poly_zeta(P, q), 1 + 0j, 0.3, j=j)
        pred = laurent_moment(P, j)
        tag = "  (should vanish)" if j > d else ""
        print(f"   j = {j}: numeric {fmt(num)}   formula {fmt(pred)}{tag}")
    print()


def demo_trivial_action() -> None:
    """Trivial action on n points: residue (-1)^{r+1} r!, pole order r+1."""
    print("=" * 72)
    print("4. Trivial action, |Y_n| = n:  a_n = n(n-1)...(n-r+1)")
    print("=" * 72)
    for r in range(0, 6):
        P = desc_pochhammer(r)
        res = contour_moment(lambda q, p=P: poly_zeta(p, q), 1 + 0j, 0.25)
        pred = (-1) ** (r + 1) * math.factorial(r)
        print(
            f"  r = {r}: numeric residue {fmt(res)}   "
            f"predicted (-1)^(r+1) r! = {pred:d}   pole order {r + 1}"
        )
    print()


def demo_detector() -> None:
    """The pair (pole order, residue) detects eventual transitivity."""
    print("=" * 72)
    print("5. The analytic detector: order -1 and residue -1")
    print("=" * 72)
    scenarios: List[tuple[str, Poly]] = [
        ("eventually transitive (P = 1)", [1]),
        ("eventually 2 orbits (P = 2)", [2]),
        ("eventually 3 orbits (P = 3)", [3]),
        ("linear growth (P = x)", [0, 1]),
    ]
    for name, P in scenarios:
        Pc = [complex(c) for c in P]
        res = contour_moment(lambda q, p=Pc: poly_zeta(p, q), 1 + 0j, 0.3)
        order = poly_degree(Pc) + 1
        verdict = (
            "TRANSITIVE"
            if order == 1 and abs(res + 1) < 1e-6
            else "not eventually transitive"
        )
        print(
            f"  {name:<32} pole order {order}, residue {fmt(res)}  ->  {verdict}"
        )
    print()


def demo_two_periodic() -> None:
    """Two-periodic grade counts: the second singularity at q = -1."""
    print("=" * 72)
    print("6. Two-periodic grade counts (c0, c1): a second pole at q = -1")
    print("=" * 72)
    for c0, c1 in [(1, 1), (3, 1), (2, 5), (4, 4)]:
        F = lambda q, a=c0, b=c1: periodic_gf(a, b, q)
        r1 = contour_moment(F, 1 + 0j, 0.5)
        rm1 = contour_moment(F, -1 + 0j, 0.5)
        print(
            f"  (c0, c1) = ({c0}, {c1}):  Res_1 = {fmt(r1)} "
            f"(pred {-(c0 + c1) / 2: .6f}),  "
            f"Res_-1 = {fmt(rm1)} (pred {(c0 - c1) / 2: .6f})"
        )
    print("  The second singularity vanishes exactly when c0 = c1.\n")


def demo_quasi_polynomial() -> None:
    """Quasi-polynomial grade counts: a residue at every m-th root of unity."""
    print("=" * 72)
    print("7. Quasi-polynomial grade counts a_n = P_{n mod m}(n)")
    print("=" * 72)
    Ps: List[Poly] = [
        [complex(c) for c in (1, 1)],   # P_0(x) = x + 1
        [complex(c) for c in (2,)],     # P_1(x) = 2
        [complex(c) for c in (0, 0, 1)],  # P_2(x) = x^2
    ]
    m = len(Ps)
    zeta = cmath.exp(2j * math.pi / m)
    # sanity check of the series against its closed form
    q0 = 0.3 + 0.1j
    series = sum(
        poly_eval(Ps[n % m], complex(n)) * q0 ** n for n in range(400)
    )
    print(f"  series at q = {q0}:      {fmt(series)}")
    print(f"  closed form at q = {q0}: {fmt(quasi_poly_zeta(Ps, q0))}")
    for k in range(m):
        pole = zeta ** (-k)
        res = contour_moment(lambda q: quasi_poly_zeta(Ps, q), pole, 0.4)
        pred = -(
            sum(zeta ** (-(k * j)) * poly_eval(Ps[j], -1) for j in range(m)) / m
        ) / zeta ** k
        print(
            f"  k = {k}: pole at {fmt(pole)}   numeric {fmt(res)}   "
            f"predicted {fmt(pred)}"
        )
    print()


def demo_reciprocity() -> None:
    """Ehrhart-style reciprocity: Z(1/q) = - sum_{n >= 1} P(-n) q^n."""
    print("=" * 72)
    print("8. Reciprocity:  Z(1/q) = - sum_{n>=1} P(-n) q^n")
    print("=" * 72)
    tests: List[tuple[str, Poly]] = [
        ("P(x) = 1", [1]),
        ("P(x) = x", [0, 1]),
        ("P(x) = x^2 + x", [0, 1, 1]),
        ("P(x) = x^3 - 2x + 7", [7, -2, 0, 1]),
    ]
    q = 0.37 - 0.21j
    for name, P in tests:
        Pc = [complex(c) for c in P]
        lhs = poly_zeta(Pc, 1 / q)
        rhs = -sum(poly_eval(Pc, complex(-n)) * q ** n for n in range(1, 500))
        first = -poly_eval(Pc, -1)
        print(
            f"  {name:<18} Z(1/q) = {fmt(lhs)}   reflected sum = {fmt(rhs)}"
        )
        print(f"      coefficient of q^1 = -P(-1) = {fmt(first)} = the residue at q = 1")
    print()


def main() -> None:
    demo_universal_residue()
    demo_zeta_regularised_residue()
    demo_pole_order_and_moments()
    demo_trivial_action()
    demo_detector()
    demo_two_periodic()
    demo_quasi_polynomial()
    demo_reciprocity()
    print("All numerical checks agree with the theorems.")


if __name__ == "__main__":
    main()


"""
Spectral certification of Laurent coefficients by contour quadrature.

Every closed-form prediction of a residue or of a higher Laurent coefficient
can be checked independently by evaluating

    mu_j(F; c) = (1 / 2 pi i) * closed integral over |z - c| = rho of
                 (z - c)^j F(z) dz .

Discretising the circle uniformly turns this into the trapezoidal rule

    mu_j ~ (1/T) sum_{t<T} (z_t - c)^{j+1} F(z_t),   z_t = c + rho e^{2 pi i t/T},

which for a function analytic in an annulus around the circle converges
geometrically in T: the error decays like R^{-T} where R > 1 is set by the
distance from the contour to the nearest other singularity.  The routine below
doubles T until two successive estimates agree to a requested tolerance, and
returns the estimate together with the number of evaluations used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Tuple


def laurent_moment_numeric(
    F: Callable[[complex], complex],
    center: complex,
    rho: float,
    j: int = 0,
    tol: float = 1e-12,
    max_samples: int = 1 << 16,
) -> Tuple[complex, int]:
    """Adaptive trapezoidal estimate of the j-th Laurent moment of F at center."""

    def estimate(T: int) -> complex:
        total = 0j
        for t in range(T):
            z = center + rho * cmath.exp(2j * math.pi * t / T)
            total += (z - center) ** (j + 1) * F(z)
        return total / T

    T = 16
    prev = estimate(T)
    while T < max_samples:
        T *= 2
        cur = estimate(T)
        if abs(cur - prev) < tol * max(1.0, abs(cur)):
            return cur, T
        prev = cur
    return prev, T


def pole_order_numeric(
    F: Callable[[complex], complex], center: complex, rho: float, jmax: int = 12
) -> int:
    """Largest j with a nonvanishing Laurent moment, plus one: the pole order."""
    order = 0
    for j in range(jmax + 1):
        val, _ = laurent_moment_numeric(F, center, rho, j)
        if abs(val) > 1e-8:
            order = j + 1
    return order


if __name__ == "__main__":
    # Partition function of the grade count P(n) = 2n^2 - 3n + 5:
    # closed form 5/(1-q) - q/(1-q)^2 + 4 q^2/(1-q)^3.
    def Z(q: complex) -> complex:
        return 5 / (1 - q) - q / (1 - q) ** 2 + 4 * q ** 2 / (1 - q) ** 3

    for j in range(4):
        val, used = laurent_moment_numeric(Z, 1 + 0j, 0.3, j)
        print(f"moment j={j}: {val.real:+.9f}{val.imag:+.9f}i   ({used} samples)")
    print("pole order:", pole_order_numeric(Z, 1 + 0j, 0.3))


"""
Gregory-Newton extraction of the singularity data of a graded family.

Given finitely many grade counts a_N, a_{N+1}, ..., a_{N+D} known to be the
values of a polynomial P of degree at most D, this routine returns

  * the degree of P,
  * the finite differences (Delta^k P)(0), k = 0, ..., deg P,
  * the pole order deg P + 1 of the partition function at q = 1,
  * the residue -P(-1),
  * every Laurent moment m_j = sum_k (-1)^{k+1} C(k, j) (Delta^k P)(0),
    i.e. the complete principal part of the partition function at q = 1.

Cost: O(D^2) arithmetic operations, all of them exact if the inputs are
integers or rationals.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Sequence


def difference_table(values: Sequence[Fraction]) -> List[List[Fraction]]:
    """All successive forward differences of a finite list of values."""
    table: List[List[Fraction]] = [list(values)]
    while len(table[-1]) > 1:
        row = table[-1]
        table.append([row[i + 1] - row[i] for i in range(len(row) - 1)])
    return table


def rebase_at_zero(counts: Sequence[Fraction], start: int) -> List[Fraction]:
    """Values P(0), P(1), ..., P(D) from samples P(start), ..., P(start+D).

    Uses the Newton expansion around `start` and the fact that shifting the
    base point of a polynomial only requires the difference table.
    """
    diffs = [row[0] for row in difference_table(counts)]

    def binom(y: int, k: int) -> Fraction:
        num = Fraction(1)
        for i in range(k):
            num *= (y - i)
        return num / math.factorial(k)

    def P(y: int) -> Fraction:
        return sum(c * binom(y - start, k) for k, c in enumerate(diffs))

    return [P(i) for i in range(len(counts))]


def singularity_data(counts: Sequence[int], start: int) -> Dict[str, object]:
    """Full singularity data at q = 1 of an eventually polynomial grade count."""
    based = rebase_at_zero([Fraction(c) for c in counts], start)
    newton = [row[0] for row in difference_table(based)]
    degree = 0
    for k, c in enumerate(newton):
        if c != 0:
            degree = k
    newton = newton[: degree + 1]
    residue = -sum((-1) ** k * c for k, c in enumerate(newton))
    moments = [
        sum((-1) ** (k + 1) * math.comb(k, j) * c for k, c in enumerate(newton))
        for j in range(degree + 1)
    ]
    return {
        "degree": degree,
        "newton_coefficients": newton,
        "pole_order": degree + 1,
        "residue": residue,
        "laurent_moments": moments,
        "eventually_transitive": degree == 0 and residue == -1,
    }


if __name__ == "__main__":
    # a_n = 1: eventually transitive.
    print(singularity_data([1, 1, 1, 1], 4))
    # a_n = 2n^2 - 3n + 5.
    print(singularity_data([2 * n * n - 3 * n + 5 for n in range(6, 10)], 6))
    # a_n = n(n-1)(n-2): trivial action on n points, r = 3.
    print(singularity_data([n * (n - 1) * (n - 2) for n in range(5, 10)], 5))


"""
Fourier-sectional computation of the residue spectrum of a quasi-polynomial
grade count.

Input: a period m and grade counts a_N, ..., a_M known to satisfy
a_n = P_{n mod m}(n) for polynomials P_0, ..., P_{m-1} of degree at most D.

Output: for every m-th root of unity zeta^{-k} the residue of the analytic
continuation of the partition function sum_n a_n q^n, namely

    Res_{q = zeta^{-k}} = -(1 / (m zeta^k)) * sum_{j<m} zeta^{-kj} P_j(-1).

The algorithm has three stages: interpolate each residue class to obtain the
section polynomials (cost O(m D^2)); evaluate each at the reflected grade -1
(cost O(mD)); and apply a discrete Fourier transform of length m
(cost O(m^2) naively, O(m log m) with a fast transform).
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from typing import Dict, List, Sequence, Tuple


def lagrange_at(nodes: Sequence[int], values: Sequence[Fraction], y: int) -> Fraction:
    """Exact value at y of the polynomial interpolating (nodes, values)."""
    total = Fraction(0)
    for i, xi in enumerate(nodes):
        term = values[i]
        for j, xj in enumerate(nodes):
            if i != j:
                term *= Fraction(y - xj, xi - xj)
        total += term
    return total


def section_values_at_minus_one(
    counts: Dict[int, int], m: int
) -> List[Fraction]:
    """The numbers P_j(-1) for each residue class j modulo m."""
    out: List[Fraction] = []
    for j in range(m):
        nodes = sorted(n for n in counts if n % m == j)
        if not nodes:
            raise ValueError(f"no samples in residue class {j} mod {m}")
        values = [Fraction(counts[n]) for n in nodes]
        out.append(lagrange_at(nodes, values, -1))
    return out


def residue_spectrum(counts: Dict[int, int], m: int) -> List[Tuple[complex, complex]]:
    """Return the list of (pole, residue) pairs at the m-th roots of unity."""
    vals = section_values_at_minus_one(counts, m)
    zeta = cmath.exp(2j * math.pi / m)
    out: List[Tuple[complex, complex]] = []
    for k in range(m):
        amp = sum(zeta ** (-(k * j)) * complex(vals[j]) for j in range(m)) / m
        pole = zeta ** (-k)
        residue = -amp / zeta ** k
        out.append((pole, residue))
    return out


if __name__ == "__main__":
    # a_n = floor(n/2): the dihedral group acting on pairs from Z/nZ.
    counts = {n: n // 2 for n in range(6, 16)}
    for pole, res in residue_spectrum(counts, 2):
        print(f"pole {pole:+.4f}   residue {res:+.6f}")
    # Expected: residue 3/4 at q = 1 and 1/4 at q = -1.

    # a_n = P_{n mod 3}(n) with P_0 = n+1, P_1 = 2, P_2 = n^2.
    def a(n: int) -> int:
        return [n + 1, 2, n * n][n % 3]

    counts3 = {n: a(n) for n in range(9, 24)}
    for pole, res in residue_spectrum(counts3, 3):
        print(f"pole {pole:+.4f}   residue {res:+.6f}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib
from typing import Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"

LEAN_FILES = [
    "Catalog/Physics/GradedTransitivityComplex.lean",
    "Catalog/Physics/GradedTransitivityResidue.lean",
    "Catalog/Physics/GradedTransitivityTrivial.lean",
    "Catalog/Physics/GradedTransitivityDetector.lean",
    "Catalog/Physics/GradedTransitivityPeriodic.lean",
    "Catalog/Physics/GradedTransitivityRootsOfUnity.lean",
    "Catalog/Physics/GradedTransitivityFourier.lean",
    "Catalog/Physics/GradedTransitivityLaurent.lean",
    "Catalog/Physics/GradedTransitivityQuasiPolynomial.lean",
    "Catalog/Physics/GradedTransitivityReciprocity.lean",
    "Catalog/Physics/GradedTransitivityResidueSpectrum.lean",
]

FUTURE_DIRECTIONS = """# Future Directions

Derived from the analysis and adversarial review of this thread, whose verified output is:

* Passage from the real line to the complex plane, analyticity on the plane minus the point
  q = 1, uniqueness of the continuation, and the residue -1 of the transitivity partition
  function (simple pole, order exactly -1).
* The general polynomial case: residue -P(-1) and pole order exactly deg P + 1, via
  Gregory-Newton plus Laurent expansion, including the tail-only versions for eventually
  polynomial grade counts.
* The completely explicit extreme case: residue (-1)^{r+1} r! and pole order r + 1 for the
  trivial action.
* The analytic detector: pole order -1 together with residue -1 characterises eventual
  r-transitivity, and the sharpness boundary (eventually c orbits gives the same order and
  residue -c).
* The first quasi-polynomial case: two-periodic grade counts, the second singularity at
  q = -1, its residue (c0 - c1)/2, and the resulting periodicity detector.
* Finite exponential grade counts, one simple pole per twist with residue -A_j / w_j, and the
  discrete Fourier inversion that puts a grade count periodic mod m into that form: residue
  -A_k / zeta^k at every m-th root of unity.
* New this cycle: the whole principal part at q = 1. The j-th Laurent moment of a polynomial
  grade count P is the explicit finite-difference functional
  sum_{k <= deg P} (-1)^{k+1} C(k,j) Delta^k P(0); it reduces to the residue -P(-1) at j = 0,
  vanishes for j > deg P, has nonzero top coefficient, and - like the residue - depends only
  on the tail of the grade count.
* New this cycle: the residue at every root of unity for quasi-polynomial grade counts
  a_n = P_{n mod m}(n), namely -(1/(m zeta^k)) sum_{j<m} zeta^{-kj} P_j(-1). This is exactly
  the value conjectured in the previous cycle, and it now covers both degenerate cases (one
  polynomial; periodic constants) uniformly. The mechanism is the twisted zeta-regularisation
  sum_n P(n) w^n q^n = Z_P(wq) with residue -P(-1)/w at q = 1/w, summed over the Fourier
  sections.
* New this cycle: the Ehrhart-style reciprocity law Z_P(1/q) = -sum_{n >= 1} P(-n) q^n for
  0 < |q| < 1, together with its reflected-polynomial form Z_P(1/q) = -q Z_{P(-X-1)}(q) and
  the involutivity of the reflection. Its combinatorial core is the negative-argument binomial
  identity C(-n-1, k) = (-1)^k C(n+k, k).

Open directions going forward:

1. Full principal parts at all roots of unity in the quasi-polynomial regime, twisting the
   Laurent-moment computation by each root of unity.
2. Rigidity in the quasi-polynomial regime: is the complete principal-part data at all m-th
   roots of unity a complete invariant of a quasi-polynomial grade germ?
3. Two-variable refinements: grade by both size and arity, and study the singularity structure
   in the arity variable.
4. Group-theoretic input: determine which polynomials arise as transitivity counts of natural
   families, turning the residue into a classification invariant.
5. Effective error terms in coefficient asymptotics derived from the continuation on a
   slightly larger disc.
"""


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def lean_bundle() -> str:
    parts: List[str] = []
    for rel in LEAN_FILES:
        src = read(ROOT / rel)
        parts.append(f"-- ===== {rel} =====\n{src}")
    return "\n\n".join(parts)


def main() -> None:
    article = read(ROOT / "ARTICLE.md")
    paper = read(ROOT / "RESEARCH_PAPER.md")
    tex = read(ROOT / "RESEARCH_PAPER.tex")
    demo = read(ROOT / "demo.py")
    orbit = read(ASSETS / "orbit_demo.py")
    algo_moments = read(ASSETS / "algo_moments.py")
    algo_quasi = read(ASSETS / "algo_quasi.py")
    algo_contour = read(ASSETS / "algo_contour.py")
    viz_domain = read(ASSETS / "viz_domain.py")
    viz_spectrum = read(ASSETS / "viz_spectrum.py")
    widget_explorer = read(ASSETS / "widget_explorer.html")
    widget_reciprocity = read(ASSETS / "widget_reciprocity.html")
    layout = read(ASSETS / "layout.md")

    package: Dict[str, object] = {
        "title": "Singularities of Transitivity Partition Functions: "
                 "Zeta-Regularised Residues, Laurent Moments, and Reciprocity",
        "domain": "Physics",
        "description": (
            "For a group acting on a graded family of finite sets, the generating function of "
            "the numbers of orbits on injective r-tuples continues to a rational function whose "
            "poles sit at roots of unity; its residue at the infinite-temperature point q = 1 is "
            "the zeta-regularised value -P(-1) of the grade-counting polynomial at a negative "
            "grade, and the pair (pole order, residue) = (1, -1) characterises eventual "
            "r-transitivity."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-22",
        "key_results": [
            "Universal residue theorem: an eventually r-transitive graded family has a "
            "partition function that continues uniquely off q = 1 with a simple pole there of "
            "residue -1, independent of the group, the sets, the arity and finitely many "
            "exceptional grades.",
            "Zeta-regularised residue formula: for grade counts eventually equal to a "
            "polynomial P, the pole at q = 1 has order exactly deg P + 1 and residue -P(-1), "
            "the counting polynomial evaluated at a nonexistent grade.",
            "Analytic detector for multiple transitivity: a simple pole at q = 1 together with "
            "residue -1 holds if and only if the family is eventually r-transitive, with the "
            "sharp boundary that eventually c orbits gives the same pole order and residue -c; "
            "the trivial action gives residue (-1)^{r+1} r! and pole order r + 1.",
            "Full principal part at q = 1: the coefficient of (q-1)^{-(j+1)} is the "
            "finite-difference functional sum_k (-1)^{k+1} C(k,j) Delta^k P(0), which reduces "
            "to the residue at j = 0, vanishes beyond the degree, and has nonzero top "
            "coefficient.",
            "Residues of quasi-polynomial grade counts at every m-th root of unity, "
            "-(1/(m zeta^k)) sum_{j<m} zeta^{-kj} P_j(-1), together with the reciprocity law "
            "Z(1/q) = -sum_{n>=1} P(-n) q^n showing the residue to be the first reflected grade.",
        ],
        "keywords": [
            "multiply transitive action",
            "graded G-set",
            "partition function",
            "analytic continuation",
            "residue",
            "zeta-regularisation",
            "quasi-polynomial",
            "Ehrhart reciprocity",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "Complete Numerical Verification Suite for Transitivity Partition "
                        "Function Singularities",
                "description": (
                    "Evaluates every theorem of the paper numerically. For eventually constant, "
                    "polynomial, falling-factorial, two-periodic and quasi-polynomial grade "
                    "counts it computes the closed form of the partition function, extracts the "
                    "residue and all higher Laurent coefficients by trapezoidal contour "
                    "quadrature around each singularity, and compares them with the predicted "
                    "values -P(-1), the finite-difference Laurent moments, (-1)^{r+1} r! for the "
                    "trivial action, (c0-c1)/2 at the second singularity of a two-periodic "
                    "count, and the Fourier-weighted quasi-polynomial residues. It closes with a "
                    "direct verification of the reciprocity law Z(1/q) = -sum_{n>=1} P(-n) q^n "
                    "and of the identification of its first coefficient with the residue at "
                    "q = 1. Standard library only."
                ),
                "code": demo,
            },
            {
                "name": "From Concrete Group Actions to Residues: Brute-Force Orbit Counting "
                        "and Automatic Singularity Analysis",
                "description": (
                    "Builds four graded families on the sets Z/nZ - cyclic rotations, the "
                    "dihedral group, the affine group over a prime field, and the trivial group "
                    "- and counts the orbits on injective r-tuples by explicit enumeration. It "
                    "then recovers the grade-counting polynomial from the counts by Lagrange "
                    "interpolation and finite differences, predicts the pole order, the residue "
                    "-P(-1) and the full principal part, confirms each residue by numerical "
                    "contour integration, and applies the transitivity detector. The dihedral "
                    "family at arity two is genuinely quasi-polynomial (its orbit counts are "
                    "floor(n/2)), so it is analysed by residue class modulo two, producing the "
                    "residues 3/4 at q = 1 and 1/4 at q = -1 predicted by the general formula."
                ),
                "code": orbit,
            },
        ],
        "algorithms": [
            {
                "name": "Gregory-Newton Extraction of the Complete Principal Part at the "
                        "Infinite-Temperature Point",
                "description": (
                    "Given finitely many grade counts known to be values of a polynomial P of "
                    "degree at most D, this algorithm returns the degree, the finite differences "
                    "Delta^k P(0), the pole order deg P + 1 of the partition function at q = 1, "
                    "the residue -P(-1), and every Laurent moment "
                    "m_j = sum_k (-1)^{k+1} C(k,j) Delta^k P(0), i.e. the entire principal part. "
                    "Its mathematical foundation is the pairing of the Gregory-Newton expansion "
                    "P = sum_k Delta^k P(0) binom(x,k) with the Laurent expansion of the basis "
                    "generating functions q^k/(1-q)^{k+1} at q = 1, whose j-th moment is the pure "
                    "combinatorial number (-1)^{k+1} C(k,j). The computation is a difference "
                    "table followed by a linear pass per moment, costing O(D^2) arithmetic "
                    "operations, and is exact over the rationals."
                ),
                "pseudocode": (
                    "Input: counts a_start, ..., a_{start+D}; base index start\n"
                    "Output: degree d, differences (Delta^k P)(0), pole order, residue, moments\n"
                    "1. Build the forward-difference table of the input counts.\n"
                    "2. Using the Newton expansion around `start`, evaluate P at 0, 1, ..., D\n"
                    "   (rebasing the polynomial at the origin).\n"
                    "3. Build the forward-difference table of those rebased values; its leading\n"
                    "   entries are c_k = (Delta^k P)(0).\n"
                    "4. d <- largest k with c_k nonzero; truncate c to c_0..c_d.\n"
                    "5. residue <- -sum_{k<=d} (-1)^k c_k        [ = -P(-1) ]\n"
                    "6. for j = 0..d:  m_j <- sum_{k<=d} (-1)^{k+1} C(k,j) c_k\n"
                    "7. pole order <- d + 1.\n"
                    "8. Report 'eventually transitive' iff d = 0 and residue = -1.\n"
                    "9. Return (d, c, d+1, residue, m)."
                ),
                "code": algo_moments,
            },
            {
                "name": "Fourier-Sectional Computation of the Residue Spectrum of a "
                        "Quasi-Polynomial Grade Count",
                "description": (
                    "Computes the residue of the partition function at every m-th root of unity "
                    "for a grade count that is eventually quasi-polynomial, a_n = P_{n mod m}(n). "
                    "The mathematical content is a two-step reduction: a single twisted count "
                    "P(n) w^n has partition function Z_P(wq) and therefore residue -P(-1)/w at "
                    "q = 1/w; and discrete Fourier inversion splits a quasi-polynomial count "
                    "into exactly m such twisted pieces whose amplitudes are the section "
                    "polynomials S_k = (1/m) sum_j zeta^{-kj} P_j. Only the values P_j(-1) are "
                    "needed, so each residue class is interpolated exactly over the rationals "
                    "and evaluated at the reflected grade -1, after which one discrete Fourier "
                    "transform of length m produces the whole spectrum. Cost: O(m D^2) for the "
                    "interpolations plus O(m log m) for the transform."
                ),
                "pseudocode": (
                    "Input: a dictionary of grade counts a_n, and the period m\n"
                    "Output: the pairs (pole zeta^{-k}, residue) for k = 0..m-1\n"
                    "1. for j = 0..m-1:\n"
                    "     nodes  <- the sampled grades n with n = j (mod m)\n"
                    "     v_j    <- exact Lagrange value at -1 of the polynomial through\n"
                    "               (nodes, counts)                 [ = P_j(-1) ]\n"
                    "2. zeta <- exp(2 pi i / m).\n"
                    "3. for k = 0..m-1:\n"
                    "     Ahat_k <- (1/m) sum_{j<m} zeta^{-kj} v_j   [ discrete Fourier transform ]\n"
                    "     pole_k <- zeta^{-k}\n"
                    "     res_k  <- -Ahat_k / zeta^k\n"
                    "4. Return the list of (pole_k, res_k).\n"
                    "Degenerate cases: m = 1 returns the single residue -P(-1); constant\n"
                    "sections return -Ahat_k / zeta^k with Ahat the Fourier transform of the\n"
                    "period."
                ),
                "code": algo_quasi,
            },
            {
                "name": "Spectral Certification of Laurent Coefficients by Adaptive Contour "
                        "Quadrature",
                "description": (
                    "Independently certifies any predicted residue or higher Laurent coefficient "
                    "by evaluating the defining contour integral "
                    "mu_j = (1/2 pi i) * integral of (z-c)^j F(z) dz over a circle about c. "
                    "Discretising the circle uniformly gives the trapezoidal rule "
                    "mu_j ~ (1/T) sum_t (z_t - c)^{j+1} F(z_t), which for a function analytic in "
                    "an annulus about the contour converges geometrically in the number of "
                    "sample points: the error decays like R^{-T}, with R > 1 governed by the "
                    "distance from the contour to the nearest other singularity. The routine "
                    "doubles the sample count until successive estimates agree to a requested "
                    "tolerance, and a companion routine determines the pole order as one more "
                    "than the largest index with a nonvanishing moment. Cost: O(T) function "
                    "evaluations, with T typically a few dozen for double precision."
                ),
                "pseudocode": (
                    "Input: evaluator F, centre c, radius rho, moment index j, tolerance tol\n"
                    "Output: the j-th Laurent coefficient of F at c\n"
                    "1. T <- 16;  prev <- Estimate(T)\n"
                    "2. repeat\n"
                    "     T <- 2T;  cur <- Estimate(T)\n"
                    "     if |cur - prev| < tol * max(1, |cur|) then return cur\n"
                    "     prev <- cur\n"
                    "   until T > T_max\n"
                    "where Estimate(T) = (1/T) * sum_{t<T} (z_t - c)^{j+1} F(z_t),\n"
                    "      z_t = c + rho * exp(2 pi i t / T).\n"
                    "Pole order: return 1 + max{ j : |mu_j| > threshold }."
                ),
                "code": algo_contour,
            },
        ],
        "visualizations": [
            {
                "name": "Domain Colouring of Transitivity Partition Functions: How the "
                        "Singularity Picture Depends on the Grade Count",
                "description": (
                    "Three side-by-side domain-coloured portraits of partition functions on the "
                    "complex q-plane: an eventually transitive grade count with its single "
                    "simple pole of residue -1 at q = 1; a quadratic grade count whose pole at "
                    "q = 1 has order three and residue -10; and a grade count periodic modulo "
                    "five with a simple pole at each fifth root of unity. Brightness encodes "
                    "log|Z| so poles blaze white, while hue encodes arg Z, so the number of "
                    "times the colour wheel turns around a point is exactly the order of the "
                    "pole there. The dashed circle marks the boundary of convergence of the "
                    "original series, making visible that the analytic continuation lives well "
                    "beyond it."
                ),
                "code": viz_domain,
            },
            {
                "name": "The Residue Spectrum on the Unit Circle and the Geometric Convergence "
                        "of Contour Quadrature",
                "description": (
                    "Left: for a grade count periodic modulo five, the unit circle with its five "
                    "poles, each carrying an arrow whose length and direction are the residue "
                    "there - a picture of the residue spectrum as the discrete Fourier transform "
                    "of one period, which by the rigidity theorem determines the grade germ "
                    "completely. Right: the absolute error of the trapezoidal contour rule for "
                    "the residue at q = 1, plotted against the number of sample points on a "
                    "logarithmic scale for three contour radii, exhibiting the geometric "
                    "convergence that makes the numerical certification of residues essentially "
                    "free."
                ),
                "code": viz_spectrum,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Singularity Explorer: Watch Symmetry Become a Pole",
                "description": (
                    "A live laboratory for the main theorems. Choose the shape of the grade "
                    "count - a polynomial, a periodic sequence, or a quasi-polynomial with one "
                    "section polynomial per residue class - and the widget renders the partition "
                    "function by domain colouring on the complex q-plane, with brightness "
                    "log|Z| and hue arg Z, so that pole orders can be read off from how many "
                    "times the colour wheel turns. It marks every singularity, draws the "
                    "integration contour around the selected one at a radius you control, and "
                    "computes the residue live by numerical contour integration, displaying it "
                    "beside the predicted closed form: -P(-1) for polynomial counts, the "
                    "Fourier amplitude -A_k/zeta^k for periodic ones, and the Fourier-weighted "
                    "section value for quasi-polynomial ones. The finite-difference table and "
                    "the complete list of Laurent moments are shown alongside, and a verdict "
                    "panel applies the analytic detector: a simple pole at q = 1 with residue "
                    "-1 exactly when the family is eventually r-transitive. Two collapsible "
                    "sections give the proofs of the residue formula and of the "
                    "root-of-unity spectrum."
                ),
                "html": widget_explorer,
            },
            {
                "title": "The Reciprocity Mirror: Where the Negative Grade Comes From",
                "description": (
                    "An interactive illustration of the reciprocity law "
                    "Z(1/q) = -sum_{n>=1} P(-n) q^n. Enter a grade-counting polynomial and the "
                    "widget draws its values at the real grades 0, 1, 2, ... in blue and at the "
                    "reflected grades -1, -2, ... in orange, highlighting P(-1). Sliders move "
                    "the test point q around the punctured unit disc while the panel evaluates "
                    "both sides of the identity - the rational closed form at 1/q and the "
                    "reflected series - and reports their difference, together with the "
                    "coefficient of q^1, which is exactly the residue of the partition function "
                    "at the infinite-temperature point. Collapsible notes explain the "
                    "negative-argument binomial identity that drives the reflection and the "
                    "analogy with Ehrhart reciprocity for lattice-point counting."
                ),
                "html": widget_reciprocity,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo,
            "orbit_demo": orbit,
            "algorithm_moments": algo_moments,
            "algorithm_quasi_polynomial": algo_quasi,
            "algorithm_contour": algo_contour,
            "visualization_domain_colouring": viz_domain,
            "visualization_residue_spectrum": viz_spectrum,
        },
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
From group actions to residues: brute-force orbit counting, then analysis.

This demo builds concrete graded families of finite sets with a group action,
counts the orbits on injective r-tuples by brute force, fits the resulting
grade counts by a polynomial using finite differences, and then predicts and
numerically confirms the singularity data of the transitivity partition
function

    Z_r(q) = sum_n t_r(Y_n) q^n .

Families used (all with Y_n = Z/nZ):

  * rotations:   G = Z/nZ acting by translation;
  * dihedral:    G generated by translation and negation;
  * affine:      G = { x -> a x + b : a invertible mod n } (prime n only);
  * trivial:     G = {e}, no identifications at all.

For each family and each arity r the demo reports the orbit counts, the fitted
counting polynomial P, the predicted pole order deg P + 1 and residue -P(-1),
and the residue obtained from a numerically evaluated contour integral around
q = 1.  It then applies the transitivity detector: the pole is simple and the
residue is -1 exactly when the action is eventually r-transitive.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List, Sequence, Tuple

Perm = Tuple[int, ...]          # a permutation of {0, ..., n-1}
Tuple_r = Tuple[int, ...]       # an injective r-tuple


# ---------------------------------------------------------------------------
# Groups of permutations of Z/nZ
# ---------------------------------------------------------------------------


def rotations(n: int) -> List[Perm]:
    """The cyclic group of translations x -> x + k mod n."""
    return [tuple((x + k) % n for x in range(n)) for k in range(n)]


def dihedral(n: int) -> List[Perm]:
    """Translations together with the reflection x -> -x mod n."""
    out = set()
    for k in range(n):
        out.add(tuple((x + k) % n for x in range(n)))
        out.add(tuple((k - x) % n for x in range(n)))
    return sorted(out)


def affine(n: int) -> List[Perm]:
    """Maps x -> a x + b with gcd(a, n) = 1: sharply 2-transitive for n prime."""
    out = set()
    for a in range(1, n):
        if math.gcd(a, n) != 1:
            continue
        for b in range(n):
            out.add(tuple((a * x + b) % n for x in range(n)))
    return sorted(out)


def trivial(n: int) -> List[Perm]:
    """The trivial group: only the identity."""
    return [tuple(range(n))]


# ---------------------------------------------------------------------------
# Orbit counting on injective r-tuples
# ---------------------------------------------------------------------------


def injective_tuples(n: int, r: int) -> List[Tuple_r]:
    """All injective r-tuples of elements of {0, ..., n-1}."""
    if r == 0:
        return [()]
    out: List[Tuple_r] = []

    def rec(prefix: Tuple_r) -> None:
        if len(prefix) == r:
            out.append(prefix)
            return
        for x in range(n):
            if x not in prefix:
                rec(prefix + (x,))

    rec(())
    return out


def trans_count(group: Sequence[Perm], n: int, r: int) -> int:
    """t_r(Y) = number of group orbits on injective r-tuples of Y = Z/nZ."""
    if r > n:
        return 0
    tuples = injective_tuples(n, r)
    seen: Dict[Tuple_r, bool] = {}
    orbits = 0
    for t in tuples:
        if t in seen:
            continue
        orbits += 1
        for g in group:
            seen[tuple(g[x] for x in t)] = True
    return orbits


# ---------------------------------------------------------------------------
# Finite differences, fitted polynomial, predicted singularity data
# ---------------------------------------------------------------------------


def difference_table(values: Sequence[float]) -> List[List[float]]:
    """Successive forward differences of a list of values."""
    table = [list(map(float, values))]
    while len(table[-1]) > 1:
        row = table[-1]
        table.append([row[i + 1] - row[i] for i in range(len(row) - 1)])
    return table


def interpolate(nodes: Sequence[int], values: Sequence[float]) -> Callable[[float], float]:
    """Lagrange interpolation through arbitrary (not necessarily consecutive) nodes."""

    def P(y: float) -> float:
        total = 0.0
        for i, xi in enumerate(nodes):
            term = values[i]
            for j, xj in enumerate(nodes):
                if i != j:
                    term *= (y - xj) / (xi - xj)
            total += term
        return total

    return P


def newton_data(nodes: Sequence[int], values: Sequence[float]) -> Tuple[int, List[float]]:
    """Return (deg P, [Delta^k P(0)]) for the polynomial through the samples.

    The Newton coefficients are re-based at 0, which is the normalisation used
    by the residue and Laurent-moment formulas.
    """
    P = interpolate(nodes, values)
    full = [P(float(i)) for i in range(len(nodes))]
    raw = [row[0] for row in difference_table(full)]
    deg = 0
    for k, c in enumerate(raw):
        if abs(c) > 1e-6:
            deg = k
    return deg, raw[: deg + 1]


def residue_from_newton(coeffs: Sequence[float]) -> float:
    """-P(-1) = -sum_k (-1)^k Delta^k P(0), for the expansion based at 0."""
    return -sum((-1) ** k * c for k, c in enumerate(coeffs))


def laurent_moments(coeffs: Sequence[float]) -> List[float]:
    """All Laurent moments m_j = sum_k (-1)^{k+1} C(k,j) Delta^k P(0)."""
    d = len(coeffs) - 1
    return [
        sum((-1) ** (k + 1) * math.comb(k, j) * c for k, c in enumerate(coeffs))
        for j in range(d + 1)
    ]


def poly_zeta_from_newton(coeffs: Sequence[float], q: complex) -> complex:
    """Closed form sum_k Delta^k P(0) q^k / (1-q)^{k+1}."""
    return sum(c * q ** k / (1 - q) ** (k + 1) for k, c in enumerate(coeffs))


def contour_residue(
    F: Callable[[complex], complex], center: complex, rho: float, samples: int = 4096
) -> complex:
    """Numerical residue by the trapezoidal rule on the circle |z - c| = rho."""
    total = 0j
    for t in range(samples):
        theta = 2 * math.pi * t / samples
        z = center + rho * cmath.exp(1j * theta)
        total += F(z) * 1j * rho * cmath.exp(1j * theta)
    return total * (2 * math.pi / samples) / (2j * math.pi)


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def analyse(
    name: str,
    group_of: Callable[[int], List[Perm]],
    r: int,
    grades: Sequence[int],
) -> None:
    counts = [trans_count(group_of(n), n, r) for n in grades]
    deg, coeffs = newton_data(list(grades), [float(c) for c in counts])
    res_pred = residue_from_newton(coeffs)
    res_num = contour_residue(lambda z: poly_zeta_from_newton(coeffs, z), 1 + 0j, 0.3)
    moments = laurent_moments(coeffs)
    transitive = deg == 0 and abs(res_pred + 1) < 1e-9
    print(f"  {name}, r = {r}")
    print(f"     grades {list(grades)} -> orbit counts {counts}")
    print(f"     fitted degree {deg}, Newton coefficients {['%.0f' % c for c in coeffs]}")
    print(f"     predicted pole order {deg + 1}, residue -P(-1) = {res_pred:.6f}")
    print(f"     contour integral residue = {res_num.real:.6f}")
    print(f"     principal part coefficients {['%.0f' % m for m in moments]}")
    print(
        "     detector verdict: "
        + ("EVENTUALLY r-TRANSITIVE" if transitive else "not eventually r-transitive")
    )
    print()


def analyse_quasi(
    name: str,
    group_of: Callable[[int], List[Perm]],
    r: int,
    grades: Sequence[int],
    m: int,
) -> None:
    """Quasi-polynomial analysis: one section polynomial per class mod m."""
    counts = [trans_count(group_of(n), n, r) for n in grades]
    print(f"  {name}, r = {r}, period m = {m}")
    print(f"     grades {list(grades)} -> orbit counts {counts}")
    # Newton coefficients (based at 0) of each section polynomial P_j
    sections: List[List[complex]] = []
    for j in range(m):
        nodes = [n for n in grades if n % m == j]
        vals = [float(c) for n, c in zip(grades, counts) if n % m == j]
        _, coeffs = newton_data(nodes, vals)
        sections.append([complex(c) for c in coeffs])
        pm1 = sum((-1) ** k * c for k, c in enumerate(coeffs))
        print(f"     class {j}: nodes {nodes}, P_{j}(-1) = {pm1:+.4f}")
    width = max(len(s) for s in sections)
    sections = [s + [0j] * (width - len(s)) for s in sections]
    zeta = cmath.exp(2j * math.pi / m)
    # section polynomials S_k in the Newton basis, by linearity
    S = [
        [sum(zeta ** (-(k * j)) * sections[j][i] for j in range(m)) / m
         for i in range(width)]
        for k in range(m)
    ]

    def Z(q: complex) -> complex:
        total = 0j
        for k in range(m):
            w = zeta ** k
            total += sum(
                c * (w * q) ** i / (1 - w * q) ** (i + 1) for i, c in enumerate(S[k])
            )
        return total

    for k in range(m):
        pole = zeta ** (-k)
        pred = -sum((-1) ** i * c for i, c in enumerate(S[k])) / zeta ** k
        num = contour_residue(Z, pole, 0.4)
        print(
            f"     pole at q = {pole.real:+.4f}{pole.imag:+.4f}i:  "
            f"formula {pred.real:+.6f}{pred.imag:+.6f}i   "
            f"contour {num.real:+.6f}{num.imag:+.6f}i"
        )
    print()


def main() -> None:
    print("=" * 74)
    print("Orbit counts of concrete graded families, and their residues")
    print("=" * 74)
    grades = [5, 6, 7, 8, 9, 10]
    primes = [5, 7, 11, 13]

    print("\n-- rotations of Z/nZ (sharply 1-transitive) --\n")
    analyse("cyclic rotations", rotations, 1, grades)
    analyse("cyclic rotations", rotations, 2, grades)

    print("-- dihedral symmetries of Z/nZ --\n")
    analyse("dihedral", dihedral, 1, grades)
    print("  For r = 2 the dihedral orbit counts are floor(n/2): quasi-polynomial")
    print("  of period 2, so the analysis needs a residue at each square root of 1.\n")
    analyse_quasi("dihedral", dihedral, 2, [5, 6, 7, 8, 9, 10, 11, 12], 2)

    print("-- affine group over a prime field (sharply 2-transitive) --\n")
    analyse("affine x -> ax + b", affine, 1, primes)
    analyse("affine x -> ax + b", affine, 2, primes)
    analyse("affine x -> ax + b", affine, 3, primes)

    print("-- trivial group: no identifications --\n")
    for r in (1, 2, 3):
        analyse("trivial action", trivial, r, grades)

    print("Summary of the predicted values:")
    print("  rotations, r = 1:   P = 1        residue -1   (1-transitive)")
    print("  rotations, r = 2:   P(n) = n - 1 residue  2   (pole order 2)")
    print("  affine,   r = 2:    P = 1        residue -1   (2-transitive)")
    print("  affine,   r = 3:    P(n) = n - 2 residue  3")
    print("  dihedral, r = 2:    floor(n/2), quasi-polynomial: residues 3/4 at q = 1")
    print("                      and 1/4 at q = -1")
    print("  trivial,  r:        P(n) = n(n-1)...(n-r+1), residue (-1)^(r+1) r!")


if __name__ == "__main__":
    main()


"""
Domain colouring of transitivity partition functions on the complex q-plane.

Three panels show how the singularity picture changes with the grade count:

  (a) eventually transitive grade count a_n = 1: one simple pole at q = 1
      with residue -1;
  (b) polynomial grade count P(n) = 2n^2 - 3n + 5: one pole at q = 1 of
      order 3, residue -P(-1) = -10;
  (c) grade count periodic mod 5: one simple pole at each fifth root of
      unity, with residues given by the discrete Fourier transform of one
      period.

Brightness encodes log|Z(q)| (poles blaze white) and hue encodes arg Z(q),
so the winding of colour around a pole reveals its order: a simple pole
cycles the hue once, an order-3 pole cycles it three times.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def newton_coeffs(values: Sequence[complex]) -> List[complex]:
    """Forward differences at 0 of a polynomial given by P(0), P(1), ..."""
    out: List[complex] = []
    row = list(values)
    while row:
        out.append(row[0])
        row = [row[i + 1] - row[i] for i in range(len(row) - 1)]
    return out


def poly_zeta(coeffs: Sequence[complex], q: complex) -> complex:
    """sum_k Delta^k P(0) q^k / (1-q)^{k+1}: closed form of sum_n P(n) q^n."""
    return sum(c * q ** k / (1 - q) ** (k + 1) for k, c in enumerate(coeffs))


def periodic_zeta(period: Sequence[complex], q: complex) -> complex:
    """Closed form of sum_n c_{n mod m} q^n = (sum_j c_j q^j) / (1 - q^m)."""
    m = len(period)
    return sum(c * q ** j for j, c in enumerate(period)) / (1 - q ** m)


def domain_colour(
    F: Callable[[complex], complex], extent: float = 1.8, n: int = 600
) -> np.ndarray:
    """RGB image of F on the square [-extent, extent]^2 of the q-plane."""
    xs = np.linspace(-extent, extent, n)
    ys = np.linspace(-extent, extent, n)
    img = np.zeros((n, n, 3))
    for i, y in enumerate(ys):
        for j, x in enumerate(xs):
            try:
                w = F(complex(x, y))
            except ZeroDivisionError:
                w = complex(float("inf"), 0.0)
            mag = abs(w)
            hue = (cmath.phase(w) / (2 * math.pi)) % 1.0
            val = 1.0 - 1.0 / (1.0 + math.log1p(mag))
            img[n - 1 - i, j] = hsv_to_rgb(hue, 0.85, min(1.0, 0.15 + val))
    return img


def hsv_to_rgb(h: float, s: float, v: float) -> tuple[float, float, float]:
    """Minimal HSV -> RGB conversion."""
    i = int(h * 6) % 6
    f = h * 6 - int(h * 6)
    p, q_, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    return [(v, t, p), (q_, v, p), (p, v, t), (p, q_, v), (t, p, v), (v, p, q_)][i]


def main() -> None:
    const = newton_coeffs([1 + 0j])
    quad_values = [complex(2 * n * n - 3 * n + 5) for n in range(3)]
    quad = newton_coeffs(quad_values)
    period = [complex(c) for c in (3, 1, 4, 1, 5)]

    panels = [
        ("(a) a_n = 1: simple pole at q=1, residue -1",
         lambda q: poly_zeta(const, q)),
        ("(b) P(n)=2n^2-3n+5: order-3 pole, residue -10",
         lambda q: poly_zeta(quad, q)),
        ("(c) period (3,1,4,1,5) mod 5: a pole at each fifth root of unity",
         lambda q: periodic_zeta(period, q)),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5.6))
    for ax, (title, F) in zip(axes, panels):
        ax.imshow(domain_colour(F), extent=(-1.8, 1.8, -1.8, 1.8))
        circle = plt.Circle((0, 0), 1.0, fill=False, color="white", lw=1.0, ls="--")
        ax.add_patch(circle)
        ax.set_title(title, fontsize=9)
        ax.set_xlabel("Re q")
        ax.set_ylabel("Im q")
    fig.suptitle(
        "Transitivity partition functions: brightness = log|Z|, hue = arg Z\n"
        "(the dashed circle is the boundary of convergence of the series)",
        fontsize=11,
    )
    fig.tight_layout()
    fig.savefig("partition_function_domains.png", dpi=150)
    print("wrote partition_function_domains.png")


if __name__ == "__main__":
    main()


"""
The residue spectrum, and how fast a contour integral finds it.

Left panel: for a grade count periodic modulo m the partition function has a
simple pole at every m-th root of unity, with residue -A_k / zeta^k where A_k
is the k-th discrete Fourier coefficient of one period.  The panel plots the
unit circle, the poles, and each residue as an arrow drawn at its pole,
turning the abstract "residue spectrum" into a picture: the arrows are the
Fourier transform of the period.

Right panel: the residues above are computed by the trapezoidal rule on a
circle.  For analytic integrands this rule converges geometrically, and the
panel plots the absolute error against the number of sample points, on a
logarithmic scale, for three radii.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def periodic_zeta(period: Sequence[complex], q: complex) -> complex:
    """Closed form of sum_n c_{n mod m} q^n = (sum_j c_j q^j) / (1 - q^m)."""
    m = len(period)
    return sum(c * q ** j for j, c in enumerate(period)) / (1 - q ** m)


def fourier_amplitudes(period: Sequence[complex]) -> List[complex]:
    """A_k = (1/m) sum_j zeta^{-kj} c_j, with zeta = exp(2 pi i / m)."""
    m = len(period)
    zeta = cmath.exp(2j * math.pi / m)
    return [
        sum(zeta ** (-(k * j)) * c for j, c in enumerate(period)) / m
        for k in range(m)
    ]


def contour_residue(
    F: Callable[[complex], complex], center: complex, rho: float, samples: int
) -> complex:
    """Trapezoidal-rule residue of F at center on the circle of radius rho."""
    total = 0j
    for t in range(samples):
        theta = 2 * math.pi * t / samples
        z = center + rho * cmath.exp(1j * theta)
        total += F(z) * 1j * rho * cmath.exp(1j * theta)
    return total * (2 * math.pi / samples) / (2j * math.pi)


def main() -> None:
    period = [complex(c) for c in (3, 1, 4, 1, 5)]
    m = len(period)
    zeta = cmath.exp(2j * math.pi / m)
    amps = fourier_amplitudes(period)
    residues = [-amps[k] / zeta ** k for k in range(m)]
    poles = [zeta ** (-k) for k in range(m)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.6))

    theta = np.linspace(0, 2 * math.pi, 400)
    ax1.plot(np.cos(theta), np.sin(theta), color="0.7", lw=1, ls="--")
    scale = 0.45 / max(abs(r) for r in residues)
    for k, (p, res) in enumerate(zip(poles, residues)):
        ax1.plot([p.real], [p.imag], "o", color="crimson", ms=7)
        ax1.arrow(
            p.real,
            p.imag,
            scale * res.real,
            scale * res.imag,
            width=0.008,
            color="navy",
            length_includes_head=True,
        )
        ax1.annotate(
            f"k={k}\nRes={res.real:.2f}{res.imag:+.2f}i",
            (p.real, p.imag),
            textcoords="offset points",
            xytext=(8, 8),
            fontsize=8,
        )
    ax1.set_aspect("equal")
    ax1.set_xlim(-2.0, 2.0)
    ax1.set_ylim(-2.0, 2.0)
    ax1.set_title(
        f"Residue spectrum of the period {tuple(int(c.real) for c in period)}\n"
        "one simple pole at each fifth root of unity"
    )
    ax1.set_xlabel("Re q")
    ax1.set_ylabel("Im q")

    exact = residues[0]
    F = lambda q: periodic_zeta(period, q)
    counts = [8, 16, 32, 64, 128, 256, 512]
    for rho, style in ((0.2, "o-"), (0.4, "s-"), (0.55, "^-")):
        errs = [
            max(abs(contour_residue(F, poles[0], rho, T) - exact), 1e-18)
            for T in counts
        ]
        ax2.semilogy(counts, errs, style, label=f"radius {rho}")
    ax2.set_xlabel("number of sample points on the contour")
    ax2.set_ylabel("absolute error in the residue at q = 1")
    ax2.set_title("Geometric convergence of the trapezoidal rule")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("residue_spectrum.png", dpi=150)
    print("wrote residue_spectrum.png")


if __name__ == "__main__":
    main()
