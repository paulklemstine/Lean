from __future__ import annotations
from collections import Counter
from math import log
from typing import Hashable, Iterable

def fiber_entropy_decomposition(outputs: Iterable[Hashable]) -> dict[str, float]:
    labels = list(outputs)
    if not labels:
        raise ValueError("nonempty source required")
    counts = Counter(labels)
    n = len(labels)
    return {
        "output_entropy": -sum((c/n) * log(c/n) for c in counts.values()),
        "fiber_loss": sum((c/n) * log(c) for c in counts.values()),
        "source_entropy": log(n),
    }
