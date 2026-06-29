import math, random
from typing import Set, Tuple
# requires `derivable` from the reachability algorithm above
Edge = Tuple[int, int]

def empirical_threshold(n: int, c: float, trials: int,
                        rng: random.Random, derivable) -> float:
    """Monte-Carlo estimate of Pr[Derivable T 0 (n-1)] at density p = c*log n / n,
    for the random theory on n atoms with i.i.d. edges. Sampling across c traces the
    sharp S-curve whose inflection locates p* ~ log n / n."""
    p = c * math.log(n) / n
    hits = 0
    for _ in range(trials):
        T: Set[Edge] = {(i, j) for i in range(n) for j in range(n)
                        if i != j and rng.random() < p}
        if derivable(T, 0, n - 1):
            hits += 1
    return hits / trials
