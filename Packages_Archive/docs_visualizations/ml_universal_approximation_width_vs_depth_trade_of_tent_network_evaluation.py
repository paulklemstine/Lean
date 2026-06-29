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
