from typing import Dict, List, Set, Tuple

Vertex = int


def greedy_tree_embed(tree_adj: Dict[Vertex, Set[Vertex]],
                      red_adj: Dict[Vertex, Set[Vertex]]) -> Dict[Vertex, Vertex]:
    """
    Greedy leaf-by-leaf embedding of a tree into a red graph of high minimum
    degree. Program underlying the (future) Chvatal upper bound: if the red
    minimum degree is at least n-1, every n-vertex tree embeds.

    Strategy: peel a leaf (degree-one vertex) off the tree, recursively embed
    the rest, then attach the leaf to an unused red neighbor of its parent's
    image. Raises if no slot is available (cannot happen when min red degree
    >= n-1).
    """
    verts: List[Vertex] = list(tree_adj.keys())
    if len(verts) == 1:
        # place the single vertex anywhere
        return {verts[0]: next(iter(red_adj.keys()))}

    # find a leaf and its parent
    leaf = next(v for v in verts if len(tree_adj[v]) == 1)
    parent = next(iter(tree_adj[leaf]))

    sub_adj: Dict[Vertex, Set[Vertex]] = {
        v: (tree_adj[v] - {leaf}) for v in verts if v != leaf
    }
    f = greedy_tree_embed(sub_adj, red_adj)

    used = set(f.values())
    for w in red_adj[f[parent]]:
        if w not in used:
            f[leaf] = w
            return f
    raise ValueError("no free red neighbor: min degree too small")
