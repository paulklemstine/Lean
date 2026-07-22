from typing import Iterable
def writhe(word: Iterable[int]) -> int:
    """Positive i means sigma_i; negative i means its inverse."""
    total = 0
    for letter in word:
        if letter == 0:
            raise ValueError("zero is not a signed generator")
        total += 1 if letter > 0 else -1
    return total
