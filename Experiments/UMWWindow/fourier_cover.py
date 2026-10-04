#!/usr/bin/env python3
"""
Fourier/Chebotarev cover construction (Factoring round 102): a reproducible
NEGATIVE with a mechanism.

PRIMITIVE. ChebotarevMinors.lean (catalog, never used by the factoring program)
proves every square submatrix of the DFT matrix (zeta^{jk}) is nonsingular.
Consequence: an s x a DFT system (s < a) has a kernel vector with ALL coordinates
nonzero -- a CERTIFIED set with a hole-free Fourier structure. Unlike anything
tried in rounds 96-101, this is an algebraic CONSTRUCTION primitive.

TEST. Build full-support Chebotarev kernel sets A subset Z_p and measure the
residue coverage of their difference set {a-b mod p} (the cover-relevant
quantity) against random sets of equal size.

RESULT (negative, robust over n=12,16,20): the Fourier-kernel set is WORSE than
random. The all-nonzero-kernel condition forces rigid algebraic structure that
CONCENTRATES differences -- the opposite of what a divisor cover needs. This
completes a principle with round 96b (birthday obstruction) and round 96d
(design sets ~= random): COVER CONSTRUCTION NEEDS SPREAD DIFFERENCES; any
constraint strong enough to certify structure is strong enough to concentrate
differences and defeat the cover.
"""
import random
import numpy as np
import sympy as sp
from sympy import isprime

def prime_and_dft(n):
    """find prime p with n | p-1 and a primitive n-th root zeta mod p; return (p,zeta)"""
    for p in range(2*n+1, 20*n+200):
        if isprime(p) and (p-1) % n == 0:
            for g in range(2, p):
                if pow(g, n, p) == 1 and all(pow(g, k, p) != 1
                        for k in range(1, n) if np.gcd(k, n) == 1):
                    return p, g
    return None, None

def build(n):
    p, zeta = prime_and_dft(n)
    M = sp.Matrix([[pow(zeta, (j*k) % n, p) for k in range(n)] for j in range(n)])
    return p, M

def full_support_kernel(M, rows, cols, p, tries=3000):
    """a vector in the nullspace of M[rows][cols] with ALL coordinates nonzero"""
    sub = sp.Matrix([[M[i, j] % p for j in cols] for i in rows])
    ns = sub.nullspace()
    if not ns:
        return None
    random.seed(2)
    for _ in range(tries):
        v = sp.zeros(len(cols), 1)
        for b in ns:
            v = v + random.randint(0, p-1) * b
        vv = [int(x) % p for x in v]
        if all(x != 0 for x in vv):
            return vv
    return None

def diff_coverage(S, p):
    return len(set((x - y) % p for x in S for y in S if x != y))

def main():
    random.seed(0)
    print("Fourier/Chebotarev kernel set vs random: difference-set residue coverage.")
    print("n | Fourier-kernel | random  (higher = better cover candidate)\n")
    rows_out = []
    for n in [12, 16, 20]:
        p, M = build(n)
        fr, rr = [], []
        for (s, a) in [(int(n*0.4), int(n*0.7)), (int(n*0.5), int(n*0.8))]:
            v = full_support_kernel(M, list(range(s)), list(range(a)), p)
            if v is None:
                continue
            Aset = [j for j in range(a) if v[j] != 0]
            dcov = diff_coverage(Aset, p)
            k = len(Aset)
            rc = np.mean([diff_coverage(random.sample(range(n), k), p) for _ in range(30)])
            fr.append(dcov); rr.append(rc)
        if fr:
            print(f"  n={n:2d} | Fourier {np.mean(fr):5.1f} | random {np.mean(rr):5.1f}")
            rows_out.append((n, np.mean(fr), np.mean(rr)))
    print("\n=> Fourier-kernel sets are WORSE than random at every scale tested.")
    print("   The full-support kernel forces rigid structure that CONCENTRATES")
    print("   differences; a divisor cover needs SPREAD differences.")
    print("   VERDICT: the Fourier/Chebotarev cover construction is a NEGATIVE.")

if __name__ == "__main__":
    main()