from typing import List, Sequence
import random


def avg(p: Sequence[float]) -> float:
    """Mean aggregator: social outcome is the average of positions."""
    return sum(p) / len(p)


def fairness_audit(n: int, trials: int = 1000) -> dict:
    """Empirically audit the mean aggregator on n agents against the
    Arrow-style axioms, returning a report dict of booleans.

    Complexity: O(trials * n) per axiom; O(n) profiles for the
    non-dictatorship certificate (one witness per agent).
    """
    report = {}

    # Unanimity: everyone submits c -> outcome c.
    report["unanimity"] = all(
        abs(avg([c] * n) - c) < 1e-9
        for c in (random.uniform(-100, 100) for _ in range(trials))
    )

    # Anonymity: permuting agents leaves the outcome unchanged.
    ok = True
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        q = p[:]
        random.shuffle(q)
        ok = ok and abs(avg(p) - avg(q)) < 1e-9
    report["anonymity"] = ok

    # Monotonicity: weakly increasing every position weakly increases output.
    ok = True
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        q = [pi + random.uniform(0, 10) for pi in p]
        ok = ok and avg(q) >= avg(p) - 1e-9
    report["monotonicity"] = ok

    # Translation invariance: common shift c shifts output by c.
    ok = True
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        c = random.uniform(-100, 100)
        ok = ok and abs(avg([pi + c for pi in p]) - (avg(p) + c)) < 1e-9
    report["translation_invariance"] = ok

    # Non-dictatorship certificate: witness sets agent i to 0, others to 1.
    witnesses: List[float] = []
    for i in range(n):
        profile = [0.0 if j == i else 1.0 for j in range(n)]
        witnesses.append(avg(profile))
    report["non_dictatorship"] = all(abs(w) > 1e-12 for w in witnesses)

    return report
