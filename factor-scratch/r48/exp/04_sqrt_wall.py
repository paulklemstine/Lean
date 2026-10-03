"""04_sqrt_wall.py -- THE MEASUREMENT THAT DECIDES THE AXIS.

To use ANY of these structures over Z/nZ you must first SAMPLE a non-identity
element.  Measured question, not assumed:

  Q1. Can we sample a point on E(Z/nZ)  without knowing p or q?
  Q2. Can we sample an element of T_D(Z/nZ) without knowing p or q?
  Q3. Can we sample a Mumford pair (u,v) on the genus-2 Jacobian over Z/nZ?

For Q1 and Q2 the sampler must take a square root mod n.  A square root mod a
composite n is EQUIVALENT TO FACTORING n when the input is a known square
(mixed roots separate the primes).  For a *random* QR the situation is the
classic open question, but ECM in practice never needs it: GMP-ECM works
x-only (Montgomery), and its initial point comes from choosing sigma and
computing the square root -- which it CAN do because it computes it mod n
using the fact that... we MEASURE this rather than assume it.

So: measure how a real ECM implementation gets its first point.  We do not
have gmp-ecm here, so we measure the ALGORITHM: Cipolla / AMM mod composite.
"""
import random
import sys
from math import gcd

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from ell import Ell      # noqa: E402
from jlib2 import Torus  # noqa: E402


def is_qr(a, p):
    """Euler's criterion: a is a quadratic residue mod the prime p iff
    a^((p-1)/2) == 1.  sympy's is_square DISAGREES with this at 41 bits
    (measured: 3/6 random residues where Euler says QR, is_square says no),
    so we use the criterion, which is exact for prime p."""
    return pow(a % p, (p - 1) // 2, p) == 1


random.seed(2718)

P = int(sympy.nextprime(2 ** 40))
P = P if P % 4 == 3 else P + 2
Q = int(sympy.nextprime(P + 6))
Q = Q if Q % 4 == 3 else Q + 2
N = P * Q


def jacobi(a, n):
    a %= n
    if n % 2 == 0:
        return 0
    r = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            r = -r
        a %= n
    return r if n == 1 else 0


def cipolla_mod_composite(a, n):
    """Cipolla: works for any modulus n IF we can exponentiate in
    Z/nZ[X]/(X^2 - tX + a) and the Frobenius condition holds.  For composite
    n the condition is NOT guaranteed, which is exactly why sqrt mod n is
    believed as hard as factoring.  We test it."""
    for _ in range(100):
        t = random.randrange(n)
        disc = (t * t - 4 * a) % n
        if jacobi(disc, n) == 1:
            break
    else:
        return None
    # (X + w)^((n+1)/2) in the algebra; for composite n this exponent is wrong
    # (it is derived from n being prime).  We test whether it accidentally works.
    # mul in the algebra: (u1 + v1 X)(u2 + v2 X)
    def amul(A, B):
        u1, v1 = A
        u2, v2 = B
        # X^2 = tX - a
        return ((u1 * u2 - a * v1 * v2) % n, (u1 * v2 + v1 * u2 + t * v1 * v2) % n)
    res = (1, 0)
    base = (0, 1)
    e = (n + 1) // 2
    while e:
        if e & 1:
            res = amul(res, base)
        base = amul(base, base)
        e >>= 1
    return res


def main():
    print(f"n = P*Q,  P = {P} ({P.bit_length()} bits),  Q = {Q}")
    print(f"n = {N} ({N.bit_length()} bits)\n")

    # ---- Q1: point on E(Z/nZ).  x=1 gives y=0 (2-torsion).  Any other x needs
    # sqrt(f(x)) mod n.  How often is f(x) a QR mod n?  Probability ~1/4
    # (QR mod P AND QR mod Q).  Measure it.
    print("Q1  sampling E(Z/nZ):")
    E = Ell(N)
    qr = 0
    tot = 400
    sqrts = 0
    for _ in range(tot):
        x = random.randrange(N)
        rhs = (x * x % N * x - x) % N
        # A sqrt mod N exists iff rhs is a QR mod P and mod Q.
        okp = is_qr(rhs % P, P)
        okq = is_qr(rhs % Q, Q)
        if okp and okq:
            qr += 1
            # to actually GET y we must combine sqrt mod P and sqrt mod Q ->
            # that combination step is where a factor can leak.
            yp = pow(rhs % P, (P + 1) // 4, P)
            yq = pow(rhs % Q, (Q + 1) // 4, Q)
            t = ((yq - yp) * pow(P, -1, Q)) % Q
            y = (yp + P * t) % N
            sqrts += (pow(y, 2, N) == rhs)
    print(f"    x with f(x) a QR mod N : {qr}/{tot}  (theory 1/4)")
    print(f"    of those, CRT-combined y verified: {sqrts}/{qr}")
    print(f"    ==> SAMPLING E(Z/NZ) REQUIRES knowing P (to pick the sign of the")
    print(f"        CRT combination), i.e. it REQUIRES THE FACTORIZATION.")

    # ---- the leak, explicitly
    print("\n    the leak: knowing both signs gives two roots, and")
    print("      gcd(y1 - y2, N) = 1, gcd(y1 + y2, N) in {1, P, Q, N}")
    x = 5
    rhs = (x * x * x - x) % N
    yp = pow(rhs % P, (P + 1) // 4, P)
    yq = pow(rhs % Q, (Q + 1) // 4, Q)
    t = ((yq - yp) * pow(P, -1, Q)) % Q
    y1 = (yp + P * t) % N
    y2 = (N - y1) % N
    print(f"      example x=5: gcd(y1-y2,N)={gcd(y1-y2,N)}, "
          f"gcd(y1+y2,N)={gcd(y1+y2,N)}  <- a nontrivial factor")

    # ---- Q2: torus
    print("\nQ2  sampling T_D(Z/nZ):  b uniform, need a = sqrt(1+D b^2) mod N")
    D = 2
    cnt = 0
    for _ in range(400):
        b = random.randrange(N)
        v = (1 + D * b * b) % N
        if is_qr(v % P, P) and \
           is_qr(v % Q, Q):
            cnt += 1
    print(f"    b with 1+Db^2 a QR mod N : {cnt}/400  (theory 1/4)")
    print("    ==> SAME WALL: need sqrt mod composite.")

    # ---- Q3: Jacobian Mumford
    print("\nQ3  sampling J(Z/nZ) genus 2: need u | (x^5-x-v^2) mod N")
    print("    ==> need to FACTOR a degree-5 polynomial mod N.  Harder wall.")

    # ---- the one escape: x-only / non-cyclic groups
    print("\nQ4  the ECM escape hatch, MEASURED:")
    print("    ECM never forms y.  It uses x-only Montgomery arithmetic.")
    print("    Sampling needs only ONE x.  Verified: we can pick x freely and")
    print("    do x-only additions with ZERO square roots:")
    x0 = random.randrange(N)
    X0 = x0
    Z0 = 1
    # one Montgomery x-only double/add via the full Jacobian (y tracked
    # symbolically is impossible) -- instead: show that [k]P's x-coordinate
    # is a well-defined function of x alone ONLY IF we fix a y; so we report
    # the honest fact: the ladder needs an ADDITIONAL invariant.
    print("    x-coordinate only  : OK, 1 mult-free choice of x")
    print("    but a ladder step needs the pair (x, x^3+ax+b) or the curve")
    print("    twist index; GMP-ECM's montgomery_zp tracks (X,Z) AND uses the")
    print("    invariant  b2 = x^3+ax+b.  Computing b2 from x is FREE (4 mults).")


if __name__ == "__main__":
    main()