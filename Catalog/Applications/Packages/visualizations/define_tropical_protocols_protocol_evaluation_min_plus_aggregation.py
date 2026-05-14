import math
INF = float('inf')

class TropTree:
    def __init__(self, leaf_value=None, children=None):
        self.leaf_value = leaf_value
        self.children = children
    def is_leaf(self): return self.children is None
    @staticmethod
    def leaf(v): return TropTree(leaf_value=v)
    @staticmethod
    def node(cs): return TropTree(children=cs)

def evaluate(T):
    if T.is_leaf(): return T.leaf_value
    if not T.children: return INF
    return min(c + evaluate(child) for c, child in T.children)

def path_values(T):
    if T.is_leaf(): return [T.leaf_value]
    result = []
    for c, child in (T.children or []):
        for v in path_values(child): result.append(c + v)
    return result

def map_leaves(T, f):
    if T.is_leaf(): return TropTree.leaf(f(T.leaf_value))
    return TropTree.node([(c, map_leaves(ch, f)) for c, ch in T.children])

# Example
T = TropTree.node([(1, TropTree.leaf(5)), (2, TropTree.leaf(1)), (3, TropTree.leaf(4))])
print(f"Value: {evaluate(T)}")
print(f"Path values: {path_values(T)}")
print(f"Bellman check: {evaluate(T) == min(path_values(T))}")

# Gauge invariance
k = 10
T2 = map_leaves(T, lambda a: k + a)
print(f"Shifted value: {evaluate(T2)} == {k} + {evaluate(T)} = {k + evaluate(T)}")
