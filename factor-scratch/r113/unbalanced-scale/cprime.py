#!/usr/bin/env python3
"""Deterministic prime/semiprime generator with EXACT bit budgets.

Written from scratch (not reusing r110-r112 harnesses).  Every instance is
ground-truth verified by multiplying p*q back to N and by a probabilistic
primality test on each factor.
"""
import random
from sympy import isprime, nextprime, prevprime


def prime_with_bits(b, seed):
    """A prime p with EXACTLY b bits, deterministic in `seed`."""
    if b < 2:
        raise ValueError("b too small")
    lo = 1 << (b - 1)
    hi = (1 << b) - 1
    rnd = random.Random(seed)
    for _ in range(500):
        cand = rnd.randrange(lo, hi)
        cand = prevprime(cand)
        if cand.bit_length() == b:
            return cand
    raise RuntimeError("no %d-bit prime found" % b)


def make_semiprime(nb, pb, seed):
    """N = p*q with N exactly nb bits, p exactly pb bits, q exactly nb-pb bits."""
    p = prime_with_bits(pb, seed)
    q = prime_with_bits(nb - pb, seed + 7919)
    N = p * q
    # N can come out nb-1 bits.  Redraw q until N has exactly nb bits; a
    # single nudge is not enough when p sits near 2^(pb-1).
    import random as _rnd
    tries = 0
    while N.bit_length() != nb and tries < 400:
        tries += 1
        q = prime_with_bits(nb - pb, seed + 7919 + 104729 * tries)
        N = p * q
    assert N.bit_length() == nb, (N.bit_length(), nb, tries)
    assert p.bit_length() == pb and q.bit_length() == nb - pb
    assert p * q == N
    assert isprime(p) and isprime(q), "factors must be prime"
    return p, q, N
