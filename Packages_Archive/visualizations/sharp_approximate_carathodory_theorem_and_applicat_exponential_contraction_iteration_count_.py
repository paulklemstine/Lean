from __future__ import annotations
import math

def refinement_budget(d0: float, lam: float, eps: float
                      ) -> tuple[int, float]:
    """Iteration count and total budget for a contraction process.

    Given initial diameter d0 = d_0, per-step factor lam > 1, and tolerance eps,
    returns (N, budget) where:
      * N = smallest k with (1/lam)^k * d0 < eps           (diam_le_pow)
      * budget = d0 * lam / (lam - 1) >= sum_{k>=0} d_k     (total_budget)
    """
    assert lam > 1.0 and d0 > 0.0 and eps > 0.0
    N = max(0, math.ceil(math.log(d0 / eps) / math.log(lam)))
    budget = d0 * lam / (lam - 1.0)
    return N, budget
