def construct_mds_tower(k: int, distances: list[int]) -> list[tuple[int,int,int]]:
    return [(k + 2*d - 2, k, d) for d in distances]