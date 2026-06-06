def search_candidates_lower_bound(b: int, n: int, k: int) -> int:
    assert b >= 2 and k + 1 <= n
    return b ** (n - k - 1)