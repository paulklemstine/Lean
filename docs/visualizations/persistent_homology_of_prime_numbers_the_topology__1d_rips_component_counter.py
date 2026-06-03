def rips_components_1d(gaps: list[float], epsilon: float) -> int:
    return sum(1 for g in gaps if g > epsilon) + 1