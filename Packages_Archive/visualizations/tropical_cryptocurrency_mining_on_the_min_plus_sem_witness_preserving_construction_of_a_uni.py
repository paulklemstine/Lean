from typing import Sequence

def th(m: Sequence[int], h: Sequence[int]) -> int:
    return min(x + a for x, a in zip(m, h))

def collision(m: Sequence[int], h: Sequence[int], hp: Sequence[int]) -> list[int]:
    if len(m) < 3 or not (len(m) == len(h) == len(hp)):
        raise ValueError("equal lengths with dimension at least three required")
    p = min(range(len(m)), key=lambda i: m[i] + h[i])
    r = min(range(len(m)), key=lambda i: m[i] + hp[i])
    q = next(i for i in range(len(m)) if i not in {p, r})
    out = list(m); out[q] += 1
    return out

