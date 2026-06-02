def holonomy(signs: list[int]) -> int:
    h = 1
    for s in signs:
        h *= s
    return h

def is_non_orientable(signs: list[int]) -> bool:
    return holonomy(signs) == -1