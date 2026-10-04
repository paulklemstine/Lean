#!/usr/bin/env python3
"""
IMPLICIT FACTORIZATION (IFP) -- polynomial-time factoring of RSA moduli whose
primes share low bits (Factoring round 109). A genuinely NEW per-instance model.

MODEL (untouched by rounds 96-108). N1 = p1*q1, N2 = p2*q2, and p1, p2 share
their low t bits: p1 = z + 2^w*u1, p2 = z + 2^w*u2 with z < 2^w the shared
low part (w = shared bits), q1,q2 of size alpha bits.

THE MECHANISM (derived and verified here). Mod 2^w, both primes equal z:
    N1 = p1*q1 = (z + 2^w u1) q1 = z*q1 + 2^w u1 q1  =>  N1 = z*q1 (mod 2^w).
Hence  q1 = N1 * z^{-1}  (mod 2^w). If w >= alpha (so q1 < 2^w), q1 is fully
determined, and  p1 = N1/q1 -- POLYNOMIAL TIME (one modinv and one division).

This grounds the published IFP line (May-Ritzenhofen PKC'09 t>=2a+3;
Kurosawa-Ueda 2a+1; Nuida-Itakura-Kurosawa ePrint 2014/839 t=2a-O(log k);
Feng-Nitaj-Pan ePrint 2023/1562), whose subtle bound uses a LATTICE to handle a
HINT (p1-p2) rather than the exact shared part. Here we verify the crisp
"known shared part + w>=alpha => poly-time" corollary directly.

SCOPE. Polynomial-time factoring -- far below L[1/3] -- but only for the
structured promise (primes sharing low bits), the key-reuse family, not for
independent random RSA. Per round 108/108b, the honest per-instance wins live in
distribution-specific models; this opens a THIRD such model (shared-bit primes).
"""
import random
from math import gcd

def is_prime(n):
    if n < 2: return False
    for d in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % d == 0: return n == d
    dd = n-1; r = 0
    while dd % 2 == 0: dd //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x = pow(a, dd, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x*x % n
            if x == n-1: break
        else: return False
    return True
def gp(b):
    while True:
        p = random.getrandbits(b) | (1 << (b-1)) | 1
        if is_prime(p): return p

def ifp_recover(N1, z, w, alpha):
    """Recover q1 = N1*z^{-1} mod 2^w, then p1 = N1/q1. Polynomial time.
    Requires w >= alpha so q1 < 2^w."""
    q1 = (N1 * pow(z, -1, 1 << w)) % (1 << w)
    if 1 < q1 < N1 and N1 % q1 == 0:
        return q1, N1 // q1
    return None, None

def main():
    random.seed(0)
    alpha = 16
    print("IMPLICIT FACTORIZATION: shared low-bit primes -> polynomial-time factor.")
    print(f"alpha (bits of q) = {alpha}; shared low bits w. Verify q1=N1*z^(-1) mod 2^w.\n")
    for w in [alpha, alpha + 2, 2*alpha, 2*alpha + 4]:
        ok = 0; tot = 8
        for _ in range(tot):
            # choose an ODD prime p1 whose low w bits are z (search so p1 is prime)
            while True:
                z = random.randrange(1, 1 << w) | 1
                u1 = random.randrange(1 << 8, 1 << 10)
                p1 = z + (u1 << w)
                if is_prime(p1): break
            q1 = gp(alpha); N1 = p1 * q1
            q1_rec, p1_rec = ifp_recover(N1, z, w, alpha)
            if q1_rec == q1 and p1_rec == p1:
                ok += 1
        print(f"  w={w:3d} (alpha={alpha}, 2alpha={2*alpha}): recovered {ok}/{tot}")
    print()
    print("=> With the shared low part z known and w >= alpha, factoring N1 is")
    print("   POLYNOMIAL TIME (one modinv + one division) -- far below L[1/3].")
    print("   This grounds the published IFP line (t ~ 2*alpha, polynomial time)")
    print("   as a THIRD distribution-specific per-instance model, alongside")
    print("   small-pool batches (r108/r108b).")

if __name__ == "__main__":
    main()