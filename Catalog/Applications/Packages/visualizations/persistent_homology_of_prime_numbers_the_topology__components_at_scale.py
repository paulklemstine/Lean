def components_at_scale(gaps: list[int], epsilon: int) -> int:
    return 1 + sum(1 for g in gaps if g > epsilon)