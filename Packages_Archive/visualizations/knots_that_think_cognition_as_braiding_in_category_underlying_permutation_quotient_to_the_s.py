from typing import List


def underlying_permutation(word: List[int], strands: int) -> List[int]:
    """Underlying permutation of a braid word in the symmetric group.

    Applies the adjacent transposition (i, i+1) for each letter +-(i+1),
    accumulating a permutation of {0, ..., strands-1}.  The result is the image
    of the braid under the natural quotient homomorphism to S_{strands}; if it is
    not the identity, the braid is nontrivial.  Runs in O(len(word)).
    """
    p: List[int] = list(range(strands))
    for letter in word:
        i = abs(letter) - 1
        p[i], p[i + 1] = p[i + 1], p[i]
    return p
