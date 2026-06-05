def search_gap(b: int, n: int, k: int) -> tuple:
    gap = n - k - 1
    return (gap, b ** gap)