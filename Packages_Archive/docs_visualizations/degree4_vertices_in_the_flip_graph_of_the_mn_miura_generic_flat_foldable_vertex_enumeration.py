from itertools import product
from typing import List, Tuple

Config = Tuple[bool, ...]

def mountains(a: Config) -> int:
    return sum(1 for x in a if x)

def enumerate_generic_valid() -> List[Config]:
    valid: List[Config] = []
    for a in (tuple(bits) for bits in product([False, True], repeat=4)):
        if a[0] != a[1] and a[2] == a[3]:
            assert mountains(a) in (1, 3)  # Maekawa's theorem
            valid.append(a)
    assert len(valid) == 4               # Hull's count
    return valid

if __name__ == '__main__':
    for a in enumerate_generic_valid():
        print(''.join('M' if x else 'V' for x in a), mountains(a))
