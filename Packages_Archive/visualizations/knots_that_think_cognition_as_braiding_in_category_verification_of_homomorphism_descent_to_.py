from typing import List, Tuple

Letter = Tuple[int, bool]
BraidWord = List[Letter]


def writhe(word: BraidWord) -> int:
    return sum(1 if l[1] else -1 for l in word)


def is_relator_killed(relator: BraidWord) -> bool:
    """Check that a defining braid relator has writhe 0, so the writhe
    homomorphism descends from the free group to the braid group B_n."""
    return writhe(relator) == 0


def far_commutator(i: int, j: int) -> BraidWord:
    assert i + 1 < j
    return [(i, True), (j, True), (i, False), (j, False)]


def braid_relator(i: int) -> BraidWord:
    j = i + 1
    return [(i, True), (j, True), (i, True), (j, False), (i, False), (j, False)]
