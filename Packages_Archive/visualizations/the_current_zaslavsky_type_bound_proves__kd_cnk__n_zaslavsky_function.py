from math import comb

def zaslavsky(m: int, n: int) -> int:
    """Compute Z(m, n) = sum_{k=0}^{n} C(m, k)."""
    return sum(comb(m, k) for k in range(n + 1))

def zaslavsky_iterative(m: int, n: int) -> int:
    """Compute Z(m, n) using iterative binomial update. O(n) time."""
    total = 1  # C(m, 0)
    binom = 1
    for k in range(1, n + 1):
        binom = binom * (m - k + 1) // k
        total += binom
    return total

# Verify both implementations agree
for m in range(20):
    for n in range(20):
        assert zaslavsky(m, n) == zaslavsky_iterative(m, n)
print('Both implementations agree for all m, n < 20')