def prime_sieve(a: int, b: int, n: int, primes: list[int]) -> tuple[str, int | None]:
    """Search odd primes p (with p not dividing n) for a parity obstruction."""
    def vp(m: int, p: int) -> int:
        c = 0
        while m % p == 0:
            m //= p
            c += 1
        return c
    for p in primes:
        if n % p == 0:
            continue  # v_p(a^n+1) = v_p(a+1) + v_p(n); needs correction
        if (vp(a + 1, p) + vp(b + 1, p)) % 2 == 1:
            return ("NOT A SQUARE", p)
    return ("NO LOCAL OBSTRUCTION FOUND", None)
