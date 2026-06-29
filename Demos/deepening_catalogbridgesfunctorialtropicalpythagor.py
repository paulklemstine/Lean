"""
demo.py — Functorial Tropical–Pythagorean Bridge
================================================

Self-contained numerical demonstrations of the results in the package
"A Functorial Tropical–Pythagorean Bridge: Softmax as the Normalization
Functor onto the Probability Simplex".

All functions are inlined and depend only on the Python standard library
(`math`). Run directly:

    python3 demo.py

The demos verify, on concrete numbers:
  1. softmax_2: positivity, sub-unitarity, partition of unity, shift
     invariance, surjectivity onto the open simplex.
  2. lse_2: shift homomorphism, the Maslov dequantization sandwich
     max <= lse <= max + log 2, and gradient(lse) = softmax.
  3. Curvature of lse = Bernoulli variance of softmax.
  4. The Pythagorean functor: partition (= Pythagoras), scale invariance,
     and Pythagoras = softmax of log-squares.
  5. The Pythagorean probability identity (p-q)^2 + 4 Var = 1, and the
     "standard deviation = half normalized triangle area" reading.
"""

from __future__ import annotations

import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core definitions (mirroring the formalized objects)
# --------------------------------------------------------------------------

def softmax2(a: float, b: float) -> float:
    """Two-point softmax (Gibbs weight): e^a / (e^a + e^b)."""
    ea, eb = math.exp(a), math.exp(b)
    return ea / (ea + eb)


def lse2(a: float, b: float) -> float:
    """Two-point log-sum-exp (free energy): log(e^a + e^b)."""
    return math.log(math.exp(a) + math.exp(b))


def softmax(w: List[float]) -> List[float]:
    """Numerically stable general softmax (uses shift invariance)."""
    m = max(w)
    exps = [math.exp(x - m) for x in w]
    s = sum(exps)
    return [e / s for e in exps]


def lse(w: List[float]) -> float:
    """Numerically stable general log-sum-exp."""
    m = max(w)
    return m + math.log(sum(math.exp(x - m) for x in w))


def bern_var(p: float) -> float:
    """Bernoulli variance p(1-p)."""
    return p * (1.0 - p)


def pyth_to_bernoulli(a: float, b: float, c: float) -> Tuple[float, float]:
    """Pythagorean functor: (a,b,c) with a^2+b^2=c^2 -> ((a/c)^2, (b/c)^2)."""
    return (a / c) ** 2, (b / c) ** 2


def numeric_deriv(f, x: float, h: float = 1e-6) -> float:
    """Central finite-difference derivative."""
    return (f(x + h) - f(x - h)) / (2 * h)


def numeric_second_deriv(f, x: float, h: float = 1e-4) -> float:
    """Central finite-difference second derivative."""
    return (f(x + h) - 2 * f(x) + f(x - h)) / (h * h)


def approx(x: float, y: float, tol: float = 1e-6) -> str:
    return "OK" if abs(x - y) <= tol else f"MISMATCH (|Δ|={abs(x - y):.2e})"


# --------------------------------------------------------------------------
# Demo 1: the softmax functor
# --------------------------------------------------------------------------

def demo_softmax() -> None:
    print("=" * 70)
    print("DEMO 1 — The softmax functor (tropical coords -> probability)")
    print("=" * 70)
    pairs = [(0.0, 0.0), (1.0, -1.0), (2.5, 0.3), (-4.0, 1.0)]
    for a, b in pairs:
        s_ab, s_ba = softmax2(a, b), softmax2(b, a)
        print(f"  (a,b)=({a:+.2f},{b:+.2f}): softmax2={s_ab:.6f}  "
              f"in(0,1)={0 < s_ab < 1}  "
              f"partition s(a,b)+s(b,a)={s_ab + s_ba:.6f} [{approx(s_ab + s_ba, 1.0)}]")
    print("\n  Shift invariance softmax2(a+c,b+c)=softmax2(a,b):")
    a, b = 1.3, -0.7
    for c in (5.0, -3.2, 100.0):
        print(f"    c={c:+.1f}: {softmax2(a + c, b + c):.8f}  vs  "
              f"{softmax2(a, b):.8f}  [{approx(softmax2(a + c, b + c), softmax2(a, b))}]")
    print("\n  Surjectivity softmax2(log p, log q) = p/(p+q):")
    for p, q in [(2.0, 3.0), (0.1, 0.9), (7.0, 1.0)]:
        lhs = softmax2(math.log(p), math.log(q))
        rhs = p / (p + q)
        print(f"    (p,q)=({p},{q}): {lhs:.6f} vs {rhs:.6f} [{approx(lhs, rhs)}]")
    print("\n  General softmax partition of unity:")
    w = [2.0, -1.0, 0.5, 3.3, -2.2]
    sm = softmax(w)
    print(f"    w={w}\n    softmax={[round(x, 4) for x in sm]}  sum={sum(sm):.6f} "
          f"[{approx(sum(sm), 1.0)}]  all>0={all(x > 0 for x in sm)}")


# --------------------------------------------------------------------------
# Demo 2: log-sum-exp, the Maslov sandwich, and the gradient identity
# --------------------------------------------------------------------------

def demo_lse() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2 — Log-sum-exp: shift homomorphism, Maslov sandwich, gradient")
    print("=" * 70)
    log2 = math.log(2.0)
    pairs = [(0.0, 0.0), (3.0, 1.0), (-2.0, -5.0), (10.0, 9.5)]
    print("  Maslov sandwich  max <= lse2 <= max + log 2:")
    for a, b in pairs:
        m, v = max(a, b), lse2(a, b)
        ok = m - 1e-9 <= v <= m + log2 + 1e-9
        print(f"    (a,b)=({a:+.1f},{b:+.1f}): max={m:+.4f} <= lse={v:+.4f} "
              f"<= {m + log2:+.4f}  [{'OK' if ok else 'FAIL'}]")
    print("\n  Diagonal lse2(a,a) = a + log 2:")
    for a in (0.0, 2.0, -1.5):
        print(f"    a={a:+.1f}: lse2={lse2(a, a):.6f} vs {a + log2:.6f} "
              f"[{approx(lse2(a, a), a + log2)}]")
    print("\n  Shift homomorphism lse2(a+c,b+c) = lse2(a,b) + c:")
    a, b = 1.0, 2.5
    for c in (4.0, -2.0):
        print(f"    c={c:+.1f}: {lse2(a + c, b + c):.6f} vs {lse2(a, b) + c:.6f} "
              f"[{approx(lse2(a + c, b + c), lse2(a, b) + c)}]")
    print("\n  GRADIENT of free energy = Gibbs probability  d/da lse2 = softmax2:")
    b = 0.4
    for a in (-1.0, 0.7, 2.3):
        g = numeric_deriv(lambda x: lse2(x, b), a)
        s = softmax2(a, b)
        print(f"    a={a:+.1f}: d/da lse2={g:.6f} vs softmax2={s:.6f} [{approx(g, s, 1e-5)}]")
    print("\n  CURVATURE of free energy = Bernoulli variance  d2/da2 lse2 = bernVar(softmax2):")
    for a in (-1.0, 0.7, 2.3):
        c2 = numeric_second_deriv(lambda x: lse2(x, b), a)
        v = bern_var(softmax2(a, b))
        print(f"    a={a:+.1f}: d2/da2 lse2={c2:.6f} vs var={v:.6f} [{approx(c2, v, 1e-3)}]")


# --------------------------------------------------------------------------
# Demo 3: the Pythagorean functor
# --------------------------------------------------------------------------

def demo_pythagorean() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3 — The Pythagorean functor: triangles become coins")
    print("=" * 70)
    triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (20, 21, 29)]
    print("  Partition (= Pythagoras):  (a/c)^2 + (b/c)^2 = 1")
    for a, b, c in triples:
        p, q = pyth_to_bernoulli(a, b, c)
        print(f"    {a}^2+{b}^2={c}^2 -> p={p:.6f} q={q:.6f}  p+q={p + q:.6f} "
              f"[{approx(p + q, 1.0)}]")
    print("\n  Scale invariance (dilate the triangle, same coin):")
    a, b, c = 3, 4, 5
    for t in (2, 7, 0.5):
        p0, _ = pyth_to_bernoulli(a, b, c)
        pt, _ = pyth_to_bernoulli(t * a, t * b, t * c)
        print(f"    t={t}: p={pt:.6f} vs {p0:.6f} [{approx(pt, p0)}]")
    print("\n  Pythagoras = softmax of log-squares:  softmax2(log a^2, log b^2) = (a/c)^2")
    for a, b, c in triples:
        lhs = softmax2(math.log(a * a), math.log(b * b))
        rhs = (a / c) ** 2
        print(f"    ({a},{b},{c}): {lhs:.6f} vs {rhs:.6f} [{approx(lhs, rhs)}]")


# --------------------------------------------------------------------------
# Demo 4: the Pythagorean probability identity
# --------------------------------------------------------------------------

def demo_identity() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4 — Pythagorean probability identity  (p-q)^2 + 4 Var = 1")
    print("=" * 70)
    print("  Abstract Bernoulli laws:")
    for p in (0.5, 0.36, 0.1, 0.99):
        q = 1 - p
        var = bern_var(p)
        sigma = math.sqrt(var)
        lhs = (p - q) ** 2 + 4 * var
        leg2 = (2 * sigma) ** 2
        print(f"    p={p:.2f}: (p-q)^2={(p - q) ** 2:.4f}  4Var={4 * var:.4f}  "
              f"sum={lhs:.6f} [{approx(lhs, 1.0)}]   (2σ)^2={leg2:.4f}")
    print("\n  On Pythagorean triangles: σ = sqrt(pq) = |ab|/c^2 = half normalized area:")
    for a, b, c in [(3, 4, 5), (5, 12, 13), (8, 15, 17)]:
        p, q = pyth_to_bernoulli(a, b, c)
        sigma = math.sqrt(p * q)
        area_term = abs(a * b) / (c * c)
        print(f"    ({a},{b},{c}): σ={sigma:.6f}  |ab|/c^2={area_term:.6f} "
              f"[{approx(sigma, area_term)}]   (p-q)^2+4pq={(p - q) ** 2 + 4 * p * q:.6f}")


def main() -> None:
    demo_softmax()
    demo_lse()
    demo_pythagorean()
    demo_identity()
    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
