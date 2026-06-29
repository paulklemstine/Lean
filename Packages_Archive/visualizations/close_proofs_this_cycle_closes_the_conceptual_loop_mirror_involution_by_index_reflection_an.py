from typing import Dict, Tuple

HodgeNumbers = Dict[Tuple[int, int], int]

def mirror(n: int, h: HodgeNumbers) -> HodgeNumbers:
    return {(p, q): h.get((n - p, q), 0)
            for p in range(n + 1) for q in range(n + 1)
            if h.get((n - p, q), 0) != 0}

def euler_char(n: int, h: HodgeNumbers) -> int:
    return sum((-1 if (p + q) % 2 else 1) * h.get((p, q), 0)
               for p in range(n + 1) for q in range(n + 1))

def sign_law(n: int, h: HodgeNumbers) -> Tuple[int, int]:
    chi = euler_char(n, h)
    chi_m = euler_char(n, mirror(n, h))
    assert chi_m == (-1) ** n * chi
    return chi, chi_m
