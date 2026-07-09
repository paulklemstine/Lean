"""Demo: classify a factor pair against the full bestiary."""
from typing import List, Set


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def dset(b: int, n: int) -> Set[int]:
    return set(digits(b, n))


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def classify(b: int, x: int, y: int) -> List[str]:
    v = x * y
    shared = (dset(b, x) | dset(b, y)) & dset(b, v)
    tags: List[str] = []
    if sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, v)):
        tags.append("vampire (digit-sharing)")
    if len(shared) == 1:
        tags.append("werewolf")
    if len(shared) == 0:
        tags.append("ghost")
    if is_prime(x) and is_prime(y):
        tags.append("zombie")
    return tags or ["ordinary"]


if __name__ == "__main__":
    for x, y in [(21, 60), (3, 5), (7, 7), (13, 17)]:
        print(f"{x} x {y} = {x*y}: {classify(10, x, y)}")
