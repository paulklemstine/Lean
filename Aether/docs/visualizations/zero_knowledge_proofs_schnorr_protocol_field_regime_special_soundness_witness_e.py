from typing import Tuple

def inv_mod(a: int, p: int) -> int:
    """Modular inverse of a modulo prime p."""
    return pow(a % p, -1, p)

def field_extract(p: int, c1: int, s1: int, c2: int, s2: int) -> int:
    """Field-regime special-soundness extractor.

    Given two accepting transcripts (t, c1, s1) and (t, c2, s2) sharing the
    commitment t with c1 != c2 over Z/pZ (p prime), recover the witness
        x = (s1 - s2) * (c1 - c2)^{-1}  (mod p).
    """
    if c1 == c2:
        raise ValueError("challenges must be distinct")
    return ((s1 - s2) * inv_mod(c1 - c2, p)) % p
