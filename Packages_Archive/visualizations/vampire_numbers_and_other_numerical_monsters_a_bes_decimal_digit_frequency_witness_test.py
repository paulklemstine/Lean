from collections import Counter
from typing import Tuple

def signature(n: int) -> Tuple[int, ...]:
    counts = Counter(str(n))
    return tuple(counts.get(str(d), 0) for d in range(10))

def witness(x: int, y: int) -> bool:
    left = tuple(a + b for a, b in zip(signature(x), signature(y)))
    return left == signature(x * y)

if __name__ == "__main__":
    print(1260, witness(21, 60), signature(1260))
