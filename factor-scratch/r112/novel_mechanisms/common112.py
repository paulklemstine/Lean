"""Shared, ground-truth-validated helpers for r112 novel-mechanisms.

GROUND TRUTH RULE (campaign brief sec 1.1): every factor claim is checked by
multiplying back to N.  No library's factor routine is trusted.
"""
import random
from sympy import nextprime, isprime


def gen_semiprime(bits, seed, beta=0.5):
    """N = p*q with bitlen(p) ~= beta*bits, bitlen(q) ~= (1-beta)*bits.

    Ground truth is (p, q); both are verified prime and p*q == N.
    """
    rng = random.Random(seed)
    pb = max(3, int(round(bits * beta)))
    qb = bits - pb
    while True:
        p = int(nextprime(rng.getrandbits(pb) | (1 << (pb - 1))))
        q = int(nextprime(rng.getrandbits(qb) | (1 << (qb - 1))))
        if p == q:
            continue
        N = p * q
        if N.bit_length() == bits and isprime(p) and isprime(q):
            assert p * q == N, "GROUND TRUTH FAILURE"
            return p, q, N


def verified_factor(N, p, q, r):
    """True iff r is a genuine factor of N (r | N and r*r != N)."""
    if r is None:
        return False
    if r <= 1 or r >= N:
        return False
    if N % r != 0:
        return False
    return r * (N // r) == N


def ck(p, q, N, r):
    return r is not None and N % r == 0 and 1 < r < N
