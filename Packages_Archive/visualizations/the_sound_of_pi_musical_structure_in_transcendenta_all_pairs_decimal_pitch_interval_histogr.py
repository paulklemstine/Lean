from __future__ import annotations
from typing import Sequence

def histogram(digits: Sequence[int]) -> dict[int, int]:
    if any(not 0 <= d <= 9 for d in digits):
        raise ValueError("digits must be in 0,...,9")
    result = {q: 0 for q in range(13)}
    for i in range(len(digits)):
        for j in range(i+1, len(digits)):
            result[abs(digits[i]-digits[j])] += 1
    return result

if __name__ == "__main__":
    h = histogram([3,1,4,1,5,9,2,6])
    print(h)
    print("octave count:", h[12])
