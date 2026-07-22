def passes_modular_sieve(x: int, y: int) -> bool:
    v: int = x * y
    if (v - (x + y)) % 9 != 0:
        return False
    if (v - (x + y)) % 3 != 0:
        return False
    if x % 3 == 1 or y % 3 == 1:
        return False
    if ((x - 1) * (y - 1)) % 9 != 1 % 9:
        return False
    return True
