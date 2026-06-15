from __future__ import annotations

def relu(x: float) -> float:
    return max(x, 0.0)

def tent(x: float) -> float:
    "The tent map as an exact width-2 ReLU layer: 1 - relu(2x-1) - relu(1-2x)."
    return 1.0 - relu(2.0 * x - 1.0) - relu(1.0 - 2.0 * x)

def tent_iterate(x: float, k: int) -> float:
    "Depth-k tent network: tent composed with itself k times (O(k) work)."
    for _ in range(k):
        x = tent(x)
    return x

def count_crossings(f, level, samples):
    "Count sign changes of (f - level); for tent^[k] this is ~ 2^k for level in (0,1)."
    grid = [i / (samples - 1) for i in range(samples)]
    vals = [f(x) - level for x in grid]
    return sum(1 for a, b in zip(vals, vals[1:]) if (a < 0 <= b) or (b < 0 <= a))

for k in range(1, 9):
    c = count_crossings(lambda x: tent_iterate(x, k), 0.5, 8 * 2**k + 1)
    print(f"k={k}  2^k={2**k}  crossings={c}")
