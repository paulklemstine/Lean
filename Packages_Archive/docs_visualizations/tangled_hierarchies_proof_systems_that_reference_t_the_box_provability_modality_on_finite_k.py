from typing import Dict, Set

Frame = Dict[int, Set[int]]  # world -> set of successors

def box(frame: Frame, a: Set[int]) -> Set[int]:
    """box A = { w : every successor of w lies in A }, the provability modality.
    Runs in O(|W| + |edges|) by scanning each world's successor set once."""
    return {w for w in frame if frame[w].issubset(a)}

def diamond(frame: Frame, a: Set[int]) -> Set[int]:
    """diamond A = { w : some successor of w lies in A }, consistency-with."""
    return {w for w in frame if frame[w] & a}
