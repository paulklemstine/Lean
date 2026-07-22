from typing import List, Set, Tuple

Frame = Tuple[List[object], Set[Tuple[object, object]]]

def successors(w: object, R: Set[Tuple[object, object]]) -> Set[object]:
    return {v for (a, v) in R if a == w}

def box(frame: Frame, S: Set[object]) -> Set[object]:
    worlds, R = frame
    return {w for w in worlds if successors(w, R) <= S}

def diamond(frame: Frame, S: Set[object]) -> Set[object]:
    worlds, R = frame
    return {w for w in worlds if successors(w, R) & S}
