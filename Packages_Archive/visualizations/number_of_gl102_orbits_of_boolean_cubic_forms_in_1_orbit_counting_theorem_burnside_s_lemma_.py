from __future__ import annotations
from typing import Callable, Sequence

def orbit_count_burnside(group: Sequence[object],
                         domain: Sequence[object],
                         act: Callable[[object, object], object]) -> int:
    """Number of orbits of a finite group action via the orbit-counting theorem.

    orbits = (1/|G|) * sum_{g in G} |{x : g.x = x}|.
    """
    fixed_sum = 0
    for g in group:
        fixed_sum += sum(1 for x in domain if act(g, x) == x)
    assert fixed_sum % len(group) == 0, "inconsistent: |G| must divide the sum"
    return fixed_sum // len(group)
