"""
Numerical demonstrations for the additive uncertainty principle on Z/pZ.

Everything is self-contained: complex arithmetic, Gaussian elimination,
determinants and the discrete Fourier transform are implemented from scratch
so that the script runs on a bare Python 3 installation.

The demonstrations are:

  1. The discrete Fourier transform on Z/nZ and support counting.
  2. The additive uncertainty principle  |supp f| + |supp f_hat| >= p + 1
     verified exhaustively over structured and random signals.
  3. The strict gap between the additive bound and the multiplicative bound
     |supp f| * |supp f_hat| >= p  (the p = 13, 4 + 4 example).
  4. Chebotarev's theorem: every square minor of the prime Fourier matrix is
     nonsingular -- checked exhaustively for small primes, and contrasted with
     the singular minors that appear for composite moduli.
  5. Frenkel's combinatorial identity
         (prod_{j<k} j!) * G_N = V(a) * V(b),
     with G_N the N-th coefficient of det((X+1)^{a_i b_j}), N = k(k-1)/2.
  6. The exact converse: for any A, B with |A| + |B| = p + 1 we construct a
     signal whose support is exactly A and whose spectrum's support is
     exactly B.
  7. Deterministic sparse recovery from an arbitrary set of 2k frequencies,
     and failure at 2k - 1 frequencies.
  8. The primality criterion: subgroup indicators break the additive bound for
     every composite modulus.

Run with:  python3 demo.py
"""

from __future__ import annotations

import cmath
import itertools
import math
import random
from typing import Dict, List, Sequence, Tuple

Complex = complex
Matrix = List[List[Complex]]
Signal = List[Complex]

TOL = 1e-9


# ---------------------------------------------------------------------------
# Basic linear algebra
# ---------------------------------------------------------------------------


def zeta(n: int, e: int = 1) -> Complex:
    """The power zeta_n^e of the primitive n-th root of unity exp(-2*pi*i/n)."""
    return cmath.exp(-2j * cmath.pi * (e % n) / n)


def dft(f: Sequence[Complex], n: int) -> Signal:
    """Discrete Fourier transform on Z/nZ: f_hat(k) = sum_x zeta_n^{kx} f(x)."""
    return [sum(zeta(n, k * x) * f[x] for x in range(n)) for k in range(n)]


def support(f: Sequence[Complex], tol: float = TOL) -> List[int]:
    """Indices where the signal is (numerically) nonzero."""
    return [i for i, v in enumerate(f) if abs(v) > tol]


def determinant(mat: Matrix) -> Complex:
    """Determinant by Gaussian elimination with partial pivoting."""
    a = [row[:] for row in mat]
    m = len(a)
    if m == 0:
        return 1.0 + 0j
    det: Complex = 1.0 + 0j
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            return 0.0 + 0j
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = 1.0 / a[col][col]
        for r in range(col + 1, m):
            factor = a[r][col] * inv
            if factor != 0:
                for c in range(col, m):
                    a[r][c] -= factor * a[col][c]
    return det


def solve(mat: Matrix, rhs: Sequence[Complex]) -> Signal:
    """Solve a square nonsingular system by Gaussian elimination."""
    m = len(mat)
    a = [list(mat[r]) + [rhs[r]] for r in range(m)]
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            raise ValueError("singular system")
        a[col], a[pivot] = a[pivot], a[col]
        inv = 1.0 / a[col][col]
        for c in range(col, m + 1):
            a[col][c] *= inv
        for r in range(m):
            if r != col and a[r][col] != 0:
                factor = a[r][col]
                for c in range(col, m + 1):
                    a[r][c] -= factor * a[col][c]
    return [a[r][m] for r in range(m)]


def fourier_minor(n: int, rows: Sequence[int], cols: Sequence[int]) -> Matrix:
    """The submatrix (zeta_n^{k x}) with k in `rows` (frequencies), x in `cols`."""
    return [[zeta(n, k * x) for x in cols] for k in rows]


# ---------------------------------------------------------------------------
# 1-3. The uncertainty principles
# ---------------------------------------------------------------------------


def support_pair(f: Sequence[Complex], n: int) -> Tuple[int, int]:
    """Return (|supp f|, |supp f_hat|)."""
    return len(support(f)), len(support(dft(f, n)))


def demo_uncertainty(p: int = 13, trials: int = 400, seed: int = 20260822) -> None:
    print(f"\n=== 1-2. Additive uncertainty principle on Z/{p}Z ===")
    rng = random.Random(seed)

    delta: Signal = [0j] * p
    delta[3] = 1.0 + 0j
    a, b = support_pair(delta, p)
    print(f"  delta at 3            : |supp f| = {a:2d}, |supp f_hat| = {b:2d}, sum = {a + b}")

    const: Signal = [1.0 + 0j] * p
    a, b = support_pair(const, p)
    print(f"  constant 1            : |supp f| = {a:2d}, |supp f_hat| = {b:2d}, sum = {a + b}")

    worst = None
    for _ in range(trials):
        k = rng.randint(1, p)
        positions = rng.sample(range(p), k)
        f = [0j] * p
        for x in positions:
            f[x] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
        a, b = support_pair(f, p)
        assert a + b >= p + 1, (a, b)
        if worst is None or a + b < worst[0]:
            worst = (a + b, a, b)
    assert worst is not None
    print(f"  {trials} random signals : minimum observed sum = {worst[0]} "
          f"(reached at |supp f| = {worst[1]}, |supp f_hat| = {worst[2]}); bound is {p + 1}")


def demo_additive_beats_multiplicative(p: int = 13) -> None:
    print(f"\n=== 3. The additive bound is strictly stronger (p = {p}) ===")
    alpha = beta = 4
    print(f"  candidate support sizes ({alpha}, {beta})")
    print(f"    multiplicative bound: {alpha} * {beta} = {alpha * beta} >= {p}  -> permitted")
    print(f"    additive bound      : {alpha} + {beta} = {alpha + beta} >= {p + 1}? "
          f"{'yes' if alpha + beta >= p + 1 else 'NO -> forbidden'}")
    forbidden = [(a, b) for a in range(1, p + 1) for b in range(1, p + 1)
                 if a * b >= p and a + b < p + 1]
    print(f"  pairs allowed by the product bound but excluded by the sum bound: {len(forbidden)}")
    print(f"    e.g. {forbidden[:6]}")


# ---------------------------------------------------------------------------
# 4. Chebotarev's theorem
# ---------------------------------------------------------------------------


def all_minors_nonsingular(n: int, max_size: int | None = None) -> Tuple[int, List[Tuple]]:
    """Check every square minor of the n x n Fourier matrix; return failures."""
    top = n if max_size is None else min(n, max_size)
    checked = 0
    failures: List[Tuple] = []
    for k in range(1, top + 1):
        for rows in itertools.combinations(range(n), k):
            for cols in itertools.combinations(range(n), k):
                d = determinant(fourier_minor(n, rows, cols))
                checked += 1
                if abs(d) < 1e-8:
                    failures.append((rows, cols, d))
    return checked, failures


def demo_chebotarev(primes: Sequence[int] = (5, 7), composites: Sequence[int] = (4, 6)) -> None:
    print("\n=== 4. Chebotarev: total nonsingularity of the prime Fourier matrix ===")
    for p in primes:
        checked, failures = all_minors_nonsingular(p)
        status = "ALL NONSINGULAR" if not failures else f"{len(failures)} SINGULAR"
        print(f"  n = {p} (prime)    : {checked:6d} square minors checked -> {status}")
    for n in composites:
        checked, failures = all_minors_nonsingular(n)
        print(f"  n = {n} (composite): {checked:6d} square minors checked -> "
              f"{len(failures)} singular")
        if failures:
            rows, cols, _ = failures[0]
            print(f"      first singular block: rows {rows}, columns {cols}")


# ---------------------------------------------------------------------------
# 5. Frenkel's identity  sf(k) * G_N = V(a) * V(b)
# ---------------------------------------------------------------------------


def poly_mul(u: Sequence[int], v: Sequence[int]) -> List[int]:
    out = [0] * (len(u) + len(v) - 1)
    for i, ui in enumerate(u):
        if ui:
            for j, vj in enumerate(v):
                out[i + j] += ui * vj
    return out


def shifted_det_coeffs(a: Sequence[int], b: Sequence[int]) -> Dict[int, int]:
    """Coefficients of G(X) = det((X+1)^{a_i b_j}) via the Leibniz formula.

    Each permutation sigma contributes sgn(sigma) * (X+1)^{s_sigma},
    s_sigma = sum_i a_{sigma(i)} b_i, whose coefficients are binomials.
    """
    k = len(a)
    coeffs: Dict[int, int] = {}
    for perm in itertools.permutations(range(k)):
        sign = permutation_sign(perm)
        s = sum(a[perm[i]] * b[i] for i in range(k))
        for d in range(s + 1):
            coeffs[d] = coeffs.get(d, 0) + sign * math.comb(s, d)
    return {d: c for d, c in coeffs.items() if c != 0}


def permutation_sign(perm: Sequence[int]) -> int:
    """Sign of a permutation given as a tuple of images."""
    seen = [False] * len(perm)
    sign = 1
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


def vandermonde(a: Sequence[int]) -> int:
    """V(a) = prod_{i<j} (a_j - a_i)."""
    out = 1
    for i in range(len(a)):
        for j in range(i + 1, len(a)):
            out *= a[j] - a[i]
    return out


def superfactorial(k: int) -> int:
    """sf(k) = prod_{j<k} j!."""
    out = 1
    for j in range(k):
        out *= math.factorial(j)
    return out


def demo_frenkel(p: int = 7) -> None:
    print(f"\n=== 5. Frenkel's identity  sf(k)*G_N = V(a)*V(b)  (residues mod {p}) ===")
    for k in (2, 3):
        for a in itertools.combinations(range(p), k):
            for b in itertools.combinations(range(p), k):
                coeffs = shifted_det_coeffs(a, b)
                N = k * (k - 1) // 2
                below = [d for d in coeffs if d < N]
                gN = coeffs.get(N, 0)
                lhs = superfactorial(k) * gN
                rhs = vandermonde(a) * vandermonde(b)
                assert not below, (a, b, below)
                assert lhs == rhs, (a, b, lhs, rhs)
        print(f"  k = {k}: for all choices of {k} distinct residues a, b < {p}:")
        print(f"           all coefficients of G below degree N = {k * (k - 1) // 2} vanish, "
              f"and sf({k})*G_N = V(a)V(b)")
    a, b = (1, 3, 4), (0, 2, 5)
    coeffs = shifted_det_coeffs(a, b)
    N = 3
    print(f"  example a = {a}, b = {b}: G_N = {coeffs.get(N, 0)}, "
          f"V(a) = {vandermonde(a)}, V(b) = {vandermonde(b)}, sf(3) = {superfactorial(3)}")
    print(f"           p = {p} divides V(a)V(b) = {vandermonde(a) * vandermonde(b)}? "
          f"{(vandermonde(a) * vandermonde(b)) % p == 0}  <- must be False")


# ---------------------------------------------------------------------------
# 6. The exact converse: prescribing both supports
# ---------------------------------------------------------------------------


def kernel_vector_via_minors(mat: Matrix) -> Signal:
    """Nonzero kernel vector of an (m) x (m+1) matrix via signed maximal minors."""
    m = len(mat)
    cols = len(mat[0])
    assert cols == m + 1
    out: Signal = []
    for j in range(cols):
        sub = [[row[c] for c in range(cols) if c != j] for row in mat]
        out.append(((-1) ** j) * determinant(sub))
    return out


def extremal_signal(p: int, A: Sequence[int], B: Sequence[int]) -> Signal:
    """Signal with supp f = A and supp f_hat = B, for |A| + |B| = p + 1."""
    assert len(A) + len(B) == p + 1
    R = [k for k in range(p) if k not in set(B)]
    mat = fourier_minor(p, R, A)  # (|A| - 1) x |A|
    coeffs = kernel_vector_via_minors(mat)
    scale = max(abs(c) for c in coeffs)
    f: Signal = [0j] * p
    for x, c in zip(A, coeffs):
        f[x] = c / scale
    return f


def demo_exact_converse(p: int = 11) -> None:
    print(f"\n=== 6. Exact converse: every admissible support pair occurs (p = {p}) ===")
    cases = [([0, 1, 2, 3], list(range(p))[:p + 1 - 4]),
             ([2, 5, 7], sorted(random.Random(7).sample(range(p), p + 1 - 3))),
             ([0, 1, 4, 6, 9], sorted(random.Random(11).sample(range(p), p + 1 - 5)))]
    for A, B in cases:
        f = extremal_signal(p, A, B)
        got_a, got_b = support(f), support(dft(f, p))
        ok = got_a == sorted(A) and got_b == sorted(B)
        print(f"  |A| = {len(A)}, |B| = {len(B)}, |A|+|B| = {len(A) + len(B)} = p+1 : "
              f"supports reproduced exactly? {ok}")
        print(f"      A = {sorted(A)}")
        print(f"      B = {sorted(B)}")


# ---------------------------------------------------------------------------
# 7. Deterministic sparse recovery
# ---------------------------------------------------------------------------


def recover_sparse(p: int, k: int, S: Sequence[int], data: Sequence[Complex]) -> Signal:
    """Brute-force deterministic recovery of a k-sparse signal from |S| >= 2k samples."""
    assert len(S) >= 2 * k
    for A in itertools.combinations(range(p), k):
        mat = fourier_minor(p, S[:k], A)
        try:
            c = solve(mat, [data[S.index(s)] for s in S[:k]])
        except ValueError:
            continue
        cand: Signal = [0j] * p
        for x, v in zip(A, c):
            cand[x] = v
        spec = dft(cand, p)
        if all(abs(spec[s] - data[i]) < 1e-7 for i, s in enumerate(S)):
            return cand
    raise RuntimeError("no consistent candidate (should not happen)")


def demo_sparse_recovery(p: int = 13, k: int = 2, seed: int = 5) -> None:
    print(f"\n=== 7. Deterministic sparse recovery on Z/{p}Z, k = {k} ===")
    rng = random.Random(seed)
    positions = sorted(rng.sample(range(p), k))
    f: Signal = [0j] * p
    for x in positions:
        f[x] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    spec = dft(f, p)

    S = sorted(rng.sample(range(p), 2 * k))
    data = [spec[s] for s in S]
    rec = recover_sparse(p, k, S, data)
    err = max(abs(rec[i] - f[i]) for i in range(p))
    print(f"  true support {positions}, arbitrary frequency set S = {S} (|S| = 2k = {2 * k})")
    print(f"  recovery error = {err:.2e}  -> exact recovery from an arbitrary sampling pattern")

    S_short = S[:2 * k - 1]
    A = sorted(rng.sample(range(p), 2 * k))
    mat = fourier_minor(p, S_short, A)
    h_coeffs = kernel_vector_via_minors(mat)
    h: Signal = [0j] * p
    for x, c in zip(A, h_coeffs):
        h[x] = c
    g1: Signal = [0j] * p
    g2: Signal = [0j] * p
    for idx, x in enumerate(A):
        if idx < k:
            g1[x] = h[x]
        else:
            g2[x] = -h[x]
    s1, s2 = dft(g1, p), dft(g2, p)
    agree = max(abs(s1[s] - s2[s]) for s in S_short)
    print(f"  with only {2 * k - 1} frequencies S' = {S_short}: two distinct {k}-sparse signals")
    print(f"      supports {support(g1)} and {support(g2)}, "
          f"spectra agree on S' to {agree:.2e}  -> 2k-1 samples never suffice")


# ---------------------------------------------------------------------------
# 8. The primality criterion
# ---------------------------------------------------------------------------


def subgroup_indicator(n: int, d: int) -> Signal:
    """Indicator of the subgroup d*Z/nZ."""
    return [1.0 + 0j if x % d == 0 else 0j for x in range(n)]


def demo_primality_criterion(limit: int = 16) -> None:
    print("\n=== 8. The additive bound holds for all signals iff the modulus is prime ===")
    print("   n | prime? | witness d*e |  |supp f| + |supp f_hat|  vs  n+1")
    for n in range(2, limit + 1):
        prime = all(n % t for t in range(2, int(n ** 0.5) + 1))
        if prime:
            print(f"  {n:2d} |  yes   |      --     |  bound  >= {n + 1} holds for every signal")
            continue
        d = next(t for t in range(2, n) if n % t == 0 and n // t >= 2)
        e = n // d
        f = subgroup_indicator(n, d)
        a, b = support_pair(f, n)
        assert (a, b) == (e, d), (a, b, e, d)
        print(f"  {n:2d} |   no   |   {d} * {e:2d}    |  {a} + {b} = {a + b:2d}  <  {n + 1}"
              f"   (product {a * b} = {n})")


# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 78)
    print("THE ADDITIVE UNCERTAINTY PRINCIPLE ON CYCLIC GROUPS OF PRIME ORDER")
    print("=" * 78)
    demo_uncertainty()
    demo_additive_beats_multiplicative()
    demo_chebotarev()
    demo_frenkel()
    demo_exact_converse()
    demo_sparse_recovery()
    demo_primality_criterion()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()


"""Support-constrained Fourier interpolation on Z/pZ.

Given a prime p, a spatial set A and a frequency set B with |A| = |B|, and
arbitrary prescribed spectral data g on B, there is exactly one signal f that
vanishes off A and satisfies f_hat(k) = g(k) for every k in B.  The routine
below builds the |B| x |A| block of the Fourier matrix and solves the resulting
square system; total nonsingularity of the prime Fourier matrix guarantees that
the system is uniquely solvable for EVERY pair (A, B), with no genericity
assumption on the positions of the two sets.

Complexity: O(m^3) for m = |A| = |B| (Gauss-Jordan with partial pivoting),
plus O(m^2) to build the matrix.
"""

from __future__ import annotations

import cmath
from typing import Dict, List, Sequence

Complex = complex
Matrix = List[List[Complex]]


def zeta(n: int, e: int = 1) -> Complex:
    """Power zeta_n^e of the primitive n-th root of unity exp(-2*pi*i/n)."""
    return cmath.exp(-2j * cmath.pi * (e % n) / n)


def fourier_block(p: int, freqs: Sequence[int], positions: Sequence[int]) -> Matrix:
    """The block (zeta_p^{k x}) with rows k in `freqs`, columns x in `positions`."""
    return [[zeta(p, k * x) for x in positions] for k in freqs]


def solve_square(mat: Matrix, rhs: Sequence[Complex]) -> List[Complex]:
    """Gauss-Jordan elimination with partial pivoting on a nonsingular system."""
    m = len(mat)
    aug: List[List[Complex]] = [list(mat[r]) + [rhs[r]] for r in range(m)]
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(aug[r][col]))
        if abs(aug[pivot][col]) < 1e-14:
            raise ValueError("singular block (impossible for prime modulus)")
        aug[col], aug[pivot] = aug[pivot], aug[col]
        inv = 1.0 / aug[col][col]
        for c in range(col, m + 1):
            aug[col][c] *= inv
        for r in range(m):
            if r != col and aug[r][col] != 0:
                factor = aug[r][col]
                for c in range(col, m + 1):
                    aug[r][c] -= factor * aug[col][c]
    return [aug[r][m] for r in range(m)]


def interpolate(p: int, A: Sequence[int], B: Sequence[int],
                data: Dict[int, Complex]) -> List[Complex]:
    """Unique signal supported in A whose transform equals `data` on B."""
    if len(A) != len(B):
        raise ValueError("|A| must equal |B|")
    coeffs = solve_square(fourier_block(p, list(B), list(A)), [data[k] for k in B])
    f: List[Complex] = [0j] * p
    for x, c in zip(A, coeffs):
        f[x] = c
    return f


if __name__ == "__main__":
    p = 13
    A = [1, 4, 5, 9]
    B = [0, 2, 7, 11]
    target = {0: 1 + 0j, 2: -2j, 7: 3 + 1j, 11: 0.5 + 0j}
    f = interpolate(p, A, B, target)
    spec = [sum(zeta(p, k * x) * f[x] for x in range(p)) for k in range(p)]
    print("signal supported on", [x for x in range(p) if abs(f[x]) > 1e-9])
    print("max interpolation error:",
          max(abs(spec[k] - target[k]) for k in B))


"""Construction of extremal signals: prescribing BOTH supports.

For a prime p and any two sets A, B with |A| + |B| = p + 1 there is a signal f
with supp f = A and supp f_hat = B exactly.  The construction is explicit: let
R be the complement of B (of size |A| - 1) and consider the (|A|-1) x |A| block
of the Fourier matrix with rows R and columns A.  Its kernel is one-dimensional
and a kernel vector is given by the signed maximal minors

    c_x = (-1)^{position of x} * det(block with the column of x deleted).

Total nonsingularity of the prime Fourier matrix says every one of those minors
is nonzero, so the resulting signal is nonzero at every point of A; and since
its transform vanishes on R, the additive uncertainty principle forces the
transform to be nonzero at every point of B.

Complexity: |A| determinants of size (|A|-1), i.e. O(|A|^4) naively, or
O(|A|^3) with a single LU factorisation of the transposed block.
"""

from __future__ import annotations

import cmath
from typing import List, Sequence

Complex = complex
Matrix = List[List[Complex]]


def zeta(n: int, e: int = 1) -> Complex:
    """Power zeta_n^e of the primitive n-th root of unity exp(-2*pi*i/n)."""
    return cmath.exp(-2j * cmath.pi * (e % n) / n)


def determinant(mat: Matrix) -> Complex:
    """Determinant via Gaussian elimination with partial pivoting."""
    a = [row[:] for row in mat]
    m = len(a)
    det: Complex = 1.0 + 0j
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            return 0j
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = 1.0 / a[col][col]
        for r in range(col + 1, m):
            factor = a[r][col] * inv
            for c in range(col, m):
                a[r][c] -= factor * a[col][c]
    return det


def extremal_signal(p: int, A: Sequence[int], B: Sequence[int]) -> List[Complex]:
    """Signal with supp f = A and supp f_hat = B, valid when |A| + |B| = p + 1."""
    if len(A) + len(B) != p + 1:
        raise ValueError("need |A| + |B| = p + 1")
    R = [k for k in range(p) if k not in set(B)]
    block: Matrix = [[zeta(p, k * x) for x in A] for k in R]
    coeffs: List[Complex] = []
    for j in range(len(A)):
        minor = [[row[c] for c in range(len(A)) if c != j] for row in block]
        coeffs.append(((-1) ** j) * determinant(minor))
    scale = max(abs(c) for c in coeffs)
    f: List[Complex] = [0j] * p
    for x, c in zip(A, coeffs):
        f[x] = c / scale
    return f


if __name__ == "__main__":
    p = 11
    A = [0, 3, 4, 8]
    B = [1, 2, 3, 5, 6, 7, 9, 10]
    f = extremal_signal(p, A, B)
    spec = [sum(zeta(p, k * x) * f[x] for x in range(p)) for k in range(p)]
    print("supp f      =", [x for x in range(p) if abs(f[x]) > 1e-9], " target", A)
    print("supp f_hat  =", [k for k in range(p) if abs(spec[k]) > 1e-9], " target", B)
    print("sum of sizes =", len(A) + len(B), " p + 1 =", p + 1)


"""Deterministic k-sparse recovery from an arbitrary set of 2k frequencies.

On Z/pZ with p prime, any k-sparse signal is uniquely determined by its Fourier
values on ANY set S of 2k frequencies: if two k-sparse signals agree there,
their difference h is 2k-sparse with a spectrum vanishing on S, so
|supp h| + |supp h_hat| <= 2k + (p - 2k) = p, which the additive uncertainty
principle forbids unless h = 0.

Two algorithms are provided.

* `recover_by_search` implements the guarantee literally: every k-subset A is a
  candidate support; because every |S| x |A| block has full column rank, each
  candidate yields at most one coefficient vector, and exactly one candidate is
  consistent with the data.  Cost: O(C(p,k) * k^2 * |S|).

* `recover_by_prony` is the classical efficient route when S is a block of 2k
  CONSECUTIVE frequencies: build the k x k Hankel matrix of the samples, solve
  for the annihilating filter, find its roots among the p-th roots of unity to
  read off the support, and solve a k x k Vandermonde system for the
  amplitudes.  Cost: O(k^3 + p*k).
"""

from __future__ import annotations

import cmath
import itertools
from typing import List, Sequence, Tuple

Complex = complex
Matrix = List[List[Complex]]


def zeta(n: int, e: int = 1) -> Complex:
    """Power zeta_n^e of the primitive n-th root of unity exp(-2*pi*i/n)."""
    return cmath.exp(-2j * cmath.pi * (e % n) / n)


def solve_square(mat: Matrix, rhs: Sequence[Complex]) -> List[Complex]:
    """Gauss-Jordan with partial pivoting; raises on a singular matrix."""
    m = len(mat)
    aug = [list(mat[r]) + [rhs[r]] for r in range(m)]
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(aug[r][col]))
        if abs(aug[pivot][col]) < 1e-12:
            raise ValueError("singular")
        aug[col], aug[pivot] = aug[pivot], aug[col]
        inv = 1.0 / aug[col][col]
        for c in range(col, m + 1):
            aug[col][c] *= inv
        for r in range(m):
            if r != col and aug[r][col] != 0:
                factor = aug[r][col]
                for c in range(col, m + 1):
                    aug[r][c] -= factor * aug[col][c]
    return [aug[r][m] for r in range(m)]


def dft(f: Sequence[Complex], n: int) -> List[Complex]:
    """Discrete Fourier transform on Z/nZ."""
    return [sum(zeta(n, k * x) * f[x] for x in range(n)) for k in range(n)]


def recover_by_search(p: int, k: int, S: Sequence[int],
                      data: Sequence[Complex], tol: float = 1e-7) -> List[Complex]:
    """Recover a k-sparse signal from spectral samples on an arbitrary S, |S| >= 2k."""
    if len(S) < 2 * k:
        raise ValueError("need at least 2k samples")
    for A in itertools.combinations(range(p), k):
        block = [[zeta(p, s * x) for x in A] for s in S[:k]]
        try:
            coeffs = solve_square(block, list(data[:k]))
        except ValueError:
            continue
        cand: List[Complex] = [0j] * p
        for x, c in zip(A, coeffs):
            cand[x] = c
        spec = dft(cand, p)
        if all(abs(spec[s] - data[i]) < tol for i, s in enumerate(S)):
            return cand
    raise RuntimeError("no consistent candidate")


def recover_by_prony(p: int, k: int, start: int,
                     data: Sequence[Complex], tol: float = 1e-6
                     ) -> List[Tuple[int, Complex]]:
    """Prony recovery from the 2k consecutive frequencies start, ..., start+2k-1.

    Returns the list of (position, amplitude) pairs.
    """
    if len(data) < 2 * k:
        raise ValueError("need 2k consecutive samples")
    if k == 0:
        return []
    hankel = [[data[i + j] for j in range(k)] for i in range(k)]
    rhs = [-data[k + i] for i in range(k)]
    filt = solve_square(hankel, rhs)          # annihilating filter coefficients
    poly = list(filt) + [1.0 + 0j]            # c_0 + c_1 z + ... + z^k
    roots: List[int] = []
    for x in range(p):
        z = zeta(p, x)
        val = sum(poly[j] * z ** j for j in range(k + 1))
        if abs(val) < tol * (k + 1):
            roots.append(x)
    roots = roots[:k]
    vander = [[zeta(p, (start + i) * x) for x in roots] for i in range(len(roots))]
    amps = solve_square(vander, [data[i] for i in range(len(roots))])
    return list(zip(roots, amps))


if __name__ == "__main__":
    import random

    p, k = 23, 3
    rng = random.Random(1)
    positions = sorted(rng.sample(range(p), k))
    f: List[Complex] = [0j] * p
    for x in positions:
        f[x] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    spec = dft(f, p)

    S = sorted(rng.sample(range(p), 2 * k))
    rec = recover_by_search(p, k, S, [spec[s] for s in S])
    print("arbitrary S =", S,
          "-> error", max(abs(rec[i] - f[i]) for i in range(p)))

    start = 0
    prony = recover_by_prony(p, k, start, [spec[start + i] for i in range(2 * k)])
    print("Prony on consecutive frequencies -> support",
          sorted(x for x, _ in prony), "(true:", positions, ")")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Shared/ChebotarevMinors.lean",
    "Catalog/Shared/FourierUncertaintySum.lean",
    "Catalog/Shared/FourierUncertaintySumApplications.lean",
    "Catalog/Shared/FourierUncertaintyPrimeCriterion.lean",
    "Catalog/Shared/FourierInterpolation.lean",
    "Catalog/Shared/FourierUncertaintyRank.lean",
]

FUTURE_DIRECTIONS = read(ASSETS / "future_directions.md")

lean_proofs = "\n\n".join(
    f"-- ============================================================\n"
    f"-- FILE: {rel}\n"
    f"-- ============================================================\n\n" + read(ROOT / rel)
    for rel in LEAN_FILES
)

package = {
    "title": "The Additive Uncertainty Principle on Cyclic Groups of Prime Order",
    "domain": "Shared",
    "description": (
        "For a prime p and a nonzero signal on Z/pZ, the sizes of the supports of the signal and "
        "of its discrete Fourier transform satisfy |supp f| + |supp f-hat| >= p + 1, a strict "
        "strengthening of the classical multiplicative bound |supp f| * |supp f-hat| >= p. The "
        "bound rests on Chebotarev's theorem that every square minor of the prime-order Fourier "
        "matrix is nonsingular, is attained by every pair of support sets whose sizes add to p+1, "
        "characterises primality among moduli, and yields deterministic recovery of k-sparse "
        "signals from an arbitrary set of 2k frequencies."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-22",
    "key_results": [
        "Additive uncertainty principle: for prime p and nonzero f on Z/pZ, "
        "|supp f| + |supp f-hat| >= p + 1, strictly stronger than the multiplicative bound "
        "|supp f| * |supp f-hat| >= p (which permits, for instance, 4 + 4 on Z/13Z).",
        "Chebotarev's theorem on the minors of the prime-order Fourier matrix: every square "
        "submatrix of the matrix of powers of a primitive p-th root of unity is nonsingular, "
        "proved by an order-of-vanishing argument culminating in the identity "
        "(prod_{j<k} j!) * G_N = V(a) V(b) between the critical coefficient of the shifted "
        "determinant polynomial and a product of two Vandermonde determinants.",
        "Exact converse to the additive bound: every pair of subsets A, B of Z/pZ with "
        "|A| + |B| = p + 1 is realised as the pair of supports of some signal and its transform, "
        "so the inequality is attained at every boundary point and in every position.",
        "Primality criterion: for n >= 2 the additive bound holds for all nonzero signals on "
        "Z/nZ if and only if n is prime; for n = de with d, e >= 2 the indicator of the subgroup "
        "of index d gives |supp f| + |supp f-hat| = d + e <= n.",
        "Deterministic sparse recovery: a k-sparse signal on Z/pZ is determined by its transform "
        "on an arbitrary set of 2k frequencies, and for every set of 2k-1 frequencies there exist "
        "distinct k-sparse signals with identical data there; moreover every rectangular block of "
        "the prime Fourier matrix has rank exactly min(|A|,|B|), giving unique interpolation of "
        "prescribed spectral data by signals with prescribed support.",
    ],
    "keywords": [
        "uncertainty principle",
        "discrete Fourier transform",
        "Chebotarev's theorem",
        "cyclotomic polynomial",
        "Vandermonde determinant",
        "sparse recovery",
        "compressed sensing",
        "finite cyclic groups",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification Suite for the Additive Uncertainty Principle",
            "description": (
                "A dependency-free Python program that reconstructs every result of the paper "
                "numerically: it implements the discrete Fourier transform, complex Gaussian "
                "elimination and determinants from scratch; verifies |supp f| + |supp f-hat| >= "
                "p + 1 on structured and random signals over Z/13Z; enumerates the 43 support "
                "pairs on Z/13Z that the multiplicative bound permits and the additive bound "
                "forbids; checks exhaustively that all 251 square minors for p = 5 and all 3431 "
                "for p = 7 are nonsingular while composite moduli 4 and 6 produce 4 and 120 "
                "singular blocks respectively; confirms Frenkel's combinatorial identity "
                "(prod_{j<k} j!) G_N = V(a) V(b) together with the vanishing of all lower "
                "coefficients for every choice of 2 or 3 distinct residues mod 7; constructs "
                "signals with prescribed supports in both domains; performs exact sparse recovery "
                "from an arbitrary set of 2k frequencies and exhibits the failure at 2k-1; and "
                "tabulates the subgroup-indicator counterexamples for every composite modulus up "
                "to 16."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Census of Achievable Support Pairs and Constructive Realisation of the Boundary",
            "description": (
                "Two experiments on Z/11Z. First, an empirical census: thousands of random "
                "signals of every support size are transformed and the observed pairs "
                "(|supp f|, |supp f-hat|) are printed as an ASCII scatter table against the "
                "forbidden region alpha + beta < p + 1, which is never entered. Second, a "
                "constructive proof of the exact converse: for every split alpha + beta = p + 1 "
                "and randomly chosen sets A, B of those sizes, a signal with supp f = A and "
                "supp f-hat = B is built from the signed maximal minors of the (alpha-1) x alpha "
                "Fourier block indexed by the frequencies outside B, and both supports are "
                "verified to match exactly."
            ),
            "code": read(ASSETS / "demo_census.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Support-Constrained Fourier Interpolation on a Prime Cyclic Group",
            "description": (
                "Given a prime p, a spatial set A, a frequency set B with |A| = |B| = m, and "
                "arbitrary prescribed spectral data on B, this algorithm returns the unique "
                "signal vanishing off A whose transform matches the data on B. Mathematically it "
                "solves the square system M c = g where M is the |B| x |A| block of the Fourier "
                "matrix; Chebotarev's total nonsingularity theorem guarantees that M is "
                "invertible for EVERY pair (A, B), so the algorithm never fails and needs no "
                "genericity or randomness assumption on the sampling pattern. Complexity: O(m^2) "
                "to build the block and O(m^3) for Gauss-Jordan elimination with partial "
                "pivoting; numerically the conditioning of M is the only practical limitation, "
                "since invertibility is guaranteed but no uniform lower bound on the smallest "
                "singular value is available."
            ),
            "pseudocode": (
                "INPUT : prime p; sets A, B subset of Z/pZ with |A| = |B| = m; data g : B -> C\n"
                "OUTPUT: the unique f with supp f subset of A and f_hat(k) = g(k) for k in B\n"
                "\n"
                "1. zeta <- exp(-2*pi*i/p)\n"
                "2. for each k in B, for each x in A:\n"
                "3.     M[k][x] <- zeta^((k*x) mod p)\n"
                "4. c <- SOLVE(M, (g(k))_{k in B})            # Gauss-Jordan, partial pivoting\n"
                "5.     (the system is nonsingular by total nonsingularity of the prime\n"
                "6.      Fourier matrix, for every choice of A and B)\n"
                "7. f <- zero vector of length p\n"
                "8. for each x in A: f[x] <- c[x]\n"
                "9. return f"
            ),
            "code": read(ASSETS / "algo1_interpolation.py"),
        },
        {
            "name": "Explicit Construction of Extremal Signals with Two Prescribed Supports",
            "description": (
                "Realises the exact converse of the additive uncertainty principle: for a prime p "
                "and any sets A, B with |A| + |B| = p + 1, it returns a signal whose support is "
                "exactly A and whose transform's support is exactly B. Let R be the complement of "
                "B, of size |A| - 1. The (|A|-1) x |A| Fourier block with rows R and columns A has "
                "a one-dimensional kernel, and a kernel vector is given by the signed maximal "
                "minors c_x = (-1)^{pos(x)} det(block with column x deleted). Total nonsingularity "
                "makes every one of these minors nonzero, hence supp f = A; and since f-hat "
                "vanishes on R, the additive bound itself forces supp f-hat = B, for otherwise the "
                "total would be at most p. Complexity: |A| determinants of size |A| - 1, i.e. "
                "O(|A|^4) naively and O(|A|^3) with a single LU factorisation of the transposed "
                "block."
            ),
            "pseudocode": (
                "INPUT : prime p; sets A, B subset of Z/pZ with |A| + |B| = p + 1\n"
                "OUTPUT: f with supp f = A exactly and supp f_hat = B exactly\n"
                "\n"
                "1. R <- Z/pZ \\ B                              # |R| = |A| - 1\n"
                "2. build the (|A|-1) x |A| matrix M[k][x] = zeta^((k*x) mod p), k in R, x in A\n"
                "3. for j = 0 .. |A| - 1:\n"
                "4.     M_j <- M with column j deleted          # square of size |A| - 1\n"
                "5.     c[j] <- (-1)^j * det(M_j)               # every det is nonzero\n"
                "6. normalise c by its largest modulus\n"
                "7. f <- zero vector of length p\n"
                "8. for j, x in enumerate(A): f[x] <- c[j]\n"
                "9. return f                                    # M c = 0, so f_hat vanishes on R"
            ),
            "code": read(ASSETS / "algo2_extremal.py"),
        },
        {
            "name": "Deterministic k-Sparse Recovery from an Arbitrary Set of 2k Frequencies",
            "description": (
                "Recovers an unknown k-sparse signal on Z/pZ from its spectrum on an arbitrary "
                "set S of 2k frequencies. Uniqueness is a direct consequence of the additive "
                "uncertainty principle: two k-sparse signals agreeing on S have a difference h "
                "with |supp h| <= 2k and |supp h-hat| <= p - 2k, a total of at most p, which is "
                "impossible unless h = 0. Two routines are supplied. The combinatorial routine "
                "implements the guarantee literally, testing every candidate support of size k; "
                "because every |S| x |A| block has full column rank, each candidate yields at most "
                "one coefficient vector and exactly one candidate is consistent, at cost "
                "O(C(p,k) k^2 |S|). When S is a block of 2k consecutive frequencies, Prony's "
                "method is used instead: the k x k Hankel system produces the annihilating filter, "
                "its roots among the p-th roots of unity reveal the support, and a k x k "
                "Vandermonde solve returns the amplitudes, all in O(k^3 + p k). Closing the gap "
                "between guaranteed uniqueness for arbitrary S and efficiency for structured S is "
                "an open problem."
            ),
            "pseudocode": (
                "INPUT : prime p; sparsity k; frequency set S with |S| >= 2k; data y = f_hat|_S\n"
                "OUTPUT: the unique k-sparse f with f_hat|_S = y\n"
                "\n"
                "GENERAL S (uniqueness guaranteed for every pattern):\n"
                "1. for each A subset of Z/pZ with |A| = k:\n"
                "2.     solve the k x k system (zeta^{s x})_{s in first k of S, x in A} c = y|_first k\n"
                "3.     f_A <- signal supported on A with coefficients c\n"
                "4.     if f_A_hat agrees with y on ALL of S: return f_A\n"
                "5. (exactly one A passes, by the additive uncertainty principle)\n"
                "\n"
                "CONSECUTIVE S = {t, t+1, ..., t+2k-1} (efficient):\n"
                "6. H <- Hankel matrix H[i][j] = y[i+j], 0 <= i, j < k\n"
                "7. solve H * filt = -(y[k], ..., y[2k-1])      # annihilating filter\n"
                "8. P(z) <- filt[0] + filt[1] z + ... + z^k\n"
                "9. support <- { x in Z/pZ : P(zeta^x) = 0 }    # exactly k roots\n"
                "10. solve the k x k Vandermonde system for the amplitudes\n"
                "11. return the recovered signal"
            ),
            "code": read(ASSETS / "algo3_recovery.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Achievable Support Region: Hyperbola versus Half-Plane",
            "description": (
                "Plots the plane of support pairs (|supp f|, |supp f-hat|) for p = 23, showing the "
                "hyperbola alpha*beta = p (boundary of the classical multiplicative bound), the "
                "line alpha + beta = p + 1 (boundary of the additive bound), the 179 lattice "
                "points that lie between them - permitted by the product bound and impossible in "
                "reality - and the boundary points of the additive bound, every one of which is "
                "attained by an explicit signal with arbitrarily prescribed supports."
            ),
            "code": read(ASSETS / "viz_region.py"),
        },
        {
            "name": "Total Nonsingularity in Picture Form: Minor Determinants for Prime and Composite Moduli",
            "description": (
                "Computes the modulus of the determinant of every 2 x 2 submatrix of the Fourier "
                "matrix for a prime modulus and for a composite modulus of comparable size, and "
                "renders the results as two heatmaps indexed by the row pair and the column pair. "
                "For the prime modulus no cell is black: every minor is nonsingular. For the "
                "composite modulus the black cells mark the vanishing minors, which occur exactly "
                "at the row/column pairs coming from a subgroup and its annihilator - the same "
                "structure that breaks the additive uncertainty bound."
            ),
            "code": read(ASSETS / "viz_minors.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Uncertainty Sandbox: Try to Beat the Bound",
            "description": (
                "An interactive clock of the residues modulo n on which time samples can be "
                "switched on and off by clicking, with the spectrum recomputed live and displayed "
                "as a bar chart. The panel reports |supp f|, |supp f-hat|, their sum and their "
                "product against the additive threshold n + 1 and the multiplicative threshold n. "
                "Presets provide the single spike, the constant signal, random sparse signals with "
                "real or complex amplitudes, and - for composite moduli - the subgroup indicator "
                "that breaks the additive bound by exactly (d-1)(e-1). Sliding the modulus between "
                "prime and composite values makes the role of primality immediately visible: on a "
                "prime modulus no configuration whatsoever brings the total below n + 1, while on "
                "a composite modulus a single click on the subgroup preset does it."
            ),
            "html": read(ASSETS / "widget1_sandbox.html"),
        },
        {
            "title": "The Chebotarev Minor Explorer: Hunting for a Singular Block",
            "description": (
                "Displays the Fourier matrix modulo n as a table of exponents k*x mod n and lets "
                "the reader select any set of rows and any set of columns by clicking; the "
                "determinant of the selected square block is computed live in exact complex "
                "arithmetic and reported as nonsingular or singular. A scan button sweeps every "
                "square block up to size four and reports how many are singular along with the "
                "smallest nonzero determinant modulus encountered - a first glimpse of the "
                "conditioning question that governs noise-robust recovery. A hunt button searches "
                "for a singular block and, for composite moduli, always finds one built from a "
                "subgroup and its annihilator; for prime moduli it reports that none exists, which "
                "is Chebotarev's theorem experienced rather than merely stated."
            ),
            "html": read(ASSETS / "widget2_minors.html"),
        },
    ],
    "interactive_layout": read(ASSETS / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_census": read(ASSETS / "demo_census.py"),
        "interpolation": read(ASSETS / "algo1_interpolation.py"),
        "extremal_signals": read(ASSETS / "algo2_extremal.py"),
        "sparse_recovery": read(ASSETS / "algo3_recovery.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("wrote", out, f"({out.stat().st_size} bytes)")


"""Census of achievable support pairs on Z/pZ, and the exact converse.

Two experiments on a small prime modulus.

(1) EMPIRICAL CENSUS.  Many random signals are drawn (with supports of every
    possible size) and the pair (|supp f|, |supp f_hat|) is recorded.  The
    observed pairs are printed as a table: every observed point satisfies
    alpha + beta >= p + 1, and no point below the line is ever seen.

(2) CONSTRUCTIVE CONVERSE.  For every split alpha + beta = p + 1 and randomly
    chosen sets A, B of those sizes, an explicit signal with supp f = A and
    supp f_hat = B is built from the signed maximal minors of the (alpha-1) x
    alpha Fourier block with rows outside B.  Every boundary point is therefore
    attained, with the two supports in arbitrary prescribed positions.
"""

from __future__ import annotations

import cmath
import random
from typing import List, Sequence, Tuple

Complex = complex


def zeta(n: int, e: int = 1) -> Complex:
    """Power zeta_n^e of exp(-2*pi*i/n)."""
    return cmath.exp(-2j * cmath.pi * (e % n) / n)


def dft(f: Sequence[Complex], n: int) -> List[Complex]:
    """Discrete Fourier transform on Z/nZ."""
    return [sum(zeta(n, k * x) * f[x] for x in range(n)) for k in range(n)]


def support(f: Sequence[Complex], tol: float = 1e-9) -> List[int]:
    """Indices of the numerically nonzero entries."""
    return [i for i, v in enumerate(f) if abs(v) > tol]


def determinant(mat: List[List[Complex]]) -> Complex:
    """Determinant by Gaussian elimination with partial pivoting."""
    a = [row[:] for row in mat]
    m = len(a)
    det: Complex = 1.0 + 0j
    for col in range(m):
        piv = max(range(col, m), key=lambda r: abs(a[r][col]))
        if abs(a[piv][col]) < 1e-14:
            return 0j
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            det = -det
        det *= a[col][col]
        inv = 1.0 / a[col][col]
        for r in range(col + 1, m):
            fac = a[r][col] * inv
            for c in range(col, m):
                a[r][c] -= fac * a[col][c]
    return det


def extremal_signal(p: int, A: Sequence[int], B: Sequence[int]) -> List[Complex]:
    """Signal with supp f = A and supp f_hat = B, for |A| + |B| = p + 1."""
    R = [k for k in range(p) if k not in set(B)]
    block = [[zeta(p, k * x) for x in A] for k in R]
    coeffs = []
    for j in range(len(A)):
        minor = [[row[c] for c in range(len(A)) if c != j] for row in block]
        coeffs.append(((-1) ** j) * determinant(minor))
    scale = max(abs(c) for c in coeffs)
    f: List[Complex] = [0j] * p
    for x, c in zip(A, coeffs):
        f[x] = c / scale
    return f


def census(p: int, per_size: int = 60, seed: int = 3) -> List[Tuple[int, int]]:
    """Record (|supp f|, |supp f_hat|) for many random signals."""
    rng = random.Random(seed)
    seen = set()
    for k in range(1, p + 1):
        for _ in range(per_size):
            f: List[Complex] = [0j] * p
            for x in rng.sample(range(p), k):
                f[x] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
            seen.add((len(support(f)), len(support(dft(f, p)))))
    return sorted(seen)


def main(p: int = 11) -> None:
    print(f"=== Census of support pairs on Z/{p}Z ===")
    pairs = census(p)
    assert all(a + b >= p + 1 for a, b in pairs)
    print(f"  distinct observed pairs: {len(pairs)}")
    print(f"  minimum observed sum   : {min(a + b for a, b in pairs)} (bound is {p + 1})")
    grid = {(a, b) for a, b in pairs}
    print("      beta ->")
    for a in range(1, p + 1):
        row = "".join("#" if (a, b) in grid else ("." if a + b >= p + 1 else " ")
                      for b in range(1, p + 1))
        print(f"   a={a:2d} |{row}|")
    print("   ('#' observed, '.' allowed but not sampled, ' ' forbidden by the bound)")

    print(f"\n=== Constructive converse: every split of {p + 1} is attained ===")
    rng = random.Random(17)
    for alpha in range(1, p + 1):
        beta = p + 1 - alpha
        A = sorted(rng.sample(range(p), alpha))
        B = sorted(rng.sample(range(p), beta))
        f = extremal_signal(p, A, B)
        ok = support(f) == A and support(dft(f, p)) == B
        print(f"  |A| = {alpha:2d}, |B| = {beta:2d}: supports realised exactly -> {ok}")
        assert ok


if __name__ == "__main__":
    main()


"""Visualisation: total nonsingularity of the prime Fourier matrix.

For a prime modulus and a composite modulus of comparable size, every 2 x 2
submatrix of the Fourier matrix (zeta_n^{kx}) is formed and its |determinant|
recorded.  The two heatmaps show |det| indexed by the row pair and the column
pair.  For the prime modulus no entry is zero -- Chebotarev's theorem in
picture form.  For the composite modulus the black cells are the vanishing
minors, and they occur exactly at the row/column pairs that are cosets of a
subgroup and its annihilator.
"""

from __future__ import annotations

import itertools
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def minor_grid(n: int, size: int = 2) -> Tuple[np.ndarray, List[Tuple[int, ...]]]:
    """|det| of every `size` x `size` minor of the n x n Fourier matrix."""
    idx = list(itertools.combinations(range(n), size))
    grid = np.zeros((len(idx), len(idx)))
    w = np.exp(-2j * np.pi / n)
    for i, rows in enumerate(idx):
        for j, cols in enumerate(idx):
            block = np.array([[w ** ((r * c) % n) for c in cols] for r in rows])
            grid[i, j] = abs(np.linalg.det(block))
    return grid, idx


def main(prime: int = 7, composite: int = 8) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 6))
    for ax, n, tag in ((axes[0], prime, "prime"), (axes[1], composite, "composite")):
        grid, idx = minor_grid(n, 2)
        im = ax.imshow(grid, cmap="viridis", vmin=0, vmax=grid.max())
        zeros = int((grid < 1e-9).sum())
        ax.set_title(f"$n = {n}$ ({tag}): {zeros} singular $2\\times2$ minors", fontsize=12)
        labels = ["".join(str(t) for t in t_) for t_ in idx]
        step = max(1, len(labels) // 14)
        ax.set_xticks(range(0, len(labels), step))
        ax.set_xticklabels(labels[::step], rotation=90, fontsize=7)
        ax.set_yticks(range(0, len(labels), step))
        ax.set_yticklabels(labels[::step], fontsize=7)
        ax.set_xlabel("column pair (positions)")
        ax.set_ylabel("row pair (frequencies)")
        fig.colorbar(im, ax=ax, fraction=0.046, label="|det|")
    fig.suptitle("Every square minor of a prime Fourier matrix is nonsingular", fontsize=14)
    fig.tight_layout()
    fig.savefig("chebotarev_minors.png", dpi=160)
    print("wrote chebotarev_minors.png")


if __name__ == "__main__":
    main()


"""Visualisation: the achievable support region for p = 23.

Plots, in the (|supp f|, |supp f_hat|)-plane:
  * the hyperbola alpha * beta = p, boundary of the classical multiplicative
    uncertainty bound;
  * the line alpha + beta = p + 1, boundary of the additive bound;
  * the lattice points allowed by the product bound but forbidden by the sum
    bound (the genuine gain of the additive principle);
  * the boundary points, every one of which is realised by an explicit signal
    whose two supports can be prescribed arbitrarily.
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def forbidden_pairs(p: int) -> List[Tuple[int, int]]:
    """Pairs permitted by alpha*beta >= p but excluded by alpha+beta >= p+1."""
    return [(a, b) for a in range(1, p + 1) for b in range(1, p + 1)
            if a * b >= p and a + b < p + 1]


def main(p: int = 23) -> None:
    fig, ax = plt.subplots(figsize=(7.2, 6.6))

    alphas = np.linspace(0.6, p + 0.4, 600)
    ax.plot(alphas, p / alphas, lw=2.2, color="#c94f4f",
            label=r"multiplicative bound  $\alpha\beta = p$")
    ax.plot(alphas, (p + 1) - alphas, lw=2.2, color="#2f6fb5",
            label=r"additive bound  $\alpha+\beta = p+1$")

    bad = forbidden_pairs(p)
    ax.scatter([a for a, _ in bad], [b for _, b in bad], s=26, color="#e8a33d",
               edgecolor="#7a5313", zorder=3,
               label="permitted by product bound, impossible")

    boundary = [(a, p + 1 - a) for a in range(1, p + 1)]
    ax.scatter([a for a, _ in boundary], [b for _, b in boundary], s=34,
               color="#2f6fb5", zorder=4, label="attained (every position of supports)")

    ax.fill_between(alphas, (p + 1) - alphas, p + 1, color="#2f6fb5", alpha=0.07)

    ax.set_xlim(0, p + 1)
    ax.set_ylim(0, p + 1)
    ax.set_xlabel(r"$|\mathrm{supp}\, f|$", fontsize=12)
    ax.set_ylabel(r"$|\mathrm{supp}\, \hat f|$", fontsize=12)
    ax.set_title(f"Achievable support pairs on $\\mathbb{{Z}}/{p}\\mathbb{{Z}}$", fontsize=13)
    ax.grid(alpha=0.25, linestyle=":")
    ax.legend(loc="upper right", fontsize=9, framealpha=0.95)
    fig.tight_layout()
    fig.savefig("uncertainty_region.png", dpi=170)
    print("wrote uncertainty_region.png;",
          len(bad), "lattice points lie in the gap between the two bounds")


if __name__ == "__main__":
    main()
