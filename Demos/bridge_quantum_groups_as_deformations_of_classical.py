"""
Quantum groups as deformations of classical groups: numerical demonstrations.

Self-contained (standard library only).  Every routine below is inlined and
type-hinted, and each demonstration re-verifies, numerically or exactly, one of
the results of the accompanying paper:

  1. Quantum integers  [m]_q = (q^m - q^-m)/(q - q^-1)  ->  m           as q -> 1
  2. Gaussian binomials  C_q(n,j)  ->  binomial(n,j)                    as q -> 1
  3. The (n+1)-dimensional module of U_q(sl_2): all defining relations,
     and convergence of E, F, (K - K^-1)/(q - q^-1) to the classical e, f, h
  4. The quantum Casimir: scalar action (Schur), and the shifted eigenvalue
     converging to the classical value n(n+2)/4
  5. Temperley-Lieb: the 8x8 generators, e_i^2 = delta e_i, zig-zag relations,
     Reidemeister II, and the Yang-Baxter / braid relation
  6. The Kauffman bracket of the (2,n) torus links, its closed form, the
     quantum trace of the R-matrix, and the Jones values
     V(unknot) = 1,  V(trefoil) = t + t^3 - t^4  with  t = A^-4
  7. Quantum double: self-distributivity <=> Yang-Baxter, conjugation braiding,
     and modularity of abelian anyons (S S' = |A| Id)

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import comb, cos, pi, sin
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Complex = complex
Matrix = List[List[complex]]


# ---------------------------------------------------------------------------
# 1. Quantum integers
# ---------------------------------------------------------------------------

def q_int(q: float, m: int) -> float:
    """Symmetric quantum integer [m]_q = (q^m - q^-m)/(q - q^-1)."""
    return (q ** m - q ** (-m)) / (q - 1.0 / q)


def q_int_regular(q: float, m: int) -> float:
    """Denominator-free form  [m]_q = q^{1-m} * sum_{i<m} q^{2i}  (m >= 0)."""
    return q ** (1 - m) * sum(q ** (2 * i) for i in range(m))


def demo_quantum_integers() -> None:
    print("=" * 74)
    print("1. QUANTUM INTEGERS DEGENERATE TO ORDINARY INTEGERS")
    print("=" * 74)
    print(f"{'q':>10} | " + " ".join(f"[{m}]_q".rjust(11) for m in range(1, 6)))
    print("-" * 74)
    for q in (1.5, 1.1, 1.01, 1.001, 1.00001):
        row = " ".join(f"{q_int(q, m):11.6f}" for m in range(1, 6))
        print(f"{q:10.5f} | {row}")
    print(f"{'limit':>10} | " + " ".join(f"{m:11.6f}" for m in range(1, 6)))

    # the two formulas agree away from q = 1, and the regular one extends to q = 1
    worst = max(abs(q_int(1.3, m) - q_int_regular(1.3, m)) for m in range(6))
    print(f"\n  max |[m]_q - q^(1-m) sum q^(2i)| at q = 1.3 :  {worst:.3e}")
    print(f"  regular form at q = 1 exactly:  {[q_int_regular(1.0, m) for m in range(6)]}")

    # fundamental identity  [a][b] - [a-1][b+1] = [b-a+1]
    q = 1.234
    err = max(
        abs(q_int(q, a) * q_int(q, b) - q_int(q, a - 1) * q_int(q, b + 1) - q_int(q, b - a + 1))
        for a in range(-3, 4)
        for b in range(-3, 4)
    )
    print(f"  max error in  [a][b] - [a-1][b+1] = [b-a+1]  (|a|,|b| <= 3) :  {err:.3e}")


# ---------------------------------------------------------------------------
# 2. Gaussian binomials
# ---------------------------------------------------------------------------

def q_binom(q: float, n: int, j: int) -> float:
    """Gaussian binomial via the q-Pascal recursion C_q(n+1,j+1)=q^{n-j}C_q(n,j)+C_q(n,j+1)."""
    if j == 0:
        return 1.0
    if n == 0:
        return 0.0
    return q ** (n - j) * q_binom(q, n - 1, j - 1) + q_binom(q, n - 1, j)


def demo_gaussian_binomials() -> None:
    print()
    print("=" * 74)
    print("2. GAUSSIAN BINOMIALS DEGENERATE TO BINOMIAL COEFFICIENTS")
    print("=" * 74)
    n = 5
    print(f"  row n = {n}")
    for q in (2.0, 1.2, 1.01, 1.0):
        vals = " ".join(f"{q_binom(q, n, j):10.4f}" for j in range(n + 1))
        print(f"  q = {q:6.3f} : {vals}")
    print(f"  classical : " + " ".join(f"{comb(n, j):10d}" for j in range(n + 1)))

    # second q-Pascal recursion and reflection symmetry
    q = 1.7
    e1 = max(
        abs(q_binom(q, n + 1, j + 1) - q_binom(q, n, j) - q ** (j + 1) * q_binom(q, n, j + 1))
        for j in range(n + 1)
    )
    e2 = max(abs(q_binom(q, n, j) - q_binom(q, n, n - j)) for j in range(n + 1))
    print(f"\n  dual q-Pascal  C(n+1,j+1) = C(n,j) + q^(j+1) C(n,j+1)  error : {e1:.3e}")
    print(f"  reflection symmetry  C(n,j) = C(n,n-j)                 error : {e2:.3e}")

    # q-binomial theorem for q-commuting 2x2 matrices:  y x = q x y
    q = 1.3
    x: Matrix = [[0.0, 1.0], [0.0, 0.0]]            # E
    y: Matrix = [[q ** 0.5, 0.0], [0.0, q ** -0.5]]  # a K with K E = q E K
    lhs = mat_pow(mat_add(x, y), 4)
    rhs = [[0.0, 0.0], [0.0, 0.0]]
    for j in range(5):
        term = mat_mul(mat_pow(x, j), mat_pow(y, 4 - j))
        rhs = mat_add(rhs, mat_scale(q_binom(q, 4, j), term))
    print(f"  q-binomial theorem (x+y)^4 = sum C_q(4,j) x^j y^(4-j)  error : "
          f"{mat_dist(lhs, rhs):.3e}")


# ---------------------------------------------------------------------------
# small dense matrix helpers
# ---------------------------------------------------------------------------

def mat_add(a: Matrix, b: Matrix) -> Matrix:
    return [[a[i][j] + b[i][j] for j in range(len(a))] for i in range(len(a))]


def mat_sub(a: Matrix, b: Matrix) -> Matrix:
    return [[a[i][j] - b[i][j] for j in range(len(a))] for i in range(len(a))]


def mat_scale(c: complex, a: Matrix) -> Matrix:
    return [[c * a[i][j] for j in range(len(a))] for i in range(len(a))]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def mat_id(n: int) -> Matrix:
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def mat_pow(a: Matrix, k: int) -> Matrix:
    out = mat_id(len(a))
    for _ in range(k):
        out = mat_mul(out, a)
    return out


def mat_dist(a: Matrix, b: Matrix) -> float:
    return max(abs(a[i][j] - b[i][j]) for i in range(len(a)) for j in range(len(a)))


# ---------------------------------------------------------------------------
# 3. The (n+1)-dimensional module of U_q(sl_2)
# ---------------------------------------------------------------------------

def uq_module(q: float, n: int) -> Tuple[Matrix, Matrix, Matrix, Matrix]:
    """E, F, K, K^-1 on the (n+1)-dimensional highest-weight module, in the basis v_0..v_n.

    E v_i = [i]_q v_{i-1},  F v_i = [n-i]_q v_{i+1},  K v_i = q^{n-2i} v_i.
    """
    d = n + 1
    E = [[0.0] * d for _ in range(d)]
    F = [[0.0] * d for _ in range(d)]
    K = [[0.0] * d for _ in range(d)]
    Ki = [[0.0] * d for _ in range(d)]
    for i in range(d):
        K[i][i] = q ** (n - 2 * i)
        Ki[i][i] = q ** (-(n - 2 * i))
        if i >= 1:
            E[i - 1][i] = q_int(q, i)
        if i + 1 < d:
            F[i + 1][i] = q_int(q, n - i)
    return E, F, K, Ki


def classical_module(n: int) -> Tuple[Matrix, Matrix, Matrix]:
    """e, f, h on the (n+1)-dimensional sl_2 module."""
    d = n + 1
    e = [[0.0] * d for _ in range(d)]
    f = [[0.0] * d for _ in range(d)]
    h = [[0.0] * d for _ in range(d)]
    for i in range(d):
        h[i][i] = float(n - 2 * i)
        if i >= 1:
            e[i - 1][i] = float(i)
        if i + 1 < d:
            f[i + 1][i] = float(n - i)
    return e, f, h


def demo_module_and_limit() -> None:
    print()
    print("=" * 74)
    print("3. THE (n+1)-DIMENSIONAL MODULE, AND ITS CLASSICAL LIMIT")
    print("=" * 74)
    n = 3
    q = 1.4
    E, F, K, Ki = uq_module(q, n)

    rel_KE = mat_dist(mat_mul(K, E), mat_scale(q * q, mat_mul(E, K)))
    rel_KF = mat_dist(mat_scale(q * q, mat_mul(K, F)), mat_mul(F, K))
    cartan = mat_scale(1.0 / (q - 1 / q), mat_sub(K, Ki))
    rel_EF = mat_dist(mat_sub(mat_mul(E, F), mat_mul(F, E)), cartan)
    rel_KK = mat_dist(mat_mul(K, Ki), mat_id(n + 1))
    print(f"  n = {n}, q = {q}")
    print(f"    K K^-1 = 1                          error : {rel_KK:.3e}")
    print(f"    K E = q^2 E K                       error : {rel_KE:.3e}")
    print(f"    q^2 K F = F K                       error : {rel_KF:.3e}")
    print(f"    [E,F] = (K - K^-1)/(q - q^-1)       error : {rel_EF:.3e}")

    e, f, h = classical_module(n)
    print("\n  convergence of the generators to the classical operators:")
    print(f"  {'q':>10} | {'|E-e|':>10} {'|F-f|':>10} {'|cartan-h|':>12}")
    for q in (1.5, 1.1, 1.01, 1.001):
        E, F, K, Ki = uq_module(q, n)
        cartan = mat_scale(1.0 / (q - 1 / q), mat_sub(K, Ki))
        print(f"  {q:10.5f} | {mat_dist(E, e):10.3e} {mat_dist(F, f):10.3e} "
              f"{mat_dist(cartan, h):12.3e}")
    print("  (the Cartan column is the 0/0 quotient (K - K^-1)/(q - q^-1) -> h)")


# ---------------------------------------------------------------------------
# 4. The quantum Casimir
# ---------------------------------------------------------------------------

def casimir_scalar(q: float, n: int) -> float:
    """Eigenvalue (q^{n+1} + q^{-(n+1)})/(q - q^-1)^2 of the quantum Casimir."""
    return (q ** (n + 1) + q ** (-(n + 1))) / (q - 1 / q) ** 2


def casimir_regular(q: float, n: int) -> float:
    """Regular form of the shifted eigenvalue: q^{1-n} S_n S_{n+2} / (q+1)^2."""
    sn = sum(q ** i for i in range(n))
    sn2 = sum(q ** i for i in range(n + 2))
    return q ** (1 - n) * sn * sn2 / (q + 1) ** 2


def demo_casimir() -> None:
    print()
    print("=" * 74)
    print("4. THE QUANTUM CASIMIR: SCHUR SCALAR AND CLASSICAL LIMIT")
    print("=" * 74)
    n, q = 3, 1.35
    E, F, K, Ki = uq_module(q, n)
    d = n + 1
    coef = 1.0 / (q - 1 / q) ** 2
    C = mat_add(mat_mul(F, E), mat_scale(coef, mat_add(mat_scale(q, K), mat_scale(1 / q, Ki))))
    lam = casimir_scalar(q, n)
    print(f"  n = {n}, q = {q}:  C - lambda*I  deviation : "
          f"{mat_dist(C, mat_scale(lam, mat_id(d))):.3e}    (lambda = {lam:.6f})")
    print("  => the Casimir acts by ONE scalar on the whole module (quantum Schur)")

    print(f"\n  shifted eigenvalue  Omega_q(n) - (q+q^-1)/(q-q^-1)^2  ->  n(n+2)/4")
    print(f"  {'q':>10} | " + " ".join(f"n={n}".rjust(12) for n in range(1, 5)))
    for q in (1.5, 1.1, 1.01, 1.001):
        shift = (q + 1 / q) / (q - 1 / q) ** 2
        row = " ".join(f"{casimir_scalar(q, n) - shift:12.6f}" for n in range(1, 5))
        print(f"  {q:10.5f} | {row}")
    print(f"  {'limit':>10} | " + " ".join(f"{n * (n + 2) / 4:12.6f}" for n in range(1, 5)))
    q = 1.0001
    err = max(abs(casimir_scalar(q, n) - (q + 1 / q) / (q - 1 / q) ** 2 - casimir_regular(q, n))
              for n in range(1, 5))
    print(f"\n  agreement with the regular form at q = {q} : {err:.3e}"
          "   (regular form is stable, the raw difference is not)")


# ---------------------------------------------------------------------------
# 5. Temperley-Lieb, Reidemeister II, Yang-Baxter
# ---------------------------------------------------------------------------

def loop_value(A: complex) -> complex:
    """delta = -A^2 - A^-2."""
    return -A ** 2 - A ** (-2)


def cup(A: complex, i: int, j: int) -> complex:
    """Coefficients of the q-deformed singlet  omega = A|01> - A^-1|10>."""
    if (i, j) == (0, 1):
        return A
    if (i, j) == (1, 0):
        return -1 / A
    return 0.0


def tl_generators_8(A: complex) -> Tuple[Matrix, Matrix]:
    """The 8x8 Temperley-Lieb generators e_1, e_2 on V (x) V (x) V, V = k^2."""
    idx: List[Tuple[int, int, int]] = list(product((0, 1), repeat=3))
    pos: Dict[Tuple[int, int, int], int] = {p: n for n, p in enumerate(idx)}
    e1: Matrix = [[0.0] * 8 for _ in range(8)]
    e2: Matrix = [[0.0] * 8 for _ in range(8)]
    for p in idx:
        for r in idx:
            e1[pos[p]][pos[r]] = -cup(A, p[0], p[1]) * cup(A, r[0], r[1]) * (p[2] == r[2])
            e2[pos[p]][pos[r]] = -cup(A, p[1], p[2]) * cup(A, r[1], r[2]) * (p[0] == r[0])
    return e1, e2


def kauffman(A: complex, e: Matrix) -> Matrix:
    """The braiding g = A*1 + A^-1 e."""
    return mat_add(mat_scale(A, mat_id(len(e))), mat_scale(1 / A, e))


def demo_temperley_lieb() -> None:
    print()
    print("=" * 74)
    print("5. TEMPERLEY-LIEB, REIDEMEISTER II AND THE YANG-BAXTER EQUATION")
    print("=" * 74)
    for A in (2.0, 0.6 + 0.4j, complex(cos(0.7), sin(0.7))):
        e1, e2 = tl_generators_8(A)
        d = loop_value(A)
        s1 = mat_dist(mat_mul(e1, e1), mat_scale(d, e1))
        s2 = mat_dist(mat_mul(e2, e2), mat_scale(d, e2))
        zig = mat_dist(mat_mul(mat_mul(e1, e2), e1), e1)
        zag = mat_dist(mat_mul(mat_mul(e2, e1), e2), e2)
        g1, g2 = kauffman(A, e1), kauffman(A, e2)
        gi1 = mat_add(mat_scale(1 / A, mat_id(8)), mat_scale(A, e1))
        r2 = mat_dist(mat_mul(g1, gi1), mat_id(8))
        ybe = mat_dist(mat_mul(mat_mul(g1, g2), g1), mat_mul(mat_mul(g2, g1), g2))
        print(f"  A = {A!s:>22}   delta = {d:.4f}")
        print(f"    e_i^2 = delta e_i          : {s1:.2e}, {s2:.2e}")
        print(f"    e1e2e1 = e1 , e2e1e2 = e2  : {zig:.2e}, {zag:.2e}")
        print(f"    Reidemeister II  g g' = 1  : {r2:.2e}")
        print(f"    braid relation g1g2g1=g2g1g2: {ybe:.2e}")


# ---------------------------------------------------------------------------
# 6. The bracket and Jones values of the (2,n) torus links
# ---------------------------------------------------------------------------

def b_coeff(A: Fraction, n: int) -> Fraction:
    """b_n, defined by b_0 = 0 and b_{n+1} = A b_n + A^-1 A^n + A^-1 delta b_n."""
    d = -A ** 2 - 1 / A ** 2
    b = Fraction(0)
    for i in range(n):
        b = A * b + A ** i / A + d * b / A
    return b


def bracket(A: Fraction, n: int) -> Fraction:
    """Kauffman bracket of the closure of sigma_1^n (the (2,n) torus link)."""
    d = -A ** 2 - 1 / A ** 2
    return A ** n * d + b_coeff(A, n)


def jones(A: Fraction, n: int) -> Fraction:
    """Writhe-corrected invariant V_n = (-A^-3)^n <n>."""
    return (-1 / A ** 3) ** n * bracket(A, n)


def qtrace_of_braid_power(A: complex, n: int) -> complex:
    """Quantum trace of R^n on V (x) V, with ribbon weight mu = diag(-A^2, -A^-2)."""
    idx: List[Tuple[int, int]] = list(product((0, 1), repeat=2))
    pos = {p: k for k, p in enumerate(idx)}
    e: Matrix = [[0.0] * 4 for _ in range(4)]
    for p in idx:
        for r in idx:
            e[pos[p]][pos[r]] = -cup(A, p[0], p[1]) * cup(A, r[0], r[1])
    R = mat_pow(kauffman(A, e), n)
    mu = [-A ** 2, -A ** (-2)]
    return sum(mu[p[0]] * mu[p[1]] * R[pos[p]][pos[p]] for p in idx)


def demo_jones() -> None:
    print()
    print("=" * 74)
    print("6. THE (2,n) TORUS LINKS: BRACKET, QUANTUM TRACE, JONES VALUES")
    print("=" * 74)
    A = Fraction(2)
    d = -A ** 2 - 1 / A ** 2
    names = {1: "unknot", 2: "Hopf link", 3: "trefoil", 4: "(2,4) torus link",
             5: "cinquefoil (2,5)"}
    print(f"  exact arithmetic at A = {A}   (delta = {d})")
    print(f"  {'n':>2} {'link':>18} {'<n>':>22} {'V_n':>26}")
    print("  " + "-" * 70)
    for n in range(1, 7):
        print(f"  {n:2d} {names.get(n, f'(2,{n}) torus link'):>18} "
              f"{str(bracket(A, n)):>22} {str(jones(A, n)):>26}")

    # closed form  delta * b_n = (-1)^n A^-3n - A^n
    err = max(abs(d * b_coeff(A, n) - ((-1) ** n / A ** (3 * n) - A ** n)) for n in range(8))
    print(f"\n  closed form  delta*b_n = (-1)^n A^-3n - A^n     max error : {err}")

    # quantum trace of the R-matrix reproduces delta * bracket
    Ac = 0.83 + 0.21j
    dc = loop_value(Ac)
    worst = 0.0
    for n in range(6):
        lhs = qtrace_of_braid_power(Ac, n)
        bn = 0.0 + 0.0j
        for i in range(n):
            bn = Ac * bn + Ac ** i / Ac + dc * bn / Ac
        rhs = dc * (Ac ** n * dc + bn)
        worst = max(worst, abs(lhs - rhs))
    print(f"  qtr(R^n) = delta * <n>  (A = {Ac})   max error : {worst:.3e}")

    # unknot normalisation and the trefoil polynomial, symbolically in t = A^-4
    print(f"\n  V(unknot) = V_1 = {jones(A, 1)}   (must be exactly 1)")
    t = 1 / A ** 4
    print(f"  V(trefoil) = V_3 = {jones(A, 3)}")
    print(f"  t + t^3 - t^4 at t = A^-4 = {t}  =  {t + t ** 3 - t ** 4}")
    print(f"  V_3 == t + t^3 - t^4 ?  {jones(A, 3) == t + t ** 3 - t ** 4}")
    print(f"  V_3 != V_1 ?            {jones(A, 3) != jones(A, 1)}"
          "   ==> the trefoil cannot be untied")

    # check the identity V_3 = t + t^3 - t^4 at several values of A
    bad = [str(a) for a in (Fraction(3), Fraction(5, 2), Fraction(7, 3))
           if jones(a, 3) != 1 / a ** 4 + 1 / a ** 12 - 1 / a ** 16]
    print(f"  same identity at A = 3, 5/2, 7/3 : {'all hold' if not bad else bad}")


# ---------------------------------------------------------------------------
# 7. Quantum double: racks, conjugation, abelian anyons
# ---------------------------------------------------------------------------

def is_self_distributive(elements: Sequence[int], act: Callable[[int, int], int]) -> bool:
    return all(act(x, act(y, z)) == act(act(x, y), act(x, z))
               for x in elements for y in elements for z in elements)


def rack_braid_relation(elements: Sequence[int], act: Callable[[int, int], int]) -> bool:
    def c1(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
        return (act(t[0], t[1]), t[0], t[2])

    def c2(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
        return (t[0], act(t[1], t[2]), t[1])

    return all(c1(c2(c1(t))) == c2(c1(c2(t)))
               for t in product(elements, repeat=3))


def demo_quantum_double() -> None:
    print()
    print("=" * 74)
    print("7. QUANTUM DOUBLE: SELF-DISTRIBUTIVITY, CONJUGATION, MODULARITY")
    print("=" * 74)

    # symmetric group S_3 as permutations of {0,1,2}, conjugation action
    perms: List[Tuple[int, ...]] = sorted(product(range(3), repeat=3))
    perms = [p for p in perms if len(set(p)) == 3]
    index = {p: i for i, p in enumerate(perms)}

    def compose(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple(a[b[i]] for i in range(3))

    def inverse(a: Tuple[int, ...]) -> Tuple[int, ...]:
        out = [0, 0, 0]
        for i, ai in enumerate(a):
            out[ai] = i
        return tuple(out)

    def conj(i: int, j: int) -> int:
        x, y = perms[i], perms[j]
        return index[compose(compose(x, y), inverse(x))]

    elems = list(range(len(perms)))
    print(f"  group S_3 ({len(perms)} elements), action x |> y = x y x^-1")
    print(f"    self-distributive ?      {is_self_distributive(elems, conj)}")
    print(f"    braid relation holds ?   {rack_braid_relation(elems, conj)}")

    # a NON self-distributive operation must fail the braid relation (the 'only if')
    def bad(i: int, j: int) -> int:
        return (i + j) % len(perms)

    print(f"    control: x |> y = x + y  self-distributive ? {is_self_distributive(elems, bad)}"
          f",  braid relation ? {rack_braid_relation(elems, bad)}")

    # abelian anyons: A = Z/N with chi(x,y) = exp(2 pi i x y / N)
    print("\n  abelian anyons  A = Z/N,  chi(x,y) = exp(2 pi i x y / N)")
    for N in (2, 3, 5, 6):
        def chi(x: int, y: int, N: int = N) -> complex:
            return complex(cos(2 * pi * x * y / N), sin(2 * pi * x * y / N))

        # Yang-Baxter for the diagonal braiding
        ybe = max(
            abs(chi(y, x) * chi(z, x) * chi(z, y) - chi(z, y) * chi(z, x) * chi(y, x))
            for x, y, z in product(range(N), repeat=3)
        )
        # hexagons = bilinearity
        hexl = max(abs(chi((x + y) % N, z) - chi(x, z) * chi(y, z))
                   for x, y, z in product(range(N), repeat=3))
        # modularity:  sum_y chi(x,y) chi(-x',y) = N delta_{x,x'}
        worst = 0.0
        for x, xp in product(range(N), repeat=2):
            s = sum(chi(x, y) * chi((-xp) % N, y) for y in range(N))
            target = complex(N if x == xp else 0)
            worst = max(worst, abs(s - target))
        nondeg = all(any(abs(chi(x, y) - 1) > 1e-12 for y in range(N)) for x in range(1, N))
        print(f"    N = {N}:  YBE {ybe:.1e}   hexagon {hexl:.1e}   "
              f"nondegenerate {nondeg}   S S' - N*Id  {worst:.1e}")
    print("  invertible S-matrix  ==>  the braided category is modular")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_quantum_integers()
    demo_gaussian_binomials()
    demo_module_and_limit()
    demo_casimir()
    demo_temperley_lieb()
    demo_jones()
    demo_quantum_double()
    print()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
