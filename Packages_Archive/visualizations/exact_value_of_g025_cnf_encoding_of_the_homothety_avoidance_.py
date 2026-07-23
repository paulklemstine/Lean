from typing import List, Tuple

Clause = List[Tuple[int, bool]]  # (variable_id, polarity)

def build_clauses(N: int, r: int,
                  pattern: Tuple[int, int, int] = (0, 2, 5)
                  ) -> Tuple[int, List[Clause]]:
    """
    Encode 'copy-free r-coloring of {1..N}' as a CNF over variables x_{i,c},
    var id = (i-1)*r + c. Returns (num_vars, clauses).
    Totality: OR_c x_{i,c}. Avoidance: for each triple and color c, NOT all equal.
    Clause count Theta(N^2). Satisfiable  <=>  {1..N} does NOT force `pattern`.
    """
    def vid(i: int, c: int) -> int:
        return (i - 1) * r + c

    clauses: List[Clause] = []
    for i in range(1, N + 1):
        clauses.append([(vid(i, c), True) for c in range(r)])  # totality
    top = pattern[-1]
    a = 1
    while 1 + top * a <= N:
        b = 1
        while b + top * a <= N:
            pts = [b + a * s for s in pattern]
            for c in range(r):
                clauses.append([(vid(p, c), False) for p in pts])  # avoidance
            b += 1
        a += 1
    return N * r, clauses
