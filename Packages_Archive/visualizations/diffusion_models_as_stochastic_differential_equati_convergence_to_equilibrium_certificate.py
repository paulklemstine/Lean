import math


def convergence_time(m0: float, v0: float, eps: float) -> float:
    """Smallest t* such that |m(t)| < eps and |v(t) - 1| < eps for all t >= t*.

    Since |m(t)| = |m0| exp(-t/2) and |v(t) - 1| = |v0 - 1| exp(-t),
        |m(t)| < eps  <=>  t > 2 log(|m0| / eps),
        |v(t) - 1| < eps  <=>  t > log(|v0 - 1| / eps).
    The certificate is the max of the two thresholds (clamped at 0).
    Complexity: O(1).
    """
    t_mean = 2.0 * math.log(abs(m0) / eps) if abs(m0) > eps else 0.0
    t_var = math.log(abs(v0 - 1.0) / eps) if abs(v0 - 1.0) > eps else 0.0
    return max(0.0, t_mean, t_var)
