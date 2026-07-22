from __future__ import annotations
from typing import FrozenSet, Set, Tuple

Statement = FrozenSet[int]
System = Set[Statement]

def power_relations(F: System, G: System) -> Tuple[bool, bool, bool, bool]:
    le_fg = F.issubset(G)
    le_gf = G.issubset(F)
    lt_fg = le_fg and not le_gf
    mind_tool = lt_fg
    incomparable = (not le_fg) and (not le_gf)
    return le_fg, lt_fg, mind_tool, incomparable
