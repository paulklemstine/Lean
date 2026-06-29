from typing import List
def total_cost(bits_per_step: List[int], tf: float) -> float:
    return sum(bits_per_step) * tf
