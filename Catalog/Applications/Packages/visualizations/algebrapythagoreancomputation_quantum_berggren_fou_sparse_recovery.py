import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple, Optional
BERG_MATRICES = {
    'A': np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    'B': np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]]),
    'C': np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
}
BERG_LIST = [BERG_MATRICES['A'], BERG_MATRICES['B'], BERG_MATRICES['C']]
ROOT_TRIPLE = np.array([3, 4, 5])

def sparse_recovery(coeffs: Dict, support: set) -> Dict:
    """
    Recover a signal from its wavelet coefficients on a known support.

    If the signal is known to be k-prefix-constant, its support consists only
    of the scaling coefficient and detail coefficients at levels 0, ..., k-1.

    Algorithm:
        restricted_coeffs ← {key: coeffs[key] for key in support}
        return restricted_coeffs

    Theorem (Exact Recovery):
        If ∀ key ∉ support: coeffs[key] = 0, then
        inverse(restricted_coeffs) = inverse(coeffs) = f

    Complexity: O(|support|) time.
    """
    return {k: v for k, v in coeffs.items() if k in support or k == 'scaling'}