"""
Fork channels: exact single-bit leakage of AND / OR / XOR / split-count readouts.

This script is a self-contained numerical companion to the theory of *fork
channels*.  A fork is a source of (n+1) independent Bernoulli(p) bits
x_0, ..., x_n observed only through one scalar readout F.  The leakage of the
readout about the designated bit x_0 is the squared Pearson correlation

    L(F) = Cov(x_0, F)^2 / (Var(x_0) * Var(F)).

Everything is computed in EXACT rational arithmetic (fractions.Fraction), so no
floating-point noise and no unnormalised-weight pathology can enter.

Demonstrated results
--------------------
1. Channel collapse:  A = Phi(p, n),  g = Phi(1-p, n),  X = Phi((1-2p)^2, n),
   Is = Phi(1, n) = 1/(n+1),  where  Phi(t, n) = t^n / (1 + t + ... + t^n).
   Verified against brute-force enumeration of all 2^(n+1) bit patterns.
2. Strict monotonicity of Phi in t, hence size-free orderings.
3. Refutation of the "AND overtakes XOR at n = 8" crossover.
4. Refutation of "X/g -> 2"; the trichotomy about the critical bias p = 3/4.
5. The exact 25-bit table at p = 1/3.
6. Product universality: leakage of prod_i c(x_i) is Phi(m^2/s, n).
7. Symmetric optimality: every permutation-invariant readout leaks <= 1/(n+1).
8. Total-leakage sum rule: sum_i corrSq(x_i, F) <= 1, saturated by the count.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple

Bits = Tuple[int, ...]
Readout = Callable[[Bits], Fraction]


# ----------------------------------------------------------------------------
# The exact fork functional
# ----------------------------------------------------------------------------

def patterns(n_bits: int) -> List[Bits]:
    """All bit patterns of length ``n_bits``."""
    return [tuple(t) for t in product((0, 1), repeat=n_bits)]


def weight(p: Fraction, x: Bits) -> Fraction:
    """Product weight of the pattern ``x`` under independent Bernoulli(p) bits."""
    w = Fraction(1)
    for b in x:
        w *= p if b == 1 else (1 - p)
    return w


def expectation(p: Fraction, f: Readout, n_bits: int) -> Fraction:
    """Exact expectation of the readout ``f`` over an ``n_bits``-bit fork."""
    return sum((weight(p, x) * f(x) for x in patterns(n_bits)), Fraction(0))


def covariance(p: Fraction, f: Readout, g: Readout, n_bits: int) -> Fraction:
    """Exact covariance Cov(f, g)."""
    ef = expectation(p, f, n_bits)
    eg = expectation(p, g, n_bits)
    efg = expectation(p, lambda x: f(x) * g(x), n_bits)
    return efg - ef * eg


def variance(p: Fraction, f: Readout, n_bits: int) -> Fraction:
    """Exact variance Var(f)."""
    return covariance(p, f, f, n_bits)


def corr_sq(p: Fraction, f: Readout, g: Readout, n_bits: int) -> Fraction:
    """Exact squared Pearson correlation of two readouts."""
    vf = variance(p, f, n_bits)
    vg = variance(p, g, n_bits)
    if vf == 0 or vg == 0:
        return Fraction(0)
    return covariance(p, f, g, n_bits) ** 2 / (vf * vg)


def bit(i: int) -> Readout:
    """Indicator readout of the i-th bit."""
    return lambda x: Fraction(x[i])


def leakage(p: Fraction, f: Readout, n_bits: int) -> Fraction:
    """Leakage of the readout ``f`` about the designated bit x_0."""
    return corr_sq(p, bit(0), f, n_bits)


# ----------------------------------------------------------------------------
# The four classical readouts
# ----------------------------------------------------------------------------

def and_readout(x: Bits) -> Fraction:
    return Fraction(1) if all(b == 1 for b in x) else Fraction(0)


def or_readout(x: Bits) -> Fraction:
    return Fraction(1) if any(b == 1 for b in x) else Fraction(0)


def xor_readout(x: Bits) -> Fraction:
    return Fraction(sum(x) % 2)


def count_readout(x: Bits) -> Fraction:
    return Fraction(sum(x))


# ----------------------------------------------------------------------------
# The universal profile
# ----------------------------------------------------------------------------

def phi(t: Fraction, n: int) -> Fraction:
    """The fork profile Phi(t, n) = t^n / (1 + t + ... + t^n)."""
    denom = sum((t ** k for k in range(n + 1)), Fraction(0))
    return t ** n / denom


def channel_parameters(p: Fraction) -> Dict[str, Fraction]:
    """The four channel parameters of a Bernoulli(p) fork."""
    return {
        "A  (AND)": p,
        "g  (OR)": 1 - p,
        "X  (XOR)": (1 - 2 * p) ** 2,
        "Is (count)": Fraction(1),
    }


def channel_table(p: Fraction, n: int) -> Dict[str, Fraction]:
    """Exact leakages of the four channels of an (n+1)-bit fork, via the profile."""
    return {name: phi(t, n) for name, t in channel_parameters(p).items()}


# ----------------------------------------------------------------------------
# Product universality
# ----------------------------------------------------------------------------

def product_readout(c_true: Fraction, c_false: Fraction) -> Readout:
    """The coordinatewise product readout  F(x) = prod_i c(x_i)."""
    def f(x: Bits) -> Fraction:
        v = Fraction(1)
        for b in x:
            v *= c_true if b == 1 else c_false
        return v
    return f


def product_parameter(p: Fraction, c_true: Fraction, c_false: Fraction) -> Fraction:
    """The product parameter theta = m^2 / s with m = E c and s = E c^2."""
    m = p * c_true + (1 - p) * c_false
    s = p * c_true ** 2 + (1 - p) * c_false ** 2
    return m ** 2 / s


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def approx(q: Fraction, digits: int = 6) -> str:
    """Scientific-notation rendering of an exact rational."""
    return f"{float(q):.{digits}e}"


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 1. Channel collapse, certified against brute force
# ----------------------------------------------------------------------------

def demo_collapse(p: Fraction = Fraction(1, 3), max_n: int = 8) -> None:
    rule(f"1. CHANNEL COLLAPSE  (p = {p})   brute force  vs  Phi(t, n)")
    print(f"{'n':>3} {'channel':>12} {'brute force (2^(n+1) sum)':>28} "
          f"{'Phi(parameter, n)':>26}  ok")
    readouts = {
        "A  (AND)": and_readout,
        "g  (OR)": or_readout,
        "X  (XOR)": xor_readout,
        "Is (count)": count_readout,
    }
    params = channel_parameters(p)
    all_ok = True
    for n in range(1, max_n + 1):
        for name, f in readouts.items():
            brute = leakage(p, f, n + 1)
            closed = phi(params[name], n)
            ok = brute == closed
            all_ok = all_ok and ok
            print(f"{n:>3} {name:>12} {approx(brute):>28} {approx(closed):>26}  "
                  f"{'YES' if ok else 'NO'}")
        print("-" * 78)
    print(f"All brute-force values matched the closed form: {all_ok}")


# ----------------------------------------------------------------------------
# 2. Monotonicity and size-free ordering
# ----------------------------------------------------------------------------

def demo_monotonicity(n_values: Sequence[int] = (1, 2, 5, 12, 24)) -> None:
    rule("2. STRICT MONOTONICITY OF THE PROFILE IN t")
    ts = [Fraction(k, 10) for k in range(1, 11)]
    for n in n_values:
        vals = [phi(t, n) for t in ts]
        increasing = all(a < b for a, b in zip(vals, vals[1:]))
        print(f"n = {n:>2}:  Phi(0.1..1.0, n) strictly increasing: {increasing}"
              f"   Phi(1, n) = 1/{n + 1} = {approx(phi(Fraction(1), n))}")
    print()
    print("Because Phi is strictly increasing, the ranking of the four channels")
    print("is the ranking of their parameters and never depends on the size n.")


# ----------------------------------------------------------------------------
# 3. No crossover: the alleged n = 8 transition
# ----------------------------------------------------------------------------

def demo_no_crossover(p: Fraction = Fraction(1, 3), max_n: int = 25) -> None:
    rule(f"3. THE 'AND OVERTAKES XOR AT n = 8' CROSSOVER DOES NOT EXIST  (p = {p})")
    par = channel_parameters(p)
    print(f"parameter of A = p          = {par['A  (AND)']}")
    print(f"parameter of X = (1-2p)^2   = {par['X  (XOR)']}")
    print(f"sign of A - X is the sign of p - (1-2p)^2, which contains no n.")
    print()
    print(f"{'n':>3} {'A':>16} {'X':>16} {'sign(A - X)':>14}")
    signs = set()
    for n in range(1, max_n + 1):
        a = phi(par["A  (AND)"], n)
        x = phi(par["X  (XOR)"], n)
        s = "A > X" if a > x else ("A < X" if a < x else "A = X")
        signs.add(s)
        if n <= 10 or n == max_n:
            print(f"{n:>3} {approx(a):>16} {approx(x):>16} {s:>14}")
    print()
    print(f"distinct orderings observed over n = 1..{max_n}: {sorted(signs)}")
    print("A single ordering for all n: no crossover size exists.")
    print()
    print("The true threshold is in the BIAS, not the size:  A >= X  iff  p >= 1/4.")
    for pp in (Fraction(1, 5), Fraction(1, 4), Fraction(1, 3)):
        a = phi(pp, 6)
        x = phi((1 - 2 * pp) ** 2, 6)
        rel = ">" if a > x else ("<" if a < x else "=")
        print(f"  p = {str(pp):>4}:  A {rel} X   (A = {approx(a)}, X = {approx(x)})")


# ----------------------------------------------------------------------------
# 4. The X/g trichotomy
# ----------------------------------------------------------------------------

def demo_ratio_trichotomy(max_n: int = 30) -> None:
    rule("4. THE RATIO X / g NEVER TENDS TO 2  (trichotomy about p = 3/4)")
    biases = [Fraction(1, 3), Fraction(2, 3), Fraction(3, 4), Fraction(4, 5),
              Fraction(9, 10)]
    print(f"{'p':>6}", end="")
    ns = [2, 5, 10, 20, max_n]
    for n in ns:
        print(f"{'X/g at n=' + str(n):>18}", end="")
    print()
    for p in biases:
        print(f"{str(p):>6}", end="")
        for n in ns:
            x = phi((1 - 2 * p) ** 2, n)
            g = phi(1 - p, n)
            print(f"{approx(x / g):>18}", end="")
        print()
    print()
    print("p < 3/4 : X/g -> 0 geometrically.")
    print("p = 3/4 : X = g identically in n, so X/g == 1.")
    print("p > 3/4 : X/g diverges.")
    print("The value 2 is never a limit, for any bias.")


# ----------------------------------------------------------------------------
# 5. Phase diagram
# ----------------------------------------------------------------------------

def demo_phase_diagram(n: int = 6) -> None:
    rule(f"5. PHASE DIAGRAM OF THE THREE BOOLEAN CHANNELS  (shown at n = {n})")
    biases = [Fraction(1, 10), Fraction(1, 4), Fraction(1, 3), Fraction(1, 2),
              Fraction(2, 3), Fraction(3, 4), Fraction(9, 10)]
    for p in biases:
        tbl = channel_table(p, n)
        order = sorted(tbl.items(), key=lambda kv: kv[1])
        pieces = [order[0][0].split()[0]]
        for (_, prev), (name, cur) in zip(order, order[1:]):
            pieces.append(" = " if cur == prev else " < ")
            pieces.append(name.split()[0])
        chain = "".join(pieces)
        note = ""
        if p == Fraction(1, 4):
            note = "   <- critical: A = X"
        elif p == Fraction(1, 2):
            note = "   <- critical: A = g, and X = 0 exactly"
        elif p == Fraction(3, 4):
            note = "   <- critical: X = g"
        print(f"p = {str(p):>4}:  {chain}{note}")
    print()
    print("Regimes:  p<1/4: A<X<g<Is | 1/4<p<1/2: X<A<g<Is | "
          "1/2<p<3/4: X<g<A<Is | p>3/4: g<X<A<Is")
    print("The three merges are pairwise and isolated: there is no triple point.")


# ----------------------------------------------------------------------------
# 6. The closed 25-bit table
# ----------------------------------------------------------------------------

def demo_table25(p: Fraction = Fraction(1, 3), n: int = 24) -> None:
    rule(f"6. THE CLOSED TABLE AT {n + 1} BITS  (p = {p}, n = {n})")
    expected = {
        "Is (count)": Fraction(1, 25),
        "g  (OR)": Fraction(16777216, 847255055011),
        "A  (AND)": Fraction(1, 423644304721),
        "X  (XOR)": Fraction(1, 89737248461481573596281),
    }
    tbl = channel_table(p, n)
    for name in ["X  (XOR)", "A  (AND)", "g  (OR)", "Is (count)"]:
        v = tbl[name]
        print(f"{name:>12} = {str(v):>46}  = {approx(v)}   "
              f"matches recorded value: {v == expected[name]}")
    print()
    order_ok = tbl["X  (XOR)"] < tbl["A  (AND)"] < tbl["g  (OR)"] < tbl["Is (count)"]
    print(f"ordering  X < A < g < Is  holds: {order_ok}")
    span = tbl["Is (count)"] / tbl["X  (XOR)"]
    print(f"dynamic range Is / X = {approx(span)}  "
          "(21 orders of magnitude: floating point cannot see this table)")


# ----------------------------------------------------------------------------
# 7. Product universality
# ----------------------------------------------------------------------------

def demo_product_universality(p: Fraction = Fraction(2, 5), n: int = 6) -> None:
    rule(f"7. PRODUCT UNIVERSALITY  (p = {p}, n = {n}):  "
         "leak(prod_i c(x_i)) = Phi(m^2/s, n)")
    coordinate_functions: List[Tuple[str, Fraction, Fraction]] = [
        ("AND        c = (1, 0)", Fraction(1), Fraction(0)),
        ("NOR        c = (0, 1)", Fraction(0), Fraction(1)),
        ("parity     c = (-1, 1)", Fraction(-1), Fraction(1)),
        ("geometric  c = (3, 1)", Fraction(3), Fraction(1)),
        ("damped     c = (1, 4)", Fraction(1), Fraction(4)),
        ("near-const c = (10, 11)", Fraction(10), Fraction(11)),
    ]
    print(f"{'coordinate function':>24} {'theta = m^2/s':>18} "
          f"{'Phi(theta, n)':>16} {'brute force':>16}  ok")
    for label, ct, cf in coordinate_functions:
        theta = product_parameter(p, ct, cf)
        closed = phi(theta, n)
        brute = leakage(p, product_readout(ct, cf), n + 1)
        print(f"{label:>24} {approx(theta, 4):>18} {approx(closed):>16} "
              f"{approx(brute):>16}  {'YES' if brute == closed else 'NO'}")
    print()
    print(f"split count for comparison:  Is = 1/(n+1) = "
          f"{approx(Fraction(1, n + 1))}")
    print("Every non-constant product readout has theta = m^2/s < 1 strictly,")
    print("since s - m^2 = p(1-p)(c(1)-c(0))^2 > 0.  Hence every product readout")
    print("leaks strictly less than the split count, at every fork size.")


# ----------------------------------------------------------------------------
# 8. Symmetric optimality
# ----------------------------------------------------------------------------

def demo_symmetric_optimality(p: Fraction = Fraction(2, 5), n: int = 5) -> None:
    rule(f"8. SYMMETRIC OPTIMALITY  (p = {p}, {n + 1} bits): "
         f"every symmetric readout leaks <= 1/{n + 1}")
    n_bits = n + 1
    bound = Fraction(1, n_bits)

    symmetric: List[Tuple[str, Readout]] = [
        ("Hamming weight w", count_readout),
        ("affine 7w - 3", lambda x: Fraction(7) * sum(x) - 3),
        ("AND", and_readout),
        ("OR", or_readout),
        ("XOR", xor_readout),
        ("majority [w > n/2]", lambda x: Fraction(1) if 2 * sum(x) > n_bits else Fraction(0)),
        ("threshold [w >= 2]", lambda x: Fraction(1) if sum(x) >= 2 else Fraction(0)),
        ("w^2", lambda x: Fraction(sum(x)) ** 2),
        ("min(w, 3)", lambda x: Fraction(min(sum(x), 3))),
    ]
    print(f"{'symmetric readout':>22} {'leakage':>16} {'bound 1/(n+1)':>16}  "
          f"{'attains bound':>14}")
    for label, f in symmetric:
        lk = leakage(p, f, n_bits)
        assert lk <= bound, "optimality bound violated"
        print(f"{label:>22} {approx(lk):>16} {approx(bound):>16}  "
              f"{str(lk == bound):>14}")
    print()
    print("Only the Hamming weight and its non-degenerate affine images attain")
    print("the bound: the split count is the unique optimal symmetric readout.")


# ----------------------------------------------------------------------------
# 9. The total-leakage sum rule
# ----------------------------------------------------------------------------

def demo_sum_rule(p: Fraction = Fraction(1, 3), n_bits: int = 5) -> None:
    rule(f"9. TOTAL-LEAKAGE SUM RULE  (p = {p}, {n_bits} bits): "
         "sum_i corrSq(x_i, F) <= 1")
    readouts: List[Tuple[str, Readout]] = [
        ("Hamming weight w", count_readout),
        ("affine  x_0 + 2 x_1", lambda x: Fraction(x[0]) + 2 * Fraction(x[1])),
        ("single bit x_0", bit(0)),
        ("AND", and_readout),
        ("OR", or_readout),
        ("XOR", xor_readout),
        ("w^2", lambda x: Fraction(sum(x)) ** 2),
        ("x_0 * x_1 + x_2", lambda x: Fraction(x[0] * x[1] + x[2])),
    ]
    print(f"{'readout':>22} {'sum of leakages':>18} {'deficiency':>16}  "
          f"{'affine (saturates)':>20}")
    for label, f in readouts:
        total = sum((corr_sq(p, bit(i), f, n_bits) for i in range(n_bits)),
                    Fraction(0))
        assert total <= 1, "sum rule violated"
        print(f"{label:>22} {approx(total):>18} {approx(1 - total):>16}  "
              f"{str(total == 1):>20}")
    print()
    print("The deficiency 1 - sum is exactly the normalised mean square of the")
    print("readout's nonlinear part; it vanishes precisely for affine readouts.")
    print()
    print("Pigeonhole consequence: #{i : leakage_i >= tau} <= 1/tau.")
    for tau in (Fraction(1, 2), Fraction(1, 4), Fraction(1, 10)):
        f = count_readout
        hits = sum(1 for i in range(n_bits)
                   if corr_sq(p, bit(i), f, n_bits) >= tau)
        print(f"  tau = {str(tau):>4}:  Hamming weight has {hits} bit(s) at that "
              f"level; bound 1/tau = {float(1 / tau):.1f}")
    print("In particular at most one bit of a fork can ever be more than half-leaked.")


# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_collapse()
    demo_monotonicity()
    demo_no_crossover()
    demo_ratio_trichotomy()
    demo_phase_diagram()
    demo_table25()
    demo_product_universality()
    demo_symmetric_optimality()
    demo_sum_rule()
    rule("SUMMARY")
    print("All four fork channels are one rational profile")
    print("    Phi(t, n) = t^n / (1 + t + ... + t^n)")
    print("read at four parameters:  p (AND), 1-p (OR), (1-2p)^2 (XOR), 1 (count).")
    print("Phi is strictly increasing in t, so every ordering is size-free:")
    print("  * the split count dominates, with exact value 1/(n+1);")
    print("  * no size-dependent crossover between channels can occur;")
    print("  * X/g never tends to 2 -- the trichotomy pivots at p = 3/4.")


if __name__ == "__main__":
    main()
