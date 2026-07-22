from typing import List, Sequence, Tuple
def validate_pair(c: Sequence[Sequence[int]], r: Sequence[Sequence[int]]) -> bool:
    if not c or not c[0] or len(c) != len(r): return False
    m, n = len(c), len(c[0])
    if any(len(x) != n for x in c) or any(len(x) != n for x in r): return False
    if any({c[i][j] for i in range(m)} != set(range(m)) for j in range(n)): return False
    if any(set(r[i]) != set(range(n)) for i in range(m)): return False
    return {(c[i][j], r[i][j]) for i in range(m) for j in range(n)} == {(q,s) for q in range(m) for s in range(n)}
