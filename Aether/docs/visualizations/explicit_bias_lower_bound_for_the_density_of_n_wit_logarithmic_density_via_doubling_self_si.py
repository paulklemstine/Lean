def s2(n: int) -> int:
    return bin(n).count("1")

def cusick_count(t: int, N: int) -> int:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))

def cusick_count_via_doubling(k: int, m: int) -> int:
    """Compute cusickCount(2^k, 2^{k+2} m) in O(1) shift operations using the
    self-similarity cusickCount(2t, 2N) = 2 cusickCount(t, N) and the base case
    cusickCount(1, 4m) = 3m. Returns the exact value 3 * 2^k * m."""
    base = 3 * m                 # cusickCount(1, 4m) = 3m  (Theorem 4.3)
    return (1 << k) * base       # k applications of the doubling rule
