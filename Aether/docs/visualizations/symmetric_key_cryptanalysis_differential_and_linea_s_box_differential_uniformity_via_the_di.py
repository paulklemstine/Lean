from typing import Callable

GF_MODULUS: int = 0x11B  # x^8 + x^4 + x^3 + x + 1 (AES Rijndael polynomial)


def gf_mul(a: int, b: int) -> int:
    """Multiply two elements of GF(2^8) with the AES reduction polynomial."""
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        b >>= 1
        carry = a & 0x80
        a = (a << 1) & 0xFF
        if carry:
            a ^= (GF_MODULUS & 0xFF)
    return p


def gf_inv(a: int) -> int:
    """Multiplicative inverse in GF(2^8); inv(0) := 0 (AES convention)."""
    if a == 0:
        return 0
    result, base, exp = 1, a, 254  # a^254 = a^{-1} in a group of order 255
    while exp > 0:
        if exp & 1:
            result = gf_mul(result, base)
        base = gf_mul(base, base)
        exp >>= 1
    return result


def differential_uniformity(sbox: Callable[[int], int], n_bits: int = 8) -> int:
    """
    S-box differential uniformity.

    Compute the maximal off-origin entry of the difference-distribution table:
        max over a != 0, b of  #{ x : S(x XOR a) XOR S(x) == b }.
    For the AES inversion S-box this equals 4, so the maximal differential
    probability is 4/256 = 2^-6.

    Complexity: O(2^(2 n_bits)); O(2^16) for AES.
    """
    size = 1 << n_bits
    best = 0
    for a in range(1, size):
        counts = [0] * size
        for x in range(size):
            counts[sbox(x ^ a) ^ sbox(x)] += 1
        m = max(counts)
        if m > best:
            best = m
    return best
