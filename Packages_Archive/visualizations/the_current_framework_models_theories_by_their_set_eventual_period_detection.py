def find_eventual_period(step, states, max_n=50):
    """Find the eventual period of the periodic count sequence."""
    def iterate(x, n):
        for _ in range(n): x = step[x]
        return x
    counts = [sum(1 for x in states if iterate(x, n) == x) for n in range(max_n)]
    for p in range(1, max_n // 2):
        for N in range(max_n // 3):
            if all(counts[n] == counts[n+p] for n in range(N, max_n - p)):
                return N, p, counts
    return None, None, counts

step = {0: 3, 1: 5, 2: 0, 3: 1, 4: 2, 5: 4, 6: 6, 7: 3}
N, p, counts = find_eventual_period(step, list(range(8)))
print(f'Eventual period p={p} starting at N={N}')
print(f'First 20 counts: {counts[:20]}')