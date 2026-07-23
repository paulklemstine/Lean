from math import factorial
from typing import List


def encode_factoradic(n: int, k: int) -> List[int]:
    """Encode a natural number n into its length-k factoradic digit vector.

    Returns c with c[i] = i-th factoradic digit, satisfying c[i] <= i and
    sum(c[i] * i! for i < k) == n whenever n < k!.
    Implements the streaming division algorithm whose loop invariant is the
    pair of splitting identities (splitting_div / splitting_mod).
    """
    c: List[int] = [0] * k
    for i in range(1, k + 1):
        c[i - 1] = n % i      # remainder gives the digit (bounded by i-1)
        n //= i               # quotient carries to higher positions
    return c
