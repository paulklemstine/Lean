from __future__ import annotations
from typing import List

def cumulative_from_distribution(P: List[int], length: int) -> List[int]:
    """Build the cumulative weight-threshold CDF wcount(C, t) from the PMF wexact.

    Given P[w] = #{codewords of weight w}, returns W[0..length] with
    W[t] = wcount(C, t) = sum_{u<=t} P[u] = #{codewords of weight <= t}.
    This is Theorem (CDF-PMF link): wcount = prefix-sum of wexact, and it
    saturates at W[length] = |C|.

    Complexity: O(length).
    """
    W = [0] * (length + 1)
    running = 0
    for t in range(length + 1):
        running += P[t] if t < len(P) else 0
        W[t] = running
    return W
