"""
Does the class-group (continued-fraction / SQUOF) walk beat L[1/2]? -- the decisive number.

THE CLAIM UNDER TEST (E-6/E-7/E-8 thread, "an ECM-independent L[1/2] method via
lotteries in Cl(Q(sqrt(D)))"). The thread's own preregistered hypothesis H1 says the
mechanism is structurally dead: for D = k*N with p | D, the forms of discriminant
D == 0 (mod p) compose into a group of order EXACTLY p. An order that is exactly p
admits no smoothness lottery -- there is nothing to select -- so the walk pays the
full birthday cost sqrt(p).

WHY THAT KILLS THE THREAD. ECM's entire exponent advantage comes from the smoothness
lottery over a group order m that is a random number: exp(sqrt(ln p * ln ln p)).
A group of order exactly p forces sqrt(p) steps. For balanced N = pq those differ by
orders of magnitude -- sqrt(p) = N^(1/4) versus L[1/2].

THE MEASUREMENT. Classical: if p | N then in the CF expansion of sqrt(N) there are
i < j < 2p with m_i == m_j (mod p). So the walk's first modular repeat occurs at
~sqrt(p) by birthday. This script measures that directly.

[p IS USED] to label the residues m_i mod p and to detect the collision. That is a
MEASUREMENT INSTRUMENT ONLY. A run of this walk that actually extracted a factor
would not need p; the number reported here is a property of the walk's period, not
of a factoring procedure, and the extraction step is deliberately NOT implemented,
because implementing it would risk conflating "found the collision" with "factored".
"""

from __future__ import annotations

import math
import random
import time


def cf_m_sequence(N: int, maxterms: int):
    """Yield m_k for the continued fraction of sqrt(N). Exact integer arithmetic.

    Standard recurrence (a_0 = floor(sqrt N)):
        m_{k+1} = d_k*a_k - m_k
        d_{k+1} = (N - m_{k+1}^2) / d_k
        a_{k+1} = floor((a_0 + m_{k+1}) / d_{k+1})
    """
    a0 = math.isqrt(N)
    if a0 * a0 == N:
        raise ValueError("perfect square")
    m, d, a = 0, 1, a0
    for _ in range(maxterms):
        m = d * a - m
        nd = (N - m * m) // d
        a = (a0 + m) // nd
        d = nd
        yield m, d, a


def first_modular_repeat(N: int, p: int, maxterms: int) -> int:
    """First k at which m_k repeats a previous residue mod p. [uses p]"""
    seen: dict[int, int] = {}
    for k, (m, _d, _a) in enumerate(cf_m_sequence(N, maxterms)):
        r = m % p
        if r in seen:
            return k
        seen[r] = k
    return -1


def selftest() -> bool:
    ok = True

    print("SELFTEST 1: CF recurrence reconstructs sqrt(N)")
    for N in (23, 101, 1009, 65537):
        terms = [a for (_m, _d, a) in cf_m_sequence(N, 30)]
        # a_0 = floor(sqrt(N)) is prepended to the generated a_1, a_2, ...
        seq = [math.isqrt(N)] + terms
        # Rebuild the value from the first 25 partial quotients.
        p_nm2, p_nm1 = 0, 1
        q_nm2, q_nm1 = 1, 0
        for a in seq[:25]:
            p = a * p_nm1 + p_nm2
            q = a * q_nm1 + q_nm2
            p_nm2, p_nm1 = p_nm1, p
            q_nm2, q_nm1 = q_nm1, q
        err = abs(p_nm1 / q_nm1 - math.sqrt(N))
        if err > 1e-9:
            print(f"  [FAIL] N={N} convergent err={err:.3e}")
            ok = False
        else:
            print(f"  [PASS] N={N} convergent err={err:.3e}")

    print("SELFTEST 2: sqrt(23) has a_0 = 4")
    a0 = math.isqrt(23)
    if a0 != 4:
        print(f"  [FAIL] a0={a0}")
        ok = False
    else:
        print("  [PASS] a0=4")

    print("SELFTEST 3: the repeat detector finds a collision for a KNOWN factor")
    # 1000003 * 1000033
    p, q = 1000003, 1000033
    N = p * q
    k = first_modular_repeat(N, min(p, q), maxterms=4_000_000)
    sqp = math.isqrt(min(p, q))
    if k < 0:
        print("  [FAIL] no collision found (harness cannot detect the phenomenon)")
        ok = False
    else:
        print(f"  [PASS] first repeat at k={k}, sqrt(p)={sqp}, ratio={k/sqp:.3f}")

    print("SELFTEST 4: negative control -- a prime N has NO small factor, so a")
    print("  collision mod a large prime p should NOT appear within ~sqrt(p).")
    P = 1000003  # prime
    k2 = first_modular_repeat(P, P, maxterms=200_000)
    if k2 >= 0:
        print(f"  [FAIL] collision found at k={k2} for prime modulus (should be rare)")
        ok = False
    else:
        print("  [PASS] no collision within 200000 terms, as expected")

    print()
    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


def ecm_L_half_cost(pbits: int) -> float:
    """ECM cost in the same 'steps' unit: L[1/2] = exp(sqrt(ln p ln ln p))."""
    lp = pbits * math.log(2)
    return math.exp(math.sqrt(lp * math.log(lp)))


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 78)
    print("MEASUREMENT: first modular repeat in sqrt(N) vs sqrt(p), and vs L[1/2]")
    print("=" * 78)
    rng = random.Random(20261003)
    print(f"{'pbits':>5} {'N':>24} {'repeat k':>9} {'sqrt(p)':>9} "
          f"{'L[1/2]':>11} {'k/L[1/2]':>10}")

    for pbits in (14, 16, 18, 20, 22):
        rows = []
        for _trial in range(4):
            p = rng.getrandbits(pbits) | (1 << (pbits - 1)) | 1
            q = rng.getrandbits(pbits) | (1 << (pbits - 1)) | 1
            while q == p:
                q = rng.getrandbits(pbits) | (1 << (pbits - 1)) | 1
            N = p * q
            small = min(p, q)
            k = first_modular_repeat(N, small, maxterms=6_000_000)
            if k < 0:
                continue
            sqp = math.sqrt(small)
            L = ecm_L_half_cost(pbits)
            rows.append((k, sqp, L))
            print(f"{pbits:5d} {N:24d} {k:9d} {sqp:9.0f} {L:11.0f} {k/L:10.1f}")
        if rows:
            rk = sorted(r[0] for r in rows)[len(rows) // 2]
            sqp = sorted(r[1] for r in rows)[len(rows) // 2]
            L = sorted(r[2] for r in rows)[len(rows) // 2]
            print(f"  -> median: k/sqrt(p) = {rk/sqp:.3f}  "
                  f"(birthday predicts ~sqrt(pi/8)={math.sqrt(math.pi/8):.3f})"
                  f"   k/L[1/2] = {rk/L:.1f}x")
    print()
    print("INTERPRETATION RULE, preregistered:")
    print("  k ~ sqrt(p)  => walk cost = sqrt(p) = N^(1/4). No lottery is available,")
    print("                  because the relevant group has order exactly p.")
    print("  k/L[1/2] >> 1 => the class-group walk is far MORE expensive than ECM, so")
    print("                  it is not an ECM-independent L[1/2] method. THREAD DEAD.")


if __name__ == "__main__":
    main()