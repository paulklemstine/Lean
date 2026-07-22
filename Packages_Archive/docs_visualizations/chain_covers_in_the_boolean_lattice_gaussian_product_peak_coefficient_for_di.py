from typing import List, Tuple


def divisor_lattice_chain_cover(exponents: Tuple[int, ...]) -> int:
    """Peak coefficient of prod_i (1 + x + ... + x^{e_i}): the chain-cover
    number of the divisor lattice with the given prime exponents."""
    poly: List[int] = [1]
    for e in exponents:
        factor = [1] * (e + 1)
        conv = [0] * (len(poly) + len(factor) - 1)
        for i, a in enumerate(poly):
            for j, b in enumerate(factor):
                conv[i + j] += a * b
        poly = conv
    return max(poly)
