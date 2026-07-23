from itertools import combinations
from typing import Dict, List, Tuple

Subset = Tuple[int, ...]

def incidence_system(n: int, r: int, k: int) -> tuple[List[Subset], Dict[Subset, List[int]]]:
    variables = list(combinations(range(n), r))
    index = {s: i for i, s in enumerate(variables)}
    constraints = {S: [index[t] for t in combinations(S, r)]
                   for S in combinations(range(n), k)}
    return variables, constraints

variables, constraints = incidence_system(6, 3, 4)
print(len(variables), len(constraints), len(next(iter(constraints.values()))))
