#!/usr/bin/env python3
"""Numerical demonstrations for anti-gravity theorem dependency spaces.

The script uses only the Python standard library.  An edge (user, foundation)
means that ``user`` directly depends on ``foundation``.
"""

from __future__ import annotations

from collections import Counter, deque
from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Sequence, Set, Tuple

Edge = Tuple[str, str]


@dataclass(frozen=True)
class TheoremSystem:
    """A finite dependency network with natural-number proof lengths."""

    vertices: Tuple[str, ...]
    edges: Tuple[Edge, ...]
    proof_length: Mapping[str, int]

    def __post_init__(self) -> None:
        names = set(self.vertices)
        if len(names) != len(self.vertices):
            raise ValueError("vertex names must be unique")
        if set(self.proof_length) != names:
            raise ValueError("proof lengths must be supplied for every vertex")
        if any(length < 0 for length in self.proof_length.values()):
            raise ValueError("proof lengths must be nonnegative")
        if any(user not in names or base not in names for user, base in self.edges):
            raise ValueError("every edge endpoint must be a vertex")


def gravitational_weights(system: TheoremSystem) -> Dict[str, int]:
    """Return the number of direct users of each theorem in O(n + e) time."""
    weights = {vertex: 0 for vertex in system.vertices}
    for _user, foundation in system.edges:
        weights[foundation] += 1
    return weights


def anti_gravity_set(
    system: TheoremSystem, minimum_weight: int, maximum_length: int
) -> Set[str]:
    """Classify theorems satisfying both influence and brevity thresholds."""
    weights = gravitational_weights(system)
    return {
        vertex
        for vertex in system.vertices
        if weights[vertex] >= minimum_weight
        and system.proof_length[vertex] <= maximum_length
    }


def foundation_to_users(system: TheoremSystem) -> Dict[str, List[str]]:
    """Reverse user-to-foundation edges so searches follow support upward."""
    users: Dict[str, List[str]] = {vertex: [] for vertex in system.vertices}
    for user, foundation in system.edges:
        users[foundation].append(user)
    return users


def support_cone(system: TheoremSystem, foundation: str) -> Set[str]:
    """Compute all theorems reachable from a foundation, including itself."""
    users = foundation_to_users(system)
    reached = {foundation}
    queue = deque([foundation])
    while queue:
        current = queue.popleft()
        for user in users[current]:
            if user not in reached:
                reached.add(user)
                queue.append(user)
    return reached


def is_dependency_dense(system: TheoremSystem, distinguished: Set[str]) -> bool:
    """Test density by checking whether every cone meets the distinguished set."""
    return all(support_cone(system, x) & distinguished for x in system.vertices)


def dense_by_reverse_search(system: TheoremSystem, distinguished: Set[str]) -> bool:
    """Test density in O(n + e) time by searching from targets to foundations."""
    foundations: Dict[str, List[str]] = {vertex: [] for vertex in system.vertices}
    for user, foundation in system.edges:
        foundations[user].append(foundation)
    reached = set(distinguished)
    queue = deque(distinguished)
    while queue:
        current = queue.popleft()
        for base in foundations[current]:
            if base not in reached:
                reached.add(base)
                queue.append(base)
    return len(reached) == len(system.vertices)


def verify_charging(
    system: TheoremSystem,
    anti: Set[str],
    charge: Mapping[str, str],
    capacity: int = 10,
    require_support: bool = False,
) -> Tuple[bool, Dict[str, int]]:
    """Check image, fiber capacity, and optionally support compatibility."""
    if set(charge) != set(system.vertices):
        return False, {}
    counts = Counter(charge.values())
    valid = all(target in anti for target in charge.values())
    valid = valid and all(size <= capacity for size in counts.values())
    if require_support:
        valid = valid and all(
            target in support_cone(system, source)
            for source, target in charge.items()
        )
    return valid, dict(sorted(counts.items()))


def edgeless_counterexample() -> None:
    """Demonstrate that ten short isolated theorems give a zero proportion."""
    vertices = tuple(f"E{i}" for i in range(10))
    system = TheoremSystem(vertices, (), {v: 1 for v in vertices})
    weights = gravitational_weights(system)
    anti = anti_gravity_set(system, minimum_weight=1, maximum_length=1)
    assert all(value == 0 for value in weights.values())
    assert not anti
    print("EDGELESS TEN-THEOREM COUNTEREXAMPLE")
    print(f"weights = {weights}")
    print(f"anti-gravity set at thresholds (1, 1) = {sorted(anti)}")
    print(f"anti-gravity proportion = {len(anti)}/{len(vertices)} = 0%\n")


def density_example() -> None:
    """Build a system whose selected short hubs are dependency-cofinal."""
    vertices = ("f0", "f1", "a", "b", "a1", "a2", "b1", "b2")
    edges: Tuple[Edge, ...] = (
        ("a", "f0"), ("a", "f1"), ("b", "f0"), ("b", "f1"),
        ("a1", "a"), ("a2", "a"), ("a", "a1"), ("a", "a2"),
        ("b1", "b"), ("b2", "b"), ("b", "b1"), ("b", "b2"),
    )
    lengths = {v: 8 for v in vertices}
    lengths.update({"a": 2, "b": 2})
    system = TheoremSystem(vertices, edges, lengths)
    anti = anti_gravity_set(system, minimum_weight=2, maximum_length=2)
    slow = is_dependency_dense(system, anti)
    fast = dense_by_reverse_search(system, anti)
    assert anti == {"a", "b"}
    assert slow and fast
    print("DEPENDENCY-DENSITY EXAMPLE")
    print(f"weights = {gravitational_weights(system)}")
    print(f"anti-gravity set at thresholds (2, 2) = {sorted(anti)}")
    print(f"every dependency cone meets that set = {fast}\n")


def charging_example() -> None:
    """Exhibit a ten-to-one certificate attaining the ten-percent boundary."""
    vertices = tuple(f"T{i:02d}" for i in range(20))
    # T00 and T10 have many direct users and short proofs.
    edges = tuple((f"T{i:02d}", "T00") for i in range(1, 10)) + tuple(
        (f"T{i:02d}", "T10") for i in range(11, 20)
    )
    lengths = {v: 9 for v in vertices}
    lengths["T00"] = lengths["T10"] = 1
    system = TheoremSystem(vertices, edges, lengths)
    anti = anti_gravity_set(system, minimum_weight=9, maximum_length=1)
    charge = {
        vertex: ("T00" if index < 10 else "T10")
        for index, vertex in enumerate(vertices)
    }
    valid, fibers = verify_charging(system, anti, charge, capacity=10)
    assert valid and max(fibers.values()) == 10
    assert len(vertices) == 10 * len(anti)
    print("TEN-PERCENT CHARGING CERTIFICATE")
    print(f"anti-gravity set at thresholds (9, 1) = {sorted(anti)}")
    print(f"fiber sizes = {fibers}")
    print(f"certificate valid = {valid}")
    print(f"count inequality: {len(vertices)} <= 10 * {len(anti)}")
    print(f"anti-gravity proportion = {100 * len(anti) / len(vertices):.1f}%\n")


def threshold_table() -> None:
    """Show monotonic shrinkage as the minimum weight threshold rises."""
    vertices = ("base", "bridge", "u1", "u2", "u3", "u4")
    edges: Tuple[Edge, ...] = (
        ("bridge", "base"), ("u1", "bridge"), ("u2", "bridge"),
        ("u3", "bridge"), ("u4", "base"),
    )
    lengths = {"base": 2, "bridge": 2, "u1": 1, "u2": 1, "u3": 1, "u4": 1}
    system = TheoremSystem(vertices, edges, lengths)
    print("THRESHOLD SENSITIVITY")
    for minimum in range(5):
        anti = anti_gravity_set(system, minimum, maximum_length=2)
        print(f"minimum weight {minimum}: {sorted(anti)}")


def main() -> None:
    edgeless_counterexample()
    density_example()
    charging_example()
    threshold_table()


if __name__ == "__main__":
    main()
