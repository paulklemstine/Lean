"""Independent replication of the exp-568 outcome-separated ECM accounting.

Guarded affine elliptic-curve arithmetic mod N = p*q (Weierstrass, y^2 = x^3+ax+b),
true-lcm stage-1 schedule k(B1) = lcm(1..B1) accumulated prime by prime.  Each trial
is classified into {found_p, found_q, dead, nothing} by the gcd revealed at the first
non-invertible denominator.

Run: python3 ecm_wall_evidence.py
"""

import random
from math import gcd, isqrt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
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


def next_prime(n: int) -> int:
    while not is_prime(n):
        n += 1
    return n


def primes_upto(B: int):
    sieve = [True] * (B + 1)
    for i in range(2, isqrt(B) + 1):
        if sieve[i]:
            for j in range(i * i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]


class Blocked(Exception):
    def __init__(self, g):
        self.g = g


def inv_guarded(d, N):
    d %= N
    g = gcd(d, N)
    if g != 1:
        raise Blocked(g)
    return pow(d, -1, N)


def ec_add(P, Q, a, N):
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 % N == x2 % N:
        if (y1 + y2) % N == 0:
            return None
        lam = (3 * x1 * x1 + a) * inv_guarded(2 * y1, N) % N
    else:
        lam = (y2 - y1) * inv_guarded(x2 - x1, N) % N
    x3 = (lam * lam - x1 - x2) % N
    y3 = (lam * (x1 - x3) - y1) % N
    return (x3, y3)


def ec_mul(k, P, a, N):
    R = None
    Q = P
    while k:
        if k & 1:
            R = ec_add(R, Q, a, N)
        Q = ec_add(Q, Q, a, N)
        k >>= 1
    return R


def trial(p, q, B1, rng):
    """One curve; returns one of 'found_p', 'found_q', 'dead', 'nothing'."""
    N = p * q
    x0, y0, a = rng.randrange(N), rng.randrange(N), rng.randrange(N)
    b = (y0 * y0 - x0 * x0 * x0 - a * x0) % N
    if gcd(4 * a * a * a + 27 * b * b, N) != 1:
        return "skipped"
    P = (x0, y0)
    try:
        for r in primes_upto(max(B1, 2)):
            e = 1
            while r ** (e + 1) <= B1:
                e += 1
            P = ec_mul(r ** e, P, a, N)
            if P is None:
                # exact simultaneous vanishing mod p AND mod q: the only shape a
                # genuine "death" can take.
                return "dead"
    except Blocked as blk:
        g = blk.g
        if g == p:
            return "found_p"
        if g == q:
            return "found_q"
        if g == N:
            return "dead"
        return "nothing"
    return "nothing"


def main():
    rng = random.Random(20260827)
    print(f"{'p':>7} {'q':>9} {'B1/p':>6} {'B1':>7} "
          f"{'found_p':>8} {'found_q':>8} {'dead':>5} {'nothing':>8}"
          f" {'skipped':>8}")
    for p in (1009, 4001, 8191):
        q = next_prime(3 * p + rng.randrange(1, 200))
        for ratio in (0.125, 0.25, 0.5, 0.9, 1.05):
            B1 = max(2, int(ratio * p))
            counts = {"found_p": 0, "found_q": 0, "dead": 0, "nothing": 0,
                      "skipped": 0}
            for _ in range(40):
                counts[trial(p, q, B1, rng)] += 1
            print(f"{p:>7} {q:>9} {ratio:>6} {B1:>7} "
                  f"{counts['found_p']:>8} {counts['found_q']:>8} "
                  f"{counts['dead']:>5} {counts['nothing']:>8}"
                  f" {counts['skipped']:>8}")

    # Order-completion check underlying the Lean theorems: at B1 >= p+1+2*sqrt(p),
    # every integer in the Hasse window divides lcm(1..B1).
    from math import lcm
    for p in (13, 101, 1009):
        B1 = p + 1 + 2 * isqrt(p) + 2
        L = 1
        for n in range(1, B1 + 1):
            L = lcm(L, n)
        lo = max(1, p + 1 - 2 * isqrt(p) - 1)
        hi = p + 1 + 2 * isqrt(p) + 1
        ok = all(L % n == 0 for n in range(lo, hi + 1))
        print(f"p={p}: every Hasse-window order in [{lo},{hi}] divides lcm(1..{B1}): {ok}")


if __name__ == "__main__":
    main()
