def local_partition_function(p: int, beta: float) -> float:
    return 1.0 / (1.0 - p ** (-beta))