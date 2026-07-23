from __future__ import annotations
from typing import List

def convolve_weight_distributions(P: List[int], Q: List[int]) -> List[int]:
    """Cauchy convolution of two finite weight distributions.

    Given P[i] = #{codewords of C with weight i} and Q[j] likewise for D, returns
    R[t] = #{codewords of C (+) D with weight t} = sum_{s<=t} P[s] * Q[t-s].
    This realizes wexact(C (+) D) = wexact(C) * wexact(D), the discrete shadow of
    the weight-enumerator product W_{C(+)D} = W_C * W_D.

    Complexity: O(len(P) * len(Q)) integer multiply-adds.
    """
    R = [0] * (len(P) + len(Q) - 1)
    for s, ps in enumerate(P):
        if ps == 0:
            continue
        for d, qd in enumerate(Q):
            R[s + d] += ps * qd
    return R
