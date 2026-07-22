from math import log2
from typing import List, Sequence, Tuple

def pipeline_dissipation(stage_cards: Sequence[int]) -> Tuple[List[float], float]:
    """Per-stage entropy drops and total dissipation for a deterministic pipeline.

    stage_cards[i] = reachable-state count after stage i, with stage_cards[i+1]
    <= stage_cards[i]. Each drop is nonnegative (data-processing inequality) and
    the drops telescope to the total log2(stage_cards[0]) - log2(stage_cards[-1]).
    """
    drops = [log2(stage_cards[i]) - log2(stage_cards[i + 1])
             for i in range(len(stage_cards) - 1)]
    total = log2(stage_cards[0]) - log2(stage_cards[-1])
    return drops, total
