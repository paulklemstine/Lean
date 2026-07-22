from __future__ import annotations
from dataclasses import dataclass
from typing import Iterator
@dataclass(frozen=True, order=True)
class OrdinalPair:
    blocks: int
    tail: int
    def __post_init__(self) -> None:
        if self.blocks < 0 or self.tail < 0: raise ValueError("nonnegative coordinates required")
    def __str__(self) -> str:
        h = "0" if self.blocks == 0 else ("omega" if self.blocks == 1 else f"omega*{self.blocks}")
        return str(self.tail) if self.blocks == 0 else (h if self.tail == 0 else f"{h}+{self.tail}")

def enumerate_clock(K: int, N: int) -> Iterator[OrdinalPair]:
    if K < 0 or N < 0: raise ValueError("nonnegative cutoffs required")
    for k in range(K):
        for n in range(N): yield OrdinalPair(k,n)
