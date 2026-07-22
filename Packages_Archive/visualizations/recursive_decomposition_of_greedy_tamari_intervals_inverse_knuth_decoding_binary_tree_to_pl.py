from typing import Optional, Tuple

PlaneTree = Tuple[str, Tuple]
Forest = Tuple[PlaneTree, ...]
BinTree = Optional[Tuple[str, "BinTree", "BinTree"]]


def bin_to_forest(b: BinTree) -> Forest:
    """Decode a binary tree back into a plane forest (inverse Knuth transform).

    An internal node bin(l, r) becomes a plane-tree node whose children are the
    decoding of l, followed by the decoding of r as the remaining forest.
    """
    if b is None:
        return ()
    _, l, r = b
    return (("node", bin_to_forest(l)),) + bin_to_forest(r)
