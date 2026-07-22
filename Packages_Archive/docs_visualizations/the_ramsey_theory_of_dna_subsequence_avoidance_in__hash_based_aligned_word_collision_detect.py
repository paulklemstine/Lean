from __future__ import annotations
from itertools import product
from typing import Optional

def first_collision(sequence: str, m: int) -> Optional[tuple[int, int, str]]:
    if m <= 0:
        raise ValueError("m must be positive")
    seen: dict[str, int] = {}
    for i in range(len(sequence) // m):
        word = sequence[i*m:(i+1)*m]
        if word in seen:
            return seen[word], i, word
        seen[word] = i
    return None

if __name__ == "__main__":
    motifs = ["".join(w) for w in product("ACGT", repeat=4)]
    sequence = "".join(motifs + [motifs[0]])
    print(first_collision(sequence, 4))
