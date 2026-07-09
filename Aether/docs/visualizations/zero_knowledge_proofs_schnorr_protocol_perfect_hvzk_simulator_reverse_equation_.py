import random
from typing import Tuple


def simulate(Y: int, g: int, p: int) -> Tuple[int, int, int]:
    """Perfect-HVZK simulator: no secret used; output ~ honest distribution."""
    c: int = random.randrange(p)
    s: int = random.randrange(p)
    t: int = (s * g - c * Y) % p
    return (t, c, s)
