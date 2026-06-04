def sensitivity_analysis(probs: list[float]) -> list[tuple[int, float]]:
    T = 1.0
    for p in probs:
        T *= p
    cofactors = [(i, T / p if p > 0 else float('inf')) for i, p in enumerate(probs)]
    cofactors.sort(key=lambda x: -x[1])
    return cofactors