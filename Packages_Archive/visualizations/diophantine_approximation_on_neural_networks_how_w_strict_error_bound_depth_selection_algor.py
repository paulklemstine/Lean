from decimal import Decimal
from typing import Iterable, Tuple

def sufficient_depth(epsilon: Decimal) -> int:
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    n, bound = 0, Decimal(1)
    while bound >= epsilon:
        n += 1
        bound /= 2
    return n

def certificates(values: Iterable[str]) -> list[Tuple[Decimal, int, Decimal]]:
    output: list[Tuple[Decimal, int, Decimal]] = []
    for text in values:
        epsilon = Decimal(text)
        n = sufficient_depth(epsilon)
        output.append((epsilon, n, Decimal(2) ** (-n)))
    return output

if __name__ == "__main__":
    for epsilon, n, bound in certificates(["1e-3", "1e-6", "1e-12", "1e-30"]):
        print(f"epsilon={epsilon}, sufficient depth={n}, bound={bound}")
