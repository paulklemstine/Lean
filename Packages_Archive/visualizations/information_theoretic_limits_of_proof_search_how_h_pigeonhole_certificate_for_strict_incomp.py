from __future__ import annotations

def strict_compression_obstruction(n: int) -> dict[str, int | bool]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    objects = 1 << n
    shorter_descriptions = objects - 1
    return {
        "objects": objects,
        "shorter_descriptions": shorter_descriptions,
        "deficit": objects - shorter_descriptions,
        "injective_encoding_possible": objects <= shorter_descriptions,
    }
