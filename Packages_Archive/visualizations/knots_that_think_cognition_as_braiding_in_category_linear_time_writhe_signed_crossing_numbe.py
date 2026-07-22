from typing import List, Tuple

Letter = Tuple[int, bool]
BraidWord = List[Letter]


def writhe(word: BraidWord) -> int:
    """Compute the writhe (signed crossing number) of a braid word in O(k)."""
    total: int = 0
    for _index, sign in word:
        total += 1 if sign else -1
    return total
