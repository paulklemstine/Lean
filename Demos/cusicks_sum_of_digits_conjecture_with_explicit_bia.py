"""Numerical demonstrations for Cusick's binary sum-of-digits problem.

Self-contained (standard library only). Every result demonstrated here mirrors a
formally verified theorem about the binary sum-of-digits function

    s2(n) = number of 1s in the binary expansion of n.

Theorems exercised (Lean names in brackets):
  * s2(a+b) <= s2(a)+s2(b)                              [s2_subadditive]
  * s2(n) + v2(n!) = n                                  [s2_add_val]
  * sum_{x<2^k} s2(x) = k*2^(k-1)  (mean k/2)           [s2_block_sum]
  * carries K(n,t) = v2(C(n+t,t)) = s2(t)+s2(n)-s2(n+t) [carries_eq_sub]
  * s2(n)<=s2(n+t)  <=>  K(n,t)<=s2(t)                  [cusick_reformulation]
  * s2(n)<=s2(n+1)  <=>  n % 4 != 3                     [cusick_t1_iff]
  * #{n<4m : s2(n)<=s2(n+1)} = 3m  (c_1 = 3/4)          [cusick_t1_density]
  * Count(2t,2N) = 2*Count(t,N)                         [cusickCount_two_mul]
  * Count(2^k, 2^(k+2) m) = 3*2^k*m  (c_{2^k}=3/4)      [cusick_pow2_density]
  * Count(2^k t, 2^k N) = 2^k * Count(t,N)              [cusickCount_two_pow_mul]
"""

from __future__ import annotations

from math import comb, factorial


def s2(n: int) -> int:
    """Binary sum-of-digits (popcount): number of 1s in the base-2 expansion."""
    return bin(n).count("1")


def v2(m: int) -> int:
    """2-adic valuation: largest e with 2^e | m (v2(0) treated as a big number)."""
    if m == 0:
        return 10**9
    e = 0
    while m % 2 == 0:
        m //= 2
        e += 1
    return e


def carries(t: int, n: int) -> int:
    """Number of base-2 carries when adding n and t (Kummer: v2 of C(n+t, t))."""
    return v2(comb(n + t, t))


def cusick_predicate(n: int, t: int) -> bool:
    """The Cusick event: the digit sum does not decrease, s2(n) <= s2(n+t)."""
    return s2(n) <= s2(n + t)


def cusick_count(t: int, N: int) -> int:
    """Count(t, N) = #{ 0 <= n < N : s2(n) <= s2(n+t) }."""
    return sum(1 for n in range(N) if cusick_predicate(n, t))


def cusick_floor(t: int) -> float:
    """Cusick's conjectured explicit lower bound 1/2 + 2^-(2*s2(t)+1) on c_t."""
    return 0.5 + 2.0 ** (-(2 * s2(t) + 1))


def demo_subadditivity_and_carry_identity(bound: int = 64) -> None:
    """Verify subadditivity and the exact carry identity s2(n+t)+K = s2(n)+s2(t)."""
    print("== Subadditivity and exact carry identity ==")
    for a in range(bound):
        for b in range(bound):
            assert s2(a + b) <= s2(a) + s2(b)
            # carry identity and Kummer subtraction form
            assert s2(a + b) + carries(b, a) == s2(a) + s2(b)
            assert carries(b, a) == s2(b) + s2(a) - s2(a + b)
    print(f"  verified for all a,b < {bound}: s2 subadditive, "
          "s2(n+t)+carries = s2(n)+s2(t), Kummer subtraction form.\n")


def demo_legendre_identity(bound: int = 200) -> None:
    """Verify the additive Legendre identity s2(n) + v2(n!) = n."""
    print("== Legendre (additive form): s2(n) + v2(n!) = n ==")
    for n in range(bound):
        assert s2(n) + v2(factorial(n)) == n
    print(f"  verified for all n < {bound}.\n")


def demo_block_mean(kmax: int = 14) -> None:
    """Verify sum_{x<2^k} s2(x) = k*2^(k-1), i.e. the mean of s2 is exactly k/2."""
    print("== Block average: sum_{x<2^k} s2(x) = k*2^(k-1), mean = k/2 ==")
    for k in range(1, kmax + 1):
        total = sum(s2(x) for x in range(2 ** k))
        assert total == k * 2 ** (k - 1)
        mean = total / 2 ** k
        assert abs(mean - k / 2) < 1e-12
        print(f"  k={k:2d}:  sum={total:8d} = k*2^(k-1),  mean={mean:.3f} = k/2")
    print()


def demo_cusick_reformulation(bound: int = 64) -> None:
    """Verify s2(n)<=s2(n+t)  <=>  carries(t,n) <= s2(t)."""
    print("== Carry reformulation: s2(n)<=s2(n+t) <=> carries <= s2(t) ==")
    for t in range(1, bound):
        for n in range(bound):
            assert cusick_predicate(n, t) == (carries(t, n) <= s2(t))
    print(f"  verified for all 1<=t<{bound}, n<{bound}.\n")


def demo_t1_density(mmax: int = 12) -> None:
    """Verify c_1 = 3/4 exactly: #{n<4m : s2(n)<=s2(n+1)} = 3m, and the
    congruence criterion s2(n)<=s2(n+1) <=> n % 4 != 3."""
    print("== Exact density c_1 = 3/4 (t=1) ==")
    for n in range(4 * mmax):
        assert cusick_predicate(n, 1) == (n % 4 != 3)
    for m in range(1, mmax + 1):
        cnt = cusick_count(1, 4 * m)
        assert cnt == 3 * m
        print(f"  m={m:2d}:  Count(1, {4*m:3d}) = {cnt:3d} = 3m,   "
              f"density = {cnt/(4*m):.4f}   (floor {cusick_floor(1):.4f})")
    print()


def demo_pow2_density_and_bias(kmax: int = 6, mmax: int = 4) -> None:
    """Verify c_{2^k} = 3/4 via Count(2^k, 2^(k+2) m) = 3*2^k*m, and the explicit
    surplus over the fair half: Count - 2^(k+1) m = 2^k m."""
    print("== Exact density c_{2^k} = 3/4 and explicit bias ==")
    for k in range(kmax + 1):
        for m in range(1, mmax + 1):
            N = 2 ** (k + 2) * m
            cnt = cusick_count(2 ** k, N)
            assert cnt == 3 * 2 ** k * m
            fair_half = 2 ** (k + 1) * m
            assert cnt - fair_half == 2 ** k * m   # cusick_pow2_bias
        print(f"  k={k}:  c_(2^{k}) = {cnt/N:.4f},  surplus over half = "
              f"{cnt-2**(k+1)*m} = 2^{k}*m   (floor {cusick_floor(2**k):.4f})")
    print()


def demo_doubling_self_similarity(tmax: int = 6, Nmax: int = 64,
                                  kmax: int = 4) -> None:
    """Verify Count(2t,2N)=2 Count(t,N) and the orbit law
    Count(2^k t, 2^k N) = 2^k Count(t,N) (density depends only on odd part of t)."""
    print("== Doubling self-similarity and orbit invariance ==")
    for t in range(1, tmax + 1):
        for N in range(1, Nmax + 1):
            assert cusick_count(2 * t, 2 * N) == 2 * cusick_count(t, N)
            for k in range(kmax + 1):
                assert (cusick_count(2 ** k * t, 2 ** k * N)
                        == 2 ** k * cusick_count(t, N))
    print(f"  verified Count(2t,2N)=2 Count(t,N) and orbit law for "
          f"1<=t<={tmax}, N<={Nmax}, k<={kmax}.")
    # Illustrate orbit-constant density: same density along {t,2t,4t,...}.
    for t in (1, 3, 5):
        window = 2 ** 10
        densities = [cusick_count(2 ** k * t, 2 ** k * window) / (2 ** k * window)
                     for k in range(4)]
        shown = ", ".join(f"{d:.4f}" for d in densities)
        print(f"  odd part t={t}: densities along orbit = [{shown}] (constant)")
    print()


def main() -> None:
    demo_subadditivity_and_carry_identity()
    demo_legendre_identity()
    demo_block_mean()
    demo_cusick_reformulation()
    demo_t1_density()
    demo_pow2_density_and_bias()
    demo_doubling_self_similarity()
    print("All numerical checks passed — consistent with the formal theorems.")


if __name__ == "__main__":
    main()
