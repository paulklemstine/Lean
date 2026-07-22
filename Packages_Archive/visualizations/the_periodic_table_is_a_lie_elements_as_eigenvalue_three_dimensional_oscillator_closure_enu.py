from __future__ import annotations

def oscillator_rows(count: int) -> list[tuple[int, int, int]]:
    total = 0
    rows: list[tuple[int, int, int]] = []
    for level in range(count):
        capacity = (level + 1) * (level + 2)
        total += capacity
        rows.append((level, capacity, total))
    return rows

if __name__ == "__main__":
    empirical = [2, 8, 20, 28, 50, 82]
    for (level, capacity, closure), target in zip(oscillator_rows(6), empirical):
        print(level, capacity, closure, target, "match:", closure == target)
