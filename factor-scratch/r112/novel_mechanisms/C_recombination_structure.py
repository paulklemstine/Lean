#!/usr/bin/env python3
"""
CANDIDATE C -- Is a real NFS relation matrix structurally distinguishable from
a RANDOM GF(2) matrix, in a way that recombination could exploit?

THE MECHANISM (a recombination scheme, distinct from Coppersmith/p+1/ECM).
Standard NFS recombination: m relations -> GF(2) elimination -> nullspace vectors
-> hash each vector's square part -> two equal square parts give
gcd(a-b, N) that splits N.  The claim worth testing is that real NFS relations
are NOT independent random vectors (they come from a 2-parameter (a,b) family
hitting a smoothness condition), so the nullspace might carry structure that
changes the collision process.

FALSIFIER (cheapest possible): if the collision process on the real NFS
nullspace is statistically indistinguishable from a RANDOM GF(2) matrix of the
same shape, there is no exploitable structure and the direction is closed.
This is a NULL-RESULT test, run before any recombination rule is invented --
inventing R1/R2 first and then looking for a win is how this campaign
manufactures results.

MANDATORY CONTROL: the SAME collision statistic is computed on a random GF(2)
matrix of identical (m, n) shape.  A harness that cannot separate real from
random has no power to detect structure.

NOTE ON A DEFECT FOUND WHILE WRITING THIS: the first draft implemented two
named recombination rules (R1 two-way, R2 three-way) that turned out to share
the same collision code path -- the "control" would have been a re-derivation
through the same expression, the exact failure in
four-verification-failures-that-all-looked-fine item 2.  Deleted; replaced by
a single collision statistic compared against an independent random matrix.

SCOPE LIMIT stated BEFORE the run: even a positive here is a CONSTANT factor.
It cannot change the L[1/3] exponent.  Run at small N because that is where a
full relation collection is affordable.
"""
import sys, json, time, random
from math import gcd
from sympy import primerange
from common112 import gen_semiprime


# ---------------------------------------------------------------- GF(2) elim
def nullspace_basis(M, ncols):
    """Basis of {x : M x = 0} over GF(2), via RREF.  Independent of any
    recombination code -- this is pure linear algebra."""
    Mf = [row[:] for row in M]
    m = len(Mf)
    piv = []
    r = 0
    for c in range(ncols):
        pr = None
        for i in range(r, m):
            if Mf[i][c]:
                pr = i
                break
        if pr is None:
            continue
        Mf[r], Mf[pr] = Mf[pr], Mf[r]
        for i in range(m):
            if i != r and Mf[i][c]:
                Mf[i] = [a ^ b for a, b in zip(Mf[i], Mf[r])]
        piv.append(c)
        r += 1
        if r == m:
            break
    pivset = set(piv)
    free = [c for c in range(ncols) if c not in pivset]
    basis = []
    for f in free:
        v = [0] * ncols
        v[f] = 1
        for i, pc in enumerate(piv):
            v[pc] = Mf[i][f]
        basis.append(v)
    return basis, r


def collect_nfs_relations(N, fb, boxA, boxB, need, rng):
    """Cubic Montgomery NFS: N = d^3 + c, F(x,y) = (d x + y)^3 + c, F(1,0)=N.

    Smoothness is EXACT trial division over fb.  No Dickman, no approximation.
    """
    d = int(round(N ** (1.0 / 3)))
    while d ** 3 > N:
        d -= 1
    while (d + 1) ** 3 <= N:
        d += 1
    c = N - d ** 3
    assert d ** 3 + c == N, "f(1) != N"
    assert c != 0
    rels = []
    tries = 0
    cap = need * 3000
    while len(rels) < need and tries < cap:
        tries += 1
        x = rng.randrange(1, boxA)
        y = rng.randrange(0, boxB)
        v = (d * x + y) ** 3 + c
        if v <= 1:
            continue
        rem = v
        exps = [0] * len(fb)
        for i, pr in enumerate(fb):
            if pr > rem:
                break
            if rem % pr == 0:
                e = 0
                while rem % pr == 0:
                    rem //= pr
                    e += 1
                exps[i] = e
        if rem != 1:
            continue
        rels.append((exps, x, y, v))
    return rels, tries, d, c


def square_part_key(vec, fb):
    """The square class of the integer prod fb[i]**vec[i]:
    the set of primes appearing to an ODD exponent."""
    return frozenset(i for i, e in enumerate(vec) if e)


def collision_stats(M, ncols, fb, N, seed):
    """Fraction of nullspace vectors whose square part collides with an earlier
    one, and whether any collision yields a genuine split.  This is the
    statistic compared real-vs-random."""
    basis, rank = nullspace_basis(M, ncols)
    seen = {}
    coll = 0
    splits = 0
    for idx, vec in enumerate(basis):
        key = square_part_key(vec, fb)
        if key in seen:
            coll += 1
            a = 1
            for i, e in enumerate(vec):
                if e:
                    a *= fb[i] ** e
            b = 1
            for i, e in enumerate(basis[seen[key]]):
                if e:
                    b *= fb[i] ** e
            g = gcd(a - b, N)
            if 1 < g < N:
                splits += 1
        else:
            seen[key] = idx
    nb = len(basis)
    return dict(rank=rank, nullity=nb, collisions=coll,
                collision_rate=(coll / nb if nb else 0.0), splits=splits,
                distinct_keys=len(seen))


def main():
    out = dict(cells=[])
    cfgs = [(60, 1, 3), (60, 2, 3)]          # (N bits, seed, target rels)
    for Nbits, seed, need in cfgs:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(Nbits, seed, beta=0.5)
        assert p * q == N and N.bit_length() == Nbits
        BB = 400
        fb = list(primerange(2, BB))
        rels, tries, d, c = collect_nfs_relations(
            N, fb, boxA=4000, boxB=4000, need=need, rng=rng)
        if len(rels) < need:
            out["cells"].append(dict(Nbits=Nbits, seed=seed,
                                     err="relation collection stalled",
                                     got=len(rels), tries=tries))
            print("N=%d seed=%d: only %d/%d relations" %
                  (Nbits, seed, len(rels), need), flush=True)
            continue
        M = [[e % 2 for e in exps] for exps, x, y, v in rels]
        real = collision_stats(M, len(fb), fb, N, seed)
        # NULL CONTROL: same shape, random GF(2) rows
        rng2 = random.Random(seed * 7 + 1)
        Mr = [[rng2.randrange(2) for _ in range(len(fb))] for _ in rels]
        rand = collision_stats(Mr, len(fb), fb, N, seed)
        out["cells"].append(dict(Nbits=Nbits, seed=seed, d=d, c=c, BB=BB,
                                 n_rels=len(rels), tries=tries,
                                 real=real, random=rand))
        print("N=%d seed=%d rels=%d  REAL nullity=%d collrate=%.4f splits=%d"
              "  |  RANDOM nullity=%d collrate=%.4f splits=%d" %
              (Nbits, seed, len(rels), real["nullity"], real["collision_rate"],
               real["splits"], rand["nullity"], rand["collision_rate"],
               rand["splits"]), flush=True)
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_C_recomb.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
