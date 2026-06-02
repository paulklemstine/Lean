def compute_search_dimension(k: int, b: int) -> float:
    if k == 1: return 0.0
    if k == b: return 1.0
    return math.log(k) / math.log(b)