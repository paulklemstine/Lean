from typing import Dict, Set

Frame = Dict[int, Set[int]]

def worlds(frame: Frame) -> Set[int]:
    return set(frame.keys())

def box(frame: Frame, a: Set[int]) -> Set[int]:
    return {w for w in frame if frame[w].issubset(a)}

def loeb_fixed_point(frame: Frame, a: Set[int]) -> Set[int]:
    """Iterate the transformer Phi(X) = (box X -> A) = (W \ box X) union A to a
    fixed point. On a converse-well-founded frame this terminates, and the
    resulting fixed point equals box A, exhibiting Loeb's identity numerically."""
    w_all = worlds(frame)
    x: Set[int] = set()
    while True:
        nxt = (w_all - box(frame, x)) | a
        # box(Phi antecedent) is the Loeb-relevant quantity; track box X.
        cur_box, new_box = box(frame, x), box(frame, nxt)
        if new_box == cur_box:
            return cur_box
        x = nxt
