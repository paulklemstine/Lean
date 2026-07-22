from typing import Optional, Tuple

PlaneTree = Tuple[str, Tuple]
Forest = Tuple[PlaneTree, ...]
BinTree = Optional[Tuple[str, "BinTree", "BinTree"]]


def forest_to_bin(f: Forest) -> BinTree:
    """Encode a plane forest as a binary tree via the Knuth transform.

    left subtree  = encoding of the first tree's children
    right subtree = encoding of the remaining forest
    """
    if not f:
        return None
    first, *rest = f
    _, children = first
    return ("bin", forest_to_bin(tuple(children)), forest_to_bin(tuple(rest)))
