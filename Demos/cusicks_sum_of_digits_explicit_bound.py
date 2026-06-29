"""
Numerical demonstrations for:

    Cusick's Sum-of-Digits Explicit Bound
    A carry-counting reformulation via Kummer's theorem.

Key facts demonstrated (all proved formally in the Lean development):

  * carries(t, n) := v2( C(n+t, t) )                      (Kummer's theorem)
  * carries(t, n) == s2(t) + s2(n) - s2(n+t)              (carries_eq_sub)
  * s2(n+t) + carries(t, n) == s2(n) + s2(t)              (s2_add_carries)
  * s2(n) <= s2(n+t)  <=>  carries(t, n) <= s2(t)         (cusick_reformulation)
  * carries(t, n) == 0  =>  s2(n+t) == s2(n) + s2(t)      (cusick_of_no_carry)
  * carries(t, n) <= s2(n) + s2(t)                        (carries_le_total)
  * t < 2**L  =>  s2(t + 2**L) == s2(t) + 1               (s2_high_bit)
  * s2(n) <= s2(n+1)  <=>  n % 4 != 3                     (cusick_t1_iff)
  * exactly 3m of n in [0,4m) satisfy s2(n)<=s2(n+1)      (cusick_t1_density)

Run with:  python demo.py
"""

from __future__ import annotations

from math import comb


def s2(n: int) -> int:
    """Binary digit sum (Hamming weight / popcount) of n >= 0."""
    return bin(n).count("1")


def v2(m: int) -> int:
    """2-adic valuation of m >= 1 (largest e with 2**e | m)."""
    if m == 0:
        return 0
    e = 0
    while m % 2 == 0:
        m //= 2
        e += 1
    return e


def carries_kummer(t: int, n: int) -> int:
    """Carry count of binary addition n + t, via Kummer: v2( C(n+t, t) )."""
    return v2(comb(n + t, t))


def carries_digitsum(t: int, n: int) -> int:
    """Carry count via the conservation identity: s2(t) + s2(n) - s2(n+t)."""
    return s2(t) + s2(n) - s2(n + t)


def cusick_holds(t: int, n: int) -> bool:
    """Whether s2(n) <= s2(n+t)."""
    return s2(n) <= s2(n + t)


def demo_kummer_agreement(t_max: int = 8, n_max: int = 64) -> None:
    """Verify the two carry formulas agree, and the conservation identity holds."""
    print("== Kummer vs. digit-sum carry count, and conservation identity ==")
    ok = True
    for t in range(1, t_max + 1):
        for n in range(n_max + 1):
            ck = carries_kummer(t, n)
            cd = carries_digitsum(t, n)
            assert ck == cd, (t, n, ck, cd)
            # conservation: s2(n+t) + carries == s2(n) + s2(t)
            assert s2(n + t) + ck == s2(n) + s2(t), (t, n)
            # unconditional total bound
            assert ck <= s2(n) + s2(t)
    print(f"   all checks passed for t<={t_max}, n<={n_max}  ->  OK={ok}")


def demo_reformulation(t_max: int = 8, n_max: int = 200) -> None:
    """Verify  s2(n)<=s2(n+t)  <=>  carries(t,n) <= s2(t)."""
    print("== Cusick reformulation:  inequality  <=>  carries <= s2(t) ==")
    for t in range(1, t_max + 1):
        for n in range(n_max + 1):
            lhs = cusick_holds(t, n)
            rhs = carries_kummer(t, n) <= s2(t)
            assert lhs == rhs, (t, n, lhs, rhs)
    print(f"   equivalence verified for t<={t_max}, n<={n_max}")


def demo_t1_density(m: int = 250000) -> None:
    """Confirm exactly 3m of n in [0,4m) satisfy s2(n)<=s2(n+1), so c_1 = 3/4."""
    print("== Exact t=1 density:  c_1 = 3/4 ==")
    N = 4 * m
    good = sum(1 for n in range(N) if cusick_holds(1, n))
    # also confirm the residue characterization n % 4 != 3
    good_res = sum(1 for n in range(N) if n % 4 != 3)
    print(f"   window [0,{N}):  good = {good},  expected 3m = {3 * m}")
    print(f"   residue count (n%4!=3) = {good_res}")
    print(f"   measured density = {good / N:.6f}   (bound 5/8 = {5/8})")
    assert good == 3 * m
    assert good_res == 3 * m


def demo_explicit_gap(t_max: int = 16, k: int = 22) -> None:
    """Empirical density c_t over [0, 2^k) vs the bound 1/2 + 2^{-(2 s2(t)+1)}."""
    print("== Empirical c_t vs explicit lower bound 1/2 + 2^{-(2 s2(t)+1)} ==")
    N = 1 << k
    print(f"   window [0, 2^{k}) = [0, {N})")
    print(f"   {'t':>3} {'s2(t)':>5} {'c_t (emp)':>12} {'bound':>12} {'ok':>4}")
    for t in range(1, t_max + 1):
        good = sum(1 for n in range(N) if cusick_holds(t, n))
        c = good / N
        bound = 0.5 + 2.0 ** (-(2 * s2(t) + 1))
        ok = c >= bound - 1e-9
        print(f"   {t:>3} {s2(t):>5} {c:>12.6f} {bound:>12.6f} {str(ok):>4}")


def demo_high_bit(t_max: int = 12) -> None:
    """Confirm s2(t + 2^L) = s2(t)+1 whenever t < 2^L (no-carry high bit)."""
    print("== No-carry high bit:  s2(t + 2^L) = s2(t) + 1  for t < 2^L ==")
    for t in range(t_max + 1):
        L = t.bit_length()  # smallest L with t < 2^L (works since t < 2^L needed)
        L = max(L, 1)
        while t >= 2 ** L:
            L += 1
        assert s2(t + 2 ** L) == s2(t) + 1, (t, L)
    print(f"   verified for t<={t_max}")


def demo_infinite_good_set(t: int = 5, count: int = 8) -> None:
    """Show the sparse witness family n = 2^{j+t} all lie in the good set."""
    print(f"== Infinite good set for t={t}: witnesses n = 2^(j+{t}) ==")
    for j in range(count):
        n = 2 ** (j + t)
        gain = s2(n + t) - s2(n)
        assert gain == s2(t)  # maximal gain, no carry
        print(f"   j={j}: n=2^{j+t}={n:>12}  s2(n)={s2(n)}  s2(n+t)={s2(n+t)}  gain={gain}")


if __name__ == "__main__":
    demo_kummer_agreement()
    print()
    demo_reformulation()
    print()
    demo_high_bit()
    print()
    demo_infinite_good_set()
    print()
    demo_t1_density()
    print()
    demo_explicit_gap()
