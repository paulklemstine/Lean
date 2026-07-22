from __future__ import annotations
from collections import Counter
from typing import Hashable, Iterable

def certify_uniform_fibers(outputs: Iterable[Hashable]) -> tuple[int, int] | None:
    labels = list(outputs)
    if not labels:
        raise ValueError("nonempty source required")
    counts = Counter(labels)
    sizes = set(counts.values())
    if len(sizes) != 1:
        return None
    k = next(iter(sizes))
    m = len(counts)
    assert len(labels) == m * k
    return m, k
