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

def artin_mazur_coefficients(
    f: Callable[[int], int], d: int, num_terms: int
) -> List[Fraction]:
    """Compute Artin-Mazur zeta coefficients.

    artinMazurCoeff(f, n) = periodicCount(f, n+1) / (n+1)

    Complexity: O(num_terms · d³ · log(num_terms)) total.

    Args:
        f: Transition function
        d: State space size
        num_terms: Number of coefficients to compute

    Returns:
        List of Artin-Mazur coefficients as exact fractions
    """
    M = build_correspondence_matrix(f, d)
    coeffs = []
    for n in range(num_terms):
        Mn1 = matrix_power(M, n + 1)
        tr = int(np.trace(Mn1))
        coeffs.append(Fraction(tr, n + 1))
    return coeffs