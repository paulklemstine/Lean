import random
from typing import List, Sequence


def expected_empty_monte_carlo(
    p: Sequence[float], j: int, trials: int, seed: int = 0
) -> float:
    """Unbiased Monte Carlo estimate of E_p[U_j^N].

    Simulate draws until first coverage (main collector done), then count how
    many types have been seen fewer than j times.  Average over `trials`.
    """
    rng = random.Random(seed)
    n: int = len(p)
    cumulative: List[float] = []
    acc = 0.0
    for prob in p:
        acc += prob
        cumulative.append(acc)

    def draw() -> int:
        x = rng.random()
        for idx, threshold in enumerate(cumulative):
            if x <= threshold:
                return idx
        return n - 1

    total_empty = 0
    for _ in range(trials):
        counts = [0] * n
        seen_types = 0
        while seen_types < n:
            t = draw()
            if counts[t] == 0:
                seen_types += 1
            counts[t] += 1
        total_empty += sum(1 for c in counts if c < j)
    return total_empty / trials
