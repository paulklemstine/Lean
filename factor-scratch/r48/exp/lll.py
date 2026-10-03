"""Hand-rolled LLL over Z.

Gram-Schmidt is done in float with per-row power-of-two rescaling (so a
2000-bit row never overflows a double); the basis itself is exact Python
ints.  `mu` is scale-invariant, and each row's true squared norm is carried
in log2 so the Lovasz comparison stays valid across rows of wildly
different magnitude.

`verify()` checks the reducer did not corrupt the lattice: exact integer
determinant preservation, no zero rows, and the Lovasz condition on the
output.  The instrument has to be trusted before it can measure anything.
"""
from math import log2, sqrt


def _det_int(rows):
    """Exact integer determinant, fraction-free Bareiss."""
    n = len(rows)
    if n == 0:
        return 1
    A = [list(r) for r in rows]
    sign = 1
    prev = 1
    for k in range(n - 1):
        if A[k][k] == 0:
            piv = None
            for i in range(k + 1, n):
                if A[i][k] != 0:
                    piv = i
                    break
            if piv is None:
                return 0
            A[k], A[piv] = A[piv], A[k]
            sign = -sign
        pk = A[k][k]
        for i in range(k + 1, n):
            aik = A[i][k]
            # every entry must still be rescaled by pk/prev, even when aik==0
            for j in range(k + 1, n):
                A[i][j] = (A[i][j] * pk - aik * A[k][j]) // prev
            A[i][k] = 0
        prev = pk
    return sign * A[n - 1][n - 1]


def _shift(row):
    """Power-of-two shift bringing the row into a safe float range."""
    m = 0
    for x in row:
        a = abs(x)
        if a:
            b = a.bit_length()
            if b > m:
                m = b
    return max(0, m - 60)


def _to_float(row, s):
    return [float(x >> s) if x >= 0 else -float((-x) >> s) for x in row]


def lll(B, delta=0.99, max_steps=2000000):
    """Standard LLL.  B: list of rows of ints.  Returns a new list of rows."""
    B = [list(r) for r in B]
    n = len(B)
    if n == 0:
        return B
    d = len(B[0])
    mu = [[0.0] * n for _ in range(n)]
    Bst = [[0.0] * d for _ in range(n)]
    Dsh = [0.0] * n     # squared norm of the *shifted* b*_i (float, finite)
    logD = [0.0] * n     # log2 of the true ||b*_i||^2

    def gs_row(i):
        s = _shift(B[i])
        v = _to_float(B[i], s)
        for j in range(i):
            num = 0.0
            bj = Bst[j]
            for t in range(d):
                num += v[t] * bj[t]
            mu[i][j] = num / Dsh[j] if Dsh[j] > 0.0 else 0.0
        r = list(v)
        for j in range(i):
            c = mu[i][j]
            bj = Bst[j]
            for t in range(d):
                r[t] -= c * bj[t]
        nrm = 0.0
        for x in r:
            nrm += x * x
        if nrm <= 0.0:
            raise ValueError("rank-deficient basis")
        nrm = max(nrm, 1e-300)
        logD[i] = 2.0 * s + log2(nrm)
        # Renormalise the orthogonalised vector by a power of two.  mu is
        # scale-invariant, so this is free, and it keeps every coordinate near
        # 2^30 -- without it the orthogonalised vector can be many hundreds of
        # bits below the row norm and the float dot products lose all
        # significance, which makes the Lovasz test oscillate forever.
        mx = max(abs(x) for x in r)
        if mx > 0.0:
            t2 = int(log2(mx)) - 30
            if t2 != 0:
                f = 2.0 ** (-t2) if abs(t2) < 900 else 1.0
                r = [x * f for x in r]
                logD[i] += 2.0 * t2
                nrm *= f * f
        Bst[i] = r
        Dsh[i] = max(nrm, 1e-300)

    def size_reduce(k):
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5 + 1e-12:
                q = int(round(mu[k][j]))
                bk, bj = B[k], B[j]
                if q:
                    for t in range(d):
                        bk[t] -= q * bj[t]
                for t in range(n):
                    mu[k][t] -= q * mu[j][t]
                mu[k][j] -= q

    for i in range(n):
        gs_row(i)

    k = 1
    steps = 0
    while k < n:
        steps += 1
        if steps > max_steps:
            raise RuntimeError("LLL did not terminate")
        size_reduce(k)
        gs_row(k)                       # norms changed -> recompute row k
        if logD[k] >= logD[k - 1] + log2(max(delta - mu[k][k - 1] ** 2, 1e-12)) - 1e-9:
            k += 1
        else:
            B[k], B[k - 1] = B[k - 1], B[k]
            # both rows changed position: row k-1's GS changed, so row k's
            # mu coefficients against it are stale and must be redone too.
            gs_row(k - 1)
            gs_row(k)
            k = max(k - 1, 1)
    return B


def verify(B_in, B_out, delta=0.99, tol=1e-6):
    """Checks the reducer did not corrupt the lattice."""
    n = len(B_in)
    problems = []
    din, dout = _det_int(B_in), _det_int(B_out)
    if abs(din) != abs(dout):
        problems.append("det changed: %s -> %s" % (din, dout))
    for i, r in enumerate(B_out):
        if all(x == 0 for x in r):
            problems.append("row %d is zero" % i)
    if n > 1:
        d = len(B_out[0])
        mu = [[0.0] * n for _ in range(n)]
        Bst = [[0.0] * d for _ in range(n)]
        Dsh = [0.0] * n
        logD = [0.0] * n
        for i in range(n):
            s = _shift(B_out[i])
            v = _to_float(B_out[i], s)
            for j in range(i):
                num = sum(v[t] * Bst[j][t] for t in range(d))
                mu[i][j] = num / Dsh[j] if Dsh[j] > 0 else 0.0
            r = list(v)
            for j in range(i):
                c = mu[i][j]
                for t in range(d):
                    r[t] -= c * Bst[j][t]
            nrm = max(sum(x * x for x in r), 1e-300)
            logD[i] = 2.0 * s + log2(nrm)
            mx = max(abs(x) for x in r)
            if mx > 0.0:
                t2 = int(log2(mx)) - 30
                if t2 != 0:
                    f = 2.0 ** (-t2) if abs(t2) < 900 else 1.0
                    r = [x * f for x in r]
                    logD[i] += 2.0 * t2
                    nrm *= f * f
            Bst[i] = r
            Dsh[i] = max(nrm, 1e-300)
        for k in range(1, n):
            lhs = logD[k]
            rhs = logD[k - 1] + log2(max(delta - mu[k][k - 1] ** 2, 1e-12))
            if lhs < rhs - tol:
                problems.append("Lovasz violated at k=%d by %.3g bits" % (k, rhs - lhs))
    return problems


def row_log2norm(row):
    """log2 of the 2-norm.  Computed from bit_length so it never overflows a
    float and never hits math.log2's domain error on a zero row."""
    s = sum(x * x for x in row)
    if s == 0:
        return float("-inf")
    return 0.5 * (s.bit_length() - 1)
