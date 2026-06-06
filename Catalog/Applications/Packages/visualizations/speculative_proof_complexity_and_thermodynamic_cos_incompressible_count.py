def incompressible_count(b: int, n: int) -> int:
    return b**n - (b**n - 1) // (b - 1)