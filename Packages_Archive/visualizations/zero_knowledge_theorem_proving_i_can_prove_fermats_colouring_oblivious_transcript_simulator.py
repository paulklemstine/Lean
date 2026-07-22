import random
from itertools import product
from typing import List, Tuple

Pair = Tuple[int, int]


def distinct_pairs() -> List[Pair]:
    return [(x, y) for (x, y) in product(range(3), range(3)) if x != y]


def simulate_round(rng: random.Random) -> Pair:
    """Sample a transcript with no knowledge of the secret colouring."""
    return rng.choice(distinct_pairs())
