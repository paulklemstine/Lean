def fusion_path_count(n: int, outcome: int) -> int:
    if n == 0: return 1 if outcome == 0 else 0
    if n == 1: return 0 if outcome == 0 else 1
    d0, d1 = 0, 1
    for _ in range(n - 1):
        d0, d1 = d1, d0 + d1
    return d0 if outcome == 0 else d1