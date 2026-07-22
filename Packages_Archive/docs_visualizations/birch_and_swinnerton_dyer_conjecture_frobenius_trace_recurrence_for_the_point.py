from typing import List

def frobenius_trace_tower(a_p: float, p: float, n_max: int) -> List[float]:
    """
    Compute the point-count tower  #E(F_{p^n}) = p^n + 1 - s_n  for n = 0..n_max,
    where s_n = alpha^n + beta^n satisfies Newton\'s recurrence
        s_0 = 2, s_1 = a_p, s_{k+2} = a_p * s_{k+1} - p * s_k.
    Mirrors the verified theorems traceSeq_eq_power_sum and pointCount.
    Complexity: O(n_max) arithmetic operations, O(n_max) memory.
    """
    if a_p * a_p > 4 * p:
        raise ValueError("Hasse bound a^2 <= 4p violated; not a valid Frobenius trace.")
    s: List[float] = [2.0, a_p]
    for _ in range(2, n_max + 1):
        s.append(a_p * s[-1] - p * s[-2])
    s = s[: n_max + 1]
    return [p ** k + 1 - s[k] for k in range(n_max + 1)]
