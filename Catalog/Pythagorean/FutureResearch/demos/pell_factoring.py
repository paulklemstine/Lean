#!/usr/bin/env python3
"""
Pell Sequence Factoring Demo
=============================
Demonstrates the connection between Pell sequences, Berggren tree ancestry,
and integer factoring (Williams' p+1 method via Pythagorean triples).

Key idea: For N = p*q, the Pell sequence P_G satisfies P_{T(p)} ≡ 0 (mod p),
where T(p) is the Pell rank of p. If T(p) is smooth, we can find gcd(P_G, N) > 1.
"""

import math
from typing import Optional, Tuple, List

# ============================================================
# Section 1: Pell Sequence Computations
# ============================================================

def pell_sequences(n: int, mod: Optional[int] = None) -> Tuple[int, int]:
    """Compute (H_n, P_n) - half-companion and Pell numbers.
    H(0)=1, H(1)=1, H(n+2) = 2*H(n+1) + H(n)
    P(0)=0, P(1)=1, P(n+2) = 2*P(n+1) + P(n)
    """
    if n == 0:
        return (1, 0)
    H_prev, H_curr = 1, 1
    P_prev, P_curr = 0, 1
    for _ in range(n - 1):
        H_prev, H_curr = H_curr, 2 * H_curr + H_prev
        P_prev, P_curr = P_curr, 2 * P_curr + P_prev
        if mod:
            H_prev %= mod
            H_curr %= mod
            P_prev %= mod
            P_curr %= mod
    return (H_curr, P_curr)


def pell_fast_doubling(n: int, mod: int) -> Tuple[int, int]:
    """Compute (H_n mod m, P_n mod m) in O(log n) using doubling formulas:
    P(2k) = 2*P(k)*H(k)
    H(2k) = 2*H(k)^2 - (-1)^k
    """
    if n == 0:
        return (1 % mod, 0)
    if n == 1:
        return (1 % mod, 1 % mod)

    # Use binary representation of n
    bits = bin(n)[2:]  # binary string
    H, P = 1, 0  # H_0, P_0
    sign = 1  # (-1)^0 = 1

    for bit in bits:
        # Double: compute H_{2k}, P_{2k} from H_k, P_k
        new_P = (2 * P * H) % mod
        new_H = (2 * H * H - sign) % mod
        H, P = new_H, new_P
        sign = 1  # (-1)^(2k) = 1

        if bit == '1':
            # Increment: compute H_{2k+1}, P_{2k+1}
            new_H = (2 * H + P) % mod  # This is wrong for the half-companion
            # Actually: H(n+1) = 2*H(n) + ... no, we need:
            # P(n+1) = P(n) + H(n) ... no that's for standard Pell
            # For our recurrence: H(n+1) = H(n) + 2*P(n)... let me verify
            # H(0)=1,H(1)=1: H(1)=1 = 1+2*0 = H(0)+2*P(0) ✓ (but also H(1)=2*H(0)+H(-1)...)
            # Actually the addition formulas give:
            # H(m+n) = H(m)*H(n) + 2*P(m)*P(n)
            # P(m+n) = P(m)*H(n) + H(m)*P(n)
            # For m=1: H(n+1) = H(1)*H(n) + 2*P(1)*P(n) = H(n) + 2*P(n)
            # P(n+1) = P(1)*H(n) + H(1)*P(n) = H(n) + P(n)
            new_H2 = (H + 2 * P) % mod
            new_P2 = (H + P) % mod
            H, P = new_H2, new_P2
            sign = -sign  # (-1)^(2k+1) = -(-1)^(2k) = -1 * sign_before_increment
            # Actually (-1)^(2k+1) = -1 when starting from (-1)^(2k) = 1
            sign = -1 if sign == 1 else 1  # toggle

    return (H % mod, P % mod)


def pell_rank(p: int) -> int:
    """Find the Pell rank T(p): smallest T > 0 with P_T ≡ 0 (mod p)."""
    H_prev, H_curr = 1, 1
    P_prev, P_curr = 0, 1
    for T in range(1, 2 * p + 2):
        if P_curr % p == 0:
            return T
        H_prev, H_curr = H_curr, (2 * H_curr + H_prev) % p
        P_prev, P_curr = P_curr, (2 * P_curr + P_prev) % p
    return -1  # should not happen for prime p


# ============================================================
# Section 2: Factoring via Pell Sequences
# ============================================================

def factor_pell_basic(N: int, B: int = 1000) -> Optional[int]:
    """Basic Pell factoring: compute P_G mod N for G=1,2,...,B
    and check gcd(P_G, N) for non-trivial factors.
    """
    H_prev, H_curr = 1 % N, 1 % N
    P_prev, P_curr = 0, 1 % N

    for G in range(1, B + 1):
        g = math.gcd(P_curr, N)
        if 1 < g < N:
            return g
        # Also check P_G * P_{G-1} product
        product = (P_curr * P_prev) % N
        if product != 0:
            g2 = math.gcd(product, N)
            if 1 < g2 < N:
                return g2
        H_prev, H_curr = H_curr, (2 * H_curr + H_prev) % N
        P_prev, P_curr = P_curr, (2 * P_curr + P_prev) % N
    return None


def factor_pell_factorial(N: int, B: int = 50) -> Optional[int]:
    """Williams' p+1 method: compute P_{B!} mod N using fast doubling.
    If T(p) | B! for some prime factor p, then P_{B!} ≡ 0 (mod p).
    """
    # Compute B! step by step, multiplying the index
    H, P = 1 % N, 0  # Start with (H_0, P_0) = (1, 0)

    for k in range(2, B + 1):
        # We need (H_{k*n}, P_{k*n}) from (H_n, P_n)
        # Use the addition formula iteratively: multiply index by k
        # (H_{kn}, P_{kn}) via k applications of the addition formula
        H_new, P_new = 1 % N, 0  # (H_0, P_0)
        H_base, P_base = H, P  # (H_n, P_n) where n = (k-1)!

        # Compute (H_{k*n}, P_{k*n}) by repeated addition
        for _ in range(k):
            # (H_{a+b}, P_{a+b}) = (H_a*H_b + 2*P_a*P_b, P_a*H_b + H_a*P_b)
            H_next = (H_new * H_base + 2 * P_new * P_base) % N
            P_next = (P_new * H_base + H_new * P_base) % N
            H_new, P_new = H_next, P_next

        H, P = H_new, P_new

        g = math.gcd(P, N)
        if 1 < g < N:
            print(f"  Factor found at k={k} (computing P_{{k!}}): gcd = {g}")
            return g

    return None


def factor_pell_bsgs(N: int, B: int = 10000) -> Optional[int]:
    """Baby-Step Giant-Step Pell factoring.
    Baby steps: P_j for j = 0,...,m-1
    Giant steps: P_{k*m} for k = 1,2,...,B/m
    Check gcd of accumulated products.
    """
    m = int(math.isqrt(B)) + 1

    # Baby steps: compute P_j mod N for j = 0,...,m-1
    baby_P = [0] * m
    H_prev, H_curr = 1 % N, 1 % N
    P_prev, P_curr = 0, 1 % N
    baby_P[0] = 0

    for j in range(1, m):
        baby_P[j] = P_curr
        H_prev, H_curr = H_curr, (2 * H_curr + H_prev) % N
        P_prev, P_curr = P_curr, (2 * P_curr + P_prev) % N

    # Giant step base: (H_m, P_m) mod N
    H_m, P_m = pell_sequences(m, mod=N)

    # Giant steps with product accumulation
    H_giant, P_giant = H_m, P_m
    product = 1

    for k in range(1, B // m + 2):
        # Accumulate product of P_{km} values
        product = (product * P_giant) % N

        # Periodically check gcd
        if k % 10 == 0 or k == B // m + 1:
            g = math.gcd(product, N)
            if 1 < g < N:
                return g
            product = 1

        # Advance giant step: (H_{(k+1)m}, P_{(k+1)m}) from (H_{km}, P_{km})
        H_next = (H_giant * H_m + 2 * P_giant * P_m) % N
        P_next = (P_giant * H_m + H_giant * P_m) % N
        H_giant, P_giant = H_next, P_next

    return None


# ============================================================
# Section 3: Ghost Ancestor Computation
# ============================================================

def ghost_ancestor(a: int, b: int, c: int, n: int) -> Tuple[int, int, int]:
    """Compute the n-th ghost ancestor using closed form.
    Uses Pell sequences H_n, P_n.
    """
    H, P = pell_sequences(n)
    eps = (-1) ** n

    p = H**2 * a + 2 * P**2 * b - 2 * P * H * c
    q = 2 * P**2 * a + H**2 * b - 2 * P * H * c
    h = -2 * P * H * a - 2 * P * H * b + (4 * P**2 + eps) * c

    return (p, q, h)


def verify_pythagorean(a: int, b: int, c: int) -> bool:
    return a**2 + b**2 == c**2


# ============================================================
# Section 4: Demonstrations
# ============================================================

def demo_pell_identity():
    """Verify H²-2P²=(-1)^n for small n."""
    print("=" * 60)
    print("DEMO 1: Pell Identity H(n)² - 2P(n)² = (-1)^n")
    print("=" * 60)
    for n in range(15):
        H, P = pell_sequences(n)
        identity = H**2 - 2 * P**2
        expected = (-1)**n
        status = "✓" if identity == expected else "✗"
        print(f"  n={n:2d}: H={H:6d}, P={P:6d}, H²-2P²={identity:2d} = (-1)^{n} {status}")
    print()


def demo_ghost_ancestors():
    """Show ghost ancestors of (3,4,5)."""
    print("=" * 60)
    print("DEMO 2: Ghost Ancestors of (3,4,5)")
    print("=" * 60)
    a, b, c = 3, 4, 5
    for n in range(8):
        p, q, h = ghost_ancestor(a, b, c, n)
        is_pyth = verify_pythagorean(p, q, h)
        print(f"  G^{n}(3,4,5) = ({p}, {q}, {h})  "
              f"p²+q²=h²? {is_pyth}  "
              f"q-p={q-p} = (-1)^{n}·(4-3)={(-1)**n}")
    print()


def demo_pell_ranks():
    """Compute Pell ranks for small primes."""
    print("=" * 60)
    print("DEMO 3: Pell Ranks T(p) for Small Primes")
    print("=" * 60)
    print(f"  {'p':>4s}  {'T(p)':>5s}  {'p mod 8':>7s}  {'(2/p)':>5s}  {'divides':>10s}")
    print(f"  {'─'*4}  {'─'*5}  {'─'*7}  {'─'*5}  {'─'*10}")

    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        T = pell_rank(p)
        p_mod_8 = p % 8
        # Legendre symbol (2/p) = 1 if p ≡ ±1 (mod 8), -1 if p ≡ ±3 (mod 8)
        leg = 1 if p_mod_8 in [1, 7] else -1
        divides_what = f"p-1={p-1}" if leg == 1 else f"p+1={p+1}"
        does_divide = (p - leg) % T == 0
        print(f"  {p:4d}  {T:5d}  {p_mod_8:7d}  {leg:5d}  {divides_what:>10s}  "
              f"T|p-(2/p)? {'✓' if does_divide else '✗'}")
    print()


def demo_factoring():
    """Demonstrate factoring via Pell sequences."""
    print("=" * 60)
    print("DEMO 4: Factoring via Pell Sequences")
    print("=" * 60)

    test_cases = [
        (15, "3 × 5"),
        (77, "7 × 11"),
        (221, "13 × 17"),
        (1189, "29 × 41"),
        (10403, "101 × 103"),
        (46927, "199 × 233" if 199 * 233 == 46367 else "misc"),
        (104729, "prime test"),
    ]

    # Fix test cases
    test_cases = [
        (15, "3 × 5"),
        (77, "7 × 11"),
        (221, "13 × 17"),
        (1189, "29 × 41"),
        (10403, "101 × 103"),
        (19043, "127 × 149 = 18923" if 127*149==19043 else ""),
    ]

    for N, desc in test_cases:
        if N < 4:
            continue
        print(f"\n  N = {N} ({desc})")
        factor = factor_pell_basic(N, B=500)
        if factor:
            print(f"    Basic method: found factor {factor} (other: {N // factor})")
        else:
            print(f"    Basic method: no factor found in 500 steps")

        factor2 = factor_pell_factorial(N, B=20)
        if factor2:
            print(f"    Williams p+1: found factor {factor2} (other: {N // factor2})")
        else:
            print(f"    Williams p+1: no factor found with B=20")
    print()


def demo_doubling_formulas():
    """Verify the doubling formulas."""
    print("=" * 60)
    print("DEMO 5: Pell Doubling Formulas")
    print("=" * 60)
    for n in range(10):
        H_n, P_n = pell_sequences(n)
        H_2n, P_2n = pell_sequences(2 * n)

        P_double = 2 * P_n * H_n
        H_double = 2 * H_n**2 - (-1)**n

        p_ok = P_2n == P_double
        h_ok = H_2n == H_double

        print(f"  n={n:2d}: P(2n)={P_2n:8d} = 2P(n)H(n)={P_double:8d} {'✓' if p_ok else '✗'}  "
              f"H(2n)={H_2n:8d} = 2H(n)²-(-1)^n={H_double:8d} {'✓' if h_ok else '✗'}")
    print()


def demo_addition_formulas():
    """Verify the addition formulas."""
    print("=" * 60)
    print("DEMO 6: Pell Addition Formulas")
    print("=" * 60)
    for m in range(6):
        for n in range(6):
            H_m, P_m = pell_sequences(m)
            H_n, P_n = pell_sequences(n)
            H_mn, P_mn = pell_sequences(m + n)

            H_add = H_m * H_n + 2 * P_m * P_n
            P_add = P_m * H_n + H_m * P_n

            if H_mn != H_add or P_mn != P_add:
                print(f"  FAIL: m={m}, n={n}")
                return
    print("  All addition formula checks passed ✓")
    print()


def demo_cassini():
    """Verify Pell Cassini identity."""
    print("=" * 60)
    print("DEMO 7: Pell Cassini Identity P(n+2)P(n)-P(n+1)²=(-1)^(n+1)")
    print("=" * 60)
    for n in range(12):
        _, P_n = pell_sequences(n)
        _, P_n1 = pell_sequences(n + 1)
        _, P_n2 = pell_sequences(n + 2)
        cassini = P_n2 * P_n - P_n1**2
        expected = (-1)**(n + 1)
        status = "✓" if cassini == expected else "✗"
        print(f"  n={n:2d}: P({n+2})·P({n}) - P({n+1})² = {cassini:2d} = (-1)^{n+1} {status}")
    print()


def demo_composition():
    """Verify ghost ancestor composition: G^{m+n} = G^m ∘ G^n."""
    print("=" * 60)
    print("DEMO 8: Ghost Ancestor Composition G^(m+n) = G^m(G^n(·))")
    print("=" * 60)
    a, b, c = 3, 4, 5
    all_ok = True
    for m in range(6):
        for n in range(6):
            direct = ghost_ancestor(a, b, c, m + n)
            inner = ghost_ancestor(a, b, c, n)
            composed = ghost_ancestor(inner[0], inner[1], inner[2], m)
            if direct != composed:
                print(f"  FAIL: m={m}, n={n}: {direct} ≠ {composed}")
                all_ok = False
    if all_ok:
        print("  All composition checks passed ✓")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  PELL SEQUENCE FACTORING & PYTHAGOREAN TREE DEMO")
    print("=" * 60 + "\n")

    demo_pell_identity()
    demo_ghost_ancestors()
    demo_pell_ranks()
    demo_doubling_formulas()
    demo_addition_formulas()
    demo_cassini()
    demo_composition()
    demo_factoring()

    print("\n" + "=" * 60)
    print("  All demos completed successfully!")
    print("=" * 60)
