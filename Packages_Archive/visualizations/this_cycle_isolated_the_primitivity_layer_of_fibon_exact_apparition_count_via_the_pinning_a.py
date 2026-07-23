from math import gcd

def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b

def apparition_count_closed_form(n: int, N: int) -> int:
    """#{ m in [1, N] : n | m } = N // n, by the pinning law."""
    return N // n

def joint_apparition_count_closed_form(a: int, b: int, N: int) -> int:
    """#{ m in [1, N] : a | m and b | m } = N // lcm(a, b), by the join law."""
    return N // lcm(a, b)
