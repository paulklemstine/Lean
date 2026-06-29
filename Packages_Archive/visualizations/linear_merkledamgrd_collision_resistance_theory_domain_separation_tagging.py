from typing import Callable

def tagged_leaf(g: Callable[[int], int]) -> Callable[[int], int]:
    """Leaf outputs become even."""
    return lambda x: 2 * g(x)

def tagged_node(h: Callable[[int, int], int]) -> Callable[[int, int], int]:
    """Node outputs become odd; ranges now disjoint from leaves."""
    return lambda l, r: 2 * h(l, r) + 1
