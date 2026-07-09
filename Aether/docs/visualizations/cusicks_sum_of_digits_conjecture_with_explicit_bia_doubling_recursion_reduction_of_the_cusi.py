from __future__ import annotations


def s2(n: int) -> int:
    return bin(n).count("1")


def cusick_count_direct(t: int, N: int) -> int:
    """Reference O(N log N) count of {n < N : s2(n) <= s2(n+t)}."""
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))


def cusick_density_pow2(k: int) -> float:
    """Closed-form density c_{2^k} = 3/4 (from cusick_pow2_density)."""
    return 3.0 / 4.0


def cusick_count_reduce(t: int, N: int) -> int:
    """Strip the shared power of two from (t, N) via Count(2t,2N)=2 Count(t,N)
    (cusickCount_two_mul / cusickCount_two_pow_mul), then fall back to direct
    counting on the reduced odd-shift instance."""
    k: int = 0
    while t % 2 == 0 and N % 2 == 0:
        t //= 2
        N //= 2
        k += 1
    return (1 << k) * cusick_count_direct(t, N)
