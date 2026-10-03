#!/usr/bin/env python3
"""
E2 -- the theorem on NON-SQUAREFREE N, where ord_{r^f}(g) != ord_r(g).

This is the case the naive proof gets wrong.  If N = p^2 q and
ord_{p^2}(g) = p * ord_p(g), then ord_N(g) = lcm(p*ord_p g, ord_q g) which
is NOT lcm(ord_p g, ord_q g).  The theorem as stated (with prime-POWER
orders) must still hold and must still never return a wrong factor.

Also checks the degenerate case on non-squarefree N.

Self-test carried forward from selftest_ordercert.py:
  * honest certificate verifies;
  * a certificate for the WRONG order is rejected;
  * descent on a forced-split instance always returns a divisor of N.
"""
import random
import sympy
from sympy.ntheory import n_order

from e_ordercert import cert_verify, descend


def rand_unit(rng, m):
    while True:
        x = rng.randrange(2, m - 1)
        if sympy.gcd(x, m) == 1:
            return x


def main():
    rng = random.Random(5150)

    print("=" * 72)
    print("E2a: N = p^2 * q  (non-squarefree).  Descent must split, never lie.")
    split = wrong = 0
    for _ in range(60):
        p = sympy.randprime(10**12, 10**13)
        q = sympy.randprime(10**12, 10**13)
        if p == q:
            continue
        N = p * p * q
        g = rand_unit(rng, N)
        M = n_order(g, N)
        fac = sympy.factorint(M)
        assert cert_verify(N, g, M, fac), "certificate failed to verify"
        d, why = descend(N, g, M, fac)
        if d is not None:
            split += 1
            if not (1 < d < N and N % d == 0):
                wrong += 1
                print(f"      !! WRONG ANSWER d={d} N={N}")
        # record whether the prime-power blowup actually happened
        if _ < 3:
            o_p2 = n_order(g, p * p)
            o_p = n_order(g, p)
            print(f"      N has {N.bit_length()}b, p={p}, "
                  f"ord_(p^2)={o_p2}, ord_p={o_p}, "
                  f"{'BLOWUP (p^{%d})' % sympy.gcd(o_p2, p) if o_p2 != o_p else 'same'}"
                  f", ord_N has p? {p in fac}")
    print(f"      split {split}/60, wrong {wrong}  [wrong must be 0]")
    assert wrong == 0

    print("=" * 72)
    print("E2b: N = p^k * q for k = 2..6")
    for k in range(2, 7):
        p = sympy.randprime(10**7, 10**8)
        q = sympy.randprime(10**7, 10**8)
        if p == q:
            continue
        N = p ** k * q
        g = rand_unit(rng, N)
        M = n_order(g, N)
        fac = sympy.factorint(M)
        ok = cert_verify(N, g, M, fac)
        d, why = descend(N, g, M, fac)
        good = (d is not None and 1 < d < N and N % d == 0)
        print(f"      k={k}  N={N.bit_length():3d}b  cert_ok={ok}  "
              f"-> {'factor' if good else 'DEGENERATE'}   p^e in ord? "
              f"v_p(M)={fac.get(p,0)} (>= {k-1} iff blowup)")

    print("=" * 72)
    print("E2c: DEGENERATE on non-squarefree N -- certify, never split.")
    # force ord_p(g) == ord_q(g) == T, then take N = p^2 * q
    from fix_selftest3b import primes_1modT, elem_of_order
    T = 2 ** 24 * 3 ** 3
    ps = primes_1modT(T, kmax=8000)
    built = 0
    if len(ps) >= 2:
        p, q = ps[0], ps[1]
        a = elem_of_order(p, T, rng)
        b = elem_of_order(q, T, rng)
        if a is not None and b is not None:
            # g ≡ a mod p^2 requires ord = T | p(p-1) -- use CRT mod p^2, q
            # simplest: choose g ≡ a mod p, g ≡ b mod q, then lift mod p^2
            g0 = (a + p * ((b - a) * pow(p, -1, q) % q)) % (p * q)
            # lift: g0 + p*q*t  choose t so g mod p^2 still has order dividing T
            for t in range(p):
                g = (g0 + p * q * t) % (p * p * q)
                if pow(g, T, p * p * q) == 1 % (p * p * q):
                    break
            N = p * p * q
            M = n_order(g, N)
            fac = sympy.factorint(M)
            ok = cert_verify(N, g, M, fac)
            d, why = descend(N, g, M, fac)
            print(f"      N = p^2*q, {N.bit_length()}b, ord_N(g)={M}, "
                  f"cert_ok={ok}")
            print(f"      descent -> {why}")
            print(f"      split={d is not None}  [for a degenerate ord this must "
                  f"be False OR d must divide N]")
            if d is not None:
                assert 1 < d < N and N % d == 0
            built += 1
    if not built:
        print("      (no instance built in budget)")

    print("=" * 72)
    print("E2d: control -- a certificate for the WRONG order is rejected")
    p = sympy.randprime(10**12, 10**13)
    q = sympy.randprime(10**12, 10**13)
    N = p * p * q
    g = rand_unit(rng, N)
    M = n_order(g, N)
    fac = sympy.factorint(M)
    Mb = M
    for qq in list(fac):
        if fac[qq] >= 2:
            Mb = M // qq
            break
        else:
            Mb = M // qq
            break
    print(f"      verifying claim ord_N(g) = {M} (true)  ->",
          cert_verify(N, g, M, fac), " [must be True]")
    print(f"      verifying claim ord_N(g) = {Mb} (false) ->",
          cert_verify(N, g, Mb, sympy.factorint(Mb)),
          " [must be False]")


if __name__ == "__main__":
    main()