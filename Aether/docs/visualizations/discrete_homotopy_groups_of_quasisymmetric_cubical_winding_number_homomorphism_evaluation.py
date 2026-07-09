from typing import List, Tuple

Letter = Tuple[int, int]
Word = List[Letter]

TREE_EDGES = (0, 1, 2)
CLOSING_EDGE = 3


def winding_number(word: Word) -> int:
    """Evaluate the winding-number homomorphism pi_1(hollow) -> Z.

    Tree edges map to 0; the closing edge maps to 1. On an arbitrary word this
    is the signed count of the closing edge and is invariant under free
    reduction and under the spanning-tree relations. Two loops are discretely
    homotopic in the hollow square iff they share a winding number.
    Runs in O(n) time.
    """
    return sum(sign for edge, sign in word if edge == CLOSING_EDGE)
