from __future__ import annotations
import math
from typing import List


def softmax_attention(
    q: List[float],
    ks: List[List[float]],
    vs: List[List[float]],
) -> List[float]:
    """
    Numerically stable single-head softmax self-attention.

    Computes, for query q, keys ks (n x d), and values vs (n x m):
        score_j  = <q, k_j>
        w_j      = softmax(score)_j = exp(score_j) / sum_l exp(score_l)
        output_i = sum_j w_j * vs[j][i]

    Stabilized by subtracting the maximum score (max-subtraction trick),
    justified by the shift-invariance of softmax and the bound
    log Z >= score_j for every j (logPartition_ge_term).

    Returns the output vector of length m. The output is guaranteed to lie
    in the per-coordinate convex hull of the values (attnOutput_mem_Icc).
    """
    n = len(ks)
    m = len(vs[0])
    # 1. scores
    scores: List[float] = [sum(qi * kji for qi, kji in zip(q, k)) for k in ks]
    # 2. stabilizing shift
    z_star: float = max(scores)
    # 3. shifted exponentials
    exps: List[float] = [math.exp(s - z_star) for s in scores]
    # 4. partition
    s: float = sum(exps)
    # 5. weights (sum to one: attnWeight_sum_one)
    w: List[float] = [e / s for e in exps]
    # 6. output
    return [sum(w[j] * vs[j][i] for j in range(n)) for i in range(m)]
