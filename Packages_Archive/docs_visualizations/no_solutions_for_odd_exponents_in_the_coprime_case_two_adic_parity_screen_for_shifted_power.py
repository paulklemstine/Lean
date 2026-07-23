def parity_screen(a: int, b: int) -> str:
    """Return a verdict from the 2-adic parity criterion for (a^n+1)(b^n+1)."""
    def v2(m: int) -> int:
        c = 0
        while m % 2 == 0:
            m //= 2
            c += 1
        return c
    if (v2(a + 1) + v2(b + 1)) % 2 == 1:
        return "NOT A SQUARE for all odd n"
    return "UNDECIDED by 2-adic valuation"
