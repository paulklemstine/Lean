from typing import Iterator, Tuple

def stream_negative_tower(base: int, components: int, stages: int) -> Iterator[Tuple[int, int, int]]:
    """Yield (stage, dimension, Euler value) without storing the tower."""
    if min(base, components, stages) < 0:
        raise ValueError("inputs must be nonnegative")
    for k in range(stages):
        dimension = -(base + k)
        euler = components if dimension % 2 == 0 else -components
        yield k, dimension, euler
