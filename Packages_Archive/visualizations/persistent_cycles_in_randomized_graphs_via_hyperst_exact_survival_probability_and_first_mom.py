from __future__ import annotations
import random

def survival_first_moment(p: float, family: list[frozenset[int]],
                          num_edges: int, trials: int | None = None,
                          seed: int = 0) -> dict[str, object]:
    """Compute exact survival probabilities, the first-moment/union-bound value,
    and (optionally) a Monte-Carlo estimate of Pr[some member survives]."""
    surv: dict[frozenset[int], float] = {S: p ** len(S) for S in family}
    moment: float = sum(surv.values())
    result: dict[str, object] = {"survival": surv, "first_moment": moment}
    if trials is not None:
        rng = random.Random(seed)
        hits = 0
        for _ in range(trials):
            kept = {e for e in range(num_edges) if rng.random() < p}
            if any(S <= kept for S in family):
                hits += 1
        result["monte_carlo"] = hits / trials
    return result
