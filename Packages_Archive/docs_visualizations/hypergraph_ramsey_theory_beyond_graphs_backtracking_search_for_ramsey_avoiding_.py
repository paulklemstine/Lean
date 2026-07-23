from itertools import combinations
from typing import List, Tuple

Subset = Tuple[int, ...]

def find_coloring(n: int, r: int, k: int) -> List[int] | None:
    variables = list(combinations(range(n), r))
    index = {s: i for i, s in enumerate(variables)}
    constraints = [[index[t] for t in combinations(S, r)] for S in combinations(range(n), k)]
    assignment = [-1] * len(variables)
    def solve(i: int) -> bool:
        if i == len(variables): return True
        for color in (0, 1):
            assignment[i] = color
            bad = any(all(assignment[j] != -1 for j in edge) and
                      len({assignment[j] for j in edge}) == 1 for edge in constraints)
            if not bad and solve(i + 1): return True
        assignment[i] = -1
        return False
    return assignment if solve(0) else None

print(find_coloring(5, 3, 4))
