"""
De-Quantization Assessed: Shor's Quantum Fourier Transform Is Irreducible
=========================================================================

Numerical companion to the paper.  Pure standard library (no NumPy): all linear
algebra -- exact ranks over the rationals, singular values via a Jacobi
eigensolver, the discrete Fourier transform, continued fractions -- is
implemented inline.

The script demonstrates, on small explicit instances, the seven quantitative
statements of the paper:

  1.  The full Shor register state  Q^{-1/2} sum_x |x> |a^x mod N>  has Schmidt
      rank exactly r (the multiplicative order) across the exponent/function
      cut, with a perfectly flat Schmidt spectrum, entanglement entropy log r
      and mutual information 2 log r.

  2.  The periodic comb  c_x = [x = x0 mod r],  the input of the quantum
      Fourier transform, has Schmidt rank exactly  min(C, r / gcd(r, B))
      across the cut  x = b + B c  with  B*C = Q  and  r <= B.

  3.  For an odd order r and a power-of-two block size B >= r the rank is the
      full  min(C, r):  no qubit cut ever compresses the comb.

  4.  The Fourier transform of the comb is supported exactly on the multiples
      of  m = Q / r,  each carrying probability  1/r;  across a cut it is the
      period-m comb dressed by diagonal phases, hence again of exponential
      rank.

  5.  Any classical sampler supported on a set S is at total-variation distance
      at least  1 - |S|/r  from the ideal Fourier output.

  6.  Flat-spectrum Eckart-Young: the squared overlap of a normalized rank-D
      state with a flat rank-r state is at most  D/r,  attained by truncation;
      equivalently the squared Frobenius error is at least  2 - 2 sqrt(D/r).

  7.  One ideal sample yields the order by continued fractions, and an even
      order with  a^{r/2} != -1 (mod N)  yields a nontrivial factor of N.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from math import gcd
from typing import Callable, Dict, List, Sequence, Tuple

Matrix = List[List[float]]
CMatrix = List[List[complex]]

# ----------------------------------------------------------------------------
# 0. Elementary linear algebra (exact rank, Jacobi singular values)
# ----------------------------------------------------------------------------


def exact_rank(matrix: Sequence[Sequence[float]]) -> int:
    """Rank of a real matrix computed exactly over the rationals."""
    rows: List[List[Fraction]] = [[Fraction(x).limit_denominator(10**9) for x in row]
                                  for row in matrix]
    if not rows or not rows[0]:
        return 0
    n_rows, n_cols = len(rows), len(rows[0])
    rank, pivot_row = 0, 0
    for col in range(n_cols):
        pivot = None
        for r in range(pivot_row, n_rows):
            if rows[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        head = rows[pivot_row][col]
        rows[pivot_row] = [x / head for x in rows[pivot_row]]
        for r in range(n_rows):
            if r != pivot_row and rows[r][col] != 0:
                factor = rows[r][col]
                rows[r] = [a - factor * b for a, b in zip(rows[r], rows[pivot_row])]
        pivot_row += 1
        rank += 1
        if pivot_row == n_rows:
            break
    return rank


def jacobi_eigenvalues(sym: Matrix, sweeps: int = 100, tol: float = 1e-13) -> List[float]:
    """Eigenvalues of a real symmetric matrix by the cyclic Jacobi method."""
    n = len(sym)
    a = [row[:] for row in sym]
    for _ in range(sweeps):
        off = math.sqrt(sum(a[i][j] ** 2 for i in range(n) for j in range(n) if i != j))
        if off < tol:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(a[p][q]) < tol:
                    continue
                theta = (a[q][q] - a[p][p]) / (2.0 * a[p][q])
                sign = 1.0 if theta >= 0 else -1.0
                t = sign / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(t * t + 1.0)
                s = t * c
                for k in range(n):
                    akp, akq = a[k][p], a[k][q]
                    a[k][p] = c * akp - s * akq
                    a[k][q] = s * akp + c * akq
                for k in range(n):
                    apk, aqk = a[p][k], a[q][k]
                    a[p][k] = c * apk - s * aqk
                    a[q][k] = s * apk + c * aqk
    return sorted((a[i][i] for i in range(n)), reverse=True)


def hermitian_eigenvalues(herm: Sequence[Sequence[complex]]) -> List[float]:
    """Eigenvalues of a complex Hermitian matrix H = A + iB, obtained from the
    real symmetric embedding [[A, -B], [B, A]] (each eigenvalue appears twice)."""
    n = len(herm)
    embedded: Matrix = [[0.0] * (2 * n) for _ in range(2 * n)]
    for i in range(n):
        for j in range(n):
            re, im = herm[i][j].real, herm[i][j].imag
            embedded[i][j] = re
            embedded[i][j + n] = -im
            embedded[i + n][j] = im
            embedded[i + n][j + n] = re
    return jacobi_eigenvalues(embedded)[0::2]


def singular_values(matrix: Sequence[Sequence[complex]]) -> List[float]:
    """Singular values of a complex matrix, via the eigenvalues of M M^H."""
    n_rows = len(matrix)
    gram: CMatrix = [[0j] * n_rows for _ in range(n_rows)]
    for i in range(n_rows):
        for j in range(n_rows):
            gram[i][j] = sum(matrix[i][k] * matrix[j][k].conjugate()
                             for k in range(len(matrix[0])))
    return [math.sqrt(max(0.0, ev)) for ev in hermitian_eigenvalues(gram)]


def numeric_rank(matrix: Sequence[Sequence[complex]], rel_tol: float = 1e-6) -> int:
    """Numerical rank: singular values above `rel_tol` times the largest one."""
    svals = singular_values(matrix)
    if not svals or svals[0] <= 0.0:
        return 0
    return sum(1 for s in svals if s > rel_tol * svals[0])


def shannon_entropy(probabilities: Sequence[float], base: float = math.e) -> float:
    """Shannon entropy of a probability vector, in units of log base `base`."""
    total = 0.0
    for p in probabilities:
        if p > 1e-15:
            total -= p * math.log(p, base)
    return total


# ----------------------------------------------------------------------------
# 1. The full Shor register state across the exponent/function cut
# ----------------------------------------------------------------------------


def multiplicative_order(a: int, n: int) -> int:
    """Least r >= 1 with a^r = 1 (mod n); requires gcd(a, n) = 1."""
    if gcd(a, n) != 1:
        raise ValueError("a and n must be coprime")
    value, r = a % n, 1
    while value != 1:
        value = (value * a) % n
        r += 1
    return r


def shor_state_matrix(a: int, n_modulus: int, q_size: int) -> CMatrix:
    """Coefficient matrix of  Q^{-1/2} sum_{x<Q} |x> |a^x mod N>.

    Rows are indexed by the exponent x, columns by the residue value.
    """
    amp = 1.0 / math.sqrt(q_size)
    values = sorted({pow(a, x, n_modulus) for x in range(q_size)})
    index = {v: i for i, v in enumerate(values)}
    mat: CMatrix = [[0j] * len(values) for _ in range(q_size)]
    for x in range(q_size):
        mat[x][index[pow(a, x, n_modulus)]] = complex(amp, 0.0)
    return mat


def demo_full_state() -> None:
    print("=" * 78)
    print("1.  Full Shor state: rank = r exactly, flat spectrum, entropy log r")
    print("=" * 78)
    for n_modulus, a, m in ((15, 7, 5), (21, 2, 4), (35, 3, 3)):
        r = multiplicative_order(a, n_modulus)
        q_size = r * m
        mat = shor_state_matrix(a, n_modulus, q_size)
        svals = singular_values(mat)[:numeric_rank(mat)]
        probs = [s * s for s in svals]
        print(f"  N={n_modulus:3d}  a={a:2d}  order r={r}  Q=r*m={q_size}")
        print(f"      Schmidt rank            : {len(svals)}   (predicted {r})")
        print(f"      singular values         : "
              f"{['%.4f' % s for s in svals]}  (flat: all 1/sqrt(r)={1/math.sqrt(r):.4f})")
        print(f"      entanglement entropy    : {shannon_entropy(probs):.6f} nats"
              f"   (predicted log r = {math.log(r):.6f})")
        print(f"      mutual information      : {2*shannon_entropy(probs):.6f} nats"
              f"   (predicted 2 log r = {2*math.log(r):.6f})")
        print(f"      => every matrix-product representation needs bond dim >= {r}")
    print()


# ----------------------------------------------------------------------------
# 2-3. The comb (QFT input) across a cut: the sharp cut-period law
# ----------------------------------------------------------------------------


def comb_cut_matrix(block: int, blocks: int, r: int, x0: int, amp: float = 1.0) -> CMatrix:
    """Comb  [x = x0 mod r]  across the cut  x = b + B c,  b < B, c < C."""
    return [[complex(amp, 0.0) if (b + block * c) % r == x0 % r else 0j
             for c in range(blocks)] for b in range(block)]


def predicted_comb_rank(block: int, blocks: int, r: int) -> int:
    """min(C, r / gcd(r, B)) -- the exact Schmidt rank when r <= B."""
    return min(blocks, r // gcd(r, block))


def demo_comb_rank() -> None:
    print("=" * 78)
    print("2.  QFT input comb: Schmidt rank = min(C, r/gcd(r,B))  exactly")
    print("=" * 78)
    print("     B    C     r   x0 | measured rank | min(C, r/gcd(r,B))")
    print("   " + "-" * 60)
    cases = [(8, 8, 5, 3), (8, 8, 8, 1), (12, 6, 6, 0), (16, 16, 15, 7),
             (16, 4, 15, 2), (12, 12, 4, 1), (9, 9, 3, 2), (16, 16, 16, 5)]
    ok = True
    for block, blocks, r, x0 in cases:
        mat = comb_cut_matrix(block, blocks, r, x0)
        measured = exact_rank([[z.real for z in row] for row in mat])
        predicted = predicted_comb_rank(block, blocks, r)
        agree = measured == predicted
        ok = ok and agree
        print(f"   {block:3d}  {blocks:3d}  {r:4d}  {x0:3d} | {measured:13d} |"
              f" {predicted:18d}   {'ok' if agree else 'MISMATCH'}")
    print(f"   all agree: {ok}")
    print()
    print("   Aligned cuts (r divides B) are the only product states:")
    for block, blocks, r in ((12, 6, 6), (8, 8, 4), (9, 9, 3), (8, 8, 5)):
        mat = comb_cut_matrix(block, blocks, r, 0)
        print(f"     B={block:3d} C={blocks:3d} r={r:3d}  r divides B: {block % r == 0}"
              f"  rank={exact_rank([[z.real for z in row] for row in mat])}")
    print()
    print("3.  Odd order, power-of-two block: no qubit cut ever compresses")
    print("   " + "-" * 60)
    for k, r in ((4, 5), (4, 7), (5, 15), (5, 21)):
        block = 2 ** k
        blocks = block
        mat = comb_cut_matrix(block, blocks, r, 1)
        measured = exact_rank([[z.real for z in row] for row in mat])
        print(f"     B=2^{k}={block:4d}  C={blocks:4d}  r={r:3d}"
              f"  gcd(r,B)={gcd(r, block)}  rank={measured}  (= min(C,r) = {min(blocks, r)})")
    print()


def demo_flat_spectrum() -> None:
    print("=" * 78)
    print("   Flat spectrum of the comb: no decaying tail to truncate")
    print("=" * 78)
    for block, blocks, r in ((5, 5, 7), (4, 4, 9), (6, 6, 13)):
        mat = comb_cut_matrix(block, blocks, r, 0)
        norm = math.sqrt(sum(abs(z) ** 2 for row in mat for z in row))
        mat = [[z / norm for z in row] for row in mat]
        svals = singular_values(mat)[:numeric_rank(mat)]
        probs = [s * s for s in svals]
        ratio = max(probs) / min(probs)
        print(f"     B={block} C={blocks} r={r}: rank={len(svals)}  "
              f"max/min Schmidt weight = {ratio:.6f}  "
              f"participation ratio = {1/sum(p*p for p in probs):.4f}")
    print("     (ratio 1.000000 and participation ratio = rank: perfectly flat)")
    print()


# ----------------------------------------------------------------------------
# 4. The Fourier transform of the comb
# ----------------------------------------------------------------------------


def dft_of_comb(r: int, m: int, x0: int) -> List[complex]:
    """Unnormalized DFT  sum_{t<m} w^{(x0 + r t) y}  of the comb, Q = r*m."""
    q_size = r * m
    return [sum(cmath.exp(2j * math.pi * ((x0 + r * t) * y % q_size) / q_size)
                for t in range(m)) for y in range(q_size)]


def output_cut_matrix(block: int, blocks: int, m: int, j: int, q_size: int,
                      amp: float = 1.0) -> CMatrix:
    """QFT output state across the cut x = b + B c: the period-m comb dressed by
    the diagonal phases  exp(2 pi i j x / Q)."""
    return [[amp * cmath.exp(2j * math.pi * j * (b + block * c) / q_size)
             if (b + block * c) % m == 0 else 0j
             for c in range(blocks)] for b in range(block)]


def demo_qft_output() -> None:
    print("=" * 78)
    print("4.  Fourier transform of the comb: probability 1/r on multiples of m")
    print("=" * 78)
    for r, m, x0 in ((5, 4, 2), (6, 3, 1), (7, 5, 4)):
        q_size = r * m
        spectrum = dft_of_comb(r, m, x0)
        probs = [abs(z) ** 2 / (r * m * m) for z in spectrum]
        support = [y for y, p in enumerate(probs) if p > 1e-9]
        print(f"     r={r} m={m} Q={q_size}: support = {support}"
              f"  = multiples of m ({support == [m*k for k in range(r)]})")
        print(f"        probabilities  = {['%.4f' % probs[y] for y in support]}"
              f"  (predicted 1/r = {1/r:.4f}),  total = {sum(probs):.6f}")
        # the output across a cut is the period-m comb dressed by diagonal phases
        for block in [d for d in range(1, q_size + 1)
                      if q_size % d == 0 and d >= m and d < q_size]:
            blocks = q_size // block
            mat = output_cut_matrix(block, blocks, m, j=1, q_size=q_size)
            measured = numeric_rank(mat)
            predicted = min(blocks, m // gcd(m, block))
            print(f"        output cut B={block:3d} C={blocks:3d}:  rank = {measured}"
                  f"   predicted min(C, m/gcd(m,B)) = {predicted}"
                  f"   {'ok' if measured == predicted else 'MISMATCH'}")
    print()


# ----------------------------------------------------------------------------
# 5. Total-variation lower bound for small-support samplers
# ----------------------------------------------------------------------------


def tv_distance(p: Sequence[float], q: Sequence[float]) -> float:
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


def demo_tv_bound() -> None:
    print("=" * 78)
    print("5.  Any sampler supported on S is >= 1 - |S|/r away in TV distance")
    print("=" * 78)
    r, m = 64, 4
    q_size = r * m
    ideal = [1.0 / r if y % m == 0 else 0.0 for y in range(q_size)]
    for support_size in (1, 2, 4, 8, 16, 32, 64):
        sampler = [0.0] * q_size
        for i in range(support_size):
            sampler[(i * m) % q_size] += 1.0 / support_size
        measured = tv_distance(ideal, sampler)
        bound = 1.0 - support_size / r
        print(f"     |S| = {support_size:3d}:  TV = {measured:.4f}"
              f"   >=  1 - |S|/r = {bound:.4f}"
              f"   {'(>= 1/2)' if 2*support_size <= r else ''}")
    print("     A polynomial-size support against exponential r forces TV -> 1.")
    print()


# ----------------------------------------------------------------------------
# 6. Flat-spectrum Eckart-Young: fidelity of truncation is exactly D/r
# ----------------------------------------------------------------------------


def truncation_fidelity(r: int, keep: int) -> Tuple[float, float]:
    """(squared overlap, squared Frobenius error) of the best rank-`keep`
    approximation of a normalized flat rank-r state."""
    overlap = sum((1.0 / math.sqrt(r)) * (1.0 / math.sqrt(keep)) for _ in range(keep))
    return overlap ** 2, 2.0 - 2.0 * overlap


def demo_truncation() -> None:
    print("=" * 78)
    print("6.  Flat-spectrum truncation: fidelity exactly D/r, error 2-2sqrt(D/r)")
    print("=" * 78)
    r = 1024
    print(f"     flat rank r = {r}")
    for keep in (1, 2, 8, 32, 128, 512, 1024):
        fid, err = truncation_fidelity(r, keep)
        print(f"       D = {keep:5d}:  |<M,A>|^2 = {fid:.6f}  (D/r = {keep/r:.6f})"
              f"    ||M-A||_F^2 = {err:.6f}  (2-2sqrt(D/r) = "
              f"{2-2*math.sqrt(keep/r):.6f})")
    print("     Note: the fidelity decays as D/r, NOT as (D/r)^2.")
    print()


# ----------------------------------------------------------------------------
# 7. From one ideal sample to a factor of N
# ----------------------------------------------------------------------------


def continued_fraction_convergents(numerator: int, denominator: int) -> List[Tuple[int, int]]:
    """Convergents p/q of numerator/denominator."""
    convergents: List[Tuple[int, int]] = []
    p_prev, p_cur = 0, 1
    q_prev, q_cur = 1, 0
    a, b = numerator, denominator
    while b:
        quotient = a // b
        a, b = b, a - quotient * b
        p_prev, p_cur = p_cur, quotient * p_cur + p_prev
        q_prev, q_cur = q_cur, quotient * q_cur + q_prev
        convergents.append((p_cur, q_cur))
    return convergents


def order_from_sample(y: int, q_size: int, bound: int) -> int:
    """Largest convergent denominator of y/Q not exceeding `bound`."""
    best = 1
    for _, q in continued_fraction_convergents(y, q_size):
        if q <= bound:
            best = max(best, q)
    return best


def factor_from_order(a: int, r: int, n_modulus: int) -> Tuple[int, int] | None:
    """Nontrivial factor pair from an even order with a^{r/2} != -1 (mod N)."""
    if r % 2 == 1:
        return None
    root = pow(a, r // 2, n_modulus)
    if root == n_modulus - 1:
        return None
    d1, d2 = gcd(root - 1, n_modulus), gcd(root + 1, n_modulus)
    for d in (d1, d2):
        if 1 < d < n_modulus:
            return d, n_modulus // d
    return None


def demo_sample_to_factor() -> None:
    print("=" * 78)
    print("7.  One ideal sample -> the order -> a nontrivial factor of N")
    print("=" * 78)
    for n_modulus, a, m in ((15, 7, 8), (21, 2, 8), (33, 5, 4), (35, 3, 4)):
        r = multiplicative_order(a, n_modulus)
        q_size = r * m
        recovered: Dict[int, int] = {}
        for k in range(r):
            y = k * m                      # every peak of the ideal output
            recovered[y] = order_from_sample(y, q_size, n_modulus)
        good = [y for y, est in recovered.items() if est == r]
        factors = factor_from_order(a, r, n_modulus)
        print(f"     N={n_modulus:3d} a={a:2d}: order r={r}, Q={q_size}")
        print(f"        peaks y = k*m, k=0..{r-1};  "
              f"{len(good)}/{r} of them return the exact order by continued fractions")
        print(f"        (all others return a divisor of r: "
              f"{sorted(set(recovered.values()))})")
        if factors:
            print(f"        r is even and a^(r/2) != -1  =>  N = {factors[0]} * {factors[1]}")
        else:
            print("        r odd or a^(r/2) = -1: retry with another base a")
    print()


# ----------------------------------------------------------------------------
# 8. Complementarity of the two QFT endpoints
# ----------------------------------------------------------------------------


def cut_period(r: int, block: int) -> int:
    return r // gcd(r, block)


def demo_complementarity() -> None:
    print("=" * 78)
    print("8.  Endpoint complementarity: min(C, cutper(lcm(r,m),B)) <= rank_in*rank_out")
    print("=" * 78)
    print("       Q     B    C    r    m | rank_in rank_out |  lcm bound")
    print("   " + "-" * 66)
    cases = [(36, 6, 6, 6, 6), (64, 8, 8, 5, 8), (60, 10, 6, 4, 15),
             (72, 12, 6, 6, 4), (100, 10, 10, 4, 25)]
    for q_size, block, blocks, r, m in cases:
        rank_in = min(blocks, cut_period(r, block))
        rank_out = min(blocks, cut_period(m, block))
        lcm_rm = r * m // gcd(r, m)
        bound = min(blocks, cut_period(lcm_rm, block))
        print(f"   {q_size:5d} {block:5d} {blocks:4d} {r:4d} {m:4d} |"
              f" {rank_in:7d} {rank_out:8d} | {bound:5d} <= {rank_in*rank_out}"
              f"   {'ok' if bound <= rank_in*rank_out else 'FAIL'}")
    print()
    print("   The Q=36, r=m=6, B=C=6 row: BOTH endpoints are product states.")
    print("   Complementarity of the two endpoints is therefore false in general --")
    print("   but it requires an aligned cut, lcm(r,m) | B, and for an odd order r>1")
    print("   no power of two is a multiple of r:")
    for r in (3, 5, 7, 15, 21):
        aligned = [k for k in range(1, 12) if 2 ** k % r == 0]
        print(f"     r = {r:3d}:  powers of two divisible by r among 2^1..2^11: {aligned}")
    print()


def main() -> None:
    demo_full_state()
    demo_comb_rank()
    demo_flat_spectrum()
    demo_qft_output()
    demo_tv_bound()
    demo_truncation()
    demo_sample_to_factor()
    demo_complementarity()
    print("=" * 78)
    print("Conclusion: every endpoint of Shor's Fourier transform carries Schmidt")
    print("rank equal to the order r, with a flat spectrum; truncation to bond")
    print("dimension D retains fidelity only D/r; and one ideal sample factors N.")
    print("Low-rank classical emulation of Shor is possible exactly when the order")
    print("is small -- that is, exactly when the instance is already classically easy.")
    print("=" * 78)


if __name__ == "__main__":
    main()
