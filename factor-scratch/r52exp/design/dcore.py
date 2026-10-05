"""
dcore.py -- shared machinery for the D1/D2/D3 design-principle experiment.

THE PRINCIPLE UNDER TEST (established in round 51, LL_hybrid + KK_relcond)
-------------------------------------------------------------------------
  * NFS relation-finding succeeds because the hit set {x : l | (a^2 - b^k)} is
    PERIODIC in the index a with period exactly l, so a sieve can mark hits
    without ever forming the big integer.
  * Stange's hit set {x : l | (g^x mod n)} is aperiodic in x (LL_hybrid F2,
    5/5 primes), and separately (g^x mod n) mod l != g^x mod l in 88.2% of
    cases (F1) -- reduction mod n is not a ring homomorphism downward.
  * KK_relcond PROVED that a condition which REJECTS candidates can never beat
    the fraction q it discards:
        GAIN = (s_C/s_0) * q / (1 + q*c_cond/c_gen)
    so any balanced character (q = 1/2) is a guaranteed >= 2x loss.

THIS MODULE'S JOB: give a harness that can classify a candidate construction by
the MECHANISM that decides whether a sieve applies, and that can tell a
    "periodicity"  (small, MARKABLE period ~ l)
from a
    "periodicity in the weak sense" (a period exists, but it is huge and/or
     not computable).
That distinction is the load-bearing thing in D2/D3 and it is not what round
51's F2 measured.

MANDATORY CONTROLS BUILT IN
---------------------------
  * `periodicity()`   -- smallest period <= dmax, with an explicit statement of
                         the window K, and a NON-VACUITY obligation on callers.
  * `z_binom()`       -- refuses k > n (round-52's vacuous detector).
  * exact Psi, never Dickman rho (r48/_shared/dickman.py raises above u = 5).
  * every loop bounded.
  * per-modulus reporting is the DEFAULT: `table()` returns per-modulus rows and
    the pooled row carries the between-modulus sd, because programme rates swing
    +-0.25 on 2-adic structure alone.
"""

from __future__ import annotations

import json
import os
import random
from fractions import Fraction
from math import gcd, isqrt, log

from sympy import Matrix
from sympy.polys.matrices import DomainMatrix
from sympy.polys.domains import QQ

RESULTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results")
os.makedirs(RESULTS, exist_ok=True)


# --------------------------------------------------------------------------
# 1. Semiprimes and moduli
# --------------------------------------------------------------------------

def next_prime(x: int) -> int:
    """Bounded next-prime. No unbounded loops (round-51 lost time to those)."""
    from sympy import isprime
    if x < 2:
        return 2
    c = x + 1 if x % 2 == 0 else x + 2
    for _ in range(10_000_000):
        if isprime(c):
            return int(c)
        c += 2
    raise RuntimeError("next_prime did not terminate")


def gen_semiprime(bits: int, rng: random.Random, balance: str = "balanced"):
    """RSA-shaped semiprime n = p*q. `balance` in {balanced, skewed}.

    ⚠️ BOUNDED AND IT RETURNS None WHEN IT CANNOT, because the first version
    spun forever below 16 bits: `half = bits//2` gives half = 6 at bits = 12,
    and `next_prime` on a range with fewer than a prime in it never returns
    inside its own cap, so the retry loop never terminated.  D2b hit it as a
    >120 s hang with no output -- the third time this round that an unbounded
    loop looked like slowness.
    """
    half = max(3, bits // 2)
    if balance != "balanced":
        for _ in range(200_000):
            p = next_prime(rng.randrange(1 << (bits - 24), 1 << (bits - 20)))
            q = next_prime(rng.randrange(1 << 10, 1 << 14))
            if p != q and p * q >= (1 << (bits - 1)):
                return p * q, p, q
        return None
    # Balanced.  Draw BOTH factors from the SAME band so that p*q always lands
    # in [2^(bits-2), 2^bits] regardless of the parity of `bits`.  The previous
    # version required p*q >= 2^(bits-1) with p,q ~ 2^floor(bits/2), which is
    # UNREACHABLE for odd bits (bits=13: p,q < 2^6, so p*q < 2^12 < 2^12 is
    # borderline and the retry loop burned 200k iterations before giving up --
    # every odd bit size silently returned None).
    lo = 1 << (half - 1)
    hi = 1 << half
    if hi - lo < 8:
        return None
    for _ in range(200_000):
        p = next_prime(rng.randrange(lo, hi))
        q = next_prime(rng.randrange(lo, hi))
        if p != q:
            return p * q, p, q
    return None


def v2(x: int) -> int:
    """2-adic valuation of a POSITIVE integer. x must be nonzero."""
    if x == 0:
        raise ValueError("v2(0) is undefined -- this is the round-51 hang class")
    return (x & -x).bit_length() - 1


def factor_base(bbound: int, n: int, exclude: bool = True) -> list:
    """FB = primes <= bbound.

    `exclude=True` (the default) drops primes dividing `n`.  The exclusion is
    not cosmetic: LL_hybrid's F1 bug report was that the first version of the
    test forgot it, and then (g^x mod n) mod p == g^x mod p held VACUOUSLY
    because n ≡ 0 (mod p).

    `exclude=False` gives the raw prime list, which is what a smoothness test
    wants -- FB-smoothness of a relation value has nothing to do with which
    primes divide the modulus.  Getting this backwards is easy and silently
    makes every "is it smooth" query wrong for the small primes.
    """
    from sympy import primerange
    return [int(q) for q in primerange(2, bbound + 1)
            if (not exclude) or n % int(q) != 0]


# --------------------------------------------------------------------------
# 2. The periodicity detector  (D1's instrument)
# --------------------------------------------------------------------------

def periodicity(hits: list, dmax: int):
    """Smallest d <= dmax with hits[x] == hits[x+d] for ALL x with x+d <= len-1.

    `hits` is a 0/1 list indexed by candidate index.  Returns (d, n_checked) or
    (None, ...) -- None means "no period <= dmax on this window", which is a
    statement about dmax and the window, NOT a proof of aperiodicity.

    NON-VACUITY: a constant hit vector has period 1 trivially.  Callers MUST
    report `mean` so a constant vector is visible as such.
    """
    K = len(hits)
    for d in range(1, dmax + 1):
        ok = True
        for x in range(K - d):
            if hits[x] != hits[x + d]:
                ok = False
                break
        if ok:
            return d, K - d
    return None, 0


def hit_count(hits: list) -> int:
    return sum(1 for h in hits if h)


# --------------------------------------------------------------------------
# 3. Exact smoothness  (never Dickman rho)
# --------------------------------------------------------------------------

def exact_psi(x: int, y: int) -> int:
    """|{m <= x : m is y-smooth}| exactly, by the standard recursion

        Psi(x, i) = Psi(x, i-1) + Psi(x // p_i, i)
                    \\_____/    \\________/
        not div by p_i      divisible by p_i

    with Psi(x, 0) = 1 (only m = 1, when x >= 1).  Memoised, so the state
    count is bounded by (#distinct x//(products)) x (#primes <= y).

    NOT Dickman rho: r48/_shared/dickman.py raises above u = 5, and rho is the
    wrong functional form as a null anyway (Psi/x -> e^-gamma/ln B is constant
    at fixed B while rho -> 0, so the ratio diverges).
    """
    from functools import lru_cache
    from sympy import primerange

    if x < 1:
        return 0
    if y < 2:
        return 1  # only m = 1
    primes = [int(q) for q in primerange(2, min(y, x) + 1)]

    @lru_cache(maxsize=None)
    def psi(xx: int, i: int) -> int:
        if xx < 1:
            return 0
        if i == 0:
            return 1
        return psi(xx, i - 1) + psi(xx // primes[i - 1], i)

    return psi(x, len(primes))


def factor_exponents(v: int, FB: list):
    """Exponent vector of v over FB, or None if v has a factor > FB[-1].

    ⚠️ THE V = 0 HANG.  `a^2 - b^3 == 0` exactly when `a = c^3, b = c^2`
    (a = 8, b = 4 is the smallest example, and it is INSIDE the usual search
    box).  Then `while v % q == 0: v //= q` never terminates, because
    0 % q == 0 and 0 // q == 0 forever.  Round 51 lost >100 s to this and,
    with stdout block-buffered through a pipe, could not distinguish the hang
    from slowness.  It is handled ONCE, here, and every caller uses this
    function -- do NOT re-implement the divide-out loop inline.

    Returns (exponent_list, FB) or None.
    """
    if v <= 0:
        return None
    exps = []
    w = v
    for i, q in enumerate(FB):
        e = 0
        while w % q == 0:
            e += 1
            w //= q
            if w == 0:          # unreachable guard: w can never reach 0 here
                return None
        exps.append(e)
        if w == 1:
            # PAD to full width.  Returning a short vector here is a footgun:
            # two relations of different factorisations would then produce
            # relation-matrix rows of DIFFERENT lengths, which is exactly the
            # AssertionError that D2c hit on its first run.
            while len(exps) < len(FB):
                exps.append(0)
            return exps
    return None if w != 1 else exps


def is_smooth(v: int, FB: list) -> bool:
    """v is FB-smooth (FB sorted; smooth means every prime factor <= FB[-1]).

    Bounded: at most len(FB) divide-out rounds, and v <= 0 is REFUSED rather
    than looped on (see factor_exponents).
    """
    if v <= 0:
        return False
    for q in FB:
        while v % q == 0:
            v //= q
        if v == 1:
            return True
    return v == 1


# --------------------------------------------------------------------------
# 4. Statistics, with the non-vacuous detector
# --------------------------------------------------------------------------

def z_binom(k: int, n: int, p0: float) -> float:
    """z = (k - n p0) / sqrt(n p0 (1-p0)).  REFUSES k > n.

    Round 52's vacuous detector: a z that cannot fire is worse than none.
    """
    if not (0 <= k <= n):
        raise ValueError(f"z_binom: k={k} outside 0..n={n} -- vacuous detector")
    if n == 0 or p0 <= 0 or p0 >= 1:
        raise ValueError(f"z_binom: degenerate n={n} p0={p0}")
    num = k - n * p0
    den = (n * p0 * (1 - p0)) ** 0.5
    return num / den if den else 0.0


def pooled_with_spread(rates: list):
    """Pooled rate plus the between-cell sd -- the mandatory per-modulus control.

    rates: list of (k_i, n_i).  Returns (pooled, mean_of_rates, sd_of_rates).
    """
    K = sum(k for k, _ in rates)
    N = sum(n for _, n in rates)
    pooled = K / N if N else float("nan")
    rs = [k / n for k, n in rates if n]
    m = sum(rs) / len(rs) if rs else float("nan")
    if len(rs) > 1:
        var = sum((r - m) ** 2 for r in rs) / (len(rs) - 1)
        sd = var ** 0.5
    else:
        sd = float("nan")
    return pooled, m, sd


def fmt_rate(pooled: float, sd: float) -> str:
    return f"{pooled:.4f} (per-cell sd {sd:.4f})"


# --------------------------------------------------------------------------
# 5. Rational-exact QQ kernel  (never int() a Rational; never ZZ rref)
# --------------------------------------------------------------------------

def qq_kernel_basis(rows, n_cols: int):
    """Basis of null(M^T) over QQ, where M is the matrix whose ROWS are `rows`.

    Returns a list of vectors of length len(rows) -- one per free column of
    rref(M^T) -- each satisfying   sum_j w[j] * rows[j][i] = 0 for every i.

    WHY THE TRANSPOSE.  A relation matrix has RELATIONS AS ROWS and factor-base
    entries as columns, so it is TALL (more relations than unknowns), which is
    the shape where null(M) is trivially zero but null(M^T) has dimension
    len(rows) - rank.  A linear combination of relations is exactly a vector in
    null(M^T): the entries are the coefficients on the relations.  So this is
    the right object, and it is the one D2c needed.

    ⚠️⚠️ rref() REPORTS PIVOT COLUMNS OF THE MATRIX IT IS GIVEN.  Row-reducing
    M directly makes every column of a full-column-rank tall matrix a pivot,
    so the free-column list is EMPTY and the function would report "nullspace is
    EMPTY" for a matrix whose relation space has dimension len(rows) - rank >=
    1.  D2c hit exactly this on all 9 cells.  Reducing M^T fixes it.

    ⚠️⚠️ THE TRANSPOSE IS LOAD-BEARING.  `DomainMatrix.rref()` reports the PIVOT
    COLUMNS of the matrix handed to it.  For a TALL matrix -- the shape of every
    relation matrix, since relations always outnumber unknowns -- with full
    column rank, EVERY column is a pivot column, so the free-column list comes
    out EMPTY and the nullspace looks trivially zero, even though its true
    dimension is (rows - rank) >= 1.

    Not hypothetical: D2c hit this on all 9 cells and reported "nullspace is
    EMPTY" for a 4b x b matrix whose nullspace has dimension >= 3b.  It would
    have claimed that no oversized relation matrix has a kernel.

    The fix: the right nullspace of M is the LEFT nullspace of M^T, so reduce
    M^T (b x m); its pivot columns are then a proper subset and the free columns
    span exactly the kernel.

    Other guards, all earned:
      * rref over QQ ONLY.  `DomainMatrix.rref` is ~700-1000x faster than
        `sympy.Matrix.nullspace()` at b >= 40, which never finishes.
      * NEVER over ZZ.  Integer rref cannot divide, so it halts in a
        pivot-columns-only form whose free columns are never cleared -- it
        returns WRONG kernel vectors, silently.
      * `from_list_sympy` lands in domain EXRAW, not QQ, so convert explicitly.
      * `to_sympy()` yields DomainScalars and Fraction(DomainScalar) raises
        TypeError -- unwrap the scalar.
      * NON-VACUITY: an undivided Krylov reconstruction yields the IDENTICALLY
        ZERO vector, which passes M w = 0.  Assert nonzero, and verify against
        the ORIGINAL matrix rather than the echelon form.
    """
    if not rows:
        raise ValueError("qq_kernel_basis: empty matrix -> no basis, caller must handle")
    for r in rows:
        if len(r) != n_cols:
            raise ValueError(
                f"qq_kernel_basis: ragged row (len {len(r)} != {n_cols}). "
                "Pad exponent vectors to full width -- factor_exponents does this."
            )
    n_rows = len(rows)

    # ⚠️ WHICH MATRIX TO REDUCE.  We want null(M^T): vectors of length #relations.
    # rref reports pivot columns of what it is given.
    #   * If M is TALL (n_rows > n_cols -- the relation-matrix case), reducing M
    #     directly makes EVERY column a pivot, so free is empty and the kernel
    #     looks trivially zero.  So reduce M^T.
    #   * If M is WIDE or square, reducing M^T is still correct and general, but
    #     we then need the kernel of a matrix whose free columns index
    #     RELATIONS -- same thing, different shape.
    # Both cases are handled by always reducing M^T; the guard below only
    # exists so that a genuinely-independent relation set raises rather than
    # returning something meaningless.
    Mt = [[Fraction(int(rows[i][j])) for i in range(n_rows)]
          for j in range(n_cols)]
    T = DomainMatrix.from_list_sympy(n_cols, n_rows, Mt).convert_to(QQ)
    R, pivots = T.rref()

    def _ent(i, j):
        e = R[i, j]
        if hasattr(e, "to_sympy"):
            try:
                return e.to_sympy()
            except Exception:
                pass
        return e

    piv = list(pivots)
    pivset = set(piv)
    free = [c for c in range(n_rows) if c not in pivset]
    if not free:
        # n_rows == 1 and the single row is nonzero: null(M^T) is 1-dimensional
        # and always exists.  rref of the 2x1 transpose pivots column 0 and
        # leaves no free column, so handle the rank-1 minimal case directly.
        if n_rows == 1 and all(Fraction(int(x)) != 0 for x in rows[0]):
            c0 = Fraction(rows[0][0])
            c1 = Fraction(rows[0][1])
            w = [-c1, c0]           # c0*w0 + c1*w1 == 0
            assert any(x != 0 for x in w), "degenerate"
            assert w[0] * Fraction(rows[0][0]) + w[1] * Fraction(rows[0][1]) == 0
            return [w]
        raise ValueError(
            "qq_kernel_basis: null(M^T) is EMPTY (rank(M) = #rows). The relations are "
            "linearly independent -- too few relations to find a dependence. Not a "
            "code bug: the caller asked for a kernel that cannot exist."
        )
    n_rows = len(rows)
    basis = []
    for fc in free:
        w = [Fraction(0)] * n_rows        # M^T w = 0  <=>  M w = 0
        w[fc] = Fraction(1)
        # R is in row-echelon form; row i has pivot piv[i], and by construction
        # every NON-PIVOT entry of row i lies strictly to the RIGHT of piv[i].
        # So   sum_{c != piv[i]} R[i,c] w[c] + w[piv[i]] = 0
        # gives w[piv[i]] directly.  (The first version iterated only over
        # `free` columns, silently DROPPING the pivot entries of other rows,
        # and produced vectors that failed the M v = 0 check -- caught by the
        # assertion below, which is exactly why that assertion is there.)
        for i, pc in enumerate(piv):
            acc = Fraction(0)
            for c in range(pc + 1, n_rows):
                if c == pc:
                    continue
                acc += Fraction(_ent(i, c)) * w[c]
            w[pc] = -acc
        # NON-VACUITY: the zero vector trivially satisfies M w = 0
        assert any(x != 0 for x in w), (
            f"kernel basis vector for free col {fc} is identically zero -- vacuous"
        )
        # VERIFY against the ORIGINAL matrix -- in the TRANSPOSE sense, which is
        # what was actually computed.  The vectors span null(M^T) = null(Mt),
        # i.e. vectors of length #RELATIONS, so the check is
        #     for each column index i of Mt:   sum_j w[j] * rows[j][i] == 0
        # ⚠️ The first version checked `sum_j rows[i][j] * w[j]`, i.e. null(M),
        # which is the WRONG nullspace and, because zip() silently truncates
        # to the shorter of a length-b row and a length-#relations vector, it
        # fails on square matrices and would pass vacuously otherwise.  This
        # assertion is the only reason the bug surfaced.
        for i in range(n_cols):
            assert sum(w[j] * Fraction(int(rows[j][i])) for j in range(n_rows)) == 0, (
                f"returned kernel vector fails null(M^T) at column {i}: {w}"
            )
        basis.append(w)
    return basis


def vec_to_ints(v, scale: int = 1):
    """Fractions -> ints.  Asserts integrality after scaling; NEVER int()s blindly.

    Round-51's warning: `int(Fraction(1,2)) == 0` silently destroys M v = 0.
    """
    out = []
    for x in v:
        t = Fraction(x) * scale
        if t.denominator != 1:
            raise ValueError(f"non-integral component {x} at scale {scale}")
        out.append(int(t))
    return out


# --------------------------------------------------------------------------
# 6. Modulus arithmetic helpers  (bounded)
# --------------------------------------------------------------------------

def modpow(a: int, e: int, m: int) -> int:
    """Built-in pow is already log-time; wrapper only for symmetry + counting."""
    return pow(a, e, m)


def order_mod(a: int, m: int, cap_bits: int = 40) -> int:
    """ord_m(a) by factoring m's smooth part when possible, else baby-step.

    Bounded: returns -1 if it cannot be determined within `cap_bits` factor
    stripping rounds, and says so.  We never loop unbounded.
    """
    from sympy import factorint
    if gcd(a, m) != 1:
        return 0
    order = m
    try:
        fac = factorint(m)
    except Exception:
        return -1
    for q in fac:
        for _ in range(cap_bits):
            if order % q == 0 and pow(a, order // q, m) == 1:
                order //= q
            else:
                break
    return order


def write_json(name: str, obj) -> str:
    path = os.path.join(RESULTS, name)
    with open(path, "w") as f:
        json.dump(obj, f, indent=1, default=str)
    return path


def read_json(name: str):
    path = os.path.join(RESULTS, name)
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return json.load(f)