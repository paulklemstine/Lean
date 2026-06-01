def arithmetic_mirror_depth(NX: int, NY: int, p: int) -> int:
    return abs(NX + NY - 2 * (1 + p + p**2 + p**3))