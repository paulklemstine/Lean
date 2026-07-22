"""Binary-monster verifier: confirm the no-power-of-two-fang law."""
from typing import List, Tuple


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def popcount(n: int) -> int:
    return bin(n).count("1")


def shares_all_digits(b: int, x: int, y: int) -> bool:
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


def binary_monsters(limit: int) -> List[Tuple[int, int, int]]:
    res: List[Tuple[int, int, int]] = []
    for x in range(1, limit):
        for y in range(x, limit):
            if shares_all_digits(2, x, y):
                # laws: both fangs carry >= 2 one-bits and popcounts add up
                assert popcount(x) >= 2 and popcount(y) >= 2
                assert popcount(x) + popcount(y) == popcount(x * y)
                assert popcount(x * y) <= popcount(x) * popcount(y)
                res.append((x, y, x * y))
    return res


if __name__ == "__main__":
    ms = binary_monsters(64)
    print(f"{len(ms)} binary digit-sharing pairs; all fangs have >= 2 one-bits.")
