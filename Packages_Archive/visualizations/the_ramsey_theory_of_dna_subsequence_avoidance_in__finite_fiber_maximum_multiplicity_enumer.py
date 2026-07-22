from __future__ import annotations
from collections import Counter

def maximum_multiplicity(sequence: str, m: int) -> tuple[str, int]:
    if m <= 0:
        raise ValueError("m must be positive")
    counts = Counter(sequence[i*m:(i+1)*m] for i in range(len(sequence)//m))
    if not counts:
        raise ValueError("no complete blocks")
    return counts.most_common(1)[0]

if __name__ == "__main__":
    dna = ("ACGT" * 300)
    print(maximum_multiplicity(dna, 4))
