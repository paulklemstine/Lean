from typing import Dict, List

Graph = Dict[int, List[int]]


def mixing_time(P: List[List[float]], eps: float = 1e-3,
                max_steps: int = 100000) -> int:
    """Empirical mixing time: steps for mu P^t to reach TV distance < eps to uniform.

    Scales like (1/gap) * log(1/eps).
    """
    n = len(P)
    if n <= 1:
        return 0
    mu = [0.0] * n
    mu[0] = 1.0
    u = 1.0 / n
    for step in range(1, max_steps + 1):
        mu = [sum(mu[i] * P[i][j] for i in range(n)) for j in range(n)]
        if 0.5 * sum(abs(mu[j] - u) for j in range(n)) < eps:
            return step
    return max_steps
