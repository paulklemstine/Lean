"""Round 57: why 0.4795 and not 0.5 -- a group-structure answer.

ROUNDS 55-56 measured the fraction of NON-TRIVIAL congruences x^2 = y^2 (mod n)
produced by the linear algebra.  Round 55 got 0.4795 (pooled z = -4.79).  Round 56
showed the deviation is FLAT in the smoothness bound B (slope +0.004), flat in the
x-range (bit-identical across 16x), and absent of the obvious artefact (nowrap=0).

CLAIM.  The achievable set of congruences is not an arbitrary subset; it is the
image of a GROUP HOMOMORPHISM, and that forces the fraction to be exactly 0 or
exactly 1/2 under UNIFORM sampling.  The 0.4795 is therefore a SAMPLING artefact,
not a property of the algorithm.

THE STRUCTURE.  Let P_1..P_m be the relations, each giving x_i^2 = y_i (mod n)
with y_i B-smooth.  For S subset [m] write

    X_S = prod_{i in S} x_i        (mod n)
    y_S = prod_{i in S} y_i        (mod n)

If every exponent in y_S is even then y_S = Z_S^2 for an integer Z_S, and

    X_S^2 = X_S^2 ... = prod x_i^2 = prod y_i = Z_S^2   (mod n)

so X_S^2 = Z_S^2 (mod n).  Let z_S = X_S Z_S^{-1} (mod n); then z_S^2 = 1.
For S,T and the symmetric difference S sym T,

    X_S X_T = X_{S sym T} * (prod_{i in S n T} x_i)^2
    Z_S Z_T = +- Z_{S sym T} * (prod_{i in S n T} y_i)

hence, using x_i^2 = y_i (mod n) and that y_i is a unit mod n (all primes of y_i
are <= B < p, q):

    z_S z_T = +- z_{S sym T}

Modulo the sign -- and the SIGN IS IRRELEVANT, since a congruence is trivial iff
X_S = +- Z_S, i.e. iff [z_S] = [1] in ker(phi)/{+-1} ~ Z/2 -- this says

    S |-> [z_S]  is a HOMOMORPHISM  K -> Z/2,

where K is the F_2 kernel of the relation matrix (the additive group of subsets
whose exponent parities all vanish).  A homomorphism has a kernel that is an
INDEXED subgroup, so uniform sampling from K gives EXACTLY 1/2 non-trivial, or
EXACTLY 0 if the map is trivial.

PREDICTION.  Uniform sampling from K: fraction is 1/2 (to within binomial noise),
and is EXACTLY 1/2 in expectation regardless of B, of the x-range, of n.  The
0.4795 came from sampling in ARRIVAL ORDER (Gaussian elimination order), which is
not uniform on K.

WHY THIS IS WORTH HAVING EVEN IF NO ALGORITHM IMPROVES: it identifies the sharp
question behind Lee-Venkatesan Conj. 7.1 as an INDEX question -- "is the map
K -> Z/2 onto?" -- rather than a distributional one, and it says the answer, once
non-triviality occurs at all, is as strong as possible.
"""

from __future__ import annotations

import math
import random
from math import gcd, isqrt


def is_prime(n):
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2; s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def rand_prime(bits, rng):
    while True:
        c = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(c):
            return c


def primes_upto(limit):
    s = bytearray([1]) * (limit + 1)
    s[0:2] = b"\x00\x00"
    for i in range(2, isqrt(limit) + 1):
        if s[i]:
            s[i * i::i] = bytearray(len(s[i * i::i]))
    return [i for i in range(2, limit + 1) if s[i]]


def collect(n, B, xrange, mult=8):
    """Relations x_i^2 = y_i mod n with y_i B-smooth, non-vacuous."""
    P = primes_upto(B)
    idx = {l: i for i, l in enumerate(P)}
    lo = isqrt(n) + 1
    rels, x = [], lo
    while x < xrange and len(rels) < 8 * len(P):
        y = (x * x) % n
        if y > 1:
            r = isqrt(y)
            if r * r != y:
                t = y
                par = 0
                for l in P:
                    c = 0
                    while t % l == 0:
                        t //= l; c += 1
                    if c & 1:
                        par |= 1 << idx[l]
                if t == 1:
                    rels.append((x, y, par))
        x += 1
    return P, rels


def kernel_basis(P, rels):
    """Basis of the F_2 KERNEL of the relation matrix, as combos of relation
    indices.

    BUG FOUND IN v1: this returned the PIVOT combinations (one per pivot), not
    the DEPENDENCIES.  A pivot combo is a relation whose parity vector is
    nonzero; only combos that reduce to the ZERO vector are kernel elements.
    Symptom: every sample had Yp not a perfect square, and the run printed
    nothing at all -- the "too few relations" branch was masking a total
    failure.  Fixed by collecting on v == 0.

    Returns (kernel_combos, ncols).
    """
    ncols = len(P)
    piv = [0] * ncols           # pivot vector
    pcombo = [0] * ncols        # combination of relation indices
    kernel = []
    for i, (x, y, par) in enumerate(rels):
        v, combo = par, 1 << i
        k = ncols - 1
        stored = False
        while k >= 0:
            if (v >> k) & 1:
                if piv[k]:
                    v ^= piv[k]; combo ^= pcombo[k]
                else:
                    piv[k], pcombo[k] = v, combo
                    stored = True
                    break
            k -= 1
        if not stored and v == 0:
            kernel.append(combo)      # <- the dependency: this is a kernel elt
    return kernel, ncols


def classify(n, X, Yp):
    Z = isqrt(Yp)
    if Z * Z != Yp:
        return None
    if (X * X - Z * Z) % n:
        return None
    g1 = gcd((X - Z) % n, n)
    g2 = gcd((X + Z) % n, n)
    return (1 < g1 < n) or (1 < g2 < n)


def run(n, B, xrange, nsamp, rng):
    P, rels = collect(n, B, xrange)
    if len(rels) < len(P) + 2:
        return None
    basis, ncols = kernel_basis(P, rels)
    if not basis:
        return None
    # uniform sampling from K: random XOR of kernel basis elements
    nontriv = 0
    tot = 0
    for _ in range(nsamp):
        combo = 0
        for b in basis:
            if rng.getrandbits(1):
                combo ^= b
        if combo == 0:
            continue
        X, Yp = 1, 1
        for i in range(len(rels)):
            if (combo >> i) & 1:
                X = (X * rels[i][0]) % n
                Yp *= rels[i][1]
        c = classify(n, X, Yp)
        if c is None:
            continue
        tot += 1
        if c:
            nontriv += 1
    return nontriv, tot, len(basis)


def main():
    print(__doc__)
    print()
    print("=== Uniform sampling from the F_2 kernel: expect EXACTLY 1/2 ===")
    print()
    print(f"{'bits':>5} {'B':>6} {'dim K':>6} {'samples':>8} {'nontriv':>8} "
          f"{'frac':>8} {'z vs 1/2':>10}")
    from math import erf, sqrt as msqrt
    for bits in (16, 18, 20):
        for B in (200, 400, 800):
            rng = random.Random(1000 + bits + B)
            p = rand_prime(bits, rng); q = rand_prime(bits, rng)
            while q == p:
                q = rand_prime(bits, rng)
            n = p * q
            r = run(n, B, int(isqrt(n) * 8), 400, rng)
            if r is None:
                print(f"{bits:5d} {B:6d}  -- too few relations --")
                continue
            nt, tot, dim = r
            if tot == 0:
                continue
            frac = nt / tot
            z = (nt - tot / 2) / msqrt(tot / 4)
            print(f"{bits:5d} {B:6d} {dim:6d} {tot:8d} {nt:8d} {frac:8.4f} "
                  f"{z:+10.2f}")


if __name__ == "__main__":
    main()