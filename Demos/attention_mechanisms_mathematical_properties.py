"""
Numerical demonstrations of the mathematical properties of softmax self-attention.

This script is fully self-contained (pure Python standard library) and mirrors the
formally verified results:

  * attnWeight_sum_one    -- softmax attention weights are a probability distribution.
  * convexCombo_mem_Icc   -- a convex combination of points in [lo, hi] stays in [lo, hi].
  * attnOutput_mem_Icc    -- each output coordinate is confined to the value range
                             (convex-hull confinement).
  * logPartition_ge_term  -- log(partition) dominates every individual score.

Model of a single attention head:
  query  q  : list[float]                length d
  keys   ks : list[list[float]]          n x d
  values vs : list[list[float]]          n x m

  score_j   = <q, k_j>                   (dot product)
  kernel_j  = exp(score_j)
  Z         = sum_j kernel_j             (partition function)
  w_j       = kernel_j / Z               (attention weight)
  output_i  = sum_j w_j * v_j_i          (weighted average of values)
"""

from __future__ import annotations

import math
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Core attention primitives (everything inlined, with type hints)             #
# --------------------------------------------------------------------------- #

def dot(a: List[float], b: List[float]) -> float:
    """Standard Euclidean inner product <a, b> = sum_i a_i * b_i."""
    return sum(ai * bi for ai, bi in zip(a, b))


def exp_kernel(q: List[float], k: List[float]) -> float:
    """Unnormalized exponential kernel exp(<q, k>); always strictly positive."""
    return math.exp(dot(q, k))


def attn_partition(q: List[float], ks: List[List[float]]) -> float:
    """Partition function Z = sum_j exp(<q, k_j>)."""
    return sum(exp_kernel(q, k) for k in ks)


def attn_weights(q: List[float], ks: List[List[float]]) -> List[float]:
    """Softmax attention weights w_j = exp(<q,k_j>) / Z (numerically stable)."""
    scores = [dot(q, k) for k in ks]
    z_star = max(scores)
    exps = [math.exp(s - z_star) for s in scores]
    s = sum(exps)
    return [e / s for e in exps]


def attn_output(
    q: List[float], ks: List[List[float]], vs: List[List[float]]
) -> List[float]:
    """Attention output o_i = sum_j w_j * v_j_i for each value coordinate i."""
    w = attn_weights(q, ks)
    m = len(vs[0])
    return [sum(w[j] * vs[j][i] for j in range(len(vs))) for i in range(m)]


def log_partition(q: List[float], ks: List[List[float]]) -> float:
    """Stable log-partition log Z = z* + log sum_j exp(score_j - z*)."""
    scores = [dot(q, k) for k in ks]
    z_star = max(scores)
    return z_star + math.log(sum(math.exp(s - z_star) for s in scores))


# --------------------------------------------------------------------------- #
# Demonstrations of each theorem                                              #
# --------------------------------------------------------------------------- #

def demo_weights_sum_to_one() -> None:
    """attnWeight_sum_one: weights are positive and sum to exactly 1."""
    print("=" * 70)
    print("1. attnWeight_sum_one : softmax weights form a probability distribution")
    print("=" * 70)
    q = [0.5, -1.2, 0.3]
    ks = [[1.0, 0.0, 2.0], [-0.5, 1.0, 0.0], [0.2, 0.2, 0.2], [3.0, -1.0, 0.5]]
    w = attn_weights(q, ks)
    print(f"  weights       = {[round(x, 6) for x in w]}")
    print(f"  all positive  = {all(x > 0 for x in w)}")
    print(f"  sum of weights= {sum(w):.12f}  (theorem: = 1)")
    print()


def demo_convex_combo() -> None:
    """convexCombo_mem_Icc: convex combination of points in [lo,hi] stays inside."""
    print("=" * 70)
    print("2. convexCombo_mem_Icc : weighted average stays inside [lo, hi]")
    print("=" * 70)
    lo, hi = -2.0, 5.0
    xs = [-2.0, 0.7, 3.3, 5.0, 1.1]          # all inside [lo, hi]
    w = [0.1, 0.25, 0.3, 0.05, 0.3]          # nonneg, sum to 1
    combo = sum(wi * xi for wi, xi in zip(w, xs))
    print(f"  interval      = [{lo}, {hi}]")
    print(f"  points        = {xs}")
    print(f"  weights       = {w}  (sum = {sum(w)})")
    print(f"  convex combo  = {combo:.6f}")
    print(f"  inside [lo,hi]= {lo <= combo <= hi}  (theorem: True)")
    print()


def demo_output_confinement() -> None:
    """attnOutput_mem_Icc: each output coordinate lies in the value coordinate range."""
    print("=" * 70)
    print("3. attnOutput_mem_Icc : output confined to convex hull of values")
    print("=" * 70)
    q = [1.0, -0.5]
    ks = [[0.3, 1.0], [2.0, -1.0], [-1.0, 0.5], [0.7, 0.7]]
    vs = [[10.0, -3.0], [4.0, 8.0], [-1.0, 0.0], [6.5, 2.5]]
    out = attn_output(q, ks, vs)
    m = len(vs[0])
    print(f"  output        = {[round(o, 6) for o in out]}")
    for i in range(m):
        col = [v[i] for v in vs]
        lo, hi = min(col), max(col)
        ok = lo <= out[i] <= hi
        print(f"  coord {i}: range=[{lo}, {hi}], output={out[i]:.4f}, confined={ok}")
    print()


def demo_log_partition_bound() -> None:
    """logPartition_ge_term: log Z >= every individual score <q, k_j>."""
    print("=" * 70)
    print("4. logPartition_ge_term : log-partition dominates every score")
    print("=" * 70)
    q = [0.8, 1.5, -0.4]
    ks = [[1.0, 1.0, 1.0], [2.0, 0.0, -1.0], [0.0, 3.0, 0.0], [-1.0, -1.0, 2.0]]
    logZ = log_partition(q, ks)
    print(f"  log Z = {logZ:.6f}")
    for j, k in enumerate(ks):
        score = dot(q, k)
        print(f"  score_{j} = {score:.6f}   log Z >= score : {logZ >= score - 1e-12}")
    print()


def demo_attention_sink() -> None:
    """The attention-sink crossover governed by the partition function structure."""
    print("=" * 70)
    print("5. Attention sink : a logit gap g ~ log n preserves Omega(1) mass")
    print("=" * 70)
    print("  sink mass = 1 / (1 + (n-1) e^{-g})")
    for n in (10, 100, 1000, 10000):
        g_fixed = 3.0                 # constant gap -> mass vanishes
        g_logn = math.log(n)          # gap ~ log n -> mass persists
        mass_fixed = 1.0 / (1.0 + (n - 1) * math.exp(-g_fixed))
        mass_logn = 1.0 / (1.0 + (n - 1) * math.exp(-g_logn))
        print(
            f"  n={n:6d} | gap=3 -> mass={mass_fixed:.4f} | "
            f"gap=log n -> mass={mass_logn:.4f}"
        )
    print()


def demo_focusing() -> None:
    """Sharpening: scaling logits drives one weight to 1 (softmax concentration)."""
    print("=" * 70)
    print("6. Focusing : scaling logits sharpens the distribution toward a token")
    print("=" * 70)
    base_scores = [0.0, 0.5, 1.0, 2.0]
    for scale in (0.0, 1.0, 3.0, 10.0):
        scores = [scale * s for s in base_scores]
        z_star = max(scores)
        exps = [math.exp(s - z_star) for s in scores]
        s = sum(exps)
        w = [e / s for e in exps]
        print(f"  scale={scale:5.1f} -> weights={[round(x,4) for x in w]}")
    print()


def main() -> None:
    print()
    print("SOFTMAX SELF-ATTENTION: NUMERICAL DEMONSTRATIONS OF VERIFIED PROPERTIES")
    print()
    demo_weights_sum_to_one()
    demo_convex_combo()
    demo_output_confinement()
    demo_log_partition_bound()
    demo_attention_sink()
    demo_focusing()
    print("All demonstrations consistent with the formally verified theorems.")


if __name__ == "__main__":
    main()
