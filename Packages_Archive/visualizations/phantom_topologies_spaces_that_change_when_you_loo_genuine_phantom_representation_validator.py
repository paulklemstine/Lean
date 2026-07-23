from typing import FrozenSet, Sequence, Tuple
Topology = FrozenSet[int]
def validate_genuine(topologies: Sequence[Topology]) -> Tuple[bool, Topology]:
    if not topologies: raise ValueError("nonempty family required")
    shared = set(topologies[0])
    for topology in topologies[1:]: shared &= topology
    consensus = frozenset(shared)
    return all(consensus < observer for observer in topologies), consensus
left = frozenset({0, 1, 3})
right = frozenset({0, 2, 3})
print(validate_genuine([left, right]))
