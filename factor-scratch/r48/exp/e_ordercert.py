#!/usr/bin/env python3
"""
E1 -- THE ORDER-CERTIFICATE DESCENT.

THEOREM (proved in notes/F_rigorous.md).
Let N be composite, g a unit mod N, and suppose we are given a complete
factorization  M = prod q_i^{e_i}  of ord_N(g).
(a) The certificate is VERIFIABLE in poly(log N) time.
(b) In poly(log N) time, either we output a nontrivial factor of N, or we
    output a certificate that ord_r(g) is the SAME for every prime r | N.
(c) Hence: factoring N reduces in POLY-TIME to producing (g, factored order).
    Given the factored order, the factorization is essentially free.

Proof sketch. ord_N(g) = lcm(ord_p(g), ord_q(g)).  For each prime q_i | M,
  d_i = gcd(g^{M/q_i} - 1, N)
      = prod_{ r | N : ord_r(g) | M/q_i } r.
If the v_{q_i}-valuations of ord_p(g) and ord_q(g) differ, exactly one of
them divides M/q_i and d_i is a nontrivial factor.  If they agree for every
q_i then ord_p(g) = ord_q(g) and every d_i is 1 or N.  QED.

THE POINT: smoothness is needed ONLY to FIND (g, factored order).  The
factoring step given it is deterministic and polynomial.  That is the whole
content of the ECM / Pollard p-1 smoothness heuristic.

MEASUREMENTS
  E1a  success rate + cost of the descent on REAL random g  (must be 1.000;
       a random g splits unless ord_p(g)=ord_q(g), a measure-zero event).
  E1b  degenerate instances (ord_p = ord_q exactly) -- descent must certify,
       never split, never return a WRONG factor.
  E1c  cost law: time to obtain the order by trial division is ~B, and the
       descent itself is O(omega(M) * poly(log N)) -- measure it.
"""
import random
import sys
import time
import sympy
from sympy.ntheory import n_order

from fix_selftest3b import build as build_degenerate


def cert_verify(N, g, M, fac):
    """(a) poly(log N) verification of ord_N(g) == M with the given fac."""
    prod = 1
    for q, e in fac.items():
        if not sympy.isprime(q):
            return False
        prod *= q ** e
    if prod != M:
        return False
    if pow(g, M, N) != 1 % N:
        return False
    for q in fac:
        if pow(g, M // q, N) == 1 % N:
            return False
    return True


def descend(N, g, M, fac):
    """(b) the descent.  Returns (factor|None, reason)."""
    for q in fac:
        d = sympy.gcd(pow(g, M // q, N) - 1, N)
        if 1 < d < N:
            return int(d), f"split at q={q}"
    return None, "degenerate: ord_r(g) constant over r|N"


def e1a(n_trials=300):
    """Random g.  Predicted success 1.000 exactly (degenerate set is tiny)."""
    rng = random.Random(4242)
    split = 0
    wrong = 0
    steps = []
    t_desc = 0.0
    for _ in range(n_trials):
        p = sympy.randprime(10**20, 10**21)
        q = sympy.randprime(10**20, 10**21)
        if p == q:
            continue
        N = p * q
        g = rng.randrange(2, N - 1) | 1
        M = n_order(g, N)
        fac = sympy.factorint(M)
        assert cert_verify(N, g, M, fac)
        t0 = time.perf_counter()
        d, why = descend(N, g, M, fac)
        t_desc += time.perf_counter() - t0
        if d is not None:
            split += 1
            if N % d or not (1 < d < N):
                wrong += 1
            steps.append(len(fac))
    rate = split / n_trials
    # Wilson 95%
    z = 1.96
    p_ = rate
    den = 1 + z * z / n_trials
    c = (p_ + z * z / (2 * n_trials)) / den
    h = z * sympy.sqrt(p_ * (1 - p_) / n_trials + z * z / (4 * n_trials**2)) / den
    print(f"[E1a] random g, N~2^70, n={n_trials}")
    print(f"      descent split rate = {rate:.4f}  Wilson95 [{c-h:.4f}, {c+h:.4f}]")
    print(f"      WRONG factors returned = {wrong}   [must be 0]")
    print(f"      mean omega(M) (distinct primes in order) = "
          f"{sum(steps)/max(1,len(steps)):.2f}")
    print(f"      total descent CPU time for {n_trials} runs = {t_desc:.2f}s")
    return rate, wrong


def e1b():
    """Degenerate instances at scale.  Descent must certify, never split."""
    rng = random.Random(20261003)
    ok = bad = built = 0
    for T in [2**20*3**5, 2**30, 2**30*3**4, 2**36, 2**40*3**5, 2**48,
              2**54*3**3, 2**60, 2**64*3**2]:
        r = build_degenerate(T, rng)
        if r is None:
            continue
        N, g, T_, p, q = r
        built += 1
        fac = sympy.factorint(T_)
        assert cert_verify(N, g, T_, fac)
        d, why = descend(N, g, T_, fac)
        if d is None:
            ok += 1
        else:
            bad += 1
            print(f"      !! SPLIT a degenerate instance N={N}: {why}")
        print(f"      N={N.bit_length():3d}b  ord={T_.bit_length():2d}b  "
              f"{why}")
    print(f"[E1b] degenerate instances: built={built} certified={ok} "
          f"WRONGLY-SPLIT={bad}  [bad must be 0]")
    return ok, bad


def e1c():
    """(c) cost accounting: descent cost vs omega(M), and the O(B) to FIND M."""
    rng = random.Random(777)
    print("[E1c] descent cost vs omega(M)  (predicts linear in omega(M))")
    rows = []
    for target in [4, 8, 16, 32, 64]:
        # build g of order = product of `target` distinct primes
        while True:
            qs = []
            cand = sympy.prime(200)
            while len(qs) < target:
                if sympy.isprime(cand) and cand > 10**6:
                    qs.append(cand)
                cand = sympy.nextprime(cand)
            M = 1
            for q in qs:
                M *= q
            p = sympy.randprime(10**30, 10**31)
            q2 = sympy.randprime(10**30, 10**31)
            N = p * q2
            # CRT g with order M mod p and order 1 mod q2  -> ord_N(g)=M
            a = _elem_order(p, M, rng)
            if a is None:
                continue
            g = (a + p * ((1 - a) * pow(p, -1, q2) % q2)) % N
            if n_order(g, N) == M:
                break
        fac = sympy.factorint(M)
        assert cert_verify(N, g, M, fac)
        t0 = time.perf_counter()
        d, why = descend(N, g, M, fac)
        dt = time.perf_counter() - t0
        assert d is not None and N % d == 0
        rows.append((len(fac), dt))
        print(f"      omega(M)={len(fac):3d}  M={M.bit_length():4d}b  "
              f"descent={dt*1e3:8.3f} ms  -> {why}")
    print("      (each extra distinct prime factor costs one exponentiation)")


def _elem_order(r, T, rng, tries=3000):
    if (r - 1) % T:
        return None
    e = (r - 1) // T
    for _ in range(tries):
        c = rng.randrange(2, r)
        b = pow(c, e, r)
        if b != 1 and n_order(b, r) == T:
            return b
    return None


def e1d():
    """(d) THE PROMISE IS CHECKABLE.  Time the verifier at scale."""
    import timeit
    print("[E1d] certificate-verification cost (must be poly in log N)")
    rng = random.Random(31337)
    for bits in [64, 128, 256, 512]:
        p = sympy.randprime(10**(bits // 2 - 1), 10**(bits // 2))
        q = sympy.randprime(10**(bits // 2 - 1), 10**(bits // 2))
        if p == q:
            continue
        N = p * q
        g = rng.randrange(2, N - 1) | 1
        M = n_order(g, N)
        fac = sympy.factorint(M)
        dt = timeit.timeit(lambda: cert_verify(N, g, M, fac), number=5) / 5
        print(f"      N={bits} bits  M={M.bit_length()} bits  "
              f"omega(M)={len(fac)}  verify={dt*1e3:8.3f} ms")


if __name__ == "__main__":
    e1a()
    print()
    e1b()
    print()
    e1c()
    print()
    e1d()