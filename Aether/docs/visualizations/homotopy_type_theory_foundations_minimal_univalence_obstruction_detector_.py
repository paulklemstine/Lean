from itertools import permutations
from typing import List, Tuple


def automorphisms(n: int) -> List[Tuple[int, ...]]:
    """All self-equivalences (bijections) of an n-element type."""
    return list(permutations(range(n)))


def id_type_self_card() -> int:
    """|A == A| in a proof-irrelevant identity type is always 1."""
    return 1


def univalence_obstructed(n: int) -> bool:
    """
    Univalence requires idToEquiv : (A == A) -> (A ~ A) to be a bijection.
    In a proof-irrelevant setting |A == A| = 1 but |Aut(A)| = n!, so the
    obstruction is present exactly when |Aut(A)| > 1.
    """
    return len(automorphisms(n)) > id_type_self_card()


def minimal_obstruction() -> int:
    """The smallest n with a non-trivial automorphism group: Bool, n = 2."""
    n = 1
    while not univalence_obstructed(n):
        n += 1
    return n
