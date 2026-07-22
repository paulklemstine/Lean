from enum import Enum
from typing import Dict

class Edge(Enum):
    FLAT = "flat"; TAB = "tab"; BLANK = "blank"

def comp(e: Edge) -> Edge:
    """Return the shape that physically interlocks with edge `e`."""
    return {Edge.FLAT: Edge.FLAT, Edge.TAB: Edge.BLANK, Edge.BLANK: Edge.TAB}[e]

def is_involution() -> bool:
    """Verify comp(comp(e)) == e for every edge (order-two symmetry)."""
    return all(comp(comp(e)) == e for e in Edge)

def fixed_points() -> Dict[str, bool]:
    """Map each edge to whether it is self-complementary (a border edge)."""
    return {e.value: (comp(e) == e) for e in Edge}
