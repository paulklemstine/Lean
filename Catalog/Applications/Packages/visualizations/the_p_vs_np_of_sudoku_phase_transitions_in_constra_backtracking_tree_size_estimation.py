def backtracking_tree_analysis(b: float, d: int, p: float) -> tuple[float, str]:
    eff = b * (1 - p)
    size = eff ** d
    phase = 'EASY' if eff < 1 else ('CRITICAL' if eff == 1 else 'HARD')
    return size, phase