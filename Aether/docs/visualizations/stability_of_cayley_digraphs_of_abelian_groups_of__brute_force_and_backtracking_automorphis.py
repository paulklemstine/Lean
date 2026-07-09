from itertools import permutations
from typing import Dict, FrozenSet, List


def automorphisms_of_cayley(n: int, S: FrozenSet[int]) -> List[Dict[int, int]]:
    """Brute-force Aut(Cay(Z/n, S)): all permutations preserving h-g in S.

    Complexity O(n! * n^2); feasible for n <= 8.
    """
    V: List[int] = list(range(n))
    result: List[Dict[int, int]] = []
    for perm in permutations(V):
        sigma = dict(zip(V, perm))
        if all(((sigma[h] - sigma[g]) % n in S) == ((h - g) % n in S)
               for g in V for h in V):
            result.append(sigma)
    return result


def automorphism_count_backtracking(adj: List[List[bool]]) -> int:
    """Count adjacency-preserving permutations of a digraph by pruned search.

    Scales to the 2n-vertex double cover where n! enumeration is infeasible.
    """
    n: int = len(adj)
    image: List[int] = [-1] * n
    used: List[bool] = [False] * n
    count: int = 0

    def consistent(i: int, target: int) -> bool:
        return all(adj[target][image[j]] == adj[i][j]
                   and adj[image[j]][target] == adj[j][i]
                   for j in range(i))

    def backtrack(i: int) -> None:
        nonlocal count
        if i == n:
            count += 1
            return
        for target in range(n):
            if not used[target] and consistent(i, target):
                image[i], used[target] = target, True
                backtrack(i + 1)
                used[target] = False

    backtrack(0)
    return count
