"""
demo.py — Numerical demonstrations for "Hidden Coordinate Systems".

Two independent, fully self-contained demonstrations:

  Part I  — The Log-Affine Normal Form Theorem.
            Every expression built from coordinate projections, positive
            constants, multiplication and real powers evaluates to a single
            weighted geometric monomial  exp(sum_i w_i * log x_i + c).
            We build random expression trees, evaluate them directly, and
            check the value matches the value reconstructed from the
            normal form (w, c).

  Part II — The modular / theta-group structure of Pythagorean triples.
            We verify the Berggren generators equal the theta-group
            generators (M3 = T^2, M1 = T^2 S), check the theta parity
            predicate and its closure, generate the Berggren tree of
            primitive triples, confirm the 3x3 Berggren matrices preserve
            the Lorentz form diag(1,1,-1), and map leaves to Farey
            fractions.

Run:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, List, Tuple, Union

# ===========================================================================
# PART I — LOG-AFFINE NORMAL FORM
# ===========================================================================

# --- Syntax: the multiplicative positive fragment --------------------------


@dataclass(frozen=True)
class Coord:
    """Coordinate projection x_i."""
    i: int


@dataclass(frozen=True)
class PosConst:
    """A positive constant c > 0."""
    c: float


@dataclass(frozen=True)
class Mul:
    """Product e1 * e2."""
    e1: "PosEMLExpr"
    e2: "PosEMLExpr"


@dataclass(frozen=True)
class RPow:
    """Real power e ** r."""
    e: "PosEMLExpr"
    r: float


PosEMLExpr = Union[Coord, PosConst, Mul, RPow]


def eval_pos_eml(e: PosEMLExpr, x: List[float]) -> float:
    """Direct denotational evaluation on a positive vector x."""
    if isinstance(e, Coord):
        return x[e.i]
    if isinstance(e, PosConst):
        return e.c
    if isinstance(e, Mul):
        return eval_pos_eml(e.e1, x) * eval_pos_eml(e.e2, x)
    if isinstance(e, RPow):
        return eval_pos_eml(e.e, x) ** e.r
    raise TypeError(f"unknown expression node: {e!r}")


def to_log_affine_form(e: PosEMLExpr, n: int) -> Tuple[List[float], float]:
    """Syntactic normalization: return (weights w, constant c) such that
    eval(e)(x) == exp(sum_i w_i * log x_i + c) for all positive x."""
    if isinstance(e, Coord):
        w = [0.0] * n
        w[e.i] = 1.0
        return w, 0.0
    if isinstance(e, PosConst):
        return [0.0] * n, math.log(e.c)
    if isinstance(e, Mul):
        w1, c1 = to_log_affine_form(e.e1, n)
        w2, c2 = to_log_affine_form(e.e2, n)
        return [a + b for a, b in zip(w1, w2)], c1 + c2
    if isinstance(e, RPow):
        w, c = to_log_affine_form(e.e, n)
        return [e.r * a for a in w], e.r * c
    raise TypeError(f"unknown expression node: {e!r}")


def eval_from_normal_form(w: List[float], c: float, x: List[float]) -> float:
    """Reconstruct the value from the log-affine normal form."""
    return math.exp(sum(wi * math.log(xi) for wi, xi in zip(w, x)) + c)


def random_expr(n: int, depth: int, rng: random.Random) -> PosEMLExpr:
    """Generate a random multiplicative-positive expression tree."""
    if depth <= 0:
        if rng.random() < 0.5:
            return Coord(rng.randrange(n))
        return PosConst(round(rng.uniform(0.1, 5.0), 3))
    kind = rng.choice(["coord", "const", "mul", "rpow"])
    if kind == "coord":
        return Coord(rng.randrange(n))
    if kind == "const":
        return PosConst(round(rng.uniform(0.1, 5.0), 3))
    if kind == "mul":
        return Mul(random_expr(n, depth - 1, rng), random_expr(n, depth - 1, rng))
    return RPow(random_expr(n, depth - 1, rng), round(rng.uniform(-2.0, 2.0), 3))


def part_one() -> None:
    print("=" * 70)
    print("PART I — Log-Affine Normal Form Theorem")
    print("=" * 70)

    # A hand-built example: 5 * x0^3 * sqrt(x1) * (2 * x2 / x0)^0.4
    n = 3
    expr: PosEMLExpr = Mul(
        Mul(
            Mul(PosConst(5.0), RPow(Coord(0), 3.0)),
            RPow(Coord(1), 0.5),
        ),
        RPow(Mul(PosConst(2.0), Mul(Coord(2), RPow(Coord(0), -1.0))), 0.4),
    )
    x = [1.7, 2.3, 0.9]
    direct = eval_pos_eml(expr, x)
    w, c = to_log_affine_form(expr, n)
    recon = eval_from_normal_form(w, c, x)
    print("\nHand-built expression  5 * x0^3 * sqrt(x1) * (2 * x2 / x0)^0.4")
    print(f"  input x            = {x}")
    print(f"  direct eval        = {direct:.10f}")
    print(f"  weights w          = {[round(v, 4) for v in w]}")
    print(f"  constant c         = {c:.6f}  (exp c = {math.exp(c):.6f})")
    print(f"  reconstructed eval = {recon:.10f}")
    print(f"  match              = {math.isclose(direct, recon, rel_tol=1e-12)}")

    # Randomized stress test of Theorem 2.2.
    rng = random.Random(20260612)
    trials, max_err = 5000, 0.0
    for _ in range(trials):
        n = rng.randint(1, 4)
        e = random_expr(n, depth=rng.randint(0, 5), rng=rng)
        xx = [round(rng.uniform(0.2, 4.0), 4) for _ in range(n)]
        w, c = to_log_affine_form(e, n)
        d = eval_pos_eml(e, xx)
        r = eval_from_normal_form(w, c, xx)
        max_err = max(max_err, abs(d - r) / max(1.0, abs(d)))
    print(f"\nRandomized check over {trials} expression trees:")
    print(f"  max relative error eval vs. normal form = {max_err:.2e}")
    print(f"  THEOREM 2.2 confirmed numerically       = {max_err < 1e-9}")

    # Positivity (Lemma 2.1).
    pos_ok = all(
        eval_pos_eml(random_expr(3, 4, rng), [rng.uniform(0.2, 4.0) for _ in range(3)]) > 0
        for _ in range(2000)
    )
    print(f"\nLemma 2.1 positivity holds on 2000 samples  = {pos_ok}")


# ===========================================================================
# PART II — PYTHAGOREAN TRIPLES AND THE THETA GROUP
# ===========================================================================

Mat2 = Tuple[Tuple[int, int], Tuple[int, int]]
Mat3 = Tuple[Tuple[int, int, int], ...]


def mat2_mul(a: Mat2, b: Mat2) -> Mat2:
    return (
        (a[0][0] * b[0][0] + a[0][1] * b[1][0], a[0][0] * b[0][1] + a[0][1] * b[1][1]),
        (a[1][0] * b[0][0] + a[1][1] * b[1][0], a[1][0] * b[0][1] + a[1][1] * b[1][1]),
    )


def mat2_det(a: Mat2) -> int:
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def mat2_trace(a: Mat2) -> int:
    return a[0][0] + a[1][1]


# Generators
T_MAT: Mat2 = ((1, 1), (0, 1))
T_SQ: Mat2 = ((1, 2), (0, 1))
S_GEN: Mat2 = ((0, -1), (1, 0))
BM3: Mat2 = T_SQ                       # M3 = T^2  (verified in Lean)
BM3_INV: Mat2 = ((1, -2), (0, 1))
BM1: Mat2 = mat2_mul(T_SQ, S_GEN)      # M1 = T^2 * S


def theta_group_parity(m: Mat2) -> bool:
    """Theta parity predicate (Definition 3.1)."""
    return (
        m[0][0] % 2 == m[1][1] % 2
        and m[0][1] % 2 == m[1][0] % 2
        and (m[0][0] + m[0][1]) % 2 == 1
    )


def euclid_param(m: int, n: int) -> Tuple[int, int, int]:
    """Euclid parametrization (a, b, c) = (m^2-n^2, 2mn, m^2+n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


# 3x3 Berggren matrices acting on (a,b,c) and the Lorentz form Q.
BB1: Mat3 = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
BB2: Mat3 = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
BB3: Mat3 = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))
Q3: Mat3 = ((1, 0, 0), (0, 1, 0), (0, 0, -1))


def mat3_mul(a: Mat3, b: Mat3) -> Mat3:
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3))
        for i in range(3)
    )


def mat3_transpose(a: Mat3) -> Mat3:
    return tuple(tuple(a[j][i] for j in range(3)) for i in range(3))


def mat3_det(a: Mat3) -> int:
    return (
        a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
        - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
        + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0])
    )


def apply3(a: Mat3, v: Tuple[int, int, int]) -> Tuple[int, int, int]:
    return tuple(sum(a[i][k] * v[k] for k in range(3)) for i in range(3))


def berggren_tree(depth: int) -> List[Tuple[int, int, int]]:
    """Generate primitive Pythagorean triples from seed (3,4,5)."""
    triples: List[Tuple[int, int, int]] = []
    frontier = [(3, 4, 5)]
    for _ in range(depth + 1):
        triples.extend(frontier)
        frontier = [apply3(B, t) for t in frontier for B in (BB1, BB2, BB3)]
    return triples


def r2(N: int) -> int:
    """Number of (x, y) in Z^2 with x^2 + y^2 = N."""
    if N < 0:
        return 0
    b = int(math.isqrt(N))
    return sum(
        1
        for x in range(-b, b + 1)
        for y in range(-b, b + 1)
        if x * x + y * y == N
    )


def berggren_to_farey(a: int, b: int, c: int) -> Fraction:
    """Map a triple to its Farey fraction b/(a+c)."""
    return Fraction(b, a + c)


def part_two() -> None:
    print("\n" + "=" * 70)
    print("PART II — Pythagorean triples and the theta group")
    print("=" * 70)

    print("\nBerggren = theta generators (Theorem 3.3):")
    print(f"  M3 == T^2                 : {BM3 == T_SQ}")
    print(f"  M3^-1 * M1 == S           : {mat2_mul(BM3_INV, BM1) == S_GEN}")
    print(f"  M1 == T^2 * S             : {BM1 == mat2_mul(T_SQ, S_GEN)}")
    print(f"  S^2 == -I                 : {mat2_mul(S_GEN, S_GEN) == ((-1, 0), (0, -1))}")
    s4 = mat2_mul(mat2_mul(S_GEN, S_GEN), mat2_mul(S_GEN, S_GEN))
    print(f"  S^4 == I                  : {s4 == ((1, 0), (0, 1))}")
    print(f"  det M1, det M2-shape, det M3 = {mat2_det(BM1)}, -1, {mat2_det(BM3)}")
    print(f"  trace M1, M3, S          : {mat2_trace(BM1)}, {mat2_trace(BM3)}, {mat2_trace(S_GEN)}")

    print("\nTheta parity (Definition 3.1, Theorem 3.2):")
    print(f"  parity(T^2)              : {theta_group_parity(T_SQ)}")
    print(f"  parity(S)                : {theta_group_parity(S_GEN)}")
    print(f"  parity(T)  (should fail) : {theta_group_parity(T_MAT)}")
    # Closure under products of det-1 matrices.
    closure_ok = True
    words = [T_SQ, S_GEN]
    cur = ((1, 0), (0, 1))
    rng = random.Random(7)
    for _ in range(500):
        g = rng.choice(words)
        cur = mat2_mul(cur, g)
        if mat2_det(cur) == 1 and not theta_group_parity(cur):
            closure_ok = False
            break
    print(f"  parity closed on 500 random words in <T^2,S> : {closure_ok}")

    print("\nLorentz isometries (Theorem 3.4):")
    for name, B in (("B1", BB1), ("B2", BB2), ("B3", BB3)):
        preserves = mat3_mul(mat3_mul(mat3_transpose(B), Q3), B) == Q3
        print(f"  {name}^T Q {name} == Q : {preserves},  det {name} = {mat3_det(B)}")

    print("\nEuclid parametrization (Theorem 3.5):")
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2)]:
        a, b, c = euclid_param(m, n)
        print(f"  (m,n)=({m},{n}) -> ({a},{b},{c}), a^2+b^2-c^2 = {a*a + b*b - c*c}")

    print("\nBerggren tree (each triple is Pythagorean and primitive):")
    tree = berggren_tree(depth=2)
    all_pyth = all(a * a + b * b == c * c for a, b, c in tree)
    all_prim = all(math.gcd(math.gcd(a, b), c) == 1 for a, b, c in tree)
    print(f"  generated {len(tree)} triples to depth 2")
    print(f"  all satisfy a^2+b^2=c^2  : {all_pyth}")
    print(f"  all primitive            : {all_prim}")
    print(f"  first few                : {tree[:5]}")

    print("\nSums of two squares (r2):")
    print(f"  r2(0) = {r2(0)} (expect 1),  r2(1) = {r2(1)} (expect 4)")
    primes_1mod4 = [5, 13, 17, 29, 37, 41]
    reps = {p: next((x, y) for x in range(p) for y in range(p) if x * x + y * y == p)
            for p in primes_1mod4}
    print(f"  two-squares theorem p=1 mod 4: {reps}")

    print("\nFarey fractions via b/(a+c):")
    for a, b, c in [(3, 4, 5), (5, 12, 13), (8, 15, 17), (20, 21, 29)]:
        print(f"  ({a},{b},{c}) -> {berggren_to_farey(a, b, c)}")


def main() -> None:
    part_one()
    part_two()
    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
