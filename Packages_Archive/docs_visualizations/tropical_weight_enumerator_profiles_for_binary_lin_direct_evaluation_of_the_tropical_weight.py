from typing import List, Tuple

Codeword = Tuple[int, ...]
Code = List[Codeword]


def weight(c: Codeword) -> int:
    """Hamming weight of a binary codeword."""
    return sum(1 for x in c if x % 2 == 1)


def twe(C: Code, t: float) -> float:
    """Evaluate the tropical weight enumerator twe_C(t) = min_{c in C} wt(c) * t."""
    return min(weight(c) * t for c in C)
