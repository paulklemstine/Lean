from typing import List, Tuple

Codeword = Tuple[int, ...]
Code = List[Codeword]


def weight(c: Codeword) -> int:
    return sum(1 for x in c if x % 2 == 1)


def min_distance(C: Code) -> int:
    nz = [weight(c) for c in C if any(x % 2 == 1 for x in c)]
    return min(nz)


def compose_profile(twe_C, twe_D, dC: int, dD: int):
    """
    Compose the tropical profiles of building-block codes into the profile of
    their direct sum without expanding the (exponentially large) product code:
        twe_{C(+)D}(t) = twe_C(t) + twe_D(t)        (tropical additivity)
        d(C (+) D)     = min(dC, dD)                 (tropical-min law)
    Returns (profile_function, distance).
    """
    return (lambda t: twe_C(t) + twe_D(t)), min(dC, dD)
