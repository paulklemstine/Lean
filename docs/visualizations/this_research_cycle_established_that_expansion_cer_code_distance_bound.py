def code_distance_bound(gap: float, inner_dist: float, block_length: int) -> float:
    return (inner_dist - (1.0 - gap)) * block_length