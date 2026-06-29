"""
demo.py — Arithmetic Universality in Additive Cellular Automata
            via p-adic Renormalization
================================================================

Self-contained numerical demonstrations of the algebraic theory of
one-dimensional, nearest-neighbour *additive* cellular automata (CAs)
over the finite field F_p = ZMod p.

Core dictionary
---------------
A finite-support configuration s : Z -> F_p is encoded as a *Laurent
polynomial*

        S(T) = sum_x  s(x) * T^x ,     s(x) in F_p .

The additive nearest-neighbour rule (the F_p analogue of Wolfram's
"Rule 90": every cell becomes the sum of its two neighbours mod p) is
multiplication by the single ring element

        caOp = T + T^{-1}.

Time-t evolution is therefore multiplication by (caOp)^t, and the whole
space-time diagram is just the powers of one ring element.

The results demonstrated here (all formally proved):

  * caEvolve_add / caEvolve_smul : evolution is F_p-linear.
  * caOp_binomial : (T+T^{-1})^n = sum_{k<=n} C(n,k) * T^{2k-n}.
  * caOp_pow_char : (T+T^{-1})^p = T^p + T^{-p}  (Frobenius collapse).
  * caOp_renorm   : (T+T^{-1})^{p^k} = T^{p^k} + T^{-p^k}.
  * caOp_renorm_seed : (caOp)^{p^k} * T^a = T^{a+p^k} + T^{a-p^k}.

Plus the conjectural Lucas count of live cells (Future Direction 1).

Everything is exact integer / modular arithmetic; no external libraries.
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Tuple

# A Laurent polynomial over F_p is a dict {exponent: coefficient mod p},
# with zero coefficients pruned.
LaurentPoly = Dict[int, int]


# ---------------------------------------------------------------------------
# Basic Laurent-polynomial arithmetic over F_p
# ---------------------------------------------------------------------------
def normalize(poly: LaurentPoly, p: int) -> LaurentPoly:
    """Reduce coefficients mod p and drop zero terms."""
    out: LaurentPoly = {}
    for exp, coeff in poly.items():
        c = coeff % p
        if c != 0:
            out[exp] = c
    return out


def poly_add(a: LaurentPoly, b: LaurentPoly, p: int) -> LaurentPoly:
    """Add two Laurent polynomials over F_p (superposition of configs)."""
    out: LaurentPoly = dict(a)
    for exp, coeff in b.items():
        out[exp] = (out.get(exp, 0) + coeff) % p
    return normalize(out, p)


def poly_scale(a: LaurentPoly, c: int, p: int) -> LaurentPoly:
    """Multiply a Laurent polynomial by a scalar c in F_p (homogeneity)."""
    return normalize({exp: coeff * c for exp, coeff in a.items()}, p)


def poly_mul(a: LaurentPoly, b: LaurentPoly, p: int) -> LaurentPoly:
    """Multiply two Laurent polynomials over F_p (a discrete convolution)."""
    out: LaurentPoly = {}
    for ea, ca in a.items():
        for eb, cb in b.items():
            out[ea + eb] = (out.get(ea + eb, 0) + ca * cb) % p
    return normalize(out, p)


def ca_op(p: int) -> LaurentPoly:
    """The additive nearest-neighbour CA operator caOp = T + T^{-1}."""
    return {1: 1 % p, -1: 1 % p}


def ca_evolve(state: LaurentPoly, t: int, p: int) -> LaurentPoly:
    """Evolve a configuration t steps: multiply by (caOp)^t over F_p."""
    op = ca_op(p)
    result: LaurentPoly = {0: 1 % p}          # the identity polynomial T^0 = 1
    for _ in range(t):
        result = poly_mul(result, op, p)
    return poly_mul(state, result, p)


# ---------------------------------------------------------------------------
# Closed forms implied by the theorems
# ---------------------------------------------------------------------------
def ca_op_binomial(n: int, p: int) -> LaurentPoly:
    """Closed form (caOp_binomial):
       (T+T^{-1})^n = sum_{k=0}^{n} C(n,k) * T^{2k-n}  (mod p)."""
    out: LaurentPoly = {}
    for k in range(n + 1):
        out[2 * k - n] = (out.get(2 * k - n, 0) + comb(n, k)) % p
    return normalize(out, p)


def ca_op_renorm(p: int, k: int) -> LaurentPoly:
    """Closed form (caOp_renorm):
       (T+T^{-1})^{p^k} = T^{p^k} + T^{-p^k}  (mod p)."""
    e = p ** k
    return {e: 1 % p, -e: 1 % p}


def base_p_digits(n: int, p: int) -> List[int]:
    """Digits of n in base p, least significant first."""
    if n == 0:
        return [0]
    digits: List[int] = []
    while n > 0:
        digits.append(n % p)
        n //= p
    return digits


def lucas_live_cell_count(t: int, p: int) -> int:
    """Conjectured live-cell count (Future Direction 1):
       number of nonzero cells of (caOp)^t equals prod_i (d_i + 1),
       where t = sum_i d_i p^i.  By Lucas' theorem this counts the k with
       C(t,k) != 0 mod p."""
    product = 1
    for d in base_p_digits(t, p):
        product *= (d + 1)
    return product


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
def poly_str(poly: LaurentPoly) -> str:
    if not poly:
        return "0"
    terms = []
    for exp in sorted(poly):
        c = poly[exp]
        if exp == 0:
            terms.append(f"{c}")
        else:
            terms.append(f"{c}*T^{exp}")
    return " + ".join(terms)


def render_spacetime(p: int, steps: int) -> str:
    """ASCII space-time diagram from a single seed at the origin.

    A live (nonzero) cell is drawn '#', a dead cell '.'.  Over F_2 this
    is exactly the Sierpinski triangle."""
    rows: List[Tuple[int, LaurentPoly]] = []
    state: LaurentPoly = {0: 1 % p}
    op = ca_op(p)
    for _ in range(steps + 1):
        rows.append((0, dict(state)))
        state = poly_mul(state, op, p)
    width = steps
    lines = []
    for _, row in rows:
        chars = []
        for x in range(-width, width + 1):
            chars.append("#" if row.get(x, 0) != 0 else ".")
        lines.append("".join(chars))
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_linearity() -> None:
    print("=" * 70)
    print("1.  F_p-LINEARITY of evolution (caEvolve_add / caEvolve_smul)")
    print("=" * 70)
    p, t = 5, 3
    s1: LaurentPoly = {0: 1, 2: 3}
    s2: LaurentPoly = {-1: 4, 1: 2}
    lhs = ca_evolve(poly_add(s1, s2, p), t, p)
    rhs = poly_add(ca_evolve(s1, t, p), ca_evolve(s2, t, p), p)
    print(f"  p = {p}, t = {t}")
    print(f"  Evolve(s1 + s2)        = {poly_str(lhs)}")
    print(f"  Evolve(s1) + Evolve(s2)= {poly_str(rhs)}")
    print(f"  additivity holds: {lhs == rhs}")
    c = 4
    lhs2 = ca_evolve(poly_scale(s1, c, p), t, p)
    rhs2 = poly_scale(ca_evolve(s1, t, p), c, p)
    print(f"  Evolve(c*s1)  = {poly_str(lhs2)}")
    print(f"  c*Evolve(s1)  = {poly_str(rhs2)}")
    print(f"  homogeneity holds: {lhs2 == rhs2}")
    print()


def demo_binomial() -> None:
    print("=" * 70)
    print("2.  GENERATING FUNCTION (caOp_binomial): Pascal's triangle mod p")
    print("=" * 70)
    for p in (2, 3, 5):
        ok = True
        for n in range(0, 12):
            direct = ca_evolve({0: 1}, n, p)
            closed = ca_op_binomial(n, p)
            ok = ok and (direct == closed)
        print(f"  p = {p}: (caOp)^n == sum C(n,k) T^(2k-n) for n=0..11 -> {ok}")
    print("\n  Row n of (caOp)^n over F_3 (coefficients, low..high exponent):")
    for n in range(0, 7):
        poly = ca_op_binomial(n, 3)
        coeffs = [poly.get(2 * k - n, 0) for k in range(n + 1)]
        print(f"    n={n}: {coeffs}")
    print()


def demo_renormalization() -> None:
    print("=" * 70)
    print("3.  p-ADIC RENORMALIZATION (caOp_pow_char / caOp_renorm)")
    print("=" * 70)
    for p in (2, 3, 5):
        for k in (1, 2):
            t = p ** k
            direct = ca_evolve({0: 1}, t, p)
            collapsed = ca_op_renorm(p, k)
            print(f"  p={p}, t=p^{k}={t:>3}:  (caOp)^t = {poly_str(direct):<22}"
                  f" collapses to two rays: {direct == collapsed}")
    print()


def demo_seed_lightcone() -> None:
    print("=" * 70)
    print("4.  TRANSLATION-COVARIANT SEED (caOp_renorm_seed)")
    print("=" * 70)
    p, k, a = 3, 1, 10
    t = p ** k
    seed: LaurentPoly = {a: 1}
    out = ca_evolve(seed, t, p)
    expected: LaurentPoly = {a + t: 1, a - t: 1}
    print(f"  p={p}, k={k}, seed at a={a}, t=p^k={t}")
    print(f"  (caOp)^t * T^a = {poly_str(out)}")
    print(f"  expected T^(a+t)+T^(a-t) = {poly_str(expected)}")
    print(f"  match: {out == expected}")
    print()


def demo_sierpinski_count() -> None:
    print("=" * 70)
    print("5.  LIVE-CELL COUNT via LUCAS (Future Direction 1)")
    print("=" * 70)
    for p in (2, 3):
        ok = True
        for t in range(0, 28):
            actual = len(ca_evolve({0: 1}, t, p))
            predicted = lucas_live_cell_count(t, p)
            ok = ok and (actual == predicted)
        print(f"  p={p}: #live cells == prod(d_i+1) for t=0..27 -> {ok}")
        powers = [p ** k for k in range(0, 4)]
        print(f"        at powers of p {powers}: counts ="
              f" {[len(ca_evolve({0:1}, t, p)) for t in powers]} (all 2)")
    print()


def demo_sierpinski_picture() -> None:
    print("=" * 70)
    print("6.  SPACE-TIME DIAGRAM (Sierpinski self-similarity)")
    print("=" * 70)
    print("  Rule 90 over F_2, 16 steps from a single seed:\n")
    print(render_spacetime(2, 16))
    print()


def main() -> None:
    demo_linearity()
    demo_binomial()
    demo_renormalization()
    demo_seed_lightcone()
    demo_sierpinski_count()
    demo_sierpinski_picture()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
