from typing import List

def dual(lam: List[int]) -> List[int]:
    """Contragredient: (L^v)_i = -L_{n-1-i}."""
    n = len(lam)
    return [-lam[n - 1 - i] for i in range(n)]

def twist(k: int, lam: List[int]) -> List[int]:
    """Determinant twist by |det|^k: (twist k L)_i = L_i + k."""
    return [x + k for x in lam]
