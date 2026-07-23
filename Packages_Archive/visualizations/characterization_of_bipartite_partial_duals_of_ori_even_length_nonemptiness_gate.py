from __future__ import annotations
from typing import Sequence

def even_length_gate(hyperedge_lengths: Sequence[int]) -> bool:
    """Return True iff the bipartite family is nonempty, i.e. iff every
    hyperedge has even length (the global all-crossing nonemptiness test)."""
    return all(length % 2 == 0 for length in hyperedge_lengths)
