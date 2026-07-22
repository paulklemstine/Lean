from __future__ import annotations

def coulomb_rows(count: int) -> list[tuple[int, int, int]]:
    total = 0
    rows: list[tuple[int, int, int]] = []
    for n in range(1, count + 1):
        capacity = 2 * n * n
        total += capacity
        rows.append((n, capacity, total))
    return rows

if __name__ == "__main__":
    for n, capacity, closure in coulomb_rows(8):
        closed = n * (n + 1) * (2 * n + 1) // 3
        print(n, capacity, closure, "identity:", closure == closed)
