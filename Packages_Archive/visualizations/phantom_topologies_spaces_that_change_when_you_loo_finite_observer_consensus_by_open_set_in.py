from typing import FrozenSet, Sequence
Topology = FrozenSet[int]
def consensus(topologies: Sequence[Topology]) -> Topology:
    if not topologies: raise ValueError("nonempty family required")
    out = set(topologies[0])
    for topology in topologies[1:]: out &= topology
    return frozenset(out)
indiscrete = frozenset({0, 3})
left = frozenset({0, 1, 3})
right = frozenset({0, 2, 3})
shared = consensus([left, right])
print(shared, shared == indiscrete, shared < left and shared < right)
