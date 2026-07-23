from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple

OpenSet = FrozenSet[int]
Topology = Set[OpenSet]

def join(a: Topology, b: Topology) -> Topology:
    """Lattice join of two finite topologies = sets open in BOTH."""
    return a & b

def collapse_to_two(observers: List[Topology], reality: Topology
                    ) -> Tuple[Topology, Topology]:
    """Given a genuine finite representation whose join is `reality`, bundle
    observers greedily until exactly two strictly-finer joinands remain,
    realizing the lattice collapse principle."""
    assert len(observers) >= 2
    first = observers[0]
    rest = observers[1]
    for obs in observers[2:]:
        rest = join(rest, obs)
    # `first` and `rest` are both strictly finer than reality and join to it.
    return first, rest
