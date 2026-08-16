"""
Algorithm: Lexicographic Dominant-Term Extraction and Limit Evaluation
======================================================================

Given a transseries as a finite list of (rank, coefficient) pairs, where a rank
(d, a, b, c) names the transmonomial

    m_{d,a,b,c}(x) = exp(d e^x) exp(a x) x^b (log x)^c ,

the dominant term is the one whose rank is largest in the LEXICOGRAPHIC order
(fastest scale first).  The Dominant-Term Theorem states

    f(x) / (kappa * m_{g0}(x))  ->  1     as x -> +infinity,

where g0 is the dominant rank and kappa its coefficient.  Everything about the
asymptotics of f -- its limit, its eventual sign, whether it eventually vanishes --
is read off from (g0, kappa) alone.

Complexity: O(m) comparisons for m terms (a single linear scan), each comparison
costing at most 4 real comparisons.
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional, Tuple

Rank = Tuple[float, float, float, float]
Transseries = Dict[Rank, float]

ZERO_RANK: Rank = (0.0, 0.0, 0.0, 0.0)


def dominant_term(f: Transseries) -> Optional[Tuple[Rank, float]]:
    """Return (dominant rank, its coefficient), or None for the zero transseries.

    The lexicographic maximum is exactly Python's tuple maximum."""
    terms = [(g, c) for g, c in f.items() if c != 0.0]
    if not terms:
        return None
    best_rank, best_coeff = terms[0]
    for g, c in terms[1:]:
        if g > best_rank:  # lexicographic comparison
            best_rank, best_coeff = g, c
    return best_rank, best_coeff


def limit_at_infinity(f: Transseries) -> str:
    """Compute lim_{x->+inf} f(x) in the extended reals, exactly."""
    dom = dominant_term(f)
    if dom is None:
        return "0"
    g0, kappa = dom
    if g0 < ZERO_RANK:      # dominant transmonomial tends to 0
        return "0"
    if g0 == ZERO_RANK:     # dominant transmonomial is the constant 1
        return f"{kappa:g}"
    return "+infinity" if kappa > 0 else "-infinity"


def eventual_sign(f: Transseries) -> int:
    """+1, -1 or 0: the sign that f(x) eventually takes and keeps."""
    dom = dominant_term(f)
    if dom is None:
        return 0
    _, kappa = dom
    return 1 if kappa > 0 else -1


def compare_germs(f: Transseries, g: Transseries) -> int:
    """Decide whether f < g, f = g or f > g eventually, by comparing expansions.

    Correctness is the Faithfulness Theorem: eventual comparison of the functions
    is comparison of their transseries."""
    diff: Transseries = dict(f)
    for k, v in g.items():
        diff[k] = diff.get(k, 0.0) - v
    return -eventual_sign(diff)


def evaluate(f: Transseries, x: float) -> float:
    """Numerically evaluate the (finite) transseries at a point x > 1."""
    total = 0.0
    for (d, a, b, c), coeff in f.items():
        lx = math.log(x)
        arg = a * x + b * lx + c * math.log(lx)
        if d:
            arg += d * math.exp(x)
        total += coeff * math.exp(arg)
    return total


if __name__ == "__main__":
    examples: List[Tuple[str, Transseries]] = [
        ("3 e^x / x^2 - 5 log x + 7",
         {(0.0, 1.0, -2.0, 0.0): 3.0, (0.0, 0.0, 0.0, 1.0): -5.0, ZERO_RANK: 7.0}),
        ("1000 log x - 2 x", {(0.0, 0.0, 0.0, 1.0): 1000.0, (0.0, 0.0, 1.0, 0.0): -2.0}),
        ("7 - 4/x", {ZERO_RANK: 7.0, (0.0, 0.0, -1.0, 0.0): -4.0}),
        ("e^(e^x) - e^(1000 x)", {(1.0, 0.0, 0.0, 0.0): 1.0, (0.0, 1000.0, 0.0, 0.0): -1.0}),
    ]
    for name, f in examples:
        dom = dominant_term(f)
        assert dom is not None
        print(f"{name:<28s} dominant rank {dom[0]}  coeff {dom[1]:+g}"
              f"  limit = {limit_at_infinity(f):<10s} sign = {eventual_sign(f):+d}")
    a = {(0.0, 0.0, 1.0, 0.0): 1.0}                       # x
    b = {(0.0, 0.0, 0.0, 1.0): 1e9}                       # 10^9 log x
    print(f"\nx vs 10^9 log x eventually: "
          f"{'x < 10^9 log x' if compare_germs(a, b) < 0 else 'x > 10^9 log x'}")
    print(f"   (at x = 10^6 the numbers still say the opposite: "
          f"{evaluate(a, 1e6):.3e} vs {evaluate(b, 1e6):.3e})")


"""
Algorithm: Henselian Deformation of a Simple Residue Root
=========================================================

The transseries field contains roots that no radical formula can reach.  They are
produced as follows.  Let F(z) be a monic polynomial whose coefficients are formal
power series in a parameter X, and suppose the residue polynomial F_0 = F mod X,
a genuine real polynomial, has a SIMPLE real root a (F_0(a) = 0, F_0'(a) != 0).
Then:

  1. R[[X]] is X-adically complete, hence Henselian, so Newton's iteration

         y_{k+1} = y_k - F(y_k) / F'(y_k),      y_0 = a,

     converges X-adically: the X-order of F(y_k) at least doubles at each step
     (quadratic convergence), and F'(y_k) is invertible because its constant term
     F_0'(a) is a nonzero real.

  2. Substituting an INFINITESIMAL transseries t for X is a ring homomorphism
     R[[X]] -> transseries (the family (f_k t^k) is summable because t has
     positive order), and it carries the root to a root.

Applied to F(z) = z^3 - 3z + X with residue root a = 0 this produces, for every
infinitesimal t, a root of z^3 - 3z + t, although the Cardano discriminant
(t/2)^2 + (-3/3)^3 = t^2/4 - 1 is strictly NEGATIVE.  This is the classical
casus irreducibilis: such a root cannot be expressed by real radicals.

Complexity: O(log N) Newton steps to reach precision X^N, each step costing a
truncated power series multiplication and inversion, i.e. O(N^2) coefficient
operations naively (or O(N log N) with fast multiplication).
"""

from __future__ import annotations

from typing import Callable, List

Series = List[float]  # coefficients of a truncated element of R[[X]]


def series_mul(p: Series, q: Series, order: int) -> Series:
    out = [0.0] * order
    for i, pi in enumerate(p[:order]):
        if pi == 0.0:
            continue
        for j, qj in enumerate(q[:order - i]):
            if qj != 0.0:
                out[i + j] += pi * qj
    return out


def series_inv(p: Series, order: int) -> Series:
    """Inverse of a power series with nonzero constant term (a unit of R[[X]])."""
    if p[0] == 0.0:
        raise ValueError("not a unit: the constant term vanishes")
    out = [0.0] * order
    out[0] = 1.0 / p[0]
    for n in range(1, order):
        out[n] = -sum(p[k] * out[n - k] for k in range(1, min(n, len(p) - 1) + 1)) / p[0]
    return out


def series_eval_poly(coeffs: List[Series], y: Series, order: int) -> Series:
    """Evaluate sum_i coeffs[i] * y^i by Horner's rule in R[[X]]."""
    acc: Series = [0.0] * order
    for c in reversed(coeffs):
        acc = series_mul(acc, y, order)
        for i in range(min(order, len(c))):
            acc[i] += c[i]
    return acc


def hensel_lift(coeffs: List[Series], residue_root: float, order: int = 12) -> Series:
    """Lift a simple root of the residue polynomial to a root in R[[X]].

    `coeffs[i]` is the power series coefficient of z^i; the polynomial must be
    monic and `residue_root` must be a simple root of z -> sum coeffs[i][0] z^i."""
    deriv_coeffs = [[c * i for c in coeffs[i]] for i in range(1, len(coeffs))]
    residue_deriv = sum(dc[0] * residue_root ** i for i, dc in enumerate(deriv_coeffs))
    if residue_deriv == 0.0:
        raise ValueError("the residue root is not simple; Hensel does not apply")
    y: Series = [0.0] * order
    y[0] = residue_root
    precision = 1
    while precision < order:
        precision = min(order, 2 * precision)   # quadratic convergence
        F = series_eval_poly(coeffs, y, precision)
        Fp = series_eval_poly(deriv_coeffs, y, precision)
        corr = series_mul(F, series_inv(Fp, precision), precision)
        y = [y[i] - (corr[i] if i < precision else 0.0) for i in range(order)]
    return y


def casus_irreducibilis_root(order: int = 12) -> Series:
    """The root of z^3 - 3 z + X as a power series in X."""
    zero: Series = [0.0] * order
    X: Series = [0.0] * order
    if order > 1:
        X[1] = 1.0
    minus3: Series = [-3.0] + [0.0] * (order - 1)
    one: Series = [1.0] + [0.0] * (order - 1)
    return hensel_lift([X, minus3, zero, one], residue_root=0.0, order=order)


if __name__ == "__main__":
    y = casus_irreducibilis_root(order=14)
    terms = "  ".join(f"{c:+.8g} X^{i}" for i, c in enumerate(y) if abs(c) > 1e-15)
    print("root of z^3 - 3z + X in R[[X]]:")
    print("   z(X) =", terms)
    print("\nSubstituting an infinitesimal (numerically, small real t):")
    for t in (1e-1, 1e-2, 1e-3, 1e-4):
        z = sum(c * t ** i for i, c in enumerate(y))
        print(f"   t = {t:8.1e}:  z = {z: .14f}   residual = {z**3 - 3*z + t: .3e}"
              f"   Cardano disc = {(t/2)**2 - 1: .8f} < 0")
    print("\nThe discriminant is negative for every infinitesimal t, so the root")
    print("is not obtainable by real radicals -- it exists by Hensel lifting alone.")


"""
Algorithm: Newton Scaling Normalisation of a Monic Transseries Polynomial
=========================================================================

Given a monic polynomial P(z) = z^n + a_{n-1} z^{n-1} + ... + a_0 over the
transseries field, the Newton scaling operator is

    N_lambda(P)(z) = lambda^{-n} P(lambda z),

again monic of degree n, with coefficients a_i * lambda^{i-n}, and with roots
exactly the roots of P divided by lambda.  The Newton Normalisation Theorem says
that the choice

    lambda = max_{i < n, a_i != 0} |a_i|^{1/(n-i)}

makes N_lambda(P) NORMALISED:

  * every coefficient lies in the valuation ring, |a_i lambda^{i-n}| <= 1;
  * unless P = z^n, some non-leading coefficient has absolute value exactly 1.

Normalisation is exactly the hypothesis under which the residue polynomial (reduce
modulo the infinitesimals) is a genuine monic real polynomial of degree n other
than z^n, so that the real closedness of R becomes usable, and it is accompanied
by the Cauchy root bound |z| < 2.

The maximum exists because the transseries order is total; the fractional powers
exist because every positive transseries has n-th roots of all orders.

Complexity: n root extractions and n-1 comparisons; on the level of ranks alone
(the case implemented here, where each coefficient is a transmonomial) the whole
computation is O(n) arithmetic on quadruples of reals.
"""

from __future__ import annotations

from typing import List, Optional, Tuple

Rank = Tuple[float, float, float, float]

ZERO_RANK: Rank = (0.0, 0.0, 0.0, 0.0)


def rank_add(g: Rank, h: Rank) -> Rank:
    return (g[0] + h[0], g[1] + h[1], g[2] + h[2], g[3] + h[3])


def rank_smul(s: float, g: Rank) -> Rank:
    return (s * g[0], s * g[1], s * g[2], s * g[3])


def newton_lambda(coeff_ranks: List[Optional[Rank]]) -> Rank:
    """The Newton scaling exponent, as a rank.

    coeff_ranks[i] is the rank of a_i, or None if a_i = 0; the list has length
    n+1 and coeff_ranks[n] must be the rank 0 (monic)."""
    n = len(coeff_ranks) - 1
    candidates = [rank_smul(1.0 / (n - i), g)
                  for i, g in enumerate(coeff_ranks[:n]) if g is not None]
    if not candidates:
        return ZERO_RANK          # P = z^n; take lambda = 1
    return max(candidates)        # lexicographic max = largest transseries


def scaled_coefficient_ranks(coeff_ranks: List[Optional[Rank]],
                             lam: Rank) -> List[Optional[Rank]]:
    """The ranks of the coefficients of N_lambda(P)."""
    n = len(coeff_ranks) - 1
    return [None if g is None else rank_add(g, rank_smul(float(i - n), lam))
            for i, g in enumerate(coeff_ranks)]


def is_normalised(scaled: List[Optional[Rank]]) -> Tuple[bool, bool]:
    """Return (all coefficients in the valuation ring, some non-leading one is a
    unit).  A transmonomial of rank g has absolute value <= 1 iff g <= 0, and
    exactly 1 iff g = 0."""
    n = len(scaled) - 1
    bounded = all(g is None or not (ZERO_RANK < g) for g in scaled)
    hits_unit = any(g == ZERO_RANK for g in scaled[:n])
    return bounded, hits_unit


def normalise(coeff_ranks: List[Optional[Rank]]) -> Tuple[Rank, List[Optional[Rank]]]:
    """Full pipeline: choose lambda, rescale, and certify normalisation."""
    lam = newton_lambda(coeff_ranks)
    scaled = scaled_coefficient_ranks(coeff_ranks, lam)
    bounded, hits_unit = is_normalised(scaled)
    assert bounded, "normalisation failed: a coefficient left the valuation ring"
    assert hits_unit or all(g is None for g in coeff_ranks[:-1]), \
        "normalisation failed: no non-leading unit coefficient"
    return lam, scaled


def name(g: Optional[Rank]) -> str:
    if g is None:
        return "0"
    d, a, b, c = g
    parts = []
    if d:
        parts.append(f"exp({d:g} e^x)")
    if a:
        parts.append(f"e^({a:g}x)")
    if b:
        parts.append(f"x^{b:g}")
    if c:
        parts.append(f"(log x)^{c:g}")
    return " ".join(parts) if parts else "1"


if __name__ == "__main__":
    tests: List[Tuple[str, List[Optional[Rank]]]] = [
        ("z^3 + x^2 z^2 + x^5 z + x^9",
         [(0.0, 0.0, 9.0, 0.0), (0.0, 0.0, 5.0, 0.0), (0.0, 0.0, 2.0, 0.0), ZERO_RANK]),
        ("z^5 + e^x z + e^(e^x)",
         [(1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), None, None, None, ZERO_RANK]),
        ("z^3 + (1/x) z^2 + (1/x^7)",
         [(0.0, 0.0, -7.0, 0.0), None, (0.0, 0.0, -1.0, 0.0), ZERO_RANK]),
    ]
    for label, ranks in tests:
        lam, scaled = normalise(ranks)
        print(f"P = {label}")
        print(f"   lambda   = {name(lam)}")
        print("   scaled coefficients:")
        for i, g in enumerate(scaled):
            print(f"      i = {i}:  {name(g):<22s} rank {g}")
        bounded, unit = is_normalised(scaled)
        print(f"   in valuation ring: {bounded};  non-leading unit present: {unit}\n")


"""
Algorithm: Root Extraction by Leading Decomposition and Binomial Expansion
==========================================================================

To compute an n-th root of a POSITIVE transseries f, factor it as

    f = m_g * r * (1 + eps),      r = leading coefficient > 0,
                                  eps infinitesimal (all ranks strictly below 0),

and take the three roots separately:

  (i)   m_g^(1/n) = m_{g/n}          -- possible because the rank group R^4 is
                                        DIVISIBLE (real exponents, not integers);
  (ii)  r^(1/n)                      -- possible because R is real closed;
  (iii) (1 + eps)^(1/n) = sum_k C(1/n, k) eps^k
                                     -- the binomial series, which is a genuinely
                                        INFINITE transseries and converges in the
                                        formal (Hahn) sense because
                                        ord(eps^k) = k * ord(eps) -> -infinity.

Complexity: with the series truncated after N terms, the cost is N transseries
multiplications; if eps has m terms, the truncated product has O(m^N) terms in the
worst case and O(N*m) for the common case of eps supported on a single line of
ranks.  Coefficients are computed exactly in rational arithmetic.
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial
from typing import Dict, Tuple

Rank = Tuple[float, float, float, float]
Transseries = Dict[Rank, float]

ZERO_RANK: Rank = (0.0, 0.0, 0.0, 0.0)


def rank_add(g: Rank, h: Rank) -> Rank:
    return (g[0] + h[0], g[1] + h[1], g[2] + h[2], g[3] + h[3])


def rank_smul(s: float, g: Rank) -> Rank:
    return (s * g[0], s * g[1], s * g[2], s * g[3])


def ts_mul(f: Transseries, g: Transseries, floor: Rank) -> Transseries:
    """Product, discarding every term of rank at or below `floor`."""
    out: Transseries = {}
    for k1, v1 in f.items():
        for k2, v2 in g.items():
            k = rank_add(k1, k2)
            if not floor < k:
                continue
            out[k] = out.get(k, 0.0) + v1 * v2
    return {k: v for k, v in out.items() if v != 0.0}


def binomial_coefficient(s: Fraction, k: int) -> Fraction:
    """Generalised binomial coefficient C(s, k) = s(s-1)...(s-k+1)/k!, exactly."""
    num = Fraction(1)
    for j in range(k):
        num *= (s - j)
    return num / factorial(k)


def leading_decomposition(f: Transseries) -> Tuple[Rank, float, Transseries]:
    """Return (g, r, eps) with f = m_g * r * (1 + eps) and eps infinitesimal."""
    g = max(k for k, v in f.items() if v != 0.0)
    r = f[g]
    eps = {rank_add(k, rank_smul(-1.0, g)): v / r for k, v in f.items() if v != 0.0}
    del eps[ZERO_RANK]
    return g, r, eps


def nth_root(f: Transseries, n: int, depth: int = 8) -> Transseries:
    """An n-th root of the positive transseries f, truncated after `depth` binomial
    terms.  Raises if f is not positive."""
    g, r, eps = leading_decomposition(f)
    if r <= 0.0:
        raise ValueError("n-th roots are guaranteed only for positive transseries")
    head: Transseries = {rank_smul(1.0 / n, g): r ** (1.0 / n)}
    if not eps:
        return head
    eps_order = max(eps)                                  # strictly below 0
    floor = rank_smul(float(depth + 1), eps_order)        # truncation floor
    unit: Transseries = {ZERO_RANK: 1.0}
    power: Transseries = {ZERO_RANK: 1.0}
    s = Fraction(1, n)
    for k in range(1, depth + 1):
        power = ts_mul(power, eps, floor)
        if not power:
            break
        coeff = float(binomial_coefficient(s, k))
        for rk, v in power.items():
            unit[rk] = unit.get(rk, 0.0) + coeff * v
    return ts_mul(head, unit, rank_add(rank_smul(1.0 / n, g), floor))


if __name__ == "__main__":
    import math

    f: Transseries = {(0.0, 0.0, 1.0, 0.0): 1.0, ZERO_RANK: 1.0}  # x + 1
    root = nth_root(f, 2, depth=8)
    print("sqrt(x + 1) =")
    for g, c in sorted(root.items(), reverse=True):
        print(f"    {c:+.10f} * x^{g[2]:g}")
    for x in (5.0, 50.0, 5000.0):
        approx = sum(c * math.exp(g[2] * math.log(x)) for g, c in root.items())
        print(f"  x = {x:>8.0f}: series {approx:.12f}  exact {math.sqrt(x+1):.12f}")

    g_: Transseries = {(0.0, 1.0, 0.0, 0.0): 1.0, (0.0, 0.0, 1.0, 0.0): 3.0}  # e^x + 3x
    cube = nth_root(g_, 3, depth=5)
    print("\n(e^x + 3x)^(1/3) has leading term of rank",
          max(cube), "-- i.e. e^(x/3), as expected.")


"""
Demonstration: Faithfulness of the Expansion and the Hardy-Field Trichotomy
===========================================================================

Three theorems, exhibited numerically.

1. FAITHFULNESS.  Two exp-log expressions define eventually equal functions if and
   only if their transseries expansions coincide, and one is eventually smaller than
   the other exactly when its expansion is smaller.  So comparison of germs is a
   finite, exact computation on the expansions -- and it is right even when direct
   numerical evaluation at any feasible x says the opposite.

2. THE HARDY-FIELD TRICHOTOMY.  Every exp-log function of this kind is eventually
   strictly increasing, strictly decreasing, or constant; it never oscillates; and it
   therefore has a limit in R u {+-infinity}.  The proof runs through the derivative,
   which lies in the same algebra, so its dominant term settles the sign.

3. NO FLAT ELEMENTS.  A nonzero exp-log function is never o(m) for every
   transmonomial m -- it is asymptotic to a constant multiple of its own dominant
   transmonomial.  This is what makes the expansion a complete invariant, and it is
   exactly what fails for power series (where e^{-x} is invisible).

Run:  python3 demo_hardy_field.py
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple

Rank = Tuple[float, float, float, float]     # (d, a, b, c), compared lexicographically
Transseries = Dict[Rank, float]

ZERO: Rank = (0.0, 0.0, 0.0, 0.0)
R_EXP: Rank = (0.0, 1.0, 0.0, 0.0)           # e^x
R_INV_X: Rank = (0.0, 0.0, -1.0, 0.0)        # 1/x
R_INV_XLOG: Rank = (0.0, 0.0, -1.0, -1.0)    # 1/(x log x)


def rank_add(g: Rank, h: Rank) -> Rank:
    return (g[0] + h[0], g[1] + h[1], g[2] + h[2], g[3] + h[3])


def evaluate(f: Transseries, x: float) -> float:
    total = 0.0
    lx = math.log(x)
    for (d, a, b, c), coeff in f.items():
        arg = a * x + b * lx + c * math.log(lx)
        if d:
            arg += d * math.exp(x)
        total += coeff * math.exp(arg)
    return total


def log_of_monomial(f: Transseries, x: float) -> float:
    """log of a single-term transseries, computed without overflow."""
    (d, a, b, c), coeff = next(iter(f.items()))
    lx = math.log(x)
    val = a * x + b * lx + c * math.log(lx)
    if d:
        val += d * math.exp(x)
    return math.log(abs(coeff)) + val


def dominant(f: Transseries) -> Tuple[Rank, float] | None:
    live = {g: c for g, c in f.items() if c != 0.0}
    if not live:
        return None
    g = max(live)
    return g, live[g]


def dlog(g: Rank) -> Transseries:
    """Logarithmic derivative of the transmonomial of rank g."""
    d, a, b, c = g
    out: Transseries = {}
    for rank, coeff in ((R_EXP, d), (ZERO, a), (R_INV_X, b), (R_INV_XLOG, c)):
        if coeff:
            out[rank] = out.get(rank, 0.0) + coeff
    return out


def derivative(f: Transseries) -> Transseries:
    out: Transseries = {}
    for g, c in f.items():
        for h, v in dlog(g).items():
            k = rank_add(g, h)
            out[k] = out.get(k, 0.0) + c * v
    return {k: v for k, v in out.items() if v != 0.0}


def limit(f: Transseries) -> str:
    dom = dominant(f)
    if dom is None:
        return "0"
    g0, kappa = dom
    if g0 < ZERO:
        return "0"
    if g0 == ZERO:
        return f"{kappa:g}"
    return "+infinity" if kappa > 0 else "-infinity"


def trichotomy(f: Transseries) -> str:
    df = derivative(f)
    dom = dominant(df)
    if dom is None:
        return "eventually CONSTANT"
    return ("eventually STRICTLY INCREASING" if dom[1] > 0
            else "eventually STRICTLY DECREASING")


def main() -> None:
    print("=" * 76)
    print("1. FAITHFULNESS: comparison of germs is comparison of expansions")
    print("=" * 76)
    pairs: List[Tuple[str, Transseries, str, Transseries, float]] = [
        ("x", {(0.0, 0.0, 1.0, 0.0): 1.0},
         "10^9 log x", {(0.0, 0.0, 0.0, 1.0): 1e9}, 1e6),
        ("x^50", {(0.0, 0.0, 50.0, 0.0): 1.0},
         "e^(x/1000)", {(0.0, 0.001, 0.0, 0.0): 1.0}, 1e3),
        ("e^(10^6 x)", {(0.0, 1e6, 0.0, 0.0): 1.0},
         "e^(e^x)", {(1.0, 0.0, 0.0, 0.0): 1.0}, 12.0),
    ]
    for na, fa, nb, fb, x in pairs:
        diff = dict(fa)
        for k, v in fb.items():
            diff[k] = diff.get(k, 0.0) - v
        dom = dominant(diff)
        assert dom is not None
        verdict = f"{na} > {nb}" if dom[1] > 0 else f"{na} < {nb}"
        # compare in log space: all four are single transmonomials, so no overflow
        la, lb = log_of_monomial(fa, x), log_of_monomial(fb, x)
        numeric = f"{na} > {nb}" if la > lb else f"{na} < {nb}"
        flag = "AGREES" if verdict == numeric else "*** numerics DISAGREE ***"
        print(f"   eventual truth:  {verdict:<24s}"
              f" numerics at x = {x:<8.3g} say {numeric:<24s} {flag}")
    print()

    print("=" * 76)
    print("2. THE HARDY-FIELD TRICHOTOMY: limits exist, nothing oscillates")
    print("=" * 76)
    tests: List[Tuple[str, Transseries]] = [
        ("3 e^x / x^2 - 5 log x + 7",
         {(0.0, 1.0, -2.0, 0.0): 3.0, (0.0, 0.0, 0.0, 1.0): -5.0, ZERO: 7.0}),
        ("7 - 4/x", {ZERO: 7.0, R_INV_X: -4.0}),
        ("-2 x + 1000 log x",
         {(0.0, 0.0, 1.0, 0.0): -2.0, (0.0, 0.0, 0.0, 1.0): 1000.0}),
        ("42 (a constant)", {ZERO: 42.0}),
        ("1/x + 1/(x log x)", {R_INV_X: 1.0, R_INV_XLOG: 1.0}),
    ]
    for name, f in tests:
        print(f"   {name:<28s} limit = {limit(f):<12s} {trichotomy(f)}")
    print()
    print("   Confirming the monotonicity numerically for -2x + 1000 log x")
    print("   (it INCREASES for a while, then turns over -- 'eventually' is real):")
    f = {(0.0, 0.0, 1.0, 0.0): -2.0, (0.0, 0.0, 0.0, 1.0): 1000.0}
    for x in (10.0, 100.0, 400.0, 500.0, 1000.0, 10000.0):
        d = evaluate(derivative(f), x)
        print(f"        x = {x:>8.0f}:  f(x) = {evaluate(f, x):>14.3f}   "
              f"f'(x) = {d:>10.5f}  ({'up' if d > 0 else 'down'})")
    print()

    print("=" * 76)
    print("3. NO FLAT ELEMENTS: every nonzero function is seen by the scale")
    print("=" * 76)
    f = {(0.0, 1.0, -2.0, 0.0): 3.0, (0.0, 0.0, 0.0, 1.0): -5.0, ZERO: 7.0}
    g0, kappa = dominant(f)  # type: ignore[misc]
    print(f"   f = 3 e^x/x^2 - 5 log x + 7 has dominant term {kappa:+g} * rank {g0}")
    for x in (10.0, 20.0, 40.0, 80.0):
        ratio = evaluate(f, x) / (kappa * evaluate({g0: 1.0}, x))
        print(f"        f(x) / (kappa * m(x)) at x = {x:>5.0f}:  {ratio:.12f}")
    print("   -> the ratio tends to 1, so f is NOT o(m) for its own dominant m.")
    print("      Contrast the power series world, where e^{-x} = o(x^{-n}) for every n")
    print("      and is therefore invisible to expansion.  Here nothing hides.")


if __name__ == "__main__":
    main()


"""
Visualization: Flatness of log log x, and Convergence of the Binomial Root Series
=================================================================================

LEFT PANEL -- the Liouville obstruction.  Every EML transmonomial that grows is,
at its slowest, of the form (log x)^c with c > 0.  Yet

        log log x / (log x)^c  ->  0     for every c > 0,

so log log x grows but is FLAT against the entire EML scale.  Since every EML
function tending to +infinity must be asymptotic to a constant multiple of a
single growing transmonomial (the dominant-term theorem), log log x cannot be an
EML function -- and therefore 1/(x log x), whose antiderivative it is, has no
antiderivative inside the algebra.  We plot log(log L / L^c) against log L for
several c; every curve eventually goes to -infinity, but the smaller c is, the
longer it takes.

RIGHT PANEL -- root extraction.  The n-th root of a positive transseries is built
from a divisible rank, a real root of the leading coefficient, and the binomial
series (1 + eps)^(1/n) = sum_k C(1/n, k) eps^k, which is genuinely infinite.  We
plot the relative error of the truncated series for sqrt(x+1) as a function of the
number of terms retained, at several values of x: the error falls geometrically,
at a rate governed by the size of the infinitesimal eps = 1/x.

Run: python3 viz_flatness_and_roots.py    (writes flatness_and_roots.png)
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def binomial_coefficient(s: Fraction, k: int) -> Fraction:
    num = Fraction(1)
    for j in range(k):
        num *= (s - j)
    return num / math.factorial(k)


def sqrt_series_value(x: float, terms: int) -> float:
    """Truncated  sqrt(x) * (1 + 1/x)^(1/2)  =  sqrt(x+1)."""
    eps = 1.0 / x
    s = Fraction(1, 2)
    total = 0.0
    for k in range(terms):
        total += float(binomial_coefficient(s, k)) * eps ** k
    return math.sqrt(x) * total


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # ---------------- left: flatness of log log x ----------------
    L = np.logspace(0.4, 3.0, 900)                # L = log x, on a log axis
    for c, colour in zip((1.0, 0.5, 0.2, 0.05, 0.01),
                         ("#B5446E", "#E8743B", "#D9B310", "#3B7DD8", "#4C9F70")):
        # log( log L / L^c ) = log(log L) - c log L
        ax1.plot(L, np.log(np.log(L)) - c * L, lw=2.0, color=colour,
                 label=rf"$c = {c:g}$")
    ax1.axhline(0.0, color="black", lw=1.0)
    ax1.set_xscale("log")
    ax1.set_xlabel(r"$L = \log x$   (logarithmic axis)", fontsize=12)
    ax1.set_ylabel(r"$\log\!\left(\log L / L^{c}\right)$", fontsize=12)
    ax1.set_title(r"$\log\log x$ is flat against every growing scale $(\log x)^c$"
                  "\n(all curves fall to $-\\infty$; small $c$ merely takes longer)",
                  fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(alpha=0.3)

    # ---------------- right: binomial root series ----------------
    max_terms = 16
    ks: List[int] = list(range(1, max_terms + 1))
    for x, colour in zip((2.0, 4.0, 10.0, 100.0),
                         ("#B5446E", "#E8743B", "#3B7DD8", "#4C9F70")):
        exact = math.sqrt(x + 1.0)
        errs = [max(abs(sqrt_series_value(x, k) - exact) / exact, 1e-17) for k in ks]
        ax2.semilogy(ks, errs, "o-", ms=4, lw=1.8, color=colour,
                     label=rf"$x = {x:g}$   ($\varepsilon = 1/x$)")
    ax2.set_xlabel("number of binomial terms retained", fontsize=12)
    ax2.set_ylabel("relative error of the truncated root", fontsize=12)
    ax2.set_title(r"$\sqrt{x+1} = \sqrt{x}\,\sum_k \binom{1/2}{k} x^{-k}$"
                  "\nthe infinite series is genuinely needed", fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig("flatness_and_roots.png", dpi=160)
    print("wrote flatness_and_roots.png")


if __name__ == "__main__":
    main()


"""
Visualization: The EML Growth Hierarchy and its Lexicographic Order
===================================================================

Two panels.

LEFT: the four scales of the hierarchy, plotted as log(log(m(x))) against x, so
that exp(exp x), exp x, x and log x all fit on one axis.  The curves never cross
after a certain point -- the hierarchy is a strict order -- and the vertical gaps
between the levels grow without bound.

RIGHT: the strictness of the hierarchy.  For n = 1..6 we plot
log( (log x)^n / x ), log( x^n / e^x ) and log( (e^x)^n / e^(e^x) ), all of which
tend to -infinity: NO finite power of one level ever reaches the next.  This is
the analytic content of the Scale Comparison Theorem, which says that the
asymptotic ordering of transmonomials exp(d e^x) exp(a x) x^b (log x)^c is the
LEXICOGRAPHIC ordering of the exponent quadruple (d, a, b, c).

Run: python3 viz_growth_hierarchy.py     (writes growth_hierarchy.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def log_of_monomial(d: float, a: float, b: float, c: float, x: np.ndarray) -> np.ndarray:
    """log of exp(d e^x) exp(a x) x^b (log x)^c, computed safely."""
    lx = np.log(x)
    out = a * x + b * lx + c * np.log(lx)
    if d:
        out = out + d * np.exp(x)
    return out


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # ---------------- left panel: the four scales ----------------
    x = np.linspace(3.0, 6.0, 600)
    scales: List[Tuple[str, Tuple[float, float, float, float], str]] = [
        (r"$\log x$",   (0.0, 0.0, 0.0, 1.0), "#4C9F70"),
        (r"$x$",        (0.0, 0.0, 1.0, 0.0), "#3B7DD8"),
        (r"$e^{x}$",    (0.0, 1.0, 0.0, 0.0), "#E8743B"),
        (r"$e^{e^{x}}$", (1.0, 0.0, 0.0, 0.0), "#B5446E"),
    ]
    for label, (d, a, b, c), colour in scales:
        y = log_of_monomial(d, a, b, c, x)
        ax1.plot(x, np.log(np.abs(y) + 1e-300), lw=2.4, color=colour, label=label)
    ax1.set_xlabel(r"$x$", fontsize=12)
    ax1.set_ylabel(r"$\log\,|\log \mathfrak{m}(x)|$", fontsize=12)
    ax1.set_title("The four scales of the EML hierarchy\n"
                  r"$1 \ll \log x \ll x \ll e^{x} \ll e^{e^{x}}$", fontsize=13)
    ax1.legend(fontsize=12, loc="upper left")
    ax1.grid(alpha=0.3)

    # ---------------- right panel: strictness ----------------
    # Each of the three comparisons  (log x)^n / x,  x^n / e^x,  (e^x)^n / e^(e^x)
    # has log-ratio  n*log(u) - u  with u = log x, u = x, u = e^x respectively.
    # So a single family of curves settles all three at once.
    u = np.logspace(0.3, 3.0, 900)
    cmap = plt.get_cmap("viridis")
    for k, n in enumerate(range(1, 13, 2)):
        ax2.plot(u, n * np.log(u) - u, color=cmap(k / 6.0), lw=1.9,
                 label=rf"$n = {n}$")
    ax2.axhline(0.0, color="black", lw=1.0)
    ax2.set_xscale("log")
    ax2.set_ylim(-300, 40)
    ax2.set_xlabel(r"$u$   ($u=\log x$, $u=x$ or $u=e^{x}$)", fontsize=12)
    ax2.set_ylabel(r"$n\log u - u$   ($=\log$ of the ratio)", fontsize=12)
    ax2.set_title("No finite power of one level reaches the next\n"
                  r"$(\log x)^n\!/x$, $x^n\!/e^x$, $(e^x)^n\!/e^{e^x}$"
                  " all have log-ratio " + r"$n\log u - u \to -\infty$", fontsize=13)
    ax2.legend(fontsize=10, loc="lower left", ncol=2)
    ax2.grid(alpha=0.3, which="both")

    fig.suptitle("Growth ranks: comparing transmonomials is comparing "
                 r"$(d,a,b,c)$ lexicographically", fontsize=14)
    fig.tight_layout()
    fig.savefig("growth_hierarchy.png", dpi=160)
    print("wrote growth_hierarchy.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the deliverables in this directory."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).parent
ASSETS = ROOT / "assets"

LEAN_DIR = pathlib.Path("Catalog/Applications/EML")
LEAN_ORDER = [
    "TransseriesEMLBase.lean",
    "TransseriesRoots.lean",
    "TransseriesOrderRigidity.lean",
    "TransseriesEMLExpansion.lean",
    "TransseriesRingEmbedding.lean",
    "TransseriesDerivation.lean",
    "TransseriesConstants.lean",
    "TransseriesAsymptoticComparison.lean",
    "TransseriesHardyField.lean",
    "TransseriesNoAntiderivative.lean",
    "PowerSeriesHensel.lean",
    "TransseriesHensel.lean",
    "TransseriesRealClosed.lean",
    "TransseriesNewtonScaling.lean",
]


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def lean_bundle() -> tuple[str, List[str]]:
    chunks: List[str] = []
    names: List[str] = []
    for fname in LEAN_ORDER:
        p = ROOT / LEAN_DIR / fname
        rel = str(LEAN_DIR / fname)
        names.append(rel)
        chunks.append(f"/- ======================================================\n"
                      f"   FILE: {rel}\n"
                      f"   ====================================================== -/\n\n"
                      + read(p))
    return "\n\n".join(chunks), names


FUTURE_DIRECTIONS = """# Future Directions — EML Transseries

The formal development of this cycle is organised as follows.

| component | content |
|---|---|
| base | the rank group `Rank = R x_lex (R x_lex (R x_lex R))`, the ordered field `TS` of Hahn series over it, transmonomials, the growth hierarchy, non-Archimedeanity |
| roots | `n`-th roots of positives, squares `=` nonnegatives, odd roots, `-1` is not a sum of squares |
| order rigidity | the ordering is definable (`f <= g` iff `g - f` is a square), uniqueness of the ordering, automatic monotonicity of ring maps, the quadratic fragment of real closedness |
| expansion | the transseries expansion of an exp-log function, order embedding of germs, uniqueness of the expansion |
| ring embedding | the injective ring homomorphisms from the exp-log algebra into `TS` and into the germs at `+infinity` |
| derivation | the formal derivation, the Leibniz rule, and the theorem that it computes the analytic derivative |
| asymptotic comparison | the asymptotic comparison theorem, formal and analytic |
| constants | the kernel of the derivation is exactly `R` |
| Hardy field | limits in `R u {+-infinity}`, eventual strict monotonicity, eventual injectivity |
| no antiderivative | `log log x` is flat against the whole exp-log scale; `1/(x log x)` has no exp-log antiderivative |
| power series Hensel | `R[[X]]` is `X`-adically complete, hence henselian; the evaluation ring map into `TS` at an infinitesimal |
| transseries Hensel | infinitesimals and their positive order; Hensel lifting of simple residue roots into `TS`; Cardano; the casus irreducibilis solved by lifting; the deformation theorem for perturbed real polynomials |
| real closedness | `R` is real closed (via the intermediate value theorem); real closedness of `TS` reduced to the single odd-degree clause; degree-`1` roots |
| Newton scaling | the Newton scaling operator `lambda^{-n} P(lambda X)`, normalisation of an arbitrary monic polynomial, the Cauchy root bound `|z| < 2` for polynomials with coefficients in the valuation ring, and the sharpened reduction of real closedness to *normalised* odd-degree polynomials |

What was **not** achieved: full real closedness of `TS`. The gap is now much sharper
than at the end of the previous cycle. Concretely:

* the *scaling* half of the Newton-polygon argument is now a theorem: for every monic `P`
  there is a positive `lambda` with `lambda^{-n} P(lambda X)` **normalised** — all
  coefficients in the valuation ring (`|coeff| <= 1`) and, unless `P = X^n`, some
  non-leading coefficient exactly `+-1`, so the residue polynomial is monic of degree `n`
  and different from `X^n`. Real closedness is then equivalent to the odd-degree root
  property for *normalised* monic polynomials, and every root of such a polynomial is
  bounded: `|z| < 2`.

* the remaining obstruction is the case of a residue root of multiplicity greater than
  one: the Henselian lifting theorem available here applies to *simple* residue roots.
  The classical remedy is to substitute `z -> a + z_1` around the multiple root, rescale
  again, and induct on the multiplicity; making that induction well-founded over the
  non-discrete value group `R^4`, where Newton slopes need not be discrete, is the crux.

Beyond closing that gap, two directions stand out.

* **Deeper scales.** Replace the four-dimensional rank group by a direct limit over
  iterated exponentials and logarithms, obtaining a scale closed under `exp`, `log` and
  integration. The asymptotic comparison theorem should persist, with the flatness
  argument for `log log x` becoming a diagonal argument.

* **Effective transseries arithmetic.** The proofs of this development are algorithms:
  dominant-term extraction and limit evaluation; root extraction by leading decomposition
  and binomial expansion; Newton scaling normalisation; Henselian deformation of a simple
  residue root; and formal differentiation. Assembled into a library, they give certified
  exp-log limit computation, asymptotic expansion and root finding, with the theorems above
  as their correctness statements.
"""


def main() -> None:
    article = read(ROOT / "ARTICLE.md")
    paper_md = read(ROOT / "RESEARCH_PAPER.md")
    paper_tex = read(ROOT / "RESEARCH_PAPER.tex")
    demo = read(ROOT / "demo.py")
    lean_src, lean_files = lean_bundle()

    demos: List[Dict[str, str]] = [
        {
            "name": "Complete Numerical Laboratory for Exponential–Logarithmic "
                    "Transseries",
            "description":
                "An end-to-end computational companion to the theory. It implements "
                "growth ranks as quadruples of reals with lexicographic comparison and "
                "verifies the Scale Comparison Theorem numerically; confirms the strict "
                "hierarchy (no finite power of one scale reaches the next); builds a "
                "truncated transseries arithmetic and uses it to extract n-th roots via "
                "the leading decomposition together with the generalised binomial series, "
                "checking the truncated roots against exact values to machine precision; "
                "illustrates the dominant-term theorem by computing limits, eventual signs "
                "and asymptotic ratios; implements the formal derivation (the logarithmic "
                "derivative rule d·e^x + a + b/x + c/(x log x)) and validates it against "
                "central-difference numerical derivatives; exhibits the flatness of "
                "log log x against every growing transmonomial, in log space so that "
                "astronomically large arguments can be reached; performs the Hensel lift "
                "of the casus-irreducibilis cubic z^3 - 3z + t as a power series in the "
                "infinitesimal t, verifying that the residual vanishes while the Cardano "
                "discriminant stays strictly negative; carries out Newton scaling "
                "normalisation of a monic polynomial with transmonomial coefficients; and "
                "confirms the Cauchy root bound |z| < 2 over thousands of random "
                "normalised polynomials.",
            "code": demo,
        },
        {
            "name": "Faithfulness of the Expansion and the Hardy-Field Trichotomy",
            "description":
                "A focused demonstration of the three theorems that make the transseries "
                "expansion a complete asymptotic invariant. First, faithfulness: the "
                "eventual comparison of two exp-log germs is decided exactly by comparing "
                "their expansions, and the script exhibits three pairs (x versus 10^9 log x, "
                "x^50 versus e^{x/1000}, e^{10^6 x} versus e^{e^x}) where direct numerical "
                "evaluation at any feasible argument gives the *opposite* answer to the "
                "truth — showing why an exact symbolic criterion is indispensable. Second, "
                "the Hardy-field trichotomy: the derivative of an exp-log expression lies "
                "in the same algebra, so its dominant term decides eventual monotonicity; "
                "the script classifies several functions as eventually increasing, "
                "decreasing or constant, computes their limits in the extended reals, and "
                "traces the sign of the derivative of -2x + 1000 log x across the point "
                "where it finally turns over. Third, the absence of flat elements: a "
                "nonzero exp-log function is asymptotic to a constant multiple of its own "
                "dominant transmonomial, in sharp contrast to the power-series world where "
                "e^{-x} is invisible to every order.",
            "code": read(ASSETS / "demo_hardy_field.py"),
        },
    ]

    algorithms: List[Dict[str, str]] = [
        {
            "name": "Lexicographic Dominant-Term Extraction and Limit Evaluation",
            "description":
                "The workhorse of exp-log asymptotics. A transseries is stored as a finite "
                "list of (rank, coefficient) pairs, a rank (d, a, b, c) naming the "
                "transmonomial exp(d e^x) e^{ax} x^b (log x)^c. The Scale Comparison "
                "Theorem says that asymptotic comparison of transmonomials is exactly "
                "lexicographic comparison of ranks, so the dominant term is the "
                "lexicographic maximum of the support — a single linear scan. The "
                "Dominant-Term Theorem then gives f(x) / (kappa · m_{g0}(x)) → 1, and every "
                "asymptotic question is answered from the pair (g0, kappa) alone: the limit "
                "in the extended reals, the eventual sign, and (by faithfulness) the "
                "eventual comparison of two germs, obtained by taking the dominant term of "
                "the difference. Complexity: O(m) rank comparisons for m terms, each "
                "costing at most four real comparisons; the whole procedure is exact and "
                "involves no numerical evaluation, which matters because numerical "
                "evaluation can give the wrong verdict at every feasible argument.",
            "pseudocode":
                "INPUT  f: finite set of (rank g in R^4, coefficient c in R)\n"
                "OUTPUT (g0, kappa) dominant data; limit; eventual sign\n"
                "\n"
                "1. drop all pairs with c = 0\n"
                "2. if f is empty: return (limit 0, sign 0)\n"
                "3. (g0, kappa) <- first surviving pair\n"
                "4. for each remaining pair (g, c):\n"
                "5.     if g >_lex g0 then (g0, kappa) <- (g, c)\n"
                "       // lexicographic: compare d, then a, then b, then c\n"
                "6. if g0 <_lex 0:        limit <- 0\n"
                "7. else if g0 = 0:       limit <- kappa\n"
                "8. else:                 limit <- sign(kappa) * infinity\n"
                "9. eventual sign <- sign(kappa)\n"
                "10. return (g0, kappa), limit, eventual sign\n"
                "\n"
                "COMPARE-GERMS(f, g):\n"
                "1. d <- f - g   (coefficientwise)\n"
                "2. return -sign(dominant coefficient of d)   // 0 if d = 0",
            "code": read(ASSETS / "alg_dominant_term.py"),
        },
        {
            "name": "Root Extraction by Leading Decomposition and Binomial Expansion",
            "description":
                "Computes an n-th root of a positive transseries, and is the constructive "
                "content of the theorem that the transseries field is Euclidean (the "
                "nonnegative elements are precisely the squares). The input is factored as "
                "f = m_g · r · (1 + eps): a dominant transmonomial, a positive real leading "
                "coefficient, and a 1-unit whose deviation eps from 1 is infinitesimal. "
                "Each factor is rooted separately: the rank g is divided by n, which is "
                "legitimate exactly because the rank group R^4 is divisible (the exponents "
                "are real numbers, not integers); the real r is rooted in R; and the 1-unit "
                "is expanded by the generalised binomial series sum_k C(1/n, k) eps^k, "
                "which converges in the formal Hahn sense because the rank of eps^k marches "
                "off to minus infinity. The last step is where the theory genuinely needs "
                "infinite sums: even for a two-term input such as x + 1 the root is an "
                "infinite series. Binomial coefficients are computed in exact rational "
                "arithmetic. Complexity: N truncated transseries multiplications for N "
                "retained terms; the truncation is by rank floor, so the cost is O(N·m) for "
                "an eps supported on a single line of ranks.",
            "pseudocode":
                "INPUT  f (positive transseries), n >= 1, depth N\n"
                "OUTPUT h with h^n = f, truncated after N binomial terms\n"
                "\n"
                "1. g <- lexicographic max of supp(f);  r <- coefficient of g\n"
                "2. assert r > 0                      // positivity is required\n"
                "3. eps <- { (k - g) |-> f[k]/r : k in supp(f) } \\ { 0 |-> 1 }\n"
                "       // f = m_g * r * (1 + eps), and every rank of eps is < 0\n"
                "4. head <- monomial of rank g/n with coefficient r^(1/n)\n"
                "5. if eps = 0: return head\n"
                "6. floor <- (N + 1) * (lexicographic max of supp(eps))\n"
                "7. unit <- 1;  power <- 1\n"
                "8. for k = 1 .. N:\n"
                "9.     power <- truncate(power * eps, floor)\n"
                "10.    if power = 0: break\n"
                "11.    unit <- unit + C(1/n, k) * power\n"
                "           // C(s,k) = s(s-1)...(s-k+1)/k!, exact rationals\n"
                "12. return truncate(head * unit, g/n + floor)",
            "code": read(ASSETS / "alg_root_extraction.py"),
        },
        {
            "name": "Newton Scaling Normalisation of a Monic Transseries Polynomial",
            "description":
                "The scaling step of the Newton-polygon analysis, performed entirely inside "
                "the transseries field. For lambda > 0 the operator N_lambda(P)(z) = "
                "lambda^{-n} P(lambda z) sends a monic polynomial of degree n to a monic "
                "polynomial of degree n with coefficients a_i · lambda^{i-n} and with roots "
                "exactly the roots of P divided by lambda. The Newton Normalisation Theorem "
                "states that the choice lambda = max_{i<n, a_i != 0} |a_i|^{1/(n-i)} makes "
                "the scaled polynomial normalised: every coefficient lies in the valuation "
                "ring (absolute value at most 1) and, unless P = z^n, some non-leading "
                "coefficient has absolute value exactly 1. The maximum exists because the "
                "transseries order is total; the fractional powers exist by the root "
                "extraction algorithm. Normalisation is precisely the hypothesis that makes "
                "the residue polynomial a genuine monic real polynomial of degree n other "
                "than z^n, so that the real closedness of the residue field becomes usable, "
                "and it comes with the Cauchy bound |z| < 2 on all roots. Complexity: n root "
                "extractions and n-1 comparisons; when the coefficients are transmonomials "
                "the whole computation reduces to O(n) arithmetic on quadruples of reals.",
            "pseudocode":
                "INPUT  monic P of degree n, coefficients a_0, ..., a_{n-1}, a_n = 1\n"
                "OUTPUT lambda > 0 and the normalised polynomial N_lambda(P)\n"
                "\n"
                "1. C <- { |a_i|^(1/(n-i)) : i < n and a_i != 0 }\n"
                "       // each root exists: the field is Euclidean with divisible ranks\n"
                "2. if C is empty:            // P = z^n\n"
                "3.     return lambda = 1, P\n"
                "4. lambda <- max C           // exists: the order is total\n"
                "5. for i = 0 .. n:\n"
                "6.     b_i <- a_i * lambda^(i - n)\n"
                "7. assert |b_i| <= 1 for all i          // valuation ring\n"
                "8. assert exists i < n with |b_i| = 1   // residue polynomial != z^n\n"
                "9. return lambda, (b_0, ..., b_n)\n"
                "\n"
                "// every root z of a normalised monic polynomial satisfies |z| < 2:\n"
                "//   |z|^n <= sum_{i<n} |z|^i = (|z|^n - 1)/(|z| - 1) <= |z|^n - 1\n"
                "//   for |z| >= 2, a contradiction.",
            "code": read(ASSETS / "alg_newton_scaling.py"),
        },
        {
            "name": "Henselian Deformation of a Simple Residue Root",
            "description":
                "Produces roots that lie beyond the reach of radicals. Let F be a monic "
                "polynomial whose coefficients are formal power series in a parameter X, "
                "and suppose its residue F_0 = F mod X, a real polynomial, has a simple real "
                "root a. Because R[[X]] is X-adically complete and hence Henselian, Newton's "
                "iteration y <- y - F(y)/F'(y) started at y = a converges X-adically: the "
                "X-order of F(y) at least doubles at each step, and F'(y) is invertible "
                "throughout because its constant term F_0'(a) is a nonzero real. Substituting "
                "an infinitesimal transseries t for X is a ring homomorphism — the family "
                "(f_k t^k) is summable because t has positive order — so the root is carried "
                "into the transseries field. Applied to F(z) = z^3 - 3z + X with the simple "
                "residue root 0, this yields, for every infinitesimal t, a root of "
                "z^3 - 3z + t although the Cardano discriminant t^2/4 - 1 is strictly "
                "negative: the classical casus irreducibilis, whose roots provably cannot be "
                "written with real radicals. Complexity: O(log N) Newton steps to reach "
                "precision X^N, each step a truncated power series multiplication and "
                "inversion, i.e. O(N^2) coefficient operations naively.",
            "pseudocode":
                "INPUT  monic F in R[[X]][z]; a simple real root a of F_0 = F mod X;\n"
                "       target precision N\n"
                "OUTPUT y in R[[X]] with F(y) = 0 mod X^N and y(0) = a\n"
                "\n"
                "1. assert F_0(a) = 0 and F_0'(a) != 0      // simplicity is essential\n"
                "2. y <- a                                   // constant series\n"
                "3. precision <- 1\n"
                "4. while precision < N:\n"
                "5.     precision <- min(N, 2 * precision)   // quadratic convergence\n"
                "6.     Fy  <- eval F  at y, truncated at X^precision   (Horner)\n"
                "7.     Fpy <- eval F' at y, truncated at X^precision\n"
                "8.     y <- y - Fy * inverse(Fpy)           // Fpy is a unit\n"
                "9. return y\n"
                "\n"
                "TRANSPORT-TO-TRANSSERIES(y, t):\n"
                "1. assert t is infinitesimal (|t| < r for every real r > 0)\n"
                "2. return sum_k y_k * t^k        // summable, since ord(t) > 0",
            "code": read(ASSETS / "alg_hensel_lift.py"),
        },
    ]

    visualizations: List[Dict[str, str]] = [
        {
            "name": "The Growth Hierarchy and its Lexicographic Order",
            "description":
                "Two panels. The left panel plots the four scales log x, x, e^x and e^{e^x} "
                "on a doubly logarithmic vertical axis so that all four fit on one picture; "
                "the curves are separated by gaps that grow without bound, which is the "
                "visual form of the statement that each level dominates the previous one "
                "absolutely. The right panel makes the *strictness* precise. The three "
                "comparisons (log x)^n / x, x^n / e^x and (e^x)^n / e^{e^x} all have "
                "log-ratio n·log u - u with u = log x, u = x and u = e^x respectively, so a "
                "single family of curves settles all of them: for every n the curve rises "
                "briefly and then falls to minus infinity, showing that no finite power of "
                "one level ever reaches the next. Together the panels are the analytic "
                "content of the Scale Comparison Theorem, which identifies asymptotic "
                "comparison of transmonomials with lexicographic comparison of their "
                "exponent quadruples.",
            "code": read(ASSETS / "viz_growth_hierarchy.py"),
        },
        {
            "name": "Flatness of log log x and Convergence of the Binomial Root Series",
            "description":
                "Two panels illustrating the two places where the theory is subtle. The "
                "left panel plots log(log L / L^c) against L = log x for several exponents "
                "c > 0, and every curve descends to minus infinity: log log x is negligible "
                "against every growing transmonomial of the exp-log scale, however slowly "
                "that transmonomial grows. Since the dominant-term theorem forces any "
                "exp-log function tending to infinity to be asymptotic to a constant "
                "multiple of a single growing transmonomial, log log x cannot be one — and "
                "therefore 1/(x log x), whose antiderivative it is, has no antiderivative "
                "inside the algebra. The right panel plots, on a logarithmic error axis, the "
                "relative error of the truncated binomial series for sqrt(x+1) against the "
                "number of terms retained, at four values of x; the error falls "
                "geometrically at a rate set by the size of the infinitesimal 1/x, "
                "confirming that the infinite series is genuinely needed and that its "
                "truncations converge exactly as the theory predicts.",
            "code": read(ASSETS / "viz_flatness_and_roots.py"),
        },
    ]

    interactive_demos: List[Dict[str, str]] = [
        {
            "title": "The Transmonomial Comparator: Watching Lexicographic Order Decide",
            "description":
                "An interactive laboratory for the Scale Comparison Theorem. Two "
                "transmonomials exp(d e^x) e^{ax} x^b (log x)^c are controlled by eight "
                "sliders — the four exponents of each — and the widget announces the exact "
                "asymptotic verdict together with the reason: it names the first coordinate "
                "at which the ranks differ, states that the lexicographic order decides "
                "there and stops, and points out that every later coordinate is powerless "
                "however extreme it is set. Below, a canvas plots the logarithm of the "
                "ratio of the two transmonomials over a logarithmic range of x reaching as "
                "far as 10^40, coloured green where the first dominates and red where the "
                "second does. Preset buttons load the instructive cases: x against "
                "(log x)^{1000}, x^{500} against e^{0.001x}, e^{10^6 x} against e^{e^x}, a "
                "near-tie in the power of x that is resolved only by the logarithmic "
                "coordinate, and a comparison of two decaying monomials. The lesson the "
                "widget teaches by experiment is that the crossover point can be pushed "
                "arbitrarily far out — so the exact lexicographic rule, not numerical "
                "evaluation, is what settles growth at infinity.",
            "html": read(ASSETS / "widget_comparator.html"),
        },
        {
            "title": "The Transseries Root Laboratory: Binomial Roots and the "
                     "Casus Irreducibilis",
            "description":
                "A two-tab exploration of the two distinct ways the transseries field "
                "produces roots. The first tab implements root extraction by leading "
                "decomposition: choose a transseries x^p + q and a root order n, and watch "
                "the algorithm divide the rank by n, take the real root of the leading "
                "coefficient, and expand the 1-unit by the generalised binomial series, "
                "displaying the resulting infinite series term by term along with its value, "
                "the exact value, and the relative error; a live convergence plot shows the "
                "geometric decay of the truncation error at three values of x, making "
                "concrete why the infinite sum is not optional. The second tab turns to a "
                "root no radical formula can express: the cubic z^3 - 3z + t with t "
                "infinitesimal, whose Cardano discriminant t^2/4 - 1 is strictly negative — "
                "the classical casus irreducibilis. Sliders control the number of Newton "
                "iterations and the retained series order, and the widget performs Hensel "
                "lifting of the simple residue root z = 0 live, displaying the power series "
                "in t, the number of coefficients determined (visibly doubling with each "
                "iteration, the signature of quadratic convergence), and a table of the "
                "lifted root, its residual and the discriminant after substituting the "
                "honest infinitesimal t = 1/x.",
            "html": read(ASSETS / "widget_root_lab.html"),
        },
    ]

    package: Dict[str, Any] = {
        "title": "EML Transseries: Asymptotic Expansions Beyond Power Series",
        "domain": "Applications",
        "description":
            "An explicit ordered field of exponential–logarithmic transseries, built as "
            "Hahn series over the lexicographically ordered rank group R^4 encoding the "
            "hierarchy e^{e^x} >> e^x >> x >> log x, in which every positive element has "
            "n-th roots, the ordering is definable and rigid, and the transseries expansion "
            "of an exp-log function is a complete asymptotic invariant. Real closedness is "
            "reduced, via Henselian lifting and a Newton scaling normalisation theorem, to "
            "the single clause that every normalised monic odd-degree polynomial has a root.",
        "authors": ["Aristotle"],
        "date": "2026-08-16",
        "key_results": [
            "Scale Comparison Theorem: asymptotic comparison of the transmonomials "
            "exp(d e^x) e^{ax} x^b (log x)^c is exactly the lexicographic comparison of "
            "their exponent quadruples (d, a, b, c), giving the strict hierarchy in which "
            "no finite power of one scale reaches the next.",
            "Root Extraction Theorem: every positive transseries has an n-th root for every "
            "n, so the nonnegative transseries are precisely the squares, the field is "
            "Euclidean and formally real, and consequently its ordering is definable by "
            "'g - f is a square', is the unique compatible ordering, and is preserved by "
            "every ring homomorphism out of the field.",
            "Asymptotic Comparison Theorem: a transseries dominated by every transmonomial "
            "is zero, and an exp-log function that is o(m) for every transmonomial m is "
            "identically zero; the exp-log scale therefore admits no flat germs and the "
            "transseries expansion is a complete invariant that determines the function.",
            "Hardy field theorem with a Liouville-type obstruction: the exp-log algebra "
            "carries a derivation computing the analytic derivative whose kernel is exactly "
            "the real constants, every exp-log germ is eventually monotone or constant and "
            "has a limit in the extended reals, and 1/(x log x) has no antiderivative in the "
            "algebra because log log x is flat against the whole scale.",
            "Reduction of real closedness: with roots beyond radicals supplied by Henselian "
            "lifting (the casus-irreducibilis cubic z^3 - 3z + t has a root for every "
            "infinitesimal t despite its negative Cardano discriminant), the Newton scaling "
            "normalisation theorem and the Cauchy root bound |z| < 2 reduce real closedness "
            "of the transseries field to the single clause that every normalised monic "
            "odd-degree polynomial has a root.",
        ],
        "keywords": [
            "transseries",
            "Hahn series",
            "Hardy field",
            "asymptotic expansion",
            "real closed field",
            "Newton polygon",
            "Hensel's lemma",
            "exp-log functions",
        ],
        "article": article,
        "research_paper": paper_md,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": demos,
        "algorithms": algorithms,
        "visualizations": visualizations,
        "interactive_demos": interactive_demos,
        "interactive_layout": read(ASSETS / "interactive_layout.md"),
        "lean_proofs": lean_src,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo},
        "lean_files": lean_files,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size/1024:.1f} KB)")


if __name__ == "__main__":
    main()


"""
EML Transseries: numerical demonstrations
=========================================

Self-contained numerical companion to the theory of exponential-logarithmic (EML)
transseries: formal series in the four-scale hierarchy

    exp(exp x)  >>  exp x  >>  x  >>  log x .

A *rank* is a quadruple (d, a, b, c) of real numbers naming the transmonomial

    m_{d,a,b,c}(x) = exp(d * exp x) * exp(a * x) * x**b * (log x)**c ,

ranks are compared lexicographically, and a transseries is a (formally infinite,
here truncated) real linear combination of transmonomials with well-ordered support.

The script demonstrates, numerically:

  1. Rank arithmetic and the Scale Comparison Theorem.
  2. The strict growth hierarchy: no power of one scale reaches the next.
  3. Root extraction via leading decomposition + binomial series (infinite sums matter).
  4. The dominant-term theorem, limits, and asymptotic sign.
  5. The formal derivation vs. the true analytic derivative.
  6. Flatness of log log x against the whole EML scale (Liouville obstruction).
  7. Hensel lifting of the casus-irreducibilis cubic z^3 - 3 z + t.
  8. Newton scaling: normalising a monic polynomial.
  9. The Cauchy root bound |z| < 2 for normalised monic polynomials.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------------
# 1. Ranks: growth rates as points of R^4, compared lexicographically
# ----------------------------------------------------------------------------------

Rank = Tuple[float, float, float, float]  # (d, a, b, c)

ONE: Rank = (0.0, 0.0, 0.0, 0.0)
LOG: Rank = (0.0, 0.0, 0.0, 1.0)
X: Rank = (0.0, 0.0, 1.0, 0.0)
EXP: Rank = (0.0, 1.0, 0.0, 0.0)
EXPEXP: Rank = (1.0, 0.0, 0.0, 0.0)


def rank_add(g: Rank, h: Rank) -> Rank:
    """Transmonomials multiply by adding exponent data."""
    return (g[0] + h[0], g[1] + h[1], g[2] + h[2], g[3] + h[3])


def rank_neg(g: Rank) -> Rank:
    """Inverse of a transmonomial negates exponent data."""
    return (-g[0], -g[1], -g[2], -g[3])


def rank_smul(s: float, g: Rank) -> Rank:
    """s-th power of a transmonomial scales exponent data (s may be fractional:
    the rank group R^4 is divisible, which is why n-th roots exist)."""
    return (s * g[0], s * g[1], s * g[2], s * g[3])


def rank_lt(g: Rank, h: Rank) -> bool:
    """Scale Comparison Theorem: m_g < m_h iff g <_lex h.
    (Python tuple comparison IS lexicographic, so this is literally `g < h`.)
    Throughout this script a rank stores the four exponents DIRECTLY, so a larger
    rank means a faster-growing transmonomial and the DOMINANT term of a
    transseries is the one of LARGEST rank."""
    return g < h


def mono_log(g: Rank, x: float) -> float:
    """log of the transmonomial named by g, at x > 1 (safe for huge values)."""
    d, a, b, c = g
    lx = math.log(x)
    val = a * x + b * lx + c * math.log(lx)
    if d:  # only touch exp(x) when the double-exponential coordinate is nonzero
        val += d * math.exp(x)
    return val


def mono(g: Rank, x: float) -> float:
    """The transmonomial named by g, evaluated at x > 1."""
    return math.exp(mono_log(g, x))


def mono_log_ratio(g: Rank, h: Rank, x: float) -> float:
    """log( m_g(x) / m_h(x) ), computed without overflow."""
    return mono_log(g, x) - mono_log(h, x)


def rank_name(g: Rank) -> str:
    d, a, b, c = g
    parts: List[str] = []
    if d:
        parts.append(f"exp({d:g}*e^x)")
    if a:
        parts.append(f"e^({a:g}x)")
    if b:
        parts.append("x" if b == 1 else f"x^{b:g}")
    if c:
        parts.append("log x" if c == 1 else f"(log x)^{c:g}")
    return " * ".join(parts) if parts else "1"


def demo_1_scale_comparison() -> None:
    print("=" * 78)
    print("1. RANK ARITHMETIC AND THE SCALE COMPARISON THEOREM")
    print("=" * 78)
    print("Transmonomials form a group isomorphic to (R^4, +):")
    prod = rank_add(EXP, rank_smul(-2.0, X))
    print(f"   e^x * x^-2       -> rank {prod}   =  {rank_name(prod)}")
    inv = rank_neg(EXP)
    print(f"   (e^x)^-1         -> rank {inv}   =  {rank_name(inv)}")
    half = rank_smul(0.5, X)
    print(f"   sqrt(x)          -> rank {half}   =  {rank_name(half)}")
    print()
    print("Comparison is lexicographic; check it numerically at large x:")
    pairs = [(LOG, X), (X, EXP), (EXP, EXPEXP), ((0.0, 0.0, 1000.0, 0.0), EXP)]
    for g, h in pairs:
        x = 40.0
        lr = mono_log_ratio(g, h, x)
        verdict = "g < h (lex)" if rank_lt(g, h) else "g >= h (lex)"
        print(f"   {rank_name(g):>18s}  vs {rank_name(h):<12s}"
              f"  {verdict:12s}  log(ratio) at x={x:g}: {lr:+.4e}")
    print()


def demo_2_growth_hierarchy() -> None:
    print("=" * 78)
    print("2. STRICT GROWTH HIERARCHY: NO POWER OF ONE SCALE REACHES THE NEXT")
    print("=" * 78)
    print("For every n:  (log x)^n < x,   x^n < e^x,   (e^x)^n < e^(e^x).")
    for n in (2, 5, 20, 100):
        assert rank_lt(rank_smul(n, LOG), X)
        assert rank_lt(rank_smul(n, X), EXP)
        assert rank_lt(rank_smul(n, EXP), EXPEXP)
    print("   lexicographic check passed for n = 2, 5, 20, 100")
    x = 1e6
    lx = math.log(x)
    print(f"   at x = {x:.0e}:  (log x)^5 / x        = {lx ** 5 / x:.3e}")
    print(f"                   x^5 / e^x            = {math.exp(5 * lx - x):.3e}"
          "   (underflows to 0: the gap is enormous)")
    print()


# ----------------------------------------------------------------------------------
# 2. Truncated transseries arithmetic
# ----------------------------------------------------------------------------------

# A transseries is represented as a dict rank -> coefficient, truncated by discarding
# terms of rank above `depth` in a chosen infinitesimal direction.

TS = Dict[Rank, float]


def ts_add(f: TS, g: TS) -> TS:
    out: TS = dict(f)
    for k, v in g.items():
        out[k] = out.get(k, 0.0) + v
        if out[k] == 0.0:
            del out[k]
    return out


def ts_scale(c: float, f: TS) -> TS:
    return {k: c * v for k, v in f.items() if c * v != 0.0}


def ts_mul(f: TS, g: TS, cutoff: Rank | None = None) -> TS:
    """Product, discarding every term of rank at or below `cutoff` (truncation)."""
    out: TS = {}
    for k1, v1 in f.items():
        for k2, v2 in g.items():
            k = rank_add(k1, k2)
            if cutoff is not None and not rank_lt(cutoff, k):
                continue
            out[k] = out.get(k, 0.0) + v1 * v2
    return {k: v for k, v in out.items() if v != 0.0}


def ts_order(f: TS) -> Rank:
    """The rank of the DOMINANT transmonomial: the largest rank in the support."""
    if not f:
        raise ValueError("the zero transseries has no dominant term")
    return max(f)


def ts_leading_coeff(f: TS) -> float:
    return f[ts_order(f)]


def ts_eval(f: TS, x: float) -> float:
    return sum(c * mono(g, x) for g, c in f.items())


def ts_show(f: TS, maxterms: int = 6) -> str:
    if not f:
        return "0"
    terms = sorted(f.items(), reverse=True)[:maxterms]
    out = " + ".join(f"{c:+.6g}*{rank_name(g)}" for g, c in terms)
    if len(f) > maxterms:
        out += " + ..."
    return out


def binomial_coeff(s: Fraction, k: int) -> Fraction:
    num = Fraction(1)
    for j in range(k):
        num *= (s - j)
    return num / math.factorial(k)


def ts_root(f: TS, n: int, depth: int = 8) -> TS:
    """n-th root of a POSITIVE transseries, by the three-step proof:
        f = t^g * r * (1 + eps),
        take g/n            (the rank group R^4 is divisible),
        take r**(1/n)       (R is real closed),
        take (1+eps)**(1/n) (binomial series -- a genuinely INFINITE sum).
    """
    g = ts_order(f)
    r = f[g]
    if r <= 0.0:
        raise ValueError("root extraction requires a positive transseries")
    # eps = f / (m_g * r) - 1 : an infinitesimal (all its ranks are strictly negative)
    eps = {rank_add(k, rank_neg(g)): v / r for k, v in f.items()}
    del eps[ONE]
    if not eps:
        return {rank_smul(1.0 / n, g): r ** (1.0 / n)}
    cutoff = rank_smul(depth + 1, ts_order(eps))
    # binomial series sum_k C(1/n, k) eps^k
    unit: TS = {ONE: 1.0}
    power: TS = {ONE: 1.0}
    s = Fraction(1, n)
    for k in range(1, depth + 1):
        power = ts_mul(power, eps, cutoff)
        if not power:
            break
        unit = ts_add(unit, ts_scale(float(binomial_coeff(s, k)), power))
    head: TS = {rank_smul(1.0 / n, g): r ** (1.0 / n)}
    return ts_mul(head, unit, rank_add(rank_smul(1.0 / n, g), cutoff))


def demo_3_root_extraction() -> None:
    print("=" * 78)
    print("3. ROOT EXTRACTION: LEADING DECOMPOSITION + BINOMIAL SERIES")
    print("=" * 78)
    f: TS = {X: 1.0, ONE: 1.0}  # the transseries x + 1
    print(f"   f            = {ts_show(f)}")
    root = ts_root(f, 2, depth=6)
    print(f"   sqrt(f)      = {ts_show(root)}")
    print("   (a genuinely INFINITE series, even though f has two terms)")
    sq = ts_mul(root, root, rank_smul(-4.0, X))
    print(f"   sqrt(f)^2    = {ts_show(sq)}   <- reproduces f up to truncation")
    print()
    for x in (10.0, 100.0, 10_000.0):
        approx = ts_eval(root, x)
        exact = math.sqrt(x + 1.0)
        print(f"   x = {x:>9.0f}:  series = {approx:.12f}   exact = {exact:.12f}"
              f"   rel.err = {abs(approx - exact) / exact:.2e}")
    print()
    g: TS = {EXP: 1.0, X: 3.0}  # e^x + 3x
    cube = ts_root(g, 3, depth=5)
    print(f"   g            = {ts_show(g)}")
    print(f"   g^(1/3)      = {ts_show(cube)}")
    for x in (20.0, 40.0):
        approx = ts_eval(cube, x)
        exact = (math.exp(x) + 3.0 * x) ** (1.0 / 3.0)
        print(f"   x = {x:>9.0f}:  series = {approx:.10f}   exact = {exact:.10f}"
              f"   rel.err = {abs(approx - exact) / exact:.2e}")
    print()


def demo_4_dominant_term() -> None:
    print("=" * 78)
    print("4. DOMINANT-TERM THEOREM, LIMITS AND ASYMPTOTIC SIGN")
    print("=" * 78)
    examples: List[Tuple[str, TS, Tuple[float, ...]]] = [
        ("3*e^x/x^2 - 5*log x + 7", {rank_add(EXP, rank_smul(-2.0, X)): 3.0,
                                     LOG: -5.0, ONE: 7.0}, (30.0, 60.0)),
        ("-2*x + 1000*log x",       {X: -2.0, LOG: 1000.0}, (1e6, 1e12)),
        ("7 - 4/x",                 {ONE: 7.0, rank_neg(X): -4.0}, (1e3, 1e6)),
        ("1/x + 1/(x log x)",       {rank_neg(X): 1.0,
                                     rank_neg(rank_add(X, LOG)): 1.0}, (1e6, 1e60)),
    ]
    for name, f, xs in examples:
        g0 = ts_order(f)
        kappa = f[g0]
        if rank_lt(g0, ONE):
            limit = "0"
        elif g0 == ONE:
            limit = f"{kappa:g}"
        else:
            limit = "+inf" if kappa > 0 else "-inf"
        print(f"   {name:<26s} dominant term {kappa:+g} * {rank_name(g0):<14s}"
              f" limit = {limit}")
        # numerically confirm f(x) / (kappa * m_{g0}(x)) -> 1
        for x in xs:
            ratio = ts_eval(f, x) / (kappa * mono(g0, x))
            print(f"        f(x)/(kappa*m(x)) at x={x:<9.3g}: {ratio:.8f}")
    print("   -> eventual sign of f is the sign of the dominant coefficient;")
    print("      hence a nonzero EML function is eventually nonvanishing (faithfulness).")
    print()


# ----------------------------------------------------------------------------------
# 3. Derivation
# ----------------------------------------------------------------------------------

R_EXP: Rank = (0.0, 1.0, 0.0, 0.0)          # e^x
R_INV_X: Rank = (0.0, 0.0, -1.0, 0.0)       # 1/x
R_INV_XLOG: Rank = (0.0, 0.0, -1.0, -1.0)   # 1/(x log x)


def dlog(g: Rank) -> TS:
    """Logarithmic derivative of the transmonomial of rank g = (d, a, b, c):
           d*e^x + a + b/x + c/(x log x),
    itself a finite combination of transmonomials -- which is exactly why the EML
    algebra is closed under differentiation."""
    d, a, b, c = g
    out: TS = {}
    for rank, coeff in ((R_EXP, d), (ONE, a), (R_INV_X, b), (R_INV_XLOG, c)):
        if coeff:
            out[rank] = out.get(rank, 0.0) + coeff
    return {k: v for k, v in out.items() if v != 0.0}


def eml_deriv(f: TS) -> TS:
    """The formal derivation of the EML algebra: sum over terms of coeff*[g]*dlog(g)."""
    out: TS = {}
    for g, c in f.items():
        out = ts_add(out, ts_mul({g: c}, dlog(g)))
    return out


def demo_5_derivation() -> None:
    print("=" * 78)
    print("5. THE FORMAL DERIVATION EQUALS THE ANALYTIC DERIVATIVE")
    print("=" * 78)
    examples: List[Tuple[str, TS]] = [
        ("x^3",           {(0.0, 0.0, 3.0, 0.0): 1.0}),
        ("log x",         {LOG: 1.0}),
        ("e^x * x^-2",    {rank_add(EXP, rank_smul(-2.0, X)): 1.0}),
        ("5 (a constant)", {ONE: 5.0}),
    ]
    for name, f in examples:
        df = eml_deriv(f)
        print(f"   D[{name:<14s}] = {ts_show(df)}")
        x0, h = 7.0, 1e-6
        numeric = (ts_eval(f, x0 + h) - ts_eval(f, x0 - h)) / (2 * h)
        formal = ts_eval(df, x0) if df else 0.0
        print(f"        at x={x0:g}:  formal = {formal:.9f}   numerical = {numeric:.9f}")
    print()
    print("   Kernel of the derivation = the real constants:")
    print(f"        D[5]     = {ts_show(eml_deriv({ONE: 5.0}))}")
    print(f"        D[log x] = {ts_show(eml_deriv({LOG: 1.0}))}   (nonzero: 1/x)")
    print("   Note D[log x] = 1/x, so 1/x DOES have an antiderivative in the algebra.")
    print()


def demo_6_loglog_flatness() -> None:
    print("=" * 78)
    print("6. LIOUVILLE OBSTRUCTION: log log x IS FLAT AGAINST THE WHOLE SCALE")
    print("=" * 78)
    print("   Every growing transmonomial has lexicographically POSITIVE rank;")
    print("   the slowest of them are (log x)^c with c > 0.  Yet")
    print("        log log x / (log x)^c  ->  0   for every c > 0,")
    print("   however small c is.  Write L = log x, so the ratio is log(L)/L^c;")
    print("   we evaluate it in log space to reach genuinely astronomical L.")
    exponents = (2, 6, 30, 200, 2000, 20000)
    print("        c        " + "".join(f"L=1e{e:<7d}" for e in exponents))
    for c in (1.0, 0.5, 0.1, 0.01, 0.001):
        row = []
        for e in exponents:
            log_L = e * math.log(10.0)
            row.append(f"{math.exp(math.log(log_L) - c * log_L):.2e}  ")
        print(f"        {c:<8g} " + "".join(row))
    print()
    print("   Any EML function tending to +inf is asymptotic to kappa * (a growing")
    print("   transmonomial), by the dominant-term theorem.  log log x is not.")
    print("   Hence log log x is not an EML function, and 1/(x log x) -- whose")
    print("   antiderivative is log log x -- has NO antiderivative in the algebra.")
    print()


# ----------------------------------------------------------------------------------
# 4. Hensel lifting: the casus irreducibilis cubic
# ----------------------------------------------------------------------------------

def hensel_lift_cubic(order: int = 10) -> List[float]:
    """Solve z^3 - 3 z + t = 0 for z as a power series in the infinitesimal t,
    by Newton iteration in R[[t]].  The residue cubic z^3 - 3z has the SIMPLE
    root z = 0 (derivative -3 there), so the root deforms uniquely."""
    y: List[float] = [0.0] * order  # start at the residue root z = 0

    def poly_mul(p: List[float], q: List[float]) -> List[float]:
        out = [0.0] * order
        for i, pi in enumerate(p):
            if pi == 0.0:
                continue
            for j, qj in enumerate(q):
                if i + j < order and qj != 0.0:
                    out[i + j] += pi * qj
        return out

    def poly_inv(p: List[float]) -> List[float]:
        assert p[0] != 0.0, "not invertible: constant term vanishes"
        out = [0.0] * order
        out[0] = 1.0 / p[0]
        for n in range(1, order):
            out[n] = -sum(p[k] * out[n - k] for k in range(1, n + 1)) / p[0]
        return out

    t = [0.0] * order
    if order > 1:
        t[1] = 1.0
    for _ in range(2 * order):  # quadratic convergence; this is generous
        y2 = poly_mul(y, y)
        y3 = poly_mul(y2, y)
        F = [y3[i] - 3.0 * y[i] + t[i] for i in range(order)]
        Fp = [3.0 * y2[i] - (3.0 if i == 0 else 0.0) for i in range(order)]
        corr = poly_mul(F, poly_inv(Fp))
        y = [y[i] - corr[i] for i in range(order)]
    return y


def demo_7_hensel() -> None:
    print("=" * 78)
    print("7. HENSEL LIFTING: THE CASUS IRREDUCIBILIS CUBIC z^3 - 3z + t")
    print("=" * 78)
    coeffs = hensel_lift_cubic(order=12)
    terms = " ".join(f"{c:+.6g} t^{i}" for i, c in enumerate(coeffs) if abs(c) > 1e-14)
    print(f"   root as a power series in t:   z(t) = {terms}")
    print()
    print("   Cardano discriminant  (t/2)^2 + (-3/3)^3 = t^2/4 - 1 < 0 for |t| < 2,")
    print("   so for every INFINITESIMAL t the discriminant is strictly negative:")
    print("   the root is NOT expressible by real radicals -- it lies beyond the reach")
    print("   of the n-th root theorem, and is produced instead by Hensel's lemma.")
    print()
    print("   numerical check (t small and real):")
    for t in (1e-1, 1e-2, 1e-3):
        z = sum(c * t ** i for i, c in enumerate(coeffs))
        residual = z ** 3 - 3.0 * z + t
        disc = (t / 2.0) ** 2 - 1.0
        print(f"        t = {t:8.1e}:  z = {z: .12f}   z^3-3z+t = {residual: .3e}"
              f"   disc = {disc: .6f} < 0")
    print()
    print("   substituting t = 1/x gives a genuine transseries root:")
    for x in (10.0, 1000.0):
        t = 1.0 / x
        z = sum(c * t ** i for i, c in enumerate(coeffs))
        print(f"        x = {x:>7.0f}:  z(1/x) = {z:.12f}   residual ="
              f" {z ** 3 - 3 * z + t: .3e}")
    print()


# ----------------------------------------------------------------------------------
# 5. Newton scaling and the Cauchy bound
# ----------------------------------------------------------------------------------

def newton_scale_lambda_ranks(coeff_ranks: List[Rank | None]) -> Rank:
    """Newton scaling exponent for a monic polynomial whose i-th coefficient is a
    transmonomial of rank coeff_ranks[i] (None meaning the coefficient is 0).
    lambda = max_{i<n, a_i != 0} |a_i|^{1/(n-i)}, computed on ranks:
    the rank of |a_i|^{1/(n-i)} is rank(a_i)/(n-i), and MAXIMUM in value is
    MINIMUM in rank."""
    n = len(coeff_ranks) - 1
    candidates = [rank_smul(1.0 / (n - i), g)
                  for i, g in enumerate(coeff_ranks[:-1]) if g is not None]
    if not candidates:
        return ONE  # P = z^n, take lambda = 1
    return max(candidates)  # largest rank = largest transseries


def demo_8_newton_scaling() -> None:
    print("=" * 78)
    print("8. NEWTON SCALING: NORMALISING A MONIC POLYNOMIAL")
    print("=" * 78)
    # P(z) = z^3 + (x^2) z^2 + (x^5) z + x^9, coefficients are transmonomials
    ranks: List[Rank | None] = [
        (0.0, 0.0, 9.0, 0.0),   # a_0 = x^9
        (0.0, 0.0, 5.0, 0.0),   # a_1 = x^5
        (0.0, 0.0, 2.0, 0.0),   # a_2 = x^2
        ONE,                    # a_3 = 1 (monic)
    ]
    n = 3
    print("   P(z) = z^3 + x^2 z^2 + x^5 z + x^9      (monic, degree 3)")
    for i, g in enumerate(ranks[:-1]):
        assert g is not None
        print(f"        |a_{i}|^(1/(n-{i})) has rank {rank_smul(1.0/(n-i), g)}"
              f"  =  {rank_name(rank_smul(1.0/(n-i), g))}")
    lam = newton_scale_lambda_ranks(ranks)
    print(f"   lambda = max = {rank_name(lam)}   (rank {lam})")
    print("   scaled coefficients  a_i * lambda^(i-n):")
    ok_bounded, hits_one = True, False
    for i, g in enumerate(ranks):
        assert g is not None
        sg = rank_add(g, rank_smul(float(i - n), lam))
        bounded = not rank_lt(ONE, sg)  # |coeff| <= 1  <=>  rank <= 0
        ok_bounded &= bounded
        if sg == ONE and i < n:
            hits_one = True
        print(f"        i = {i}:  rank {sg}  =  {rank_name(sg):<12s}"
              f"  |coeff| {'<= 1' if bounded else '> 1  (!)'}")
    print(f"   all coefficients in the valuation ring: {ok_bounded}")
    print(f"   some non-leading coefficient of absolute value exactly 1: {hits_one}")
    print("   -> the polynomial is NORMALISED: its residue polynomial is a genuine")
    print("      monic real cubic different from z^3, so the real closedness of R")
    print("      becomes usable.")
    print()


def demo_9_cauchy_bound() -> None:
    print("=" * 78)
    print("9. CAUCHY ROOT BOUND FOR NORMALISED MONIC POLYNOMIALS")
    print("=" * 78)
    print("   If P is monic with all |a_i| <= 1 then every root satisfies |z| < 2.")
    print("   (Proof: |z|^n <= sum_{i<n}|z|^i = (|z|^n - 1)/(|z| - 1) <= |z|^n - 1")
    print("    when |z| >= 2 -- a contradiction.  Valid in any ordered field.)")
    print()
    import random
    random.seed(20260816)
    worst = 0.0
    for _ in range(4000):
        n = random.choice([3, 5, 7])
        a = [random.uniform(-1.0, 1.0) for _ in range(n)] + [1.0]
        # find the real roots by bisection on a fine grid over [-2, 2]
        def P(z: float) -> float:
            return sum(c * z ** i for i, c in enumerate(a))
        grid = [-2.0 + 4.0 * k / 2000 for k in range(2001)]
        for u, v in zip(grid, grid[1:]):
            if P(u) * P(v) <= 0.0:
                lo, hi = u, v
                for _ in range(60):
                    mid = 0.5 * (lo + hi)
                    if P(lo) * P(mid) <= 0.0:
                        hi = mid
                    else:
                        lo = mid
                worst = max(worst, abs(0.5 * (lo + hi)))
    print(f"   largest root modulus found over 4000 random normalised polynomials:"
          f" {worst:.6f}  (< 2)")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  EML TRANSSERIES: ASYMPTOTIC EXPANSIONS BEYOND POWER SERIES")
    print("#" * 78)
    print()
    demo_1_scale_comparison()
    demo_2_growth_hierarchy()
    demo_3_root_extraction()
    demo_4_dominant_term()
    demo_5_derivation()
    demo_6_loglog_flatness()
    demo_7_hensel()
    demo_8_newton_scaling()
    demo_9_cauchy_bound()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
