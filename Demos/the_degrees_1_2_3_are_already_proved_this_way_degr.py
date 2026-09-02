"""
Finite certificates for universal polynomial identities
=======================================================

Numerical demonstration of the results:

  * degree-graded exactness on the box grid {0,...,d}^n            (Section 3)
  * sharpness: d points per coordinate never suffice               (Theorem 3.6)
  * completeness / decidability of the finite check                (Section 4)
  * no uniqueness set of <= d points                               (Theorem 5.1)
  * dimension lower bound  C(n+d, n)                               (Theorem 5.3)
  * simplex-lattice unisolvence and its minimality                 (Section 6)
  * the exact characteristic threshold (Artin-Schreier witness)    (Theorem 6.4)
  * per-variable / multilinear refinement (Boolean cube)           (Section 7)
  * downset and weighted (quasi-homogeneous) certificates          (Section 9)
  * downset interpolation: existence and uniqueness                (Theorem 9.4)
  * downsets are strictly finer than weighted sublevel sets        (Prop. 9.8)

Everything is exact integer / rational arithmetic; no external dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from math import comb, factorial
from typing import Callable, Dict, Iterable, Iterator, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The reflective chart calculus: expression trees
# ----------------------------------------------------------------------------

Point = Tuple[int, ...]
Exponent = Tuple[int, ...]


@dataclass(frozen=True)
class Expr:
    """A formal polynomial expression tree.

    kind is one of 'var', 'const', 'add', 'mul', 'neg'.
      * 'var'   : payload is the variable index (int)
      * 'const' : payload is an integer constant
      * others  : payload is a tuple of child expressions
    """

    kind: str
    payload: object

    # --- constructors -------------------------------------------------------
    @staticmethod
    def var(i: int) -> "Expr":
        return Expr("var", i)

    @staticmethod
    def const(c: int) -> "Expr":
        return Expr("const", c)

    def __add__(self, other: "Expr") -> "Expr":
        return Expr("add", (self, other))

    def __mul__(self, other: "Expr") -> "Expr":
        return Expr("mul", (self, other))

    def __neg__(self) -> "Expr":
        return Expr("neg", (self,))

    def __sub__(self, other: "Expr") -> "Expr":
        return self + (-other)

    def __pow__(self, k: int) -> "Expr":
        out = Expr.const(1)
        for _ in range(k):
            out = out * self
        return out

    # --- pretty printing ----------------------------------------------------
    def __str__(self) -> str:
        if self.kind == "var":
            return "x" + str(self.payload)
        if self.kind == "const":
            return str(self.payload)
        if self.kind == "add":
            a, b = self.payload  # type: ignore[misc]
            return f"({a} + {b})"
        if self.kind == "mul":
            a, b = self.payload  # type: ignore[misc]
            return f"({a}*{b})"
        a, = self.payload  # type: ignore[misc]
        return f"(-{a})"


def evaluate(e: Expr, x: Sequence[int], modulus: int | None = None) -> int:
    """Evaluate the expression at an integer point, optionally mod `modulus`."""

    def red(v: int) -> int:
        return v % modulus if modulus is not None else v

    if e.kind == "var":
        return red(x[e.payload])  # type: ignore[index]
    if e.kind == "const":
        return red(e.payload)  # type: ignore[arg-type]
    if e.kind == "add":
        a, b = e.payload  # type: ignore[misc]
        return red(evaluate(a, x, modulus) + evaluate(b, x, modulus))
    if e.kind == "mul":
        a, b = e.payload  # type: ignore[misc]
        return red(evaluate(a, x, modulus) * evaluate(b, x, modulus))
    a, = e.payload  # type: ignore[misc]
    return red(-evaluate(a, x, modulus))


# --- syntactic shape invariants (structural recursion, no expansion) --------

def total_degree(e: Expr) -> int:
    if e.kind == "var":
        return 1
    if e.kind == "const":
        return 0
    if e.kind == "add":
        a, b = e.payload  # type: ignore[misc]
        return max(total_degree(a), total_degree(b))
    if e.kind == "mul":
        a, b = e.payload  # type: ignore[misc]
        return total_degree(a) + total_degree(b)
    a, = e.payload  # type: ignore[misc]
    return total_degree(a)


def multidegree(e: Expr, n: int) -> Tuple[int, ...]:
    if e.kind == "var":
        return tuple(1 if i == e.payload else 0 for i in range(n))
    if e.kind == "const":
        return tuple(0 for _ in range(n))
    if e.kind == "add":
        a, b = e.payload  # type: ignore[misc]
        return tuple(max(u, v) for u, v in zip(multidegree(a, n), multidegree(b, n)))
    if e.kind == "mul":
        a, b = e.payload  # type: ignore[misc]
        return tuple(u + v for u, v in zip(multidegree(a, n), multidegree(b, n)))
    a, = e.payload  # type: ignore[misc]
    return multidegree(a, n)


def weighted_degree(e: Expr, w: Sequence[int]) -> int:
    if e.kind == "var":
        return w[e.payload]  # type: ignore[index]
    if e.kind == "const":
        return 0
    if e.kind == "add":
        a, b = e.payload  # type: ignore[misc]
        return max(weighted_degree(a, w), weighted_degree(b, w))
    if e.kind == "mul":
        a, b = e.payload  # type: ignore[misc]
        return weighted_degree(a, w) + weighted_degree(b, w)
    a, = e.payload  # type: ignore[misc]
    return weighted_degree(a, w)


# --- the generic value: expand to a dictionary exponent -> coefficient ------

def denotation(e: Expr, n: int) -> Dict[Exponent, int]:
    """The generic value of the expression, as a polynomial over the integers."""
    if e.kind == "var":
        exp = tuple(1 if i == e.payload else 0 for i in range(n))
        return {exp: 1}
    if e.kind == "const":
        c = int(e.payload)  # type: ignore[arg-type]
        return {tuple(0 for _ in range(n)): c} if c != 0 else {}
    if e.kind == "add":
        a, b = e.payload  # type: ignore[misc]
        out = dict(denotation(a, n))
        for exp, c in denotation(b, n).items():
            out[exp] = out.get(exp, 0) + c
        return {k: v for k, v in out.items() if v != 0}
    if e.kind == "mul":
        a, b = e.payload  # type: ignore[misc]
        out: Dict[Exponent, int] = {}
        for ea, ca in denotation(a, n).items():
            for eb, cb in denotation(b, n).items():
                exp = tuple(u + v for u, v in zip(ea, eb))
                out[exp] = out.get(exp, 0) + ca * cb
        return {k: v for k, v in out.items() if v != 0}
    a, = e.payload  # type: ignore[misc]
    return {k: -v for k, v in denotation(a, n).items()}


# ----------------------------------------------------------------------------
# 2. Node sets
# ----------------------------------------------------------------------------

def box_nodes(n: int, d: int) -> List[Point]:
    """The box grid {0,...,d}^n:  (d+1)^n points."""
    return list(product(range(d + 1), repeat=n))


def rect_nodes(bounds: Sequence[int]) -> List[Point]:
    """The rectangular box prod_i {0,...,D_i}:  prod_i (D_i+1) points."""
    return list(product(*[range(b + 1) for b in bounds]))


def simplex_nodes(n: int, d: int) -> List[Point]:
    """The simplex lattice {a in N^n : sum a_i <= d}:  C(n+d, n) points."""
    if n == 0:
        return [()]
    out: List[Point] = []
    for k in range(d + 1):
        for tail in simplex_nodes(n - 1, d - k):
            out.append((k,) + tail)
    return out


def weighted_nodes(w: Sequence[int], d: int) -> List[Point]:
    """The weighted simplex {a : sum_i w_i a_i <= d} (requires all w_i >= 1)."""
    if len(w) == 0:
        return [()]
    out: List[Point] = []
    k = 0
    while k * w[0] <= d:
        for tail in weighted_nodes(w[1:], d - k * w[0]):
            out.append((k,) + tail)
        k += 1
    return out


def downset_closure(maximal: Iterable[Exponent]) -> List[Exponent]:
    """All componentwise-smaller vectors: the downset generated by `maximal`."""
    out = set()
    for m in maximal:
        for a in product(*[range(v + 1) for v in m]):
            out.add(tuple(a))
    return sorted(out)


def is_downset(nodes: Iterable[Exponent]) -> bool:
    s = set(nodes)
    for a in s:
        for i in range(len(a)):
            if a[i] > 0:
                b = list(a)
                b[i] -= 1
                if tuple(b) not in s:
                    return False
    return True


# ----------------------------------------------------------------------------
# 3. Certificates
# ----------------------------------------------------------------------------

def certificate(e1: Expr, e2: Expr, nodes: Sequence[Point],
                modulus: int | None = None) -> bool:
    """Do the two expressions agree at every node?  (exact integer check)"""
    return all(evaluate(e1, p, modulus) == evaluate(e2, p, modulus) for p in nodes)


def universal_identity_holds(e1: Expr, e2: Expr, n: int) -> bool:
    """Decide validity in EVERY commutative ring, via the box-grid certificate."""
    d = max(total_degree(e1), total_degree(e2))
    return certificate(e1, e2, box_nodes(n, d))


def denotations_agree(e1: Expr, e2: Expr, n: int) -> bool:
    """Ground truth: equality of generic values, by full expansion."""
    return denotation(e1, n) == denotation(e2, n)


# ----------------------------------------------------------------------------
# 4. Linear algebra over the rationals (for interpolation / rank counts)
# ----------------------------------------------------------------------------

def rank(matrix: List[List[Fraction]]) -> int:
    """Exact rank by Gaussian elimination over the rationals."""
    m = [row[:] for row in matrix]
    rows, cols = len(m), (len(m[0]) if m else 0)
    r = 0
    for c in range(cols):
        piv = next((i for i in range(r, rows) if m[i][c] != 0), None)
        if piv is None:
            continue
        m[r], m[piv] = m[piv], m[r]
        inv = Fraction(1) / m[r][c]
        m[r] = [v * inv for v in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                f = m[i][c]
                m[i] = [a - f * b for a, b in zip(m[i], m[r])]
        r += 1
        if r == rows:
            break
    return r


def vandermonde(nodes: Sequence[Point], exponents: Sequence[Exponent]) -> List[List[Fraction]]:
    """Rows indexed by nodes, columns by exponents: entry = node^exponent."""
    return [[Fraction(
        int(prod_pow(p, a))) for a in exponents] for p in nodes]


def prod_pow(p: Sequence[int], a: Exponent) -> int:
    out = 1
    for v, k in zip(p, a):
        out *= v ** k
    return out


def solve_interpolation(nodes: Sequence[Point], exponents: Sequence[Exponent],
                        values: Sequence[Fraction]) -> List[Fraction] | None:
    """Solve the square interpolation system, or return None if singular."""
    n = len(nodes)
    assert n == len(exponents)
    aug = [row[:] + [values[i]] for i, row in enumerate(vandermonde(nodes, exponents))]
    for c in range(n):
        piv = next((i for i in range(c, n) if aug[i][c] != 0), None)
        if piv is None:
            return None
        aug[c], aug[piv] = aug[piv], aug[c]
        inv = Fraction(1) / aug[c][c]
        aug[c] = [v * inv for v in aug[c]]
        for i in range(n):
            if i != c and aug[i][c] != 0:
                f = aug[i][c]
                aug[i] = [a - f * b for a, b in zip(aug[i], aug[c])]
    return [aug[i][n] for i in range(n)]


# ----------------------------------------------------------------------------
# 5. The worked identities
# ----------------------------------------------------------------------------

x0, x1, x2 = Expr.var(0), Expr.var(1), Expr.var(2)
THREE = Expr.const(3)

CUBE_LHS = (x0 + x1) ** 3
CUBE_RHS = x0 ** 3 + THREE * (x0 ** 2 * x1) + THREE * (x0 * x1 ** 2) + x1 ** 3

QUARTIC_LHS = ((x0 + x1) ** 2) * ((x0 - x1) ** 2)
QUARTIC_RHS = (x0 ** 2 - x1 ** 2) ** 2

SYM_LHS = x0 ** 3 + x1 ** 3 + x2 ** 3 - THREE * (x0 * x1 * x2)
SYM_RHS = (x0 + x1 + x2) * (x0 ** 2 + x1 ** 2 + x2 ** 2
                            - x0 * x1 - x1 * x2 - x2 * x0)

INCEXCL_LHS = (Expr.const(1) - x0) * (Expr.const(1) - x1)
INCEXCL_RHS = Expr.const(1) - x0 - x1 + x0 * x1

QUASI_LHS = (x0 ** 2 + x1) * (x0 ** 2 - x1)
QUASI_RHS = x0 ** 4 - x1 ** 2

# A deliberately FALSE identity, to show completeness (no false positives).
FAKE_LHS = (x0 + x1) ** 3
FAKE_RHS = x0 ** 3 + THREE * (x0 ** 2 * x1) + THREE * (x0 * x1 ** 2) + x1 ** 3 + Expr.const(1)


def root_product(d: int) -> Expr:
    """x(x-1)...(x-(d-1)):  degree d, vanishing on the d-point grid {0,...,d-1}."""
    out = Expr.const(1)
    for k in range(d):
        out = out * (x0 - Expr.const(k))
    return out


# ----------------------------------------------------------------------------
# 6. Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_box_certificates() -> None:
    banner("1. Degree-graded exactness: box-grid certificates")
    cases = [
        ("(a+b)^3 = a^3+3a^2b+3ab^2+b^3", CUBE_LHS, CUBE_RHS, 2),
        ("(a+b)^2(a-b)^2 = (a^2-b^2)^2", QUARTIC_LHS, QUARTIC_RHS, 2),
        ("a^3+b^3+c^3-3abc = (a+b+c)(a^2+b^2+c^2-ab-bc-ca)", SYM_LHS, SYM_RHS, 3),
    ]
    for name, lhs, rhs, n in cases:
        d = max(total_degree(lhs), total_degree(rhs))
        nodes = box_nodes(n, d)
        ok = certificate(lhs, rhs, nodes)
        truth = denotations_agree(lhs, rhs, n)
        print(f"  {name}")
        print(f"    n = {n}, syntactic degree bound d = {d}, "
              f"box points = (d+1)^n = {len(nodes)}")
        print(f"    certificate passes: {ok};  generic values equal: {truth}")
        assert ok == truth
        print("    => identity holds in EVERY commutative ring." if ok else "")

    print("\n  Completeness has no false positives.  A perturbed identity:")
    d = max(total_degree(FAKE_LHS), total_degree(FAKE_RHS))
    nodes = box_nodes(2, d)
    bad = [p for p in nodes if evaluate(FAKE_LHS, p) != evaluate(FAKE_RHS, p)]
    print(f"    (a+b)^3 = a^3+3a^2b+3ab^2+b^3 + 1 : certificate passes ="
          f" {certificate(FAKE_LHS, FAKE_RHS, nodes)}")
    print(f"    first witnessing node: {bad[0]}, "
          f"values {evaluate(FAKE_LHS, bad[0])} != {evaluate(FAKE_RHS, bad[0])}")
    assert not certificate(FAKE_LHS, FAKE_RHS, nodes)


def demo_sharpness() -> None:
    banner("2. Sharpness: d points per coordinate never suffice")
    print("   e_1 = x(x-1)...(x-(d-1)),  e_2 = 0")
    for d in range(1, 7):
        e = root_product(d)
        short = [(k,) for k in range(d)]          # only d points
        full = [(k,) for k in range(d + 1)]       # d+1 points
        zero = Expr.const(0)
        print(f"    d = {d}:  deg = {total_degree(e)},"
              f"  agrees on {{0..{d-1}}} ({len(short)} pts): {certificate(e, zero, short)},"
              f"  on {{0..{d}}} ({len(full)} pts): {certificate(e, zero, full)}"
              f"   [value at x={d} is {evaluate(e, (d,))} = {d}!]")
        assert certificate(e, zero, short)
        assert not certificate(e, zero, full)
        assert evaluate(e, (d,)) == factorial(d)


def demo_no_small_uniqueness_set() -> None:
    banner("3. No uniqueness set of at most d points (any domain)")
    print("   For any T with |T| <= d, the polynomial prod_{t in T} (x_1 - t_1)")
    print("   is nonzero of total degree <= d and vanishes on all of T.")
    T: List[Point] = [(2, 5), (-3, 1), (7, 7)]     # 3 cleverly chosen points
    d = 3
    witness = Expr.const(1)
    for t in T:
        witness = witness * (x0 - Expr.const(t[0]))
    print(f"    T = {T}   (|T| = {len(T)} <= d = {d})")
    print(f"    witness = {witness}")
    print(f"    total degree = {total_degree(witness)}")
    print(f"    values on T  = {[evaluate(witness, t) for t in T]}")
    print(f"    nonzero?     = {denotation(witness, 2) != {}}  "
          f"(e.g. value at (0,0) is {evaluate(witness, (0, 0))})")
    assert all(evaluate(witness, t) == 0 for t in T)
    assert denotation(witness, 2) != {}


def demo_simplex() -> None:
    banner("4. The simplex lattice: an optimal node set")
    print("   |S(n,d)| = C(n+d, n) = number of monomials of total degree <= d")
    print(f"   {'n':>2} {'d':>2} {'box (d+1)^n':>12} {'simplex C(n+d,n)':>18} {'saving':>9}")
    for n in range(1, 5):
        for d in range(1, 5):
            box, simp = (d + 1) ** n, comb(n + d, n)
            assert len(simplex_nodes(n, d)) == simp
            assert len(box_nodes(n, d)) == box
            print(f"   {n:>2} {d:>2} {box:>12} {simp:>18} {box - simp:>9}")

    print("\n   Simplex certificates for the worked identities:")
    for name, lhs, rhs, n in [
        ("(a+b)^3 expansion", CUBE_LHS, CUBE_RHS, 2),
        ("a^3+b^3+c^3-3abc factorisation", SYM_LHS, SYM_RHS, 3),
    ]:
        d = max(total_degree(lhs), total_degree(rhs))
        nodes = simplex_nodes(n, d)
        ok = certificate(lhs, rhs, nodes)
        print(f"     {name}: {len(nodes)} simplex points "
              f"(box would need {(d+1)**n}), passes = {ok}")
        assert ok and denotations_agree(lhs, rhs, n)

    print("\n   Unisolvence, checked by rank: the Vandermonde matrix of the")
    print("   simplex nodes against the monomials of degree <= d is invertible.")
    for n, d in [(2, 3), (3, 3), (2, 4)]:
        nodes = simplex_nodes(n, d)
        exps = simplex_nodes(n, d)      # same index set
        r = rank(vandermonde(nodes, exps))
        print(f"     n={n}, d={d}: matrix {len(nodes)}x{len(exps)}, rank = {r}"
              f"  -> {'unisolvent' if r == len(nodes) else 'DEGENERATE'}")
        assert r == len(nodes)

    print("\n   Minimality: any node set with fewer than C(n+d,n) points admits a")
    print("   nonzero polynomial of degree <= d vanishing on it (rank deficiency).")
    n, d = 2, 3
    exps = simplex_nodes(n, d)
    short = simplex_nodes(n, d)[:-1]     # one point too few
    r = rank(vandermonde(short, exps))
    print(f"     n={n}, d={d}: {len(short)} points vs {len(exps)} monomials,"
          f" rank = {r} < {len(exps)}  -> kernel is nonzero")
    assert r < len(exps)


def demo_characteristic() -> None:
    banner("5. The exact characteristic threshold (Artin-Schreier witness)")
    print("   Over a field of characteristic p, x^p - x vanishes at every")
    print("   lattice node, so the simplex lattice fails as soon as d >= p.")
    for p in (2, 3, 5, 7):
        witness = x0 ** p - x0
        nodes = simplex_nodes(2, p)          # d = p  >= p
        vals = {evaluate(witness, t, modulus=p) for t in nodes}
        print(f"     p = {p}: d = {p} >= p;  x^{p} - x has total degree {p};"
              f"  values mod {p} on the {len(nodes)} nodes: {vals}")
        assert vals == {0}
    print("\n   Below the characteristic the lattice still works: for p = 7, d = 3")
    print("   the nodes 0..3 remain distinct mod 7, so unisolvence is intact.")
    print(f"     images of 0,1,2,3 mod 7 = {[k % 7 for k in range(4)]} (all distinct)")


def demo_multilinear() -> None:
    banner("6. Per-variable refinement: the Boolean cube")
    n = 2
    md_l = multidegree(INCEXCL_LHS, n)
    md_r = multidegree(INCEXCL_RHS, n)
    cube = rect_nodes([1] * n)
    ok = certificate(INCEXCL_LHS, INCEXCL_RHS, cube)
    print("   (1-a)(1-b) = 1 - a - b + ab")
    print(f"     per-variable degrees: lhs {md_l}, rhs {md_r}  -> multilinear")
    print(f"     Boolean cube {{0,1}}^{n}: {len(cube)} points, passes = {ok}")
    print(f"     total-degree box would need (2+1)^{n} = {3**n} points")
    assert ok and denotations_agree(INCEXCL_LHS, INCEXCL_RHS, n)

    print("\n   Growth of the saving 2^n  vs  (n+1)^n for multilinear expressions:")
    for n in range(2, 8):
        print(f"     n = {n}: cube {2**n:>8}   total-degree grid {(n+1)**n:>12}")
        assert 2 ** n < (n + 1) ** n


def demo_weighted() -> None:
    banner("7. Weighted (quasi-homogeneous) certificates")
    w = (1, 2)
    d = max(weighted_degree(QUASI_LHS, w), weighted_degree(QUASI_RHS, w))
    wn = weighted_nodes(w, d)
    sn = simplex_nodes(2, max(total_degree(QUASI_LHS), total_degree(QUASI_RHS)))
    bn = box_nodes(2, max(total_degree(QUASI_LHS), total_degree(QUASI_RHS)))
    ok = certificate(QUASI_LHS, QUASI_RHS, wn)
    print("   (a^2 + b)(a^2 - b) = a^4 - b^2,  weights w = (1,2)")
    print(f"     weighted degree bound d = {d}")
    print(f"     weighted node set : {len(wn):>3} points  {sorted(wn)}")
    print(f"     total-deg simplex : {len(sn):>3} points")
    print(f"     box grid          : {len(bn):>3} points")
    print(f"     weighted certificate passes = {ok}")
    assert ok and denotations_agree(QUASI_LHS, QUASI_RHS, 2)
    assert len(wn) == 9 and len(sn) == 15 and len(bn) == 25

    print("\n   The saving is unbounded as the weights grow"
          " (w = (1,k), d = 2k for a^2 vs b):")
    for k in (2, 3, 5, 8):
        wn_k = weighted_nodes((1, k), 2 * k)
        sn_k = simplex_nodes(2, 2 * k)
        print(f"     k = {k:>2}: weighted {len(wn_k):>4} points,"
              f" total-degree simplex {len(sn_k):>4} points")


def demo_downsets() -> None:
    banner("8. Downsets: support-adapted node sets")
    print("   A downset is closed under decreasing any coordinate.")
    staircase = downset_closure([(3, 0), (1, 1), (0, 2)])
    print(f"     example downset D = {staircase}   (|D| = {len(staircase)})")
    print(f"     is a downset: {is_downset(staircase)}")
    r = rank(vandermonde(staircase, staircase))
    print(f"     evaluation matrix {len(staircase)}x{len(staircase)}: rank = {r}"
          f"  -> {'unisolvent' if r == len(staircase) else 'DEGENERATE'}")
    assert r == len(staircase)

    print("\n   Downset interpolation: existence AND uniqueness.")
    targets = [Fraction(v) for v in (1, -2, 3, 0, 5, -1, 4)][:len(staircase)]
    coeffs = solve_interpolation(staircase, staircase, targets)
    assert coeffs is not None
    print("     prescribed values :", [str(t) for t in targets])
    recon = [sum(c * Fraction(prod_pow(p, a)) for c, a in zip(coeffs, staircase))
             for p in staircase]
    print("     interpolated back :", [str(v) for v in recon])
    print("     coefficients      :",
          {a: str(c) for a, c in zip(staircase, coeffs) if c != 0})
    assert recon == targets

    print("\n   Downsets are strictly finer than weighted sublevel sets"
          " (Proposition 9.8).")
    cross = downset_closure([(2, 0), (0, 2)])
    print(f"     D = {cross}, a0 = (1,1) not in D")
    assert (1, 1) not in cross and is_downset(cross)
    offenders = 0
    for w1 in range(1, 9):
        for w2 in range(1, 9):
            for dd in range(0, 40):
                if all(w1 * a + w2 * b <= dd for a, b in cross):
                    # every weighted simplex containing D contains (1,1)
                    assert w1 + w2 <= dd
                    offenders += 1
    print(f"     checked {offenders} weighted sublevel sets containing D;"
          f" every one also contains (1,1).")

    print("\n   Both classical shapes are downsets:")
    print(f"     simplex S(2,3) is a downset: {is_downset(simplex_nodes(2, 3))}")
    print(f"     box {{0..2}}^2  is a downset: {is_downset(box_nodes(2, 2))}")
    print(f"     weighted W((1,2),4) is a downset:"
          f" {is_downset(weighted_nodes((1, 2), 4))}")


def demo_decision_procedure() -> None:
    banner("9. The decision procedure in action")
    tests: List[Tuple[str, Expr, Expr, int]] = [
        ("(a+b)^3 == a^3+3a^2b+3ab^2+b^3", CUBE_LHS, CUBE_RHS, 2),
        ("(a+b)^3 == a^3+3a^2b+3ab^2+b^3+1", FAKE_LHS, FAKE_RHS, 2),
        ("(a+b)^2(a-b)^2 == (a^2-b^2)^2", QUARTIC_LHS, QUARTIC_RHS, 2),
        ("(a+b)^2 == a^2+b^2", (x0 + x1) ** 2, x0 ** 2 + x1 ** 2, 2),
        ("a(b+c) == ab+ac", x0 * (x1 + x2), x0 * x1 + x0 * x2, 3),
        ("a^2-b^2 == (a-b)(a+b)", x0 ** 2 - x1 ** 2, (x0 - x1) * (x0 + x1), 2),
    ]
    print(f"   {'identity':<40} {'points':>8} {'decision':>10} {'truth':>8}")
    for name, lhs, rhs, n in tests:
        d = max(total_degree(lhs), total_degree(rhs))
        pts = comb(n + d, n)
        verdict = certificate(lhs, rhs, simplex_nodes(n, d))
        truth = denotations_agree(lhs, rhs, n)
        print(f"   {name:<40} {pts:>8} {str(verdict):>10} {str(truth):>8}")
        assert verdict == truth


def demo_dimension_counts() -> None:
    banner("10. Dimension counts: interpolation on a box grid")
    print("   dim { p : deg_{x_i} p <= b for all i } = (b+1)^n,")
    print("   verified as the rank of the grid evaluation matrix.")
    for n, b in [(1, 3), (2, 2), (2, 3), (3, 1)]:
        nodes = rect_nodes([b] * n)
        exps = rect_nodes([b] * n)
        r = rank(vandermonde(nodes, exps))
        print(f"     n={n}, b={b}: (b+1)^n = {(b+1)**n:>3}, rank = {r:>3}"
              f"  -> {'isomorphism' if r == (b+1)**n else 'FAILS'}")
        assert r == (b + 1) ** n


def main() -> None:
    print(__doc__)
    demo_box_certificates()
    demo_sharpness()
    demo_no_small_uniqueness_set()
    demo_simplex()
    demo_characteristic()
    demo_multilinear()
    demo_weighted()
    demo_downsets()
    demo_decision_procedure()
    demo_dimension_counts()
    banner("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
