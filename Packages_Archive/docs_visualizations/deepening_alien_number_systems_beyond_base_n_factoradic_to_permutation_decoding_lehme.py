from math import factorial
from typing import List

def factoradic_to_permutation(n: int, k: int) -> List[int]:
    """Map n in [0, (k+1)!) to the n-th permutation of {0,...,k} (lex order).

    Uses the factorial-base (factoradic) bases [2,3,...,k+1]: the factoradic
    digits of n form the Lehmer code, which selects, position by position, the
    d_i-th remaining element. This is the concrete content of Future-Directions
    Conjecture 2 linking Fin((k+1)!) with Perm(Fin(k+1)).
    """
    bs = [i + 2 for i in range(k)]              # [2,3,...,k+1], product (k+1)!
    little: List[int] = []                      # factoradic digits, least sig first
    for b in bs:
        little.append(n % b)
        n //= b
    # Lehmer code, most-significant first, with a trailing 0 (pool of size 1):
    code = list(reversed(little)) + [0]
    pool = list(range(k + 1))
    perm: List[int] = []
    for c in code:
        perm.append(pool.pop(c))
    return perm
