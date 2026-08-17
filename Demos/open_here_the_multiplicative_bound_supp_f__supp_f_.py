"""
Numerical companion to
"Additive uncertainty on cyclic groups of prime order".

Everything here is self-contained (standard library only) and illustrates,
numerically and exactly, the results of the paper:

  1. The additive bound  |supp f| + |supp f^| >= p + 1  on Z_p, p prime,
     and the strictly weaker Donoho-Stark product bound |supp f|*|supp f^| >= p.
  2. Why the product bound cannot imply the additive one (an arithmetic gap).
  3. Failure of the additive bound on the composite group Z_4 (the indicator
     of the subgroup {0,2}), where the product bound holds with equality.
  4. Sharpness of the additive bound at both ends: Dirac deltas and characters.
  5. The parity-weighted permutation criterion: a minor of the DFT matrix of
     Z_p is nonsingular iff some residue is hit by unequally many even and odd
     permutations through the exponent map  sigma |-> sum_j S(sigma j) T j.
     This is checked with *exact integer arithmetic* (no floating point).
  6. The sparse-recovery corollary: any k-sparse vector on Z_p is uniquely
     determined by any 2k of its Fourier coefficients.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

Complex = complex

# ---------------------------------------------------------------------------
# 1. Discrete Fourier transform on Z_n and supports
# ---------------------------------------------------------------------------

TOL = 1e-9


def dft(f: Sequence[Complex]) -> List[Complex]:
    """Unnormalised DFT on Z_n:  f^(k) = sum_x omega^{-kx} f(x), omega = e^{2 pi i / n}."""
    n = len(f)
    out: List[Complex] = []
    for k in range(n):
        acc = 0j
        for x in range(n):
            acc += cmath.exp(-2j * math.pi * (k * x % n) / n) * f[x]
        out.append(acc)
    return out


def support(f: Sequence[Complex], tol: float = TOL) -> List[int]:
    """Indices where the vector is (numerically) nonzero."""
    return [i for i, v in enumerate(f) if abs(v) > tol]


def uncertainty_pair(f: Sequence[Complex]) -> Tuple[int, int]:
    """Return (|supp f|, |supp f^|)."""
    return len(support(f)), len(support(dft(f)))


# ---------------------------------------------------------------------------
# 2. Random tests of the two uncertainty inequalities
# ---------------------------------------------------------------------------


def random_sparse_vector(n: int, k: int, rng: random.Random) -> List[Complex]:
    """A random vector on Z_n with exactly k nonzero entries."""
    pos = rng.sample(range(n), k)
    f = [0j] * n
    for i in pos:
        f[i] = complex(rng.uniform(-1, 1), rng.uniform(-1, 1))
        while abs(f[i]) < 0.1:
            f[i] = complex(rng.uniform(-1, 1), rng.uniform(-1, 1))
    return f


def test_bounds(p: int, trials: int = 200, seed: int = 1) -> Dict[str, int]:
    """Check the additive and multiplicative bounds on random sparse vectors."""
    rng = random.Random(seed)
    worst_sum = 10 ** 9
    worst_prod = 10 ** 9
    for _ in range(trials):
        k = rng.randint(1, p)
        f = random_sparse_vector(p, k, rng)
        a, b = uncertainty_pair(f)
        worst_sum = min(worst_sum, a + b)
        worst_prod = min(worst_prod, a * b)
        assert a + b >= p + 1, f"additive bound violated at p={p}: {a}+{b}"
        assert a * b >= p, f"product bound violated at p={p}: {a}*{b}"
    return {"p": p, "min_sum": worst_sum, "min_product": worst_prod}


# ---------------------------------------------------------------------------
# 3. The arithmetic gap: product bound does not imply the additive bound
# ---------------------------------------------------------------------------


def product_not_sum_witness(p: int) -> Tuple[int, int]:
    """(a, b) with a*b >= p (product bound satisfied) but a + b < p + 1."""
    a, b = 2, (p + 1) // 2
    assert a * b >= p and a + b < p + 1
    return a, b


def balanced_witness(p: int) -> Tuple[int, int]:
    """The 'sqrt(p) x sqrt(p)' profile: legal for the product bound, illegal additively."""
    a = math.isqrt(p)
    while a * a < p:
        a += 1
    return a, a


# ---------------------------------------------------------------------------
# 4. Primality is essential: the counterexample on Z_4
# ---------------------------------------------------------------------------


def subgroup_indicator_z4() -> List[Complex]:
    """Indicator of the subgroup {0, 2} of Z_4."""
    return [1 + 0j, 0j, 1 + 0j, 0j]


# ---------------------------------------------------------------------------
# 5. Sharpness: deltas and characters
# ---------------------------------------------------------------------------


def delta(n: int, a: int) -> List[Complex]:
    f = [0j] * n
    f[a] = 1 + 0j
    return f


def character(n: int, b: int) -> List[Complex]:
    return [cmath.exp(2j * math.pi * (b * x % n) / n) for x in range(n)]


# ---------------------------------------------------------------------------
# 6. The parity-weighted permutation criterion (exact integer arithmetic)
# ---------------------------------------------------------------------------


def perm_sign(perm: Sequence[int]) -> int:
    """Sign of a permutation given in one-line notation."""
    n = len(perm)
    seen = [False] * n
    sign = 1
    for i in range(n):
        if seen[i]:
            continue
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        if length % 2 == 0:
            sign = -sign
    return sign


def perm_coefficients(S: Sequence[int], T: Sequence[int], p: int) -> Dict[int, int]:
    """
    Parity-weighted multiplicities  c_r = sum_{sigma : E_sigma = r} sgn(sigma),
    where E_sigma = sum_j S[sigma(j)] * T[j]  (mod p).

    The minor (omega^{S_j T_k}) is nonsingular iff some c_r is nonzero (n >= 2).
    Complexity: O(n! * n).
    """
    n = len(S)
    coeffs: Dict[int, int] = {}
    for perm in itertools.permutations(range(n)):
        e = sum(S[perm[j]] * T[j] for j in range(n)) % p
        coeffs[e] = coeffs.get(e, 0) + perm_sign(perm)
    return {r: c for r, c in coeffs.items() if c != 0}


def minor_is_nonsingular(S: Sequence[int], T: Sequence[int], p: int) -> bool:
    """Exact nonsingularity test for a DFT minor of Z_p via the parity criterion."""
    if len(S) <= 1:
        return True
    return len(perm_coefficients(S, T, p)) > 0


def fibre_profile(S: Sequence[int], T: Sequence[int], p: int) -> Dict[int, Tuple[int, int]]:
    """For each residue r: (number of even permutations, number of odd ones) with E_sigma = r."""
    n = len(S)
    prof: Dict[int, Tuple[int, int]] = {}
    for perm in itertools.permutations(range(n)):
        e = sum(S[perm[j]] * T[j] for j in range(n)) % p
        ev, od = prof.get(e, (0, 0))
        if perm_sign(perm) == 1:
            prof[e] = (ev + 1, od)
        else:
            prof[e] = (ev, od + 1)
    return prof


def verify_chebotarev(p: int, n: int) -> Tuple[int, int]:
    """
    Exhaustively verify that every n x n minor of the DFT matrix of Z_p is
    nonsingular, using the exact parity criterion.
    Returns (number of minors tested, number of singular ones found).
    """
    tested = 0
    singular = 0
    for S in itertools.combinations(range(p), n):
        for T in itertools.combinations(range(p), n):
            tested += 1
            if not minor_is_nonsingular(S, T, p):
                singular += 1
    return tested, singular


def unique_perm_fraction(p: int, n: int) -> float:
    """
    Fraction of minors for which some permutation realises its exponent
    uniquely (a fibre of size one) - the easy sufficient condition.
    """
    good = 0
    total = 0
    for S in itertools.combinations(range(p), n):
        for T in itertools.combinations(range(p), n):
            total += 1
            prof = fibre_profile(S, T, p)
            if any(ev + od == 1 for ev, od in prof.values()):
                good += 1
    return good / total


# ---------------------------------------------------------------------------
# 7. Sparse recovery: 2k Fourier samples determine a k-sparse vector
# ---------------------------------------------------------------------------


def recover_sparse(p: int, k: int, samples: Sequence[int], f: Sequence[Complex]) -> List[Complex]:
    """
    Given the Fourier coefficients of a k-sparse f at 2k frequencies, recover f
    by brute-force least squares over all possible supports (a demonstration of
    uniqueness, not an efficient algorithm).
    """
    fhat = dft(f)
    data = [fhat[s] for s in samples]
    best: Tuple[float, List[Complex]] = (float("inf"), [0j] * p)
    for supp in itertools.combinations(range(p), k):
        # solve the (2k) x k system by normal equations, done with plain Python
        A = [[cmath.exp(-2j * math.pi * (s * x % p) / p) for x in supp] for s in samples]
        coeffs = _least_squares(A, list(data))
        resid = 0.0
        for row, d in zip(A, data):
            resid += abs(sum(r * c for r, c in zip(row, coeffs)) - d) ** 2
        if resid < best[0]:
            g = [0j] * p
            for x, c in zip(supp, coeffs):
                g[x] = c
            best = (resid, g)
    return best[1]


def _least_squares(A: List[List[Complex]], b: List[Complex]) -> List[Complex]:
    """Solve min ||Ax - b|| via normal equations and Gaussian elimination."""
    m, n = len(A), len(A[0])
    # normal equations  (A* A) x = A* b
    M = [[sum(A[i][r].conjugate() * A[i][c] for i in range(m)) for c in range(n)] for r in range(n)]
    y = [sum(A[i][r].conjugate() * b[i] for i in range(m)) for r in range(n)]
    # Gaussian elimination with partial pivoting
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(M[r][col]))
        M[col], M[piv] = M[piv], M[col]
        y[col], y[piv] = y[piv], y[col]
        if abs(M[col][col]) < 1e-14:
            continue
        for r in range(col + 1, n):
            factor = M[r][col] / M[col][col]
            for c in range(col, n):
                M[r][c] -= factor * M[col][c]
            y[r] -= factor * y[col]
    x = [0j] * n
    for r in range(n - 1, -1, -1):
        if abs(M[r][r]) < 1e-14:
            continue
        x[r] = (y[r] - sum(M[r][c] * x[c] for c in range(r + 1, n))) / M[r][r]
    return x


# ---------------------------------------------------------------------------
# Main narrative
# ---------------------------------------------------------------------------


def main() -> None:
    line = "=" * 74

    print(line)
    print("1. THE TWO UNCERTAINTY INEQUALITIES ON Z_p")
    print(line)
    for p in (5, 7, 11, 13):
        stats = test_bounds(p, trials=120, seed=p)
        print(
            f"  p = {p:2d}:  min over random trials of |supp f|+|supp f^| = {stats['min_sum']:3d}"
            f"   (bound p+1 = {p+1:3d});"
            f"   min of the product = {stats['min_product']:3d}  (bound p = {p:2d})"
        )

    print()
    print(line)
    print("2. THE ADDITIVE BOUND IS STRICTLY STRONGER")
    print(line)
    for p in (5, 11, 23, 101):
        a, b = product_not_sum_witness(p)
        c, d = balanced_witness(p)
        print(
            f"  p = {p:3d}:  (a,b) = ({a},{b}) has a*b = {a*b} >= {p} but a+b = {a+b} < {p+1};"
            f"   balanced profile ({c},{d}): product {c*d} >= {p}, sum {c+d} < {p+1}"
        )

    print()
    print(line)
    print("3. PRIMALITY IS ESSENTIAL: THE SUBGROUP {0,2} OF Z_4")
    print(line)
    f4 = subgroup_indicator_z4()
    a, b = uncertainty_pair(f4)
    print(f"  f = indicator of {{0,2}} in Z_4:   |supp f| = {a},  |supp f^| = {b}")
    print(f"  product  {a}*{b} = {a*b} >= 4        (Donoho-Stark holds, with equality)")
    print(f"  additive {a}+{b} = {a+b} <  5        (the additive bound FAILS)")
    print(f"  transform values: {[complex(round(z.real, 6), round(z.imag, 6)) for z in dft(f4)]}")

    print()
    print(line)
    print("4. SHARPNESS AT BOTH ENDS (p = 7)")
    print(line)
    p = 7
    a, b = uncertainty_pair(delta(p, 3))
    print(f"  Dirac delta at 3:      |supp| = {a}, |supp of transform| = {b}, sum = {a+b} = p+1")
    a, b = uncertainty_pair(character(p, 2))
    print(f"  character x -> w^{{2x}}:  |supp| = {a}, |supp of transform| = {b}, sum = {a+b} = p+1")

    print()
    print(line)
    print("5. THE PARITY-WEIGHTED PERMUTATION CRITERION (exact integer arithmetic)")
    print(line)
    S, T = (0, 1, 3), (0, 2, 3)
    p = 7
    print(f"  p = {p}, rows S = {S}, columns T = {T}")
    prof = fibre_profile(S, T, p)
    for r in sorted(prof):
        ev, od = prof[r]
        print(f"    residue {r}: {ev} even, {od} odd permutations  ->  signed count {ev-od:+d}")
    print(f"  nonzero parity-weighted multiplicities: {perm_coefficients(S, T, p)}")
    print(f"  minor nonsingular: {minor_is_nonsingular(S, T, p)}")

    print()
    for (p, n) in ((5, 3), (7, 3), (7, 4), (11, 3), (11, 4)):
        tested, singular = verify_chebotarev(p, n)
        frac = unique_perm_fraction(p, n)
        print(
            f"  p = {p:2d}, n = {n}: {tested:5d} minors tested, {singular} singular;"
            f"  {100*frac:5.1f}% settled by a singleton fibre"
        )

    print()
    print(line)
    print("6. SPARSE RECOVERY FROM 2k FOURIER SAMPLES (p = 11, k = 2)")
    print(line)
    p, k = 11, 2
    f = [0j] * p
    f[2] = 1.5 + 0.5j
    f[7] = -0.75 + 1.25j
    samples = [0, 1, 2, 3]
    g = recover_sparse(p, k, samples, f)
    err = max(abs(x - y) for x, y in zip(f, g))
    print(f"  true signal:      {[complex(round(z.real,3), round(z.imag,3)) for z in f]}")
    print(f"  frequencies used: {samples}")
    print(f"  recovered:        {[complex(round(z.real,3), round(z.imag,3)) for z in g]}")
    print(f"  max error:        {err:.2e}")
    print()
    print("  Any 2k = 4 frequencies suffice, because every 4 x 4 minor of the")
    print("  Fourier matrix of Z_11 is nonsingular - which is exactly the")
    print("  additive uncertainty principle in disguise.")


if __name__ == "__main__":
    main()
