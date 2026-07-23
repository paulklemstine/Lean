from typing import Tuple


def power_saving_data(k: int) -> Tuple[float, float, bool]:
    assert k >= 2
    c: float = 1.0 / (k * k)
    e: float = k - c
    admissible: bool = (1.0 <= e < k)
    return c, e, admissible
