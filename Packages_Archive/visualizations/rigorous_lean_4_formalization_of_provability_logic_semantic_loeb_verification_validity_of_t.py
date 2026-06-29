from typing import List, Set, Tuple

Frame = Tuple[List[object], Set[Tuple[object, object]]]

def complement(frame: Frame, S: Set[object]) -> Set[object]:
    worlds, _ = frame
    return set(worlds) - S

def loeb_holds(frame: Frame, S: Set[object]) -> bool:
    boxS = box(frame, S)
    implication = complement(frame, boxS) | S
    return box(frame, implication) <= boxS
