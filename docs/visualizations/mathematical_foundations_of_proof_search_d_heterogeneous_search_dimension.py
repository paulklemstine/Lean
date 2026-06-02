def compute_het_search_dimension(levels: list[tuple[int,int]]) -> float:
    log_k_sum = sum(math.log(k) for k, b in levels)
    log_b_sum = sum(math.log(b) for k, b in levels)
    return log_k_sum / log_b_sum