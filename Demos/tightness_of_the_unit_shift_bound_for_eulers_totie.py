"""Numerical demonstrations for the unit-shift totient equation phi(n) = phi(n+1).

This script is fully self-contained: every helper (the totient, Fermat numbers,
the Fermat product family, the counting function S1phi, and the witness
certification) is inlined with type hints. It reproduces the key results of the
accompanying paper:

  * the multiplicatively certified witnesses (15|16, 104|105, ..., 975|976);
  * the Fermat-prime family construction phi(N_m) = phi(N_m + 1) = 2^(2^m - 1);
  * the unconditional ten-digit solution N_5 = 2^32 - 1 = 4294967295;
  * the counting function S1phi and the transfer-theorem lower bounds
    S1phi(194) >= 6 and S1phi(975) >= 10.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Core arithmetic
# ---------------------------------------------------------------------------

def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime factorization of n >= 1 as {prime: exponent}."""
    if n < 1:
        raise ValueError("n must be a positive integer")
    factors: Dict[int, int] = {}
    d = 2
    m = n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def totient(n: int) -> int:
    """Euler's totient function via the multiplicative prime-power formula
    phi(p^e) = p^(e-1) * (p - 1)."""
    if n == 1:
        return 1
    result = 1
    for p, e in prime_factorization(n).items():
        result *= p ** (e - 1) * (p - 1)
    return result


def fermat_number(k: int) -> int:
    """The k-th Fermat number F_k = 2^(2^k) + 1."""
    return 2 ** (2 ** k) + 1


def fermat_prod(m: int) -> int:
    """N_m = product of the first m Fermat numbers F_0 ... F_{m-1}.

    By the classical telescoping identity this equals 2^(2^m) - 1."""
    prod = 1
    for k in range(m):
        prod *= fermat_number(k)
    return prod


# ---------------------------------------------------------------------------
# The counting function
# ---------------------------------------------------------------------------

def solutions_up_to(x: int) -> List[int]:
    """All n with 1 <= n <= x and phi(n) = phi(n+1)."""
    return [n for n in range(1, x + 1) if totient(n) == totient(n + 1)]


def S1phi(x: int) -> int:
    """S1phi(x) = #{ n <= x : phi(n) = phi(n+1) }."""
    return len(solutions_up_to(x))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_witnesses() -> None:
    """Certify each Graham-Holt-Pomerance-style witness multiplicatively."""
    witnesses: List[int] = [15, 104, 164, 194, 255, 495, 584, 975]
    print("=" * 70)
    print("Multiplicatively certified unit-shift witnesses")
    print("=" * 70)
    for n in witnesses:
        fn = prime_factorization(n)
        fn1 = prime_factorization(n + 1)
        tn, tn1 = totient(n), totient(n + 1)
        fmt = lambda f: " * ".join(
            f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(f.items())
        )
        ok = "OK" if tn == tn1 else "MISMATCH"
        print(f"  n={n:>4}: {n} = {fmt(fn):<14} | {n+1} = {fmt(fn1):<14}"
              f" | phi = {tn} = {tn1}  [{ok}]")
    print()


def demo_fermat_family() -> None:
    """phi(N_m) = phi(N_m + 1) = 2^(2^m - 1) for m with F_0..F_{m-1} prime."""
    print("=" * 70)
    print("Fermat-prime family: phi(N_m) = phi(N_m + 1) = 2^(2^m - 1)")
    print("=" * 70)
    for m in range(1, 6):  # F_0..F_4 are the known Fermat primes
        Nm = fermat_prod(m)
        expected = 2 ** (2 ** m - 1)
        t0, t1 = totient(Nm), totient(Nm + 1)
        assert Nm + 1 == 2 ** (2 ** m), "telescoping identity failed"
        ok = "OK" if t0 == t1 == expected else "MISMATCH"
        print(f"  m={m}: N_m = {Nm} (= 2^{2**m} - 1),  N_m+1 = 2^{2**m}")
        print(f"         phi(N_m) = phi(N_m+1) = {t0} = 2^({2**m}-1)  [{ok}]")
    print()


def demo_concrete_2pow32() -> None:
    """The unconditional ten-digit solution N_5 = 2^32 - 1."""
    print("=" * 70)
    print("Unconditional concrete solution N_5 = 2^32 - 1")
    print("=" * 70)
    n = 4294967295  # = 2^32 - 1 = 3 * 5 * 17 * 257 * 65537
    assert n == fermat_prod(5) == 2 ** 32 - 1
    tn, tn1 = totient(n), totient(n + 1)
    print(f"  n          = {n}  (= 2^32 - 1)")
    print(f"  n + 1      = {n + 1}  (= 2^32)")
    print(f"  phi(n)     = {tn}")
    print(f"  phi(n + 1) = {tn1}  (= 2^31 = {2**31})")
    print(f"  equal?     {tn == tn1}")
    print()


def demo_counting() -> None:
    """The counting function S1phi and transfer-theorem lower bounds."""
    print("=" * 70)
    print("Counting function S1phi(x) and transfer-theorem bounds")
    print("=" * 70)
    print(f"  Solutions up to 1000: {solutions_up_to(1000)}")
    for x in (194, 975, 1000):
        print(f"  S1phi({x}) = {S1phi(x)}")
    print()
    # Transfer theorem: a certified witness set below x bounds S1phi(x).
    W6: List[int] = [1, 3, 15, 104, 164, 194]
    W10: List[int] = [1, 3, 15, 104, 164, 194, 255, 495, 584, 975]
    assert all(totient(w) == totient(w + 1) for w in W6)
    assert all(totient(w) == totient(w + 1) for w in W10)
    assert len(W6) <= S1phi(194)
    assert len(W10) <= S1phi(975)
    print(f"  Transfer theorem:  |W6|={len(W6)} <= S1phi(194)={S1phi(194)}  (>= 6 OK)")
    print(f"  Transfer theorem: |W10|={len(W10)} <= S1phi(975)={S1phi(975)}  (>= 10 OK)")
    print()


def demo_structure() -> None:
    """Structural facts: parity of collision values; 104 is an even solution."""
    print("=" * 70)
    print("Structural constraints on solutions")
    print("=" * 70)
    sols = solutions_up_to(1000)
    all_even = all(totient(n) % 2 == 0 for n in sols if n >= 2)
    print(f"  All collision values phi(n) for n>=2 are even? {all_even}")
    print(f"  Even solution (refutes 'must be odd' folklore): n=104,"
          f" phi(104)={totient(104)} = phi(105)={totient(105)}")
    print()


def main() -> None:
    demo_witnesses()
    demo_fermat_family()
    demo_concrete_2pow32()
    demo_counting()
    demo_structure()


if __name__ == "__main__":
    main()
