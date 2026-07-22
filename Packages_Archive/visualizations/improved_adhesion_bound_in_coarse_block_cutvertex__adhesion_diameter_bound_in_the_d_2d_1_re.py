from typing import Dict, Set

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def adhesion(bag_i: Set[Vertex], bag_j: Set[Vertex]) -> Set[Vertex]:
    """Adhesion set of two bags: their intersection B_i ∩ B_j. O(min sizes)."""
    return bag_i & bag_j


def adhesion_bound(d: int) -> int:
    """The conditional 4d+2 adhesion-diameter bound in the (d, 2d+1) regime.

    Mathematical basis: an adhesion set is a subset of each of its two bags, and
    diameter is monotone under subsets; a bag of diameter <= 2d+1 therefore
    yields adhesion diameter <= 2d+1 <= 4d+2. Complexity O(1).
    """
    return 4 * d + 2
