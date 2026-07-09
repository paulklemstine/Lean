from itertools import permutations
from typing import FrozenSet, List, Tuple


def decide_stability(n: int, S: FrozenSet[int]) -> Tuple[bool, int, int]:
    """Decide stability of Cay(Z/n, S) via the cardinality criterion.

    Returns (stable, |Aut(X)|, |Aut(X (x) K2)|).  By expectedHom_injective the
    double cover always has at least 2|Aut(X)| automorphisms; stability holds
    iff equality, i.e. |Aut(X (x) K2)| == 2|Aut(X)|.
    """
    V: List[int] = list(range(n))

    def aut_count_cayley() -> int:
        c = 0
        for perm in permutations(V):
            s = dict(zip(V, perm))
            if all(((s[h] - s[g]) % n in S) == ((h - g) % n in S)
                   for g in V for h in V):
                c += 1
        return c

    def aut_count_double() -> int:
        W: List[Tuple[int, int]] = [(g, a) for g in range(n) for a in (0, 1)]
        adj = [[((q[0] - p[0]) % n in S and p[1] != q[1]) for q in W] for p in W]
        m = len(W)
        image, used, count = [-1] * m, [False] * m, 0

        def consistent(i: int, t: int) -> bool:
            return all(adj[t][image[j]] == adj[i][j]
                       and adj[image[j]][t] == adj[j][i] for j in range(i))

        def bt(i: int) -> None:
            nonlocal count
            if i == m:
                count += 1
                return
            for t in range(m):
                if not used[t] and consistent(i, t):
                    image[i], used[t] = t, True
                    bt(i + 1)
                    used[t] = False

        bt(0)
        return count

    a = aut_count_cayley()
    b = aut_count_double()
    return (b == 2 * a, a, b)
