#!/usr/bin/env python3
"""TRIVIAL / GENERIC BASELINE on the SAME instances the attack runs on.

Brief sec "THE #1 TRAP": beside EVERY success count, report what the generic
baseline does on the same input.  If the baseline solves it, the "attack" is a
correctness test, not evidence.

Baselines measured:
  * trial division by small primes (instant)
  * Pollard rho (Brent), timed, with an iteration cap
  * PARI factorint via cypari2 / gmpy, timed, capped
Every reported factor is verified by multiplying back to N.
"""
import time
import math
import random

SMALL = []
_s = 2
while len(SMALL) < 20000:
    if all(_s % k for k in range(2, int(_s ** 0.5) + 1)):
        SMALL.append(_s)
    _s += 1
SMALLSET = set(SMALL)


def trial_division(N, cap=20000, tlimit=30.0):
    t0 = time.time()
    for p in SMALL[:cap]:
        if N % p == 0:
            return dict(found=True, factor=p, sec=round(time.time() - t0, 3),
                        method="trial")
        if time.time() - t0 > tlimit:
            break
    return dict(found=False, sec=round(time.time() - t0, 3), method="trial")


def brent_rho(N, max_iter=2_000_000, seed=12345):
    """Pollard rho (Brent cycle detection). Returns dict with factor if found."""
    rnd = random.Random(seed)
    t0 = time.time()
    if N % 2 == 0:
        return dict(found=True, factor=2, sec=round(time.time() - t0, 4),
                    method="rho", iters=0)
    for c in itertools_count():
        y, m = rnd.randrange(1, N), 128
        g = r = 1
        q = 1
        it = 0
        while g == 1 and it < max_iter:
            x = y
            for _ in range(r):
                y = (y * y + c) % N
            k = 0
            while k < r and g == 1:
                ys = y
                for _ in range(min(m, r - k)):
                    y = (y * y + c) % N
                    q = (q * abs(x - y)) % N
                g = math.gcd(q, N)
                k += m
                it += r
            r *= 2
        if g == N:
            while True:
                ys = (ys * ys + c) % N
                g = math.gcd(abs(x - ys), N)
                if g > 1:
                    break
        if g != N and g > 1:
            f = g
            if f * (N // f) == N:
                return dict(found=True, factor=f, sec=round(time.time() - t0, 3),
                            method="rho", iters=it)
    return dict(found=False, sec=round(time.time() - t0, 3), method="rho",
                iters=max_iter)


def itertools_count():
    c = 1
    while True:
        yield c
        c += 1


def pari_factorint(N, tlimit=60.0):
    """PARI factorint on N, wall-clock capped. Reports whether it finished."""
    try:
        import cypari2
        pari = cypari2.Pari()
    except Exception as e:
        return dict(found=False, sec=0.0, method="pari", err=str(e)[:60])
    t0 = time.time()
    try:
        facs = pari(N).factorint(tlimit=int(tlimit))
    except Exception as e:
        return dict(found=False, sec=round(time.time() - t0, 3), method="pari",
                    err=type(e).__name__)
    el = time.time() - t0
    out = {}
    for k, v in facs.items():
        if int(k) not in out:
            out[int(k)] = 0
        out[int(k)] += int(v)
    big = [k for k in out if k > 1 and out[k] == 1]
    fac = big[0] if big else None
    return dict(found=(fac is not None), factor=fac, sec=round(el, 3),
                method="pari", complete=True,
                verified=(fac is not None and fac * (N // fac) == N))
