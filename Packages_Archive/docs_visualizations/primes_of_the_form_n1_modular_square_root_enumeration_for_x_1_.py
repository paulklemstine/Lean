from typing import List

def modular_roots_sq_plus_one(p: int) -> List[int]:
    """Enumerate all roots of x^2 + 1 = 0 in Z/p by scanning residues.

    Returns the sorted list of x in {0,...,p-1} with (x*x + 1) % p == 0.
    Complexity: O(p) modular multiplications. By card_solSet_of_ne /
    card_solSet_of_three the output has length 0 or 2 for odd primes (1 for p=2).
    """
    return [x for x in range(p) if (x * x + 1) % p == 0]
