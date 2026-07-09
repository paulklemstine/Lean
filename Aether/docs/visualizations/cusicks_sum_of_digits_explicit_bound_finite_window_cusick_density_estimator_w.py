def s2(n: int) -> int:
    return bin(n).count("1")

def cusick_density_window(t: int, k: int) -> float:
    """Empirical density of G_t over [0, 2^k); for t=1 the exact value is 3/4.

    Uses the residue shortcut for t=1 (n % 4 != 3) and direct counting otherwise.
    """
    N = 1 << k
    if t == 1:
        # exactly floor(3N/4) since N is a power of two (multiple of 4 for k>=2)
        return (3 * N // 4) / N
    good = sum(1 for n in range(N) if s2(n + t) >= s2(n))
    return good / N
