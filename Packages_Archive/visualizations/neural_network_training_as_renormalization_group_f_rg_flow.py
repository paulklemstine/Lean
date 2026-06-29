from typing import Sequence
import math
import numpy as np

def rg_flow(P: np.ndarray, x0: np.ndarray, t: float) -> np.ndarray:
    """
    Closed-form RG training flow (the exact solution of theta' = -(I-P) theta):

        theta(t) = P x0 + exp(-t) * (x0 - P x0).

    The relevant part P x0 is frozen; the irrelevant part (x0 - P x0) relaxes
    exponentially to zero. Cost: one application of P plus O(d) arithmetic.
    """
    Px0 = P @ x0
    return Px0 + math.exp(-t) * (x0 - Px0)
