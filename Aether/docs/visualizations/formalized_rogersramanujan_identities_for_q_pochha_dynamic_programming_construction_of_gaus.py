from typing import List

Poly = List[int]  # coefficient list, index = exponent of q

def gaussian_binomial(n: int, k: int) -> Poly:
    """Return [n choose k]_q as an integer coefficient list.

    Uses bottom-up dynamic programming over the q-Pascal recurrence
        [n+1,k+1] = [n,k] + q^{k+1} [n,k+1].
    Time O(n*k*deg), space O(k*deg), deg = k*(n-k).
    """
    # row[j] holds [i choose j]_q for the current i
    row: List[Poly] = [[1]] + [[] for _ in range(k)]
    for i in range(1, n + 1):
        new: List[Poly] = [[1]]
        for j in range(1, k + 1):
            lower = row[j - 1]                       # [i-1, j-1]
            upper = ([0] * j + row[j]) if row[j] else []  # q^j [i-1, j]
            m = max(len(lower), len(upper))
            s = [0] * m
            for t, c in enumerate(lower): s[t] += c
            for t, c in enumerate(upper): s[t] += c
            while s and s[-1] == 0: s.pop()
            new.append(s)
        row = new
    return row[k]
