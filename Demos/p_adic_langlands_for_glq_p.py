"""
Numerical demonstrations for:

    Foundations of the p-adic Langlands correspondence for GL_2(Q_p):
    the determinant bridge and twisting compatibilities.

Every result from the paper is illustrated here with exact arithmetic
(over the rationals, using Python's `fractions.Fraction`) and over the
finite residue rings Z/p^k Z, which are the standard finite-precision
models of the p-adic integers Z_p.

The demonstrations cover:
    1. Cayley-Hamilton:  M^2 = (tr M) M - (det M) I
    2. Adjugate / inverse:  M ((tr M) I - M) = (det M) I,  M^{-1} explicit
    3. Determinant surjectivity via diag(u, 1)
    4. Kernel of det = SL_2 (det = 1)
    5. Scalar center: det(u I) = u^2, and u I commutes with everything
    6. Twisting law:  det(chi (x) rho) = chi^2 * det rho

Self-contained: only the standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence, Tuple

# A 2x2 matrix is a tuple of tuples of a Scalar; Scalar is Fraction or int.
Scalar = Fraction
Matrix = Tuple[Tuple[Scalar, Scalar], Tuple[Scalar, Scalar]]


# --------------------------------------------------------------------------- #
# Basic 2x2 matrix algebra over an arbitrary field (here: rationals or Z/mZ). #
# --------------------------------------------------------------------------- #

def mat(a: Scalar, b: Scalar, c: Scalar, d: Scalar) -> Matrix:
    """Build the 2x2 matrix [[a, b], [c, d]]."""
    return ((a, b), (c, d))


def identity() -> Matrix:
    """The 2x2 identity matrix."""
    return mat(Fraction(1), Fraction(0), Fraction(0), Fraction(1))


def trace(m: Matrix) -> Scalar:
    """Trace tr(M) = M_11 + M_22."""
    return m[0][0] + m[1][1]


def determinant(m: Matrix) -> Scalar:
    """Determinant det(M) = M_11 M_22 - M_12 M_21."""
    return m[0][0] * m[1][1] - m[0][1] * m[1][0]


def add(a: Matrix, b: Matrix) -> Matrix:
    """Entrywise sum of two matrices."""
    return tuple(tuple(a[i][j] + b[i][j] for j in range(2)) for i in range(2))  # type: ignore


def sub(a: Matrix, b: Matrix) -> Matrix:
    """Entrywise difference of two matrices."""
    return tuple(tuple(a[i][j] - b[i][j] for j in range(2)) for i in range(2))  # type: ignore


def smul(s: Scalar, a: Matrix) -> Matrix:
    """Scalar multiple s * M."""
    return tuple(tuple(s * a[i][j] for j in range(2)) for i in range(2))  # type: ignore


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product A * B."""
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )  # type: ignore


# --------------------------------------------------------------------------- #
# 1. Cayley-Hamilton:  M^2 = (tr M) M - (det M) I                             #
# --------------------------------------------------------------------------- #

def cayley_hamilton_residual(m: Matrix) -> Matrix:
    """Return M^2 - ((tr M) M - (det M) I); the zero matrix iff C-H holds."""
    lhs = matmul(m, m)
    rhs = sub(smul(trace(m), m), smul(determinant(m), identity()))
    return sub(lhs, rhs)


def is_zero(m: Matrix) -> bool:
    """Test whether a matrix is entrywise zero."""
    return all(m[i][j] == 0 for i in range(2) for j in range(2))


# --------------------------------------------------------------------------- #
# 2. Adjugate / inverse:  M ((tr M) I - M) = (det M) I                        #
# --------------------------------------------------------------------------- #

def adjugate(m: Matrix) -> Matrix:
    """The adjugate (tr M) I - M, so that M * adj = (det M) I."""
    return sub(smul(trace(m), identity()), m)


def inverse_via_adjugate(m: Matrix) -> Matrix:
    """Explicit inverse (1/det) ((tr M) I - M); requires det M != 0."""
    d = determinant(m)
    if d == 0:
        raise ValueError("matrix is singular; no inverse")
    return smul(Fraction(1) / d, adjugate(m))


# --------------------------------------------------------------------------- #
# 3-4. Determinant surjectivity and its kernel                                #
# --------------------------------------------------------------------------- #

def diag_gl(u: Scalar) -> Matrix:
    """diag(u, 1) in GL_2; its determinant is exactly u (so det is onto)."""
    return mat(u, Fraction(0), Fraction(0), Fraction(1))


def in_sl2(m: Matrix) -> bool:
    """Membership in the kernel of det, i.e. SL_2 (det = 1)."""
    return determinant(m) == 1


# --------------------------------------------------------------------------- #
# 5. Scalar center:  det(u I) = u^2, and u I is central                       #
# --------------------------------------------------------------------------- #

def scalar_gl(u: Scalar) -> Matrix:
    """The central scalar matrix u * I."""
    return smul(u, identity())


def scalar_commutes(u: Scalar, g: Matrix) -> bool:
    """Verify (u I) g = g (u I)."""
    s = scalar_gl(u)
    return matmul(s, g) == matmul(g, s)


# --------------------------------------------------------------------------- #
# 6. Twisting law:  det(chi (x) rho)(g) = chi(g)^2 * det(rho(g))              #
# --------------------------------------------------------------------------- #

def twist(chi_g: Scalar, rho_g: Matrix) -> Matrix:
    """Twist of a representation value: (chi (x) rho)(g) = chi(g) * rho(g)."""
    return smul(chi_g, rho_g)


def twisting_law_holds(chi_g: Scalar, rho_g: Matrix) -> bool:
    """Check det(chi(g) rho(g)) == chi(g)^2 * det(rho(g))."""
    return determinant(twist(chi_g, rho_g)) == chi_g ** 2 * determinant(rho_g)


# --------------------------------------------------------------------------- #
# p-adic residue-ring model:  arithmetic mod p^k  (finite model of Z_p)       #
# --------------------------------------------------------------------------- #

def cayley_hamilton_mod(m_int: Sequence[Sequence[int]], modulus: int) -> bool:
    """Check Cayley-Hamilton over Z/(modulus)Z for an integer 2x2 matrix."""
    a, b = m_int[0]
    c, d = m_int[1]
    tr = (a + d) % modulus
    det = (a * d - b * c) % modulus
    # M^2
    m2 = [
        [(a * a + b * c) % modulus, (a * b + b * d) % modulus],
        [(c * a + d * c) % modulus, (c * b + d * d) % modulus],
    ]
    # (tr) M - (det) I
    rhs = [
        [(tr * a - det) % modulus, (tr * b) % modulus],
        [(tr * c) % modulus, (tr * d - det) % modulus],
    ]
    return m2 == rhs


# --------------------------------------------------------------------------- #
# Driver                                                                       #
# --------------------------------------------------------------------------- #

def _F(x: int) -> Fraction:
    return Fraction(x)


def main() -> None:
    print("=" * 70)
    print("p-adic Langlands for GL_2(Q_p): numerical demonstrations")
    print("=" * 70)

    # A concrete test matrix over Q.
    M = mat(_F(2), _F(3), _F(1), _F(4))
    print(f"\nTest matrix M = {M}")
    print(f"  tr M = {trace(M)},  det M = {determinant(M)}")

    # 1. Cayley-Hamilton
    print("\n[1] Cayley-Hamilton:  M^2 = (tr M) M - (det M) I")
    res = cayley_hamilton_residual(M)
    print(f"    residual = {res}  ->  holds: {is_zero(res)}")

    # 2. Adjugate and inverse
    print("\n[2] Adjugate identity:  M ((tr M) I - M) = (det M) I")
    lhs = matmul(M, adjugate(M))
    rhs = smul(determinant(M), identity())
    print(f"    M * adj(M) = {lhs}")
    print(f"    det(M) * I = {rhs}  ->  holds: {lhs == rhs}")
    Minv = inverse_via_adjugate(M)
    print(f"    explicit inverse M^-1 = {Minv}")
    print(f"    M * M^-1 = {matmul(M, Minv)}  (= I: {matmul(M, Minv) == identity()})")

    # 3. Determinant surjectivity
    print("\n[3] Determinant surjectivity:  det(diag(u,1)) = u")
    for u in (_F(5), _F(-3), Fraction(7, 2)):
        g = diag_gl(u)
        print(f"    u = {u}:  det(diag(u,1)) = {determinant(g)}  "
              f"-> matches: {determinant(g) == u}")

    # 4. Kernel of det = SL_2
    print("\n[4] Kernel of det = SL_2 (det = 1)")
    S = mat(_F(1), _F(1), _F(0), _F(1))         # det = 1
    print(f"    [[1,1],[0,1]] in SL_2: {in_sl2(S)}")
    print(f"    M in SL_2: {in_sl2(M)}  (det M = {determinant(M)})")

    # 5. Scalar center
    print("\n[5] Scalar center:  det(u I) = u^2, and u I is central")
    for u in (_F(3), Fraction(2, 5)):
        s = scalar_gl(u)
        print(f"    u = {u}:  det(u I) = {determinant(s)}  "
              f"-> equals u^2 = {u ** 2}: {determinant(s) == u ** 2}")
    print(f"    (3 I) commutes with M: {scalar_commutes(_F(3), M)}")

    # 6. Twisting law
    print("\n[6] Twisting law:  det(chi(g) rho(g)) = chi(g)^2 det(rho(g))")
    rho_g = mat(_F(2), _F(0), _F(1), _F(3))
    for chi_g in (_F(2), _F(-1), Fraction(3, 2)):
        ok = twisting_law_holds(chi_g, rho_g)
        d_twist = determinant(twist(chi_g, rho_g))
        d_pred = chi_g ** 2 * determinant(rho_g)
        print(f"    chi(g) = {chi_g}:  det(twist) = {d_twist}, "
              f"chi^2 det rho = {d_pred}  -> holds: {ok}")

    # p-adic residue-ring check (Cayley-Hamilton mod p^k).
    print("\n[p-adic] Cayley-Hamilton over Z/p^k Z (finite model of Z_p)")
    p = 5
    for k in (1, 2, 3):
        modulus = p ** k
        Mi = [[2, 3], [1, 4]]
        print(f"    mod {p}^{k} = {modulus}:  holds = "
              f"{cayley_hamilton_mod(Mi, modulus)}")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
