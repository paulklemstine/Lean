from typing import List, Sequence, Tuple
def encode_svelte(columns: Sequence[Sequence[Sequence[int]]], rows: Sequence[Sequence[Sequence[int]]]) -> List[Tuple[int, ...]]:
    if not columns or not rows: raise ValueError("both types are required")
    m, n = len(columns[0]), len(columns[0][0])
    return [tuple(a[i][j] for a in columns) + tuple(a[i][j] for a in rows) for i in range(m) for j in range(n)]
