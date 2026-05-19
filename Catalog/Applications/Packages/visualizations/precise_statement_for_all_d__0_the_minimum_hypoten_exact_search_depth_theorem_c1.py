import math

def max_search_depth(N: int) -> int:
    """Exact maximum depth for hypotenuse <= N. O(1) time. Certified by Theorem C."""
    if N < 5:
        return -1
    D = int((-3 + math.sqrt(2 * N + 1)) / 2)
    while 2*(D+1)**2 + 6*(D+1) + 5 <= N:
        D += 1
    while D >= 0 and 2*D**2 + 6*D + 5 > N:
        D -= 1
    return D

def min_hypotenuse_at_depth(d: int) -> int:
    """Exact minimum hypotenuse at depth d: 2d^2 + 6d + 5. Certified by Theorem A."""
    return 2*d*d + 6*d + 5

# Examples
for N in [100, 1000, 10000, 100000]:
    D = max_search_depth(N)
    print(f"N={N}: depth={D}, min_hyp={min_hypotenuse_at_depth(D)}")