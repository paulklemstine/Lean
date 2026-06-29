import math
from typing import Sequence, Tuple


def biholder_distortion_corridor(dimH_source: float,
                                 r_forward_exponents: Sequence[float],
                                 r_inverse_exponents: Sequence[float]
                                 ) -> Tuple[float, float]:
    """
    Fold a chain of bi-Holder links into the composite distortion corridor.

    Theorem 6.1: forward exponents multiply, inverse exponents multiply, so for
    a chain with forward exponents r_i and inverse exponents r_i' the image
    Hausdorff dimension d satisfies
        dimH_source * (prod r_i')  <=  d  <=  dimH_source / (prod r_i).
    Returns (lower_bound, upper_bound). Linear time in the number of links.
    """
    prod_fwd = math.prod(r_forward_exponents)
    prod_inv = math.prod(r_inverse_exponents)
    return dimH_source * prod_inv, dimH_source / prod_fwd
