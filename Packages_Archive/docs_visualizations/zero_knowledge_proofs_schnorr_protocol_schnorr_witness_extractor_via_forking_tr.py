def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse modulo prime p (Fermat's little theorem)."""
    return pow(a % p, p - 2, p)


def extract_witness(c1: int, s1: int, c2: int, s2: int, p: int) -> int:
    """Recover x* with x* * g == Y from two forking transcripts (c1 != c2)."""
    if (c1 - c2) % p == 0:
        raise ValueError('challenges must differ for extraction')
    return (inv_mod((c1 - c2) % p, p) * ((s1 - s2) % p)) % p
