from __future__ import annotations

def least_positive_avoiding_sum(x: int, y: int) -> int:
    if x < 0 or y < 0:
        raise ValueError("inputs must be nonnegative")
    return 2 if x + y == 1 else 1

def generate(last_index: int) -> list[int]:
    if last_index < 0:
        raise ValueError("index must be nonnegative")
    if last_index == 0:
        return [1]
    values = [1, 1]
    for _ in range(2, last_index + 1):
        values.append(least_positive_avoiding_sum(values[-1], values[-2]))
    return values

if __name__ == "__main__":
    print(generate(25))
