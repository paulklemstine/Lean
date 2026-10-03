#!/usr/bin/env python3
"""
Degenerate-instance generator, scale-correct version.

Fix a SMOOTH T.  Search k*T+1 for two distinct primes p, q (so T | p-1 and
T | q-1, hence F_p* and F_q* both contain elements of order exactly T).
Pick a of order T mod p, b of order T mod q, CRT them into g mod N = p*q.
Then ord_p(g) = ord_q(g) = T exactly, so the descent MUST certify
DEGENERATE.  N ~ T^2, so T = 2^30 gives a 60-bit N.

We do NOT need p = T+1.  p just has to be 1 mod T.
"""
import sympy
from sympy.ntheory import n_order, isprime


def primes_1modT(T, kmax=4000):
    out = []
    for k in range(1, kmax):
        c = k * T + 1
        if isprime(c):
            out.append(c)
            if len(out) >= 4:
                break
    return out


def elem_of_order(r, T, rng, tries=2000):
    e = (r - 1) // T
    for _ in range(tries):
        c = rng.randrange(2, r)
        b = pow(c, e, r)
        if b != 1 and n_order(b, r) == T:
            return b
    return None


def build(T, rng):
    ps = primes_1modT(T)
    if len(ps) < 2:
        return None
    p, q = ps[0], ps[1]
    a = elem_of_order(p, T, rng)
    b = elem_of_order(q, T, rng)
    if a is None or b is None:
        return None
    N = p * q
    g = (a + p * ((b - a) * pow(p, -1, q) % q)) % N
    assert n_order(g, N) == T
    return N, g, T, p, q


if __name__ == "__main__":
    import random
    rng = random.Random(20261003)
    for T in [2 ** 20 * 3 ** 5, 2 ** 30, 2 ** 30 * 3 ** 4, 2 ** 36,
              2 ** 40 * 3 ** 5, 2 ** 48, 2 ** 54 * 3 ** 3]:
        r = build(T, rng)
        if r is None:
            print(f"T={T} ({T.bit_length()}b): none")
            continue
        N, g, T_, p, q = r
        print(f"T = {T_} ({T_.bit_length()}b, {sympy.factorint(T_)})  "
              f"N = {N} ({N.bit_length()}b)")