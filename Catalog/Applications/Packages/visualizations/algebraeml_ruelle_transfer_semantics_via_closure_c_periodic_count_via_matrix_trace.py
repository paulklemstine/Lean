import numpy as np
from typing import Callable, List, Tuple, Optional
from fractions import Fraction
import numpy as np
from typing import List, Tuple
from algorithms import (
    build_correspondence_matrix,
    periodic_count_via_trace,
    row_sum_norm,
    sup_norm,
    weighted_loop_sums,
    trace_growth_bound,
)
import numpy as np
from fractions import Fraction
from typing import Callable, List, Tuple
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from algorithms import (
    build_correspondence_matrix,
    periodic_count_via_trace,
    row_sum_norm,
    weighted_loop_sums,
    trace_growth_bound,
)

def periodic_count(f: Callable[[int], int], d: int, n: int) -> int:
    """Count periodic points of period n: |{x : f^n(x) = x}|."""
    count = 0
    for x in range(d):
        y = x
        for _ in range(n):
            y = f(y)
        if y == x:
            count += 1
    return count