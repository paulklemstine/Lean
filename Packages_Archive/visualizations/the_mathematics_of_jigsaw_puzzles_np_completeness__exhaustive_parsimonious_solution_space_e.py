from itertools import product
from typing import List, Sequence, Tuple
Literal = Tuple[int, bool]
Formula = Sequence[Sequence[Literal]]

def sat(a: Tuple[bool, ...], f: Formula) -> bool:
    return all(any((a[i] if i < len(a) else False) == p for i, p in c) for c in f)

def count_solutions(n: int, f: Formula) -> List[Tuple[bool, ...]]:
    return [a for a in product((False, True), repeat=n) if sat(a, f)]

if __name__ == "__main__":
    formula = [[(0, True), (1, True), (2, False)], [(0, False), (2, True)]]
    solutions = count_solutions(3, formula)
    print("piece count:", 2 * 3 + len(formula) + 2)
    print("solutions:", solutions)
    assert len(solutions) == 5
