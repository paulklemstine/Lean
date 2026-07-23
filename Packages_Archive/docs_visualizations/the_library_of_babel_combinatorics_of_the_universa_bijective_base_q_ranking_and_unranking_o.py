from typing import Sequence

def rank_word(word: Sequence[int], q: int) -> int:
    if q < 1 or any(d < 0 or d >= q for d in word):
        raise ValueError("invalid base-q word")
    rank = 0
    for digit in word:
        rank = q * rank + digit
    return rank

def unrank_word(rank: int, q: int, n: int) -> tuple[int, ...]:
    if q < 1 or n < 0 or not 0 <= rank < q ** n:
        raise ValueError("invalid rank")
    result = [0] * n
    for i in range(n - 1, -1, -1):
        rank, result[i] = divmod(rank, q)
    return tuple(result)
