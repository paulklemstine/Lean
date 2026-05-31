def is_tropical_fermat_solution(x: int, y: int, z: int, n: int) -> bool:
    assert n >= 1
    return min(x, y) == z