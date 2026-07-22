from itertools import product
from typing import Iterable, List, Sequence, Tuple

Pattern = Tuple[Tuple[bool, ...], ...]

def count_patterns(widths: Sequence[int]) -> int:
    """Closed-form activation-pattern count = prod 2^{w_i} = 2^{sum w_i}."""
    product_form = 1
    for w in widths:
        product_form *= 2 ** w
    assert product_form == 2 ** sum(widths)
    return product_form

def enumerate_patterns(widths: Sequence[int]) -> Iterable[Pattern]:
    """Explicitly list every activation pattern (validation on small nets)."""
    layer_choices: List[List[Tuple[bool, ...]]] = [
        list(product([False, True], repeat=w)) for w in widths
    ]
    yield from product(*layer_choices)
