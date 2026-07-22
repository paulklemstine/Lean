from __future__ import annotations
from typing import Hashable, Sequence

def collision_witness(outputs: Sequence[Hashable]) -> tuple[int, int] | None:
    first: dict[Hashable, int] = {}
    for source, output in enumerate(outputs):
        if output in first:
            return first[output], source
        first[output] = source
    return None
