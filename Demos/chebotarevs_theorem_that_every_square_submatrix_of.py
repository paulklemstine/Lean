#!/usr/bin/env python3
"""
Chebotarev's theorem on roots of unity and its consequences.

Numerical demonstrations of:

  1. Chebotarev's theorem:   every square submatrix of the p x p DFT matrix
     (p prime) is nonsingular -- checked exhaustively for small primes.
  2. The exact integer certificate:  det((1+X)^{a_i b_j}) vanishes at X = 0 to
     order exactly N = n(n-1)/2, and its N-th coefficient equals
     det(vandermonde(a)) * det(binom(b_i, k)), an integer prime to p.
  3. The converse:  every composite modulus M has a singular 2x2 minor
     A = {0, M/d}, B = {0, d}.
  4. The prime-order uncertainty principle:  #supp f + #supp f^ >= p + 1,
     with sharpness on an arbitrary prescribed support.
  5. Exact sparse recovery from ANY 2k Fourier coefficients, and failure at
     2k - 1 coefficients.
  6. The Cauchy-Davenport inequality  #(A+B) >= min(p, #A + #B - 1).

Pure standard library: no third-party dependencies.
"""

from __future__ import annotations

import cmath
import itertools
import math
import random
from typing import Dict, List, Optional, Sequence, Set, Tuple

Matrix = List[List[complex]]

# --------------------------------------------------------------------------- #
# Basic linear algebra over the complex numbers                                #
# --------------------------------------------------------------------------- #


def det(matrix: Matrix) -> complex:
    """Determinant by Gaussian elimination with partial pivoting."""
    a = [row[:] for row in matrix]
    n = len(a)
    result: complex = 1.0 + 0.0j
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            return 0.0 + 0.0j
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            result = -result
        result *= a[col][col]
        inv = 1.0 / a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] * inv
            if factor != 0:
                for c in range(col, n):
                    a[r][c] -= factor * a[col][c]
    return result


def solve_least_squares(a: Matrix, b: Sequence[complex]) -> Optional[List[complex]]:
    """Solve the (possibly overdetermined) system a x = b exactly if consistent.

    Returns None when the system has no exact solution (residual > tol).
    """
    rows, cols = len(a), len(a[0])
    aug = [list(a[i]) + [b[i]] for i in range(rows)]
    pivots: List[int] = []
    row = 0
    for col in range(cols):
        piv = None
        best = 1e-10
        for r in range(row, rows):
            if abs(aug[r][col]) > best:
                best, piv = abs(aug[r][col]), r
        if piv is None:
            continue
        aug[row], aug[piv] = aug[piv], aug[row]
        inv = 1.0 / aug[row][col]
        for c in range(col, cols + 1):
            aug[row][c] *= inv
        for r in range(rows):
            if r != row and abs(aug[r][col]) > 0:
                f = aug[r][col]
                for c in range(col, cols + 1):
                    aug[r][c] -= f * aug[row][c]
        pivots.append(col)
        row += 1
        if row == rows:
            break
    for r in range(row, rows):
        if abs(aug[r][cols]) > 1e-8:
            return None
    if len(pivots) < cols:
        return None
    x = [0.0 + 0.0j] * cols
    for i, col in enumerate(pivots):
        x[col] = aug[i][cols]
    return x


def null_vector(a: Matrix) -> List[complex]:
    """A nonzero vector v with a v = 0, for a matrix with nontrivial kernel."""
    rows, cols = len(a), len(a[0])
    m = [row[:] for row in a]
    pivots: List[int] = []
    row = 0
    for col in range(cols):
        piv = None
        best = 1e-10
        for r in range(row, rows):
            if abs(m[r][col]) > best:
                best, piv = abs(m[r][col]), r
        if piv is None:
            continue
        m[row], m[piv] = m[piv], m[row]
        inv = 1.0 / m[row][col]
        for c in range(col, cols):
            m[row][c] *= inv
        for r in range(rows):
            if r != row:
                f = m[r][col]
                if abs(f) > 0:
                    for c in range(col, cols):
                        m[r][c] -= f * m[row][c]
        pivots.append(col)
        row += 1
    free = [c for c in range(cols) if c not in pivots]
    if not free:
        raise ValueError("matrix has trivial kernel")
    f0 = free[0]
    v = [0.0 + 0.0j] * cols
    v[f0] = 1.0 + 0.0j
    for i, col in enumerate(pivots):
        v[col] = -m[i][f0]
    return v


# --------------------------------------------------------------------------- #
# Discrete Fourier transform on Z/M                                            #
# --------------------------------------------------------------------------- #


def root_of_unity(modulus: int, exponent: int) -> complex:
    """exp(-2 pi i * exponent / modulus): the DFT kernel."""
    return cmath.exp(-2j * cmath.pi * (exponent % modulus) / modulus)


def dft_minor(modulus: int, rows: Sequence[int], cols: Sequence[int]) -> Matrix:
    """The submatrix (zeta^{a b}) of the DFT matrix of order `modulus`."""
    return [[root_of_unity(modulus, a * b) for b in cols] for a in rows]


def dft(signal: Sequence[complex], modulus: int) -> List[complex]:
    """Discrete Fourier transform of a signal on Z/modulus."""
    return [
        sum(signal[x] * root_of_unity(modulus, x * t) for x in range(modulus))
        for t in range(modulus)
    ]


def support(vec: Sequence[complex], tol: float = 1e-9) -> Set[int]:
    return {i for i, z in enumerate(vec) if abs(z) > tol}


# --------------------------------------------------------------------------- #
# 1. Exhaustive verification of Chebotarev's theorem                           #
# --------------------------------------------------------------------------- #


def check_all_minors(modulus: int) -> Tuple[int, int, float]:
    """Return (#minors, #singular minors, smallest nonzero |det|)."""
    total, singular = 0, 0
    smallest = math.inf
    residues = list(range(modulus))
    for n in range(1, modulus + 1):
        for rows in itertools.combinations(residues, n):
            for cols in itertools.combinations(residues, n):
                value = abs(det(dft_minor(modulus, rows, cols)))
                total += 1
                if value < 1e-9:
                    singular += 1
                else:
                    smallest = min(smallest, value)
    return total, singular, smallest


# --------------------------------------------------------------------------- #
# 2. The exact integer certificate (staircase coefficient)                     #
# --------------------------------------------------------------------------- #

Poly = List[int]  # dense coefficient list, index = degree


def poly_mul(p: Poly, q: Poly) -> Poly:
    out = [0] * (len(p) + len(q) - 1)
    for i, x in enumerate(p):
        if x:
            for j, y in enumerate(q):
                out[i + j] += x * y
    return out


def poly_pow(p: Poly, e: int) -> Poly:
    result: Poly = [1]
    base = p
    while e:
        if e & 1:
            result = poly_mul(result, base)
        base = poly_mul(base, base)
        e >>= 1
    return result


def poly_det(matrix: List[Poly]) -> Poly:
    """Determinant of a matrix of integer polynomials, by Leibniz expansion."""
    n = len(matrix)
    total: Poly = [0]
    for perm in itertools.permutations(range(n)):
        sign = permutation_sign(perm)
        term: Poly = [sign]
        for i, j in enumerate(perm):
            term = poly_mul(term, matrix[i][j])
        if len(term) > len(total):
            total = total + [0] * (len(term) - len(total))
        for k, c in enumerate(term):
            total[k] += c
    return total


def permutation_sign(perm: Sequence[int]) -> int:
    sign = 1
    seen = [False] * len(perm)
    for i in range(len(perm)):
        if not seen[i]:
            j, length = i, 0
            while not seen[j]:
                seen[j] = True
                j = perm[j]
                length += 1
            if length % 2 == 0:
                sign = -sign
    return sign


def cheb_poly(a: Sequence[int], b: Sequence[int]) -> Poly:
    """P(X) = det((1 + X)^{a_i b_j}) in Z[X]."""
    one_plus_x: Poly = [1, 1]
    return poly_det([[poly_pow(one_plus_x, ai * bj) for bj in b] for ai in a])


def vandermonde_det(values: Sequence[int]) -> int:
    result = 1
    for i in range(len(values)):
        for j in range(i + 1, len(values)):
            result *= values[j] - values[i]
    return result


def choose_det(b: Sequence[int]) -> int:
    """det(C(b_i, k)) = vandermonde(b) / (0! 1! ... (n-1)!)."""
    n = len(b)
    superfactorial = math.prod(math.factorial(k) for k in range(n))
    num = vandermonde_det(b)
    assert num % superfactorial == 0
    return num // superfactorial


def staircase(n: int) -> int:
    return n * (n - 1) // 2


def certificate(p: int, a: Sequence[int], b: Sequence[int]) -> Dict[str, int]:
    """The closed-form staircase coefficient and its residue mod p."""
    coefficient = vandermonde_det(list(a)) * choose_det(list(b))
    return {
        "N": staircase(len(a)),
        "coefficient": coefficient,
        "coefficient_mod_p": coefficient % p,
    }


# --------------------------------------------------------------------------- #
# 3. Composite counterexample                                                  #
# --------------------------------------------------------------------------- #


def composite_singular_minor(modulus: int) -> Optional[Tuple[List[int], List[int]]]:
    """For composite `modulus`, the explicit singular 2x2 pattern."""
    for d in range(2, modulus):
        if modulus % d == 0 and d < modulus:
            e = modulus // d
            if e >= 2:
                return [0, e], [0, d]
    return None


# --------------------------------------------------------------------------- #
# 4/5. Uncertainty principle, extremal functions, sparse recovery              #
# --------------------------------------------------------------------------- #


def extremal_function(p: int, a_set: Sequence[int], s_set: Sequence[int]) -> List[complex]:
    """Nonzero f supported in a_set whose transform vanishes on s_set.

    Requires len(a_set) == len(s_set) + 1.  By the rigidity theorem the answer
    is unique up to scale, and by Chebotarev its support is all of a_set.
    """
    assert len(a_set) == len(s_set) + 1
    m = len(s_set)
    rows = [[root_of_unity(p, alpha * sigma) for alpha in a_set] for sigma in s_set]
    rows.append([0.0 + 0.0j] * (m + 1))  # pad to square: forces a kernel
    coeffs = null_vector(rows)
    f = [0.0 + 0.0j] * p
    for value, alpha in zip(coeffs, a_set):
        f[alpha] = value
    return f


def sparse_decode(
    p: int, freqs: Sequence[int], measurements: Sequence[complex], k: int
) -> Optional[List[complex]]:
    """Support-enumeration decoder: recover a k-sparse signal from #freqs >= 2k
    arbitrary Fourier coefficients."""
    for candidate in itertools.combinations(range(p), k):
        a = [[root_of_unity(p, x * t) for x in candidate] for t in freqs]
        sol = solve_least_squares(a, list(measurements))
        if sol is not None:
            f = [0.0 + 0.0j] * p
            for value, x in zip(sol, candidate):
                f[x] = value
            return f
    return None


# --------------------------------------------------------------------------- #
# 6. Cauchy-Davenport                                                          #
# --------------------------------------------------------------------------- #


def sumset(p: int, A: Sequence[int], B: Sequence[int]) -> Set[int]:
    return {(a + b) % p for a in A for b in B}


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #


def demo_chebotarev() -> None:
    print("=" * 74)
    print("1.  CHEBOTAREV'S THEOREM: every square minor of F_p is nonsingular")
    print("=" * 74)
    for p in (3, 5, 7):
        total, singular, smallest = check_all_minors(p)
        print(
            f"  p = {p:2d}:  {total:5d} square minors, {singular} singular, "
            f"min |det| = {smallest:.6f}"
        )
    print("\n  Composite moduli, by contrast:")
    for m in (4, 6, 8, 9, 10, 12, 15):
        rows, cols = composite_singular_minor(m)  # type: ignore[misc]
        value = abs(det(dft_minor(m, rows, cols)))
        total, singular, _ = check_all_minors(m) if m <= 8 else (None, None, None)
        extra = f", {singular} singular of {total} minors" if total else ""
        print(f"  M = {m:2d}:  rows {rows}, cols {cols} -> |det| = {value:.2e}{extra}")


def demo_certificate() -> None:
    print()
    print("=" * 74)
    print("2.  THE EXACT INTEGER CERTIFICATE (staircase coefficient)")
    print("=" * 74)
    cases = [(5, (1, 2, 3), (0, 1, 4)), (7, (0, 2, 5), (1, 3, 6)), (7, (1, 4), (2, 6))]
    for p, a, b in cases:
        poly = cheb_poly(a, b)
        n = len(a)
        N = staircase(n)
        order = next(i for i, c in enumerate(poly) if c != 0)
        cert = certificate(p, a, b)
        print(f"  p = {p}, a = {a}, b = {b}")
        print(f"    predicted vanishing order N = n(n-1)/2 = {N}; observed = {order}")
        print(f"    [X^N] P            = {poly[N]}")
        print(f"    vandermonde * chooseDet = {cert['coefficient']}")
        print(
            f"    residue mod p      = {cert['coefficient_mod_p']}"
            f"   (nonzero => minor nonsingular)"
        )
        assert order == N and poly[N] == cert["coefficient"] != 0
        assert cert["coefficient_mod_p"] != 0


def demo_uncertainty(seed: int = 20260818) -> None:
    print()
    print("=" * 74)
    print("3.  UNCERTAINTY PRINCIPLE:  #supp f + #supp f^ >= p + 1")
    print("=" * 74)
    rng = random.Random(seed)
    p = 11
    worst = math.inf
    for _ in range(200):
        k = rng.randint(1, p)
        positions = rng.sample(range(p), k)
        f = [0.0 + 0.0j] * p
        for x in positions:
            f[x] = complex(rng.randint(-3, 3), rng.randint(-3, 3))
        if all(abs(z) == 0 for z in f):
            continue
        total = len(support(f)) + len(support(dft(f, p)))
        worst = min(worst, total)
    print(f"  p = {p}: minimum of #supp f + #supp f^ over 200 random signals = {int(worst)}")
    print(f"  (theoretical minimum p + 1 = {p + 1})")

    print("\n  Sharpness on an arbitrary prescribed support:")
    for A in ([0], [0, 1, 5], [2, 3, 7, 8, 9]):
        S = [t for t in range(len(A) - 1)]
        f = extremal_function(p, A, S)
        sf, sF = len(support(f)), len(support(dft(f, p)))
        print(
            f"    A = {A}: supp f = {sorted(support(f))}, "
            f"#supp f + #supp f^ = {sf} + {sF} = {sf + sF}"
        )
        assert sorted(support(f)) == sorted(A)
        assert sf + sF == p + 1

    print("\n  Composite modulus M = 12, subgroup indicator 1_{4Z/12}:")
    f = [1.0 + 0.0j if x % 4 == 0 else 0.0 + 0.0j for x in range(12)]
    sf, sF = len(support(f)), len(support(dft(f, 12)))
    print(f"    #supp f + #supp f^ = {sf} + {sF} = {sf + sF}  <<  M + 1 = 13")


def demo_sparse_recovery(seed: int = 7) -> None:
    print()
    print("=" * 74)
    print("4.  EXACT SPARSE RECOVERY FROM ANY 2k FOURIER COEFFICIENTS")
    print("=" * 74)
    rng = random.Random(seed)
    p, k = 13, 2
    for trial in range(3):
        positions = rng.sample(range(p), k)
        f = [0.0 + 0.0j] * p
        for x in positions:
            f[x] = complex(rng.randint(1, 4), rng.randint(-4, 4))
        freqs = rng.sample(range(p), 2 * k)  # adversarially arbitrary
        spectrum = dft(f, p)
        measurements = [spectrum[t] for t in freqs]
        recovered = sparse_decode(p, freqs, measurements, k)
        assert recovered is not None
        err = max(abs(recovered[x] - f[x]) for x in range(p))
        print(
            f"  trial {trial + 1}: support {sorted(positions)}, "
            f"measured at {sorted(freqs)} -> max error {err:.2e}"
        )

    print("\n  With only 2k - 1 frequencies, uniqueness fails:")
    S = rng.sample(range(p), 2 * k - 1)
    A = rng.sample([x for x in range(p)], 2 * k)
    h = extremal_function(p, A, S)
    A1, A2 = A[:k], A[k:]
    f1 = [h[x] if x in A1 else 0 for x in range(p)]
    f2 = [-h[x] if x in A2 else 0 for x in range(p)]
    d1, d2 = dft(f1, p), dft(f2, p)
    gap = max(abs(d1[t] - d2[t]) for t in S)
    print(f"    frequencies S = {sorted(S)}")
    print(f"    two distinct {k}-sparse signals on {sorted(A1)} and {sorted(A2)}")
    print(f"    max |f1^(t) - f2^(t)| over t in S = {gap:.2e}   (identical data)")
    assert gap < 1e-8


def demo_cauchy_davenport(seed: int = 3) -> None:
    print()
    print("=" * 74)
    print("5.  CAUCHY-DAVENPORT:  #(A+B) >= min(p, #A + #B - 1)")
    print("=" * 74)
    rng = random.Random(seed)
    for p in (7, 11, 13):
        tight = 0
        trials = 300
        for _ in range(trials):
            A = rng.sample(range(p), rng.randint(1, p))
            B = rng.sample(range(p), rng.randint(1, p))
            lhs = len(sumset(p, A, B))
            rhs = min(p, len(A) + len(B) - 1)
            assert lhs >= rhs, (A, B)
            tight += lhs == rhs
        print(f"  p = {p:2d}: {trials} random pairs verified; bound tight in {tight} cases")
    print("\n  Extremal example (arithmetic progressions, p = 11):")
    A = [0, 1, 2]
    B = [0, 1, 2, 3]
    print(
        f"    A = {A}, B = {B}: #(A+B) = {len(sumset(11, A, B))} "
        f"= #A + #B - 1 = {len(A) + len(B) - 1}"
    )


def main() -> None:
    demo_chebotarev()
    demo_certificate()
    demo_uncertainty()
    demo_sparse_recovery()
    demo_cauchy_davenport()
    print()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
