from math import comb
from typing import List

def base_p_digits(n: int, p: int) -> List[int]:
    d: List[int] = []
    if n == 0:
        return [0]
    while n > 0:
        d.append(n % p)
        n //= p
    return d

def binomial_mod_prime(m: int, k: int, p: int) -> int:
    """C(m, k) mod p via Lucas' theorem in O(log_p m) small binomials."""
    dm, dk = base_p_digits(m, p), base_p_digits(k, p)
    dk += [0] * (len(dm) - len(dk))
    result = 1
    for mi, ki in zip(dm, dk):
        if ki > mi:
            return 0
        result = (result * comb(mi, ki)) % p
    return result

def choose_prime_fibre(q: int, p: int) -> int:
    """Returns C(q*p, p) mod p, which equals q mod p by Lucas' theorem."""
    return binomial_mod_prime(q * p, p, p)
