from __future__ import annotations
from typing import Sequence

def monodromy_has_section(edge_swaps: Sequence[int]) -> bool:
    """
    Discrete section-existence test for a transversal bundle over a loop of
    directions (a finite model of Theorem 5.3 / cgh_no_section).

    `edge_swaps[k] in {0, 1}` records whether traversing edge k of the loop swaps
    the antipodal pair of geometric-permutation labels (a Z/2 transport). A
    globally consistent continuous section exists iff the total monodromy around
    the loop is trivial, i.e. iff the number of swaps is even.

    Complexity: O(L) for a loop of length L.
    """
    return sum(s % 2 for s in edge_swaps) % 2 == 0

def cgh_obstruction(edge_swaps: Sequence[int]) -> str:
    """Classify the bundle by the classification theorem."""
    if monodromy_has_section(edge_swaps):
        return "section exists => homotopy equivalent to the sphere via projection"
    return "no section => NOT sphere homotopy type (CGH-type obstruction, H_1 nonzero)"