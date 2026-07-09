from itertools import product
from typing import List, Tuple

Assignment = Tuple[bool, ...]

def enumerate_valid() -> List[Assignment]:
    valid = [tuple(a) for a in product([False, True], repeat=4)
             if a[0] != a[1] and a[2] == a[3]]
    assert len(valid) == 4  # card_genericValid (Hull's count)
    for a in valid:
        m = sum(1 for x in a if x)
        assert m in (1, 3)  # mountains_of_genericValid (Maekawa)
    return valid
