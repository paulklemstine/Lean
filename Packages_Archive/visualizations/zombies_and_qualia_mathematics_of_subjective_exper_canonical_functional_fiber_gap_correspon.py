from typing import Sequence
from demo import GapPair, SheetWorld

def construct_gap_correspondence(profiles: Sequence[str]) -> list[GapPair]:
    return [GapPair(SheetWorld(x, True), SheetWorld(x, False), (x, False)) for x in profiles]
