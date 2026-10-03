#!/usr/bin/env python3
"""
Fix for SELF-TEST 3: a 0% (degenerate) generator that scales to arbitrary N.

The old version tried to SEARCH for two primes with ord_p(2) = ord_q(2) = T
for one fixed T; that has density ~ phi(T)/(p-1), i.e. hopeless.

Construction (exact, not statistical):

  Pick a SMOOTH T with T+1 prime; put p := T+1, so ord_p(a) = p-1 = T for
  a generator a of F_p*.
  Pick any prime q with q = 1 (mod T).  Since F_q* is cyclic of order q-1 and
  T | (q-1), there EXISTS an element b of order exactly T.  Find it by taking
  b = c^{(q-1)/T} for random c -- succeeds with prob phi(T)/T, retried.
  CRT: g = a (mod p), g = b (mod q).

  Then ord_p(g) = T = ord_q(g), so lcm = T = ord_N(g), and every q-adic
  valuation agrees across the two primes.  By the theorem the descent MUST
  report DEGENERATE on every such instance.  Scale: take T = 2*3^k (smooth)
  with T+1 prime, and q a prime in [T*10^3, T*10^6], so N = p*q reaches
  10^12 .. 10^18 depending on k.
"""
import sympy
from sympy.ntheory import n_order, isprime


def element_of_order(q, T, rng):
    """b mod q with ord_q(b) == T, given T | q-1 and q prime."""
    assert (q - 1) % T == 0
    e = (q - 1) // T
    for _ in range(4000):
        c = rng.randrange(2, q)
        b = pow(c, e, q)
        if b != 1 and n_order(b, q) == T:
            return b
    return None


def crt(a, p, b, q):
    return (a + p * ((b - a) * pow(p, -1, q) % q)) % (p * q)


def build_degenerate(rng, kmin=3, kmax=8):
    """Returns (N, g, T) with ord_p(g) == ord_q(g) == T, T smooth."""
    for k in range(kmin, kmax + 1):
        T = 2 * 3 ** k
        p = T + 1
        if not isprime(p):
            continue
        a = sympy.primitive_root(p)
        lo, hi = T * 1000, T * 10 ** 6
        for _ in range(200):
            q = sympy.randprime(lo, hi)
            if q == p or (q - 1) % T:
                continue
            b = element_of_order(q, T, rng)
            if b is None:
                continue
            g = crt(a, p, b, q)
            N = p * q
            # verify the two orders really agree, from N alone
            assert n_order(g, N) == T, (n_order(g, N), T)
            return N, g, T
    return None


if __name__ == "__main__":
    import random
    rng = random.Random(20261003)
    for kmin, kmax in [(3, 5), (5, 7), (7, 10), (10, 14)]:
        r = build_degenerate(rng, kmin, kmax)
        if r is None:
            print(f"k in [{kmin},{kmax}]: no degenerate instance found")
            continue
        N, g, T = r
        print(f"k in [{kmin},{kmax}]: N = {N}  ({N.bit_length()} bits)  "
              f"T = ord(g) = {T} = {sympy.factorint(T)}")