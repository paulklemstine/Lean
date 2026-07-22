from typing import List

Poly = List[int]

def schur_polynomial(n: int) -> Poly:
    """Return the Schur / Rogers-Ramanujan polynomial D_n as coefficients.

    Iterates the q-Fibonacci recurrence
        D_0 = D_1 = 1,  D_{i+2} = D_{i+1} + q^{i+1} D_i.
    Time O(n*deg), space O(deg), deg D_n = floor(n^2/4).
    """
    prev, cur = [1], [1]
    if n == 0:
        return prev
    for i in range(n - 1):
        shifted = [0] * (i + 1) + prev            # q^{i+1} * D_i
        m = max(len(cur), len(shifted))
        nxt = [0] * m
        for t, c in enumerate(cur): nxt[t] += c
        for t, c in enumerate(shifted): nxt[t] += c
        while nxt and nxt[-1] == 0: nxt.pop()
        prev, cur = cur, nxt
    return cur
