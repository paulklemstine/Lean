from typing import List, Optional, Tuple

PlaneTree = Tuple            # a tuple of child plane trees
BinTree = Optional[Tuple]    # None, or (left_subtree, right_subtree)


def forest_to_bin(forest: Tuple[PlaneTree, ...]) -> BinTree:
    """Knuth transform: encode an ordered plane forest as a binary tree.

    The children of the first tree become the LEFT subtree; the remaining
    forest becomes the RIGHT subtree. This is a size-preserving bijection
    from n-node forests onto binary trees with n internal nodes.
    Complexity: O(n) recursive calls, one per node.
    """
    if not forest:
        return None
    head, *rest = forest          # head is itself a tuple of children
    return (forest_to_bin(head), forest_to_bin(tuple(rest)))


def bin_to_forest(tree: BinTree) -> Tuple[PlaneTree, ...]:
    """Inverse Knuth transform: decode a binary tree into a plane forest."""
    if tree is None:
        return ()
    left, right = tree
    return (bin_to_forest(left),) + bin_to_forest(right)
