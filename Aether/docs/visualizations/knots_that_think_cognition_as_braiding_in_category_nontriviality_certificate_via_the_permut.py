from typing import List


def underlying_permutation(word: List[int], strands: int) -> List[int]:
    p: List[int] = list(range(strands))
    for letter in word:
        i = abs(letter) - 1
        p[i], p[i + 1] = p[i + 1], p[i]
    return p


def is_certifiably_nontrivial(word: List[int], strands: int) -> bool:
    """Certify a braid nontrivial via its underlying permutation.

    Returns True if the underlying permutation of the braid word is not the
    identity, which is a sufficient (not necessary) condition for the braid to be
    nontrivial.  This is exactly the certificate used to prove the confused braid
    is nontrivial even though its writhe vanishes.  Runs in O(len(word)+strands).
    """
    p = underlying_permutation(word, strands)
    return any(p[k] != k for k in range(strands))
