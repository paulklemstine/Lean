"""
fastnull.py -- exact null space, fast enough to sweep b up to 200.

WHY THIS FILE EXISTS.  The sweep needs b above 16 (the Dickman model's argmin is
b=200 at n=2^30), and stange.py's `kernel_basis` calls sympy's
`Matrix.nullspace()`, which is unusable there: measured 0.037 s at b=8,
0.060 s at b=16, and STILL RUNNING after 60 s at b=32 (killed, exit 124).  Every
b above 16 in this round would have been unmeasurable, and the argmin sits
above 16.

METHOD.  Exact Gauss-Jordan over `fractions.Fraction`.  Unconditionally
correct, no clever trick, no exact-division theorem to get wrong.  Measured on
dense b x (b+c) integer matrices: 0.05 s at b=32, 0.65 s at b=64, 6.3 s at
b=128, 33 s at b=200.

⚠️ TWO BUGS THIS FILE PAID FOR, recorded because they are general hazards and
because BOTH would have shipped silently:

  (1) Bareiss fraction-free elimination with `if f == 0: continue`.  The
      skipped row is never SCALED by the pivot, so the next step's division is
      inexact and `//` truncates (51/2 -> 25).  Result: correct rank, correct
      dimension, and every single returned vector wrong.

  (2) Fraction back-substitution that (a) omitted the negation and (b) summed
      only over j > pc.  Both are wrong because a FREE column can sit LEFT of a
      pivot column and its RREF entry there need not be zero.

The lesson, and the reason FN1 asserts `M v = 0 exactly over Q` rather than
comparing ranks or dimensions: a rank check passes for a completely wrong
basis.  That assertion is the only thing standing between this file and a
fabricated factorization.
"""

from __future__ import annotations

import math
from fractions import Fraction


def nullspace_frac(M):
    """Basis (list of lists of Fraction) of {v in Q^n : M v = 0}, plus the rank.

    Matches stange.kernel_basis's CONTRACT: M is b x (b+c) given by rows, whose
    COLUMNS are the relations; the returned vectors are in Q^(b+c).
    """
    m = len(M)
    n = len(M[0])
    A = [[Fraction(x) for x in row] for row in M]
    piv = []
    r = 0
    for c in range(n):
        if r >= m:
            break
        p = None
        for i in range(r, m):
            if A[i][c] != 0:
                p = i
                break
        if p is None:
            continue
        A[r], A[p] = A[p], A[r]
        pv = A[r][c]
        A[r] = [x / pv for x in A[r]]          # pivot becomes exactly 1
        for i in range(m):
            if i == r or A[i][c] == 0:
                continue
            f = A[i][c]
            Ai, Ar = A[i], A[r]
            for j in range(c, n):
                Ai[j] -= f * Ar[j]
            Ai[c] = Fraction(0)
        piv.append(c)
        r += 1
    pivset = set(piv)
    free = [j for j in range(n) if j not in pivset]
    basis = []
    for fc in free:
        x = [Fraction(0)] * n
        x[fc] = Fraction(1)
        # Sum over ALL j != pc: in RREF the only nonzero pivot-column entry of
        # row i is at its own pivot, but FREE columns are nonzero anywhere --
        # including to the LEFT of pc.  Restricting the sum to j > pc silently
        # drops those terms.
        for i in range(len(piv) - 1, -1, -1):
            pc = piv[i]
            s = Fraction(0)
            Ai = A[i]
            for j in range(n):
                if j != pc and Ai[j] and x[j]:
                    s += Ai[j] * x[j]
            x[pc] = -s
        basis.append(x)
    return basis, r


def primitive_fast(v):
    """Algorithm 2.2 step 12 verbatim: clear denominators, then divide out the
    gcd.  Identical in behaviour to stange.primitive."""
    den = 1
    for x in v:
        d = 1 if isinstance(x, int) else (int(x.q) if hasattr(x, "q")
                                          else int(x.denominator))
        den = den * d // math.gcd(den, d)
    w = [int(x * den) for x in v]
    gg = 0
    for x in w:
        gg = math.gcd(gg, abs(x))
    if gg > 1:
        w = [x // gg for x in w]
    for x in w:
        if x != 0:
            if x < 0:
                w = [-y for y in w]
            break
    return w


def selftest() -> bool:
    import random
    import sys
    import time

    sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
    from stange import kernel_basis  # the reference implementation

    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        print(f"  [{'PASS' if cond else 'FAIL'}] {name} {detail}", flush=True)
        if not cond:
            ok = False

    print("== FN1. nullspace_frac AGREES WITH sympy kernel_basis ==")
    rng = random.Random(31415)
    for (b, c) in [(3, 2), (5, 3), (8, 1), (10, 5), (14, 2), (16, 4)]:
        for trial in range(4):
            M = [[rng.randrange(-4, 5) for _ in range(b + c)] for _ in range(b)]
            Kf, rf = nullspace_frac(M)
            Ks, rs = kernel_basis(M)
            exact = True
            for v in Kf:
                for i in range(b):
                    if sum(Fraction(M[i][j]) * v[j] for j in range(b + c)) != 0:
                        exact = False
            check(f"  b={b} c={c} #{trial}: M v = 0 EXACTLY over Q",
                  exact, f"(dimK={len(Kf)})")
            check(f"  b={b} c={c} #{trial}: rank {rf} == sympy {rs}, "
                  f"dim {len(Kf)} == {len(Ks)}", rf == rs and len(Kf) == len(Ks))

    print("== FN2. it can DO the sizes sympy cannot ==")
    import time as _t
    for b, c in [(32, 1), (64, 1), (128, 1)]:
        M = [[rng.randrange(0, 3) for _ in range(b + c)] for _ in range(b)]
        t0 = _t.perf_counter()
        K, r = nullspace_frac(M)
        dt = _t.perf_counter() - t0
        check(f"  b={b} c={c}: rank {r} dimK {len(K)} in {dt:.2f}s", dt < 90)
        good = all(sum(Fraction(M[i][j]) * v[j] for j in range(b + c)) == 0
                   for v in K for i in range(b))
        check(f"  b={b} c={c}: M v = 0 exactly at this size", good)
        pv = [primitive_fast(v) for v in K]
        check(f"  b={b} c={c}: primitive() integral, gcd 1",
              all(all(isinstance(x, int) for x in w) for w in pv))

    print("== FN3. DEGENERATE cases return the null answer, not a crash ==")
    for M in ([[0, 0, 0], [0, 0, 0]], [[0, 0, 0, 0], [1, 2, 3, 4]],
              [[1, 2], [2, 4], [3, 6]]):
        K, r = nullspace_frac(M)
        m, n = len(M), len(M[0])
        good = all(sum(Fraction(M[i][j]) * v[j] for j in range(n)) == 0
                   for v in K for i in range(m))
        check(f"  degenerate -> dim {len(K)} == n-r = {n-r}, M v = 0",
              len(K) == n - r and good)

    print("== FN4. on a matrix shaped like a REAL relation matrix (sparse) ==")
    # Dense random is the easy case; factor-base exponent matrices are very
    # sparse (a relation typically uses only a few primes).  Check exactness there.
    for (b, c) in [(12, 1), (20, 1), (26, 3)]:
        M = [[0] * (b + c) for _ in range(b)]
        for j in range(b + c):
            for i in rng.sample(range(b), 3):
                M[i][j] = rng.randrange(1, 5)
        K, r = nullspace_frac(M)
        good = all(sum(Fraction(M[i][j]) * v[j] for j in range(b + c)) == 0
                   for v in K for i in range(b))
        check(f"  sparse b={b} c={c}: rank {r} dimK {len(K)}, M v = 0", good)

    print()
    print("ALL PASS" if ok else "!!! FAILURE")
    return ok


if __name__ == "__main__":
    import sys

    sys.exit(0 if selftest() else 1)