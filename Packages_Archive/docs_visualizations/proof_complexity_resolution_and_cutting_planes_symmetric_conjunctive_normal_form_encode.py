from typing import List, Tuple

Var = Tuple[int, int]
Literal = Tuple[Var, bool]
Clause = List[Literal]

def build_php_cnf(n: int) -> List[Clause]:
    clauses: List[Clause] = []
    for p in range(n + 1):
        clauses.append([((p, h), True) for h in range(n)])
    for h in range(n):
        for p1 in range(n + 1):
            for p2 in range(n + 1):
                if p1 != p2:
                    clauses.append([((p1, h), False), ((p2, h), False)])
    return clauses
