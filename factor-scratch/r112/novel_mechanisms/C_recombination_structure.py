#!/usr/bin/env python3
"""
CANDIDATE C -- Is a REAL relation matrix structurally distinguishable from a
RANDOM GF(2) matrix, in the statistic that recombination actually uses?

THE MECHANISM (a recombination scheme, distinct from Coppersmith/p+1/ECM).
Recombination = m relations -> GF(2) elimination -> nullspace vectors -> hash
each vector's square part -> two equal square parts give gcd(a-b,N) splitting
N.  The claim worth testing: real relations are NOT independent random vectors,
so the nullspace may carry structure a smarter recombination could exploit.

FALSIFIER (cheapest possible, run BEFORE inventing any new rule): if the
collision process on the real nullspace is statistically indistinguishable
from a random GF(2) matrix of identical (m,n) shape, there is no exploitable
structure and the direction is closed.

MANDATORY CONTROL: the SAME statistic is computed on a random GF(2) matrix of
identical shape.  A harness that cannot separate real from random has no power
to detect structure at all.

DEFECT FOUND WHILE WRITING THIS (recorded, not hidden): the first draft
implemented two "different" recombination rules R1 (two-way) and R2 (three-way)
that turned out to share the same collision code path.  That is the
"control reuses the logic under test" failure from
four-verification-failures-that-all-looked-fine item 2 -- the control would
have been a re-derivation through the same expression.  Deleted and replaced
by a single collision statistic against an INDEPENDENT random matrix.

SECOND DEFECT, ALSO RECORDED: the first run collected 0/3 relations and I
nearly read that as "no structure".  It was a parameter failure -- cubic
Montgomery at N=2^60 with a factor base of 2^8.6 gives u = ln F/ln B = 11,
where Dickman is ~1e-11.  A 0/3 relation count is a VOID harness, not a null.
Rebuilt on the quadratic sieve, which reaches u ~ 3 at this size.  The
yield is printed explicitly so this cannot recur silently.

SCOPE LIMIT stated before the run: even a positive here is a CONSTANT factor.
It cannot change the L[1/3] exponent.
"""
import sys, json, time, random
from math import gcd
from sympy import primerange
from common112 import gen_semiprime


def nullspace_basis(M, ncols):
    """Basis of {y in GF(2)^m : M^T y = 0} -- the nullspace OVER RELATIONS.

    DEFECT FIXED.  The first version computed {x : M x = 0}, the nullspace
    over the factor-base COLUMNS.  Recombination needs the LEFT nullspace:
    a subset of RELATIONS whose product has all-even exponents.  Computing
    the wrong nullspace gave "real nullity 77, random nullity 0" -- an
    artefact of the real matrix being rank-deficient for unrelated reasons,
    not a statement about recombination.  Transposed now.

    Implementation: reduce M (m x n) to RREF tracking the row operations on
    an identity of size m, so the left nullspace falls out as the
    combinations that reduce to zero.
    """
    m = len(M)
    n = ncols
    # augment with m x m identity to track combinations of the m rows
    A = [list(M[i]) + [1 if j == i else 0 for j in range(m)] for i in range(m)]
    piv, r = [], 0
    for c in range(n):
        pr = None
        for i in range(r, m):
            if A[i][c]:
                pr = i
                break
        if pr is None:
            continue
        A[r], A[pr] = A[pr], A[r]
        for i in range(m):
            if i != r and A[i][c]:
                A[i] = [a ^ b for a, b in zip(A[i], A[r])]
        piv.append(c)
        r += 1
        if r == m:
            break
    # rows r..m-1 of A have zero in the first n columns -> they ARE left-null
    basis = [A[i][n:n + m] for i in range(r, m)]
    return basis, r


def qs_relations(N, D, fb, xmax, want, rng):
    """Quadratic sieve relations: x^2 - D y^2 = F,  F FB-smooth.
    Smoothness is EXACT trial division -- no Dickman, no approximation."""
    fbl = list(fb)
    rels = []
    tries = 0
    cap = want * 400
    while len(rels) < want and tries < cap:
        tries += 1
        x = rng.randrange(1, xmax)
        y = rng.randrange(1, xmax)
        val = x * x - D * y * y
        if val <= 0:
            continue
        rem = val
        exps = [0] * len(fbl)
        for i, pr in enumerate(fbl):
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
        rels.append((exps, x, y, val))
    return rels, tries


def rel_value(vec, rels, fb):
    """Integer value of the relation formed by the subset `vec` of relations,
    with its exponent parity recorded."""
    tot = 1
    par = [0] * len(fb)
    for i, e in enumerate(vec):
        if not e:
            continue
        exps = rels[i][0]
        tot *= rels[i][3]
        for j, x in enumerate(exps):
            par[j] ^= (x & 1)
    return tot, par


def stats(M, ncols, fb, N, rels):
    basis, rank = nullspace_basis(M, ncols)
    seen = {}
    coll = splits = 0
    vals = []
    for idx, vec in enumerate(basis):
        val, par = rel_value(vec, rels, fb)
        vals.append((val, par))
        key = frozenset(j for j, e in enumerate(par) if e)   # square class
        if key in seen:
            coll += 1
            b_val, _ = vals[seen[key]]
            g = gcd(val - b_val, N)
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
    for Nbits, seed in [(48, 1), (48, 2), (52, 1), (52, 2)]:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(Nbits, seed, beta=0.5)
        assert p * q == N and N.bit_length() == Nbits
        D = 1
        while any(D % r == 0 for r in (4, 9, 5, 7, 11, 13, 17, 19, 23, 29, 31)):
            D += 1
        fb = list(primerange(2, 2000))
        want = len(fb) + 20
        rels, tries = qs_relations(N, D, fb, xmax=1 << 18, want=want, rng=rng)
        yld = len(rels) / max(1, tries)
        if len(rels) < want:
            out["cells"].append(dict(Nbits=Nbits, seed=seed, err="stalled",
                                     got=len(rels), want=want, yield_=yld))
            print("N=%d seed=%d VOID: only %d/%d relations (yield %.2e)" %
                  (Nbits, seed, len(rels), want, yld), flush=True)
            continue
        M = [[e % 2 for e in exps] for exps, x, y, v in rels]
        real = stats(M, len(fb), fb, N, rels)
        rng2 = random.Random(seed * 31 + 5)
        Mr = [[rng2.randrange(2) for _ in range(len(fb))] for _ in rels]
        rand = stats(Mr, len(fb), fb, N, rels)
        out["cells"].append(dict(Nbits=Nbits, seed=seed, D=D, n_fb=len(fb),
                                 n_rels=len(rels), tries=tries, yield_=yld,
                                 real=real, random=rand))
        print("N=%d seed=%d rels=%d/%d yield=%.2e | REAL null=%d coll=%.4f "
              "splits=%d | RAND null=%d coll=%.4f splits=%d" %
              (Nbits, seed, len(rels), want, yld, real["nullity"],
               real["collision_rate"], real["splits"], rand["nullity"],
               rand["collision_rate"], rand["splits"]), flush=True)
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_C_recomb.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
