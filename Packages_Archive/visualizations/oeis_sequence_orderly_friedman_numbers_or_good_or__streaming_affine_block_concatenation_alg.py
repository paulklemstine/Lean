from __future__ import annotations

def repeated_127(n: int) -> int:
    """Compute the nth repeated-127 term by affine recurrence."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    value = 127
    for _ in range(n):
        value = 1000 * value + 127
    return value

if __name__ == "__main__":
    for i in range(8):
        print(i, repeated_127(i))
