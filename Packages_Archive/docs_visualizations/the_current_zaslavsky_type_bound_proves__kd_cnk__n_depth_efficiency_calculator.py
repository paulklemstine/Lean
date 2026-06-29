from math import comb, log2

def zaslavsky(m: int, n: int) -> int:
    return sum(comb(m, k) for k in range(n + 1))

def depth_efficiency(w: int, d: int, L: int) -> dict:
    """Compute depth efficiency metrics."""
    N = w * L
    deep = zaslavsky(w, d) ** L
    shallow_ub = (N + 1) ** d
    return {
        'neurons': N,
        'deep_bound': deep,
        'deep_log2': log2(deep),
        'shallow_upper': shallow_ub,
        'shallow_log2': log2(shallow_ub),
        'gap_log2': log2(deep) - log2(shallow_ub),
        'is_exponential': w <= d
    }

for w, d, L in [(5,10,4), (10,10,10), (8,8,8)]:
    r = depth_efficiency(w, d, L)
    print(f'w={w}, d={d}, L={L}: N={r["neurons"]}, '
          f'deep=2^{r["deep_log2"]:.0f}, shallow≤2^{r["shallow_log2"]:.1f}, '
          f'gap=2^{r["gap_log2"]:.1f}')