"""
demo.py — Numerical demonstrations for

    "Torsionness of Iwasawa Modules That Are Finitely Generated
     Over the Coefficient Ring"

Main theorem (isTorsion_of_finite):
    Let R be an integral domain and M a module over the power-series ring
    R[[X]] that is finitely generated as an R-module.  Then M is Lambda-torsion:
    there is a single NONZERO power series s in R[[X]] with s . x = 0 for all x.

The construction is explicit.  Let phi : M -> M be the R-linear operator
"multiply by X = T".  Because M is finite over R, Cayley-Hamilton supplies a
monic (hence nonzero) polynomial q over R with q(phi) = 0.  Reading q back inside
R[[X]] gives the annihilating power series s = q(T).

This file demonstrates the whole pipeline computationally over the finite ring
R = Z / p^N (a quotient model of the p-adic integers Z_p), where Lambda-modules
that are free of finite rank become explicit matrices and everything reduces to
linear algebra.  It also exhibits the standard counterexample (M = Lambda itself
is NOT torsion) that shows the hypothesis "finite over R" is essential.

Pure standard library; no external dependencies.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Polynomial / matrix arithmetic over the ring Z / m  (model of Z_p mod p^N)
# ---------------------------------------------------------------------------

Matrix = List[List[int]]
Poly = List[int]  # coefficients low-degree first: p[0] + p[1] X + p[2] X^2 + ...


def mat_mul(a: Matrix, b: Matrix, mod: int) -> Matrix:
    """Multiply two square matrices modulo `mod`."""
    n = len(a)
    out: Matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            aik = a[i][k]
            if aik == 0:
                continue
            for j in range(n):
                out[i][j] = (out[i][j] + aik * b[k][j]) % mod
    return out


def mat_identity(n: int) -> Matrix:
    """The n x n identity matrix."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def mat_scalar(c: int, a: Matrix, mod: int) -> Matrix:
    """Scale a matrix by a constant modulo `mod`."""
    return [[(c * x) % mod for x in row] for row in a]


def mat_add(a: Matrix, b: Matrix, mod: int) -> Matrix:
    """Add two matrices modulo `mod`."""
    n = len(a)
    return [[(a[i][j] + b[i][j]) % mod for j in range(n)] for i in range(n)]


def mat_apply(a: Matrix, v: Sequence[int], mod: int) -> List[int]:
    """Apply a matrix to a column vector modulo `mod`."""
    n = len(a)
    return [sum(a[i][j] * v[j] for j in range(n)) % mod for i in range(n)]


def is_zero_matrix(a: Matrix) -> bool:
    """Test whether every entry of `a` is zero."""
    return all(x == 0 for row in a for x in row)


# ---------------------------------------------------------------------------
# Characteristic polynomial via Faddeev-LeVerrier-style Newton iteration
# (works over Z / m because it uses no division; it builds char poly from
#  matrix powers using the Le Verrier recursion adapted to commutative rings).
# Here we instead use the Berkowitz algorithm, which is division-free and
# correct over an arbitrary commutative ring.
# ---------------------------------------------------------------------------

def char_poly_berkowitz(a: Matrix, mod: int) -> Poly:
    """
    Division-free characteristic polynomial of `a` over Z/mod, via the
    Berkowitz algorithm.  Returns coefficients low-degree first of
    det(X*I - A), a MONIC polynomial of degree n.
    """
    n = len(a)
    if n == 0:
        return [1]
    # Berkowitz computes the char poly p(X) = det(X I - A).
    # We follow the standard "Samuelson-Berkowitz" toeplitz-vector recursion.
    # vector for the 1x1 leading principal submatrix:
    poly_vec: List[int] = [1 % mod, (-a[0][0]) % mod]  # [1, -a00]
    for r in range(1, n):
        # R: row vector A[r][0:r]; S: column vector A[0:r][r]; M: top-left r x r
        R = [a[r][j] % mod for j in range(r)]
        S = [a[i][r] % mod for i in range(r)]
        M = [[a[i][j] % mod for j in range(r)] for i in range(r)]
        # Toeplitz matrix T of size (r+2) x (r+1):
        # rows indexed 0..r+1; column k uses entries:
        #   diagonal 1, then -a[r][r], then -R M^{k-2} S for k>=2
        col_entries: List[int] = [1 % mod, (-a[r][r]) % mod]
        Mk = mat_identity(r)  # M^0
        for _k in range(r):
            # -R * Mk * S
            MkS = mat_apply(Mk, S, mod)
            val = (-sum(R[i] * MkS[i] for i in range(r))) % mod
            col_entries.append(val)
            Mk = mat_mul(Mk, M, mod)
        # Build (r+2) x (r+1) lower-triangular Toeplitz and multiply by poly_vec
        new_vec: List[int] = [0] * (r + 2)
        for i in range(r + 2):
            acc = 0
            for j in range(r + 1):
                idx = i - j
                if 0 <= idx < len(col_entries):
                    acc += col_entries[idx] * poly_vec[j]
            new_vec[i] = acc % mod
        poly_vec = new_vec
    # poly_vec is high-degree first: [1, c_{n-1}, ..., c_0].  Reverse to low-first.
    return list(reversed(poly_vec))


def poly_eval_matrix(p: Poly, a: Matrix, mod: int) -> Matrix:
    """Evaluate polynomial p at the matrix a (i.e. compute p(A)) modulo mod."""
    n = len(a)
    result: Matrix = [[0] * n for _ in range(n)]
    power = mat_identity(n)  # A^0
    for coeff in p:
        result = mat_add(result, mat_scalar(coeff, power, mod), mod)
        power = mat_mul(power, a, mod)
    return result


# ---------------------------------------------------------------------------
# p-adic valuation and Weierstrass invariants (mu, lambda)
# ---------------------------------------------------------------------------

def p_val(x: int, p: int, cap: int) -> int:
    """p-adic valuation of x, capped at `cap` (treat 0 as having valuation cap)."""
    if x % (p ** cap) == 0:
        return cap
    v = 0
    while x % p == 0:
        x //= p
        v += 1
    return v


def weierstrass_invariants(coeffs: Poly, p: int, cap: int) -> Tuple[int, int]:
    """
    Iwasawa invariants of a nonzero element g = sum a_i T^i of Z_p[[T]],
    given its low-degree-first coefficients to p-adic precision p^cap.
        mu     = min_i v_p(a_i)
        lambda = least i achieving that minimum
    so that g = p^mu * unit * (distinguished polynomial of degree lambda).
    """
    vals = [p_val(c, p, cap) for c in coeffs]
    mu = min(vals)
    lam = next(i for i, v in enumerate(vals) if v == mu)
    return mu, lam


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_torsion_of_finite_module(p: int = 5, N: int = 3, seed: int = 7) -> None:
    """
    DEMO 1.  Build a finite free module M = (Z/p^N)^r and a random action of
    T = X by an r x r matrix Phi.  Compute the Cayley-Hamilton polynomial q,
    verify q(Phi) = 0, and verify the power series q(T) annihilates a basis
    of M (hence all of M).  This is the constructive content of
    `isTorsion_of_finite`.
    """
    import random
    rng = random.Random(seed)
    mod = p ** N
    r = 4
    phi: Matrix = [[rng.randrange(mod) for _ in range(r)] for _ in range(r)]

    print("=" * 72)
    print("DEMO 1 — Torsion of a module finite over R = Z/%d  (p=%d, N=%d)" % (mod, p, N))
    print("=" * 72)
    print("Operator phi = 'multiply by T' on M = (Z/%d)^%d:" % (mod, r))
    for row in phi:
        print("   ", row)

    q = char_poly_berkowitz(phi, mod)
    print("\nCayley-Hamilton polynomial q(T) (low-degree first):")
    print("   ", q)
    print("Leading coefficient =", q[-1], " (monic => q != 0)")

    qphi = poly_eval_matrix(q, phi, mod)
    print("\nq(phi) =", "ZERO matrix (Cayley-Hamilton holds!)" if is_zero_matrix(qphi)
          else "NONZERO — something is wrong")

    # q(T) acts on M as q(phi); check it kills each basis vector.
    all_killed = True
    for i in range(r):
        e_i = [1 if j == i else 0 for j in range(r)]
        out = mat_apply(qphi, e_i, mod)
        if any(out):
            all_killed = False
    print("q(T) annihilates every basis vector of M:", all_killed)
    print("=> M is Lambda-torsion, witnessed by the nonzero element s = q(T).")


def demo_lambda_not_torsion(p: int = 5, N: int = 3, deg: int = 6) -> None:
    """
    DEMO 2.  The counterexample of the paper: M = Lambda = R[[X]] itself is
    NOT finite over R, and is NOT torsion.  We model truncated power series
    mod X^deg and mod p^N, and show that 'multiply by X' (the shift) satisfies
    no nonzero polynomial of bounded degree: for the element 1, the powers
    1, X, X^2, ... stay R-independent, so no nonzero s kills 1 (s . 1 = s).
    """
    mod = p ** N
    print("\n" + "=" * 72)
    print("DEMO 2 — The hypothesis is essential: M = Lambda is NOT torsion")
    print("=" * 72)
    print("Truncating power series mod X^%d and mod %d." % (deg, mod))
    # 'multiply by X' shifts coefficients up by one (drop top, in truncation).
    shift: Matrix = [[1 if i == j + 1 else 0 for j in range(deg)] for i in range(deg)]
    one = [1] + [0] * (deg - 1)
    print("Powers X^k . 1 for k = 0..%d (each is a distinct basis vector):" % (deg - 1))
    v = one[:]
    for k in range(deg):
        print("   X^%d . 1 =" % k, v)
        v = mat_apply(shift, v, mod)
    print("These are R-linearly independent, so for any nonzero s in Lambda,")
    print("s . 1 = s != 0.  Hence Ann_Lambda(Lambda) = (0): Lambda is NOT torsion.")
    print("(Lambda is NOT finite over R, so Cayley-Hamilton does not apply.)")


def demo_weierstrass(p: int = 5, cap: int = 6) -> None:
    """
    DEMO 3.  Extract Iwasawa invariants (mu, lambda) from a characteristic
    element g in Z_p[[T]] via Weierstrass data:  g = p^mu * unit * P,
    with P a distinguished polynomial of degree lambda.
    """
    print("\n" + "=" * 72)
    print("DEMO 3 — Weierstrass invariants (mu, lambda) of characteristic elements")
    print("=" * 72)
    examples: List[Tuple[str, Poly]] = [
        ("g = T^2 + p*T + p^2          (mu=0, lambda=2)", [p * p, p, 1]),
        ("g = p*(T + 1)                (mu=1, lambda=0)", [p, p]),
        ("g = p^2*T^3 + p^2            (mu=2, lambda=0)", [p * p, 0, 0, p * p]),
        ("g = T^5 + p (distinguished)  (mu=0, lambda=5)", [p, 0, 0, 0, 0, 1]),
    ]
    for label, coeffs in examples:
        mu, lam = weierstrass_invariants(coeffs, p, cap)
        print("  %-44s ->  mu=%d, lambda=%d" % (label, mu, lam))


def main() -> None:
    """Run all demonstrations."""
    demo_torsion_of_finite_module()
    demo_lambda_not_torsion()
    demo_weierstrass()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
