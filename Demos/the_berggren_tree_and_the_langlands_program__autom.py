"""
The Berggren tree over Q(sqrt 2): silver units, the boundary Hecke algebra,
and the three obstructions to automorphy.

Self-contained numerical demonstration of every result in the accompanying paper.
Pure standard library (exact integer arithmetic wherever possible); no dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import isqrt, sqrt
from typing import Dict, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]
Quad = Tuple[int, int]  # x + y*sqrt(2)  <->  (x, y)

# ----------------------------------------------------------------------------
# 1. The three Berggren generators (integral isometries of a^2 + b^2 - c^2)
# ----------------------------------------------------------------------------

MAT_A: Tuple[Tuple[int, ...], ...] = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
MAT_B: Tuple[Tuple[int, ...], ...] = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
MAT_C: Tuple[Tuple[int, ...], ...] = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))

GENERATORS: Dict[str, Tuple[Tuple[int, ...], ...]] = {"A": MAT_A, "B": MAT_B, "C": MAT_C}
ROOT: Triple = (3, 4, 5)


def apply_matrix(m: Sequence[Sequence[int]], v: Triple) -> Triple:
    """Apply a 3x3 integer matrix to a triple."""
    return (
        m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
        m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
        m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
    )


def apply_word(word: str, v: Triple = ROOT) -> Triple:
    """Apply the letters of `word` (left-to-right, outermost first) to `v`."""
    out = v
    for letter in reversed(word):
        out = apply_matrix(GENERATORS[letter], out)
    return out


def is_pythagorean(v: Triple) -> bool:
    a, b, c = v
    return a * a + b * b == c * c


def preserves_lorentz(m: Sequence[Sequence[int]]) -> bool:
    """Check M^T diag(1,1,-1) M = diag(1,1,-1)."""
    q = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]
    for i in range(3):
        for j in range(3):
            s = sum(m[k][i] * q[k][k] * m[k][j] for k in range(3))
            if s != q[i][j]:
                return False
    return True


# ----------------------------------------------------------------------------
# 2. Exact arithmetic in Z[sqrt 2]
# ----------------------------------------------------------------------------

def z2_mul(u: Quad, v: Quad) -> Quad:
    """(x1 + y1 r2)(x2 + y2 r2) = (x1x2 + 2 y1y2) + (x1y2 + x2y1) r2."""
    return (u[0] * v[0] + 2 * u[1] * v[1], u[0] * v[1] + u[1] * v[0])


def z2_pow(u: Quad, n: int) -> Quad:
    out: Quad = (1, 0)
    base = u
    while n > 0:
        if n & 1:
            out = z2_mul(out, base)
        base = z2_mul(base, base)
        n >>= 1
    return out


def z2_norm(u: Quad) -> int:
    """N(x + y sqrt2) = x^2 - 2 y^2."""
    return u[0] * u[0] - 2 * u[1] * u[1]


def z2_is_unit(u: Quad) -> bool:
    return z2_norm(u) in (1, -1)


def z2_float(u: Quad) -> float:
    return u[0] + u[1] * sqrt(2.0)


def silver_coordinate(v: Triple) -> Quad:
    """zeta(a,b,c) = (a+b) + c sqrt2."""
    a, b, c = v
    return (a + b, c)


SILVER: Quad = (1, 1)        # 1 + sqrt2, the fundamental unit
LAMBDA: Quad = (3, 2)        # 3 + 2 sqrt2 = (1 + sqrt2)^2
LAMBDA_BAR: Quad = (3, -2)   # 3 - 2 sqrt2


# ----------------------------------------------------------------------------
# 3. The tree, its spine, and the unit locus
# ----------------------------------------------------------------------------

def words(depth: int) -> Iterator[str]:
    """All addresses of length exactly `depth` (empty word for depth 0)."""
    if depth == 0:
        yield ""
        return
    for tup in product("ABC", repeat=depth):
        yield "".join(tup)


def spine(n: int) -> Triple:
    """n-th node of the all-B branch."""
    return apply_word("B" * n)


def leg_difference(v: Triple) -> int:
    return v[0] - v[1]


# ----------------------------------------------------------------------------
# 4. The boundary Hecke algebra at finite depth
# ----------------------------------------------------------------------------

def hecke_matrix_depth(k: int) -> List[List[int]]:
    """
    Matrix of H = U T restricted to observables depending only on the first k letters
    of a boundary address, in the basis of depth-k cylinder indicators.

    On the boundary, (T f)(w) = sum_x f(x w) and (U f)(w) = f(sigma w), so
      (H f)(w) = (U T f)(w) = sum_x f(x . sigma w) = sum_x f(x w1 w2 ... ),
    which only ever reads the first k letters of w if f does.  Hence H preserves the
    depth-k subspace and acts there by the displayed matrix.
    """
    idx = {w: i for i, w in enumerate(words(k))}
    n = len(idx)
    mat = [[0] * n for _ in range(n)]
    for w, i in idx.items():
        tail = w[1:]                      # drop first letter: sigma w
        for x in "ABC":
            j = idx[x + tail]             # prepend x
            mat[i][j] += 1
    return mat


def matrix_eigenvalues_integer(mat: List[List[int]]) -> Dict[int, int]:
    """
    Exact spectrum for the specific structure at hand: H satisfies H^2 = 3H, so its
    eigenvalues are 0 and 3.  We verify H^2 = 3H exactly and compute multiplicities
    as rank(H) (eigenvalue 3) and n - rank(H) (eigenvalue 0).
    """
    n = len(mat)
    sq = [[sum(mat[i][t] * mat[t][j] for t in range(n)) for j in range(n)] for i in range(n)]
    assert all(sq[i][j] == 3 * mat[i][j] for i in range(n) for j in range(n)), "H^2 = 3H failed"
    r = rank_fraction([[Fraction(x) for x in row] for row in mat])
    return {3: r, 0: n - r}


def rank_fraction(mat: List[List[Fraction]]) -> int:
    """Exact rank by Gaussian elimination over the rationals."""
    m = [row[:] for row in mat]
    rows, cols = len(m), len(m[0])
    r = 0
    for c in range(cols):
        piv = None
        for i in range(r, rows):
            if m[i][c] != 0:
                piv = i
                break
        if piv is None:
            continue
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][c]
        m[r] = [x / inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                f = m[i][c]
                m[i] = [a - f * b for a, b in zip(m[i], m[r])]
        r += 1
        if r == rows:
            break
    return r


# ----------------------------------------------------------------------------
# 5. Demonstrations
# ----------------------------------------------------------------------------

def demo_generators() -> None:
    print("=" * 78)
    print("1. THE THREE GENERATORS PRESERVE a^2 + b^2 - c^2")
    print("=" * 78)
    for name, m in GENERATORS.items():
        print(f"  {name}: Lorentz-orthogonal = {preserves_lorentz(m)},  "
              f"trace = {sum(m[i][i] for i in range(3))}")
    print(f"  root {ROOT} is Pythagorean: {is_pythagorean(ROOT)}")
    for w in ("A", "B", "C", "BA", "AB", "CBA"):
        v = apply_word(w)
        print(f"  word {w:>3} -> {str(v):>20}  Pythagorean: {is_pythagorean(v)}")
    print("  Note tr A = tr C = 3, tr B = 5: all rational integers.")
    print("  => Obstruction I: the invariant trace field of the tree is Q,")
    print("     while SL(2, Z[sqrt2]) contains an element of trace 1 + sqrt2")
    print(f"     (adjoint trace (1+sqrt2)^2 - 1 = 2 + 2sqrt2 = {2 + 2*sqrt(2):.6f}, irrational).")
    print()


def demo_silver_intertwining() -> None:
    print("=" * 78)
    print("2. THE SILVER COORDINATE INTERTWINES B WITH MULTIPLICATION BY 3 + 2 sqrt2")
    print("=" * 78)
    print("   zeta(a,b,c) = (a+b) + c sqrt2  in  Z[sqrt2]")
    for w in ("", "B", "BB", "AC", "CBA"):
        v = apply_word(w)
        zv = silver_coordinate(v)
        zbv = silver_coordinate(apply_word("B" + w))
        ok = zbv == z2_mul(LAMBDA, zv)
        label = w if w else "(root)"
        print(f"  node {label:>5}: zeta = {zv[0]:>7} + {zv[1]:>7} sqrt2   "
              f"zeta(Bv) = lambda * zeta(v): {ok}")
    print()


def demo_spine_pell() -> None:
    print("=" * 78)
    print("3. THE SPINE IS THE UNIT ORBIT AND SOLVES THE NEGATIVE PELL EQUATION")
    print("=" * 78)
    print(f"  {'n':>2}  {'(a,b,c)':>28}  {'(a+b)^2-2c^2':>13}  {'|a-b|':>5}  "
          f"{'zeta = (1+sqrt2)^(2n+3)':>24}  {'c_{n+1}/c_n':>12}")
    prev_c = None
    for n in range(9):
        v = spine(n)
        z = silver_coordinate(v)
        ratio = "" if prev_c is None else f"{v[2] / prev_c:.9f}"
        matches = z == z2_pow(SILVER, 2 * n + 3)
        print(f"  {n:>2}  {str(v):>28}  {z2_norm(z):>13}  {abs(v[0]-v[1]):>5}  "
              f"{str(matches):>24}  {ratio:>12}")
        prev_c = v[2]
    print(f"  limit ratio 3 + 2 sqrt2 = {3 + 2*sqrt(2):.9f}")
    print("  Every spine node: norm(zeta) = -1  =>  a unit of Z[sqrt2],")
    print("  equivalently (a+b)^2 - 2c^2 = -1 (negative Pell), equivalently |a-b| = 1.")
    print()


def demo_binet() -> None:
    print("=" * 78)
    print("4. BINET FORMULA: THE EIGENVALUE IS THE GROWTH CONSTANT")
    print("=" * 78)
    lam = 3 + 2 * sqrt(2)
    alpha = (7 + 5 * sqrt(2)) / (2 * sqrt(2))
    beta = (7 - 5 * sqrt(2)) / (2 * sqrt(2))
    print(f"  alpha = (7+5sqrt2)/(2sqrt2) = {alpha:.10f}")
    print(f"  beta  = (7-5sqrt2)/(2sqrt2) = {beta:.10f}   (in (-1/2, 0))")
    print(f"  {'n':>2}  {'c_n (exact)':>14}  {'alpha*lambda^n':>18}  {'error':>12}  "
          f"{'nearest int ok':>14}")
    for n in range(10):
        c = spine(n)[2]
        approx = alpha * lam ** n
        print(f"  {n:>2}  {c:>14}  {approx:>18.6f}  {c - approx:>12.6f}  "
              f"{str(round(approx) == c):>14}")
    print("  Pell recursion c_{n+2} = 6 c_{n+1} - c_n:")
    cs = [spine(n)[2] for n in range(8)]
    print(f"    verified: {all(cs[n+2] == 6*cs[n+1] - cs[n] for n in range(6))}")
    print("  Euler factor (1 - (3+2sqrt2)x)(1 - (3-2sqrt2)x) = 1 - 6x + x^2:")
    prod_poly = z2_mul(LAMBDA, LAMBDA_BAR)
    sum_poly = (LAMBDA[0] + LAMBDA_BAR[0], LAMBDA[1] + LAMBDA_BAR[1])
    print(f"    product of parameters = {prod_poly} (= 1), sum = {sum_poly} (= 6)")
    print()


def demo_direction() -> None:
    print("=" * 78)
    print("5. THE SPINE CONVERGES TO THE IRRATIONAL BOUNDARY DIRECTION sqrt2")
    print("=" * 78)
    print(f"  identity ((a+b)/c)^2 = 2 - 1/c^2 checked exactly with Fractions")
    print(f"  {'n':>2}  {'(a+b)/c':>18}  {'((a+b)/c)^2 - (2 - 1/c^2)':>28}")
    for n in range(8):
        a, b, c = spine(n)
        r = Fraction(a + b, c)
        residual = r * r - (2 - Fraction(1, c * c))
        print(f"  {n:>2}  {float(r):>18.12f}  {str(residual):>28}")
    print(f"  sqrt2 = {sqrt(2):.12f}")
    print()


def demo_unit_locus(depth: int = 6) -> None:
    print("=" * 78)
    print("6. OBSTRUCTION III: THE UNIT LOCUS IS EXACTLY THE ALL-B GEODESIC")
    print("=" * 78)
    total = 0
    units = 0
    unit_words: List[str] = []
    for d in range(depth + 1):
        for w in words(d):
            v = apply_word(w)
            total += 1
            if z2_is_unit(silver_coordinate(v)):
                units += 1
                unit_words.append(w if w else "(root)")
    print(f"  nodes examined to depth {depth}: {total}")
    print(f"  nodes with unit silver coordinate: {units}")
    print(f"  their addresses: {unit_words}")
    print(f"  all are B-words: "
          f"{all(set(w) <= {'B'} for w in unit_words if w != '(root)')}")
    print("  norm identity N(zeta) = -(a-b)^2 on the cone, sample check:")
    for w in ("BA", "AB", "C", "BBC", "BBB"):
        v = apply_word(w)
        z = silver_coordinate(v)
        print(f"    {w:>4}: triple {str(v):>22}  N(zeta) = {z2_norm(z):>10}  "
              f"-(a-b)^2 = {-(v[0]-v[1])**2:>10}")
    print("  => In the boundary Cantor set the unit locus is the single point BBB...")
    print("     (Hausdorff dimension 0 inside a set of full dimension).")
    print()


def demo_hecke_spectrum(max_depth: int = 5) -> None:
    print("=" * 78)
    print("7. OBSTRUCTION II: THE BOUNDARY HECKE SPECTRUM IS EXACTLY {0, 3}")
    print("=" * 78)
    print("   T f(w) = sum_x f(x w),  U f(w) = f(sigma w),  TU = 3 id,  (UT)^2 = 3 (UT)")
    print(f"  {'depth k':>8}  {'dim':>6}  {'H^2 = 3H':>9}  {'mult(3)':>8}  {'mult(0)':>8}")
    for k in range(1, max_depth + 1):
        mat = hecke_matrix_depth(k)
        spec = matrix_eigenvalues_integer(mat)
        print(f"  {k:>8}  {len(mat):>6}  {'True':>9}  {spec[3]:>8}  {spec[0]:>8}")
    print("  No eigenvalue other than 0 and 3 exists, at any depth.")
    lam = 3 + 2 * sqrt(2)
    lam_bar = 3 - 2 * sqrt(2)
    print(f"  silver units: 3 + 2sqrt2 = {lam:.6f},  3 - 2sqrt2 = {lam_bar:.6f}")
    print(f"  neither is 0 or 3  =>  not Hecke eigenvalues of the boundary.")
    print()


def demo_temperedness() -> None:
    print("=" * 78)
    print("8. TEMPEREDNESS AND SATAKE NORMALIZATION BOTH FAIL")
    print("=" * 78)
    q = 2
    bound = 2 * sqrt(q)
    lam = 3 + 2 * sqrt(2)
    print(f"  residue cardinality of the ramified prime (sqrt2): q = {q}")
    print(f"  Ramanujan bound 2 sqrt(q) = {bound:.6f}")
    print(f"    actual boundary eigenvalue 3            : |3| = 3 > {bound:.6f} -> not tempered")
    print(f"    hypothetical eigenvalue 3 + 2 sqrt2     : {lam:.6f} > {bound:.6f} -> not tempered")
    print(f"  Satake product (3+2sqrt2)(3-2sqrt2) = {lam*(3-2*sqrt(2)):.12f} "
          f"(exactly {z2_mul(LAMBDA, LAMBDA_BAR)[0]}), but q = {q}")
    print("  => the pair is a unit pair of norm 1, not a Satake pair of an unramified")
    print("     representation of GL(2) with trivial central character.")
    print()


def demo_trichotomy(n_max: int = 6) -> None:
    print("=" * 78)
    print("9. SPECTRAL TRICHOTOMY: TWO PARABOLIC LETTERS, ONE HYPERBOLIC")
    print("=" * 78)
    print("  A and C are unipotent: char poly (X-1)^3, (M-I)^3 = 0 but (M-I)^2 != 0")
    print(f"    A fixes the rational cusp (0,1,1): {apply_word('A', (0,1,1)) == (0,1,1)}")
    print(f"    C fixes the rational cusp (1,0,1): {apply_word('C', (1,0,1)) == (1,0,1)}")
    print(f"    B moves both: {apply_word('B', (0,1,1))}, {apply_word('B', (1,0,1))}")
    print(f"  {'n':>2}  {'A^n root (quadratic)':>28}  {'C^n root (quadratic)':>28}  "
          f"{'B^n root (exponential)':>28}")
    for n in range(n_max + 1):
        va = apply_word("A" * n)
        vc = apply_word("C" * n)
        vb = apply_word("B" * n)
        assert va == (2*n+3, 2*n*n+6*n+4, 2*n*n+6*n+5)
        assert vc == (4*n*n+8*n+3, 4*n+4, 4*n*n+8*n+5)
        print(f"  {n:>2}  {str(va):>28}  {str(vc):>28}  {str(vb):>28}")
    print("  closed forms verified: A^n r = (2n+3, 2n^2+6n+4, 2n^2+6n+5),")
    print("                         C^n r = (4n^2+8n+3, 4n+4, 4n^2+8n+5).")
    print("  B has no rational light-like eigendirection: its ideal points are (1,1,+-sqrt2).")
    print()


def demo_eigenvectors() -> None:
    print("=" * 78)
    print("10. EIGEN-DECOMPOSITION OF B OVER Z[sqrt2]")
    print("=" * 78)
    # vectors with Z[sqrt2] entries, represented componentwise as Quad
    def apply_B_quad(v: Tuple[Quad, Quad, Quad]) -> Tuple[Quad, Quad, Quad]:
        def comb(row: Sequence[int]) -> Quad:
            x = sum(row[i] * v[i][0] for i in range(3))
            y = sum(row[i] * v[i][1] for i in range(3))
            return (x, y)
        return (comb(MAT_B[0]), comb(MAT_B[1]), comb(MAT_B[2]))

    tests = [
        ("(1, 1, sqrt2)", ((1, 0), (1, 0), (0, 1)), LAMBDA),
        ("(1, 1, -sqrt2)", ((1, 0), (1, 0), (0, -1)), LAMBDA_BAR),
        ("(1, -1, 0)", ((1, 0), (-1, 0), (0, 0)), (-1, 0)),
    ]
    for label, vec, eig in tests:
        img = apply_B_quad(vec)  # type: ignore[arg-type]
        expected = tuple(z2_mul(eig, comp) for comp in vec)
        q = (z2_mul(vec[0], vec[0])[0] + z2_mul(vec[1], vec[1])[0]
             - z2_mul(vec[2], vec[2])[0],)
        print(f"  B {label:>15} = ({eig[0]} + {eig[1]} sqrt2) * {label:<15} : {img == expected}"
              f"   Lorentz norm = {q[0]}")
    print("  char poly of B = (X + 1)(X^2 - 6X + 1); spin matrix [[2,1],[1,0]] has")
    print("  char poly X^2 - 2X - 1 with eigenvalues 1 +- sqrt2: the unit itself.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE BERGGREN TREE OVER Q(sqrt 2):")
    print("#  silver units, the boundary Hecke algebra, and three obstructions")
    print("#" * 78)
    print()
    demo_generators()
    demo_silver_intertwining()
    demo_spine_pell()
    demo_binet()
    demo_direction()
    demo_unit_locus()
    demo_hecke_spectrum()
    demo_temperedness()
    demo_trichotomy()
    demo_eigenvectors()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  POSITIVE: zeta(a,b,c) = (a+b) + c sqrt2 intertwines B with multiplication by")
    print("            3 + 2 sqrt2 = (1 + sqrt2)^2; the all-B spine is the unit orbit and")
    print("            solves the negative Pell equation (a+b)^2 - 2c^2 = -1.")
    print("  NEGATIVE: (I)  all Berggren traces are rational integers -> trace field Q;")
    print("            (II) the boundary Hecke spectrum is exactly {0, 3};")
    print("            (III) the unit locus in the boundary is the single point BBB...")
    print("  SLOGAN:   Q(sqrt2) is an eigenvalue field of the Berggren tree,")
    print("            not a field of definition.")
    print()


if __name__ == "__main__":
    main()
