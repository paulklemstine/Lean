import random
from typing import Tuple

def simulate_view() -> Tuple[int, int]:
    distinct = [(x, y) for x in range(3) for y in range(3) if x != y]
    return random.choice(distinct)
