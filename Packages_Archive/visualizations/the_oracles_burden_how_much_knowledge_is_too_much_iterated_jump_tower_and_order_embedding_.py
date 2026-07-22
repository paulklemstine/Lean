from typing import Callable, List

Degree = int

def jump_hierarchy(base: Degree, jump: Callable[[Degree], Degree], height: int) -> List[Degree]:
    """Iterate an abstract jump to build the tower base, J(base), ..., J^height(base)."""
    tower = [base]
    for _ in range(height):
        tower.append(jump(tower[-1]))
    return tower

def verify_order_embedding(tower: List[Degree]) -> bool:
    """Check n < m  <=>  tower[n] < tower[m] for all indices: an order embedding of (N,<)."""
    n = len(tower)
    return all((i < j) == (tower[i] < tower[j]) for i in range(n) for j in range(n))
