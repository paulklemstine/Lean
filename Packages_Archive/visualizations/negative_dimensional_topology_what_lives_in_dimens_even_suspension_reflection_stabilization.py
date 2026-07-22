from dataclasses import dataclass

@dataclass(frozen=True)
class PureObject:
    dimension: int
    components: int

    @property
    def euler(self) -> int:
        return self.components if self.dimension % 2 == 0 else -self.components

def reflection_stabilize(depth: int, components: int) -> PureObject:
    if depth < 0 or components < 0:
        raise ValueError("inputs must be nonnegative")
    source = PureObject(-depth, components)
    target = PureObject(source.dimension + 2 * depth, components)
    assert target.euler == source.euler
    return target
