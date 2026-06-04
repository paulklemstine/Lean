def support(weights: list[int]) -> set[int]:
    mw = max(weights)
    return {i for i, w in enumerate(weights) if w == mw}