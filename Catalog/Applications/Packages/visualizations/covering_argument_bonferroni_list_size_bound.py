def bonferroni_max_list_size(n: int, d: int, t: int) -> int:
    if d == 0:
        return n // t if t > 0 else float('inf')
    lo, hi = 0, 2 * n + 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        lhs = 2 * mid * t
        rhs = 2 * n + mid * (mid - 1) * d
        if lhs <= rhs:
            lo = mid
        else:
            hi = mid - 1
    return lo

# Example usage
for n, d, t in [(100, 5, 20), (100, 10, 30), (200, 5, 15)]:
    L = bonferroni_max_list_size(n, d, t)
    print(f"n={n}, d={d}, t={t}: max L = {L}")