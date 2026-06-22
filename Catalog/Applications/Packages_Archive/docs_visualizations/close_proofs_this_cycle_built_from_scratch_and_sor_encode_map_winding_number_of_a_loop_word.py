from typing import List

def winding_number(word: List[bool]) -> int:
    acc: int = 0
    for b in word:
        acc = acc + 1 if b else acc - 1
    return acc