from itertools import combinations
from typing import Iterable
Edge = tuple[int, int]
def cubic_trace_by_parity(n: int, edges: Iterable[Edge]) -> int:
    es = {tuple(sorted(e)) for e in edges}
    balance = 0
    for a, b, c in combinations(range(n), 3):
        m = sum(tuple(sorted(e)) in es for e in ((a,b),(b,c),(c,a)))
        balance += 1 if m % 2 == 0 else -1
    return 6 * balance
print(cubic_trace_by_parity(3, {(0,1),(1,2),(0,2)}))
