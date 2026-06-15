def mantel_ceiling(n: int) -> int:
    return n * n // 4

def forces_triangle(n: int, m: int) -> bool:
    return m > mantel_ceiling(n)
