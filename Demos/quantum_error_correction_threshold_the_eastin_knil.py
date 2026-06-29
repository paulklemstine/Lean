"""
Numerical demonstration of the Jones-Temperley-Lieb braid representation
and its Markov trace.

All results below mirror the formalized theorems:

  * jones_op_is_unit          <->  jonesOp_mul_inv / jonesOpInv_mul
  * braid_relation_holds      <->  braid_relation        (Yang-Baxter)
  * far_commutativity_holds   <->  braid_relation_far
  * skein_decomposition       <->  markov_trace_property
  * conjugation_invariance    <->  jones_polynomial_invariance

The Temperley-Lieb relations are realized by *explicit* small matrices, giving a
concrete model in which every abstract hypothesis is a checkable equality.

Pure Python: no third-party dependencies. Complex arithmetic throughout, since
the natural parameter A is a complex number (a root of unity in the physical /
anyonic setting).
"""

from __future__ import annotations

from typing import List

# ---------------------------------------------------------------------------
# Minimal complex-matrix toolkit (inlined; no numpy dependency).
# ---------------------------------------------------------------------------

Matrix = List[List[complex]]


def identity(n: int) -> Matrix:
    """The n x n identity matrix."""
    return [[1.0 + 0j if i == j else 0j for j in range(n)] for i in range(n)]


def matmul(P: Matrix, Q: Matrix) -> Matrix:
    """Standard matrix product P * Q."""
    n, k, m = len(P), len(Q), len(Q[0])
    return [[sum(P[i][t] * Q[t][j] for t in range(k)) for j in range(m)]
            for i in range(n)]


def scalar_mul(c: complex, P: Matrix) -> Matrix:
    """Scalar multiple c * P."""
    return [[c * x for x in row] for row in P]


def add(P: Matrix, Q: Matrix) -> Matrix:
    """Entrywise sum P + Q."""
    return [[P[i][j] + Q[i][j] for j in range(len(P[0]))] for i in range(len(P))]


def trace(P: Matrix) -> complex:
    """Matrix trace, a symmetric linear functional: tr(XY) = tr(YX)."""
    return sum(P[i][i] for i in range(len(P)))


def close_to(P: Matrix, Q: Matrix, tol: float = 1e-9) -> bool:
    """Whether two matrices agree up to numerical tolerance."""
    return all(abs(P[i][j] - Q[i][j]) < tol
               for i in range(len(P)) for j in range(len(P[0])))


# ---------------------------------------------------------------------------
# Core definitions (mirroring the Lean development).
# ---------------------------------------------------------------------------

def loop_value(A: complex) -> complex:
    """The Temperley-Lieb loop value delta = -(A^2 + A^{-2})."""
    return -(A ** 2 + A ** (-2))


def jones_op(A: complex, X: Matrix) -> Matrix:
    """The Jones operator jonesOp(A, X) = A * I + A^{-1} * X (Kauffman bracket)."""
    n = len(X)
    return add(scalar_mul(A, identity(n)), scalar_mul(A ** (-1), X))


def jones_op_inv(A: complex, X: Matrix) -> Matrix:
    """The proposed inverse jonesOpInv(A, X) = A^{-1} * I + A * X."""
    n = len(X)
    return add(scalar_mul(A ** (-1), identity(n)), scalar_mul(A, X))


# ---------------------------------------------------------------------------
# An explicit two-generator Temperley-Lieb model.
#
#   a = [[delta, 0], [1, 0]],   b = [[0, 1], [0, delta]]
#
# satisfy  a^2 = delta a,  b^2 = delta b,  aba = a,  bab = b.
# ---------------------------------------------------------------------------

def tl_generators_adjacent(A: complex) -> tuple[Matrix, Matrix]:
    """Two adjacent Temperley-Lieb generators e_i, e_{i+1} as 2x2 matrices."""
    d = loop_value(A)
    a: Matrix = [[d, 0j], [1.0 + 0j, 0j]]
    b: Matrix = [[0j, 1.0 + 0j], [0j, d]]
    return a, b


def tl_generators_far(A: complex) -> tuple[Matrix, Matrix]:
    """Two far-apart (commuting) generators as block-diagonal 4x4 matrices."""
    d = loop_value(A)
    # a acts on the first block, c on the second; they commute by construction.
    a: Matrix = [
        [d, 0j, 0j, 0j],
        [1.0 + 0j, 0j, 0j, 0j],
        [0j, 0j, 1.0 + 0j, 0j],
        [0j, 0j, 0j, 1.0 + 0j],
    ]
    c: Matrix = [
        [1.0 + 0j, 0j, 0j, 0j],
        [0j, 1.0 + 0j, 0j, 0j],
        [0j, 0j, d, 0j],
        [0j, 0j, 1.0 + 0j, 0j],
    ]
    return a, c


# ---------------------------------------------------------------------------
# Verifications.
# ---------------------------------------------------------------------------

def jones_op_is_unit(A: complex, X: Matrix) -> bool:
    """jonesOp(A,X) * jonesOpInv(A,X) = I and the reverse (Theorem: jonesOp_mul_inv)."""
    J, Jinv = jones_op(A, X), jones_op_inv(A, X)
    n = len(X)
    return (close_to(matmul(J, Jinv), identity(n))
            and close_to(matmul(Jinv, J), identity(n)))


def braid_relation_holds(A: complex, a: Matrix, b: Matrix) -> bool:
    """sigma sigma' sigma = sigma' sigma sigma' (Theorem: braid_relation)."""
    sa, sb = jones_op(A, a), jones_op(A, b)
    lhs = matmul(matmul(sa, sb), sa)
    rhs = matmul(matmul(sb, sa), sb)
    return close_to(lhs, rhs)


def far_commutativity_holds(A: complex, a: Matrix, c: Matrix) -> bool:
    """Commuting generators give commuting Jones ops (Theorem: braid_relation_far)."""
    sa, sc = jones_op(A, a), jones_op(A, c)
    return close_to(matmul(sa, sc), matmul(sc, sa))


def skein_decomposition(A: complex, X: Matrix, e: Matrix) -> bool:
    """tr(X * jonesOp(A,e)) = A*tr(X) + A^{-1}*tr(X*e)  (Theorem: markov_trace_property)."""
    lhs = trace(matmul(X, jones_op(A, e)))
    rhs = A * trace(X) + A ** (-1) * trace(matmul(X, e))
    return abs(lhs - rhs) < 1e-9


def conjugation_invariance(g: Matrix, b: Matrix) -> bool:
    """tr(g b g^{-1}) = tr(b) for the symmetric trace (Theorem: jones_polynomial_invariance)."""
    # 2x2 inverse via the closed-form formula.
    det = g[0][0] * g[1][1] - g[0][1] * g[1][0]
    ginv: Matrix = [[g[1][1] / det, -g[0][1] / det],
                    [-g[1][0] / det, g[0][0] / det]]
    conj = matmul(matmul(g, b), ginv)
    return abs(trace(conj) - trace(b)) < 1e-9


# ---------------------------------------------------------------------------
# Driver.
# ---------------------------------------------------------------------------

def main() -> None:
    # A primitive root-of-unity-flavoured parameter (the physical regime).
    import cmath
    A = cmath.exp(1j * cmath.pi / 5)  # A = e^{i pi / 5}
    d = loop_value(A)
    print(f"Parameter A = e^(i*pi/5) = {A:.4f}")
    print(f"Loop value  delta = -(A^2 + A^-2) = {d:.4f}")
    print(f"            (note delta is real: {d.real:.6f})")
    print()

    a, b = tl_generators_adjacent(A)

    # Sanity: the model satisfies the Temperley-Lieb relations.
    aa = matmul(a, a)
    print("TL relation a^2 = delta*a :", close_to(aa, scalar_mul(d, a)))
    print("TL relation b^2 = delta*b :", close_to(matmul(b, b), scalar_mul(d, b)))
    print("TL relation a b a = a     :", close_to(matmul(matmul(a, b), a), a))
    print("TL relation b a b = b     :", close_to(matmul(matmul(b, a), b), b))
    print()

    print("[jonesOp_mul_inv]  jonesOp(A,a) is a unit :", jones_op_is_unit(A, a))
    print("[jonesOp_mul_inv]  jonesOp(A,b) is a unit :", jones_op_is_unit(A, b))
    print("[braid_relation]   sigma sig' sig = sig' sig sig' :",
          braid_relation_holds(A, a, b))

    af, cf = tl_generators_far(A)
    print("[braid_relation_far] far generators commute :",
          far_commutativity_holds(A, af, cf))
    print()

    print("[markov_trace_property] skein decomposition holds :",
          skein_decomposition(A, jones_op(A, b), a))

    # Conjugation invariance with an arbitrary invertible g.
    g: Matrix = [[2.0 + 0j, 1.0 + 0j], [1.0 + 0j, 1.0 + 0j]]
    braid_word = matmul(jones_op(A, a), jones_op(A, b))  # sigma_0 sigma_1
    print("[jones_polynomial_invariance] tr(g b g^-1) = tr(b) :",
          conjugation_invariance(g, braid_word))

    # A worked Markov-trace value: trace of the closure of a 2-braid sigma^k.
    print()
    print("Markov-trace values of sigma_0^k closures (tr of jonesOp(A,a)^k):")
    powk: Matrix = identity(2)
    s0 = jones_op(A, a)
    for k in range(1, 5):
        powk = matmul(powk, s0)
        print(f"  k = {k}:  tr = {trace(powk):.4f}")


if __name__ == "__main__":
    main()
