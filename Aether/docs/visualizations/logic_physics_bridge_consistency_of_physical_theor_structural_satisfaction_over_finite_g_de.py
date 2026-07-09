from __future__ import annotations
from dataclasses import dataclass
from typing import List, Set, Tuple

@dataclass(frozen=True)
class Form:
    kind: str
    index: int = 0
    left: 'Form | None' = None
    right: 'Form | None' = None

@dataclass
class Frame:
    worlds: List[int]
    R: Set[Tuple[int, int]]
    def successors(self, w: int) -> List[int]:
        return [v for v in self.worlds if (w, v) in self.R]

def sat(frame: Frame, w: int, phi: Form) -> bool:
    if phi.kind == 'bot':
        return False
    if phi.kind == 'imp':
        return (not sat(frame, w, phi.left)) or sat(frame, w, phi.right)
    if phi.kind == 'neg':
        return not sat(frame, w, phi.left)
    if phi.kind == 'box':
        return all(sat(frame, v, phi.left) for v in frame.successors(w))
    raise ValueError(phi.kind)

def valid(frame: Frame, phi: Form) -> bool:
    return all(sat(frame, w, phi) for w in frame.worlds)
