from typing import List


def writhe(word: List[int]) -> int:
    """Writhe (exponent sum) of a braid word.

    A braid word is a list of nonzero integers: +(i+1) encodes the Artin
    generator sigma_i, and -(i+1) encodes its inverse.  The writhe is the signed
    crossing count and is a group homomorphism into the integers, hence a braid
    invariant.  Runs in O(len(word)).
    """
    total = 0
    for letter in word:
        total += 1 if letter > 0 else -1
    return total
