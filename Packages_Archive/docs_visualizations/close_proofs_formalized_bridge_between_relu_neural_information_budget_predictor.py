from __future__ import annotations
import math

def predicted_search_information(b: float, dimension: float, depth: int) -> float:
    """Predicted total search information (in nats) for a depth-`depth` goal.

    Uses log b - log k = log b * (1 - D) per step (dimension_info_rate) and
    linear accumulation over depth (info_content_decomposition):
        total = depth * log(b) * (1 - D).
    """
    assert b >= 2 and 0.0 <= dimension <= 1.0 and depth >= 0
    return depth * math.log(b) * (1.0 - dimension)
