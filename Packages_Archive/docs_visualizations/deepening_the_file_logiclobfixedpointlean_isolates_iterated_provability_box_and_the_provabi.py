from __future__ import annotations
from typing import FrozenSet, List

Statement = FrozenSet[int]

def nat_box(s: Statement, n: int) -> Statement:
    """□S = { m | for all j < m, j in S } over the universe {0,...,n-1}."""
    return frozenset(m for m in range(n) if all(j in s for j in range(m)))

def iterate_box(n: int, k: int) -> List[Statement]:
    """Return [□^0(∅), ..., □^k(∅)]; each equals {0,...,i-1}."""
    cur: Statement = frozenset()
    chain: List[Statement] = [cur]
    for _ in range(k):
        cur = nat_box(cur, n)
        chain.append(cur)
    return chain

def implies(a: Statement, b: Statement, n: int) -> Statement:
    return frozenset(m for m in range(n) if m not in a or m in b)

def graded_godel_ii(n: int) -> List[bool]:
    """For each k, return True iff □^{k+1}⊥'s consistency is UNprovable."""
    chain = iterate_box(n, n)
    out: List[bool] = []
    for k in range(n - 1):
        stmt = chain[k + 1]
        con = implies(stmt, frozenset(), n)
        out.append(nat_box(con, n) != frozenset(range(n)))
    return out
