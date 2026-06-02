import math
from typing import List, Tuple

def tropical_cost_analysis(errors: List[float]) -> Tuple[float, float, float]:
    """Returns (parallel_cost, sequential_bound, parallel_error)."""
    costs = [-math.log(e) for e in errors]
    parallel_cost = sum(costs)
    sequential_bound = min(costs)
    parallel_error = 1.0
    for e in errors:
        parallel_error *= e
    return parallel_cost, sequential_bound, parallel_error
