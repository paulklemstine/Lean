from __future__ import annotations
from typing import Dict, List, Tuple

Tree = Dict[int, List[int]]  # adjacency list of a tree (undirected)


def chromatic_sum_tree(tree: Tree, root: int = 0, palette: int = 3) -> int:
    """
    Polynomial-time chromatic sum of a TREE (hence any forest, component-wise)
    via dynamic programming over rooted subtrees.

    dp[v][k] = minimum colour sum of the subtree rooted at v, given that v is
    coloured k. For each child u, v contributes the best child cost over all
    child colours k' != k. A tree never needs more than (max degree + 1) colours,
    and for the *sum* optimum a small palette (here `palette`, default 3) always
    suffices; increase it if a graph has very high degree.

    Complexity: O(n * palette^2) time, O(n * palette) space -- polynomial,
    the tractable ('forest') side of the conjectured dichotomy.
    """
    colors = range(1, palette + 1)
    dp: Dict[int, Dict[int, int]] = {}
    order: List[int] = []
    parent: Dict[int, int] = {root: -1}
    stack = [root]
    seen = {root}
    while stack:                       # iterative DFS to get a post-order
        v = stack.pop()
        order.append(v)
        for u in tree[v]:
            if u not in seen:
                seen.add(u)
                parent[u] = v
                stack.append(u)
    for v in reversed(order):          # process children before parents
        dp[v] = {}
        for k in colors:
            total = k
            for u in tree[v]:
                if u == parent[v]:
                    continue
                total += min(dp[u][kp] for kp in colors if kp != k)
            dp[v][k] = total
    return min(dp[root][k] for k in colors)
