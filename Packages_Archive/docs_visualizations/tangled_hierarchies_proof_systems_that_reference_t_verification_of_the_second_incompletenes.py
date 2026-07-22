from typing import Dict, Set

Frame = Dict[int, Set[int]]

def box(frame: Frame, a: Set[int]) -> Set[int]:
    return {w for w in frame if frame[w].issubset(a)}

def consistency(frame: Frame) -> Set[int]:
    """Con = { w : w has at least one successor }."""
    return {w for w in frame if frame[w]}

def verify_collapse(frame: Frame) -> bool:
    """Verify Godel II (box Con subset box bottom) and the tangled hierarchy
    theorem (no consistent world lies in box Con) on a finite frame."""
    con = consistency(frame)
    box_con = box(frame, con)
    box_bot = box(frame, set())
    godel_two = box_con.issubset(box_bot)
    tangled = all(w not in box_con for w in con)
    return godel_two and tangled
