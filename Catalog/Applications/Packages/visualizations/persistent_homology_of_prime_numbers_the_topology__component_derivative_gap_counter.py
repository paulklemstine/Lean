def component_drop(gaps: list[float], k: int) -> int:
    return sum(1 for g in gaps if g == k + 1)