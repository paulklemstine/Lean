def fire_vertex(L: list[list[int]], config: list[int], v: int) -> list[int]:
    new = config[:]
    for w in range(len(config)):
        new[w] += L[w][v]
    return new