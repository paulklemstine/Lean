_TAIL = [0, 1, 2, 3, 4, 4, 4, 5, 6]

def admissible_count(N: int) -> int:
    """Exact count of admissible integers in [0, N). O(1) time."""
    q, r = divmod(N, 9)
    return 7 * q + _TAIL[r]

# Verify error bound
for N in [1, 10, 100, 1000, 10000]:
    count = admissible_count(N)
    error = abs(9 * count - 7 * N)
    print(f"N={N:>6}: count={count:>6}, density={count/N:.6f}, |9c-7N|={error} <= 8")