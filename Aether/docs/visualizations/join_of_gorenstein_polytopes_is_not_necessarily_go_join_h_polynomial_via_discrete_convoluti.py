from typing import List


def join_hstar(p: List[int], q: List[int]) -> List[int]:
    """Compute the h*-vector of the join P * Q.

    Models the classical Ehrhart identity h*_{P*Q} = h*_P * h*_Q: the h*-vector of the
    join is the discrete convolution (polynomial product) of the input h*-vectors.
    Complexity O(len(p) * len(q)) directly, or O(n log n) via FFT for large degrees.
    """
    result: List[int] = [0] * (len(p) + len(q) - 1)
    for j, pj in enumerate(p):
        for k, qk in enumerate(q):
            result[j + k] += pj * qk
    return result
