#!/usr/bin/env python3
"""
A3 -- INDEPENDENT re-implementation of the candidate A threshold.

WHY THIS FILE EXISTS.  The brief's sec 1 warns that re-deriving a check
through the same code path is worthless, and the four-verification-failures
memory records a control that "recomputed the cube set through the same
broken expression" and reported 0 disagreements.  Candidate A's numbers come
from r48/exp/coppersmith.py, which this campaign has already had one
defect in (a leak alignment bug that inflated X by 64 bits).  So the
threshold is re-derived here from scratch:

  * factors generated directly from sympy.nextprime (not r48 control.py)
  * the lattice written out longhand (not r48 coppersmith.univariate_lattice)
  * reduction via fpylll directly (not r48 reduce.reduce_fpylll)

The first attempt at THIS file also reported "no factor" on the known-good
control cell (pb=64, unk=31).  That was a bug in the re-implementation, not
a refutation: the h_i rows must be x^i * f(x)^m, and the draft wrote f(x)^m
repeated t times -- a wrong lattice that therefore contained no root.  The
lesson is the campaign's own: a control that fails on CORRECT input means the
instrument is broken, not the phenomenon.
"""
from sympy import nextprime, isprime
from fpylll import IntegerMatrix, LLL
import random, json, time


def gen(bits, seed, pb):
    r = random.Random(seed)
    qb = bits - pb
    while True:
        p = int(nextprime(r.getrandbits(pb) | (1 << (pb - 1))))
        q = int(nextprime(r.getrandbits(qb) | (1 << (qb - 1))))
        N = p * q
        if N.bit_length() == bits and isprime(p) and isprime(q):
            assert p * q == N
            return p, q, N


def cell(N, p, unk, m, t, budget_s=120):
    """Coppersmith lattice for f(x) = a + x, root x0 = p - a, |x0| < 2^unk."""
    nb = p.bit_length()
    if not (1 <= unk < nb):
        return None
    a = (p >> unk) << unk
    assert 0 <= p - a < (1 << unk)
    # FULL polynomial powers, matching the standard Coppersmith basis:
    #   g_{k,i} = N^{m-k} x^i f(x)^k   k=0..m-1, i=0..delta-1
    #   h_i    = x^i f(x)^m           i=0..t-1
    # with delta = deg f = 1 here, so dim = delta*m + t = m + t.
    # DEFECT FIXED: an earlier draft used the DEGREE-1 TRUNCATION
    # ((a+x)^k -> a^k + k a^(k-1) x) and kept dim = m+t, so the lattice had
    # only two columns carrying any information.  That lattice cannot contain
    # the root at any dimension, which is why it "found nothing" even on the
    # known-good control cell (pb=64, unk=31) in 0 s.  Full powers now.
    delta = 1
    dim = delta * m + t

    def polypow(c, k):
        """(a+x)^k as a coefficient list (exact, no truncation)."""
        r = [1]
        base = [c, 1]
        for _ in range(k):
            nxt = [0] * (len(r) + len(base) - 1)
            for i, u in enumerate(r):
                if u:
                    for j, w in enumerate(base):
                        if w:
                            nxt[i + j] += u * w
            r = nxt
        return r

    rows = []
    for k in range(m):
        fk = polypow(a, k)
        Np = N ** (m - k)
        for i in range(delta):
            row = [0] * dim
            for j, c in enumerate(fk):
                if i + j < dim:
                    row[i + j] = c * Np
            rows.append(row)
    fm = polypow(a, m)
    for i in range(t):
        row = [0] * dim
        for j, c in enumerate(fm):
            if i + j < dim:
                row[i + j] = c
        rows.append(row)
    sc = [delta ** 0 ] * dim
    X = 1 << unk
    sc = [X ** i for i in range(dim)]
    rows = [[r[c] * sc[c] for c in range(dim)] for r in rows]
    M = IntegerMatrix(dim, dim)
    for i, r in enumerate(rows):
        for j, v in enumerate(r):
            M[i, j] = int(v)
    LLL.reduction(M)
    for k in range(min(6, dim)):
        row = [int(M[k, c]) for c in range(dim)]
        pv = [row[c] // sc[c] for c in range(dim)]
        if pv[1] and pv[0] % pv[1] == 0:
            x = -pv[0] // pv[1]
            v = pv[0] + pv[1] * x
            if v and N % v == 0 and 1 < v < N:
                return v
    return None


GRID = [(18, 18), (26, 26), (34, 34), (42, 42), (26, 34), (30, 40)]


def run(pb, unks, seed=7):
    p, q, N = gen(128, seed, pb)
    assert p.bit_length() == pb and N.bit_length() == 128 and p * q == N
    res = []
    for unk in unks:
        t0 = time.time()
        got = None
        for (m, t) in GRID:
            got = cell(N, p, unk, m, t)
            if got:
                break
        # GROUND TRUTH: multiply back
        ok = got is not None and N % got == 0 and 1 < got < N
        is_p = (got == p)
        res.append(dict(pb=pb, unk=unk, found=bool(ok), is_p=bool(is_p),
                        secs=round(time.time() - t0, 1)))
        print("pb=%d unk=%2d found=%s is_p=%s (%.0fs)" %
              (pb, unk, ok, is_p, time.time() - t0), flush=True)
    return res


if __name__ == "__main__":
    out = []
    # CONTROL first: must reproduce the closed axis (31 works / 32 fails)
    out += run(64, [31, 32])
    out += run(42, [13, 14, 20, 21])
    out += run(32, [7, 8])
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_A3_independent.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)
